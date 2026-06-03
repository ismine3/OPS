"""
服务器管理 API
"""
import logging
from flask import Blueprint, request, jsonify, g, current_app
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required, module_required
from ..utils.operation_log import log_operation
from ..utils.validators import validate_ip, validate_hostname, validate_string_length
from ..utils.password_utils import encrypt_data, decrypt_data
from ..utils.scheduler import get_scheduler_db_config
from ..utils.password_rotator import rotate_server_password
from .users import get_user_allowed_envs

logger = logging.getLogger(__name__)

servers_bp = Blueprint('servers', __name__, url_prefix='/api/servers')


@servers_bp.route('', methods=['GET'])
@jwt_required
@module_required('servers')
def get_servers():
    """
    获取服务器列表
    支持查询参数: env_type, platform, search, page, page_size
    """
    db = get_db()
    cursor = db.cursor()
    try:
        env_filter = request.args.get('env_type', '')
        platform_filter = request.args.get('platform', '')
        project_filter = request.args.get('project_id', '')
        search = request.args.get('search', '')
        page = request.args.get('page', '1')
        page_size = request.args.get('page_size', '10')

        # 分页参数处理
        try:
            page = int(page)
            page_size = int(page_size)
            if page < 1:
                page = 1
            if page_size < 1:
                page_size = 10
            if page_size > 100:
                page_size = 100
        except ValueError:
            page = 1
            page_size = 10

        # 构建基础查询条件
        where_clause = "WHERE 1=1"
        params = []
        if env_filter:
            where_clause += " AND s.env_type = %s"
            params.append(env_filter)
        if platform_filter:
            where_clause += " AND s.platform = %s"
            params.append(platform_filter)
        if project_filter:
            where_clause += " AND EXISTS (SELECT 1 FROM project_servers ps WHERE ps.server_id = s.id AND ps.project_id = %s)"
            params.append(project_filter)
        if search:
            where_clause += " AND (s.hostname LIKE %s OR s.inner_ip LIKE %s OR s.platform LIKE %s)"
            params.extend([f'%{search}%'] * 3)

        # 用户环境权限过滤（admin 不过滤）
        allowed_envs = get_user_allowed_envs(g.current_user['user_id'], g.current_user['role'])
        if allowed_envs is not None:
            if not allowed_envs:
                return jsonify({'code': 200, 'data': {'items': [], 'total': 0, 'page': page, 'page_size': page_size}}), 200
            placeholders = ','.join(['%s'] * len(allowed_envs))
            where_clause += f" AND s.env_type IN ({placeholders})"
            params.extend(allowed_envs)

        # 查询总数
        count_sql = f"SELECT COUNT(*) as total FROM servers s {where_clause}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']

        # 查询数据（不加项目 JOIN，项目关联单独批量查）
        sql = f"""
            SELECT s.*
            FROM servers s
            {where_clause}
            ORDER BY s.env_type, s.id
            LIMIT %s OFFSET %s
        """
        offset = (page - 1) * page_size
        cursor.execute(sql, params + [page_size, offset])
        servers = cursor.fetchall()

        # 批量查询项目关联
        server_ids = [s['id'] for s in servers]
        project_map = {}
        if server_ids:
            placeholders = ','.join(['%s'] * len(server_ids))
            cursor.execute(f"""
                SELECT ps.server_id, p.id, p.project_name
                FROM project_servers ps
                JOIN projects p ON ps.project_id = p.id
                WHERE ps.server_id IN ({placeholders})
            """, server_ids)
            for row in cursor.fetchall():
                sid = row['server_id']
                if sid not in project_map:
                    project_map[sid] = []
                project_map[sid].append({'id': row['id'], 'name': row['project_name']})

        for s in servers:
            projects = project_map.get(s['id'], [])
            s['project_ids'] = [p['id'] for p in projects]
            s['project_names'] = [p['name'] for p in projects]

        # 解密密码字段
        for server in servers:
            if server.get('os_password'):
                try:
                    server['os_password'] = decrypt_data(server['os_password'])
                except:
                    pass  # 解密失败保持原值
            if server.get('regular_password'):
                try:
                    server['regular_password'] = decrypt_data(server['regular_password'])
                except:
                    pass  # 解密失败保持原值

        return jsonify({
            'code': 200,
            'data': {
                'items': servers,
                'total': total,
                'page': page,
                'page_size': page_size
            }
        })
    finally:
        cursor.close()


@servers_bp.route('/options', methods=['GET'])
@jwt_required
def get_server_options():
    """
    获取服务器选项列表（供其他模块下拉选择，仅需登录认证）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 用户环境权限过滤
        allowed_envs = get_user_allowed_envs(g.current_user['user_id'], g.current_user['role'])
        if allowed_envs is not None:
            if not allowed_envs:
                return jsonify({'code': 200, 'data': []}), 200
            placeholders = ','.join(['%s'] * len(allowed_envs))
            cursor.execute(
                f"SELECT id, hostname AS name, inner_ip FROM servers WHERE env_type IN ({placeholders}) ORDER BY env_type, hostname",
                allowed_envs
            )
        else:
            cursor.execute("SELECT id, hostname AS name, inner_ip FROM servers ORDER BY env_type, hostname")
        servers = cursor.fetchall()
        return jsonify({
            'code': 200,
            'data': servers
        })
    finally:
        cursor.close()


@servers_bp.route('/<int:server_id>', methods=['GET'])
@jwt_required
@module_required('servers')
def get_server_detail(server_id):
    """
    获取服务器详情（含关联服务列表）
    密码字段会被解密返回
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT * FROM servers WHERE id = %s", (server_id,))
        server = cursor.fetchone()
        if not server:
            return jsonify({
                'code': 404,
                'message': '服务器不存在'
            }), 404
        
        # 解密密码字段
        if server.get('os_password'):
            try:
                server['os_password'] = decrypt_data(server['os_password'])
            except:
                pass  # 解密失败保持原值
        if server.get('regular_password'):
            try:
                server['regular_password'] = decrypt_data(server['regular_password'])
            except:
                pass  # 解密失败保持原值

        cursor.execute(
            "SELECT * FROM services WHERE server_id = %s ORDER BY category, service_name",
            (server_id,)
        )
        services = cursor.fetchall()
        
        # 批量查询端口映射数据
        if services:
            service_ids = [s['id'] for s in services]
            placeholders = ','.join(['%s'] * len(service_ids))
            cursor.execute(f"""
                SELECT id, service_id, inner_port, mapped_port, protocol, remark
                FROM service_ports WHERE service_id IN ({placeholders}) ORDER BY id
            """, service_ids)
            port_rows = cursor.fetchall()
            port_map = {}
            for p in port_rows:
                sid = p['service_id']
                if sid not in port_map:
                    port_map[sid] = []
                port_map[sid].append(p)
            for s in services:
                s['ports'] = port_map.get(s['id'], [])
        
        # 查询关联的项目列表
        cursor.execute(
            "SELECT p.id, p.project_name, p.status FROM projects p "
            "JOIN project_servers ps ON p.id = ps.project_id WHERE ps.server_id = %s",
            (server_id,)
        )
        projects = cursor.fetchall()
        
        return jsonify({
            'code': 200,
            'data': {
                'server': server,
                'services': services,
                'projects': projects
            }
        })
    finally:
        cursor.close()

@servers_bp.route('/list', methods=['GET'])
@jwt_required
@module_required('servers')
def get_servers_list():
    """
    获取所有服务器简要信息（供下拉框使用）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 用户环境权限过滤
        allowed_envs = get_user_allowed_envs(g.current_user['user_id'], g.current_user['role'])
        if allowed_envs is not None:
            if not allowed_envs:
                return jsonify({'code': 200, 'data': []}), 200
            placeholders = ','.join(['%s'] * len(allowed_envs))
            cursor.execute(
                f"SELECT id, env_type, hostname, inner_ip FROM servers WHERE env_type IN ({placeholders}) ORDER BY env_type, inner_ip",
                allowed_envs
            )
        else:
            cursor.execute("SELECT id, env_type, hostname, inner_ip FROM servers ORDER BY env_type, inner_ip")
        servers = cursor.fetchall()
        return jsonify({
            'code': 200,
            'data': servers
        })
    finally:
        cursor.close()

@servers_bp.route('', methods=['POST'])
@jwt_required
@module_required('servers')
@role_required(['admin', 'operator'])
def create_server():
    """
    创建服务器
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.get_json(silent=True) or {}
        if not data:
            return jsonify({"code": 400, "message": "请求体不能为空"}), 400

        # 输入验证
        hostname = data.get('hostname')
        inner_ip = data.get('inner_ip')
        mapped_ip = data.get('mapped_ip')
        public_ip = data.get('public_ip')
        
        # 验证主机名
        if hostname and not validate_hostname(hostname):
            return jsonify({
                'code': 400,
                'message': '主机名格式不正确'
            }), 400
        
        # 验证IP地址
        if inner_ip and not validate_ip(inner_ip):
            return jsonify({
                'code': 400,
                'message': '内网IP地址格式不正确'
            }), 400
        
        if mapped_ip and not validate_ip(mapped_ip):
            return jsonify({
                'code': 400,
                'message': '映射IP地址格式不正确'
            }), 400
        
        if public_ip and not validate_ip(public_ip):
            return jsonify({
                'code': 400,
                'message': '公网IP地址格式不正确'
            }), 400
        
        # 验证字符串长度
        if not validate_string_length(data.get('env_type'), min_len=1, max_len=50):
            return jsonify({
                'code': 400,
                'message': '环境类型长度必须在1-50个字符之间'
            }), 400
        
        if not validate_string_length(data.get('platform'), min_len=1, max_len=100):
            return jsonify({
                'code': 400,
                'message': '平台长度必须在1-100个字符之间'
            }), 400
        
        if hostname and not validate_string_length(hostname, max_len=255):
            return jsonify({
                'code': 400,
                'message': '主机名长度不能超过255个字符'
            }), 400
        
        # 验证其他字段长度
        if data.get('cpu') and not validate_string_length(data.get('cpu'), max_len=50):
            return jsonify({
                'code': 400,
                'message': 'CPU信息长度不能超过50个字符'
            }), 400
        
        if data.get('memory') and not validate_string_length(data.get('memory'), max_len=50):
            return jsonify({
                'code': 400,
                'message': '内存信息长度不能超过50个字符'
            }), 400
        
        if data.get('sys_disk') and not validate_string_length(data.get('sys_disk'), max_len=50):
            return jsonify({
                'code': 400,
                'message': '系统盘信息长度不能超过50个字符'
            }), 400
        
        if data.get('data_disk') and not validate_string_length(data.get('data_disk'), max_len=50):
            return jsonify({
                'code': 400,
                'message': '数据盘信息长度不能超过50个字符'
            }), 400
        
        if data.get('purpose') and not validate_string_length(data.get('purpose'), max_len=500):
            return jsonify({
                'code': 400,
                'message': '用途信息长度不能超过500个字符'
            }), 400
        
        if data.get('os_user') and not validate_string_length(data.get('os_user'), max_len=100):
            return jsonify({
                'code': 400,
                'message': '系统账户长度不能超过100个字符'
            }), 400
        
        if data.get('os_password') and not validate_string_length(data.get('os_password'), max_len=255):
            return jsonify({
                'code': 400,
                'message': '系统密码长度不能超过255个字符'
            }), 400
        
        if data.get('regular_user') and not validate_string_length(data.get('regular_user'), max_len=100):
            return jsonify({
                'code': 400,
                'message': '普通用户名长度不能超过100个字符'
            }), 400
        
        if data.get('regular_password') and not validate_string_length(data.get('regular_password'), max_len=255):
            return jsonify({
                'code': 400,
                'message': '普通用户密码长度不能超过255个字符'
            }), 400
        
        # 验证证书路径
        cert_path = data.get('cert_path')
        if cert_path:
            if not validate_string_length(cert_path, max_len=255):
                return jsonify({
                    'code': 400,
                    'message': '证书路径长度不能超过255个字符'
                }), 400
            if not cert_path.startswith('/'):
                return jsonify({
                    'code': 400,
                    'message': '证书路径必须以/开头'
                }), 400
        
        # 验证密码更新周期
        rotation_days = data.get('password_rotation_days')
        if rotation_days is not None:
            try:
                rotation_days = int(rotation_days)
                if rotation_days < 1 or rotation_days > 365:
                    return jsonify({
                        'code': 400,
                        'message': '密码更新周期必须在1-365天之间'
                    }), 400
            except (ValueError, TypeError):
                return jsonify({
                    'code': 400,
                    'message': '密码更新周期必须为有效数字'
                }), 400
        
        # 加密敏感信息（密码）
        os_password_encrypted = encrypt_data(data.get('os_password')) if data.get('os_password') else None
        regular_password_encrypted = encrypt_data(data.get('regular_password')) if data.get('regular_password') else None
        
        rotation_enabled = 1 if data.get('password_rotation_enabled') else 0
        rotation_days_val = rotation_days if rotation_days else 30
        
        cursor.execute(
            "INSERT INTO servers (env_type, platform, hostname, inner_ip, mapped_ip, public_ip, "
            "cpu, memory, sys_disk, data_disk, purpose, os_user, os_password, regular_user, regular_password, "
            "remark, cert_path, password_rotation_enabled, password_rotation_days) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
            (data.get('env_type'), data.get('platform'), hostname,
             inner_ip, mapped_ip, public_ip,
             data.get('cpu'), data.get('memory'), data.get('sys_disk'),
             data.get('data_disk'), data.get('purpose'), data.get('os_user'),
             os_password_encrypted, data.get('regular_user', ''), regular_password_encrypted,
             data.get('remark'), cert_path,
             rotation_enabled, rotation_days_val)
        )
        db.commit()
        server_id = cursor.lastrowid
        
        # 处理项目关联
        project_ids = data.get('project_ids', [])
        if project_ids:
            # 验证项目ID存在
            placeholders = ','.join(['%s'] * len(project_ids))
            cursor.execute(
                f"SELECT id FROM projects WHERE id IN ({placeholders})",
                tuple(project_ids)
            )
            existing_ids = {row['id'] for row in cursor.fetchall()}
            for pid in project_ids:
                if pid in existing_ids:
                    cursor.execute(
                        "INSERT INTO project_servers (project_id, server_id) VALUES (%s, %s)",
                        (pid, server_id)
                    )
            db.commit()
        
        # 记录操作日志
        log_operation(module='服务器管理', action='create', target_id=server_id, 
                     target_name=data.get('hostname'), detail={'env_type': data.get('env_type'), 'inner_ip': data.get('inner_ip')})
        return jsonify({
            'code': 200,
            'message': '创建成功',
            'data': {'id': server_id}
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'创建失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@servers_bp.route('/<int:server_id>', methods=['PUT'])
@jwt_required
@module_required('servers')
@role_required(['admin', 'operator'])
def update_server(server_id):
    """
    更新服务器
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.get_json(silent=True) or {}
        if not data:
            return jsonify({"code": 400, "message": "请求体不能为空"}), 400

        fields = []
        values = []
        # 允许的字段白名单，防止SQL注入
        allowed_fields = ['env_type', 'platform', 'hostname', 'inner_ip', 'mapped_ip', 'public_ip',
                         'cpu', 'memory', 'sys_disk', 'data_disk', 'purpose', 'os_user',
                         'os_password', 'regular_user', 'regular_password', 'remark', 'cert_path',
                         'password_rotation_enabled', 'password_rotation_days']
        
        # 输入验证
        if 'hostname' in data:
            hostname = data['hostname']
            if hostname and not validate_hostname(hostname):
                return jsonify({
                    'code': 400,
                    'message': '主机名格式不正确'
                }), 400
            if hostname and not validate_string_length(hostname, max_len=255):
                return jsonify({
                    'code': 400,
                    'message': '主机名长度不能超过255个字符'
                }), 400
        
        if 'inner_ip' in data and data['inner_ip'] and not validate_ip(data['inner_ip']):
            return jsonify({
                'code': 400,
                'message': '内网IP地址格式不正确'
            }), 400
        
        if 'mapped_ip' in data and data['mapped_ip'] and not validate_ip(data['mapped_ip']):
            return jsonify({
                'code': 400,
                'message': '映射IP地址格式不正确'
            }), 400
        
        if 'public_ip' in data and data['public_ip'] and not validate_ip(data['public_ip']):
            return jsonify({
                'code': 400,
                'message': '公网IP地址格式不正确'
            }), 400
        
        if 'env_type' in data and not validate_string_length(data['env_type'], min_len=1, max_len=50):
            return jsonify({
                'code': 400,
                'message': '环境类型长度必须在1-50个字符之间'
            }), 400
        
        if 'platform' in data and not validate_string_length(data['platform'], min_len=1, max_len=100):
            return jsonify({
                'code': 400,
                'message': '平台长度必须在1-100个字符之间'
            }), 400
        
        # 验证其他字段长度
        if 'cpu' in data and data['cpu'] and not validate_string_length(data['cpu'], max_len=50):
            return jsonify({
                'code': 400,
                'message': 'CPU信息长度不能超过50个字符'
            }), 400
        
        if 'memory' in data and data['memory'] and not validate_string_length(data['memory'], max_len=50):
            return jsonify({
                'code': 400,
                'message': '内存信息长度不能超过50个字符'
            }), 400
        
        if 'sys_disk' in data and data['sys_disk'] and not validate_string_length(data['sys_disk'], max_len=50):
            return jsonify({
                'code': 400,
                'message': '系统盘信息长度不能超过50个字符'
            }), 400
        
        if 'data_disk' in data and data['data_disk'] and not validate_string_length(data['data_disk'], max_len=50):
            return jsonify({
                'code': 400,
                'message': '数据盘信息长度不能超过50个字符'
            }), 400
        
        if 'purpose' in data and data['purpose'] and not validate_string_length(data['purpose'], max_len=500):
            return jsonify({
                'code': 400,
                'message': '用途信息长度不能超过500个字符'
            }), 400
        
        if 'os_user' in data and data['os_user'] and not validate_string_length(data['os_user'], max_len=100):
            return jsonify({
                'code': 400,
                'message': '系统账户长度不能超过100个字符'
            }), 400
        
        if 'os_password' in data and data['os_password'] and not validate_string_length(data['os_password'], max_len=255):
            return jsonify({
                'code': 400,
                'message': '系统密码长度不能超过255个字符'
            }), 400
        
        if 'regular_user' in data and data['regular_user'] and not validate_string_length(data['regular_user'], max_len=100):
            return jsonify({
                'code': 400,
                'message': '普通用户名长度不能超过100个字符'
            }), 400
        
        if 'regular_password' in data and data['regular_password'] and not validate_string_length(data['regular_password'], max_len=255):
            return jsonify({
                'code': 400,
                'message': '普通用户密码长度不能超过255个字符'
            }), 400
        
        # 验证证书路径
        if 'cert_path' in data and data['cert_path']:
            if not validate_string_length(data['cert_path'], max_len=255):
                return jsonify({
                    'code': 400,
                    'message': '证书路径长度不能超过255个字符'
                }), 400
            if not data['cert_path'].startswith('/'):
                return jsonify({
                    'code': 400,
                    'message': '证书路径必须以/开头'
                }), 400
        
        # 验证密码更新周期
        if 'password_rotation_days' in data and data['password_rotation_days'] is not None:
            try:
                days = int(data['password_rotation_days'])
                if days < 1 or days > 365:
                    return jsonify({
                        'code': 400,
                        'message': '密码更新周期必须在1-365天之间'
                    }), 400
            except (ValueError, TypeError):
                return jsonify({
                    'code': 400,
                    'message': '密码更新周期必须为有效数字'
                }), 400
        
        # 处理密码字段加密
        if 'os_password' in data and data['os_password']:
            data['os_password'] = encrypt_data(data['os_password'])
        if 'regular_password' in data and data['regular_password']:
            data['regular_password'] = encrypt_data(data['regular_password'])
        
        for key in data:
            if key in allowed_fields:
                fields.append(f"`{key}` = %s")
                values.append(data[key])

        if fields:
            values.append(server_id)
            cursor.execute(f"UPDATE servers SET {', '.join(fields)} WHERE id = %s", values)
        
        # 处理项目关联更新
        if 'project_ids' in data:
            # 先删除旧的关联
            cursor.execute("DELETE FROM project_servers WHERE server_id = %s", (server_id,))
            # 添加新的关联
            project_ids = data['project_ids']
            if project_ids:
                for pid in project_ids:
                    cursor.execute(
                        "INSERT INTO project_servers (project_id, server_id) VALUES (%s, %s)",
                        (pid, server_id)
                    )
        
        db.commit()
        # 记录操作日志
        cursor.execute("SELECT hostname FROM servers WHERE id = %s", (server_id,))
        server = cursor.fetchone()
        log_operation(module='服务器管理', action='update', target_id=server_id, 
                     target_name=server['hostname'] if server else str(server_id),
                     detail={'updated_fields': list(data.keys())})
        return jsonify({
            'code': 200,
            'message': '更新成功'
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'更新失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@servers_bp.route('/<int:server_id>/rotate-password', methods=['POST'])
@jwt_required
@module_required('servers')
@role_required(['admin', 'operator'])
def rotate_password(server_id):
    """
    手动触发服务器密码轮换
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT * FROM servers WHERE id = %s", (server_id,))
        server = cursor.fetchone()
        if not server:
            return jsonify({'code': 404, 'message': '服务器不存在'}), 404

        # 快速检查是否正在执行中（精确并发控制由 rotate_server_password 内部原子锁保证）
        if server.get('password_rotation_status') == 'running':
            return jsonify({'code': 409, 'message': '该服务器正在执行密码轮换中，请稍后重试'}), 409

        # 获取数据库配置和密码长度配置
        db_config = get_scheduler_db_config()
        if not db_config:
            return jsonify({'code': 500, 'message': '调度器未初始化，无法获取数据库配置'}), 500

        # 从系统配置读取密码长度（fallback 到16）
        password_length = current_app.config.get('PASSWORD_ROTATION_LENGTH', 16)

        # 异步执行密码轮换（在新线程中）
        import threading
        def run():
            try:
                result = rotate_server_password(server, db_config, password_length)
                logger.info("服务器 %s 密码轮换结果: %s", server.get('hostname'), result.get('message'))
            except Exception as e:
                logger.exception("服务器 %s 密码轮换线程异常: %s", server.get('hostname'), e)
                # 异常时更新数据库状态为 failed
                try:
                    import pymysql
                    err_conn = pymysql.connect(**db_config)
                    err_cursor = err_conn.cursor()
                    err_cursor.execute(
                        "UPDATE servers SET password_rotation_status = 'failed', password_rotation_error = %s WHERE id = %s",
                        (f'线程异常: {str(e)}'[:1000], server_id)
                    )
                    err_conn.commit()
                    err_cursor.close()
                    err_conn.close()
                except Exception:
                    pass

        thread = threading.Thread(target=run, daemon=True)
        thread.start()

        # 记录操作日志
        log_operation(module='服务器管理', action='rotate_password', target_id=server_id,
                     target_name=server.get('hostname'), detail={'action': '手动触发密码轮换'})

        return jsonify({
            'code': 200,
            'message': '密码轮换任务已提交，正在后台执行'
        })
    finally:
        cursor.close()


@servers_bp.route('/<int:server_id>', methods=['DELETE'])
@jwt_required
@module_required('servers')
@role_required(['admin', 'operator'])
def delete_server(server_id):
    """
    删除服务器（同时删除关联的服务记录）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 先获取服务器信息用于日志
        cursor.execute("SELECT hostname FROM servers WHERE id = %s", (server_id,))
        server = cursor.fetchone()
        if not server:
            return jsonify({
                'code': 404,
                'message': '服务器不存在'
            }), 404
        hostname = server['hostname']
        
        # 先删除关联的服务记录
        cursor.execute("DELETE FROM services WHERE server_id = %s", (server_id,))
        
        # 再删除服务器
        cursor.execute("DELETE FROM servers WHERE id = %s", (server_id,))
        db.commit()
        
        # 记录操作日志
        log_operation(module='服务器管理', action='delete', target_id=server_id, target_name=hostname)
        
        return jsonify({
            'code': 200,
            'message': '删除成功'
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'删除失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
