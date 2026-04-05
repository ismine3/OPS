"""
域名管理 API
"""
from flask import Blueprint, request, jsonify, current_app
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required
from ..utils.ssl_checker import send_domain_expiry_notification
from ..utils.operation_log import log_operation
from ..utils.password_utils import decrypt_data

domains_bp = Blueprint('domains', __name__, url_prefix='/api/domains')

# 尝试导入阿里云 SDK
try:
    from alibabacloud_domain20180129.client import Client as Domain20180129Client
    from alibabacloud_tea_openapi import models as open_api_models
    from alibabacloud_domain20180129 import models as domain_20180129_models
    from alibabacloud_tea_util import models as util_models
    ALIYUN_SDK_AVAILABLE = True
except ImportError:
    ALIYUN_SDK_AVAILABLE = False


def create_aliyun_client(access_key_id, access_key_secret):
    """创建阿里云域名客户端"""
    config = open_api_models.Config(
        access_key_id=access_key_id,
        access_key_secret=access_key_secret
    )
    config.endpoint = 'domain.aliyuncs.com'
    return Domain20180129Client(config)


@domains_bp.route('', methods=['GET'])
@jwt_required
def get_domains():
    """
    获取域名列表（分页）
    支持 search 参数搜索 domain_name/owner/registrar
    支持 project_id 参数筛选项目
    
    参数:
        page: 页码，默认1
        page_size: 每页数量，默认20
        search: 搜索关键词
        project_id: 项目ID筛选
    
    返回: {"code": 200, "data": {"items": [...], "total": N}}
    """
    import datetime
    
    search = request.args.get('search', '').strip()
    project_id = request.args.get('project_id', '').strip()
    page = int(request.args.get('page', 1))
    page_size = int(request.args.get('page_size', 20))
    offset = (page - 1) * page_size
    
    db = get_db()
    cursor = db.cursor()
    try:
        # 构建基础查询条件
        base_sql = """
            FROM domains d
            LEFT JOIN credentials c ON d.aliyun_account_id = c.id
            LEFT JOIN projects p ON d.project_id = p.id
        """
        params = []
                
        if search:
            base_sql += " WHERE d.domain_name LIKE %s OR d.owner LIKE %s OR d.registrar LIKE %s"
            like_pattern = f'%{search}%'
            params = [like_pattern, like_pattern, like_pattern]
                
        if project_id:
            if search:
                base_sql += " AND d.project_id = %s"
            else:
                base_sql += " WHERE d.project_id = %s"
            params.append(project_id)
        
        # 查询总数
        count_sql = f"SELECT COUNT(*) as total {base_sql}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']
        
        # 查询分页数据
        data_sql = f"""
            SELECT d.*, c.credential_name as aliyun_account_name, p.project_name
            {base_sql}
            ORDER BY d.id DESC
            LIMIT %s OFFSET %s
        """
        params.extend([page_size, offset])
        cursor.execute(data_sql, params)
        domains = cursor.fetchall()
        
        # 序列化 datetime 字段
        for domain in domains:
            for key in ['registration_date', 'expire_date', 'created_at', 'updated_at']:
                if domain.get(key) and isinstance(domain[key], (datetime.datetime, datetime.date)):
                    domain[key] = domain[key].strftime('%Y-%m-%d %H:%M:%S') if isinstance(domain[key], datetime.datetime) else str(domain[key])
        
        return jsonify({
            'code': 200,
            'data': {
                'items': domains,
                'total': total
            }
        }), 200
    finally:
        cursor.close()

@domains_bp.route('', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def create_domain():
    """
    手动添加域名
    
    请求体: {
        "domain_name": "xxx.com",
        "registrar": "阿里云",
        "registration_date": "2024-01-01",
        "expire_date": "2025-01-01",
        "owner": "xxx公司",
        "dns_servers": "dns1.xxx.com,dns2.xxx.com",
        "status": "正常",
        "cost": 100.00,
        "remark": "备注"
    }
    返回: {"code": 200, "message": "域名添加成功"}
    """
    data = request.get_json()
    
    if not data:
        return jsonify({
            'code': 400,
            'message': '请求体不能为空'
        }), 400
    
    domain_name = data.get('domain_name')
    
    if not domain_name:
        return jsonify({
            'code': 400,
            'message': '域名不能为空'
        }), 400
    
    db = get_db()
    cursor = db.cursor()
    try:
        # 检查域名是否已存在
        cursor.execute("SELECT id FROM domains WHERE domain_name = %s", (domain_name,))
        if cursor.fetchone():
            return jsonify({
                'code': 409,
                'message': '域名已存在'
            }), 409
        
        # 创建域名
        cursor.execute("""
            INSERT INTO domains (
                domain_name, registrar, registration_date, expire_date, owner,
                dns_servers, status, source, cost, remark, project_id
            ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
        """, (
            domain_name,
            data.get('registrar', ''),
            data.get('registration_date'),
            data.get('expire_date'),
            data.get('owner', ''),
            data.get('dns_servers', ''),
            data.get('status', '正常'),
            'manual',
            data.get('cost'),
            data.get('remark', ''),
            data.get('project_id')
        ))
        
        db.commit()
        domain_id = cursor.lastrowid
        
        # 记录操作日志
        log_operation('域名管理', 'create', domain_id, domain_name, {'registrar': data.get('registrar')})
        
        return jsonify({
            'code': 200,
            'message': '域名添加成功',
            'data': {'id': domain_id}
        }), 200
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'域名添加失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@domains_bp.route('/<int:domain_id>', methods=['PUT'])
@jwt_required
@role_required(['admin', 'operator'])
def update_domain(domain_id):
    """
    更新域名信息
    
    请求体: {
        "registrar": "阿里云",
        "registration_date": "2024-01-01",
        "expire_date": "2025-01-01",
        "owner": "xxx公司",
        "dns_servers": "dns1.xxx.com,dns2.xxx.com",
        "status": "正常",
        "cost": 100.00,
        "remark": "备注"
    }
    返回: {"code": 200, "message": "域名更新成功"}
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
        # 检查域名是否存在
        cursor.execute("SELECT id FROM domains WHERE id = %s", (domain_id,))
        if not cursor.fetchone():
            return jsonify({
                'code': 404,
                'message': '域名不存在'
            }), 404
        
        # 检查域名名称是否与其他域名冲突
        if 'domain_name' in data:
            cursor.execute(
                "SELECT id FROM domains WHERE domain_name = %s AND id != %s",
                (data['domain_name'], domain_id)
            )
            if cursor.fetchone():
                return jsonify({
                    'code': 409,
                    'message': '域名已存在'
                }), 409
        
        # 构建更新数据
        allowed_fields = [
            'domain_name', 'registrar', 'registration_date', 'expire_date',
            'owner', 'dns_servers', 'status', 'cost', 'remark', 'project_id'
        ]
        
        update_fields = []
        update_values = []
        
        for field in allowed_fields:
            if field in data:
                update_fields.append(f"{field} = %s")
                update_values.append(data[field])
        
        if not update_fields:
            return jsonify({
                'code': 400,
                'message': '没有要更新的字段'
            }), 400
        
        # 执行更新
        update_values.append(domain_id)
        sql = f"UPDATE domains SET {', '.join(update_fields)} WHERE id = %s"
        cursor.execute(sql, update_values)
        db.commit()
        
        # 记录操作日志
        log_operation('域名管理', 'update', domain_id, data.get('domain_name'))
        
        return jsonify({
            'code': 200,
            'message': '域名更新成功'
        }), 200
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'域名更新失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@domains_bp.route('/<int:domain_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin', 'operator'])
def delete_domain(domain_id):
    """
    删除域名
    
    返回: {"code": 200, "message": "域名删除成功"}
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取域名名称
        cursor.execute("SELECT domain_name FROM domains WHERE id = %s", (domain_id,))
        domain = cursor.fetchone()
        if not domain:
            return jsonify({
                'code': 404,
                'message': '域名不存在'
            }), 404
        
        domain_name = domain['domain_name']
        
        # 删除域名
        cursor.execute("DELETE FROM domains WHERE id = %s", (domain_id,))
        db.commit()
        
        # 记录操作日志
        log_operation('域名管理', 'delete', domain_id, domain_name)
        
        return jsonify({
            'code': 200,
            'message': '域名删除成功'
        }), 200
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'域名删除失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@domains_bp.route('/sync-aliyun', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def sync_aliyun_domains():
    """
    从阿里云同步域名列表
    
    请求体: {"account_id": 1}
    返回: {"code": 200, "message": "同步成功", "data": {"total": 10, "added": 5, "skipped": 5}}
    """
    if not ALIYUN_SDK_AVAILABLE:
        return jsonify({
            'code': 500,
            'message': '阿里云 SDK 未安装，请先安装依赖: pip install alibabacloud_domain20180129 alibabacloud_tea_openapi alibabacloud_tea_util'
        }), 500
    
    data = request.get_json()
    
    if not data or not data.get('account_id'):
        return jsonify({
            'code': 400,
            'message': 'account_id 不能为空'
        }), 400
    
    account_id = data.get('account_id')
    
    db = get_db()
    cursor = db.cursor()
    try:
        # 获取阿里云账户信息（需要解密 access_key_secret）
        cursor.execute(
            "SELECT access_key_id, access_key_secret FROM credentials WHERE id = %s AND is_active = 1",
            (account_id,)
        )
        account = cursor.fetchone()
            
        if not account:
            return jsonify({
                'code': 404,
                'message': '阿里云账户不存在或已禁用'
            }), 404
            
        # 解密 AccessKey Secret
        try:
            access_key_secret = decrypt_data(account['access_key_secret'])
        except Exception as e:
            logger.error(f'AccessKey Secret 解密失败：{e}')
            return jsonify({
                'code': 500,
                'message': f'AccessKey Secret 解密失败：{str(e)}'
            }), 500
            
        # 创建阿里云客户端
        try:
            client = create_aliyun_client(
                account['access_key_id'],
                access_key_secret
            )
        except Exception as e:
            return jsonify({
                'code': 500,
                'message': f'创建阿里云客户端失败：{str(e)}'
            }), 500
        
        # 查询域名列表
        all_domains = []
        page_num = 1
        page_size = 100
        
        import logging
        logger = logging.getLogger(__name__)
        
        try:
            while True:
                query_request = domain_20180129_models.QueryDomainListRequest(
                    page_num=page_num,
                    page_size=page_size
                )
                runtime = util_models.RuntimeOptions()
                resp = client.query_domain_list_with_options(query_request, runtime)
                
                # 解析响应 - 兼容 PascalCase 和 snake_case
                domains_data = None
                if hasattr(resp, 'body'):
                    body = resp.body
                    logger.info(f"阿里云域名API响应 body 类型: {type(body)}")
                    
                    # 尝试 snake_case (新版SDK)
                    if hasattr(body, 'data') and body.data is not None:
                        data_obj = body.data
                        if hasattr(data_obj, 'domain') and data_obj.domain is not None:
                            domains_data = data_obj.domain
                    
                    # 尝试 PascalCase (旧版SDK)
                    if domains_data is None and hasattr(body, 'Data') and body.Data is not None:
                        data_obj = body.Data
                        if hasattr(data_obj, 'Domain') and data_obj.Domain is not None:
                            domains_data = data_obj.Domain
                    
                    # 尝试 total_count / TotalCount 获取总页数
                    total_count = getattr(body, 'total_count', None) or getattr(body, 'TotalCount', None) or 0
                    logger.info(f"阿里云域名总数: {total_count}")
                
                if not domains_data:
                    logger.warning(f"第 {page_num} 页未获取到域名数据")
                    if page_num == 1:
                        # 第一页就没数据，尝试打印 body 信息帮助调试
                        try:
                            body_str = str(resp.body) if hasattr(resp, 'body') else str(resp)
                            logger.info(f"API 响应内容: {body_str[:1000]}")
                        except:
                            pass
                    break
                
                logger.info(f"第 {page_num} 页获取到 {len(domains_data)} 个域名")
                
                for domain in domains_data:
                    # 兼容 PascalCase 和 snake_case 属性名
                    domain_name = (getattr(domain, 'domain_name', None) 
                                   or getattr(domain, 'DomainName', None) or '')
                    
                    if not domain_name:
                        continue
                    
                    # 解析注册日期和到期日期
                    reg_date = (getattr(domain, 'registration_date', None) 
                                or getattr(domain, 'RegistrationDate', None))
                    exp_date = (getattr(domain, 'expiration_date', None) 
                                or getattr(domain, 'ExpirationDate', None))
                    
                    # 日期可能是字符串格式，需要处理
                    # 阿里云返回格式可能是 "2024-01-01 00:00:00" 或时间戳
                    if reg_date and not isinstance(reg_date, str):
                        try:
                            reg_date = str(reg_date)
                        except:
                            reg_date = None
                    if exp_date and not isinstance(exp_date, str):
                        try:
                            exp_date = str(exp_date)
                        except:
                            exp_date = None
                    
                    # 只取日期部分 YYYY-MM-DD
                    if reg_date and len(reg_date) > 10:
                        reg_date = reg_date[:10]
                    if exp_date and len(exp_date) > 10:
                        exp_date = exp_date[:10]
                    
                    registrar = (getattr(domain, 'registrant_organization', None)
                                 or getattr(domain, 'RegistrantOrganization', None) or '')
                    
                    # DNS 列表处理
                    dns_list = (getattr(domain, 'dns_list', None) 
                                or getattr(domain, 'DnsList', None))
                    if dns_list:
                        if hasattr(dns_list, 'dns'):
                            dns_servers = ','.join(dns_list.dns) if dns_list.dns else ''
                        elif hasattr(dns_list, 'Dns'):
                            dns_servers = ','.join(dns_list.Dns) if dns_list.Dns else ''
                        elif isinstance(dns_list, list):
                            dns_servers = ','.join(dns_list)
                        else:
                            dns_servers = str(dns_list)
                    else:
                        dns_servers = ''
                    
                    # 获取域名状态和过期状态
                    domain_status_raw = (getattr(domain, 'domain_status', None) 
                                         or getattr(domain, 'DomainStatus', None))
                    expiration_status_raw = (getattr(domain, 'expiration_date_status', None) 
                                             or getattr(domain, 'ExpirationDateStatus', None))
                    
                    # 综合判断状态：优先显示过期状态，再显示域名状态
                    # ExpirationDateStatus: 1-未过期, 2-已过期
                    # DomainStatus: 1-急需续费, 2-急需赎回, 3-正常
                    if expiration_status_raw == 2 or expiration_status_raw == '2':
                        domain_status = 4  # 已过期
                    elif domain_status_raw in [1, '1']:
                        domain_status = 1  # 急需续费
                    elif domain_status_raw in [2, '2']:
                        domain_status = 2  # 急需赎回
                    elif domain_status_raw in [3, '3']:
                        domain_status = 3  # 正常
                    elif domain_status_raw is None:
                        domain_status = 3  # 默认正常
                    else:
                        domain_status = domain_status_raw
                    
                    domain_info = {
                        'domain_name': domain_name,
                        'registrar': registrar,
                        'registration_date': reg_date,
                        'expire_date': exp_date,
                        'owner': (getattr(domain, 'registrant_name', None) 
                                  or getattr(domain, 'Registrant', None) or ''),
                        'dns_servers': dns_servers,
                        'status': domain_status
                    }
                    all_domains.append(domain_info)
                
                # 如果返回的数据少于 page_size，说明已经获取完所有数据
                if len(domains_data) < page_size:
                    break
                page_num += 1
        except Exception as e:
            import traceback
            logger.error(f"查询阿里云域名列表失败: {traceback.format_exc()}")
            return jsonify({
                'code': 500,
                'message': f'查询阿里云域名列表失败: {str(e)}'
            }), 500
        
        # 将域名插入数据库（INSERT IGNORE 避免重复）
        added_count = 0
        skipped_count = 0
        
        for domain_info in all_domains:
            cursor.execute("SELECT id FROM domains WHERE domain_name = %s", (domain_info['domain_name'],))
            if cursor.fetchone():
                skipped_count += 1
                continue
            
            cursor.execute("""
                INSERT INTO domains (
                    domain_name, registrar, registration_date, expire_date, owner,
                    dns_servers, status, source, aliyun_account_id
                ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
            """, (
                domain_info['domain_name'],
                domain_info['registrar'],
                domain_info['registration_date'],
                domain_info['expire_date'],
                domain_info['owner'],
                domain_info['dns_servers'],
                domain_info['status'],
                'aliyun',
                account_id
            ))
            added_count += 1
        
        db.commit()
        
        return jsonify({
            'code': 200,
            'message': '同步成功',
            'data': {
                'total': len(all_domains),
                'added': added_count,
                'skipped': skipped_count
            }
        }), 200
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'同步失败: {str(e)}'
        }), 500
    finally:
        cursor.close()

@domains_bp.route('/notify', methods=['POST'])
@jwt_required
@role_required(['admin', 'operator'])
def trigger_domain_notify():
    """
    触发域名到期预警通知
    
    返回: {"code": 200, "message": "通知发送成功", "data": {"total": N, "expired": N, "warning": N}}
    """
    warning_days = current_app.config.get('DOMAIN_WARNING_DAYS', 30)
    webhook_url = current_app.config.get('WECHAT_WEBHOOK_URL', '')
    
    if not webhook_url:
        return jsonify({
            'code': 400,
            'message': '未配置企业微信 Webhook URL'
        }), 400
    
    db = get_db()
    cursor = db.cursor()
    try:
        # 查询即将过期或已过期的域名
        cursor.execute("""
            SELECT id, domain_name, owner, expire_date, 
                   DATEDIFF(expire_date, NOW()) as remaining_days
            FROM domains 
            WHERE expire_date IS NOT NULL 
              AND DATEDIFF(expire_date, NOW()) <= %s
            ORDER BY expire_date ASC
        """, (warning_days,))
        
        domains = cursor.fetchall()
        
        if not domains:
            return jsonify({
                'code': 200,
                'message': '没有需要通知的域名',
                'data': {'total': 0, 'expired': 0, 'warning': 0}
            }), 200
        
        # 发送通知
        success = send_domain_expiry_notification(webhook_url, domains)
        
        expired_count = sum(1 for d in domains if d.get('remaining_days', 0) <= 0)
        warning_count = len(domains) - expired_count
        
        if success:
            return jsonify({
                'code': 200,
                'message': '通知发送成功',
                'data': {
                    'total': len(domains),
                    'expired': expired_count,
                    'warning': warning_count
                }
            }), 200
        else:
            return jsonify({
                'code': 500,
                'message': '通知发送失败，请检查 webhook 配置或网络连接'
            }), 500
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'域名到期通知失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
