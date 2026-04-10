"""
数据库初始化脚本 - 创建数据库和表结构
"""
import pymysql
from app.utils.password_utils import hash_password
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
        `username` VARCHAR(20) NOT NULL UNIQUE COMMENT '用户名',
        `password_hash` VARCHAR(255) NOT NULL COMMENT '密码哈希',
        `display_name` VARCHAR(100) NOT NULL COMMENT '显示名称',
        `role` VARCHAR(50) NOT NULL DEFAULT 'operator' COMMENT '角色: admin/operator/viewer',
        `is_active` BOOLEAN DEFAULT TRUE COMMENT '是否激活',
        `password_changed_at` DATETIME NULL DEFAULT NULL COMMENT '密码修改时间，用于作废旧 JWT',
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
        `hostname` VARCHAR(255) COMMENT '主机名',
        `inner_ip` VARCHAR(100) COMMENT '内网IP',
        `mapped_ip` VARCHAR(100) COMMENT '云平台映射IP',
        `public_ip` VARCHAR(100) COMMENT '互联网IP',
        `cpu` VARCHAR(50) COMMENT 'CPU',
        `memory` VARCHAR(50) COMMENT '内存',
        `sys_disk` VARCHAR(50) COMMENT '系统盘',
        `data_disk` VARCHAR(50) COMMENT '数据盘',
        `purpose` VARCHAR(500) COMMENT '用途',
        `os_user` VARCHAR(100) COMMENT '系统账户',
        `os_password` VARCHAR(255) COMMENT '系统密码',
        `docker_user` VARCHAR(100) COMMENT '普通用户名',
        `docker_password` VARCHAR(255) COMMENT '普通用户密码',
        `remark` TEXT COMMENT '备注',
        `cert_path` VARCHAR(255) DEFAULT NULL COMMENT '证书路径',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_env_type` (`env_type`),
        INDEX `idx_inner_ip` (`inner_ip`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务器台账表';
    """)

    # 3. 项目管理表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `projects` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `project_name` VARCHAR(200) NOT NULL UNIQUE COMMENT '项目名称',
        `description` TEXT COMMENT '项目描述',
        `owner` VARCHAR(100) COMMENT '项目负责人',
        `status` VARCHAR(50) DEFAULT '运行中' COMMENT '项目状态',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_project_name` (`project_name`),
        INDEX `idx_status` (`status`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目管理表';
    """)

    # 4. 项目-服务器关联表（多对多）
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `project_servers` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `project_id` INT NOT NULL COMMENT '项目ID',
        `server_id` INT NOT NULL COMMENT '服务器ID',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_project_id` (`project_id`),
        INDEX `idx_server_id` (`server_id`),
        UNIQUE KEY `uk_project_server` (`project_id`, `server_id`),
        FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE,
        FOREIGN KEY (`server_id`) REFERENCES `servers`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目-服务器关联表';
    """)

    # 5. 服务清单表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `services` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `server_id` INT NOT NULL COMMENT '所属服务器ID',
        `category` VARCHAR(100) COMMENT '服务分类',
        `service_name` VARCHAR(200) NOT NULL COMMENT '服务名',
        `version` VARCHAR(100) COMMENT '版本',
        `inner_port` VARCHAR(200) COMMENT '内网端口',
        `mapped_port` VARCHAR(200) COMMENT '外网映射端口',
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

    # 13. 项目状态字典表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `dict_project_statuses` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `name` VARCHAR(50) NOT NULL UNIQUE COMMENT '项目状态名称',
        `sort_order` INT DEFAULT 0 COMMENT '排序号',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_sort_order` (`sort_order`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='项目状态字典表';
    """)

    # 6. 账号台账表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `accounts` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `seq_no` VARCHAR(50) COMMENT '编号',
        `name` VARCHAR(200) NOT NULL COMMENT '应用名称',
        `company` VARCHAR(200) COMMENT '所属单位',
        `access_url` VARCHAR(500) COMMENT '访问地址',
        `username` VARCHAR(100) COMMENT '用户名',
        `password` VARCHAR(255) COMMENT '密码',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_name` (`name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='账号台账表';
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
        `execute_command` VARCHAR(500) COMMENT '自定义执行命令',
        `script_files` TEXT COMMENT 'JSON数组，存储多个脚本的相对路径',
        `target_servers` JSON COMMENT '目标服务器ID列表',
        `is_active` BOOLEAN DEFAULT TRUE COMMENT '是否启用',
        `last_run_at` DATETIME COMMENT '上次执行时间',
        `next_run_at` DATETIME COMMENT '下次执行时间',
        `last_status` VARCHAR(50) COMMENT '上次执行状态',
        `last_output` TEXT COMMENT '上次执行输出',
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

    # 10. 操作日志表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `operation_logs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `user_id` INT COMMENT '操作用户ID',
        `username` VARCHAR(100) COMMENT '操作用户名',
        `module` VARCHAR(100) NOT NULL COMMENT '操作模块: 服务器/服务/应用/域名/证书/用户等',
        `action` VARCHAR(50) NOT NULL COMMENT '操作类型: create/update/delete/login等',
        `target_id` INT COMMENT '操作对象ID',
        `target_name` VARCHAR(300) COMMENT '操作对象名称',
        `detail` TEXT COMMENT '操作详情(JSON)',
        `ip` VARCHAR(50) COMMENT '操作IP',
        `user_agent` VARCHAR(500) COMMENT '浏览器User-Agent',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_user_id` (`user_id`),
        INDEX `idx_module` (`module`),
        INDEX `idx_action` (`action`),
        INDEX `idx_created_at` (`created_at`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='操作日志表';
    """)

    # 11. 角色模块授权表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `role_modules` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `role` VARCHAR(50) NOT NULL COMMENT '角色: operator/viewer',
        `module` VARCHAR(50) NOT NULL COMMENT '模块编码',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY `uk_role_module` (`role`, `module`),
        INDEX `idx_role` (`role`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='角色模块授权表';
    """)

    # 插入默认管理员账户
    admin_password_hash = hash_password('admin123')
    cursor.execute("""
    INSERT IGNORE INTO `users` (`username`, `password_hash`, `display_name`, `role`, `is_active`)
    VALUES (%s, %s, %s, %s, %s)
    """, ('admin', admin_password_hash, '系统管理员', 'admin', True))

    # 插入默认环境类型
    cursor.execute("""
    INSERT IGNORE INTO `dict_env_types` (`name`, `sort_order`) VALUES
    ('测试', 1), ('生产', 2)
    """)

    # 插入默认平台（常见平台）
    cursor.execute("""
    INSERT IGNORE INTO `dict_platforms` (`name`, `sort_order`) VALUES
    ('阿里云', 1), ('腾讯云', 2), ('天翼云', 3), ('AWS', 4)
    """)

    # 插入默认服务分类
    cursor.execute("""
    INSERT IGNORE INTO `dict_service_categories` (`name`, `sort_order`) VALUES
    ('关系型数据库', 1), ('NoSQL数据库', 2), ('分布式缓存', 3), ('消息队列', 4),
    ('搜索引擎', 5), ('数据平台与大数据', 6), ('计算服务', 7), ('存储服务', 8),
    ('网络服务', 9), ('API网关与服务网格', 10), ('微服务框架与运行时', 11),
    ('服务发现与配置中心', 12), ('前端与用户体验服务', 13), ('日志、监控与可观测性', 14),
    ('安全与身份认证', 15), ('容器编排', 16), ('CI/CD流水线', 17), ('任务调度与工作流', 18)
    """)

    # 插入默认项目状态
    cursor.execute("""
    INSERT IGNORE INTO `dict_project_statuses` (`name`, `sort_order`) VALUES
    ('运行中', 1), ('已下线', 2), ('规划中', 3)
    """)

    # 插入 operator 角色默认模块授权（8个模块全授权）
    cursor.execute("""
    INSERT IGNORE INTO `role_modules` (`role`, `module`) VALUES
    ('operator', 'servers'),
    ('operator', 'services'),
    ('operator', 'apps'),
    ('operator', 'domains'),
    ('operator', 'certs'),
    ('operator', 'projects'),
    ('operator', 'monitoring'),
    ('operator', 'tasks')
    """)

    # 14. 云凭证配置表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `credentials` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `credential_name` VARCHAR(100) NOT NULL UNIQUE COMMENT '凭证名称',
        `access_key_id` VARCHAR(100) NOT NULL COMMENT 'AccessKey ID',
        `access_key_secret` VARCHAR(255) NOT NULL COMMENT 'AccessKey Secret',
        `is_active` TINYINT DEFAULT 1 COMMENT '是否启用 0:禁用 1:启用',
        `description` VARCHAR(255) COMMENT '凭证描述',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_credential_name` (`credential_name`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='云凭证配置表';
    """)

    # 13. 域名管理表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `domains` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `domain_name` VARCHAR(255) NOT NULL UNIQUE COMMENT '域名',
        `registrar` VARCHAR(200) COMMENT '注册商',
        `registration_date` DATE COMMENT '注册日期',
        `expire_date` DATE COMMENT '到期日期',
        `owner` VARCHAR(200) COMMENT '持有者',
        `dns_servers` VARCHAR(500) COMMENT 'DNS服务器',
        `status` VARCHAR(50) DEFAULT '正常' COMMENT '状态',
        `source` VARCHAR(20) DEFAULT 'manual' COMMENT '来源 manual/aliyun',
        `aliyun_account_id` INT COMMENT '来源阿里云账户ID',
        `cost` DECIMAL(10,2) COMMENT '费用',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_domain_name` (`domain_name`),
        INDEX `idx_status` (`status`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='域名管理表';
    """)

    # 14. SSL证书管理表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `ssl_certificates` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `domain` VARCHAR(255) NOT NULL COMMENT '域名',
        `cert_type` TINYINT DEFAULT 0 COMMENT '证书类型 0:自动检测 1:手动录入 2:阿里云证书',
        `issuer` VARCHAR(200) COMMENT '颁发机构',
        `cert_generate_time` DATETIME COMMENT '证书生成时间',
        `cert_valid_days` INT COMMENT '有效期天数',
        `cert_expire_time` DATETIME COMMENT '证书到期时间',
        `remaining_days` INT COMMENT '剩余天数',
        `brand` VARCHAR(100) COMMENT '品牌',
        `cost` DECIMAL(10,2) COMMENT '费用',
        `status` VARCHAR(50) DEFAULT '正常' COMMENT '状态',
        `last_check_time` DATETIME COMMENT '最后检测时间',
        `last_notify_time` DATETIME COMMENT '最后通知时间',
        `notify_status` TINYINT DEFAULT 0 COMMENT '通知状态 0:未通知 1:已通知',
        `source` VARCHAR(20) DEFAULT 'manual' COMMENT '来源 manual/auto/aliyun',
        `aliyun_account_id` INT COMMENT '关联阿里云账户ID',
        `remark` TEXT COMMENT '备注',
        `cert_file_path` VARCHAR(500) COMMENT '证书文件存储路径',
        `key_file_path` VARCHAR(500) COMMENT '私钥文件存储路径',
        `has_cert_file` TINYINT DEFAULT 0 COMMENT '是否有证书文件 0:无 1:有',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_domain` (`domain`),
        INDEX `idx_cert_type` (`cert_type`),
        INDEX `idx_expire_time` (`cert_expire_time`),
        INDEX `idx_status` (`status`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='SSL证书管理表';
    """)

    # 为现有表添加 project_id 字段（如果不存在）
    def add_column_if_not_exists(table_name, column_name, column_def):
        """检查列是否存在，不存在则添加"""
        try:
            cursor.execute(f"""
                SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s AND COLUMN_NAME = %s
            """, (Config.DB_NAME, table_name, column_name))
            if cursor.fetchone()[0] == 0:
                cursor.execute(f"ALTER TABLE `{table_name}` ADD COLUMN {column_def}")
                print(f"已为 {table_name} 表添加 {column_name} 字段")
        except Exception as e:
            print(f"为 {table_name} 表添加 {column_name} 字段时出错: {e}")

    # 为 services 表添加 project_id 字段
    add_column_if_not_exists('services', 'project_id', '`project_id` INT DEFAULT NULL COMMENT "所属项目ID"')

    # 为 domains 表添加 project_id 字段
    add_column_if_not_exists('domains', 'project_id', '`project_id` INT DEFAULT NULL COMMENT "所属项目ID"')

    # 为 ssl_certificates 表添加 project_id 字段
    add_column_if_not_exists('ssl_certificates', 'project_id', '`project_id` INT DEFAULT NULL COMMENT "所属项目ID"')

    # 为 accounts 表添加 project_id 字段
    add_column_if_not_exists('accounts', 'project_id', '`project_id` INT DEFAULT NULL COMMENT "所属项目ID"')

    conn.commit()
    cursor.close()
    conn.close()
    
    print("数据库初始化完成！")
    print("默认管理员账户: admin / admin123")


if __name__ == '__main__':
    init_database()
