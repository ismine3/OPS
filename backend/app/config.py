import os


class Config:
    SECRET_KEY = os.environ.get('SECRET_KEY', 'ops-platform-secret-key-change-in-prod')
    JWT_SECRET_KEY = os.environ.get('JWT_SECRET_KEY', 'jwt-secret-key-change-in-prod')
    JWT_EXPIRATION_HOURS = 24
    
    DB_HOST = os.environ.get('DB_HOST', '192.168.1.124')
    DB_PORT = int(os.environ.get('DB_PORT', 3306))
    DB_USER = os.environ.get('DB_USER', 'root')
    DB_PASSWORD = os.environ.get('DB_PASSWORD', 'Pass1234.')
    DB_NAME = os.environ.get('DB_NAME', 'ops_platform')
    
    DEBUG = os.environ.get('FLASK_DEBUG', 'True').lower() in ('true', '1', 'yes')
    HOST = os.environ.get('FLASK_HOST', '0.0.0.0')
    PORT = int(os.environ.get('FLASK_PORT', 5000))
    
    UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'uploads')
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024  # 16MB
    
    # 微信企业号 webhook 配置
    WECHAT_WEBHOOK_URL = os.environ.get('WECHAT_WEBHOOK_URL', '')
    
    # SSL 证书检查配置
    SSL_CHECK_TIMEOUT = int(os.environ.get('SSL_CHECK_TIMEOUT', 10))
    SSL_WARNING_DAYS = int(os.environ.get('SSL_WARNING_DAYS', 30))

    # 域名到期预警天数
    DOMAIN_WARNING_DAYS = int(os.environ.get('DOMAIN_WARNING_DAYS', 30))

    # 定时任务 Cron 配置（分 时 日 月 周）
    CERT_AUTO_CHECK_CRON = os.environ.get('CERT_AUTO_CHECK_CRON', '0 8 * * *')  # 每天8:00
    DOMAIN_AUTO_NOTIFY_CRON = os.environ.get('DOMAIN_AUTO_NOTIFY_CRON', '0 8 * * *')  # 每天8:00

    # 证书文件存储目录
    CERT_FILES_DIR = os.path.join(UPLOAD_FOLDER, 'certs')
