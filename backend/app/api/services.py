"""
服务管理 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required, module_required
from ..utils.operation_log import log_operation

services_bp = Blueprint('services', __name__, url_prefix='/api/services')


@services_bp.route('', methods=['GET'])
@jwt_required
@module_required('services')
def get_services():
    """
    获取服务列表
    支持查询参数: category, search, env_type, project_id, page, page_size
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
        if search:
            where_clause += " AND (s.service_name LIKE %s OR s.version LIKE %s)"
            params.extend([f'%{search}%'] * 2)
        if category:
            where_clause += " AND s.category = %s"
            params.append(category)
        if env_type:
            where_clause += " AND sv.env_type = %s"
            params.append(env_type)
        if project_id:
            where_clause += " AND s.project_id = %s"
            params.append(project_id)
        
        # 查询总数
        count_sql = f"""SELECT COUNT(*) as total FROM services s
                        JOIN servers sv ON s.server_id = sv.id
                        {where_clause}"""
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']

        # 查询数据
        sql = f"""SELECT s.*, sv.hostname, sv.inner_ip as server_inner_ip, sv.mapped_ip, sv.env_type,
                         p.project_name
                  FROM services s
                  JOIN servers sv ON s.server_id = sv.id
                  LEFT JOIN projects p ON s.project_id = p.id
                  {where_clause}
                  ORDER BY sv.env_type, sv.inner_ip, s.category, s.service_name
                  LIMIT %s OFFSET %s"""
        offset = (page - 1) * page_size
        cursor.execute(sql, params + [page_size, offset])
        services = cursor.fetchall()

        return jsonify({
            'code': 200,
            'data': {
                'items': services,
                'total': total,
                'page': page,
                'page_size': page_size
            }
        })
    finally:
        cursor.close()

@services_bp.route('', methods=['POST'])
@jwt_required
@module_required('services')
@role_required(['admin', 'operator'])
def create_service():
    """
    创建服务
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        cursor.execute(
            "INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s)",
            (data.get('server_id'), data.get('category'), data.get('service_name'),
             data.get('version'), data.get('inner_port'), data.get('mapped_port'),
             data.get('remark'), data.get('project_id'))
        )
        db.commit()
        service_id = cursor.lastrowid
        
        # 记录操作日志
        log_operation('服务管理', 'create', service_id, data.get('service_name'), 
                     {'category': data.get('category'), 'version': data.get('version')})
        
        return jsonify({
            'code': 200,
            'message': '创建成功',
            'data': {'id': service_id}
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'创建失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@services_bp.route('/<int:service_id>', methods=['PUT'])
@jwt_required
@module_required('services')
@role_required(['admin', 'operator'])
def update_service(service_id):
    """
    更新服务
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取更新前的服务名
        cursor.execute("SELECT service_name FROM services WHERE id = %s", (service_id,))
        old_service = cursor.fetchone()
        service_name = old_service['service_name'] if old_service else None
        
        data = request.json
        fields = []
        values = []
        for key in ['server_id', 'category', 'service_name', 'version', 'inner_port', 'mapped_port', 'remark', 'project_id']:
            if key in data:
                fields.append(f"`{key}` = %s")
                values.append(data[key])
        if fields:
            values.append(service_id)
            cursor.execute(f"UPDATE services SET {', '.join(fields)} WHERE id = %s", values)
            db.commit()
            
            # 记录操作日志
            log_operation('服务管理', 'update', service_id, data.get('service_name') or service_name)
            
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
