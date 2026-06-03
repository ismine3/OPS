"""定时任务调度器"""
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import subprocess
import datetime
import pymysql
import os
import threading
import math
import logging
import socket

from .script_runner import run_script_file, run_custom_command

logger = logging.getLogger(__name__)

# 全局调度器实例
scheduler = BackgroundScheduler()


def get_db_config(app):
    """从 app.config 提取数据库配置字典"""
    return {
        'host': app.config.get('DB_HOST', 'localhost'),
        'port': app.config.get('DB_PORT', 3306),
        'user': app.config.get('DB_USER', 'root'),
        'password': app.config.get('DB_PASSWORD', ''),
        'database': app.config.get('DB_NAME', 'ops_platform'),
        'charset': 'utf8mb4',
        'cursorclass': pymysql.cursors.DictCursor
    }


def get_db_connection(db_config):
    """获取独立的数据库连接（用于调度器回调）"""
    return pymysql.connect(**db_config)


def execute_script(task_id, script_path, db_config, execute_command=None, task_dir=None):
    """
    执行脚本并记录日志
    在子进程中执行 Python 脚本，捕获输出并记录到数据库
    
    Args:
        task_id: 任务ID
        script_path: 脚本路径（向后兼容）
        db_config: 数据库配置
        execute_command: 自定义执行命令（可选）
        task_dir: 任务文件目录（可选）
    """
    def run():
        conn = None
        cursor = None
        log_id = None
        start_time = datetime.datetime.now()
        
        try:
            conn = get_db_connection(db_config)
            cursor = conn.cursor()
            
            # 创建任务日志记录
            cursor.execute("""
                INSERT INTO task_logs (task_id, status, start_time, triggered_by)
                VALUES (%s, %s, %s, %s)
            """, (task_id, 'running', start_time, 'schedule'))
            conn.commit()
            log_id = cursor.lastrowid
            
            # 更新任务的最后运行时间
            cursor.execute("""
                UPDATE scheduled_tasks 
                SET last_run_at = %s
                WHERE id = %s
            """, (start_time, task_id))
            conn.commit()
            
            try:
                # 优先使用自定义执行命令
                if execute_command and task_dir:
                    result = run_custom_command(execute_command, task_dir, timeout=300)
                elif script_path:
                    result = run_script_file(script_path, db_config=db_config, timeout=300)
                else:
                    raise ValueError("任务没有配置执行命令或脚本路径")
            except (FileNotFoundError, RuntimeError, ValueError) as e:
                end_time = datetime.datetime.now()
                err = str(e)
                cursor.execute(
                    """
                    UPDATE task_logs 
                    SET status = %s, end_time = %s, error_message = %s
                    WHERE id = %s
                    """,
                    ("failed", end_time, err, log_id),
                )
                cursor.execute(
                    """
                    UPDATE scheduled_tasks 
                    SET last_status = %s, last_output = %s
                    WHERE id = %s
                    """,
                    ("failed", err[:500], task_id),
                )
                conn.commit()
                return

            end_time = datetime.datetime.now()

            if result.returncode == 0:
                status = "success"
                output = result.stdout if result.stdout else "执行成功，无输出"
                error_message = None
            else:
                status = "failed"
                output = result.stdout if result.stdout else ""
                error_message = result.stderr if result.stderr else "执行失败，无错误信息"
            
            # 更新任务日志
            cursor.execute("""
                UPDATE task_logs 
                SET status = %s, end_time = %s, output = %s, error_message = %s
                WHERE id = %s
            """, (status, end_time, output, error_message, log_id))
            
            # 更新任务状态
            cursor.execute("""
                UPDATE scheduled_tasks 
                SET last_status = %s, last_output = %s
                WHERE id = %s
            """, (status, output[:500] if output else None, task_id))
            
            conn.commit()
            
        except subprocess.TimeoutExpired:
            end_time = datetime.datetime.now()
            error_message = '脚本执行超时（超过300秒）'
            if cursor and conn:
                cursor.execute("""
                    UPDATE task_logs 
                    SET status = %s, end_time = %s, error_message = %s
                    WHERE id = %s
                """, ('failed', end_time, error_message, log_id))
                cursor.execute("""
                    UPDATE scheduled_tasks 
                    SET last_status = %s, last_output = %s
                    WHERE id = %s
                """, ('failed', error_message, task_id))
                conn.commit()
                
        except Exception as e:
            end_time = datetime.datetime.now()
            error_message = str(e)
            if cursor and conn:
                try:
                    if log_id:
                        cursor.execute("""
                            UPDATE task_logs 
                            SET status = %s, end_time = %s, error_message = %s
                            WHERE id = %s
                        """, ('failed', end_time, error_message, log_id))
                    cursor.execute("""
                        UPDATE scheduled_tasks 
                        SET last_status = %s, last_output = %s
                        WHERE id = %s
                    """, ('failed', error_message[:500], task_id))
                    conn.commit()
                except:
                    pass
        finally:
            if cursor:
                cursor.close()
            if conn:
                conn.close()
    
    # 在新线程中执行
    thread = threading.Thread(target=run)
    thread.daemon = True
    thread.start()


def _create_cron_trigger(cron_expression):
    """
    解析 5 段 Cron 表达式并创建 CronTrigger
    
    Args:
        cron_expression: "分 时 日 月 周" 格式的 Cron 表达式
    Returns:
        CronTrigger 实例
    Raises:
        ValueError: Cron 表达式格式错误
    """
    parts = cron_expression.split()
    if len(parts) != 5:
        raise ValueError("Cron 表达式格式错误，需要5个字段：分 时 日 月 周")
    minute, hour, day, month, day_of_week = parts
    return CronTrigger(
        minute=minute,
        hour=hour,
        day=day,
        month=month,
        day_of_week=day_of_week
    )


def add_task_to_scheduler(task_id, script_path, cron_expression, db_config, execute_command=None, task_dir=None):
    """
    添加任务到调度器
    cron_expression 格式: "分 时 日 月 周"（5个字段）
    
    Args:
        task_id: 任务ID
        script_path: 脚本路径（向后兼容）
        cron_expression: Cron表达式
        db_config: 数据库配置
        execute_command: 自定义执行命令（可选）
        task_dir: 任务文件目录（可选）
    """
    try:
        # 解析 cron 表达式
        trigger = _create_cron_trigger(cron_expression)
        
        # 移除已存在的任务
        job_id = f'task_{task_id}'
        if scheduler.get_job(job_id):
            scheduler.remove_job(job_id)
        
        # 添加新任务
        scheduler.add_job(
            func=execute_script,
            trigger=trigger,
            id=job_id,
            args=[task_id, script_path, db_config, execute_command, task_dir],
            replace_existing=True
        )
        
        return True
    except Exception as e:
        logger.exception("添加任务到调度器失败: %s", e)
        return False


def remove_task_from_scheduler(task_id):
    """从调度器移除任务"""
    try:
        job_id = f'task_{task_id}'
        if scheduler.get_job(job_id):
            scheduler.remove_job(job_id)
            return True
        return False
    except Exception as e:
        logger.exception("从调度器移除任务失败: %s", e)
        return False


def init_scheduler(app):
    """初始化调度器，从数据库加载所有活跃任务"""
    db_config = get_db_config(app)
    
    try:
        conn = get_db_connection(db_config)
        cursor = conn.cursor()
        
        # 查询所有活跃的任务，包含新字段
        cursor.execute("""
            SELECT id, script_path, cron_expression, execute_command, script_files
            FROM scheduled_tasks
            WHERE is_active = TRUE
        """)
        
        tasks = cursor.fetchall()
        
        # 获取上传目录
        upload_folder = app.config.get('UPLOAD_FOLDER', 'uploads')
        scripts_dir = os.path.join(upload_folder, 'scripts')
        
        # 添加所有活跃任务到调度器
        for task in tasks:
            task_id = task['id']
            script_path = task['script_path']
            execute_command = task['execute_command']
            script_files = task['script_files']
            
            # 确定任务目录
            task_dir = os.path.join(scripts_dir, str(task_id))
            
            # 判断是否可以使用新逻辑
            if execute_command and task_dir and os.path.isdir(task_dir):
                # 使用自定义命令
                add_task_to_scheduler(
                    task_id,
                    script_path,
                    task['cron_expression'],
                    db_config,
                    execute_command,
                    task_dir
                )
                logger.info("已加载定时任务: %s (使用自定义命令: %s)", task_id, execute_command)
            elif script_path and os.path.exists(script_path):
                # 向后兼容：使用单文件模式
                add_task_to_scheduler(
                    task_id,
                    script_path,
                    task['cron_expression'],
                    db_config
                )
                logger.info("已加载定时任务: %s", task_id)
            else:
                logger.warning("任务 %s 的脚本文件不存在且没有自定义命令，跳过", task_id)
        
        cursor.close()
        conn.close()
        
        # 构建 app_config 字典（用于内置任务回调）
        app_config = {
            'wechat_webhook_url': app.config.get('WECHAT_WEBHOOK_URL', ''),
            'ssl_check_timeout': app.config.get('SSL_CHECK_TIMEOUT', 10),
            'password_rotation_length': app.config.get('PASSWORD_ROTATION_LENGTH', 16)
        }
        
        # 尝试从 system_config 表读取 Cron 表达式（优先于环境变量）
        cert_cron_from_db = None
        domain_cron_from_db = None
        pw_cron_from_db = None
        conn2 = None
        cursor2 = None
        try:
            conn2 = get_db_connection(db_config)
            cursor2 = conn2.cursor()
            cursor2.execute("SELECT config_key, config_value FROM system_config")
            for row in cursor2.fetchall():
                if row['config_key'] == 'cert_auto_check_cron':
                    cert_cron_from_db = row['config_value']
                elif row['config_key'] == 'domain_auto_notify_cron':
                    domain_cron_from_db = row['config_value']
                elif row['config_key'] == 'password_rotation_cron':
                    pw_cron_from_db = row['config_value']
        except Exception as e:
            logger.warning("读取 system_config 表失败，将使用环境变量默认值: %s", e)
        finally:
            if cursor2:
                cursor2.close()
            if conn2:
                conn2.close()
        
        # 注册内置定时任务：SSL证书自动检测+通知
        cert_cron = cert_cron_from_db or app.config.get('CERT_AUTO_CHECK_CRON', '0 8 * * *')
        try:
            cert_trigger = _create_cron_trigger(cert_cron)
            
            # 移除已存在的任务
            if scheduler.get_job('builtin_cert_check_notify'):
                scheduler.remove_job('builtin_cert_check_notify')
            
            scheduler.add_job(
                func=auto_cert_check_and_notify,
                trigger=cert_trigger,
                id='builtin_cert_check_notify',
                args=[db_config, app_config],
                replace_existing=True
            )
            logger.info("已注册内置任务: SSL证书自动检测+通知 (cron: %s)", cert_cron)
        except Exception as e:
            logger.exception("注册SSL证书自动检测任务失败: %s", e)
        
        # 注册内置定时任务：域名到期自动通知
        domain_cron = domain_cron_from_db or app.config.get('DOMAIN_AUTO_NOTIFY_CRON', '0 8 * * *')
        try:
            domain_trigger = _create_cron_trigger(domain_cron)
            
            # 移除已存在的任务
            if scheduler.get_job('builtin_domain_notify'):
                scheduler.remove_job('builtin_domain_notify')
            
            scheduler.add_job(
                func=auto_domain_notify,
                trigger=domain_trigger,
                id='builtin_domain_notify',
                args=[db_config, app_config],
                replace_existing=True
            )
            logger.info("已注册内置任务: 域名到期自动通知 (cron: %s)", domain_cron)
        except Exception as e:
            logger.exception("注册域名到期自动通知任务失败: %s", e)
        
        # 注册内置定时任务：服务器密码定期轮换
        password_rotation_cron = pw_cron_from_db or app.config.get('PASSWORD_ROTATION_CHECK_CRON', '0 3 * * *')
        try:
            pr_trigger = _create_cron_trigger(password_rotation_cron)
            
            # 移除已存在的任务
            if scheduler.get_job('builtin_password_rotation'):
                scheduler.remove_job('builtin_password_rotation')
            
            scheduler.add_job(
                func=auto_password_rotation,
                trigger=pr_trigger,
                id='builtin_password_rotation',
                args=[db_config, app_config],
                replace_existing=True
            )
            logger.info("已注册内置任务: 服务器密码定期轮换 (cron: %s)", password_rotation_cron)
        except Exception as e:
            logger.exception("注册服务器密码定期轮换任务失败: %s", e)
        
        # 启动调度器
        if not scheduler.running:
            scheduler.start()
            logger.info("定时任务调度器已启动")
        
        # 将 db_config 存储到调度器，供后续使用
        scheduler.db_config = db_config
        
    except Exception as e:
        logger.exception(
            "初始化调度器失败（定时任务将不可用）: DB_HOST=%s DB_PORT=%s DB_NAME=%s | %s",
            app.config.get("DB_HOST"),
            app.config.get("DB_PORT"),
            app.config.get("DB_NAME"),
            e,
        )


def get_scheduler_db_config():
    """获取调度器的数据库配置"""
    return getattr(scheduler, 'db_config', None)


def reschedule_builtin_job(job_id, cron_expression):
    """
    运行时重调度内置任务的 Cron 触发器
    
    Args:
        job_id: 内置任务 job ID（如 builtin_cert_check_notify）
        cron_expression: 5段 Cron 表达式 "分 时 日 月 周"
    Returns:
        bool: 是否成功
    """
    try:
        trigger = _create_cron_trigger(cron_expression)

        scheduler.reschedule_job(job_id, trigger=trigger)
        logger.info("已重调度内置任务 %s, cron=%s", job_id, cron_expression)
        return True
    except Exception as e:
        logger.exception("重调度内置任务 %s 失败: %s", job_id, e)
        return False


def get_effective_config(db_config, config_key, fallback=None):
    """
    从 system_config 表读取配置值，不存在时返回 fallback
    供内置任务回调函数在运行时动态读取
    """
    conn = None
    cursor = None
    try:
        conn = get_db_connection(db_config)
        cursor = conn.cursor()
        cursor.execute(
            "SELECT config_value FROM system_config WHERE config_key = %s",
            (config_key,)
        )
        row = cursor.fetchone()
        if row:
            return row['config_value']
        return fallback
    except Exception as e:
        logger.warning("读取系统配置 %s 失败: %s", config_key, e)
        return fallback
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


def auto_cert_check_and_notify(db_config, app_config):
    """
    自动SSL证书检测和通知回调函数
    不在Flask应用上下文中执行，从 app_config 读取配置
    """
    import ssl
    
    conn = None
    cursor = None
    
    try:
        conn = get_db_connection(db_config)
        cursor = conn.cursor()
        
        # 查询所有 cert_type=0 的证书域名（在线检测类型）
        cursor.execute("""
            SELECT id, domain FROM ssl_certificates 
            WHERE cert_type = 0 AND domain IS NOT NULL AND domain != ''
        """)
        certs = cursor.fetchall()
        
        logger.info(f"开始自动检测 {len(certs)} 个证书")
        
        # 对每个域名进行SSL证书检测
        for cert in certs:
            try:
                # 直接使用 ssl 模块获取证书信息
                timeout = app_config.get('ssl_check_timeout', 10)
                context = ssl.create_default_context()
                
                # 尝试 TLS 版本降级
                tls_versions = [
                    ssl.TLSVersion.TLSv1_3,
                    ssl.TLSVersion.TLSv1_2,
                    ssl.TLSVersion.TLSv1_1,
                    ssl.TLSVersion.TLSv1
                ]
                
                cert_info = None
                last_exception = None
                
                for tls_version in tls_versions:
                    sock = None
                    ssock = None
                    try:
                        context.minimum_version = tls_version
                        sock = socket.create_connection((cert['domain'], 443), timeout=timeout)
                        ssock = context.wrap_socket(sock, server_hostname=cert['domain'])
                        
                        from cryptography import x509
                        from cryptography.hazmat.backends import default_backend
                        
                        der_cert = ssock.getpeercert(binary_form=True)
                        pem_cert = ssl.DER_cert_to_PEM_cert(der_cert)
                        x509_cert = x509.load_pem_x509_certificate(pem_cert.encode(), default_backend())
                        
                        not_after = x509_cert.not_valid_after_utc.replace(tzinfo=None)
                        remaining_days = math.ceil((not_after - datetime.datetime.now()).total_seconds() / 86400)
                        
                        cert_info = {
                            'not_after': not_after,
                            'remaining_days': remaining_days
                        }
                        break
                    except Exception as e:
                        last_exception = e
                    finally:
                        if ssock:
                            try:
                                ssock.close()
                            except:
                                pass
                        if sock:
                            try:
                                sock.close()
                            except:
                                pass
                
                if cert_info:
                    # 计算三值状态: '已过期' | '即将过期' | '正常'
                    warning_days_raw = get_effective_config(db_config, 'ssl_warning_days', '30')
                    warning_days = int(warning_days_raw) if warning_days_raw else 30
                    remaining = cert_info['remaining_days']
                    if remaining <= 0:
                        cert_status = '已过期'
                    elif remaining <= warning_days:
                        cert_status = '即将过期'
                    else:
                        cert_status = '正常'
                    
                    # 更新数据库
                    cursor.execute("""
                        UPDATE ssl_certificates 
                        SET cert_expire_time = %s, remaining_days = %s, status = %s,
                            last_check_time = %s, updated_at = %s
                        WHERE id = %s
                    """, (
                        cert_info['not_after'],
                        cert_info['remaining_days'],
                        cert_status,
                        datetime.datetime.now(),
                        datetime.datetime.now(),
                        cert['id']
                    ))
                    conn.commit()
                    logger.info(f"证书 {cert['domain']} 检测完成，剩余 {cert_info['remaining_days']} 天")
                else:
                    logger.error(f"证书 {cert['domain']} 检测失败: {last_exception}")
                    
            except Exception as e:
                logger.error(f"证书 {cert['domain']} 检测异常: {str(e)}")
        
        # 更新所有证书的 remaining_days 和 status（基于 cert_expire_time 动态计算）
        # 非在线检测类型（手动录入/阿里云同步）的证书也需保持 remaining_days 和 status 最新
        warning_days_raw = get_effective_config(db_config, 'ssl_warning_days', '30')
        warning_days = int(warning_days_raw) if warning_days_raw else 30
        cursor.execute("""
            UPDATE ssl_certificates
            SET remaining_days = DATEDIFF(cert_expire_time, NOW()),
                status = CASE
                    WHEN DATEDIFF(cert_expire_time, NOW()) <= 0 THEN '已过期'
                    WHEN DATEDIFF(cert_expire_time, NOW()) <= %s THEN '即将过期'
                    ELSE '正常'
                END,
                updated_at = NOW()
            WHERE cert_expire_time IS NOT NULL
        """, (warning_days,))
        conn.commit()
        updated_count = cursor.rowcount
        logger.info(f"已更新 {updated_count} 条证书的 remaining_days 和 status（预警阈值: {warning_days} 天）")
        
        # 查询需要预警的证书（从 system_config 动态读取天数）
        warning_days_raw = get_effective_config(db_config, 'ssl_warning_days', '30')
        warning_days = int(warning_days_raw) if warning_days_raw else 30
        cursor.execute("""
            SELECT sc.id, sc.domain, p.project_name, sc.cert_expire_time,
                   DATEDIFF(sc.cert_expire_time, NOW()) as remaining_days
            FROM ssl_certificates sc
            LEFT JOIN projects p ON sc.project_id = p.id
            WHERE sc.cert_expire_time IS NOT NULL
              AND DATEDIFF(sc.cert_expire_time, NOW()) <= %s
            ORDER BY remaining_days ASC
        """, (warning_days,))
        
        warning_certs = cursor.fetchall()
        
        if warning_certs:
            webhook_url = app_config.get('wechat_webhook_url', '')
            if webhook_url:
                # 导入通知函数
                from .ssl_checker import send_wechat_notification
                
                success = send_wechat_notification(webhook_url, warning_certs)
                
                # 更新通知状态
                now = datetime.datetime.now()
                for cert in warning_certs:
                    cursor.execute("""
                        UPDATE ssl_certificates 
                        SET last_notify_time = %s, notify_status = %s
                        WHERE id = %s
                    """, (now, 'sent' if success else 'failed', cert['id']))
                conn.commit()
                
                logger.info(f"证书预警通知已发送，共 {len(warning_certs)} 个证书")
            else:
                logger.warning("未配置企业微信 Webhook URL，跳过证书预警通知")
        else:
            logger.info("没有需要预警的证书")
            
    except Exception as e:
        logger.error(f"自动证书检测任务执行失败: {str(e)}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


def auto_domain_notify(db_config, app_config):
    """
    自动域名到期通知回调函数
    不在Flask应用上下文中执行，从 app_config 读取配置
    """
    conn = None
    cursor = None
    
    try:
        conn = get_db_connection(db_config)
        cursor = conn.cursor()
        
        # 查询即将过期或已过期的域名（从 system_config 动态读取天数）
        warning_days_raw = get_effective_config(db_config, 'domain_warning_days', '30')
        warning_days = int(warning_days_raw) if warning_days_raw else 30
        cursor.execute("""
            SELECT id, domain_name, owner, expire_date, 
                   DATEDIFF(expire_date, NOW()) as remaining_days
            FROM domains 
            WHERE expire_date IS NOT NULL 
              AND DATEDIFF(expire_date, NOW()) <= %s
            ORDER BY expire_date ASC
        """, (warning_days,))
        
        domains = cursor.fetchall()
        
        if domains:
            webhook_url = app_config.get('wechat_webhook_url', '')
            if webhook_url:
                # 导入通知函数
                from .ssl_checker import send_domain_expiry_notification
                
                success = send_domain_expiry_notification(webhook_url, domains)
                logger.info(f"域名到期通知已发送，共 {len(domains)} 个域名，结果: {'成功' if success else '失败'}")
            else:
                logger.warning("未配置企业微信 Webhook URL，跳过域名到期通知")
        else:
            logger.info("没有需要预警的域名")
            
    except Exception as e:
        logger.error(f"自动域名到期通知任务执行失败: {str(e)}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()


def auto_password_rotation(db_config, app_config):
    """
    自动服务器密码轮换回调函数
    逐台检查并执行密码轮换，采用串行执行确保安全
    """
    from .password_rotator import rotate_server_password
    
    conn = None
    cursor = None
    
    try:
        conn = get_db_connection(db_config)
        cursor = conn.cursor()
        
        # 查询所有启用了密码定期更新且未在运行中的服务器
        cursor.execute("""
            SELECT * FROM servers 
            WHERE password_rotation_enabled = 1 
              AND password_rotation_status != 'running'
            ORDER BY id
        """)
        servers = cursor.fetchall()
        
        if not servers:
            logger.info("密码轮换检查完成：没有需要处理的服务器")
            return
        
        logger.info(f"开始检查 {len(servers)} 台服务器的密码轮换状态")
        
        now = datetime.datetime.now()
        rotated_count = 0
        skipped_count = 0
        failed_count = 0
        
        for server in servers:
            server_id = server['id']
            hostname = server.get('hostname', str(server_id))
            
            # 检查是否需要轮换
            last_rotated = server.get('password_last_rotated_at')
            rotation_days = server.get('password_rotation_days', 30)
            
            if last_rotated:
                days_since = (now - last_rotated).days
                if days_since < rotation_days:
                    skipped_count += 1
                    logger.debug("服务器 %s: 上次更新于 %s，距今 %s 天，未到 %s 天周期，跳过",
                               hostname, last_rotated.strftime('%Y-%m-%d'), days_since, rotation_days)
                    continue
            
            # 执行密码轮换
            logger.info("服务器 %s: 开始执行密码轮换...", hostname)
            password_length = int(app_config.get('password_rotation_length', 16))
            result = rotate_server_password(server, db_config, password_length)
            
            if result.get('success'):
                rotated_count += 1
                logger.info("服务器 %s: 密码轮换成功", hostname)
            else:
                failed_count += 1
                logger.error("服务器 %s: 密码轮换失败 - %s", hostname, result.get('message'))
        
        logger.info("密码轮换检查完成: 成功=%s, 跳过=%s, 失败=%s", rotated_count, skipped_count, failed_count)
            
    except Exception as e:
        logger.error(f"密码轮换定时任务执行失败: {str(e)}")
    finally:
        if cursor:
            cursor.close()
        if conn:
            conn.close()
