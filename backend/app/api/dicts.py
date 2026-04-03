"""
字典管理 API - 环境类型、平台、服务分类字典维护
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required

dicts_bp = Blueprint('dicts', __name__, url_prefix='/api/dicts')


def _get_db_connection():
    """获取数据库连接"""
    return get_db()


def _get_dict_items(table_name):
    """通用查询字典列表"""
    db = _get_db_connection()
    try:
        cursor = db.cursor()
        cursor.execute(f"SELECT * FROM {table_name} ORDER BY sort_order, id")
        items = cursor.fetchall()
        return jsonify({"code": 200, "data": items})
    finally:
        cursor.close()


def _create_dict_item(table_name, name, sort_order=0):
    """通用创建字典项"""
    db = _get_db_connection()
    try:
        cursor = db.cursor()
        cursor.execute(
            f"INSERT INTO {table_name} (name, sort_order) VALUES (%s, %s)",
            (name, sort_order)
        )
        db.commit()
        return jsonify({
            "code": 200,
            "message": "创建成功",
            "data": {"id": cursor.lastrowid}
        })
    except Exception as e:
        db.rollback()
        if "Duplicate" in str(e) or "UNIQUE" in str(e):
            return jsonify({"code": 400, "message": "该名称已存在"}), 400
        return jsonify({"code": 500, "message": f"创建失败: {str(e)}"}), 500
    finally:
        cursor.close()


def _update_dict_item(table_name, item_id, name, sort_order):
    """通用更新字典项"""
    db = _get_db_connection()
    try:
        cursor = db.cursor()
        fields = []
        values = []
        if name is not None:
            fields.append("name = %s")
            values.append(name)
        if sort_order is not None:
            fields.append("sort_order = %s")
            values.append(sort_order)
        
        if not fields:
            return jsonify({"code": 400, "message": "没有要更新的字段"}), 400
        
        values.append(item_id)
        cursor.execute(f"UPDATE {table_name} SET {', '.join(fields)} WHERE id = %s", values)
        db.commit()
        return jsonify({"code": 200, "message": "更新成功"})
    except Exception as e:
        db.rollback()
        if "Duplicate" in str(e) or "UNIQUE" in str(e):
            return jsonify({"code": 400, "message": "该名称已存在"}), 400
        return jsonify({"code": 500, "message": f"更新失败: {str(e)}"}), 500
    finally:
        cursor.close()


def _delete_dict_item(table_name, item_id, check_table=None, check_field=None):
    """通用删除字典项，可选检查关联数据"""
    db = _get_db_connection()
    try:
        cursor = db.cursor()
        
        # 如果需要检查关联数据
        if check_table and check_field:
            # 先获取字典项名称
            cursor.execute(f"SELECT name FROM {table_name} WHERE id = %s", (item_id,))
            item = cursor.fetchone()
            if not item:
                return jsonify({"code": 404, "message": "记录不存在"}), 404
            
            item_name = item['name']
            # 检查是否有关联数据
            cursor.execute(f"SELECT COUNT(*) as cnt FROM {check_table} WHERE {check_field} = %s", (item_name,))
            count = cursor.fetchone()['cnt']
            if count > 0:
                return jsonify({
                    "code": 400, 
                    "message": f"该字典项已被使用，无法删除（关联{count}条数据）"
                }), 400
        
        cursor.execute(f"DELETE FROM {table_name} WHERE id = %s", (item_id,))
        if cursor.rowcount == 0:
            return jsonify({"code": 404, "message": "记录不存在"}), 404
        db.commit()
        return jsonify({"code": 200, "message": "删除成功"})
    except Exception as e:
        db.rollback()
        return jsonify({"code": 500, "message": f"删除失败: {str(e)}"}), 500
    finally:
        cursor.close()


# ==================== 环境类型字典接口 ====================

@dicts_bp.route('/env-types', methods=['GET'])
@jwt_required
def get_env_types():
    """获取环境类型列表"""
    return _get_dict_items('dict_env_types')


@dicts_bp.route('/env-types', methods=['POST'])
@jwt_required
@role_required(['admin'])
def create_env_type():
    """新增环境类型"""
    data = request.json
    name = data.get('name', '').strip()
    sort_order = data.get('sort_order', 0)
    
    if not name:
        return jsonify({"code": 400, "message": "名称不能为空"}), 400
    
    return _create_dict_item('dict_env_types', name, sort_order)


@dicts_bp.route('/env-types/<int:item_id>', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_env_type(item_id):
    """修改环境类型"""
    data = request.json
    name = data.get('name')
    sort_order = data.get('sort_order')
    
    if name is not None:
        name = name.strip()
        if not name:
            return jsonify({"code": 400, "message": "名称不能为空"}), 400
    
    return _update_dict_item('dict_env_types', item_id, name, sort_order)


@dicts_bp.route('/env-types/<int:item_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin'])
def delete_env_type(item_id):
    """删除环境类型"""
    return _delete_dict_item('dict_env_types', item_id, 'servers', 'env_type')


# ==================== 平台字典接口 ====================

@dicts_bp.route('/platforms', methods=['GET'])
@jwt_required
def get_platforms():
    """获取平台列表"""
    return _get_dict_items('dict_platforms')


@dicts_bp.route('/platforms', methods=['POST'])
@jwt_required
@role_required(['admin'])
def create_platform():
    """新增平台"""
    data = request.json
    name = data.get('name', '').strip()
    sort_order = data.get('sort_order', 0)
    
    if not name:
        return jsonify({"code": 400, "message": "名称不能为空"}), 400
    
    return _create_dict_item('dict_platforms', name, sort_order)


@dicts_bp.route('/platforms/<int:item_id>', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_platform(item_id):
    """修改平台"""
    data = request.json
    name = data.get('name')
    sort_order = data.get('sort_order')
    
    if name is not None:
        name = name.strip()
        if not name:
            return jsonify({"code": 400, "message": "名称不能为空"}), 400
    
    return _update_dict_item('dict_platforms', item_id, name, sort_order)


@dicts_bp.route('/platforms/<int:item_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin'])
def delete_platform(item_id):
    """删除平台"""
    return _delete_dict_item('dict_platforms', item_id, 'servers', 'platform')


# ==================== 服务分类字典接口 ====================

@dicts_bp.route('/service-categories', methods=['GET'])
@jwt_required
def get_service_categories():
    """获取服务分类列表"""
    return _get_dict_items('dict_service_categories')


@dicts_bp.route('/service-categories', methods=['POST'])
@jwt_required
@role_required(['admin'])
def create_service_category():
    """新增服务分类"""
    data = request.json
    name = data.get('name', '').strip()
    sort_order = data.get('sort_order', 0)
    
    if not name:
        return jsonify({"code": 400, "message": "名称不能为空"}), 400
    
    return _create_dict_item('dict_service_categories', name, sort_order)


@dicts_bp.route('/service-categories/<int:item_id>', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_service_category(item_id):
    """修改服务分类"""
    data = request.json
    name = data.get('name')
    sort_order = data.get('sort_order')
    
    if name is not None:
        name = name.strip()
        if not name:
            return jsonify({"code": 400, "message": "名称不能为空"}), 400
    
    return _update_dict_item('dict_service_categories', item_id, name, sort_order)


@dicts_bp.route('/service-categories/<int:item_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin'])
def delete_service_category(item_id):
    """删除服务分类"""
    return _delete_dict_item('dict_service_categories', item_id, 'services', 'category')
