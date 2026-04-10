"""
操作日志记录工具
"""
import json
import logging
from datetime import datetime, timezone
from flask import request, g
from .db import get_db

logger = logging.getLogger(__name__)


def _client_ip():
    """优先使用反向代理传递的真实 IP。"""
    if not request:
        return None
    xff = request.headers.get("X-Forwarded-For") or request.headers.get("X-Real-IP")
    if xff:
        return xff.split(",")[0].strip()[:50]
    return (request.remote_addr or "")[:50]


def _resolve_operator(user_id=None, username=None):
    """
    解析「操作用户」：显式传入的 user_id / username 优先（可只传其一），
    否则从 JWT 上下文 g.current_user 补全。

    注意：此前逻辑要求 user_id 与 username 同时为真才采用传入值，
    导致登录失败等场景仅传入 username 时被 else 分支覆盖为 unknown。
    """
    uid = user_id
    uname = username

    if uid is None and hasattr(g, "current_user") and g.current_user:
        uid = g.current_user.get("user_id")
    if uid is None:
        uid = g.get("user_id")

    if uname is None and hasattr(g, "current_user") and g.current_user:
        uname = g.current_user.get("username")
    if uname is None:
        uname = g.get("username")
    if uname is None:
        uname = "unknown"

    return uid, uname


def log_operation(
    module,
    action,
    target_id=None,
    target_name=None,
    detail=None,
    user_id=None,
    username=None,
):
    """
    记录操作日志

    module / action: 模块与操作类型
    target_id / target_name: 操作对象
    detail: 详情 dict
    user_id / username: 操作用户（可选；登录失败等场景可只传 username）
    """
    cursor = None
    try:
        db = get_db()
        cursor = db.cursor()

        op_uid, op_uname = _resolve_operator(user_id=user_id, username=username)

        user_agent = None
        if request:
            user_agent = (request.headers.get("User-Agent") or "")[:500]

        try:
            detail_json = json.dumps(detail, ensure_ascii=False, default=str) if detail else None
        except Exception:
            detail_json = json.dumps(detail, default=str) if detail else None

        # 使用 UTC 时间，与 JWT 保持一致
        created_at = datetime.now(timezone.utc).replace(tzinfo=None)

        logger.debug(
            "记录操作日志: module=%s action=%s user=%s(%s) target=%s(%s)",
            module, action, op_uname, op_uid, target_name, target_id
        )

        cursor.execute(
            """
            INSERT INTO operation_logs
            (user_id, username, module, action, target_id, target_name, detail, ip, user_agent, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
            """,
            (
                op_uid,
                op_uname,
                module,
                action,
                target_id,
                target_name,
                detail_json,
                _client_ip(),
                user_agent,
                created_at,
            ),
        )

        db.commit()
        logger.debug("操作日志记录成功: %s.%s", module, action)

    except Exception as e:
        # 使用 error 级别确保错误可见
        logger.error("记录操作日志失败: %s", e, exc_info=True)
    finally:
        if cursor:
            cursor.close()


def log_login(user_id, username, success=True, detail=None):
    """记录登录操作（与 log_operation 一致：同时写入 target 与操作用户）"""
    log_operation(
        module="用户认证",
        action="login" if success else "login_failed",
        target_id=user_id,
        target_name=username,
        detail=detail,
        user_id=user_id,
        username=username,
    )


def log_logout(user_id, username):
    """记录登出操作"""
    log_operation(
        module="用户认证",
        action="logout",
        target_id=user_id,
        target_name=username,
        user_id=user_id,
        username=username,
    )


MODULE_NAMES = {
    "servers": "服务器管理",
    "services": "服务管理",
    "apps": "账号管理",
    "domains": "域名管理",
    "certs": "证书管理",
    "users": "用户管理",
    "aliyun_accounts": "凭证管理",
    "tasks": "定时任务",
    "role_modules": "角色授权",
}

ACTION_NAMES = {
    "create": "新增",
    "update": "更新",
    "delete": "删除",
    "import": "导入",
    "export": "导出",
    "login": "登录",
    "logout": "登出",
    "login_failed": "登录失败",
    "check": "检测",
    "deploy": "部署",
    "sync": "同步",
    "upload": "上传",
    "download": "下载",
}
