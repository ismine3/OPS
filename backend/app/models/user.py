"""
用户模型 - 用户相关的数据库操作函数
"""
from ..utils.db import get_db
from ..utils.password_utils import hash_password, verify_password


def create_user(username, password, display_name, role='operator'):
    """
    创建用户
    
    Args:
        username: 用户名
        password: 明文密码
        display_name: 显示名称
        role: 角色 (admin/operator/viewer)
    
    Returns:
        新创建的用户ID
    """
    password_hash = hash_password(password)
    
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            """
            INSERT INTO users (username, password_hash, display_name, role, is_active, password_changed_at)
            VALUES (%s, %s, %s, %s, %s, NOW())
            """,
            (username, password_hash, display_name, role, True),
        )
        db.commit()
        return cursor.lastrowid


def get_user_by_username(username):
    """
    根据用户名查询用户
    
    Args:
        username: 用户名
    
    Returns:
        用户字典或None
    """
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM users WHERE username = %s",
            (username,)
        )
        return cursor.fetchone()


def get_user_by_id(user_id):
    """
    根据ID查询用户
    
    Args:
        user_id: 用户ID
    
    Returns:
        用户字典或None
    """
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            "SELECT * FROM users WHERE id = %s",
            (user_id,)
        )
        return cursor.fetchone()


def get_all_users():
    """
    获取所有用户
    
    Returns:
        用户列表
    """
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            """
            SELECT id, username, display_name, role, is_active, created_at, updated_at
            FROM users
            ORDER BY created_at DESC
            """
        )
        return cursor.fetchall()


def update_user(user_id, data):
    """
    更新用户信息
    
    Args:
        user_id: 用户ID
        data: 要更新的字段字典，可包含 display_name, role, is_active
    
    Returns:
        是否更新成功
    """
    allowed_fields = ['display_name', 'role', 'is_active']
    update_fields = {k: v for k, v in data.items() if k in allowed_fields}
    
    if not update_fields:
        return False
    
    db = get_db()
    with db.cursor() as cursor:
        set_clause = ', '.join([f"{field} = %s" for field in update_fields.keys()])
        values = list(update_fields.values()) + [user_id]
        
        cursor.execute(
            f"UPDATE users SET {set_clause} WHERE id = %s",
            values
        )
        db.commit()
        return cursor.rowcount > 0


def delete_user(user_id):
    """
    删除用户
    
    Args:
        user_id: 用户ID
    
    Returns:
        是否删除成功
    """
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            "DELETE FROM users WHERE id = %s",
            (user_id,)
        )
        db.commit()
        return cursor.rowcount > 0


def update_password(user_id, password_hash):
    """
    更新用户密码
    
    Args:
        user_id: 用户ID
        password_hash: 密码哈希值
    
    Returns:
        是否更新成功
    """
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            "UPDATE users SET password_hash = %s, password_changed_at = NOW() WHERE id = %s",
            (password_hash, user_id),
        )
        db.commit()
        return cursor.rowcount > 0
