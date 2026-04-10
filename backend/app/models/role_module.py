"""
角色模块授权模型 - 角色模块授权相关的数据库操作函数
"""
from ..utils.db import get_db


# 可授权模块定义
AVAILABLE_MODULES = [
    {'code': 'servers', 'name': '服务器管理'},
    {'code': 'services', 'name': '服务管理'},
    {'code': 'apps', 'name': '账号管理'},
    {'code': 'domains', 'name': '域名管理'},
    {'code': 'certs', 'name': '证书管理'},
    {'code': 'projects', 'name': '项目管理'},
    {'code': 'monitoring', 'name': '监控告警'},
    {'code': 'tasks', 'name': '定时任务'},
]


def get_modules_by_role(role):
    """
    查询某角色已授权的模块编码列表
    
    Args:
        role: 角色名称 (operator/viewer)
    
    Returns:
        模块编码列表，如 ['servers', 'services', ...]
    """
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            "SELECT module FROM role_modules WHERE role = %s ORDER BY module",
            (role,)
        )
        rows = cursor.fetchall()
        return [row['module'] for row in rows]


def set_role_modules(role, module_list):
    """
    设置某角色的模块授权（先删后插，事务内完成）
    
    Args:
        role: 角色名称 (operator/viewer)
        module_list: 模块编码列表
    
    Returns:
        是否设置成功
    """
    db = get_db()
    try:
        with db.cursor() as cursor:
            # 先删除该角色的所有模块授权
            cursor.execute(
                "DELETE FROM role_modules WHERE role = %s",
                (role,)
            )
            
            # 批量插入新的模块授权
            if module_list:
                values = [(role, module) for module in module_list]
                cursor.executemany(
                    "INSERT INTO role_modules (role, module) VALUES (%s, %s)",
                    values
                )
        
        db.commit()
        return True
    except Exception as e:
        db.rollback()
        raise e


def get_all_role_modules():
    """
    获取所有角色的模块授权配置
    
    Returns:
        角色模块授权字典，如 {'operator': ['servers', ...], 'viewer': [...]}
    """
    db = get_db()
    with db.cursor() as cursor:
        cursor.execute(
            "SELECT role, module FROM role_modules ORDER BY role, module"
        )
        rows = cursor.fetchall()
        
        result = {}
        for row in rows:
            role = row['role']
            module = row['module']
            if role not in result:
                result[role] = []
            result[role].append(module)
        
        return result


def get_available_modules():
    """
    返回所有可授权模块的定义列表
    
    Returns:
        模块定义列表，如 [{'code': 'servers', 'name': '服务器管理'}, ...]
    """
    return AVAILABLE_MODULES.copy()
