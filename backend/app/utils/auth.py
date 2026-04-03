"""
JWT 认证工具
"""
import jwt
from datetime import datetime, timedelta, timezone
from flask import current_app


def generate_token(user_id, username, role):
    """
    生成 JWT token
    """
    expiration_hours = current_app.config.get("JWT_EXPIRATION_HOURS", 24)
    now = datetime.now(timezone.utc)

    payload = {
        "user_id": user_id,
        "username": username,
        "role": role,
        "exp": now + timedelta(hours=expiration_hours),
        "iat": now,
    }

    secret_key = current_app.config.get("JWT_SECRET_KEY")
    if not secret_key:
        raise RuntimeError("未配置 JWT_SECRET_KEY，无法签发令牌")

    return jwt.encode(payload, secret_key, algorithm="HS256")


def verify_token(token):
    """
    验证并解码 JWT token，失败返回 None
    """
    try:
        secret_key = current_app.config.get("JWT_SECRET_KEY")
        if not secret_key:
            return None
        payload = jwt.decode(token, secret_key, algorithms=["HS256"])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None
