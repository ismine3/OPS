from flask import Flask, jsonify
from flask_cors import CORS
from .config import Config


def create_app():
    app = Flask(__name__)
    app.config.from_object(Config)
    
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
    
    # CORS配置
    CORS(app, resources={r"/api/*": {"origins": "*"}}, supports_credentials=True)
    
    # 注册蓝图（后续任务会添加更多蓝图）
    register_blueprints(app)
    
    # 初始化定时任务调度器
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
    from .api.records import records_bp
    from .api.dashboard import dashboard_bp
    from .api.dicts import dicts_bp
    from .api.aliyun_accounts import aliyun_accounts_bp
    from .api.domains import domains_bp
    
    app.register_blueprint(auth_bp)
    app.register_blueprint(users_bp)
    app.register_blueprint(export_bp)
    app.register_blueprint(tasks_bp)
    app.register_blueprint(servers_bp)
    app.register_blueprint(services_bp)
    app.register_blueprint(apps_bp)
    app.register_blueprint(certs_bp)
    app.register_blueprint(records_bp)
    app.register_blueprint(dashboard_bp)
    app.register_blueprint(dicts_bp)
    app.register_blueprint(aliyun_accounts_bp)
    app.register_blueprint(domains_bp)
