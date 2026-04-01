"""
JWT 认证工具
"""
import jwt
import datetime
from flask import current_app, request, g
from functools import wraps
from werkzeug.security import generate_password_hash, check_password_hash


def generate_token(user_id, username, role):
    """
    生成 JWT token
    
    Args:
        user_id: 用户ID
        username: 用户名
        role: 用户角色
    
    Returns:
        JWT token 字符串
    """
    expiration_hours = current_app.config.get('JWT_EXPIRATION_HOURS', 24)
    
    payload = {
        'user_id': user_id,
        'username': username,
        'role': role,
        'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=expiration_hours),
        'iat': datetime.datetime.utcnow()
    }
    
    secret_key = current_app.config.get('JWT_SECRET_KEY', 'jwt-secret-key-change-in-prod')
    
    return jwt.encode(payload, secret_key, algorithm='HS256')


def verify_token(token):
    """
    验证并解码 JWT token
    
    Args:
        token: JWT token 字符串
    
    Returns:
        解码后的 payload 字典，验证失败返回 None
    """
    try:
        secret_key = current_app.config.get('JWT_SECRET_KEY', 'jwt-secret-key-change-in-prod')
        payload = jwt.decode(token, secret_key, algorithms=['HS256'])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None


def hash_password(password):
    """
    生成密码哈希
    
    Args:
        password: 明文密码
    
    Returns:
        密码哈希值
    """
    return generate_password_hash(password)


def check_password(password_hash, password):
    """
    验证密码
    
    Args:
        password_hash: 密码哈希值
        password: 明文密码
    
    Returns:
        是否验证通过
    """
    return check_password_hash(password_hash, password)
