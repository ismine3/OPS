"""
仪表盘统计 API
"""
from flask import Blueprint, jsonify
from datetime import datetime
from ..utils.db import get_db
from ..utils.decorators import jwt_required

dashboard_bp = Blueprint('dashboard', __name__, url_prefix='/api/dashboard')


def serialize_record(record):
    """将记录中的datetime对象转换为字符串"""
    if record and 'change_date' in record and record['change_date']:
        if isinstance(record['change_date'], datetime):
            record['change_date'] = record['change_date'].strftime('%Y-%m-%d')
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

        cursor.execute("SELECT COUNT(*) as cnt FROM domains_certs")
        cert_count = cursor.fetchone()['cnt']

        cursor.execute("SELECT COUNT(*) as cnt FROM change_records")
        record_count = cursor.fetchone()['cnt']

        # 按环境类型统计服务器
        cursor.execute("SELECT env_type, COUNT(*) as cnt FROM servers GROUP BY env_type")
        env_stats = cursor.fetchall()
        env_distribution = [{'env_type': r['env_type'], 'count': r['cnt']} for r in env_stats]

        # 最近更新记录
        cursor.execute(
            "SELECT * FROM change_records WHERE seq_no IS NOT NULL "
            "ORDER BY change_date DESC LIMIT 10"
        )
        recent_records = cursor.fetchall()
        recent_records = [serialize_record(r) for r in recent_records]

        # 域名证书到期提醒（按到期日期升序，动态计算剩余天数）
        cursor.execute(
            "SELECT *, DATEDIFF(expire_date, CURDATE()) as calc_remaining_days "
            "FROM domains_certs WHERE expire_date IS NOT NULL AND expire_date != '' "
            "ORDER BY expire_date ASC LIMIT 10"
        )
        recent_certs = cursor.fetchall()
        for cert in recent_certs:
            if cert.get('calc_remaining_days') is not None:
                cert['remaining_days'] = cert.pop('calc_remaining_days')
            if cert.get('expire_date') and isinstance(cert['expire_date'], datetime):
                cert['expire_date'] = cert['expire_date'].strftime('%Y-%m-%d')
            if cert.get('purchase_date') and isinstance(cert['purchase_date'], datetime):
                cert['purchase_date'] = cert['purchase_date'].strftime('%Y-%m-%d')

        return jsonify({
            'code': 200,
            'data': {
                'counts': {
                    'servers': server_count,
                    'services': service_count,
                    'apps': app_count,
                    'certs': cert_count,
                    'records': record_count
                },
                'env_distribution': env_distribution,
                'recent_certs': recent_certs,
                'recent_records': recent_records
            }
        })
    finally:
        cursor.close()
        db.close()
