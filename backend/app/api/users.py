"""
用户管理 API
所有接口需要管理员权限
"""
from flask import Blueprint, request, jsonify, g
from ..utils.password_utils import hash_password
from ..utils.validators import validate_username

from ..models.user import (
    create_user, get_all_users, get_user_by_id, 
    update_user, delete_user, update_password
)
from ..utils.decorators import jwt_required, role_required
from ..utils.operation_log import log_operation

users_bp = Blueprint('users', __name__, url_prefix='/api/users')


@users_bp.route('', methods=['GET'])
@jwt_required
@role_required(['admin'])
def get_users():
    """
    获取用户列表
    
    返回: {"code": 200, "data": [用户列表]}
    """
    users = get_all_users()
    return jsonify({
        'code': 200,
        'data': users
    }), 200


@users_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin'])
def create_new_user():
    """
    创建用户
    
    请求体: {"username": "xxx", "password": "xxx", "display_name": "xxx", "role": "operator"}
    返回: {"code": 200, "message": "用户创建成功"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    username = data.get('username')
    password = data.get('password')
    display_name = data.get('display_name')
    role = data.get('role', 'operator')
    
    # 验证必填字段
    if not username or not password or not display_name:
        return jsonify({
            'code': 400,
            'message': '用户名、密码和显示名称不能为空'
        }), 400
    
    # 验证用户名格式
    if not validate_username(username):
        return jsonify({
            'code': 400,
            'message': '用户名格式不正确，只能包含字母、数字和下划线，长度3-20位'
        }), 400
    
    # 验证角色
    if role not in ['admin', 'operator', 'viewer']:
        return jsonify({
            'code': 400,
            'message': '角色必须是 admin、operator 或 viewer'
        }), 400
    
    # 验证密码长度
    if len(password) < 6:
        return jsonify({
            'code': 400,
            'message': '密码长度不能少于6位'
        }), 400
    
    # 检查用户名是否已存在
    from ..models.user import get_user_by_username
    if get_user_by_username(username):
        return jsonify({
            'code': 409,
            'message': '用户名已存在'
        }), 409
    
    try:
        user_id = create_user(username, password, display_name, role)
        
        # 记录操作日志
        log_operation('用户管理', 'create', user_id, username, {'role': role})
        
        return jsonify({
            'code': 200,
            'message': '用户创建成功',
            'data': {'id': user_id}
        }), 200
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'用户创建失败: {str(e)}'
        }), 500


@users_bp.route('/<int:user_id>', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_user_info(user_id):
    """
    更新用户信息
    
    请求体: {"display_name": "xxx", "role": "xxx", "is_active": true/false}
    返回: {"code": 200, "message": "用户更新成功"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    # 检查用户是否存在
    user = get_user_by_id(user_id)
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404
    
    # 验证角色
    if 'role' in data and data['role'] not in ['admin', 'operator', 'viewer']:
        return jsonify({
            'code': 400,
            'message': '角色必须是 admin、operator 或 viewer'
        }), 400
    
    # 构建更新数据
    update_data = {}
    if 'display_name' in data:
        update_data['display_name'] = data['display_name']
    if 'role' in data:
        update_data['role'] = data['role']
    if 'is_active' in data:
        update_data['is_active'] = data['is_active']
    
    if not update_data:
        return jsonify({
            'code': 400,
            'message': '没有要更新的字段'
        }), 400
    
    try:
        success = update_user(user_id, update_data)
        if success:
            # 记录操作日志
            log_operation('用户管理', 'update', user_id, user['username'], update_data)
            
            return jsonify({
                'code': 200,
                'message': '用户更新成功'
            }), 200
        else:
            return jsonify({
                'code': 400,
                'message': '用户更新失败，可能没有变化'
            }), 400
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'用户更新失败: {str(e)}'
        }), 500


@users_bp.route('/<int:user_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin'])
def delete_user_by_id(user_id):
    """
    删除用户（不能删除自己）
    
    返回: {"code": 200, "message": "用户删除成功"}
    """
    # 检查是否是当前用户
    current_user_id = g.current_user['user_id']
    if user_id == current_user_id:
        return jsonify({
            'code': 400,
            'message': '不能删除当前登录的用户'
        }), 400
    
    # 检查用户是否存在
    user = get_user_by_id(user_id)
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404
    
    try:
        success = delete_user(user_id)
        if success:
            # 记录操作日志
            log_operation('用户管理', 'delete', user_id, user['username'])
            
            return jsonify({
                'code': 200,
                'message': '用户删除成功'
            }), 200
        else:
            return jsonify({
                'code': 400,
                'message': '用户删除失败'
            }), 400
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'用户删除失败: {str(e)}'
        }), 500


@users_bp.route('/<int:user_id>/reset-password', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def reset_user_password(user_id):
    """
    重置用户密码
    
    请求体: {"new_password": "xxx"}
    返回: {"code": 200, "message": "密码重置成功"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    new_password = data.get('new_password')
    
    if not new_password:
        return jsonify({
            'code': 400,
            'message': '新密码不能为空'
        }), 400
    
    if len(new_password) < 6:
        return jsonify({
            'code': 400,
            'message': '密码长度不能少于6位'
        }), 400
    
    # 检查用户是否存在
    user = get_user_by_id(user_id)
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404
    
    try:
        password_hash = hash_password(new_password)
        success = update_password(user_id, password_hash)
        if success:
            # 记录操作日志
            log_operation('用户管理', 'update', user_id, user['username'], {'action': 'reset_password'})
            
            return jsonify({
                'code': 200,
                'message': '密码重置成功'
            }), 200
        else:
            return jsonify({
                'code': 400,
                'message': '密码重置失败'
            }), 400
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'密码重置失败: {str(e)}'
        }), 500
