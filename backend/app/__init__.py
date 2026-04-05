import logging
import sys

from flask import Flask, jsonify, request, g
from flask_cors import CORS
from .config import Config
from .utils.db import close_db


def _configure_logging(app):
    """将日志打到 stderr，便于 Docker / Gunicorn 收集；否则 pymysql 等异常可能看不见。"""
    level = logging.DEBUG if app.config.get("DEBUG") else logging.INFO
    root = logging.getLogger()
    if not root.handlers:
        h = logging.StreamHandler(sys.stderr)
        h.setFormatter(
            logging.Formatter(
                "%(asctime)s [%(levelname)s] %(name)s: %(message)s",
                datefmt="%Y-%m-%d %H:%M:%S",
            )
        )
        root.addHandler(h)
    root.setLevel(level)
    logging.getLogger("pymysql").setLevel(logging.WARNING)
    app.logger.setLevel(level)


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    _configure_logging(app)

    # 设置 JSON 响应中保留中文字符，不进行 Unicode 转义
    app.json.ensure_ascii = False

    if not app.config.get("SECRET_KEY"):
        if app.config.get("DEBUG"):
            app.config["SECRET_KEY"] = "dev-only-secret-key-not-for-production"
        else:
            raise RuntimeError("生产环境必须设置环境变量 SECRET_KEY")
    if not app.config.get("JWT_SECRET_KEY"):
        if app.config.get("DEBUG"):
            app.config["JWT_SECRET_KEY"] = app.config["SECRET_KEY"]
        else:
            raise RuntimeError("生产环境必须设置环境变量 JWT_SECRET_KEY")

    # 设置请求体大小限制 (16MB)
    app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024
    
    # 根路由 - 返回 API 服务状态
    @app.route('/')
    def index():
        return jsonify({
            "code": 200,
            "message": "运维管理平台 API 服务运行中",
            "version": "2.0"
        })
    
    # 将Config的类属性加载到app.config
    for key in dir(Config):
        if key.isupper():
            app.config[key] = getattr(Config, key)
    
    # CORS：默认显式源列表 + credentials；CORS_ALLOW_ALL=true 时任意源（不启用 credentials）
    if app.config.get("CORS_ALLOW_ALL"):
        CORS(app, resources={r"/api/*": {"origins": "*"}})
    else:
        origins = Config.get_cors_origins_list()
        if not origins:
            origins = ["http://127.0.0.1:3000"]
        CORS(
            app,
            resources={
                r"/api/*": {
                    "origins": origins,
                    "supports_credentials": True,
                    "allow_headers": ["Content-Type", "Authorization"],
                }
            },
        )
    
    # 注册蓝图（后续任务会添加更多蓝图）
    register_blueprints(app)

    # 注册数据库连接关闭钩子
    app.teardown_appcontext(close_db)

    # 先校验数据库：连接失败时打印完整异常栈（含 host/port/user/database），再跑迁移与调度器
    with app.app_context():
        from .utils.db import get_db, log_database_target
        from .utils.schema import ensure_schema

        log_database_target(app.config)
        try:
            db = get_db()
            with db.cursor() as cur:
                cur.execute("SELECT 1")
            app.logger.info("数据库连接预检成功 (SELECT 1)")
        except Exception:
            app.logger.exception(
                "数据库连接预检失败：请核对环境变量 DB_HOST、DB_PORT、DB_USER、DB_PASSWORD、DB_NAME "
                "及 MySQL 是否已启动、网络是否互通（Docker 内 DB_HOST 一般为服务名 mysql）"
            )
            raise

        ensure_schema()

    # 初始化定时任务调度器（独立连接；失败仅记录日志，不阻止应用启动）
    from .utils.scheduler import init_scheduler

    init_scheduler(app)

    return app


def register_blueprints(app):
    """注册所有API蓝图"""
    from .api.auth import auth_bp
    from .api.users import users_bp
    from .api.export import export_bp
    from .api.tasks import tasks_bp
    from .api.servers import servers_bp
    from .api.services import services_bp
    from .api.apps import apps_bp
    from .api.certs import certs_bp
    from .api.dashboard import dashboard_bp
    from .api.dicts import dicts_bp
    from .api.aliyun_accounts import credentials_bp
    from .api.domains import domains_bp
    from .api.operation_logs import logs_bp
    from .api.monitoring import monitoring_bp
    from .api.projects import projects_bp

    app.register_blueprint(auth_bp)
    app.register_blueprint(users_bp)
    app.register_blueprint(export_bp)
    app.register_blueprint(tasks_bp)
    app.register_blueprint(servers_bp)
    app.register_blueprint(services_bp)
    app.register_blueprint(apps_bp)
    app.register_blueprint(certs_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(dicts_bp)
    app.register_blueprint(credentials_bp)
    app.register_blueprint(domains_bp)
    app.register_blueprint(logs_bp)
    app.register_blueprint(monitoring_bp)
    app.register_blueprint(projects_bp)
