"""
SSL证书检测工具模块
功能：SSL在线检测、阿里云证书同步、微信预警通知
"""

import ssl
import socket
import datetime
import math
import logging
import re
from typing import Dict, List, Optional

import requests
from cryptography import x509
from cryptography.hazmat.backends import default_backend
from flask import current_app

logger = logging.getLogger(__name__)

# 尝试导入阿里云SDK
try:
    from alibabacloud_cas20200407.client import Client as CasClient
    from alibabacloud_tea_openapi import models as open_api_models
    from alibabacloud_cas20200407 import models as cas_models
    from alibabacloud_tea_util import models as util_models
    ALIYUN_SDK_AVAILABLE = True
except ImportError:
    CasClient = None
    open_api_models = None
    cas_models = None
    util_models = None
    ALIYUN_SDK_AVAILABLE = False
    logger.warning("阿里云SDK未安装，阿里云证书功能不可用")


def _validate_domain(domain: str) -> bool:
    """验证域名格式"""
    if not domain or not isinstance(domain, str):
        return False
    if len(domain) > 255:
        return False
    # 域名正则：支持通配符、子域名、国际化域名等
    pattern = r'^(\*\.)?([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)*[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?$'
    return bool(re.match(pattern, domain))


def get_ssl_cert_info(domain: str, port: int = 443, timeout: int = 10) -> Optional[Dict]:
    """
    通过SSL连接获取证书信息，支持TLS版本降级
    
    Args:
        domain: 域名
        port: 端口，默认443
        timeout: 超时时间，默认10秒
        
    Returns:
        证书信息字典，失败返回None
        {
            'domain': str,
            'subject': str,
            'issuer': str,
            'not_before': datetime,
            'not_after': datetime,
            'valid_days': int,
            'remaining_days': int,
            'serial_number': str,
            'version': str,
            'has_expired': bool
        }
    """
    # 验证域名格式
    if not _validate_domain(domain):
        logger.error(f"无效的域名格式: {domain}")
        return None
    
    # 从配置获取超时时间
    try:
        timeout = current_app.config.get('SSL_CHECK_TIMEOUT', timeout)
    except RuntimeError:
        # 不在Flask应用上下文中
        pass
    
    # 尝试的TLS版本列表（从高到低，依次降级）
    tls_versions = [
        ssl.TLSVersion.TLSv1_3,
        ssl.TLSVersion.TLSv1_2,
        ssl.TLSVersion.TLSv1_1,
        ssl.TLSVersion.TLSv1
    ]

    # 用于记录最后一次异常，方便调试
    last_exception = None

    for tls_version in tls_versions:
        sock = None
        ssock = None
        try:
            # 创建SSL上下文，并设置最低允许的TLS版本
            context = ssl.create_default_context()
            context.minimum_version = tls_version

            # 建立TCP连接（每次TLS版本循环都新建socket连接）
            sock = socket.create_connection((domain, port), timeout=timeout)
            # 包装为SSL连接，传递server_hostname以支持SNI
            ssock = context.wrap_socket(sock, server_hostname=domain)
            # 获取DER格式证书并转换为PEM
            der_cert = ssock.getpeercert(binary_form=True)
            pem_cert = ssl.DER_cert_to_PEM_cert(der_cert)

            # 使用cryptography解析证书
            cert = x509.load_pem_x509_certificate(pem_cert.encode(), default_backend())

            # 提取时间信息（转换为naive datetime，便于存储）
            not_before = cert.not_valid_before_utc.replace(tzinfo=None)
            not_after = cert.not_valid_after_utc.replace(tzinfo=None)
            remaining_days = math.ceil((not_after - datetime.datetime.now()).total_seconds() / 86400)
            valid_days = (not_after - not_before).days

            # 提取主题和颁发者
            try:
                subject = {attr.oid._name: attr.value for attr in cert.subject}
            except (AttributeError, TypeError) as e:
                logger.warning(f"解析证书subject失败 {domain}: {type(e).__name__}: {str(e)}")
                subject = {}
            
            try:
                issuer = {attr.oid._name: attr.value for attr in cert.issuer}
            except (AttributeError, TypeError) as e:
                logger.warning(f"解析证书issuer失败 {domain}: {type(e).__name__}: {str(e)}")
                issuer = {}

            logger.debug(f"成功获取 {domain} 证书信息 (TLS {tls_version.name})")
            return {
                'domain': domain,
                'subject': subject.get('commonName', domain),
                'issuer': issuer.get('organizationName', 'Unknown'),
                'not_before': not_before,
                'not_after': not_after,
                'valid_days': valid_days,
                'remaining_days': remaining_days,
                'serial_number': str(cert.serial_number),
                'version': str(cert.version),
                'has_expired': remaining_days <= 0
            }

        except Exception as e:
            last_exception = e
            logger.debug(f"{domain} 尝试 TLS {tls_version.name} 失败: {type(e).__name__}: {str(e)}")
            continue  # 尝试下一个TLS版本
        finally:
            # 确保socket被关闭
            if ssock:
                try:
                    ssock.close()
                except Exception:
                    pass
            if sock:
                try:
                    sock.close()
                except Exception:
                    pass

    # 所有版本都失败
    logger.error(f"获取 {domain} 证书信息失败，已尝试所有TLS版本。最后错误: {type(last_exception).__name__}: {last_exception}")
    return None


def scan_aliyun_certs(access_key_id: str, access_key_secret: str, account_name: str = '') -> List[Dict]:
    """
    扫描阿里云账号的所有SSL证书
    
    Args:
        access_key_id: 阿里云AccessKey ID
        access_key_secret: 阿里云AccessKey Secret
        account_name: 账号名称（用于日志记录）
        
    Returns:
        证书信息列表
    """
    certs = []
    
    if not ALIYUN_SDK_AVAILABLE:
        raise RuntimeError("阿里云SDK未安装")

    if not access_key_id or not access_key_secret:
        raise ValueError("阿里云AccessKey不能为空")
    
    try:
        # 创建阿里云客户端配置
        config = open_api_models.Config(
            access_key_id=access_key_id,
            access_key_secret=access_key_secret
        )
        config.endpoint = 'cas.aliyuncs.com'
        client = CasClient(config)
        
        logger.info(f"开始扫描阿里云账号: {account_name or '未命名账号'}")
        
        # 使用ListCertificates查询证书列表
        list_request = cas_models.ListCertificatesRequest()
        runtime = util_models.RuntimeOptions()
        
        response = client.list_certificates_with_options(list_request, runtime)
        
        if response is None:
            logger.warning(f"账号 {account_name} 未获取到证书列表")
            return certs
        
        # 检查状态码
        if hasattr(response, 'status_code') and response.status_code != 200:
            logger.warning(f"账号 {account_name} 查询证书列表失败，状态码: {response.status_code}")
            return certs
        
        # 解析返回结果
        certificate_list = []
        if hasattr(response, 'body'):
            body = response.body
            if hasattr(body, 'certificate_list'):
                certificate_list = body.certificate_list
            elif hasattr(body, 'CertificateList'):
                certificate_list = body.CertificateList
        elif isinstance(response, dict):
            body = response.get('body', {})
            certificate_list = body.get('certificate_list', []) or body.get('CertificateList', [])
        
        logger.info(f"账号 {account_name} 共发现 {len(certificate_list)} 个证书")
        
        for cert_info in certificate_list:
            try:
                # 提取证书信息（支持snake_case和PascalCase）
                if hasattr(cert_info, 'common_name'):
                    domain = getattr(cert_info, 'common_name', 'unknown')
                    not_after_timestamp = getattr(cert_info, 'not_after', None)
                    not_before_timestamp = getattr(cert_info, 'not_before', None)
                    issuer = getattr(cert_info, 'issuer', 'Unknown')
                    cert_id = (getattr(cert_info, 'certificate_id', None)
                               or getattr(cert_info, 'cert_id', None)
                               or getattr(cert_info, 'id', None) or '')
                elif hasattr(cert_info, 'CommonName'):
                    domain = getattr(cert_info, 'CommonName', 'unknown')
                    not_after_timestamp = getattr(cert_info, 'NotAfter', None)
                    not_before_timestamp = getattr(cert_info, 'NotBefore', None)
                    issuer = getattr(cert_info, 'Issuer', 'Unknown')
                    cert_id = (getattr(cert_info, 'CertificateId', None)
                               or getattr(cert_info, 'CertId', None)
                               or getattr(cert_info, 'Id', None) or '')
                else:
                    domain = cert_info.get('common_name', cert_info.get('CommonName', 'unknown'))
                    not_after_timestamp = cert_info.get('not_after', cert_info.get('NotAfter'))
                    not_before_timestamp = cert_info.get('not_before', cert_info.get('NotBefore'))
                    issuer = cert_info.get('issuer', cert_info.get('Issuer', 'Unknown'))
                    cert_id = (cert_info.get('certificate_id') or cert_info.get('CertificateId')
                               or cert_info.get('cert_id') or cert_info.get('CertId')
                               or cert_info.get('id') or cert_info.get('Id') or '')
                
                if not not_after_timestamp or not not_before_timestamp:
                    logger.warning(f"证书缺少有效期信息: {domain}")
                    continue
                
                # 转换时间格式（时间戳转datetime）
                try:
                    not_after = datetime.datetime.fromtimestamp(not_after_timestamp / 1000)
                    not_before = datetime.datetime.fromtimestamp(not_before_timestamp / 1000)
                except ValueError as e:
                    logger.warning(f"时间格式转换失败: {e}")
                    continue
                
                valid_days = (not_after - not_before).days
                remaining_days = math.ceil((not_after - datetime.datetime.now()).total_seconds() / 86400)
                
                # 构建证书信息
                cert_data = {
                    'domain': domain,
                    'subject': domain,
                    'issuer': issuer,
                    'not_before': not_before,
                    'not_after': not_after,
                    'valid_days': valid_days,
                    'remaining_days': remaining_days,
                    'serial_number': '',
                    'version': '',
                    'has_expired': remaining_days <= 0,
                    'cert_id': cert_id,
                    'aliyun_account': account_name
                }
                
                certs.append(cert_data)
                logger.info(f"发现阿里云证书: {domain} (账号: {account_name}, ID: {cert_id}, 类型: {type(cert_id).__name__})")
                
            except Exception as e:
                logger.error(f"处理账号 {account_name} 的证书失败: {type(e).__name__}: {str(e)}")
                continue
        
        logger.info(f"阿里云证书扫描完成，共发现 {len(certs)} 个有效证书")
        return certs
        
    except Exception as e:
        error_msg = f"扫描阿里云证书失败: {type(e).__name__}: {str(e)}"
        logger.error(error_msg)
        raise RuntimeError(error_msg) from e


def send_wechat_notification(webhook_url: str, certs: List[Dict]) -> bool:
    """
    通过企业微信机器人发送证书预警通知
    
    Args:
        webhook_url: 企业微信机器人webhook地址
        certs: 证书列表，每个证书包含domain, project_name, remaining_days, cert_expire_time等字段
        
    Returns:
        发送成功返回True，否则返回False
    """
    if not certs:
        logger.info("没有需要通知的证书")
        return False
    
    if not webhook_url:
        logger.error("webhook_url不能为空")
        return False
    
    total_count = len(certs)
    expired_count = sum(1 for cert in certs if cert.get('remaining_days', 0) <= 0)
    warning_count = total_count - expired_count
    
    content = f"""## SSL证书预警通知

**统计信息**：
- 即将过期证书：{warning_count} 个
- 已过期证书：{expired_count} 个
---
"""
    
    for cert in certs:
        remaining_days = cert.get('remaining_days', 0)
        cert_expire_time = cert.get('cert_expire_time')
        
        if isinstance(cert_expire_time, datetime.datetime):
            expire_str = cert_expire_time.strftime('%Y-%m-%d %H:%M:%S')
        else:
            expire_str = str(cert_expire_time) if cert_expire_time else '未知'
        
        if remaining_days <= 0:
            status = "[EXPIRED] 已过期"
        elif remaining_days <= 3:
            status = "[URGENT] 紧急"
        elif remaining_days <= 7:
            status = "[WARNING] 严重"
        elif remaining_days <= 15:
            status = "[NORMAL] 提醒"
        else:
            status = "[INFO] 注意"
        
        content += f"""
**域名**：{cert.get('domain', '未知')}
**项目**：{cert.get('project_name', '未指定')}
**状态**：{status}
**剩余天数**：{remaining_days} 天
**过期时间**：{expire_str}
---
"""
    
    data = {
        "msgtype": "markdown",
        "markdown": {
            "content": content.strip()
        }
    }
    
    # 获取重试次数
    try:
        max_retries = current_app.config.get('NOTIFY_MAX_RETRIES', 3)
    except RuntimeError:
        max_retries = 3
    
    for attempt in range(max_retries):
        try:
            response = requests.post(webhook_url, json=data, timeout=10)
            response.raise_for_status()
            result = response.json()
            if result.get('errcode') == 0:
                logger.info("微信通知发送成功")
                return True
            else:
                logger.error(f"微信通知发送失败 (尝试 {attempt + 1}/{max_retries}): {result}")
        except Exception as e:
            logger.error(f"发送微信通知异常 (尝试 {attempt + 1}/{max_retries}): {str(e)}")
        
        if attempt < max_retries - 1:
            import time
            time.sleep(2)
    
    logger.error(f"微信通知发送失败，已重试 {max_retries} 次")
    return False


def send_domain_expiry_notification(webhook_url: str, domains: List[Dict]) -> bool:
    """
    通过企业微信机器人发送域名到期预警通知
    
    Args:
        webhook_url: 企业微信机器人webhook地址
        domains: 域名列表，每个域名包含domain_name, owner, expire_date, remaining_days等字段
        
    Returns:
        发送成功返回True，否则返回False
    """
    if not domains:
        logger.info("没有需要通知的域名")
        return False

    if not webhook_url:
        logger.error("webhook_url不能为空")
        return False

    total_count = len(domains)
    expired_count = sum(1 for domain in domains if domain.get('remaining_days', 0) <= 0)
    warning_count = total_count - expired_count

    content = f"""## 域名到期预警通知

**统计信息**：
- 即将过期域名：{warning_count} 个
- 已过期域名：{expired_count} 个
---
"""

    for domain in domains:
        remaining_days = domain.get('remaining_days', 0)
        expire_date = domain.get('expire_date')

        if isinstance(expire_date, datetime.datetime):
            expire_str = expire_date.strftime('%Y-%m-%d %H:%M:%S')
        elif isinstance(expire_date, datetime.date):
            expire_str = str(expire_date)
        else:
            expire_str = str(expire_date) if expire_date else '未知'

        if remaining_days <= 0:
            status = "[EXPIRED] 已过期"
        elif remaining_days <= 3:
            status = "[URGENT] 紧急"
        elif remaining_days <= 7:
            status = "[WARNING] 严重"
        elif remaining_days <= 15:
            status = "[NORMAL] 提醒"
        else:
            status = "[INFO] 注意"

        content += f"""
**域名**：{domain.get('domain_name', '未知')}
**所有者**：{domain.get('owner', '未指定')}
**状态**：{status}
**剩余天数**：{remaining_days} 天
**到期时间**：{expire_str}
---
"""

    data = {
        "msgtype": "markdown",
        "markdown": {
            "content": content.strip()
        }
    }

    # 获取重试次数
    try:
        max_retries = current_app.config.get('NOTIFY_MAX_RETRIES', 3)
    except RuntimeError:
        max_retries = 3

    for attempt in range(max_retries):
        try:
            response = requests.post(webhook_url, json=data, timeout=10)
            response.raise_for_status()
            result = response.json()
            if result.get('errcode') == 0:
                logger.info("域名到期通知发送成功")
                return True
            else:
                logger.error(f"域名到期通知发送失败 (尝试 {attempt + 1}/{max_retries}): {result}")
        except Exception as e:
            logger.error(f"发送域名到期通知异常 (尝试 {attempt + 1}/{max_retries}): {str(e)}")

        if attempt < max_retries - 1:
            import time
            time.sleep(2)

    logger.error(f"域名到期通知发送失败，已重试 {max_retries} 次")
    return False


def download_aliyun_cert(access_key_id: str, access_key_secret: str, cert_id) -> Optional[Dict]:
    """
    从阿里云下载证书文件（证书内容+私钥内容）
    调用 GetUserCertificateDetail API

    Args:
        access_key_id: 阿里云AccessKey ID
        access_key_secret: 阿里云AccessKey Secret
        cert_id: 阿里云证书ID

    Returns:
        {'cert': 'PEM证书内容', 'key': 'PEM私钥内容'} 或 None
    """
    if not ALIYUN_SDK_AVAILABLE:
        logger.error("阿里云SDK未安装，无法下载证书文件")
        return None

    if not access_key_id or not access_key_secret or not cert_id:
        logger.error("下载证书参数不完整")
        return None

    logger.info(f"开始下载阿里云证书: cert_id={cert_id}")

    try:
        # 创建阿里云客户端配置
        config = open_api_models.Config(
            access_key_id=access_key_id,
            access_key_secret=access_key_secret
        )
        config.endpoint = 'cas.aliyuncs.com'
        client = CasClient(config)

        # 构建请求（兼容不同 SDK 版本的参数名）
        try:
            detail_request = cas_models.GetUserCertificateDetailRequest(
                cert_id=int(cert_id)
            )
        except (TypeError, ValueError):
            try:
                detail_request = cas_models.GetUserCertificateDetailRequest(
                    certificate_id=int(cert_id)
                )
            except (TypeError, ValueError):
                logger.error(f"无法构建证书详情请求: cert_id={cert_id}")
                return None
        runtime = util_models.RuntimeOptions()

        # 调用API
        response = client.get_user_certificate_detail_with_options(detail_request, runtime)

        if response is None:
            logger.warning(f"获取证书详情失败: cert_id={cert_id}")
            return None

        # 检查状态码
        if hasattr(response, 'status_code') and response.status_code != 200:
            logger.warning(f"获取证书详情失败，状态码: {response.status_code}")
            return None

        # 调试：打印响应结构
        if hasattr(response, 'body'):
            body = response.body
            body_attrs = [attr for attr in dir(body) if not attr.startswith('_')]
            logger.info(f"证书详情响应 body 属性: {body_attrs}")
            # 打印所有非空属性值的前100字符
            for attr in body_attrs:
                val = getattr(body, attr, None)
                if val and not callable(val):
                    val_str = str(val)[:100]
                    logger.info(f"  body.{attr} = {val_str}")
        else:
            logger.info(f"证书详情响应类型: {type(response)}, 内容: {str(response)[:500]}")

        # 解析返回结果（兼容snake_case和PascalCase）
        cert_content = None
        key_content = None

        if hasattr(response, 'body'):
            body = response.body
            # 尝试获取证书内容 - 扩展属性名匹配
            for attr in ['certificate', 'Certificate', 'cert', 'Cert', 'cert_body', 'CertBody']:
                if hasattr(body, attr) and getattr(body, attr):
                    cert_content = getattr(body, attr)
                    logger.info(f"找到证书内容属性: body.{attr}")
                    break

            # 尝试获取私钥内容 - 扩展属性名匹配
            for attr in ['private_key', 'PrivateKey', 'key', 'Key', 'encrypt_private_key', 'EncryptPrivateKey']:
                if hasattr(body, attr) and getattr(body, attr):
                    key_content = getattr(body, attr)
                    logger.info(f"找到私钥内容属性: body.{attr}")
                    break

            # 如果 body 支持 to_map()，也尝试从 dict 解析
            if not cert_content and hasattr(body, 'to_map'):
                body_dict = body.to_map()
                logger.info(f"body.to_map() keys: {list(body_dict.keys())}")
                cert_content = (body_dict.get('Certificate') or body_dict.get('certificate')
                                or body_dict.get('Cert') or body_dict.get('cert'))
                key_content = (body_dict.get('PrivateKey') or body_dict.get('private_key')
                               or body_dict.get('Key') or body_dict.get('key'))
        elif isinstance(response, dict):
            body = response.get('body', {})
            cert_content = body.get('certificate') or body.get('Certificate')
            key_content = body.get('private_key') or body.get('PrivateKey')

        if not cert_content:
            logger.warning(f"证书内容为空: cert_id={cert_id}")
            return None

        logger.info(f"成功下载阿里云证书: cert_id={cert_id}")
        return {
            'cert': cert_content,
            'key': key_content
        }

    except Exception as e:
        logger.error(f"下载阿里云证书失败: cert_id={cert_id}, error={type(e).__name__}: {str(e)}")
        return None
