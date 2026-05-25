"""
数据库初始化脚本 - 创建数据库和表结构
"""
import os
import sys
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
        `regular_user` VARCHAR(100) COMMENT '普通用户名',
        `regular_password` VARCHAR(255) COMMENT '普通用户密码',
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
        `account` VARCHAR(255) COMMENT '服务账户',
        `password` VARCHAR(255) COMMENT '服务密码',
        `remark` TEXT COMMENT '备注',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_server_id` (`server_id`),
        INDEX `idx_service_name` (`service_name`),
        FOREIGN KEY (`server_id`) REFERENCES `servers`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务清单表';
    """)

    # 5.1 服务-项目关联表（支持一对多）
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `service_projects` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `service_id` INT NOT NULL COMMENT '服务ID',
        `project_id` INT NOT NULL COMMENT '项目ID',
        UNIQUE KEY `uk_service_project` (`service_id`, `project_id`),
        INDEX `idx_service_id` (`service_id`),
        INDEX `idx_project_id` (`project_id`),
        FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE CASCADE,
        FOREIGN KEY (`project_id`) REFERENCES `projects`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务-项目关联表';
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

    # 密码轮换日志表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `password_rotation_logs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `server_id` INT NOT NULL COMMENT '服务器ID',
        `old_password_hash` VARCHAR(255) COMMENT '旧密码哈希(仅用于比对)',
        `status` VARCHAR(20) NOT NULL COMMENT '执行状态: success/failed',
        `error_message` TEXT COMMENT '错误信息',
        `rotated_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '轮换时间',
        INDEX `idx_server_id` (`server_id`),
        INDEX `idx_status` (`status`),
        INDEX `idx_rotated_at` (`rotated_at`),
        FOREIGN KEY (`server_id`) REFERENCES `servers`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='密码轮换日志表';
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
    admin_password = os.environ.get('DB_PASSWORD')
    if not admin_password:
        print("错误: 未设置 ADMIN_PASSWORD 环境变量")
        print("请在 docker-compose.yml 中设置 ADMIN_PASSWORD 环境变量")
        sys.exit(1)
    admin_password_hash = hash_password(admin_password)
    cursor.execute("""
    INSERT IGNORE INTO `users` (`username`, `password_hash`, `display_name`, `role`, `is_active`)
    VALUES (%s, %s, %s, %s, %s)
    """, ('admin', admin_password_hash, '系统管理员', 'admin', True))

    # 插入默认系统配置（内置任务参数）
    cursor.execute("""
    INSERT IGNORE INTO `system_config` (`config_key`, `config_value`, `description`) VALUES
    ('cert_auto_check_cron', '0 8 * * *', 'SSL证书自动检测Cron表达式'),
    ('ssl_warning_days', '30', 'SSL证书到期预警天数'),
    ('domain_auto_notify_cron', '0 8 * * *', '域名到期通知Cron表达式'),
    ('domain_warning_days', '30', '域名到期预警天数'),
    ('password_rotation_cron', '0 3 * * *', '密码轮换检查Cron表达式')
    """)

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

    # 插入 operator 角色默认模块授权（9个模块全授权）
    cursor.execute("""
    INSERT IGNORE INTO `role_modules` (`role`, `module`) VALUES
    ('operator', 'servers'),
    ('operator', 'services'),
    ('operator', 'apps'),
    ('operator', 'domains'),
    ('operator', 'certs'),
    ('operator', 'projects'),
    ('operator', 'monitoring'),
    ('operator', 'tasks'),
    ('operator', 'deploy')
    """)

    # ========== 流水线配置字段种子数据 ==========
    pipeline_configs_seed = [
        # (config_key, config_label, config_group, sort_order, description, required, pipeline_type)
        # --- 项目基本信息（共用） ---
        ("PROJECT_NAME", "项目名称", "project", 1, "用于企业微信通知标题", 1, None),
        ("ENVIRONMENT", "部署环境", "project", 2, "测试环境或生产环境", 1, None),
        # --- Git 仓库配置（共用） ---
        ("GIT_REPO_URL", "Git 仓库地址", "git", 1, "Git 仓库完整 URL", 1, None),
        ("GIT_BRANCH", "Git 分支", "git", 2, "要构建的分支名", 1, None),
        ("GIT_CREDENTIALS_ID", "Git 凭据 ID", "git", 3, "Jenkins 中配置的 Git 凭据 ID", 1, None),
        # --- 镜像仓库配置（后端专用） ---
        ("IMAGE_REGISTRY", "Harbor 镜像仓库地址", "registry", 1, "Harbor 镜像仓库地址", 1, "backend"),
        ("IMAGE_REGISTRY_USER", "Harbor 仓库登录用户", "registry", 2, "Harbor 登录用户名", 1, "backend"),
        ("IMAGE_REGISTRY_PASSWORD", "Harbor 仓库登录密码", "registry", 3, "Harbor 登录密码", 1, "backend"),
        ("IMAGE_PROJECT", "镜像项目名", "registry", 4, "Harbor 中的项目名称", 1, "backend"),
        # --- 服务配置（后端专用） ---
        ("SERVICES", "服务列表", "service", 1, "空格分隔的服务名列表", 1, "backend"),
        ("SERVICE_DOCKERFILE_PATHS", "Dockerfile 路径映射", "service", 2, "格式: 路径:服务名 路径:服务名", 1, "backend"),
        # --- SSH 部署配置（共用） ---
        ("SSH_CONFIG_NAMES", "SSH 目标服务器", "ssh", 1, "Jenkins SSH 配置名，多个逗号分隔", 1, None),
        ("SSH_REMOTE_DIR", "SSH 远程部署目录", "ssh", 2, "目标服务器上的部署目录", 1, None),
        # --- Jenkins 构建环境（后端专用） ---
        ("MAVEN_HOME", "MAVEN_HOME", "jenkins", 1, "Maven 安装路径", 1, "backend"),
        ("JAVA_HOME", "JAVA_HOME", "jenkins", 2, "JDK 安装路径", 1, "backend"),
        ("MAVEN_OPTS", "MAVEN_OPTS", "jenkins", 3, "Maven JVM 参数", 1, "backend"),
        ("DOCKER_BUILD_OPTS", "DOCKER_BUILD_OPTS", "jenkins", 4, "Docker build 额外参数", 1, "backend"),
        ("JENKINS_NODE_LABEL", "Jenkins 节点标签", "jenkins", 5, "构建节点标签", 1, "backend"),
        ("BUILD_TIMEOUT", "构建超时时间", "jenkins", 6, "超时时间的数值部分", 1, "backend"),
        ("BUILD_TIMEOUT_UNIT", "超时时间单位", "jenkins", 7, "HOURS 或 MINUTES", 1, "backend"),
        ("BUILD_KEEP_COUNT", "保留构建历史数量", "jenkins", 8, "Jenkins 保留的构建记录数", 1, "backend"),
        # --- 企业微信通知（共用） ---
        ("WECHAT_WEBHOOK_CREDENTIALS_ID", "Webhook 凭证 ID", "wechat", 1, "Jenkins 中企业微信机器人凭证 ID", 1, None),
        # --- Dockerfile 配置（后端专用） ---
        ("DOCKERFILE_BASE_IMAGE", "基础镜像", "dockerfile", 1, "Dockerfile FROM 基础镜像", 1, "backend"),
        ("DOCKERFILE_JAR_SOURCE_PATH", "JAR 源路径", "dockerfile", 2, "JAR 文件 COPY 源路径（由服务名自动推导可留空）", 0, "backend"),
        ("DOCKERFILE_JAR_TARGET_PATH", "JAR 目标路径", "dockerfile", 3, "JAR 文件容器内目标路径（由服务名自动推导可留空）", 0, "backend"),
        # --- 部署脚本配置（后端专用） ---
        ("DEPLOY_IMAGE_REGISTRY_CHOICE", "默认镜像仓库", "deploy", 1, "deploy 脚本默认镜像仓库", 1, "backend"),
        ("DEPLOY_IMAGE_PROJECT", "默认镜像项目", "deploy", 2, "deploy 脚本默认镜像项目", 1, "backend"),
        ("DEPLOY_IMAGE_VERSION", "默认镜像版本", "deploy", 3, "deploy 脚本默认镜像版本", 1, "backend"),
        ("DEPLOY_SSH_REMOTE_DIR", "默认 SSH 远程目录", "deploy", 4, "deploy 脚本默认远程目录", 1, "backend"),
        ("DEPLOY_DEFAULT_SERVICES", "默认服务列表", "deploy", 5, "deploy 脚本默认服务列表（空格分隔）", 1, "backend"),
        ("DEPLOY_SERVICE_PORTS", "服务端口映射", "deploy", 6, "格式: svc=port;svc=port", 1, "backend"),
        ("DEPLOY_HARBOR_USER", "Harbor 登录用户", "deploy", 7, "deploy 脚本 Harbor 用户名", 1, "backend"),
        ("DEPLOY_HARBOR_PASSWORD", "Harbor 登录密码", "deploy", 8, "deploy 脚本 Harbor 密码", 1, "backend"),
        ("CONTAINER_PREFIX", "容器名称前缀", "deploy", 9, "容器名前缀，默认为空", 0, "backend"),
        # --- Docker Compose（后端专用） ---
        ("DOCKER_COMPOSE_ENV_VARS", "docker-compose 环境变量", "compose", 1, "docker-compose.yml 环境变量，每行一个 KEY=VALUE", 0, "backend"),
        # --- 前端流水线专用配置 ---
        ("NODE_VERSION", "Node.js 版本", "frontend", 1, "NVM 安装的 Node.js 版本号", 1, "frontend"),
        ("BUILD_COMMAND", "构建命令", "frontend", 2, "前端构建命令，如 npm run build", 1, "frontend"),
        ("NPM_REGISTRY", "NPM 镜像源", "frontend", 3, "npm 镜像仓库地址", 1, "frontend"),
        ("FRONTEND_DEPLOY_DIR", "前端部署目录", "frontend", 4, "目标服务器上前端文件部署目录", 1, "frontend"),
    ]
    for ck, cl, cg, so, desc, req, pt in pipeline_configs_seed:
        cursor.execute(
            "INSERT IGNORE INTO pipeline_configs (config_key, config_label, config_group, sort_order, description, required, pipeline_type) "
            "VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (ck, cl, cg, so, desc, req, pt)
        )

    # ========== 流水线配置可选值种子数据 ==========
    # 先获取所有 config_id
    cursor.execute("SELECT id, config_key FROM pipeline_configs")
    config_map = {row['config_key']: row['id'] for row in cursor.fetchall()}

    pipeline_options_seed = [
        # (config_key, option_value, is_default, sort_order)
        # --- project ---
        ("PROJECT_NAME", "water-park-pms后端", 1, 1),
        ("PROJECT_NAME", "sdc-platform", 0, 2),
        ("ENVIRONMENT", "测试环境", 1, 1),
        ("ENVIRONMENT", "生产环境", 0, 2),
        # --- git ---
        ("GIT_REPO_URL", "http://172.24.17.30/backend/water-park-pms.git", 1, 1),
        ("GIT_BRANCH", "dev", 1, 1),
        ("GIT_BRANCH", "test", 0, 2),
        ("GIT_BRANCH", "master", 0, 3),
        ("GIT_BRANCH", "main", 0, 4),
        ("GIT_CREDENTIALS_ID", "05fbd8f8-a85f-4346-a48c-9ee619fbd3f4", 1, 1),
        # --- registry ---
        ("IMAGE_REGISTRY", "harbor.huazsz.com", 1, 1),
        ("IMAGE_REGISTRY_USER", "admin", 1, 1),
        ("IMAGE_REGISTRY_PASSWORD", "Pass4321.", 1, 1),
        ("IMAGE_PROJECT", "water-park-pms-dev", 1, 1),
        ("IMAGE_PROJECT", "sdc-dev", 0, 2),
        # --- service ---
        ("SERVICES", "park-admin", 1, 1),
        ("SERVICE_DOCKERFILE_PATHS", "park-admin/dockerfile:park-admin", 1, 1),
        # --- ssh ---
        ("SSH_CONFIG_NAMES", "172.24.1.32", 1, 1),
        ("SSH_REMOTE_DIR", "/data/water-park-pms", 1, 1),
        ("SSH_REMOTE_DIR", "/data/sdc", 0, 2),
        # --- jenkins ---
        ("MAVEN_HOME", "/opt/apache-maven-3.9.8", 1, 1),
        ("JAVA_HOME", "/opt/jdk1.8.0_301", 1, 1),
        ("MAVEN_OPTS", "-Xmx2048m -XX:+UseG1GC", 1, 1),
        ("DOCKER_BUILD_OPTS", "--compress", 1, 1),
        ("JENKINS_NODE_LABEL", "master", 1, 1),
        ("JENKINS_NODE_LABEL", "slave", 0, 2),
        ("BUILD_TIMEOUT", "1", 1, 1),
        ("BUILD_TIMEOUT_UNIT", "HOURS", 1, 1),
        ("BUILD_TIMEOUT_UNIT", "MINUTES", 0, 2),
        ("BUILD_KEEP_COUNT", "10", 1, 1),
        # --- wechat ---
        ("WECHAT_WEBHOOK_CREDENTIALS_ID", "wechat-robot-webhook", 1, 1),
        # --- dockerfile ---
        ("DOCKERFILE_BASE_IMAGE", "harbor.huazsz.com/jdk/openjdk:8-jre-FFmpeg", 1, 1),
        ("DOCKERFILE_JAR_SOURCE_PATH", "park-admin/target/park-admin.jar", 1, 1),
        ("DOCKERFILE_JAR_TARGET_PATH", "/app/park-admin.jar", 1, 1),
        # --- deploy ---
        ("DEPLOY_IMAGE_REGISTRY_CHOICE", "harbor.huazsz.com", 1, 1),
        ("DEPLOY_IMAGE_PROJECT", "sdc-dev", 1, 1),
        ("DEPLOY_IMAGE_VERSION", "v1.0.0", 1, 1),
        ("DEPLOY_SSH_REMOTE_DIR", "/data/sdc", 1, 1),
        ("DEPLOY_DEFAULT_SERVICES", "saas-biz saas-file saas-gateway saas-oauth saas-pub saas-ums", 1, 1),
        ("DEPLOY_SERVICE_PORTS", "saas-biz=10204:10204;saas-file=10102:10102;saas-gateway=10200:10200;saas-oauth=10103:10103;saas-pub=10101:10101;saas-ums=10104:10104", 1, 1),
        ("DEPLOY_HARBOR_USER", "admin", 1, 1),
        ("DEPLOY_HARBOR_PASSWORD", "Pass4321.", 1, 1),
        ("CONTAINER_PREFIX", "", 1, 1),
        # --- compose ---
        ("DOCKER_COMPOSE_ENV_VARS", "", 1, 1),
        # --- 前端流水线专用选项 ---
        ("NODE_VERSION", "v24.11.0", 1, 1),
        ("NODE_VERSION", "v20.19.0", 0, 2),
        ("NODE_VERSION", "v18.20.8", 0, 3),
        ("BUILD_COMMAND", "npm run build", 1, 1),
        ("BUILD_COMMAND", "npm run build:dev", 0, 2),
        ("BUILD_COMMAND", "npm run build:prod", 0, 3),
        ("NPM_REGISTRY", "https://registry.npmmirror.com", 1, 1),
        ("NPM_REGISTRY", "https://registry.npmjs.org", 0, 2),
        ("FRONTEND_DEPLOY_DIR", "/data/sdc/html", 1, 1),
    ]
    for ck, ov, idef, so in pipeline_options_seed:
        cid = config_map.get(ck)
        if cid:
            cursor.execute(
                "INSERT IGNORE INTO pipeline_config_options (config_id, option_value, is_default, sort_order) "
                "VALUES (%s, %s, %s, %s)",
                (cid, ov, idef, so)
            )

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

    # 15. 用户环境权限表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `user_env_permissions` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `user_id` INT NOT NULL COMMENT '用户ID',
        `env_type` VARCHAR(50) NOT NULL COMMENT '环境类型',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY `uk_user_env` (`user_id`, `env_type`),
        INDEX `idx_user_id` (`user_id`),
        FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户环境权限表';
    """)

    # 16. 流水线配置字段元数据表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `pipeline_configs` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `config_key` VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键名，如 PROJECT_NAME',
        `config_label` VARCHAR(200) NOT NULL COMMENT '中文标签',
        `config_group` VARCHAR(50) NOT NULL COMMENT '分组: project/git/registry/service/ssh/jenkins/wechat/dockerfile/deploy/compose/frontend',
        `sort_order` INT DEFAULT 0 COMMENT '组内排序号',
        `description` VARCHAR(500) COMMENT '用途说明',
        `required` TINYINT DEFAULT 1 COMMENT '是否必填',
        `pipeline_type` VARCHAR(20) DEFAULT NULL COMMENT '适用流水线类型: backend=后端, frontend=前端, NULL=共用',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        INDEX `idx_config_group` (`config_group`),
        INDEX `idx_sort_order` (`sort_order`),
        INDEX `idx_pipeline_type` (`pipeline_type`)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流水线配置字段元数据表';
    """)

    # 17. 流水线配置可选值表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `pipeline_config_options` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `config_id` INT NOT NULL COMMENT '所属字段ID',
        `option_value` TEXT NOT NULL COMMENT '可选值内容',
        `is_default` TINYINT DEFAULT 0 COMMENT '是否默认选中（每字段仅一条）',
        `sort_order` INT DEFAULT 0 COMMENT '选项排序',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY `uk_config_option` (`config_id`, `option_value`(255)),
        INDEX `idx_config_id` (`config_id`),
        FOREIGN KEY (`config_id`) REFERENCES `pipeline_configs`(`id`) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流水线配置可选值表';
    """)

    # 18. 系统配置表（内置任务参数管理）
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `system_config` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `config_key` VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
        `config_value` VARCHAR(500) NOT NULL COMMENT '配置值',
        `description` VARCHAR(200) COMMENT '配置说明',
        `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';
    """)

    # 19. 流水线生成历史表
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS `pipeline_generations` (
        `id` INT AUTO_INCREMENT PRIMARY KEY,
        `project_name` VARCHAR(200) NOT NULL COMMENT '项目名称',
        `pipeline_type` VARCHAR(20) DEFAULT 'backend' COMMENT '流水线类型: backend/frontend',
        `config_snapshot` JSON COMMENT '生成时使用的配置快照 {config_key: value}',
        `output_dir` VARCHAR(500) COMMENT '输出目录相对路径',
        `files` JSON COMMENT '生成的文件列表 [{name, path}]',
        `created_by` INT COMMENT '创建人ID',
        `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
        INDEX `idx_project_name` (`project_name`),
        INDEX `idx_pipeline_type` (`pipeline_type`),
        INDEX `idx_created_at` (`created_at`),
        FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流水线生成历史表';
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

    # 为 services 表添加 account / password 字段
    add_column_if_not_exists('services', 'account', '`account` VARCHAR(255) DEFAULT NULL COMMENT "服务账户"')
    add_column_if_not_exists('services', 'password', '`password` VARCHAR(255) DEFAULT NULL COMMENT "服务密码"')

    # 为 domains 表添加 project_id 字段
    add_column_if_not_exists('domains', 'project_id', '`project_id` INT DEFAULT NULL COMMENT "所属项目ID"')

    # 为 ssl_certificates 表添加 project_id 字段
    add_column_if_not_exists('ssl_certificates', 'project_id', '`project_id` INT DEFAULT NULL COMMENT "所属项目ID"')

    # 为 accounts 表添加 project_id 字段
    add_column_if_not_exists('accounts', 'project_id', '`project_id` INT DEFAULT NULL COMMENT "所属项目ID"')

    # 为 servers 表添加密码定期更新相关字段
    add_column_if_not_exists('servers', 'password_rotation_enabled', '`password_rotation_enabled` TINYINT(1) DEFAULT 0 COMMENT "是否启用定期更新密码 0:否 1:是"')
    add_column_if_not_exists('servers', 'password_rotation_days', '`password_rotation_days` INT DEFAULT 30 COMMENT "密码更新周期(天)"')
    add_column_if_not_exists('servers', 'password_last_rotated_at', '`password_last_rotated_at` DATETIME DEFAULT NULL COMMENT "上次更新密码时间"')
    add_column_if_not_exists('servers', 'password_rotation_status', '`password_rotation_status` VARCHAR(20) DEFAULT "idle" COMMENT "密码轮换状态: idle/running/success/failed"')
    add_column_if_not_exists('servers', 'password_rotation_error', '`password_rotation_error` TEXT DEFAULT NULL COMMENT "最近一次密码更新失败的错误信息"')

    # 将 docker_user/docker_password 重命名为 regular_user/regular_password（如果旧列存在且新列不存在）
    def rename_column_if_needed(table_name, old_name, new_name, column_def):
        """如果 old_name 列存在且 new_name 列不存在，则将 old_name 重命名为 new_name"""
        try:
            cursor.execute(f"""
                SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s AND COLUMN_NAME = %s
            """, (Config.DB_NAME, table_name, old_name))
            old_exists = cursor.fetchone()['cnt'] > 0
            cursor.execute(f"""
                SELECT COUNT(*) as cnt FROM INFORMATION_SCHEMA.COLUMNS
                WHERE TABLE_SCHEMA = %s AND TABLE_NAME = %s AND COLUMN_NAME = %s
            """, (Config.DB_NAME, table_name, new_name))
            new_exists = cursor.fetchone()['cnt'] > 0
            if old_exists and not new_exists:
                cursor.execute(f"ALTER TABLE `{table_name}` CHANGE COLUMN `{old_name}` {column_def}")
                print(f"已将 {table_name}.{old_name} 重命名为 {new_name}")
        except Exception as e:
            print(f"重命名 {table_name}.{old_name} 到 {new_name} 时出错: {e}")

    rename_column_if_needed('servers', 'docker_user', 'regular_user', '`regular_user` VARCHAR(100) COMMENT "普通用户名"')
    rename_column_if_needed('servers', 'docker_password', 'regular_password', '`regular_password` VARCHAR(255) COMMENT "普通用户密码"')

    # 为 pipeline_configs 表添加 pipeline_type 字段
    add_column_if_not_exists('pipeline_configs', 'pipeline_type', '`pipeline_type` VARCHAR(20) DEFAULT NULL COMMENT "适用流水线类型: backend=后端, frontend=前端, NULL=共用" AFTER `required`')
    # 为 pipeline_generations 表添加 pipeline_type 字段
    add_column_if_not_exists('pipeline_generations', 'pipeline_type', '`pipeline_type` VARCHAR(20) DEFAULT "backend" COMMENT "流水线类型: backend/frontend" AFTER `project_name`')

    conn.commit()
    cursor.close()
    conn.close()
    
    print("数据库初始化完成！")
    print("默认管理员账户: admin（密码已通过环境变量设置）")


if __name__ == '__main__':
    init_database()
