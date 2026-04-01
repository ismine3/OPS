"""
更新记录管理 API
"""
from flask import Blueprint, request, jsonify
from datetime import datetime
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required

records_bp = Blueprint('records', __name__, url_prefix='/api/records')


def serialize_record(record):
    """将记录中的datetime对象转换为字符串"""
    if record and 'change_date' in record and record['change_date']:
        if isinstance(record['change_date'], datetime):
            record['change_date'] = record['change_date'].strftime('%Y-%m-%d')
    return record


@records_bp.route('', methods=['GET'])
@jwt_required
def get_records():
    """
    获取更新记录列表
    支持查询参数: search
    按 change_date DESC 排序
    """
    db = get_db()
    cursor = db.cursor()
    try:
        search = request.args.get('search', '')

        sql = "SELECT * FROM change_records WHERE seq_no IS NOT NULL"
        params = []
        if search:
            sql += " AND (modifier LIKE %s OR location LIKE %s OR content LIKE %s)"
            params.extend([f'%{search}%'] * 3)
        sql += " ORDER BY change_date DESC, seq_no DESC"

        cursor.execute(sql, params)
        records = cursor.fetchall()
        
        # 转换datetime对象为字符串
        records = [serialize_record(r) for r in records]

        return jsonify({
            'code': 200,
            'data': records
        })
    finally:
        cursor.close()
        db.close()


@records_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def create_record():
    """
    创建更新记录
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        cursor.execute(
            "INSERT INTO change_records (seq_no, change_date, modifier, location, content, remark) "
            "VALUES (%s,%s,%s,%s,%s,%s)",
            (data.get('seq_no'), data.get('change_date'), data.get('modifier'),
             data.get('location'), data.get('content'), data.get('remark'))
        )
        db.commit()
        return jsonify({
            'code': 200,
            'message': '创建成功',
            'data': {'id': cursor.lastrowid}
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'创建失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@records_bp.route('/<int:record_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_record(record_id):
    """
    删除更新记录
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM change_records WHERE id = %s", (record_id,))
        db.commit()
        return jsonify({
            'code': 200,
            'message': '删除成功'
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'删除失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()
