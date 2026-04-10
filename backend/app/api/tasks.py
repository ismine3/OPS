"""定时任务 API"""
from flask import Blueprint, request, jsonify, g, current_app
import os
import json
import datetime
import shutil
from werkzeug.utils import secure_filename
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required, module_required
from ..utils.operation_log import log_operation
from ..utils.scheduler import (
    add_task_to_scheduler,
    remove_task_from_scheduler,
    get_scheduler_db_config,
)
from ..utils.script_runner import assert_allowed_script, run_script_file

tasks_bp = Blueprint("tasks", __name__, url_prefix="/api/tasks")


def migrate_tasks_table():
    """迁移 scheduled_tasks 表，添加新字段"""
    db = get_db()
    cursor = db.cursor()
    try:
        # 检查 execute_command 字段是否存在
        cursor.execute("""
            SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'scheduled_tasks' AND COLUMN_NAME = 'execute_command'
        """)
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE scheduled_tasks ADD COLUMN `execute_command` VARCHAR(500) COMMENT '自定义执行命令'")
            db.commit()
            print("已添加 execute_command 字段到 scheduled_tasks 表")

        # 检查 script_files 字段是否存在
        cursor.execute("""
            SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'scheduled_tasks' AND COLUMN_NAME = 'script_files'
        """)
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE scheduled_tasks ADD COLUMN `script_files` TEXT COMMENT 'JSON数组，存储多个脚本的相对路径'")
            db.commit()
            print("已添加 script_files 字段到 scheduled_tasks 表")

        # 检查 last_status 字段是否存在
        cursor.execute("""
            SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'scheduled_tasks' AND COLUMN_NAME = 'last_status'
        """)
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE scheduled_tasks ADD COLUMN `last_status` VARCHAR(50) COMMENT '上次执行状态'")
            db.commit()
            print("已添加 last_status 字段到 scheduled_tasks 表")

        # 检查 last_output 字段是否存在
        cursor.execute("""
            SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS 
            WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'scheduled_tasks' AND COLUMN_NAME = 'last_output'
        """)
        if not cursor.fetchone():
            cursor.execute("ALTER TABLE scheduled_tasks ADD COLUMN `last_output` TEXT COMMENT '上次执行输出'")
            db.commit()
            print("已添加 last_output 字段到 scheduled_tasks 表")

    except Exception as e:
        print(f"迁移 scheduled_tasks 表失败: {str(e)}")
    finally:
        cursor.close()


@tasks_bp.record_once
def on_register(state):
    """蓝图注册时执行迁移"""
    with state.app.app_context():
        migrate_tasks_table()


def get_script_upload_path():
    """获取脚本上传目录路径"""
    upload_folder = current_app.config.get('UPLOAD_FOLDER')
    scripts_dir = os.path.join(upload_folder, 'scripts')
    if not os.path.exists(scripts_dir):
        os.makedirs(scripts_dir)
    return scripts_dir


def get_task_dir(task_id):
    """获取任务文件目录路径"""
    scripts_dir = get_script_upload_path()
    task_dir = os.path.join(scripts_dir, str(task_id))
    if not os.path.exists(task_dir):
        os.makedirs(task_dir)
    return task_dir


def allowed_script_file(filename):
    """检查文件扩展名是否允许（.py 和 .sh）"""
    if not filename or '.' not in filename:
        return False
    ext = filename.rsplit('.', 1)[1].lower()
    return ext in {'py', 'sh'}


@tasks_bp.route('', methods=['GET'])
@jwt_required
@module_required('tasks')
def get_tasks():
    """获取任务列表"""
    db = get_db()
    cursor = db.cursor()
    
    try:
        cursor.execute("""
            SELECT t.*, u.username as creator_name
            FROM scheduled_tasks t
            LEFT JOIN users u ON t.created_by = u.id
            ORDER BY t.created_at DESC
        """)
        tasks = cursor.fetchall()
        
        # 解析 script_files JSON 字段
        for task in tasks:
            if task['script_files']:
                try:
                    task['script_files'] = json.loads(task['script_files'])
                except:
                    task['script_files'] = []
            else:
                task['script_files'] = []
        
        return jsonify({
            'code': 200,
            'data': tasks
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'获取任务列表失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@tasks_bp.route('', methods=['POST'])
@jwt_required
@module_required('tasks')
@role_required(['admin', 'operator'])
def create_task():
    """创建任务"""
    # 获取表单数据
    name = request.form.get('name')
    description = request.form.get('description', '')
    cron_expression = request.form.get('cron_expression')
    execute_command = request.form.get('execute_command', '')  # 可选的自定义命令
    
    if not name:
        return jsonify({'code': 400, 'message': '任务名称不能为空'}), 400
    if not cron_expression:
        return jsonify({'code': 400, 'message': 'Cron 表达式不能为空'}), 400
    
    # 检查脚本文件（支持多文件上传）
    script_files = request.files.getlist('script_files')
    if not script_files or all(f.filename == '' for f in script_files):
        return jsonify({'code': 400, 'message': '请上传至少一个脚本文件'}), 400
    
    # 过滤有效的文件
    valid_files = [f for f in script_files if f.filename != '']
    
    # 验证文件扩展名
    for script_file in valid_files:
        if not allowed_script_file(script_file.filename):
            return jsonify({'code': 400, 'message': f'不支持的文件类型: {script_file.filename}，仅支持 .py 和 .sh 文件'}), 400
    
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 先创建任务记录获取 task_id
        cursor.execute("""
            INSERT INTO scheduled_tasks 
            (name, task_type, description, cron_expression, execute_command, is_active, created_by, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            name, 
            'script', 
            description, 
            cron_expression,
            execute_command if execute_command else None,
            True, 
            g.current_user['user_id'],
            datetime.datetime.now()
        ))
        db.commit()
        task_id = cursor.lastrowid
        
        # 创建任务目录
        task_dir = get_task_dir(task_id)
        
        # 保存所有文件到任务目录
        saved_files = []
        for script_file in valid_files:
            filename = secure_filename(script_file.filename)
            file_path = os.path.join(task_dir, filename)
            # 如果文件名冲突，添加序号
            base_name, ext = os.path.splitext(filename)
            counter = 1
            while os.path.exists(file_path):
                filename = f"{base_name}_{counter}{ext}"
                file_path = os.path.join(task_dir, filename)
                counter += 1
            script_file.save(file_path)
            saved_files.append(filename)
        
        # 更新任务记录，保存文件列表
        script_files_json = json.dumps(saved_files)
        
        # 向后兼容：如果只有一个文件且没有自定义命令，设置 script_path
        script_path = None
        if len(saved_files) == 1 and not execute_command:
            script_path = os.path.join(task_dir, saved_files[0])
        
        cursor.execute("""
            UPDATE scheduled_tasks 
            SET script_files = %s, script_path = %s
            WHERE id = %s
        """, (script_files_json, script_path, task_id))
        db.commit()
        
        # 添加到调度器
        db_config = get_scheduler_db_config()
        if db_config:
            add_task_to_scheduler(task_id, script_path, cron_expression, db_config, execute_command, task_dir)
        
        # 记录操作日志
        log_operation('定时任务', 'create', task_id, name, {'cron': cron_expression, 'files': saved_files})
        
        return jsonify({
            'code': 200,
            'message': '任务创建成功',
            'data': {
                'task_id': task_id,
                'script_files': saved_files
            }
        })
    except Exception as e:
        # 删除已创建的任务目录
        task_dir = os.path.join(get_script_upload_path(), str(task_id)) if 'task_id' in dir() else None
        if task_dir and os.path.exists(task_dir):
            shutil.rmtree(task_dir)
        return jsonify({
            'code': 500,
            'message': f'创建任务失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@tasks_bp.route('/<int:task_id>', methods=['PUT'])
@jwt_required
@module_required('tasks')
@role_required(['admin', 'operator'])
def update_task(task_id):
    """更新任务"""
    name = request.form.get('name')
    description = request.form.get('description')
    cron_expression = request.form.get('cron_expression')
    execute_command = request.form.get('execute_command')  # 可选更新
    remove_files_json = request.form.get('remove_files')  # 要删除的文件列表（JSON数组）
    
    if not name:
        return jsonify({'code': 400, 'message': '任务名称不能为空'}), 400
    if not cron_expression:
        return jsonify({'code': 400, 'message': 'Cron 表达式不能为空'}), 400
    
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 获取当前任务信息
        cursor.execute("SELECT * FROM scheduled_tasks WHERE id = %s", (task_id,))
        task = cursor.fetchone()
        
        if not task:
            return jsonify({'code': 404, 'message': '任务不存在'}), 404
        
        # 获取任务目录
        task_dir = get_task_dir(task_id)
        
        # 解析现有的文件列表
        current_files = []
        if task['script_files']:
            try:
                current_files = json.loads(task['script_files'])
            except:
                current_files = []
        
        # 处理要删除的文件
        if remove_files_json:
            try:
                remove_files = json.loads(remove_files_json)
                for filename in remove_files:
                    file_path = os.path.join(task_dir, filename)
                    if os.path.exists(file_path):
                        os.remove(file_path)
                    if filename in current_files:
                        current_files.remove(filename)
            except json.JSONDecodeError:
                pass
        
        # 处理新上传的文件
        new_files = request.files.getlist('script_files')
        for script_file in new_files:
            if script_file.filename != '':
                if not allowed_script_file(script_file.filename):
                    return jsonify({'code': 400, 'message': f'不支持的文件类型: {script_file.filename}，仅支持 .py 和 .sh 文件'}), 400
                
                filename = secure_filename(script_file.filename)
                file_path = os.path.join(task_dir, filename)
                # 如果文件名冲突，添加序号
                base_name, ext = os.path.splitext(filename)
                counter = 1
                while os.path.exists(file_path):
                    filename = f"{base_name}_{counter}{ext}"
                    file_path = os.path.join(task_dir, filename)
                    counter += 1
                script_file.save(file_path)
                if filename not in current_files:
                    current_files.append(filename)
        
        # 更新 script_files JSON
        script_files_json = json.dumps(current_files) if current_files else None
        
        # 处理 execute_command
        if execute_command is None:
            execute_command = task['execute_command']
        
        # 向后兼容：更新 script_path
        script_path = task['script_path']
        if len(current_files) == 1 and not execute_command:
            script_path = os.path.join(task_dir, current_files[0])
        elif len(current_files) == 0:
            script_path = None
        
        # 更新任务记录
        cursor.execute("""
            UPDATE scheduled_tasks 
            SET name = %s, description = %s, cron_expression = %s, 
                execute_command = %s, script_files = %s, script_path = %s, updated_at = %s
            WHERE id = %s
        """, (name, description, cron_expression, execute_command, script_files_json, script_path, datetime.datetime.now(), task_id))
        
        db.commit()
        
        # 如果任务是活跃的，重新添加到调度器
        if task['is_active']:
            remove_task_from_scheduler(task_id)
            db_config = get_scheduler_db_config()
            if db_config:
                add_task_to_scheduler(task_id, script_path, cron_expression, db_config, execute_command, task_dir)
        
        # 记录操作日志
        log_operation('定时任务', 'update', task_id, name, {'cron': cron_expression})
        
        return jsonify({
            'code': 200,
            'message': '任务更新成功',
            'data': {
                'script_files': current_files
            }
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'更新任务失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@tasks_bp.route('/<int:task_id>', methods=['DELETE'])
@jwt_required
@module_required('tasks')
@role_required(['admin', 'operator'])
def delete_task(task_id):
    """删除任务"""
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 获取任务信息
        cursor.execute("SELECT name, script_path, script_files FROM scheduled_tasks WHERE id = %s", (task_id,))
        task = cursor.fetchone()
        
        if not task:
            return jsonify({'code': 404, 'message': '任务不存在'}), 404
        
        task_name = task['name']
        script_path = task['script_path']
        
        # 从调度器移除
        remove_task_from_scheduler(task_id)
        
        # 删除任务目录及其所有文件
        task_dir = os.path.join(get_script_upload_path(), str(task_id))
        if os.path.exists(task_dir):
            shutil.rmtree(task_dir)
        
        # 兼容旧数据：如果 script_path 是在 scripts 根目录下，也删除它
        if script_path and os.path.exists(script_path):
            # 检查是否在任务目录外（旧数据）
            if not script_path.startswith(task_dir):
                os.remove(script_path)
        
        # 删除相关日志
        cursor.execute("DELETE FROM task_logs WHERE task_id = %s", (task_id,))
        
        # 删除任务
        cursor.execute("DELETE FROM scheduled_tasks WHERE id = %s", (task_id,))
        
        db.commit()
        
        # 记录操作日志
        log_operation('定时任务', 'delete', task_id, task_name)
        
        return jsonify({
            'code': 200,
            'message': '任务删除成功'
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'删除任务失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@tasks_bp.route('/<int:task_id>/toggle', methods=['POST'])
@jwt_required
@module_required('tasks')
@role_required(['admin', 'operator'])
def toggle_task(task_id):
    """启用/禁用任务"""
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 获取任务信息
        cursor.execute("SELECT * FROM scheduled_tasks WHERE id = %s", (task_id,))
        task = cursor.fetchone()
        
        if not task:
            return jsonify({'code': 404, 'message': '任务不存在'}), 404
        
        # 切换状态
        new_status = not task['is_active']
        
        cursor.execute("""
            UPDATE scheduled_tasks SET is_active = %s, updated_at = %s WHERE id = %s
        """, (new_status, datetime.datetime.now(), task_id))
        
        db.commit()
        
        # 更新调度器
        db_config = get_scheduler_db_config()
        if new_status:
            # 启用：添加到调度器
            # 确定任务目录
            task_dir = os.path.join(get_script_upload_path(), str(task_id))
            execute_command = task['execute_command']
            script_path = task['script_path']
            
            # 判断使用哪种模式
            if execute_command and task_dir and os.path.isdir(task_dir):
                # 使用自定义命令模式
                if db_config:
                    add_task_to_scheduler(task_id, script_path, task['cron_expression'], db_config, execute_command, task_dir)
            elif script_path and os.path.exists(script_path):
                # 向后兼容：使用单文件模式
                if db_config:
                    add_task_to_scheduler(task_id, script_path, task['cron_expression'], db_config)
            message = '任务已启用'
        else:
            # 禁用：从调度器移除
            remove_task_from_scheduler(task_id)
            message = '任务已禁用'
        
        return jsonify({
            'code': 200,
            'message': message,
            'data': {'is_active': new_status}
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'切换任务状态失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@tasks_bp.route('/<int:task_id>/run', methods=['POST'])
@jwt_required
@module_required('tasks')
@role_required(['admin', 'operator'])
def run_task(task_id):
    """手动执行任务"""
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 获取任务信息
        cursor.execute("SELECT * FROM scheduled_tasks WHERE id = %s", (task_id,))
        task = cursor.fetchone()
        
        if not task:
            return jsonify({'code': 404, 'message': '任务不存在'}), 404
        
        # 确定任务目录和执行方式
        task_dir = os.path.join(get_script_upload_path(), str(task_id))
        execute_command = task['execute_command']
        script_path = task['script_path']
        
        # 检查任务是否可执行
        has_custom_command = execute_command and task_dir and os.path.isdir(task_dir)
        has_script_file = script_path and os.path.exists(script_path)
        
        if not has_custom_command and not has_script_file:
            return jsonify({"code": 400, "message": "任务没有配置有效的执行命令或脚本文件"}), 400

        db_config = get_scheduler_db_config()
        if not db_config:
            return (
                jsonify(
                    {
                        "code": 503,
                        "message": "任务调度服务未就绪，请稍后重试或重启后端服务",
                    }
                ),
                503,
            )

        start_time = datetime.datetime.now()
        cursor.execute(
            """
            INSERT INTO task_logs (task_id, status, start_time, triggered_by)
            VALUES (%s, %s, %s, %s)
            """,
            (task_id, "running", start_time, "manual"),
        )
        db.commit()
        log_id = cursor.lastrowid

        task_id_ref = task_id
        script_path_ref = script_path
        execute_command_ref = execute_command
        task_dir_ref = task_dir

        def run_manual():
            import subprocess
            import pymysql
            from ..utils.script_runner import run_script_file, run_custom_command

            def _finish(status, output=None, error_message=None):
                end_time = datetime.datetime.now()
                conn = None
                cur = None
                preview = (output or error_message or "")[:500] or None
                try:
                    conn = pymysql.connect(**db_config)
                    cur = conn.cursor()
                    cur.execute(
                        """
                        UPDATE task_logs
                        SET status = %s, end_time = %s, output = %s, error_message = %s
                        WHERE id = %s
                        """,
                        (status, end_time, output, error_message, log_id),
                    )
                    cur.execute(
                        """
                        UPDATE scheduled_tasks
                        SET last_run_at = %s, last_status = %s, last_output = %s
                        WHERE id = %s
                        """,
                        (start_time, status, preview, task_id_ref),
                    )
                    conn.commit()
                finally:
                    if cur:
                        cur.close()
                    if conn:
                        conn.close()

            try:
                # 优先使用自定义执行命令
                if execute_command_ref and task_dir_ref and os.path.isdir(task_dir_ref):
                    result = run_custom_command(execute_command_ref, task_dir_ref, timeout=300)
                elif script_path_ref:
                    result = run_script_file(script_path_ref, db_config=db_config, timeout=300)
                else:
                    _finish("failed", None, "任务没有配置执行命令或脚本路径")
                    return
            except subprocess.TimeoutExpired:
                _finish("failed", None, "脚本执行超时（超过300秒）")
                return
            except (FileNotFoundError, RuntimeError, ValueError) as e:
                _finish("failed", None, str(e))
                return
            except Exception as e:
                _finish("failed", None, str(e))
                return

            if result.returncode == 0:
                out = result.stdout if result.stdout else "执行成功，无输出"
                _finish("success", out, None)
            else:
                out = result.stdout if result.stdout else ""
                err_msg = result.stderr if result.stderr else "执行失败"
                _finish("failed", out, err_msg)

        import threading

        thread = threading.Thread(target=run_manual)
        thread.daemon = True
        thread.start()

        return jsonify({"code": 200, "message": "任务已开始执行"})
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'执行任务失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@tasks_bp.route('/<int:task_id>/logs', methods=['GET'])
@jwt_required
@module_required('tasks')
def get_task_logs(task_id):
    """获取任务执行日志"""
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 验证任务是否存在
        cursor.execute("SELECT id FROM scheduled_tasks WHERE id = %s", (task_id,))
        if not cursor.fetchone():
            return jsonify({'code': 404, 'message': '任务不存在'}), 404
        
        # 获取最近50条日志
        cursor.execute("""
            SELECT * FROM task_logs 
            WHERE task_id = %s 
            ORDER BY start_time DESC 
            LIMIT 50
        """, (task_id,))
        
        logs = cursor.fetchall()
        
        return jsonify({
            'code': 200,
            'data': logs
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'获取日志失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
