"""
应用系统管理 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required
from ..utils.operation_log import log_operation
from ..utils.validators import validate_url, validate_string_length
from ..utils.password_utils import encrypt_data, decrypt_data

apps_bp = Blueprint('apps', __name__, url_prefix='/api/apps')


@apps_bp.route('/<int:app_id>', methods=['GET'])
@jwt_required
def get_app_detail(app_id):
    """
    获取应用系统详情
    密码字段会被解密返回
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT * FROM app_systems WHERE id = %s", (app_id,))
        app = cursor.fetchone()
        
        if not app:
            return jsonify({
                'code': 404,
                'message': '应用系统不存在'
            }), 404
        
        # 解密密码字段
        if app.get('password'):
            try:
                app['password'] = decrypt_data(app['password'])
            except:
                pass  # 解密失败保持原值
            
        return jsonify({
            'code': 200,
            'data': app
        })
    finally:
        cursor.close()

@apps_bp.route('', methods=['GET'])
@jwt_required
def get_apps():
    """
    获取应用系统列表
    支持查询参数: search（搜索 name、company、access_url）, page, page_size
    """
    db = get_db()
    cursor = db.cursor()
    try:
        search = request.args.get('search', '')
        page = request.args.get('page', '1')
        page_size = request.args.get('page_size', '10')

        # 分页参数处理
        try:
            page = int(page)
            page_size = int(page_size)
            if page < 1:
                page = 1
            if page_size < 1:
                page_size = 10
            if page_size > 100:
                page_size = 100
        except ValueError:
            page = 1
            page_size = 10

        # 构建基础查询条件
        where_clause = "WHERE 1=1"
        params = []
        if search:
            where_clause += " AND (name LIKE %s OR company LIKE %s OR access_url LIKE %s)"
            params.extend([f'%{search}%'] * 3)

        # 查询总数
        count_sql = f"SELECT COUNT(*) as total FROM app_systems {where_clause}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']

        # 查询数据
        sql = f"SELECT * FROM app_systems {where_clause} ORDER BY id LIMIT %s OFFSET %s"
        offset = (page - 1) * page_size
        cursor.execute(sql, params + [page_size, offset])
        apps = cursor.fetchall()
        
        # 解密密码字段
        for app in apps:
            if app.get('password'):
                try:
                    app['password'] = decrypt_data(app['password'])
                except:
                    pass  # 解密失败保持原值

        return jsonify({
            'code': 200,
            'data': {
                'items': apps,
                'total': total,
                'page': page,
                'page_size': page_size
            }
        })
    finally:
        cursor.close()

@apps_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def create_app():
    """
    创建应用系统
    字段：seq_no, name, company, access_url, username, password, remark
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        
        # 输入验证
        name = data.get('name')
        company = data.get('company')
        access_url = data.get('access_url')
        username = data.get('username')
        password = data.get('password')
        remark = data.get('remark')
        
        # 验证必填字段
        if not name:
            return jsonify({
                'code': 400,
                'message': '应用系统名称不能为空'
            }), 400
        
        # 验证字符串长度
        if not validate_string_length(name, min_len=1, max_len=200):
            return jsonify({
                'code': 400,
                'message': '应用系统名称长度必须在1-200个字符之间'
            }), 400
        
        if company and not validate_string_length(company, max_len=200):
            return jsonify({
                'code': 400,
                'message': '公司名称长度不能超过200个字符'
            }), 400
        
        # 验证URL格式
        if access_url and not validate_url(access_url):
            return jsonify({
                'code': 400,
                'message': '访问URL格式不正确'
            }), 400
        
        if username and not validate_string_length(username, max_len=100):
            return jsonify({
                'code': 400,
                'message': '用户名长度不能超过100个字符'
            }), 400
        
        if password and not validate_string_length(password, max_len=255):
            return jsonify({
                'code': 400,
                'message': '密码长度不能超过255个字符'
            }), 400
        
        if remark and not validate_string_length(remark, max_len=500):
            return jsonify({
                'code': 400,
                'message': '备注长度不能超过500个字符'
            }), 400
        
        # 加密密码
        password_encrypted = encrypt_data(password) if password else None
        
        cursor.execute(
            "INSERT INTO app_systems (seq_no, name, company, access_url, username, password, remark) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (data.get('seq_no'), name, company,
             access_url, username, password_encrypted,
             remark)
        )
        db.commit()
        app_id = cursor.lastrowid
        
        # 记录操作日志
        log_operation('应用系统', 'create', app_id, data.get('name'),
                     {'company': data.get('company'), 'access_url': data.get('access_url')})
        
        return jsonify({
            'code': 200,
            'message': '创建成功',
            'data': {'id': app_id}
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'创建失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@apps_bp.route('/<int:app_id>', methods=['PUT'])
@jwt_required
@role_required(['admin', 'operator'])
def update_app(app_id):
    """
    更新应用系统
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取更新前的应用名
        cursor.execute("SELECT name FROM app_systems WHERE id = %s", (app_id,))
        old_app = cursor.fetchone()
        app_name = old_app['name'] if old_app else None
        
        data = request.json
        fields = []
        values = []
        # 允许的字段白名单，防止SQL注入
        allowed_fields = ['seq_no', 'name', 'company', 'access_url', 'username', 'password', 'remark']
        
        # 输入验证
        if 'name' in data:
            name = data['name']
            if not name:
                return jsonify({
                    'code': 400,
                    'message': '应用系统名称不能为空'
                }), 400
            if not validate_string_length(name, min_len=1, max_len=200):
                return jsonify({
                    'code': 400,
                    'message': '应用系统名称长度必须在1-200个字符之间'
                }), 400
        
        if 'company' in data and data['company'] and not validate_string_length(data['company'], max_len=200):
            return jsonify({
                'code': 400,
                'message': '公司名称长度不能超过200个字符'
            }), 400
        
        if 'access_url' in data and data['access_url'] and not validate_url(data['access_url']):
            return jsonify({
                'code': 400,
                'message': '访问URL格式不正确'
            }), 400
        
        if 'username' in data and data['username'] and not validate_string_length(data['username'], max_len=100):
            return jsonify({
                'code': 400,
                'message': '用户名长度不能超过100个字符'
            }), 400
        
        if 'password' in data and data['password'] and not validate_string_length(data['password'], max_len=255):
            return jsonify({
                'code': 400,
                'message': '密码长度不能超过255个字符'
            }), 400
        
        if 'remark' in data and data['remark'] and not validate_string_length(data['remark'], max_len=500):
            return jsonify({
                'code': 400,
                'message': '备注长度不能超过500个字符'
            }), 400
        
        # 处理密码字段加密
        if 'password' in data and data['password']:
            data['password'] = encrypt_data(data['password'])
        
        for key in data:
            if key in allowed_fields:
                fields.append(f"`{key}` = %s")
                values.append(data[key])
        if fields:
            values.append(app_id)
            cursor.execute(f"UPDATE app_systems SET {', '.join(fields)} WHERE id = %s", values)
            db.commit()
            
            # 记录操作日志
            log_operation('应用系统', 'update', app_id, data.get('name') or app_name)
            
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

@apps_bp.route('/<int:app_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_app(app_id):
    """
    删除应用系统
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取应用名
        cursor.execute("SELECT name FROM app_systems WHERE id = %s", (app_id,))
        old_app = cursor.fetchone()
        app_name = old_app['name'] if old_app else None
        
        cursor.execute("DELETE FROM app_systems WHERE id = %s", (app_id,))
        db.commit()
        
        # 记录操作日志
        log_operation('应用系统', 'delete', app_id, app_name)
        
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
