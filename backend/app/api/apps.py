"""
应用系统管理 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required

apps_bp = Blueprint('apps', __name__, url_prefix='/api/apps')


@apps_bp.route('', methods=['GET'])
@jwt_required
def get_apps():
    """
    获取应用系统列表
    支持查询参数: search（搜索 name、company、access_url）, page, page_size
    """
    db = get_db()
    cursor = db.cursor()
    try:
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
        if search:
            where_clause += " AND (name LIKE %s OR company LIKE %s OR access_url LIKE %s)"
            params.extend([f'%{search}%'] * 3)

        # 查询总数
        count_sql = f"SELECT COUNT(*) as total FROM app_systems {where_clause}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']

        # 查询数据
        sql = f"SELECT * FROM app_systems {where_clause} ORDER BY id LIMIT %s OFFSET %s"
        offset = (page - 1) * page_size
        cursor.execute(sql, params + [page_size, offset])
        apps = cursor.fetchall()

        return jsonify({
            'code': 200,
            'data': {
                'items': apps,
                'total': total,
                'page': page,
                'page_size': page_size
            }
        })
    finally:
        cursor.close()
        db.close()


@apps_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def create_app():
    """
    创建应用系统
    字段：seq_no, name, company, access_url, username, password, remark
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        cursor.execute(
            "INSERT INTO app_systems (seq_no, name, company, access_url, username, password, remark) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (data.get('seq_no'), data.get('name'), data.get('company'),
             data.get('access_url'), data.get('username'), data.get('password'),
             data.get('remark'))
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


@apps_bp.route('/<int:app_id>', methods=['PUT'])
@jwt_required
@role_required(['admin', 'operator'])
def update_app(app_id):
    """
    更新应用系统
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        fields = []
        values = []
        for key in ['seq_no', 'name', 'company', 'access_url', 'username', 'password', 'remark']:
            if key in data:
                fields.append(f"`{key}` = %s")
                values.append(data[key])
        if fields:
            values.append(app_id)
            cursor.execute(f"UPDATE app_systems SET {', '.join(fields)} WHERE id = %s", values)
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


@apps_bp.route('/<int:app_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_app(app_id):
    """
    删除应用系统
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM app_systems WHERE id = %s", (app_id,))
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
