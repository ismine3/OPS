"""定时任务调度器"""
from apscheduler.schedulers.background import BackgroundScheduler
from apscheduler.triggers.cron import CronTrigger
import subprocess
import datetime
import pymysql
import os
import threading

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
