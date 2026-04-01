import pymysql
from flask import current_app


def get_db():
    """获取数据库连接"""
    config = current_app.config
    return pymysql.connect(
        host=config.get('DB_HOST', '192.168.1.124'),
        port=config.get('DB_PORT', 3306),
        user=config.get('DB_USER', 'root'),
        password=config.get('DB_PASSWORD', ''),
        database=config.get('DB_NAME', 'ops_platform'),
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor
    )
