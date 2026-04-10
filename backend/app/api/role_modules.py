"""
角色模块授权管理 API
"""
from flask import Blueprint, request, jsonify, g
from ..utils.decorators import jwt_required, role_required
from ..models.role_module import (
    get_modules_by_role,
    set_role_modules,
    get_all_role_modules,
    get_available_modules
)
from ..utils.operation_log import log_operation

role_modules_bp = Blueprint('role_modules', __name__, url_prefix='/api/role-modules')


@role_modules_bp.route('', methods=['GET'])
@jwt_required
@role_required(['admin'])
def get_all_roles_modules():
    """
    获取所有角色的模块授权配置（admin only）
    
    返回: {
        'code': 200,
        'data': {
            'roles': {'operator': [...], 'viewer': [...]},
            'available_modules': [...]
        }
    }
    """
    # 获取所有角色的模块授权
    roles_modules = get_all_role_modules()
    
    # 获取可授权模块列表
    available_modules = get_available_modules()
    
    return jsonify({
        'code': 200,
        'data': {
            'roles': roles_modules,
            'available_modules': available_modules
        }
    })


@role_modules_bp.route('/<role>', methods=['GET'])
@jwt_required
@role_required(['admin'])
def get_role_modules(role):
    """
    获取指定角色的已授权模块（admin only）
    
    参数:
        role: 角色名称（operator/viewer）
        
    返回: {
        'code': 200,
        'data': {'role': 'operator', 'modules': [...]}
    }
    """
    # 验证角色
    if role not in ['operator', 'viewer']:
        return jsonify({
            'code': 400,
            'message': '无效的角色，只支持 operator 或 viewer'
        }), 400
    
    modules = get_modules_by_role(role)
    
    return jsonify({
        'code': 200,
        'data': {
            'role': role,
            'modules': modules
        }
    })


@role_modules_bp.route('/<role>', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_role_modules(role):
    """
    更新指定角色的模块授权（admin only）
    
    参数:
        role: 角色名称（operator/viewer）
        
    请求体: {'modules': ['servers', 'services', ...]}
    
    返回: {'code': 200, 'message': '更新成功'}
    """
    # 验证角色
    if role not in ['operator', 'viewer']:
        return jsonify({
            'code': 400,
            'message': '无效的角色，只支持 operator 或 viewer'
        }), 400
    
    data = request.get_json()
    
    if not data or 'modules' not in data:
        return jsonify({
            'code': 400,
            'message': '请求体必须包含 modules 字段'
        }), 400
    
    module_list = data.get('modules', [])
    
    # 验证模块列表格式
    if not isinstance(module_list, list):
        return jsonify({
            'code': 400,
            'message': 'modules 必须是数组格式'
        }), 400
    
    # 验证所有模块都是有效的
    available_codes = [m['code'] for m in get_available_modules()]
    invalid_modules = [m for m in module_list if m not in available_codes]
    
    if invalid_modules:
        return jsonify({
            'code': 400,
            'message': f'无效的模块编码: {", ".join(invalid_modules)}'
        }), 400
    
    try:
        set_role_modules(role, module_list)
        
        # 记录操作日志
        log_operation(
            module='role_modules',
            action='update',
            target_name=role,
            detail={'modules': module_list}
        )
        
        return jsonify({
            'code': 200,
            'message': '更新成功'
        })
    except Exception as e:
        return jsonify({
            'code': 500,
            'message': f'更新失败: {str(e)}'
        }), 500
