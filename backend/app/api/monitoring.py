"""
监控配置 API
"""
import json
from flask import Blueprint, jsonify, current_app
from ..utils.decorators import jwt_required

monitoring_bp = Blueprint('monitoring', __name__, url_prefix='/api/monitoring')


@monitoring_bp.route('/config', methods=['GET'])
@jwt_required
def get_config():
    """
    获取 Grafana 监控配置
    """
    grafana_url = current_app.config.get('GRAFANA_URL', '')
    dashboards_raw = current_app.config.get('GRAFANA_DASHBOARDS', '[]')

    if not grafana_url:
        return jsonify({
            'code': 200,
            'message': 'Grafana 未配置',
            'data': {
                'grafana_url': '',
                'dashboards': []
            }
        })

    try:
        dashboards = json.loads(dashboards_raw)
    except json.JSONDecodeError:
        dashboards = []

    return jsonify({
        'code': 200,
        'data': {
            'grafana_url': grafana_url,
            'dashboards': dashboards
        }
    })
