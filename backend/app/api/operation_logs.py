"""
操作日志 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required
import datetime

logs_bp = Blueprint('operation_logs', __name__, url_prefix='/api/operation-logs')


@logs_bp.route('', methods=['GET'])
@jwt_required
def get_logs():
    """
    获取操作日志列表（分页）
    支持查询参数: module, action, username, start_date, end_date
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 分页参数
        page = int(request.args.get('page', 1))
        page_size = int(request.args.get('page_size', 20))
        offset = (page - 1) * page_size
        
        # 筛选参数
        module = request.args.get('module', '').strip()
        action = request.args.get('action', '').strip()
        username = request.args.get('username', '').strip()
        start_date = request.args.get('start_date', '').strip()
        end_date = request.args.get('end_date', '').strip()
        
        # 构建查询条件
        where_clause = "WHERE 1=1"
        params = []
        
        if module:
            where_clause += " AND module = %s"
            params.append(module)
        if action:
            where_clause += " AND action = %s"
            params.append(action)
        if username:
            where_clause += " AND username LIKE %s"
            params.append(f'%{username}%')
        if start_date:
            where_clause += " AND DATE(created_at) >= %s"
            params.append(start_date)
        if end_date:
            where_clause += " AND DATE(created_at) <= %s"
            params.append(end_date)
        
        # 查询总数
        count_sql = f"SELECT COUNT(*) as total FROM operation_logs {where_clause}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']
        
        # 查询数据
        data_sql = f"""
            SELECT * FROM operation_logs 
            {where_clause}
            ORDER BY created_at DESC
            LIMIT %s OFFSET %s
        """
        params.extend([page_size, offset])
        cursor.execute(data_sql, params)
        logs = cursor.fetchall()
        
        # 处理日期时间字段
        for log in logs:
            if log.get('created_at') and isinstance(log['created_at'], datetime.datetime):
                log['created_at'] = log['created_at'].strftime('%Y-%m-%d %H:%M:%S')
        
        return jsonify({
            'code': 200,
            'data': {
                'items': logs,
                'total': total,
                'page': page,
                'page_size': page_size
            }
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'获取操作日志失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@logs_bp.route('/modules', methods=['GET'])
@jwt_required
def get_modules():
    """获取所有操作模块列表"""
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT DISTINCT module FROM operation_logs ORDER BY module")
        modules = [row['module'] for row in cursor.fetchall()]
        return jsonify({
            'code': 200,
            'data': modules
        })
    finally:
        cursor.close()
        db.close()


@logs_bp.route('/actions', methods=['GET'])
@jwt_required
def get_actions():
    """获取所有操作类型列表"""
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT DISTINCT action FROM operation_logs ORDER BY action")
        actions = [row['action'] for row in cursor.fetchall()]
        return jsonify({
            'code': 200,
            'data': actions
        })
    finally:
        cursor.close()
        db.close()
