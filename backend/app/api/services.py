"""
服务管理 API
"""
from flask import Blueprint, request, jsonify, g
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required, module_required
from ..utils.operation_log import log_operation
from ..utils.password_utils import encrypt_data, decrypt_data
from ..utils.validators import validate_string_length, validate_single_port
from .users import get_user_allowed_envs
import logging

logger = logging.getLogger(__name__)

services_bp = Blueprint('services', __name__, url_prefix='/api/services')


@services_bp.route('', methods=['GET'])
@jwt_required
@module_required('services')
def get_services():
    """
    获取服务列表（支持 project_id 多条过滤）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        search = request.args.get('search', '')
        category = request.args.get('category', '')
        env_type = request.args.get('env_type', '')
        project_id = request.args.get('project_id', '')
        page = request.args.get('page', '1')
        page_size = request.args.get('page_size', '10')

        try:
            page = int(page)
            page_size = int(page_size)
            if page < 1: page = 1
            if page_size < 1: page_size = 10
            if page_size > 100: page_size = 100
        except ValueError:
            page = 1
            page_size = 10

        where_clause = "WHERE 1=1"
        params = []
        if search:
            where_clause += " AND (s.service_name LIKE %s OR s.version LIKE %s OR sv.inner_ip LIKE %s)"
            params.extend([f'%{search}%'] * 3)
        if category:
            where_clause += " AND s.category = %s"
            params.append(category)
        if env_type:
            where_clause += " AND sv.env_type = %s"
            params.append(env_type)
        if project_id:
            where_clause += " AND EXISTS (SELECT 1 FROM service_projects sp2 WHERE sp2.service_id = s.id AND sp2.project_id = %s)"
            params.append(project_id)

        allowed_envs = get_user_allowed_envs(g.current_user['user_id'], g.current_user['role'])
        if allowed_envs is not None:
            if not allowed_envs:
                return jsonify({'code': 200, 'data': {'items': [], 'total': 0, 'page': page, 'page_size': page_size}}), 200
            placeholders = ','.join(['%s'] * len(allowed_envs))
            where_clause += f" AND sv.env_type IN ({placeholders})"
            params.extend(allowed_envs)

        count_sql = f"""SELECT COUNT(DISTINCT s.id) as total FROM services s
                        JOIN servers sv ON s.server_id = sv.id
                        {where_clause}"""
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']

        sql = f"""SELECT s.*, sv.hostname, sv.inner_ip as server_inner_ip, sv.mapped_ip, sv.env_type
                  FROM services s
                  JOIN servers sv ON s.server_id = sv.id
                  {where_clause}
                  ORDER BY sv.env_type, sv.inner_ip, s.category, s.service_name
                  LIMIT %s OFFSET %s"""
        offset = (page - 1) * page_size
        cursor.execute(sql, params + [page_size, offset])
        services = cursor.fetchall()

        # 批量查所有服务的项目关联
        service_ids = [s['id'] for s in services]
        project_map = {}
        if service_ids:
            placeholders = ','.join(['%s'] * len(service_ids))
            cursor.execute(f"""
                SELECT sp.service_id, p.id, p.project_name
                FROM service_projects sp
                JOIN projects p ON sp.project_id = p.id
                WHERE sp.service_id IN ({placeholders})
            """, service_ids)
            for row in cursor.fetchall():
                sid = row['service_id']
                if sid not in project_map:
                    project_map[sid] = []
                project_map[sid].append({'id': row['id'], 'name': row['project_name']})

        # 批量查所有服务的端口映射
        port_map = {}
        if service_ids:
            cursor.execute(f"""
                SELECT id, service_id, inner_port, mapped_port, protocol, remark
                FROM service_ports
                WHERE service_id IN ({placeholders})
                ORDER BY id
            """, service_ids)
            for row in cursor.fetchall():
                sid = row['service_id']
                if sid not in port_map:
                    port_map[sid] = []
                port_map[sid].append({
                    'id': row['id'],
                    'inner_port': row['inner_port'],
                    'mapped_port': row['mapped_port'],
                    'protocol': row['protocol'],
                    'remark': row['remark']
                })

        for s in services:
            projects = project_map.get(s['id'], [])
            s['project_ids'] = [p['id'] for p in projects]
            s['project_names'] = [p['name'] for p in projects]
            s['project_id'] = s['project_ids'][0] if s['project_ids'] else None
            s['project_name'] = s['project_names'][0] if s['project_names'] else None
            ports = port_map.get(s['id'], [])
            s['ports'] = ports
            if s.get('password'):
                try:
                    s['password'] = decrypt_data(s['password'])
                except:
                    logger.warning(f'服务密码解密失败: service_id={s.get("id")}')
                    pass

        return jsonify({
            'code': 200,
            'data': {'items': services, 'total': total, 'page': page, 'page_size': page_size}
        })
    finally:
        cursor.close()

@services_bp.route('', methods=['POST'])
@jwt_required
@module_required('services')
@role_required(['admin', 'operator'])
def create_service():
    """创建服务（支持 project_ids 数组）"""
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        if not data:
            return jsonify({"code": 400, "message": "请求体不能为空"}), 400

        # 输入验证
        server_id = data.get('server_id')
        if not server_id:
            return jsonify({'code': 400, 'message': '服务器ID不能为空'}), 400

        service_name = data.get('service_name')
        if not service_name:
            return jsonify({'code': 400, 'message': '服务名称不能为空'}), 400
        if not validate_string_length(service_name, min_len=1, max_len=100):
            return jsonify({'code': 400, 'message': '服务名称长度必须在1-100个字符之间'}), 400

        category = data.get('category')
        if not category:
            return jsonify({'code': 400, 'message': '服务分类不能为空'}), 400
        if not validate_string_length(category, max_len=50):
            return jsonify({'code': 400, 'message': '服务分类长度不能超过50个字符'}), 400

        version = data.get('version')
        if version and not validate_string_length(version, max_len=50):
            return jsonify({'code': 400, 'message': '版本号长度不能超过50个字符'}), 400

        # 验证 ports 数组（新的端口映射格式）
        ports_list = data.get('ports') or []
        if not isinstance(ports_list, list):
            return jsonify({'code': 400, 'message': 'ports 必须是数组'}), 400
        for p in ports_list:
            if not isinstance(p, dict):
                return jsonify({'code': 400, 'message': 'ports 每项必须是对象'}), 400
            inner = p.get('inner_port')
            if inner is None or not validate_single_port(inner):
                return jsonify({'code': 400, 'message': f'内网端口无效: {inner}'}), 400
            mapped = p.get('mapped_port')
            if mapped is not None and not validate_single_port(mapped):
                return jsonify({'code': 400, 'message': f'映射端口无效: {mapped}'}), 400

        account = data.get('account')
        if account and not validate_string_length(account, max_len=100):
            return jsonify({'code': 400, 'message': '账户名长度不能超过100个字符'}), 400

        remark = data.get('remark')
        if remark and not validate_string_length(remark, max_len=500):
            return jsonify({'code': 400, 'message': '备注长度不能超过500个字符'}), 400

        password_encrypted = encrypt_data(data['password']) if data.get('password') else None
        cursor.execute(
            "INSERT INTO services (server_id, category, service_name, version, account, password, remark) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s)",
            (data.get('server_id'), data.get('category'), data.get('service_name'),
             data.get('version'),
             data.get('account'), password_encrypted,
             data.get('remark'))
        )
        service_id = cursor.lastrowid
        # 插入项目关联
        project_ids = data.get('project_ids') or []
        if isinstance(project_ids, list) and project_ids:
            for pid in project_ids:
                cursor.execute(
                    "INSERT IGNORE INTO service_projects (service_id, project_id) VALUES (%s, %s)",
                    (service_id, pid)
                )
        # 插入端口映射
        if ports_list:
            for p in ports_list:
                cursor.execute(
                    "INSERT INTO service_ports (service_id, inner_port, mapped_port, protocol, remark) VALUES (%s,%s,%s,%s,%s)",
                    (service_id, p.get('inner_port'), p.get('mapped_port') or None,
                     p.get('protocol', 'TCP'), p.get('remark', ''))
                )
        db.commit()
        log_operation('服务管理', 'create', service_id, data.get('service_name'),
                     {'category': data.get('category'), 'version': data.get('version')})
        return jsonify({'code': 200, 'message': '创建成功', 'data': {'id': service_id}})
    except Exception as e:
        db.rollback()
        return jsonify({'code': 500, 'message': f'创建失败: {str(e)}'}), 500
    finally:
        cursor.close()

@services_bp.route('/<int:service_id>', methods=['PUT'])
@jwt_required
@module_required('services')
@role_required(['admin', 'operator'])
def update_service(service_id):
    """更新服务（支持 project_ids 数组）"""
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT service_name FROM services WHERE id = %s", (service_id,))
        old_service = cursor.fetchone()
        service_name = old_service['service_name'] if old_service else None
        data = request.json
        if not data:
            return jsonify({"code": 400, "message": "请求体不能为空"}), 400

        # 输入验证（仅验证存在的字段）
        if 'service_name' in data and data['service_name']:
            if not validate_string_length(data['service_name'], min_len=1, max_len=100):
                return jsonify({'code': 400, 'message': '服务名称长度必须在1-100个字符之间'}), 400
        if 'category' in data and data['category']:
            if not validate_string_length(data['category'], max_len=50):
                return jsonify({'code': 400, 'message': '服务分类长度不能超过50个字符'}), 400
        if 'version' in data and data['version']:
            if not validate_string_length(data['version'], max_len=50):
                return jsonify({'code': 400, 'message': '版本号长度不能超过50个字符'}), 400
        # 验证 ports 数组
        if 'ports' in data:
            ports_list = data['ports']
            if not isinstance(ports_list, list):
                return jsonify({'code': 400, 'message': 'ports 必须是数组'}), 400
            for p in ports_list:
                if not isinstance(p, dict):
                    return jsonify({'code': 400, 'message': 'ports 每项必须是对象'}), 400
                inner = p.get('inner_port')
                if inner is None or not validate_single_port(inner):
                    return jsonify({'code': 400, 'message': f'内网端口无效: {inner}'}), 400
                mapped = p.get('mapped_port')
                if mapped is not None and not validate_single_port(mapped):
                    return jsonify({'code': 400, 'message': f'映射端口无效: {mapped}'}), 400
        if 'account' in data and data['account']:
            if not validate_string_length(data['account'], max_len=100):
                return jsonify({'code': 400, 'message': '账户名长度不能超过100个字符'}), 400
        if 'remark' in data and data['remark']:
            if not validate_string_length(data['remark'], max_len=500):
                return jsonify({'code': 400, 'message': '备注长度不能超过500个字符'}), 400

        if 'password' in data and data['password']:
            data['password'] = encrypt_data(data['password'])
        fields = []
        values = []
        for key in ['server_id', 'category', 'service_name', 'version', 'account', 'password', 'remark']:
            if key in data:
                fields.append(f"`{key}` = %s")
                values.append(data[key])
        if fields:
            values.append(service_id)
            cursor.execute(f"UPDATE services SET {', '.join(fields)} WHERE id = %s", values)
        # 同步项目关联
        if 'project_ids' in data:
            cursor.execute("DELETE FROM service_projects WHERE service_id = %s", (service_id,))
            for pid in (data['project_ids'] or []):
                cursor.execute(
                    "INSERT IGNORE INTO service_projects (service_id, project_id) VALUES (%s, %s)",
                    (service_id, pid)
                )
        # 同步端口映射
        if 'ports' in data:
            cursor.execute("DELETE FROM service_ports WHERE service_id = %s", (service_id,))
            for p in ports_list:
                cursor.execute(
                    "INSERT INTO service_ports (service_id, inner_port, mapped_port, protocol, remark) VALUES (%s,%s,%s,%s,%s)",
                    (service_id, p.get('inner_port'), p.get('mapped_port') or None,
                     p.get('protocol', 'TCP'), p.get('remark', ''))
                )
        db.commit()
        log_operation('服务管理', 'update', service_id, data.get('service_name') or service_name,
                     detail={'updated_fields': list(data.keys())})
        return jsonify({'code': 200, 'message': '更新成功'})
    except Exception as e:
        db.rollback()
        return jsonify({'code': 500, 'message': f'更新失败: {str(e)}'}), 500
    finally:
        cursor.close()

@services_bp.route('/<int:service_id>', methods=['DELETE'])
@jwt_required
@module_required('services')
@role_required(['admin', 'operator'])
def delete_service(service_id):
    """
    删除服务
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取服务名
        cursor.execute("SELECT service_name FROM services WHERE id = %s", (service_id,))
        old_service = cursor.fetchone()
        service_name = old_service['service_name'] if old_service else None
        
        cursor.execute("DELETE FROM services WHERE id = %s", (service_id,))
        db.commit()
        
        # 记录操作日志
        log_operation('服务管理', 'delete', service_id, service_name)
        
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
