import re
import ipaddress
from urllib.parse import urlparse


def validate_ip(ip):
    """
    验证IP地址格式
    支持IPv4和IPv6
    """
    if not ip:
        return False
    try:
        ipaddress.ip_address(ip)
        return True
    except ValueError:
        return False


def validate_hostname(hostname):
    """
    验证主机名格式
    """
    if not hostname:
        return False
    # 主机名长度限制
    if len(hostname) > 255:
        return False
    # 主机名格式验证
    pattern = r'^[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$'
    if not re.match(pattern, hostname):
        return False
    # 检查每个标签是否以连字符开头或结尾
    labels = hostname.split('.')
    for label in labels:
        if label.startswith('-') or label.endswith('-'):
            return False
    return True


def validate_url(url):
    """
    验证URL格式
    """
    if not url:
        return False
    try:
        result = urlparse(url)
        # 检查协议
        if result.scheme not in ['http', 'https']:
            return False
        # 检查域名
        if not result.netloc:
            return False
        return True
    except:
        return False


def validate_port(port):
    """
    验证端口号
    """
    if not port:
        return False
    try:
        port_num = int(port)
        return 1 <= port_num <= 65535
    except ValueError:
        return False


def validate_domain(domain):
    """
    验证域名格式
    """
    if not domain:
        return False
    # 支持通配符域名
    if domain.startswith('*'):
        domain = domain[1:]
        if not domain.startswith('.'):
            return False
        domain = domain[1:]
    return validate_hostname(domain)


def validate_password(password):
    """
    验证密码强度
    至少6位
    """
    if not password:
        return False
    return len(password) >= 6


def validate_username(username):
    """
    验证用户名格式
    """
    if not username:
        return False
    # 用户名长度限制
    if len(username) < 3 or len(username) > 20:
        return False
    # 用户名只能包含字母、数字和下划线
    pattern = r'^[a-zA-Z0-9_]+$'
    return bool(re.match(pattern, username))


def validate_email(email):
    """
    验证邮箱格式
    """
    if not email:
        return False
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))


def validate_integer(value):
    """
    验证整数值
    """
    if value is None:
        return False
    try:
        int(value)
        return True
    except ValueError:
        return False


def validate_positive_integer(value):
    """
    验证正整数值
    """
    if not validate_integer(value):
        return False
    return int(value) > 0


def validate_string_length(value, min_len=0, max_len=255):
    """
    验证字符串长度
    """
    if not value:
        return min_len == 0
    return min_len <= len(value) <= max_len
