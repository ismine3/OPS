"""
操作日志记录工具
"""
import json
import logging
from datetime import datetime
from flask import request, g
from .db import get_db

logger = logging.getLogger(__name__)


def log_operation(module, action, target_id=None, target_name=None, detail=None, user_id=None, username=None):
    """
    记录操作日志
    
    参数:
        module: 操作模块 (服务器/服务/应用/域名/证书/用户/阿里云账户/定时任务等)
        action: 操作类型 (create/update/delete/login/logout/import/export等)
        target_id: 操作对象ID (可选)
        target_name: 操作对象名称 (可选)
        detail: 操作详情，字典格式 (可选)
        user_id: 执行操作的用户ID (可选，用于登录等特殊场景)
        username: 执行操作的用户名 (可选，用于登录等特殊场景)
    """
    db = None
    cursor = None
    try:
        db = get_db()
        cursor = db.cursor()
        
        # 获取当前用户信息
        # 优先使用传入的参数（用于登录等特殊场景）
        # 其次从 g.current_user 读取（jwt_required装饰器设置），再次从 g 对象直接读取（before_request设置）
        if user_id is not None and username is not None:
            # 使用传入的用户信息
            pass
        elif hasattr(g, 'current_user') and g.current_user:
            user_id = g.current_user.get('user_id')
            username = g.current_user.get('username', 'unknown')
        else:
            user_id = g.get('user_id')
            username = g.get('username', 'unknown')
        
        # 获取请求信息
        ip = request.remote_addr if request else None
        user_agent = request.headers.get('User-Agent', '')[:500] if request else None
        
        # 处理详情
        detail_json = json.dumps(detail, ensure_ascii=False) if detail else None
        
        cursor.execute("""
            INSERT INTO operation_logs 
            (user_id, username, module, action, target_id, target_name, detail, ip, user_agent, created_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (user_id, username, module, action, target_id, target_name, detail_json, ip, user_agent, datetime.now()))
        
        db.commit()
        
    except Exception as e:
        logger.error(f"记录操作日志失败: {e}")
    finally:
        if cursor:
            cursor.close()
        # 注意：不在此处关闭db连接，由teardown_appcontext统一处理


def log_login(user_id, username, success=True, detail=None):
    """记录登录操作"""
    log_operation(
        module='用户认证',
        action='login' if success else 'login_failed',
        target_id=user_id,
        target_name=username,
        detail=detail
    )


def log_logout(user_id, username):
    """记录登出操作"""
    log_operation(
        module='用户认证',
        action='logout',
        target_id=user_id,
        target_name=username
    )


# 模块名称映射
MODULE_NAMES = {
    'servers': '服务器管理',
    'services': '服务管理',
    'apps': '应用系统',
    'domains': '域名管理',
    'certs': '证书管理',
    'users': '用户管理',
    'aliyun_accounts': '阿里云账户',
    'tasks': '定时任务',
}

# 操作类型映射
ACTION_NAMES = {
    'create': '新增',
    'update': '更新',
    'delete': '删除',
    'import': '导入',
    'export': '导出',
    'login': '登录',
    'logout': '登出',
    'login_failed': '登录失败',
    'check': '检测',
    'deploy': '部署',
    'sync': '同步',
    'upload': '上传',
    'download': '下载',
}
