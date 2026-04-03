import logging

import pymysql
from flask import current_app, g

logger = logging.getLogger(__name__)


def _mask_password(pwd):
    if not pwd:
        return "(空)"
    s = str(pwd)
    if len(s) <= 2:
        return "***"
    return s[0] + "***" + s[-1]


def _db_connect_params(config):
    return {
        "host": config.get("DB_HOST", "127.0.0.1"),
        "port": int(config.get("DB_PORT", 3306)),
        "user": config.get("DB_USER", "root"),
        "password": config.get("DB_PASSWORD", ""),
        "database": config.get("DB_NAME", "ops_platform"),
    }


def log_database_target(config=None):
    """启动时打印即将连接的数据库目标（密码脱敏），便于核对配置是否生效。"""
    if config is None:
        config = current_app.config
    p = _db_connect_params(config)
    logger.info(
        "数据库配置: host=%s port=%s user=%s database=%s password=%s",
        p["host"],
        p["port"],
        p["user"],
        p["database"],
        _mask_password(p["password"]),
    )


def get_db():
    """获取数据库连接（使用 Flask 应用上下文缓存）。"""
    if "db" not in g:
        config = current_app.config
        params = _db_connect_params(config)
        try:
            g.db = pymysql.connect(
                host=params["host"],
                port=params["port"],
                user=params["user"],
                password=params["password"],
                database=params["database"],
                charset="utf8mb4",
                cursorclass=pymysql.cursors.DictCursor,
                connect_timeout=10,
            )
        except Exception as e:
            logger.exception(
                "数据库连接失败: host=%s port=%s user=%s database=%s | pymysql 错误: %s",
                params["host"],
                params["port"],
                params["user"],
                params["database"],
                e,
            )
            raise
    return g.db


def close_db(e=None):
    """关闭数据库连接"""
    db = g.pop("db", None)
    if db is not None:
        try:
            db.close()
        except Exception:
            pass
