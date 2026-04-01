"""
域名证书管理 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required

certs_bp = Blueprint('certs', __name__, url_prefix='/api/certs')


@certs_bp.route('', methods=['GET'])
@jwt_required
def get_certs():
    """
    获取域名证书列表
    支持查询参数: category, search
    """
    db = get_db()
    cursor = db.cursor()
    try:
        search = request.args.get('search', '')
        category = request.args.get('category', '')

        sql = "SELECT * FROM domains_certs WHERE 1=1"
        params = []
        if search:
            sql += " AND (project LIKE %s OR entity LIKE %s)"
            params.extend([f'%{search}%'] * 2)
        if category:
            sql += " AND category = %s"
            params.append(category)
        sql += " ORDER BY category, id"

        cursor.execute(sql, params)
        certs = cursor.fetchall()

        return jsonify({
            'code': 200,
            'data': certs
        })
    finally:
        cursor.close()
        db.close()


@certs_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def create_cert():
    """
    创建域名证书记录
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        cursor.execute(
            "INSERT INTO domains_certs (seq_no, category, project, entity, purchase_date, "
            "expire_date, cost, remaining_days, brand, status, remark) "
            "VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)",
            (data.get('seq_no'), data.get('category'), data.get('project'),
             data.get('entity'), data.get('purchase_date'), data.get('expire_date'),
             data.get('cost'), data.get('remaining_days'), data.get('brand'),
             data.get('status'), data.get('remark'))
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


@certs_bp.route('/<int:cert_id>', methods=['PUT'])
@jwt_required
@role_required(['admin', 'operator'])
def update_cert(cert_id):
    """
    更新域名证书记录
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        fields = []
        values = []
        for key in ['seq_no', 'category', 'project', 'entity', 'purchase_date',
                     'expire_date', 'cost', 'remaining_days', 'brand', 'status', 'remark']:
            if key in data:
                fields.append(f"`{key}` = %s")
                values.append(data[key])
        if fields:
            values.append(cert_id)
            cursor.execute(f"UPDATE domains_certs SET {', '.join(fields)} WHERE id = %s", values)
            db.commit()
        return jsonify({
            'code': 200,
            'message': '更新成功'
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'更新失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/<int:cert_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_cert(cert_id):
    """
    删除域名证书记录
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM domains_certs WHERE id = %s", (cert_id,))
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
