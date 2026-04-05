import os


def _split_origins(raw):
    if not raw:
        return []
    return [x.strip() for x in raw.split(",") if x.strip()]


class Config:
    # 生产环境必须通过环境变量设置，勿使用代码中的默认值
    SECRET_KEY = os.environ.get("SECRET_KEY", "")
    JWT_SECRET_KEY = os.environ.get("JWT_SECRET_KEY", "")
    JWT_EXPIRATION_HOURS = int(os.environ.get("JWT_EXPIRATION_HOURS", "2"))

    DB_HOST = os.environ.get("DB_HOST", "127.0.0.1")
    DB_PORT = int(os.environ.get("DB_PORT", "3306"))
    DB_USER = os.environ.get("DB_USER", "root")
    DB_PASSWORD = os.environ.get("DB_PASSWORD", "")
    DB_NAME = os.environ.get("DB_NAME", "ops_platform")

    DEBUG = os.environ.get("FLASK_DEBUG", "false").lower() in ("true", "1", "yes")
    HOST = os.environ.get("FLASK_HOST", "0.0.0.0")
    PORT = int(os.environ.get("FLASK_PORT", "5000"))

    UPLOAD_FOLDER = os.path.join(os.path.dirname(os.path.abspath(__file__)), "uploads")
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

    WECHAT_WEBHOOK_URL = os.environ.get("WECHAT_WEBHOOK_URL", "")

    SSL_CHECK_TIMEOUT = int(os.environ.get("SSL_CHECK_TIMEOUT", "10"))
    SSL_WARNING_DAYS = int(os.environ.get("SSL_WARNING_DAYS", "30"))

    DOMAIN_WARNING_DAYS = int(os.environ.get("DOMAIN_WARNING_DAYS", "30"))

    CERT_AUTO_CHECK_CRON = os.environ.get("CERT_AUTO_CHECK_CRON", "0 8 * * *")
    DOMAIN_AUTO_NOTIFY_CRON = os.environ.get("DOMAIN_AUTO_NOTIFY_CRON", "0 8 * * *")

    CERT_FILES_DIR = os.path.join(UPLOAD_FOLDER, "certs")

    GRAFANA_URL = os.environ.get("GRAFANA_URL", "")
    GRAFANA_DASHBOARDS = os.environ.get("GRAFANA_DASHBOARDS", '[{"name":"主机监控","uid":"node-exporter"},{"name":"容器监控","uid":"cadvisor"}]')

    @staticmethod
    def get_cors_origins_list():
        return _split_origins(Config.CORS_ORIGINS)
