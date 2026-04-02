from flask import Flask, jsonify, request, g
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
    
    # 在每个请求前解析 JWT token，设置用户信息到 g 对象
    @app.before_request
    def load_user_from_token():
        # 跳过登录相关接口
        if request.endpoint and 'auth' in request.endpoint:
            return
        
        auth_header = request.headers.get('Authorization', '')
        if auth_header.startswith('Bearer '):
            token = auth_header[7:]
            from .utils.auth import verify_token
            payload = verify_token(token)
            if payload:
                g.user_id = payload.get('user_id')
                g.username = payload.get('username')
                g.role = payload.get('role')
    
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
    from .api.aliyun_accounts import aliyun_accounts_bp
    from .api.domains import domains_bp
    from .api.operation_logs import logs_bp
    
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
    app.register_blueprint(aliyun_accounts_bp)
    app.register_blueprint(domains_bp)
    app.register_blueprint(logs_bp)
