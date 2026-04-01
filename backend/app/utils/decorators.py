"""
权限装饰器
"""
from functools import wraps
from flask import request, g, jsonify
from .auth import verify_token


def jwt_required(f):
    """
    JWT 认证装饰器
    从 Authorization header 提取 Bearer token，验证后将用户信息存入 flask.g.current_user
    
    使用方法:
        @jwt_required
        def protected_route():
            user_id = g.current_user['user_id']
            ...
    """
    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get('Authorization')
        
        if not auth_header:
            return jsonify({
                'code': 401,
                'message': '缺少认证信息'
            }), 401
        
        # 支持 "Bearer <token>" 格式
        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != 'bearer':
            return jsonify({
                'code': 401,
                'message': '认证格式错误，请使用 Bearer token'
            }), 401
        
        token = parts[1]
        payload = verify_token(token)
        
        if not payload:
            return jsonify({
                'code': 401,
                'message': 'Token 无效或已过期'
            }), 401
        
        # 将用户信息存入 g
        g.current_user = {
            'user_id': payload.get('user_id'),
            'username': payload.get('username'),
            'role': payload.get('role')
        }
        
        return f(*args, **kwargs)
    
    return decorated_function


def role_required(roles):
    """
    角色权限检查装饰器
    必须在 @jwt_required 之后使用，检查 g.current_user['role'] 是否在 roles 列表中
    
    Args:
        roles: 允许的角色列表，如 ['admin'] 或 ['admin', 'operator']
    
    使用方法:
        @jwt_required
        @role_required(['admin'])
        def admin_only_route():
            ...
    """
    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not hasattr(g, 'current_user'):
                return jsonify({
                    'code': 401,
                    'message': '未进行 JWT 认证'
                }), 401
            
            user_role = g.current_user.get('role')
            
            if user_role not in roles:
                return jsonify({
                    'code': 403,
                    'message': '权限不足，需要角色: ' + ', '.join(roles)
                }), 403
            
            return f(*args, **kwargs)
        
        return decorated_function
    
    return decorator
