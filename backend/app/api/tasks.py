"""定时任务 API"""
from flask import Blueprint, request, jsonify, g, current_app
import os
import datetime
from werkzeug.utils import secure_filename
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required
from ..utils.operation_log import log_operation
from ..utils.scheduler import (
    add_task_to_scheduler, 
    remove_task_from_scheduler,
    get_scheduler_db_config,
    execute_script
)

tasks_bp = Blueprint('tasks', __name__, url_prefix='/api/tasks')


def allowed_file(filename):
    """检查文件扩展名是否允许"""
    ALLOWED_EXTENSIONS = {'py', 'sh', 'sql'}
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS


def get_script_upload_path():
    """获取脚本上传目录路径"""
    upload_folder = current_app.config.get('UPLOAD_FOLDER')
    scripts_dir = os.path.join(upload_folder, 'scripts')
    if not os.path.exists(scripts_dir):
        os.makedirs(scripts_dir)
    return scripts_dir


@tasks_bp.route('', methods=['GET'])
@jwt_required
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
        db.close()


@tasks_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def create_task():
    """创建任务"""
    # 获取表单数据
    name = request.form.get('name')
    description = request.form.get('description', '')
    cron_expression = request.form.get('cron_expression')
    
    if not name:
        return jsonify({'code': 400, 'message': '任务名称不能为空'}), 400
    if not cron_expression:
        return jsonify({'code': 400, 'message': 'Cron 表达式不能为空'}), 400
    
    # 检查脚本文件
    if 'script' not in request.files:
        return jsonify({'code': 400, 'message': '请上传脚本文件'}), 400
    
    script_file = request.files['script']
    if script_file.filename == '':
        return jsonify({'code': 400, 'message': '请选择脚本文件'}), 400
    
    # 保存脚本文件
    scripts_dir = get_script_upload_path()
    timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    filename = secure_filename(script_file.filename)
    unique_filename = f"{timestamp}_{filename}"
    script_path = os.path.join(scripts_dir, unique_filename)
    script_file.save(script_path)
    
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 插入任务记录
        cursor.execute("""
            INSERT INTO scheduled_tasks 
            (name, task_type, description, cron_expression, script_path, is_active, created_by, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            name, 
            'script', 
            description, 
            cron_expression, 
            script_path, 
            True, 
            g.current_user['user_id'],
            datetime.datetime.now()
        ))
        
        db.commit()
        task_id = cursor.lastrowid
        
        # 添加到调度器
        db_config = get_scheduler_db_config()
        if db_config:
            add_task_to_scheduler(task_id, script_path, cron_expression, db_config)
        
        # 记录操作日志
        log_operation('定时任务', 'create', task_id, name, {'cron': cron_expression})
        
        return jsonify({
            'code': 200,
            'message': '任务创建成功'
        })
    except Exception as e:
        # 删除已保存的文件
        if os.path.exists(script_path):
            os.remove(script_path)
        return jsonify({
            'code': 500,
            'message': f'创建任务失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@tasks_bp.route('/<int:task_id>', methods=['PUT'])
@jwt_required
@role_required(['admin', 'operator'])
def update_task(task_id):
    """更新任务"""
    name = request.form.get('name')
    description = request.form.get('description')
    cron_expression = request.form.get('cron_expression')
    
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
        
        script_path = task['script_path']
        
        # 如果上传了新脚本文件
        if 'script' in request.files:
            script_file = request.files['script']
            if script_file.filename != '':
                # 删除旧文件
                if script_path and os.path.exists(script_path):
                    os.remove(script_path)
                
                # 保存新文件
                scripts_dir = get_script_upload_path()
                timestamp = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
                filename = secure_filename(script_file.filename)
                unique_filename = f"{timestamp}_{filename}"
                script_path = os.path.join(scripts_dir, unique_filename)
                script_file.save(script_path)
        
        # 更新任务记录
        cursor.execute("""
            UPDATE scheduled_tasks 
            SET name = %s, description = %s, cron_expression = %s, script_path = %s, updated_at = %s
            WHERE id = %s
        """, (name, description, cron_expression, script_path, datetime.datetime.now(), task_id))
        
        db.commit()
        
        # 如果任务是活跃的，重新添加到调度器
        if task['is_active']:
            remove_task_from_scheduler(task_id)
            db_config = get_scheduler_db_config()
            if db_config:
                add_task_to_scheduler(task_id, script_path, cron_expression, db_config)
        
        # 记录操作日志
        log_operation('定时任务', 'update', task_id, name, {'cron': cron_expression})
        
        return jsonify({
            'code': 200,
            'message': '任务更新成功'
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'更新任务失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@tasks_bp.route('/<int:task_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_task(task_id):
    """删除任务"""
    db = get_db()
    cursor = db.cursor()
    
    try:
        # 获取任务信息
        cursor.execute("SELECT name, script_path FROM scheduled_tasks WHERE id = %s", (task_id,))
        task = cursor.fetchone()
        
        if not task:
            return jsonify({'code': 404, 'message': '任务不存在'}), 404
        
        task_name = task['name']
        script_path = task['script_path']
        
        # 从调度器移除
        remove_task_from_scheduler(task_id)
        
        # 删除脚本文件
        if script_path and os.path.exists(script_path):
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
        db.close()


@tasks_bp.route('/<int:task_id>/toggle', methods=['POST'])
@jwt_required
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
            if task['script_path'] and os.path.exists(task['script_path']) and db_config:
                add_task_to_scheduler(task_id, task['script_path'], task['cron_expression'], db_config)
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
        db.close()


@tasks_bp.route('/<int:task_id>/run', methods=['POST'])
@jwt_required
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
        
        if not task['script_path'] or not os.path.exists(task['script_path']):
            return jsonify({'code': 400, 'message': '脚本文件不存在'}), 400
        
        # 在新线程中执行脚本
        db_config = get_scheduler_db_config()
        if db_config:
            # 创建手动执行的日志记录
            start_time = datetime.datetime.now()
            cursor.execute("""
                INSERT INTO task_logs (task_id, status, start_time, triggered_by)
                VALUES (%s, %s, %s, %s)
            """, (task_id, 'running', start_time, 'manual'))
            db.commit()
            log_id = cursor.lastrowid
            
            # 在新线程中执行
            def run_manual():
                import subprocess
                import pymysql
                
                try:
                    result = subprocess.run(
                        ['python', task['script_path']],
                        capture_output=True,
                        text=True,
                        timeout=300
                    )
                    
                    end_time = datetime.datetime.now()
                    
                    conn = pymysql.connect(**db_config)
                    cur = conn.cursor()
                    
                    if result.returncode == 0:
                        status = 'success'
                        output = result.stdout if result.stdout else '执行成功，无输出'
                        error_message = None
                    else:
                        status = 'failed'
                        output = result.stdout if result.stdout else ''
                        error_message = result.stderr if result.stderr else '执行失败'
                    
                    cur.execute("""
                        UPDATE task_logs 
                        SET status = %s, end_time = %s, output = %s, error_message = %s
                        WHERE id = %s
                    """, (status, end_time, output, error_message, log_id))
                    
                    cur.execute("""
                        UPDATE scheduled_tasks 
                        SET last_run_at = %s, last_status = %s, last_output = %s
                        WHERE id = %s
                    """, (start_time, status, output[:500] if output else None, task_id))
                    
                    conn.commit()
                    cur.close()
                    conn.close()
                    
                except Exception as e:
                    end_time = datetime.datetime.now()
                    try:
                        conn = pymysql.connect(**db_config)
                        cur = conn.cursor()
                        cur.execute("""
                            UPDATE task_logs 
                            SET status = %s, end_time = %s, error_message = %s
                            WHERE id = %s
                        """, ('failed', end_time, str(e), log_id))
                        cur.execute("""
                            UPDATE scheduled_tasks 
                            SET last_status = %s, last_output = %s
                            WHERE id = %s
                        """, ('failed', str(e)[:500], task_id))
                        conn.commit()
                        cur.close()
                        conn.close()
                    except:
                        pass
            
            import threading
            thread = threading.Thread(target=run_manual)
            thread.daemon = True
            thread.start()
        
        return jsonify({
            'code': 200,
            'message': '任务已开始执行'
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'执行任务失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@tasks_bp.route('/<int:task_id>/logs', methods=['GET'])
@jwt_required
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
        db.close()
