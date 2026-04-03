"""
启动时轻量迁移（幂等），与 init_db 全量建表互补。
"""
import logging
import pymysql

logger = logging.getLogger(__name__)


def ensure_schema():
    """在应用上下文中调用：补全 users.password_changed_at 等列。"""
    from .db import get_db

    try:
        db = get_db()
    except Exception:
        logger.exception("ensure_schema: 连接数据库失败，请检查 DB_* 与 MySQL 是否可达")
        raise

    try:
        with db.cursor() as cursor:
            try:
                cursor.execute(
                    """
                    ALTER TABLE users
                    ADD COLUMN password_changed_at DATETIME NULL DEFAULT NULL
                    COMMENT '密码修改时间，早于该时间的 JWT 作废'
                    """
                )
                db.commit()
                logger.info("已添加列 users.password_changed_at")
            except pymysql.err.OperationalError as e:
                db.rollback()
                if e.args and e.args[0] == 1060:
                    logger.debug("users.password_changed_at 已存在，跳过 ALTER")
                else:
                    logger.exception("ensure_schema: ALTER TABLE 失败")
                    raise
    except Exception as e:
        logger.exception("ensure_schema: 未预期的错误: %s", e)
        raise
