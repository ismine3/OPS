"""
SSL证书管理 API
操作表: ssl_certificates
"""
import datetime
import os
import logging
import zipfile
import io
import shutil
import paramiko
from flask import Blueprint, request, jsonify, current_app, send_file
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required
from ..utils.ssl_checker import get_ssl_cert_info, scan_aliyun_certs, send_wechat_notification
from ..utils.operation_log import log_operation
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from cryptography.x509.oid import NameOID

logger = logging.getLogger(__name__)
certs_bp = Blueprint('certs', __name__, url_prefix='/api/certs')


def _parse_date(date_value):
    """解析日期字符串，支持多种格式"""
    if not date_value:
        return None
    if not isinstance(date_value, str):
        return date_value
    
    # 支持的日期格式列表
    date_formats = [
        '%Y-%m-%d',           # 2026-04-02
        '%Y-%m-%d %H:%M:%S',  # 2026-04-02 00:00:00
        '%Y-%m-%dT%H:%M:%S',  # 2026-04-02T00:00:00
        '%Y-%m-%dT%H:%M:%SZ', # 2026-04-02T00:00:00Z
        '%Y/%m/%d',           # 2026/04/02
    ]
    
    for fmt in date_formats:
        try:
            return datetime.datetime.strptime(date_value, fmt)
        except ValueError:
            continue
    
    raise ValueError(f'日期格式错误: {date_value}，请使用YYYY-MM-DD格式')


def _parse_cert_file(cert_content):
    """
    解析证书文件内容，提取证书信息
    返回: dict 包含 domain, issuer, not_before, not_after, valid_days, remaining_days 等
    """
    try:
        # 解析PEM格式的证书
        cert = x509.load_pem_x509_certificate(cert_content.encode(), default_backend())
        
        # 获取域名/CN
        domain = None
        try:
            # 尝试获取Common Name
            cn_attrs = cert.subject.get_attributes_for_oid(NameOID.COMMON_NAME)
            if cn_attrs:
                domain = cn_attrs[0].value
        except Exception:
            pass
        
        # 获取SAN (Subject Alternative Names)
        san_list = []
        try:
            san_ext = cert.extensions.get_extension_for_oid(x509.oid.ExtensionOID.SUBJECT_ALTERNATIVE_NAME)
            for name in san_ext.value:
                san_list.append(name.value)
            # 如果没有CN，使用第一个SAN作为域名
            if not domain and san_list:
                domain = san_list[0]
        except Exception:
            pass
        
        # 获取颁发机构
        issuer = None
        try:
            issuer_cn_attrs = cert.issuer.get_attributes_for_oid(NameOID.COMMON_NAME)
            if issuer_cn_attrs:
                issuer = issuer_cn_attrs[0].value
            else:
                # 尝试Organization
                issuer_org_attrs = cert.issuer.get_attributes_for_oid(NameOID.ORGANIZATION_NAME)
                if issuer_org_attrs:
                    issuer = issuer_org_attrs[0].value
        except Exception:
            pass
        
        # 获取有效期
        not_before = cert.not_valid_before_utc.replace(tzinfo=None)
        not_after = cert.not_valid_after_utc.replace(tzinfo=None)
        valid_days = (not_after - not_before).days
        remaining_days = (not_after - datetime.datetime.now()).days
        
        return {
            'domain': domain,
            'san_list': san_list,
            'issuer': issuer,
            'not_before': not_before,
            'not_after': not_after,
            'valid_days': valid_days,
            'remaining_days': remaining_days,
            'has_expired': remaining_days < 0
        }
    except Exception as e:
        logger.error(f"解析证书文件失败: {e}")
        return None


def _domain_filename(domain):
    """将域名转为安全的文件名前缀，如 *.example.com -> _wildcard_.example.com"""
    return domain.replace('*', '_wildcard_')


@certs_bp.route('', methods=['GET'])
@jwt_required
def get_certs():
    """
    获取证书列表（分页）
    支持查询参数: search（搜索domain/project_name）、cert_type（筛选证书类型）
    
    参数:
        page: 页码，默认1
        page_size: 每页数量，默认20
        search: 搜索关键词
        cert_type: 证书类型筛选
    
    返回: {"code": 200, "data": {"items": [...], "total": N}}
    """
    db = get_db()
    cursor = db.cursor()
    try:
        search = request.args.get('search', '').strip()
        cert_type = request.args.get('cert_type', '').strip()
        page = int(request.args.get('page', 1))
        page_size = int(request.args.get('page_size', 20))
        offset = (page - 1) * page_size
        
        # 构建基础查询条件
        base_sql = "FROM ssl_certificates WHERE 1=1"
        params = []
        
        if search:
            base_sql += " AND (domain LIKE %s OR project_name LIKE %s)"
            params.extend([f'%{search}%', f'%{search}%'])
        
        if cert_type:
            base_sql += " AND cert_type = %s"
            params.append(cert_type)
        
        # 查询总数
        count_sql = f"SELECT COUNT(*) as total {base_sql}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']
        
        # 查询分页数据
        data_sql = f"""
            SELECT 
                id, domain, project_name, cert_type, issuer, 
                cert_generate_time, cert_valid_days, cert_expire_time,
                DATEDIFF(cert_expire_time, NOW()) as remaining_days,
                brand, cost, status, last_check_time, last_notify_time, 
                notify_status, source, aliyun_account_id, remark,
                has_cert_file, cert_file_path, key_file_path,
                created_at, updated_at
            {base_sql}
            ORDER BY cert_expire_time ASC, id DESC
            LIMIT %s OFFSET %s
        """
        params.extend([page_size, offset])
        cursor.execute(data_sql, params)
        certs = cursor.fetchall()
        
        # 处理日期时间字段，使其可JSON序列化
        for cert in certs:
            for key in ['cert_generate_time', 'cert_expire_time', 'last_check_time', 
                       'last_notify_time', 'created_at', 'updated_at']:
                if cert.get(key) and isinstance(cert[key], datetime.datetime):
                    cert[key] = cert[key].strftime('%Y-%m-%d %H:%M:%S')
        
        return jsonify({
            'code': 200,
            'data': {
                'items': certs,
                'total': total
            }
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'获取证书列表失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def create_cert():
    """
    手动添加证书
    必填：domain, project_name
    可选：cert_type, issuer, cert_expire_time, brand, cost, status, remark
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        
        # 验证必填字段
        domain = data.get('domain', '').strip()
        project_name = data.get('project_name', '').strip()
        
        if not domain:
            return jsonify({'code': 400, 'message': '域名不能为空'}), 400
        if not project_name:
            return jsonify({'code': 400, 'message': '项目名称不能为空'}), 400
        
        # 获取可选字段
        cert_type = data.get('cert_type', 1)  # 默认手动录入
        issuer = data.get('issuer', '')
        cert_expire_time = data.get('cert_expire_time')
        brand = data.get('brand', '')
        cost = data.get('cost')
        status = data.get('status', 1)  # 默认正常
        remark = data.get('remark', '')
        
        # 计算剩余天数
        remaining_days = None
        cert_valid_days = None
        cert_generate_time = None
        
        if cert_expire_time:
            try:
                expire_dt = _parse_date(cert_expire_time)
                remaining_days = (expire_dt - datetime.datetime.now()).days
                
                # 如果有生成时间，计算有效期
                if data.get('cert_generate_time'):
                    generate_dt = _parse_date(data['cert_generate_time'])
                    cert_valid_days = (expire_dt - generate_dt).days
                    cert_generate_time = generate_dt
            except ValueError as e:
                return jsonify({'code': 400, 'message': str(e)}), 400
        
        # 插入数据
        sql = """
            INSERT INTO ssl_certificates 
            (domain, project_name, cert_type, issuer, cert_generate_time, 
             cert_valid_days, cert_expire_time, remaining_days, brand, 
             cost, status, source, remark, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
        """
        cursor.execute(sql, (
            domain, project_name, cert_type, issuer, cert_generate_time,
            cert_valid_days, cert_expire_time, remaining_days, brand,
            cost, status, 'manual', remark
        ))
        db.commit()
        cert_id = cursor.lastrowid
        # 记录操作日志
        log_operation(module='证书管理', action='create', target_id=cert_id, target_name=domain,
                     detail={'project_name': project_name, 'cert_type': '手动录入'})
        return jsonify({
            'code': 200,
            'message': '创建成功',
            'data': {'id': cert_id}
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


@certs_bp.route('/upload', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def upload_and_create_cert():
    """
    上传证书文件并自动解析创建证书记录
    接收 multipart/form-data:
        - cert_file: 证书文件(.pem/.crt)，必填
        - key_file: 私钥文件(.key)，可选
        - project_name: 项目名称，必填
        - brand: 品牌，可选
        - cost: 费用，可选
        - remark: 备注，可选
    
    自动从证书文件中解析: domain, issuer, cert_generate_time, cert_expire_time, cert_valid_days, remaining_days
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取上传的文件
        cert_file = request.files.get('cert_file')
        key_file = request.files.get('key_file')
        
        if not cert_file:
            return jsonify({'code': 400, 'message': '证书文件(cert_file)不能为空'}), 400
        
        # 获取表单字段
        project_name = request.form.get('project_name', '').strip()
        brand = request.form.get('brand', '').strip()
        cost = request.form.get('cost')
        remark = request.form.get('remark', '').strip()
        
        if not project_name:
            return jsonify({'code': 400, 'message': '项目名称不能为空'}), 400
        
        # 读取证书文件内容
        cert_content = cert_file.read().decode('utf-8')
        
        # 解析证书信息
        cert_info = _parse_cert_file(cert_content)
        if not cert_info:
            return jsonify({'code': 400, 'message': '证书文件解析失败，请确保证书格式正确(PEM格式)'}), 400
        
        domain = cert_info['domain']
        issuer = cert_info['issuer']
        cert_generate_time = cert_info['not_before']
        cert_expire_time = cert_info['not_after']
        cert_valid_days = cert_info['valid_days']
        remaining_days = cert_info['remaining_days']
        status = 1 if remaining_days > 0 else 0
        
        # 检查域名是否已存在
        cursor.execute("SELECT id FROM ssl_certificates WHERE domain = %s", (domain,))
        if cursor.fetchone():
            return jsonify({'code': 400, 'message': f'域名 {domain} 已存在证书记录'}), 400
        
        # 插入证书记录
        sql = """
            INSERT INTO ssl_certificates 
            (domain, project_name, cert_type, issuer, cert_generate_time, 
             cert_valid_days, cert_expire_time, remaining_days, brand, 
             cost, status, source, remark, has_cert_file, created_at, updated_at)
            VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, 0, NOW(), NOW())
        """
        cursor.execute(sql, (
            domain, project_name, 1, issuer, cert_generate_time,
            cert_valid_days, cert_expire_time, remaining_days, brand,
            cost, status, 'upload', remark
        ))
        db.commit()
        cert_id = cursor.lastrowid
        
        # 保存证书文件
        cert_dir = os.path.join(current_app.config.get('CERT_FILES_DIR', ''), str(cert_id))
        os.makedirs(cert_dir, exist_ok=True)
        safe_domain = _domain_filename(domain)
        
        # 保存证书文件
        cert_path = os.path.join(cert_dir, f'{safe_domain}.pem')
        with open(cert_path, 'w') as f:
            f.write(cert_content)
        
        # 保存私钥文件（如果存在）
        key_path = None
        if key_file:
            key_content = key_file.read().decode('utf-8')
            key_path = os.path.join(cert_dir, f'{safe_domain}.key')
            with open(key_path, 'w') as f:
                f.write(key_content)
        
        # 更新证书文件路径
        cursor.execute("""
            UPDATE ssl_certificates
            SET cert_file_path = %s, key_file_path = %s, has_cert_file = 1
            WHERE id = %s
        """, (cert_path, key_path, cert_id))
        db.commit()
    
        # 记录操作日志
        log_operation(module='证书管理', action='upload', target_id=cert_id, target_name=domain,
                     detail={'issuer': issuer, 'valid_days': cert_valid_days, 'remaining_days': remaining_days})
    
        return jsonify({
            'code': 200,
            'message': '上传成功',
            'data': {
                'id': cert_id,
                'domain': domain,
                'issuer': issuer,
                'cert_generate_time': cert_generate_time.strftime('%Y-%m-%d') if cert_generate_time else None,
                'cert_expire_time': cert_expire_time.strftime('%Y-%m-%d') if cert_expire_time else None,
                'valid_days': cert_valid_days,
                'remaining_days': remaining_days,
                'san_list': cert_info.get('san_list', [])
            }
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'上传失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/<int:cert_id>', methods=['PUT'])
@jwt_required
@role_required(['admin', 'operator'])
def update_cert(cert_id):
    """
    更新证书
    动态更新传入的字段，如果cert_expire_time被更新，重新计算remaining_days
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        
        # 检查证书是否存在
        cursor.execute("SELECT id FROM ssl_certificates WHERE id = %s", (cert_id,))
        if not cursor.fetchone():
            return jsonify({'code': 404, 'message': '证书不存在'}), 404
        
        # 构建更新字段
        fields = []
        values = []
        
        # 可更新的字段映射
        field_mapping = {
            'domain': 'domain',
            'project_name': 'project_name',
            'cert_type': 'cert_type',
            'issuer': 'issuer',
            'cert_generate_time': 'cert_generate_time',
            'cert_valid_days': 'cert_valid_days',
            'cert_expire_time': 'cert_expire_time',
            'brand': 'brand',
            'cost': 'cost',
            'status': 'status',
            'remark': 'remark'
        }
        
        for key, db_field in field_mapping.items():
            if key in data:
                fields.append(f"`{db_field}` = %s")
                values.append(data[key])
        
        # 如果更新了过期时间，重新计算剩余天数
        if 'cert_expire_time' in data and data['cert_expire_time']:
            try:
                expire_dt = _parse_date(data['cert_expire_time'])
                remaining_days = (expire_dt - datetime.datetime.now()).days
                fields.append("`remaining_days` = %s")
                values.append(remaining_days)
            except ValueError as e:
                return jsonify({'code': 400, 'message': str(e)}), 400
        
        if fields:
            fields.append("`updated_at` = NOW()")
            values.append(cert_id)
            sql = f"UPDATE ssl_certificates SET {', '.join(fields)} WHERE id = %s"
            cursor.execute(sql, values)
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
    删除证书
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 先获取证书信息用于日志
        cursor.execute("SELECT domain FROM ssl_certificates WHERE id = %s", (cert_id,))
        cert = cursor.fetchone()
        domain = cert['domain'] if cert else str(cert_id)
        
        cursor.execute("DELETE FROM ssl_certificates WHERE id = %s", (cert_id,))
        db.commit()
        
        if cursor.rowcount == 0:
            return jsonify({'code': 404, 'message': '证书不存在'}), 404
        
        # 记录操作日志
        log_operation(module='证书管理', action='delete', target_id=cert_id, target_name=domain)
        
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


@certs_bp.route('/check', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def batch_check_certs():
    """
    批量SSL在线检测
    可选参数 ids: [1,2,3]，如果不传则检测所有 cert_type=0 的证书
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json or {}
        cert_ids = data.get('ids', [])
        
        # 获取需要检测的证书列表
        if cert_ids:
            placeholders = ','.join(['%s'] * len(cert_ids))
            sql = f"""
                SELECT id, domain, project_name, cert_type 
                FROM ssl_certificates 
                WHERE id IN ({placeholders})
            """
            cursor.execute(sql, cert_ids)
        else:
            # 检测所有自动检测类型的证书 (cert_type=0)
            sql = """
                SELECT id, domain, project_name, cert_type 
                FROM ssl_certificates 
                WHERE cert_type = 0
            """
            cursor.execute(sql)
        
        certs = cursor.fetchall()
        
        if not certs:
            return jsonify({
                'code': 200,
                'message': '没有需要检测的证书',
                'data': {'total': 0, 'success': 0, 'failed': 0, 'results': []}
            })
        
        results = []
        success_count = 0
        failed_count = 0
        
        for cert in certs:
            cert_id = cert['id']
            domain = cert['domain']
            
            # 调用SSL检测
            cert_info = get_ssl_cert_info(domain)
            
            if cert_info:
                # 更新数据库
                update_sql = """
                    UPDATE ssl_certificates 
                    SET issuer = %s,
                        cert_generate_time = %s,
                        cert_valid_days = %s,
                        cert_expire_time = %s,
                        remaining_days = %s,
                        last_check_time = NOW(),
                        status = %s,
                        updated_at = NOW()
                    WHERE id = %s
                """
                status = 1 if cert_info['remaining_days'] > 0 else 0
                cursor.execute(update_sql, (
                    cert_info['issuer'],
                    cert_info['not_before'],
                    cert_info['valid_days'],
                    cert_info['not_after'],
                    cert_info['remaining_days'],
                    status,
                    cert_id
                ))
                db.commit()
                
                results.append({
                    'id': cert_id,
                    'domain': domain,
                    'status': 'success',
                    'remaining_days': cert_info['remaining_days'],
                    'issuer': cert_info['issuer']
                })
                success_count += 1
            else:
                # 检测失败，只更新检查时间
                update_sql = """
                    UPDATE ssl_certificates 
                    SET last_check_time = NOW(),
                        updated_at = NOW()
                    WHERE id = %s
                """
                cursor.execute(update_sql, (cert_id,))
                db.commit()
                
                results.append({
                    'id': cert_id,
                    'domain': domain,
                    'status': 'failed',
                    'message': 'SSL检测失败'
                })
                failed_count += 1
        
        return jsonify({
            'code': 200,
            'message': '检测完成',
            'data': {
                'total': len(certs),
                'success': success_count,
                'failed': failed_count,
                'results': results
            }
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'批量检测失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/check/<int:cert_id>', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def check_single_cert(cert_id):
    """
    检测单个证书
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取证书信息
        cursor.execute(
            "SELECT id, domain, project_name FROM ssl_certificates WHERE id = %s",
            (cert_id,)
        )
        cert = cursor.fetchone()
        
        if not cert:
            return jsonify({'code': 404, 'message': '证书不存在'}), 404
        
        domain = cert['domain']
        
        # 调用SSL检测
        cert_info = get_ssl_cert_info(domain)
        
        if cert_info:
            # 更新数据库
            update_sql = """
                UPDATE ssl_certificates 
                SET issuer = %s,
                    cert_generate_time = %s,
                    cert_valid_days = %s,
                    cert_expire_time = %s,
                    remaining_days = %s,
                    last_check_time = NOW(),
                    status = %s,
                    updated_at = NOW()
                WHERE id = %s
            """
            status = 1 if cert_info['remaining_days'] > 0 else 0
            cursor.execute(update_sql, (
                cert_info['issuer'],
                cert_info['not_before'],
                cert_info['valid_days'],
                cert_info['not_after'],
                cert_info['remaining_days'],
                status,
                cert_id
            ))
            db.commit()
            
            return jsonify({
                'code': 200,
                'message': '检测成功',
                'data': {
                    'id': cert_id,
                    'domain': domain,
                    'subject': cert_info['subject'],
                    'issuer': cert_info['issuer'],
                    'not_before': cert_info['not_before'].strftime('%Y-%m-%d %H:%M:%S'),
                    'not_after': cert_info['not_after'].strftime('%Y-%m-%d %H:%M:%S'),
                    'valid_days': cert_info['valid_days'],
                    'remaining_days': cert_info['remaining_days'],
                    'has_expired': cert_info['has_expired']
                }
            })
        else:
            # 检测失败，只更新检查时间
            update_sql = """
                UPDATE ssl_certificates 
                SET last_check_time = NOW(),
                    updated_at = NOW()
                WHERE id = %s
            """
            cursor.execute(update_sql, (cert_id,))
            db.commit()
            
            return jsonify({
                'code': 500,
                'message': f'检测域名 {domain} 失败'
            }), 500
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'检测失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/sync-aliyun', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def sync_aliyun_certs():
    """
    从阿里云同步证书
    请求体包含 account_id
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json or {}
        account_id = data.get('account_id')
        
        if not account_id:
            return jsonify({'code': 400, 'message': 'account_id不能为空'}), 400
        
        # 获取阿里云账号信息
        cursor.execute(
            "SELECT account_name, access_key_id, access_key_secret FROM aliyun_accounts WHERE id = %s AND is_active = 1",
            (account_id,)
        )
        account = cursor.fetchone()
        
        if not account:
            return jsonify({'code': 404, 'message': '阿里云账号不存在或已禁用'}), 404
        
        # 调用阿里云证书扫描
        aliyun_certs = scan_aliyun_certs(
            account['access_key_id'],
            account['access_key_secret'],
            account['account_name']
        )
        
        if not aliyun_certs:
            return jsonify({
                'code': 200,
                'message': '未从阿里云获取到证书',
                'data': {'synced': 0, 'skipped': 0}
            })
        
        synced_count = 0
        skipped_count = 0
        updated_count = 0
        downloaded_count = 0
        download_failed_count = 0
        
        for cert_info in aliyun_certs:
            domain = cert_info['domain']
            
            # 检查是否已存在
            cursor.execute(
                "SELECT id, cert_expire_time, has_cert_file FROM ssl_certificates WHERE domain = %s",
                (domain,)
            )
            existing = cursor.fetchone()
            
            if existing:
                # 比较到期时间，如果新证书到期时间更晚则更新
                existing_expire = existing.get('cert_expire_time')
                new_expire = cert_info['not_after']
                
                should_update = False
                if existing_expire is None:
                    should_update = True
                elif new_expire and new_expire > existing_expire:
                    should_update = True
                
                if should_update:
                    update_sql = """
                        UPDATE ssl_certificates 
                        SET issuer = %s, cert_generate_time = %s, cert_valid_days = %s,
                            cert_expire_time = %s, remaining_days = %s, 
                            status = %s, aliyun_account_id = %s, updated_at = NOW()
                        WHERE id = %s
                    """
                    status = 1 if cert_info['remaining_days'] > 0 else 0
                    cursor.execute(update_sql, (
                        cert_info['issuer'],
                        cert_info['not_before'],
                        cert_info['valid_days'],
                        cert_info['not_after'],
                        cert_info['remaining_days'],
                        status,
                        account_id,
                        existing['id']
                    ))
                    updated_count += 1
                else:
                    skipped_count += 1

                db_cert_id = existing['id']
                # 无论是否更新元数据，只要缺少证书文件就尝试下载
                if not existing.get('has_cert_file') and cert_info.get('cert_id'):
                    logger.info(f"证书已存在但缺少文件，尝试下载: {domain} (cert_id={cert_info['cert_id']})")
                    try:
                        from ..utils.ssl_checker import download_aliyun_cert
                        cert_content = download_aliyun_cert(
                            account['access_key_id'],
                            account['access_key_secret'],
                            cert_info['cert_id']
                        )
                        if cert_content:
                            cert_dir = os.path.join(current_app.config.get('CERT_FILES_DIR', ''), str(db_cert_id))
                            os.makedirs(cert_dir, exist_ok=True)
                            safe_domain = _domain_filename(domain)

                            cert_path = os.path.join(cert_dir, f'{safe_domain}.pem')
                            with open(cert_path, 'w') as f:
                                f.write(cert_content['cert'])

                            key_path = None
                            if cert_content.get('key'):
                                key_path = os.path.join(cert_dir, f'{safe_domain}.key')
                                with open(key_path, 'w') as f:
                                    f.write(cert_content['key'])

                            cursor.execute("""
                                UPDATE ssl_certificates
                                SET cert_file_path = %s, key_file_path = %s, has_cert_file = 1
                                WHERE id = %s
                            """, (cert_path, key_path, db_cert_id))
                            downloaded_count += 1
                            logger.info(f"证书文件下载成功: {domain}")
                        else:
                            download_failed_count += 1
                            logger.warning(f"证书文件下载返回空: {domain}")
                    except Exception as e:
                        download_failed_count += 1
                        logger.warning(f"下载阿里云证书文件失败: {domain} - {e}")
                continue

            # 插入新证书
            insert_sql = """
                INSERT INTO ssl_certificates
                (domain, project_name, cert_type, issuer, cert_generate_time,
                 cert_valid_days, cert_expire_time, remaining_days,
                 source, aliyun_account_id, status, created_at, updated_at)
                VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW(), NOW())
            """
            project_name = f"阿里云证书 - {domain}"
            status = 1 if cert_info['remaining_days'] > 0 else 0

            cursor.execute(insert_sql, (
                domain,
                project_name,
                2,  # cert_type = 2: 阿里云证书
                cert_info['issuer'],
                cert_info['not_before'],
                cert_info['valid_days'],
                cert_info['not_after'],
                cert_info['remaining_days'],
                'aliyun',
                account_id,
                status
            ))
            synced_count += 1
            db_cert_id = cursor.lastrowid

            # 自动下载证书文件
            if cert_info.get('cert_id'):
                try:
                    from ..utils.ssl_checker import download_aliyun_cert
                    cert_content = download_aliyun_cert(
                        account['access_key_id'],
                        account['access_key_secret'],
                        cert_info['cert_id']
                    )
                    if cert_content:
                        cert_dir = os.path.join(current_app.config.get('CERT_FILES_DIR', ''), str(db_cert_id))
                        os.makedirs(cert_dir, exist_ok=True)
                        safe_domain = _domain_filename(domain)

                        cert_path = os.path.join(cert_dir, f'{safe_domain}.pem')
                        with open(cert_path, 'w') as f:
                            f.write(cert_content['cert'])

                        key_path = None
                        if cert_content.get('key'):
                            key_path = os.path.join(cert_dir, f'{safe_domain}.key')
                            with open(key_path, 'w') as f:
                                f.write(cert_content['key'])

                        cursor.execute("""
                            UPDATE ssl_certificates
                            SET cert_file_path = %s, key_file_path = %s, has_cert_file = 1
                            WHERE id = %s
                        """, (cert_path, key_path, db_cert_id))
                        downloaded_count += 1
                    else:
                        download_failed_count += 1
                except Exception as e:
                    download_failed_count += 1
                    logger.warning(f"下载阿里云证书文件失败: {domain} - {e}")
        
        db.commit()
        
        return jsonify({
            'code': 200,
            'message': '同步完成',
            'data': {
                'synced': synced_count,
                'updated': updated_count,
                'skipped': skipped_count,
                'downloaded': downloaded_count,
                'download_failed': download_failed_count,
                'total': len(aliyun_certs)
            }
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'同步失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/notify', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def trigger_notify():
    """
    手动触发微信预警通知
    查询所有即将过期的证书（remaining_days <= WARNING_DAYS）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 从配置获取预警天数
        warning_days = current_app.config.get('SSL_WARNING_DAYS', 30)
        webhook_url = current_app.config.get('WECHAT_WEBHOOK_URL', '')
        
        if not webhook_url:
            return jsonify({'code': 500, 'message': '未配置微信Webhook地址'}), 500
        
        # 查询即将过期的证书
        sql = """
            SELECT id, domain, project_name, remaining_days, cert_expire_time
            FROM ssl_certificates 
            WHERE remaining_days <= %s AND status = 1
            ORDER BY remaining_days ASC
        """
        cursor.execute(sql, (warning_days,))
        certs = cursor.fetchall()
        
        if not certs:
            return jsonify({
                'code': 200,
                'message': '没有需要预警的证书',
                'data': {'notified': 0}
            })
        
        # 发送通知
        success = send_wechat_notification(webhook_url, certs)
        
        if success:
            # 更新通知状态
            for cert in certs:
                cursor.execute("""
                    UPDATE ssl_certificates 
                    SET last_notify_time = NOW(), notify_status = 1
                    WHERE id = %s
                """, (cert['id'],))
            db.commit()
            
            return jsonify({
                'code': 200,
                'message': '通知发送成功',
                'data': {'notified': len(certs)}
            })
        else:
            return jsonify({
                'code': 500,
                'message': '通知发送失败'
            }), 500
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'触发通知失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/<int:cert_id>/upload', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def upload_cert_files(cert_id):
    """
    上传证书文件
    接收 multipart/form-data，字段名 cert_file 和 key_file
    cert_file 必填，key_file 可选
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 验证证书记录存在
        cursor.execute("SELECT id, domain FROM ssl_certificates WHERE id = %s", (cert_id,))
        cert = cursor.fetchone()
        if not cert:
            return jsonify({'code': 404, 'message': '证书不存在'}), 404

        # 获取上传的文件
        cert_file = request.files.get('cert_file')
        key_file = request.files.get('key_file')

        if not cert_file:
            return jsonify({'code': 400, 'message': '证书文件(cert_file)不能为空'}), 400

        # 创建目录
        cert_dir = os.path.join(current_app.config.get('CERT_FILES_DIR', ''), str(cert_id))
        os.makedirs(cert_dir, exist_ok=True)
        safe_domain = _domain_filename(cert['domain'])

        # 保存证书文件
        cert_path = os.path.join(cert_dir, f'{safe_domain}.pem')
        cert_file.save(cert_path)

        # 保存私钥文件（如果存在）
        key_path = None
        if key_file:
            key_path = os.path.join(cert_dir, f'{safe_domain}.key')
            key_file.save(key_path)

        # 更新数据库
        cursor.execute("""
            UPDATE ssl_certificates
            SET cert_file_path = %s, key_file_path = %s, has_cert_file = 1
            WHERE id = %s
        """, (cert_path, key_path, cert_id))
        db.commit()

        return jsonify({
            'code': 200,
            'message': '上传成功',
            'data': {
                'cert_file_path': cert_path,
                'key_file_path': key_path
            }
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'上传失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/<int:cert_id>/download', methods=['GET'])
@jwt_required
def download_cert_files(cert_id):
    """
    下载证书文件
    返回 zip 文件，包含 cert.pem 和 key.pem（如果存在）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 查询证书记录
        cursor.execute("""
            SELECT domain, cert_file_path, key_file_path, has_cert_file
            FROM ssl_certificates WHERE id = %s
        """, (cert_id,))
        cert = cursor.fetchone()

        if not cert:
            return jsonify({'code': 404, 'message': '证书不存在'}), 404

        if cert['has_cert_file'] != 1:
            return jsonify({'code': 404, 'message': '证书文件不存在'}), 404

        # 创建内存中的 zip 文件
        memory_file = io.BytesIO()
        safe_domain = _domain_filename(cert['domain'])
        with zipfile.ZipFile(memory_file, 'w', zipfile.ZIP_DEFLATED) as zf:
            # 添加证书文件
            if cert['cert_file_path'] and os.path.exists(cert['cert_file_path']):
                zf.write(cert['cert_file_path'], f'{safe_domain}.pem')

            # 添加私钥文件（如果存在）
            if cert['key_file_path'] and os.path.exists(cert['key_file_path']):
                zf.write(cert['key_file_path'], f'{safe_domain}.key')

        memory_file.seek(0)

        # 构建文件名
        domain = cert['domain'].replace('.', '_').replace('*', 'wildcard')
        filename = f"{domain}_cert.zip"

        return send_file(
            memory_file,
            mimetype='application/zip',
            as_attachment=True,
            download_name=filename
        )
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'下载失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()


@certs_bp.route('/<int:cert_id>/files', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_cert_files(cert_id):
    """
    删除证书文件
    删除服务器上存储的证书文件并更新数据库
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 查询证书记录
        cursor.execute("""
            SELECT cert_file_path, key_file_path, has_cert_file
            FROM ssl_certificates WHERE id = %s
        """, (cert_id,))
        cert = cursor.fetchone()

        if not cert:
            return jsonify({'code': 404, 'message': '证书不存在'}), 404

        if cert['has_cert_file'] != 1:
            return jsonify({'code': 400, 'message': '证书文件不存在'}), 400

        # 删除证书目录
        cert_dir = os.path.join(current_app.config.get('CERT_FILES_DIR', ''), str(cert_id))
        if os.path.exists(cert_dir):
            shutil.rmtree(cert_dir)

        # 更新数据库
        cursor.execute("""
            UPDATE ssl_certificates
            SET cert_file_path = NULL, key_file_path = NULL, has_cert_file = 0
            WHERE id = %s
        """, (cert_id,))
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


@certs_bp.route('/<int:cert_id>/deploy', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def deploy_cert(cert_id):
    """
    远程部署证书
    请求体: { "server_id": 1, "remote_path": "/etc/nginx/ssl/", "ssh_user": "root" }
    ssh_user 可选值: "root"(使用系统用户), "docker"(使用普通用户)
    使用 SSH/SFTP 上传证书到远程服务器
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json or {}
        server_id = data.get('server_id')
        remote_path = data.get('remote_path', '/etc/nginx/ssl/')
        ssh_user_type = data.get('ssh_user', 'root')  # root 或 docker

        if not server_id:
            return jsonify({'code': 400, 'message': 'server_id不能为空'}), 400

        # 查询证书记录
        cursor.execute("""
            SELECT domain, cert_file_path, key_file_path, has_cert_file
            FROM ssl_certificates WHERE id = %s
        """, (cert_id,))
        cert = cursor.fetchone()

        if not cert:
            return jsonify({'code': 404, 'message': '证书不存在'}), 404

        if cert['has_cert_file'] != 1:
            return jsonify({'code': 400, 'message': '证书文件不存在，请先上传证书'}), 400

        # 查询服务器信息
        cursor.execute("""
            SELECT inner_ip, os_user, os_password, docker_user, docker_password
            FROM servers WHERE id = %s
        """, (server_id,))
        server = cursor.fetchone()

        if not server:
            return jsonify({'code': 404, 'message': '服务器不存在'}), 404

        # 根据 ssh_user_type 选择用户名和密码
        if ssh_user_type == 'docker':
            ssh_username = server.get('docker_user') or 'docker'
            ssh_password = server.get('docker_password')
            if not ssh_password:
                return jsonify({'code': 400, 'message': '该服务器未配置普通用户密码'}), 400
        else:
            ssh_username = server.get('os_user') or 'root'
            ssh_password = server.get('os_password')
            if not ssh_password:
                return jsonify({'code': 400, 'message': '该服务器未配置系统密码'}), 400

        # 检查证书文件是否存在
        if not cert['cert_file_path'] or not os.path.exists(cert['cert_file_path']):
            return jsonify({'code': 400, 'message': '证书文件不存在'}), 400

        # 建立 SSH 连接
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

        try:
            ssh.connect(
                hostname=server['inner_ip'],
                username=ssh_username,
                password=ssh_password,
                timeout=30
            )
        except Exception as e:
            return jsonify({
                'code': 500,
                'message': f'SSH连接失败(用户: {ssh_username}): {str(e)}'
            }), 500

        # 使用 SFTP 上传文件
        try:
            sftp = ssh.open_sftp()

            # 确保远程目录存在
            try:
                sftp.stat(remote_path)
            except FileNotFoundError:
                # 目录不存在，创建目录
                ssh.exec_command(f'mkdir -p {remote_path}')

            # 构建远程文件名
            domain = cert['domain'].replace('.', '_').replace('*', 'wildcard')
            remote_cert_path = os.path.join(remote_path, f"{domain}_cert.pem")
            remote_key_path = os.path.join(remote_path, f"{domain}_key.pem")

            # 上传证书文件
            sftp.put(cert['cert_file_path'], remote_cert_path)

            # 上传私钥文件（如果存在）
            if cert['key_file_path'] and os.path.exists(cert['key_file_path']):
                sftp.put(cert['key_file_path'], remote_key_path)

            sftp.close()

            # 记录操作日志
            log_operation(module='证书管理', action='deploy', target_id=cert_id, target_name=cert['domain'],
                         detail={'ssh_user': ssh_username, 'remote_path': remote_path, 'server_ip': server['inner_ip']})

            return jsonify({
                'code': 200,
                'message': '部署成功',
                'data': {
                    'ssh_user': ssh_username,
                    'remote_cert_path': remote_cert_path,
                    'remote_key_path': remote_key_path if cert['key_file_path'] else None
                }
            })
        except Exception as e:
            return jsonify({
                'code': 500,
                'message': f'文件上传失败: {str(e)}'
            }), 500
        finally:
            ssh.close()

    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'部署失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
        db.close()
