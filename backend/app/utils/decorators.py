"""
权限装饰器
"""
from datetime import datetime, timezone
from functools import wraps
from flask import request, g, jsonify
from .auth import verify_token


def _issued_at_naive(payload):
    """JWT iat 转为 naive UTC datetime，便于与 MySQL DATETIME 比较。"""
    iat = payload.get("iat")
    if iat is None:
        return None
    if isinstance(iat, datetime):
        dt = iat
        if dt.tzinfo:
            dt = dt.astimezone(timezone.utc).replace(tzinfo=None)
        return dt
    try:
        return datetime.utcfromtimestamp(int(iat))
    except (TypeError, ValueError, OSError):
        return None


def jwt_required(f):
    """
    JWT 认证装饰器：校验令牌、用户存在、已启用、密码未在签发后修改；角色以数据库为准。
    """

    @wraps(f)
    def decorated_function(*args, **kwargs):
        auth_header = request.headers.get("Authorization")

        if not auth_header:
            return (
                jsonify(
                    {
                        "code": 401,
                        "message": "缺少认证信息",
                    }
                ),
                401,
            )

        parts = auth_header.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            return (
                jsonify(
                    {
                        "code": 401,
                        "message": "认证格式错误，请使用 Bearer token",
                    }
                ),
                401,
            )

        token = parts[1]
        payload = verify_token(token)

        if not payload:
            return (
                jsonify(
                    {
                        "code": 401,
                        "message": "Token 无效或已过期",
                    }
                ),
                401,
            )

        from ..models.user import get_user_by_id

        user_id = payload.get("user_id")
        user = get_user_by_id(user_id) if user_id is not None else None
        if not user:
            return (
                jsonify(
                    {
                        "code": 401,
                        "message": "用户不存在",
                    }
                ),
                401,
            )

        if not user.get("is_active"):
            return (
                jsonify(
                    {
                        "code": 401,
                        "message": "用户已被禁用",
                    }
                ),
                401,
            )

        pwd_changed = user.get("password_changed_at")
        issued = _issued_at_naive(payload)
        if pwd_changed and issued:
            pc = pwd_changed
            if getattr(pc, "tzinfo", None):
                pc = pc.replace(tzinfo=None)
            if pc > issued:
                return (
                    jsonify(
                        {
                            "code": 401,
                            "message": "Token 已失效，请重新登录",
                        }
                    ),
                    401,
                )

        g.current_user = {
            "user_id": user["id"],
            "username": user["username"],
            "role": user["role"],
        }

        return f(*args, **kwargs)

    return decorated_function


def role_required(roles):
    """
    角色权限检查装饰器（须配合 @jwt_required，且 jwt_required 在下层先执行）。
    """

    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not hasattr(g, "current_user"):
                return (
                    jsonify(
                        {
                            "code": 401,
                            "message": "未进行 JWT 认证",
                        }
                    ),
                    401,
                )

            user_role = g.current_user.get("role")

            if user_role not in roles:
                return (
                    jsonify(
                        {
                            "code": 403,
                            "message": "权限不足，需要角色: " + ", ".join(roles),
                        }
                    ),
                    403,
                )

            return f(*args, **kwargs)

        return decorated_function

    return decorator


def module_required(module_code):
    """
    模块访问权限检查装饰器（须在 @jwt_required 之后使用）
    - admin角色直接通过（bypass）
    - 其他角色检查 role_modules 表中是否有对应模块权限
    - 无权限返回 403
    """

    def decorator(f):
        @wraps(f)
        def decorated_function(*args, **kwargs):
            if not hasattr(g, "current_user"):
                return (
                    jsonify(
                        {
                            "code": 401,
                            "message": "未进行 JWT 认证",
                        }
                    ),
                    401,
                )

            user_role = g.current_user.get("role")

            # admin角色直接通过
            if user_role == "admin":
                return f(*args, **kwargs)

            # 延迟导入避免循环依赖
            from ..models.role_module import get_modules_by_role

            # 检查模块权限
            allowed_modules = get_modules_by_role(user_role)
            if module_code not in allowed_modules:
                return (
                    jsonify(
                        {
                            "code": 403,
                            "message": "无模块访问权限",
                        }
                    ),
                    403,
                )

            return f(*args, **kwargs)

        return decorated_function

    return decorator
