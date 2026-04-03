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

logger = logging.getLogger(__name__)

# 全局调度器实例
scheduler = BackgroundScheduler()


def get_db_config(app):
    """从 app.config 提取数据库配置字典"""
    return {
        'host': app.config.get('DB_HOST', '192.168.1.124'),
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


def execute_script(task_id, script_path, db_config):
    """
    执行脚本并记录日志
    在子进程中执行 Python 脚本，捕获输出并记录到数据库
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
            
            # 执行脚本
            result = subprocess.run(
                ['python', script_path],
                capture_output=True,
                text=True,
                timeout=300  # 5分钟超时
            )
            
            end_time = datetime.datetime.now()
            
            # 判断执行结果
            if result.returncode == 0:
                status = 'success'
                output = result.stdout if result.stdout else '执行成功，无输出'
                error_message = None
            else:
                status = 'failed'
                output = result.stdout if result.stdout else ''
                error_message = result.stderr if result.stderr else '执行失败，无错误信息'
            
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


def add_task_to_scheduler(task_id, script_path, cron_expression, db_config):
    """
    添加任务到调度器
    cron_expression 格式: "分 时 日 月 周"（5个字段）
    """
    try:
        # 解析 cron 表达式
        parts = cron_expression.split()
        if len(parts) != 5:
            raise ValueError("Cron 表达式格式错误，需要5个字段：分 时 日 月 周")
        
        minute, hour, day, month, day_of_week = parts
        
        # 创建 CronTrigger
        trigger = CronTrigger(
            minute=minute,
            hour=hour,
            day=day,
            month=month,
            day_of_week=day_of_week
        )
        
        # 移除已存在的任务
        job_id = f'task_{task_id}'
        if scheduler.get_job(job_id):
            scheduler.remove_job(job_id)
        
        # 添加新任务
        scheduler.add_job(
            func=execute_script,
            trigger=trigger,
            id=job_id,
            args=[task_id, script_path, db_config],
            replace_existing=True
        )
        
        return True
    except Exception as e:
        print(f"添加任务到调度器失败: {e}")
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
        print(f"从调度器移除任务失败: {e}")
        return False


def init_scheduler(app):
    """初始化调度器，从数据库加载所有活跃任务"""
    db_config = get_db_config(app)
    
    try:
        conn = get_db_connection(db_config)
        cursor = conn.cursor()
        
        # 查询所有活跃的任务
        cursor.execute("""
            SELECT id, script_path, cron_expression 
            FROM scheduled_tasks 
            WHERE is_active = TRUE AND script_path IS NOT NULL
        """)
        
        tasks = cursor.fetchall()
        
        # 添加所有活跃任务到调度器
        for task in tasks:
            if task['script_path'] and os.path.exists(task['script_path']):
                add_task_to_scheduler(
                    task['id'],
                    task['script_path'],
                    task['cron_expression'],
                    db_config
                )
                print(f"已加载定时任务: {task['id']}")
            else:
                print(f"任务 {task['id']} 的脚本文件不存在，跳过")
        
        cursor.close()
        conn.close()
        
        # 构建 app_config 字典（用于内置任务回调）
        app_config = {
            'wechat_webhook_url': app.config.get('WECHAT_WEBHOOK_URL', ''),
            'ssl_warning_days': app.config.get('SSL_WARNING_DAYS', 30),
            'ssl_check_timeout': app.config.get('SSL_CHECK_TIMEOUT', 10),
            'domain_warning_days': app.config.get('DOMAIN_WARNING_DAYS', 30)
        }
        
        # 注册内置定时任务：SSL证书自动检测+通知
        cert_cron = app.config.get('CERT_AUTO_CHECK_CRON', '0 8 * * *')
        try:
            parts = cert_cron.split()
            if len(parts) == 5:
                minute, hour, day, month, day_of_week = parts
                cert_trigger = CronTrigger(
                    minute=minute,
                    hour=hour,
                    day=day,
                    month=month,
                    day_of_week=day_of_week
                )
                
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
                print(f"已注册内置任务: SSL证书自动检测+通知 (cron: {cert_cron})")
        except Exception as e:
            print(f"注册SSL证书自动检测任务失败: {e}")
        
        # 注册内置定时任务：域名到期自动通知
        domain_cron = app.config.get('DOMAIN_AUTO_NOTIFY_CRON', '0 8 * * *')
        try:
            parts = domain_cron.split()
            if len(parts) == 5:
                minute, hour, day, month, day_of_week = parts
                domain_trigger = CronTrigger(
                    minute=minute,
                    hour=hour,
                    day=day,
                    month=month,
                    day_of_week=day_of_week
                )
                
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
                print(f"已注册内置任务: 域名到期自动通知 (cron: {domain_cron})")
        except Exception as e:
            print(f"注册域名到期自动通知任务失败: {e}")
        
        # 启动调度器
        if not scheduler.running:
            scheduler.start()
            print("定时任务调度器已启动")
        
        # 将 db_config 存储到调度器，供后续使用
        scheduler.db_config = db_config
        
    except Exception as e:
        print(f"初始化调度器失败: {e}")


def get_scheduler_db_config():
    """获取调度器的数据库配置"""
    return getattr(scheduler, 'db_config', None)


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
                    # 更新数据库
                    cursor.execute("""
                        UPDATE ssl_certificates 
                        SET cert_expire_time = %s, remaining_days = %s, 
                            last_check_time = %s, updated_at = %s
                        WHERE id = %s
                    """, (
                        cert_info['not_after'],
                        cert_info['remaining_days'],
                        datetime.datetime.now(),
                        datetime.datetime.now(),
                        cert['id']
                    ))
                    logger.info(f"证书 {cert['domain']} 检测完成，剩余 {cert_info['remaining_days']} 天")
                else:
                    logger.error(f"证书 {cert['domain']} 检测失败: {last_exception}")
                    
            except Exception as e:
                logger.error(f"证书 {cert['domain']} 检测异常: {str(e)}")
        
        conn.commit()
        
        # 查询需要预警的证书
        warning_days = app_config.get('ssl_warning_days', 30)
        cursor.execute("""
            SELECT id, domain, project_name, cert_expire_time, remaining_days
            FROM ssl_certificates
            WHERE cert_type = 0 AND remaining_days IS NOT NULL AND remaining_days <= %s
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
        
        # 查询即将过期或已过期的域名
        warning_days = app_config.get('domain_warning_days', 30)
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
