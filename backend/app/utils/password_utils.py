"""
密码加密工具模块
使用 bcrypt 算法安全地加密和验证密码
支持对称加密存储服务器密码等敏感信息
"""
import bcrypt
import os
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
import base64

# ============================================================
# WARNING: 以下密钥仅用于开发环境
# 生产环境必须通过 DATA_ENCRYPTION_KEY 环境变量设置新密钥
# 生成命令: python -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())"
# ============================================================
_DEV_FERNET_KEY = "ySYNdFtSyLpfGr0F9hptEErhTxLUllX5OR7QpZzrjwg="


def _resolve_encryption_key_string():
    raw = os.environ.get("DATA_ENCRYPTION_KEY")
    if raw:
        return raw
    if os.environ.get("FLASK_DEBUG", "").lower() in ("1", "true", "yes") or os.environ.get(
        "OPS_DEV_ENCRYPTION_FALLBACK", ""
    ).lower() in ("1", "true", "yes"):
        return _DEV_FERNET_KEY
    raise ValueError(
        "未设置 DATA_ENCRYPTION_KEY，无法加解密敏感数据。"
        "生产环境请配置 Fernet 密钥；本地开发可设置 FLASK_DEBUG=true 或 OPS_DEV_ENCRYPTION_FALLBACK=true（不安全）。"
    )


def _get_fernet():
    """获取 Fernet 实例：支持标准 Fernet 密钥或通过 PBKDF2 从任意字符串派生。"""
    key_str = _resolve_encryption_key_string()
    key_bytes = key_str.encode() if isinstance(key_str, str) else key_str
    try:
        decoded = base64.urlsafe_b64decode(key_bytes + b"=" * (4 - len(key_bytes) % 4))
    except Exception:
        decoded = b""
    if len(decoded) == 32:
        return Fernet(key_bytes)
    kdf = PBKDF2HMAC(
        algorithm=hashes.SHA256(),
        length=32,
        salt=b"ops-platform-salt",
        iterations=100000,
    )
    derived = base64.urlsafe_b64encode(kdf.derive(key_bytes))
    return Fernet(derived)


def hash_password(password: str) -> str:
    """
    加密密码（不可逆哈希）
    Args:
        password: 明文密码
    Returns:
        加密后的密码字符串
    """
    salt = bcrypt.gensalt()
    hashed = bcrypt.hashpw(password.encode('utf-8'), salt)
    return hashed.decode('utf-8')

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """
    验证密码
    支持 bcrypt 和 Werkzeug scrypt 两种格式
    Args:
        plain_password: 明文密码
        hashed_password: 加密后的密码
    Returns:
        密码是否匹配的布尔值
    """
    if not plain_password or not hashed_password:
        return False
    
    try:
        # 判断密码格式
        if hashed_password.startswith('scrypt:'):
            # Werkzeug scrypt 格式
            from werkzeug.security import check_password_hash
            return check_password_hash(hashed_password, plain_password)
        elif hashed_password.startswith('$2'):
            # bcrypt 格式 (以 $2a$, $2b$, $2y$ 开头)
            return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
        else:
            # 未知格式，尝试 bcrypt
            return bcrypt.checkpw(plain_password.encode('utf-8'), hashed_password.encode('utf-8'))
    except Exception:
        return False


def encrypt_data(data: str) -> str:
    """
    对称加密数据（可解密）
    用于加密服务器密码、阿里云AccessKey等需要解密查看的敏感信息
    
    Args:
        data: 明文数据
    Returns:
        加密后的数据（base64字符串）
    """
    if not data:
        return data
    try:
        f = _get_fernet()
        encrypted = f.encrypt(data.encode('utf-8'))
        return encrypted.decode('utf-8')
    except Exception as e:
        raise ValueError(f"数据加密失败: {str(e)}")


def decrypt_data(encrypted_data: str) -> str:
    """
    解密数据
    
    Args:
        encrypted_data: 加密后的数据
    Returns:
        解密后的明文
    """
    if not encrypted_data:
        return encrypted_data
    try:
        f = _get_fernet()
        decrypted = f.decrypt(encrypted_data.encode('utf-8'))
        return decrypted.decode('utf-8')
    except Exception as e:
        raise ValueError(f"数据解密失败: {str(e)}")
