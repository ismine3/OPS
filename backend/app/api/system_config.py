"""系统配置 API - 内置定时任务参数管理（仅管理员可配置）"""
import logging

from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required
from ..utils.operation_log import log_operation
from ..utils.scheduler import reschedule_builtin_job, scheduler

system_config_bp = Blueprint("system_config", __name__, url_prefix="/api/system-config")

logger = logging.getLogger(__name__)

# 合法的配置键定义
VALID_CONFIG_KEYS = {
    'cert_auto_check_cron':        {'desc': 'SSL证书自动检测Cron表达式', 'builtin_job': 'builtin_cert_check_notify'},
    'ssl_warning_days':            {'desc': 'SSL证书到期预警天数',        'builtin_job': None},
    'domain_auto_notify_cron':     {'desc': '域名到期通知Cron表达式',    'builtin_job': 'builtin_domain_notify'},
    'domain_warning_days':         {'desc': '域名到期预警天数',          'builtin_job': None},
    'password_rotation_cron':      {'desc': '密码轮换检查Cron表达式',   'builtin_job': 'builtin_password_rotation'},
}


@system_config_bp.route('', methods=['GET'])
@jwt_required
@role_required(['admin'])
def get_system_config():
    """获取所有系统配置（仅管理员）"""
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT config_key, config_value, description FROM system_config ORDER BY id")
        rows = cursor.fetchall()

        result = {}
        for row in rows:
            result[row['config_key']] = {
                'value': row['config_value'],
                'description': row.get('description', '')
            }

        return jsonify({'code': 200, 'data': result})
    except Exception as e:
        return jsonify({'code': 500, 'message': f'获取系统配置失败: {str(e)}'}), 500
    finally:
        cursor.close()


@system_config_bp.route('', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_system_config():
    """更新系统配置（仅管理员），支持批量更新"""
    data = request.get_json(silent=True)
    if not data or not isinstance(data, dict):
        return jsonify({'code': 400, 'message': '请求体必须为 JSON 对象'}), 400

    db = get_db()
    cursor = db.cursor()
    updated_items = []

    try:
        for key, value in data.items():
            if key not in VALID_CONFIG_KEYS:
                return jsonify({'code': 400, 'message': f'无效的配置键: {key}'}), 400

            value_str = str(value).strip()
            if not value_str:
                return jsonify({'code': 400, 'message': f'{key} 的值不能为空'}), 400

            # 校验 cron 表达式格式（5段）
            cron_keys = ['cert_auto_check_cron', 'domain_auto_notify_cron', 'password_rotation_cron']
            if key in cron_keys:
                parts = value_str.split()
                if len(parts) != 5:
                    return jsonify({'code': 400, 'message': f'{key} Cron 表达式格式错误，需要5个字段：分 时 日 月 周'}), 400

            # 校验数值类型
            days_keys = ['ssl_warning_days', 'domain_warning_days']
            if key in days_keys:
                try:
                    days = int(value_str)
                    if days < 1 or days > 365:
                        return jsonify({'code': 400, 'message': f'{key} 必须在 1-365 之间'}), 400
                except ValueError:
                    return jsonify({'code': 400, 'message': f'{key} 必须为整数'}), 400

            cursor.execute(
                "UPDATE system_config SET config_value = %s WHERE config_key = %s",
                (value_str, key)
            )

            # 如果有对应的内置任务，尝试动态重调度
            config_def = VALID_CONFIG_KEYS[key]
            job_id = config_def['builtin_job']
            if job_id:
                if scheduler.running:
                    if not reschedule_builtin_job(job_id, value_str):
                        logger.warning("内置任务 %s 重调度失败，cron=%s", job_id, value_str)
                else:
                    logger.warning("调度器未运行，内置任务 %s 的 cron 变更将在下次重启后生效", job_id)

            updated_items.append(f"{key}={value_str}")

        db.commit()

        log_operation('系统配置', 'update', None, ','.join(updated_items))

        return jsonify({
            'code': 200,
            'message': '配置更新成功',
            'data': {'updated': updated_items}
        })
    except Exception as e:
        db.rollback()
        return jsonify({'code': 500, 'message': f'更新系统配置失败: {str(e)}'}), 500
    finally:
        cursor.close()
