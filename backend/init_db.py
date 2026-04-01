"""
数据库初始化脚本 - 创建数据库和表结构
"""
import pymysql
from werkzeug.security import generate_password_hash
from app.config import Config


def get_connection(use_db=True):
    params = {
        'host': Config.DB_HOST,
        'port': Config.DB_PORT,
        'user': Config.DB_USER,
        'password': Config.DB_PASSWORD,
        'charset': 'utf8mb4',
    }
    if use_db:
        params['database'] = Config.DB_NAME
    return pymysql.connect(**params)


def init_database():
    conn = get_connection(use_db=False)
    cursor = conn.cursor()

    # 创建数据库
    cursor.execute(
        f"CREATE DATABASE IF NOT EXISTS `{Config.DB_NAME}` "
        "DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    )
    cursor.execute(f"USE `{Config.DB_NAME}`")

    # 1. 用户表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `users` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `username` VARCHAR(100) NOT NULL UNIQUE COMMENT '用户名',
        `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希',
        `display_name` VARCHAR(100) NOT NULL COMMENT '显示名称',
        `role` VARCHAR(50) NOT NULL DEFAULT 'operator' COMMENT '角色: admin/operator/viewer',
        `is_active` BOOLEAN DEFAULT TRUE COMMENT '是否激活',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_username` (`username`),
        INDEX `idx_role` (`role`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户表';
    """)

    # 2. 服务器台账表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `servers` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `env_type` VARCHAR(50) NOT NULL COMMENT '环境类型: 测试/生产/智慧环保/水电集团',
        `platform` VARCHAR(100) COMMENT '平台',
        `hostname` VARCHAR(200) COMMENT '主机名',
        `inner_ip` VARCHAR(100) COMMENT '内网IP',
        `mapped_ip` VARCHAR(100) COMMENT '云平台映射IP',
        `public_ip` VARCHAR(100) COMMENT '互联网IP',
        `cpu` VARCHAR(50) COMMENT 'CPU',
        `memory` VARCHAR(50) COMMENT '内存',
        `sys_disk` VARCHAR(50) COMMENT '系统盘',
        `data_disk` VARCHAR(50) COMMENT '数据盘',
        `purpose` VARCHAR(500) COMMENT '用途',
        `os_user` VARCHAR(100) COMMENT '系统账户',
        `os_password` VARCHAR(200) COMMENT '系统密码',
        `docker_password` VARCHAR(200) COMMENT 'Docker密码',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_env_type` (`env_type`),
        INDEX `idx_inner_ip` (`inner_ip`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务器台账表';
    """)

    # 3. 服务清单表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `services` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `server_id` INT NOT NULL COMMENT '所属服务器ID',
        `category` VARCHAR(100) COMMENT '服务分类',
        `service_name` VARCHAR(200) NOT NULL COMMENT '服务名',
        `version` VARCHAR(100) COMMENT '版本',
        `inner_port` VARCHAR(200) COMMENT '内网端口',
        `mapped_port` VARCHAR(200) COMMENT '外网映射端口',
        `public_ip` VARCHAR(50) COMMENT '外网IP',
        `inner_ip` VARCHAR(50) COMMENT '内网IP',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_server_id` (`server_id`),
        INDEX `idx_service_name` (`service_name`),
        FOREIGN KEY (`server_id`) REFERENCES `servers`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务清单表';
    """)

    # 10. 环境类型字典表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `dict_env_types` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '环境类型名称',
        `sort_order` INT DEFAULT 0 COMMENT '排序号',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_sort_order` (`sort_order`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='环境类型字典表';
    """)

    # 11. 平台字典表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `dict_platforms` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `name` VARCHAR(100) NOT NULL UNIQUE COMMENT '平台名称',
        `sort_order` INT DEFAULT 0 COMMENT '排序号',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_sort_order` (`sort_order`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='平台字典表';
    """)

    # 12. 服务分类字典表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `dict_service_categories` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `name` VARCHAR(100) NOT NULL UNIQUE COMMENT '服务分类名称',
        `sort_order` INT DEFAULT 0 COMMENT '排序号',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_sort_order` (`sort_order`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务分类字典表';
    """)

    # 4. 应用系统台账表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `app_systems` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `seq_no` VARCHAR(50) COMMENT '编号',
        `name` VARCHAR(200) NOT NULL COMMENT '应用名称',
        `company` VARCHAR(200) COMMENT '所属单位',
        `access_url` VARCHAR(500) COMMENT '访问地址',
        `username` VARCHAR(100) COMMENT '用户名',
        `password` VARCHAR(200) COMMENT '密码',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_name` (`name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='应用系统台账表';
    """)

    # 6. 域名与证书表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `domains_certs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `seq_no` VARCHAR(20) COMMENT '序号',
        `category` VARCHAR(100) COMMENT '类别(公众平台/域名/ssl证书)',
        `project` VARCHAR(200) COMMENT '项目/子类',
        `entity` VARCHAR(200) COMMENT '主体',
        `purchase_date` DATE COMMENT '购买时间',
        `expire_date` VARCHAR(100) COMMENT '到期时间',
        `cost` DECIMAL(10,2) COMMENT '费用(元)',
        `remaining_days` VARCHAR(50) COMMENT '截止有效期(天)',
        `brand` VARCHAR(100) COMMENT '品牌',
        `status` VARCHAR(50) COMMENT '备注/状态',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_category` (`category`),
        INDEX `idx_status` (`status`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='域名与证书表';
    """)

    # 7. 更新记录表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `change_records` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `seq_no` INT COMMENT '序号',
        `change_date` DATE COMMENT '日期',
        `modifier` VARCHAR(100) COMMENT '修改人',
        `location` VARCHAR(300) COMMENT '修改位置',
        `content` TEXT COMMENT '修改内容',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_change_date` (`change_date`),
        INDEX `idx_modifier` (`modifier`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='更新记录表';
    """)

    # 8. 定时任务表（为 Task 4 预留）
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `scheduled_tasks` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `name` VARCHAR(200) NOT NULL COMMENT '任务名称',
        `task_type` VARCHAR(50) NOT NULL COMMENT '任务类型: script/sql/backup',
        `description` TEXT COMMENT '任务描述',
        `cron_expression` VARCHAR(100) NOT NULL COMMENT 'Cron表达式',
        `script_content` TEXT COMMENT '脚本内容或SQL语句',
        `script_path` VARCHAR(500) COMMENT '脚本路径（如果是文件）',
        `target_servers` JSON COMMENT '目标服务器ID列表',
        `is_active` BOOLEAN DEFAULT TRUE COMMENT '是否启用',
        `last_run_at` DATETIME COMMENT '上次执行时间',
        `next_run_at` DATETIME COMMENT '下次执行时间',
        `created_by` INT COMMENT '创建人ID',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_task_type` (`task_type`),
        INDEX `idx_is_active` (`is_active`),
        FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='定时任务表';
    """)

    # 9. 任务执行日志表（为 Task 4 预留）
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `task_logs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `task_id` INT NOT NULL COMMENT '任务ID',
        `status` VARCHAR(50) NOT NULL COMMENT '执行状态: pending/running/success/failed',
        `start_time` DATETIME COMMENT '开始时间',
        `end_time` DATETIME COMMENT '结束时间',
        `output` TEXT COMMENT '执行输出',
        `error_message` TEXT COMMENT '错误信息',
        `server_id` INT COMMENT '执行服务器ID',
        `triggered_by` VARCHAR(50) COMMENT '触发方式: schedule/manual',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_task_id` (`task_id`),
        INDEX `idx_status` (`status`),
        INDEX `idx_created_at` (`created_at`),
        FOREIGN KEY (`task_id`) REFERENCES `scheduled_tasks`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='任务执行日志表';
    """)

    # 插入默认管理员账户
    admin_password_hash = generate_password_hash('admin123')
    cursor.execute("""
    INSERT IGNORE INTO `users` (`username`, `password_hash`, `display_name`, `role`, `is_active`)
    VALUES (%s, %s, %s, %s, %s)
    """, ('admin', admin_password_hash, '系统管理员', 'admin', True))

    # 插入默认环境类型
    cursor.execute("""
    INSERT IGNORE INTO `dict_env_types` (`name`, `sort_order`) VALUES
    ('测试', 1), ('生产', 2), ('智慧环保', 3), ('水电集团', 4)
    """)

    # 插入默认平台（常见平台）
    cursor.execute("""
    INSERT IGNORE INTO `dict_platforms` (`name`, `sort_order`) VALUES
    ('数产测试环境', 1), ('数产生产环境', 2), ('智慧环保生产', 3), ('水电集团', 4)
    """)

    # 插入默认服务分类
    cursor.execute("""
    INSERT IGNORE INTO `dict_service_categories` (`name`, `sort_order`) VALUES
    ('中间件', 1), ('数据库', 2), ('缓存', 3), ('消息队列', 4), ('应用服务', 5), ('数据服务', 6)
    """)

    conn.commit()
    cursor.close()
    conn.close()
    
    print("数据库初始化完成！")
    print("默认管理员账户: admin / admin123")


if __name__ == '__main__':
    init_database()
