"""
阿里云账户管理 API
所有接口需要管理员权限
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required
from ..utils.operation_log import log_operation
from ..utils.password_utils import encrypt_data, decrypt_data

aliyun_accounts_bp = Blueprint('aliyun_accounts', __name__, url_prefix='/api/aliyun-accounts')


def is_masked_value(value):
    """判断值是否为脱敏值（包含*号）"""
    return value and '*' in value


@aliyun_accounts_bp.route('', methods=['GET'])
@jwt_required
@role_required(['admin'])
def get_accounts():
    """
    获取阿里云账户列表
    access_key_secret 字段会解密返回
    
    返回：{"code": 200, "data": [账户列表]}
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("""
            SELECT id, account_name, access_key_id, access_key_secret, 
                   is_active, description, created_at, updated_at 
            FROM aliyun_accounts 
            ORDER BY id DESC
        """)
        accounts = cursor.fetchall()
        
        # 解密 access_key_secret 字段
        for account in accounts:
            if account.get('access_key_secret'):
                try:
                    account['access_key_secret'] = decrypt_data(account['access_key_secret'])
                except:
                    pass  # 解密失败保持原值
        
        return jsonify({
            'code': 200,
            'data': accounts
        }), 200
    finally:
        cursor.close()

@aliyun_accounts_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin'])
def create_account():
    """
    创建阿里云账户
    
    请求体: {"account_name": "xxx", "access_key_id": "xxx", "access_key_secret": "xxx", "description": "xxx"}
    返回: {"code": 200, "message": "账户创建成功"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    account_name = data.get('account_name')
    access_key_id = data.get('access_key_id')
    access_key_secret = data.get('access_key_secret')
    description = data.get('description', '')
    
    # 验证必填字段
    if not account_name or not access_key_id or not access_key_secret:
        return jsonify({
            'code': 400,
            'message': '账户名称、AccessKey ID 和 AccessKey Secret 不能为空'
        }), 400
    
    db = get_db()
    cursor = db.cursor()
    try:
        # 检查账户名称是否已存在
        cursor.execute("SELECT id FROM aliyun_accounts WHERE account_name = %s", (account_name,))
        if cursor.fetchone():
            return jsonify({
                'code': 409,
                'message': '账户名称已存在'
            }), 409
        
        # 加密 AccessKey Secret
        try:
            access_key_secret_encrypted = encrypt_data(access_key_secret)
        except Exception as e:
            return jsonify({
                'code': 500,
                'message': f'AccessKey Secret 加密失败：{str(e)}'
            }), 500
        
        # 创建账户
        cursor.execute("""
            INSERT INTO aliyun_accounts (account_name, access_key_id, access_key_secret, description)
            VALUES (%s, %s, %s, %s)
        """, (account_name, access_key_id, access_key_secret_encrypted, description))
        
        db.commit()
        account_id = cursor.lastrowid
        
        # 记录操作日志
        log_operation('阿里云账户', 'create', account_id, account_name, {'description': description})
        
        return jsonify({
            'code': 200,
            'message': '账户创建成功',
            'data': {'id': account_id}
        }), 200
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'账户创建失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@aliyun_accounts_bp.route('/<int:account_id>', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_account(account_id):
    """
    更新阿里云账户
    如果 access_key_secret 传的是脱敏值（包含*）则不更新该字段
    
    请求体: {"account_name": "xxx", "access_key_id": "xxx", "access_key_secret": "xxx", "is_active": 1, "description": "xxx"}
    返回: {"code": 200, "message": "账户更新成功"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    db = get_db()
    cursor = db.cursor()
    try:
        # 检查账户是否存在
        cursor.execute("SELECT id FROM aliyun_accounts WHERE id = %s", (account_id,))
        if not cursor.fetchone():
            return jsonify({
                'code': 404,
                'message': '账户不存在'
            }), 404
        
        # 检查账户名称是否与其他账户冲突
        if 'account_name' in data:
            cursor.execute(
                "SELECT id FROM aliyun_accounts WHERE account_name = %s AND id != %s",
                (data['account_name'], account_id)
            )
            if cursor.fetchone():
                return jsonify({
                    'code': 409,
                    'message': '账户名称已存在'
                }), 409
        
        # 构建更新数据
        update_fields = []
        update_values = []
        
        if 'account_name' in data:
            update_fields.append("account_name = %s")
            update_values.append(data['account_name'])
        
        if 'access_key_id' in data:
            update_fields.append("access_key_id = %s")
            update_values.append(data['access_key_id'])
        
    # 如果 access_key_secret 存在则加密
        if 'access_key_secret' in data and not is_masked_value(data['access_key_secret']):
            try:
                update_fields.append("access_key_secret = %s")
                update_values.append(encrypt_data(data['access_key_secret']))
            except Exception as e:
                db.rollback()
                return jsonify({
                    'code': 500,
                    'message': f'AccessKey Secret 加密失败：{str(e)}'
                }), 500
        
        if 'is_active' in data:
            update_fields.append("is_active = %s")
            update_values.append(data['is_active'])
        
        if 'description' in data:
            update_fields.append("description = %s")
            update_values.append(data['description'])
        
        if not update_fields:
            return jsonify({
                'code': 400,
                'message': '没有要更新的字段'
            }), 400
        
        # 执行更新
        update_values.append(account_id)
        sql = f"UPDATE aliyun_accounts SET {', '.join(update_fields)} WHERE id = %s"
        cursor.execute(sql, update_values)
        db.commit()
        
        # 记录操作日志
        log_operation('阿里云账户', 'update', account_id, data.get('account_name'))
        
        return jsonify({
            'code': 200,
            'message': '账户更新成功'
        }), 200
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'账户更新失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@aliyun_accounts_bp.route('/<int:account_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin'])
def delete_account(account_id):
    """
    删除阿里云账户
    
    返回: {"code": 200, "message": "账户删除成功"}
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取账户名
        cursor.execute("SELECT account_name FROM aliyun_accounts WHERE id = %s", (account_id,))
        account = cursor.fetchone()
        if not account:
            return jsonify({
                'code': 404,
                'message': '账户不存在'
            }), 404
        
        account_name = account['account_name']
        
        # 删除账户
        cursor.execute("DELETE FROM aliyun_accounts WHERE id = %s", (account_id,))
        db.commit()
        
        # 记录操作日志
        log_operation('阿里云账户', 'delete', account_id, account_name)
        
        return jsonify({
            'code': 200,
            'message': '账户删除成功'
        }), 200
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'账户删除失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
