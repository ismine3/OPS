"""
仪表盘统计 API
"""
from flask import Blueprint, jsonify
from datetime import datetime
from ..utils.db import get_db
from ..utils.decorators import jwt_required

dashboard_bp = Blueprint('dashboard', __name__, url_prefix='/api/dashboard')


def serialize_datetime(record):
    """将记录中的所有datetime对象转换为字符串"""
    if not record:
        return record
    for key, value in record.items():
        if isinstance(value, datetime):
            record[key] = value.strftime('%Y-%m-%d %H:%M:%S')
    return record


@dashboard_bp.route('/stats', methods=['GET'])
@jwt_required
def get_stats():
    """
    获取仪表盘统计数据
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 各表数量统计
        cursor.execute("SELECT COUNT(*) as cnt FROM servers")
        server_count = cursor.fetchone()['cnt']

        cursor.execute("SELECT COUNT(*) as cnt FROM services")
        service_count = cursor.fetchone()['cnt']

        cursor.execute("SELECT COUNT(*) as cnt FROM app_systems")
        app_count = cursor.fetchone()['cnt']

        cursor.execute("SELECT COUNT(*) as cnt FROM domains")
        domains_count = cursor.fetchone()['cnt']

        cursor.execute("SELECT COUNT(*) as cnt FROM ssl_certificates")
        certs_count = cursor.fetchone()['cnt']

        # 即将过期证书数量（30天内）
        cursor.execute(
            "SELECT COUNT(*) as cnt FROM ssl_certificates "
            "WHERE cert_expire_time IS NOT NULL "
            "AND DATEDIFF(cert_expire_time, NOW()) <= 30 "
            "AND DATEDIFF(cert_expire_time, NOW()) > 0"
        )
        expiring_certs_count = cursor.fetchone()['cnt']

        # 按环境类型统计服务器
        cursor.execute("SELECT env_type, COUNT(*) as cnt FROM servers GROUP BY env_type")
        env_stats = cursor.fetchall()
        env_distribution = [{'env_type': r['env_type'], 'count': r['cnt']} for r in env_stats]

        # SSL证书到期提醒（按到期日期升序，动态计算剩余天数）
        cursor.execute(
            "SELECT *, DATEDIFF(cert_expire_time, NOW()) as calc_remaining_days "
            "FROM ssl_certificates WHERE cert_expire_time IS NOT NULL "
            "ORDER BY cert_expire_time ASC LIMIT 10"
        )
        recent_certs = cursor.fetchall()
        for cert in recent_certs:
            if cert.get('calc_remaining_days') is not None:
                cert['remaining_days'] = cert.pop('calc_remaining_days')
            cert = serialize_datetime(cert)

        return jsonify({
            'code': 200,
            'data': {
                'counts': {
                    'servers': server_count,
                    'services': service_count,
                    'apps': app_count,
                    'domains': domains_count,
                    'certs': certs_count,
                    'expiring_certs': expiring_certs_count
                },
                'env_distribution': env_distribution,
                'recent_certs': recent_certs
            }
        })
    finally:
        cursor.close()
        db.close()
