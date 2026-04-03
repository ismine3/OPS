import pymysql
from flask import current_app, g


def get_db():
    """获取数据库连接（使用Flask应用上下文缓存）"""
    if 'db' not in g:
        config = current_app.config
        g.db = pymysql.connect(
            host=config.get('DB_HOST', '192.168.1.124'),
            port=config.get('DB_PORT', 3306),
            user=config.get('DB_USER', 'root'),
            password=config.get('DB_PASSWORD', ''),
            database=config.get('DB_NAME', 'ops_platform'),
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
    return g.db


def close_db(e=None):
    """关闭数据库连接"""
    db = g.pop('db', None)
    if db is not None:
        try:
            db.close()
        except Exception:
            # 连接可能已经被关闭，忽略错误
            pass
