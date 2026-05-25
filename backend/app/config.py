import os


def _split_origins(raw):
    if not raw:
        return []
    return [x.strip() for x in raw.split(",") if x.strip()]


class Config:
    # 生产环境必须通过环境变量设置，勿使用代码中的默认值
    # Flask 通用密钥，用于 session 签名等
    SECRET_KEY = os.environ.get("SECRET_KEY", "")
    # JWT 签名密钥
    JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY", "")
    # JWT Token 过期时间（小时）
    JWT_EXPIRATION_HOURS = int(os.environ.get("JWT_EXPIRATION_HOURS", "2"))

    # MySQL 数据库主机地址
    DB_HOST = os.environ.get("DB_HOST", "127.0.0.1")
    # MySQL 数据库端口
    DB_PORT = int(os.environ.get("DB_PORT", "3306"))
    # MySQL 数据库用户名
    DB_USER = os.environ.get("DB_USER", "root")
    # MySQL 数据库密码
    DB_PASSWORD = os.environ.get("DB_PASSWORD", "")
    # MySQL 数据库名称
    DB_NAME = os.environ.get("DB_NAME", "ops_platform")

    # 是否开启调试模式
    DEBUG = os.environ.get("FLASK_DEBUG", "false").lower() in ("true", "1", "yes")
    # Flask 监听地址
    HOST = os.environ.get("FLASK_HOST", "0.0.0.0")
    # Flask 监听端口
    PORT = int(os.environ.get("FLASK_PORT", "5000"))

    # 上传文件存储目录
    UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "uploads")
    # 上传文件大小上限（字节），默认 16MB
    MAX_CONTENT_LENGTH = 16 * 1024 * 1024

    # JSON 响应中保留中文字符，不进行 Unicode 转义
    JSON_AS_ASCII = False

    # 逗号分隔；与 supports_credentials 同时使用时不可为 *
    CORS_ORIGINS = os.environ.get(
        "CORS_ORIGINS",
        "http://localhost:3000,http://127.0.0.1:3000",
    )
    # 设为 true 时允许任意源（不携带 credentials 的浏览器行为）
    CORS_ALLOW_ALL = os.environ.get("CORS_ALLOW_ALL", "").lower() in ("true", "1", "yes")

    # 企业微信机器人 Webhook 地址，用于发送告警通知
    WECHAT_WEBHOOK_URL = os.environ.get("WECHAT_WEBHOOK_URL", "")

    # SSL 证书在线检测超时时间（秒）
    SSL_CHECK_TIMEOUT = int(os.environ.get("SSL_CHECK_TIMEOUT", "10"))
    # SSL 证书到期预警天数，距到期 ≤ 该天数时触发告警
    SSL_WARNING_DAYS = int(os.environ.get("SSL_WARNING_DAYS", "30"))

    # 域名到期预警天数，距到期 ≤ 该天数时触发告警
    DOMAIN_WARNING_DAYS = int(os.environ.get("DOMAIN_WARNING_DAYS", "30"))

    # SSL 证书自动检查定时任务 Cron 表达式（默认每天 8:00）
    CERT_AUTO_CHECK_CRON = os.environ.get("CERT_AUTO_CHECK_CRON", "0 8 * * *")
    # 域名到期自动通知定时任务 Cron 表达式（默认每天 8:00）
    DOMAIN_AUTO_NOTIFY_CRON = os.environ.get("DOMAIN_AUTO_NOTIFY_CRON", "0 8 * * *")
    # 密码轮换检查定时任务 Cron 表达式（默认每天 3:00）
    PASSWORD_ROTATION_CHECK_CRON = os.environ.get("PASSWORD_ROTATION_CHECK_CRON", "0 3 * * *")
    # 自动生成的轮换密码长度
    PASSWORD_ROTATION_LENGTH = int(os.environ.get("PASSWORD_ROTATION_LENGTH", "16"))

    # SSL 证书文件存储目录
    CERT_FILES_DIR = os.path.join(UPLOAD_FOLDER, "certs")

    # Grafana 监控面板地址
    GRAFANA_URL = os.environ.get("GRAFANA_URL", "")
    # Grafana 仪表盘配置（JSON 数组），每项包含 name 和 uid
    GRAFANA_DASHBOARDS = os.environ.get("GRAFANA_DASHBOARDS", '[{"name":"主机监控","uid":"node-exporter"},{"name":"容器监控","uid":"cadvisor"}]')

    @staticmethod
    def get_cors_origins_list():
        return _split_origins(Config.CORS_ORIGINS)
