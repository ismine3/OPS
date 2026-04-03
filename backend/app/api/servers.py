"""
服务器管理 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required
from ..utils.operation_log import log_operation
from ..utils.validators import validate_ip, validate_hostname, validate_string_length
from ..utils.password_utils import encrypt_data, decrypt_data

servers_bp = Blueprint('servers', __name__, url_prefix='/api/servers')


@servers_bp.route('', methods=['GET'])
@jwt_required
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
            where_clause += " AND env_type = %s"
            params.append(env_filter)
        if platform_filter:
            where_clause += " AND platform = %s"
            params.append(platform_filter)
        if search:
            where_clause += " AND (hostname LIKE %s OR inner_ip LIKE %s OR platform LIKE %s)"
            params.extend([f'%{search}%'] * 3)

        # 查询总数
        count_sql = f"SELECT COUNT(*) as total FROM servers {where_clause}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']

        # 查询数据
        sql = f"SELECT * FROM servers {where_clause} ORDER BY env_type, id LIMIT %s OFFSET %s"
        offset = (page - 1) * page_size
        cursor.execute(sql, params + [page_size, offset])
        servers = cursor.fetchall()
        
        # 解密密码字段
        for server in servers:
            if server.get('os_password'):
                try:
                    server['os_password'] = decrypt_data(server['os_password'])
                except:
                    pass  # 解密失败保持原值
            if server.get('docker_password'):
                try:
                    server['docker_password'] = decrypt_data(server['docker_password'])
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

@servers_bp.route('/<int:server_id>', methods=['GET'])
@jwt_required
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
        if server.get('docker_password'):
            try:
                server['docker_password'] = decrypt_data(server['docker_password'])
            except:
                pass  # 解密失败保持原值

        cursor.execute(
            "SELECT * FROM services WHERE server_id = %s ORDER BY category, service_name",
            (server_id,)
        )
        services = cursor.fetchall()

        return jsonify({
            'code': 200,
            'data': {
                'server': server,
                'services': services
            }
        })
    finally:
        cursor.close()

@servers_bp.route('/list', methods=['GET'])
@jwt_required
def get_servers_list():
    """
    获取所有服务器简要信息（供下拉框使用）
    """
    db = get_db()
    cursor = db.cursor()
    try:
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
        
        if data.get('docker_user') and not validate_string_length(data.get('docker_user'), max_len=100):
            return jsonify({
                'code': 400,
                'message': 'Docker用户名长度不能超过100个字符'
            }), 400
        
        if data.get('docker_password') and not validate_string_length(data.get('docker_password'), max_len=255):
            return jsonify({
                'code': 400,
                'message': 'Docker密码长度不能超过255个字符'
            }), 400
        
        # 加密敏感信息（密码）
        os_password_encrypted = encrypt_data(data.get('os_password')) if data.get('os_password') else None
        docker_password_encrypted = encrypt_data(data.get('docker_password')) if data.get('docker_password') else None
        
        cursor.execute(
            "INSERT INTO servers (env_type, platform, hostname, inner_ip, mapped_ip, public_ip, "
            "cpu, memory, sys_disk, data_disk, purpose, os_user, os_password, docker_user, docker_password, remark) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
            (data.get('env_type'), data.get('platform'), hostname,
             inner_ip, mapped_ip, public_ip,
             data.get('cpu'), data.get('memory'), data.get('sys_disk'),
             data.get('data_disk'), data.get('purpose'), data.get('os_user'),
             os_password_encrypted, data.get('docker_user', 'docker'), docker_password_encrypted, data.get('remark'))
        )
        db.commit()
        server_id = cursor.lastrowid
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
                         'os_password', 'docker_user', 'docker_password', 'remark']
        
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
        
        if 'docker_user' in data and data['docker_user'] and not validate_string_length(data['docker_user'], max_len=100):
            return jsonify({
                'code': 400,
                'message': 'Docker用户名长度不能超过100个字符'
            }), 400
        
        if 'docker_password' in data and data['docker_password'] and not validate_string_length(data['docker_password'], max_len=255):
            return jsonify({
                'code': 400,
                'message': 'Docker密码长度不能超过255个字符'
            }), 400
        
        # 处理密码字段加密
        if 'os_password' in data and data['os_password']:
            data['os_password'] = encrypt_data(data['os_password'])
        if 'docker_password' in data and data['docker_password']:
            data['docker_password'] = encrypt_data(data['docker_password'])
        
        for key in data:
            if key in allowed_fields:
                fields.append(f"`{key}` = %s")
                values.append(data[key])

        if fields:
            values.append(server_id)
            cursor.execute(f"UPDATE servers SET {', '.join(fields)} WHERE id = %s", values)
            db.commit()
            # 记录操作日志
            cursor.execute("SELECT hostname FROM servers WHERE id = %s", (server_id,))
            server = cursor.fetchone()
            log_operation(module='服务器管理', action='update', target_id=server_id, 
                         target_name=server['hostname'] if server else str(server_id))
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

@servers_bp.route('/<int:server_id>', methods=['DELETE'])
@jwt_required
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
