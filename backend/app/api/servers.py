"""
服务器管理 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required

servers_bp = Blueprint('servers', __name__, url_prefix='/api/servers')


@servers_bp.route('', methods=['GET'])
@jwt_required
def get_servers():
    """
    获取服务器列表
    支持查询参数: env_type, search, page, page_size
    """
    db = get_db()
    cursor = db.cursor()
    try:
        env_filter = request.args.get('env_type', '')
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
        db.close()


@servers_bp.route('/<int:server_id>', methods=['GET'])
@jwt_required
def get_server_detail(server_id):
    """
    获取服务器详情（含关联服务列表）
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
        db.close()


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
        db.close()


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
        data = request.json
        cursor.execute(
            "INSERT INTO servers (env_type, platform, hostname, inner_ip, mapped_ip, public_ip, "
            "cpu, memory, sys_disk, data_disk, purpose, os_user, os_password, docker_password, remark) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
            (data.get('env_type'), data.get('platform'), data.get('hostname'),
             data.get('inner_ip'), data.get('mapped_ip'), data.get('public_ip'),
             data.get('cpu'), data.get('memory'), data.get('sys_disk'),
             data.get('data_disk'), data.get('purpose'), data.get('os_user'),
             data.get('os_password'), data.get('docker_password'), data.get('remark'))
        )
        db.commit()
        return jsonify({
            'code': 200,
            'message': '创建成功',
            'data': {'id': cursor.lastrowid}
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'创建失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


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
        data = request.json
        fields = []
        values = []
        for key in ['env_type', 'platform', 'hostname', 'inner_ip', 'mapped_ip', 'public_ip',
                     'cpu', 'memory', 'sys_disk', 'data_disk', 'purpose', 'os_user',
                     'os_password', 'docker_password', 'remark']:
            if key in data:
                fields.append(f"`{key}` = %s")
                values.append(data[key])

        if fields:
            values.append(server_id)
            cursor.execute(f"UPDATE servers SET {', '.join(fields)} WHERE id = %s", values)
            db.commit()
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
        db.close()


@servers_bp.route('/<int:server_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_server(server_id):
    """
    删除服务器
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM servers WHERE id = %s", (server_id,))
        db.commit()
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
        db.close()
