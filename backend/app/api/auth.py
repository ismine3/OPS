"""
认证 API
"""
from flask import Blueprint, request, jsonify, g
from werkzeug.security import check_password_hash, generate_password_hash

from ..models.user import get_user_by_username, update_password
from ..utils.auth import generate_token
from ..utils.decorators import jwt_required
from ..utils.operation_log import log_operation

auth_bp = Blueprint('auth', __name__, url_prefix='/api/auth')


@auth_bp.route('/login', methods=['POST'])
def login():
    """
    用户登录
    
    请求体: {"username": "xxx", "password": "xxx"}
    成功返回: {"code": 200, "message": "登录成功", "data": {"token": "xxx", "user": {...}}}
    失败返回: {"code": 401, "message": "用户名或密码错误"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    username = data.get('username')
    password = data.get('password')
    
    if not username or not password:
        return jsonify({
            'code': 400,
            'message': '用户名和密码不能为空'
        }), 400
    
    # 查询用户
    user = get_user_by_username(username)
    
    if not user:
        # 记录登录失败
        log_operation(module='用户认证', action='login_failed', target_name=username, detail={'reason': '用户不存在'}, user_id=None, username=username)
        return jsonify({
            'code': 401,
            'message': '用户名或密码错误'
        }), 401
    
    # 检查用户是否激活
    if not user.get('is_active'):
        log_operation(module='用户认证', action='login_failed', target_id=user['id'], target_name=username, detail={'reason': '用户已禁用'}, user_id=user['id'], username=username)
        return jsonify({
            'code': 401,
            'message': '用户已被禁用'
        }), 401
    
    # 验证密码
    if not check_password_hash(user['password_hash'], password):
        log_operation(module='用户认证', action='login_failed', target_id=user['id'], target_name=username, detail={'reason': '密码错误'}, user_id=user['id'], username=username)
        return jsonify({
            'code': 401,
            'message': '用户名或密码错误'
        }), 401
    
    # 记录登录成功
    log_operation(module='用户认证', action='login', target_id=user['id'], target_name=username, user_id=user['id'], username=username)
    
    # 生成 token
    token = generate_token(
        user_id=user['id'],
        username=user['username'],
        role=user['role']
    )
    
    return jsonify({
        'code': 200,
        'message': '登录成功',
        'data': {
            'token': token,
            'user': {
                'id': user['id'],
                'username': user['username'],
                'display_name': user['display_name'],
                'role': user['role']
            }
        }
    }), 200


@auth_bp.route('/profile', methods=['GET'])
@jwt_required
def get_profile():
    """
    获取当前用户信息
    需要 JWT 认证
    
    返回: {"code": 200, "data": {id, username, display_name, role, is_active, created_at}}
    """
    from ..models.user import get_user_by_id
    
    user_id = g.current_user['user_id']
    user = get_user_by_id(user_id)
    
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404
    
    return jsonify({
        'code': 200,
        'data': {
            'id': user['id'],
            'username': user['username'],
            'display_name': user['display_name'],
            'role': user['role'],
            'is_active': user['is_active'],
            'created_at': user['created_at'].isoformat() if user['created_at'] else None
        }
    }), 200


@auth_bp.route('/password', methods=['PUT'])
@jwt_required
def change_password():
    """
    修改密码
    需要 JWT 认证
    
    请求体: {"old_password": "xxx", "new_password": "xxx"}
    返回: {"code": 200, "message": "密码修改成功"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    old_password = data.get('old_password')
    new_password = data.get('new_password')
    
    if not old_password or not new_password:
        return jsonify({
            'code': 400,
            'message': '旧密码和新密码不能为空'
        }), 400
    
    if len(new_password) < 6:
        return jsonify({
            'code': 400,
            'message': '新密码长度不能少于6位'
        }), 400
    
    user_id = g.current_user['user_id']
    
    # 获取用户信息验证旧密码
    from ..models.user import get_user_by_id
    user = get_user_by_id(user_id)
    
    if not user:
        return jsonify({
            'code': 404,
            'message': '用户不存在'
        }), 404
    
    # 验证旧密码
    if not check_password_hash(user['password_hash'], old_password):
        return jsonify({
            'code': 400,
            'message': '旧密码错误'
        }), 400
    
    # 更新密码
    new_password_hash = generate_password_hash(new_password)
    success = update_password(user_id, new_password_hash)
    
    if success:
        return jsonify({
            'code': 200,
            'message': '密码修改成功'
        }), 200
    else:
        return jsonify({
            'code': 500,
            'message': '密码修改失败'
        }), 500
