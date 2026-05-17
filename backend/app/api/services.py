"""
服务管理 API
"""
from flask import Blueprint, request, jsonify, g
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required, module_required
from ..utils.operation_log import log_operation
from ..utils.password_utils import encrypt_data, decrypt_data
from .users import get_user_allowed_envs

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

        for s in services:
            projects = project_map.get(s['id'], [])
            s['project_ids'] = [p['id'] for p in projects]
            s['project_names'] = [p['name'] for p in projects]
            s['project_id'] = s['project_ids'][0] if s['project_ids'] else None
            s['project_name'] = s['project_names'][0] if s['project_names'] else None
            if s.get('password'):
                try:
                    s['password'] = decrypt_data(s['password'])
                except:
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
        password_encrypted = encrypt_data(data['password']) if data.get('password') else None
        cursor.execute(
            "INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, account, password, remark) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)",
            (data.get('server_id'), data.get('category'), data.get('service_name'),
             data.get('version'), data.get('inner_port'), data.get('mapped_port'),
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
        if 'password' in data and data['password']:
            data['password'] = encrypt_data(data['password'])
        fields = []
        values = []
        for key in ['server_id', 'category', 'service_name', 'version', 'inner_port', 'mapped_port', 'account', 'password', 'remark']:
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
        db.commit()
        log_operation('服务管理', 'update', service_id, data.get('service_name') or service_name)
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
