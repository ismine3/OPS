"""
数据库升级脚本 — 部署配置（流水线生成器）模块
================================================================
用途: 在已有 OPS 数据库上增量添加 pipeline_configs / pipeline_config_options /
      pipeline_generations 三张表及种子数据，并为 operator 角色授予 deploy 模块权限。

用法:
    cd backend
    python upgrade_pipeline.py

幂等性: 所有 CREATE 使用 IF NOT EXISTS，INSERT 使用 IGNORE，
        重复执行不会报错或产生重复数据。
================================================================
"""
import sys
import pymysql
from app.config import Config


def get_connection():
    return pymysql.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        database=Config.DB_NAME,
        charset='utf8mb4',
    )


# =============================================================================
#                               升级入口
# =============================================================================
def upgrade():
    print("=" * 60)
    print("  OPS 数据库升级 — 部署配置（流水线生成器）模块")
    print("=" * 60)
    print(f"  目标数据库: {Config.DB_HOST}:{Config.DB_PORT}/{Config.DB_NAME}")

    conn = get_connection()
    cursor = conn.cursor()

    try:
        # ---- 1. 创建三张新表 ----
        print("\n[1/4] 创建数据表...")

        cursor.execute("""
        CREATE TABLE IF NOT EXISTS `pipeline_configs` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `config_key` VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键名',
            `config_label` VARCHAR(200) NOT NULL COMMENT '中文标签',
            `config_group` VARCHAR(50) NOT NULL COMMENT '分组',
            `sort_order` INT DEFAULT 0 COMMENT '组内排序号',
            `description` VARCHAR(500) COMMENT '用途说明',
            `required` TINYINT DEFAULT 1 COMMENT '是否必填',
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX `idx_config_group` (`config_group`),
            INDEX `idx_sort_order` (`sort_order`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流水线配置字段元数据表';
        """)
        print("  ✓ pipeline_configs")

        cursor.execute("""
        CREATE TABLE IF NOT EXISTS `pipeline_config_options` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `config_id` INT NOT NULL COMMENT '所属字段ID',
            `option_value` TEXT NOT NULL COMMENT '可选值内容',
            `is_default` TINYINT DEFAULT 0 COMMENT '是否默认选中',
            `sort_order` INT DEFAULT 0 COMMENT '选项排序',
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            UNIQUE KEY `uk_config_option` (`config_id`, `option_value`(255)),
            INDEX `idx_config_id` (`config_id`),
            FOREIGN KEY (`config_id`) REFERENCES `pipeline_configs`(`id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流水线配置可选值表';
        """)
        print("  ✓ pipeline_config_options")

        cursor.execute("""
        CREATE TABLE IF NOT EXISTS `pipeline_generations` (
            `id` INT AUTO_INCREMENT PRIMARY KEY,
            `project_name` VARCHAR(200) NOT NULL COMMENT '项目名称',
            `config_snapshot` JSON COMMENT '生成时使用的配置快照',
            `output_dir` VARCHAR(500) COMMENT '输出目录相对路径',
            `files` JSON COMMENT '生成的文件列表',
            `created_by` INT COMMENT '创建人ID',
            `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
            INDEX `idx_project_name` (`project_name`),
            INDEX `idx_created_at` (`created_at`),
            FOREIGN KEY (`created_by`) REFERENCES `users`(`id`) ON DELETE SET NULL
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='流水线生成历史表';
        """)
        print("  ✓ pipeline_generations")
        conn.commit()

        # ---- 2. 插入配置字段种子数据 ----
        print("\n[2/4] 插入配置字段元数据...")
        pipeline_configs_seed = [
            # (config_key, config_label, config_group, sort_order, description, required)
            # --- 项目基本信息 ---
            ("PROJECT_NAME", "项目名称", "project", 1, "用于企业微信通知标题", 1),
            ("ENVIRONMENT", "部署环境", "project", 2, "测试环境或生产环境", 1),
            # --- Git 仓库配置 ---
            ("GIT_REPO_URL", "Git 仓库地址", "git", 1, "Git 仓库完整 URL", 1),
            ("GIT_BRANCH", "Git 分支", "git", 2, "要构建的分支名", 1),
            ("GIT_CREDENTIALS_ID", "Git 凭据 ID", "git", 3, "Jenkins 中配置的 Git 凭据 ID", 1),
            # --- 镜像仓库配置 ---
            ("IMAGE_REGISTRY", "Harbor 镜像仓库地址", "registry", 1, "Harbor 镜像仓库地址", 1),
            ("IMAGE_REGISTRY_USER", "Harbor 仓库登录用户", "registry", 2, "Harbor 登录用户名", 1),
            ("IMAGE_REGISTRY_PASSWORD", "Harbor 仓库登录密码", "registry", 3, "Harbor 登录密码", 1),
            ("IMAGE_PROJECT", "镜像项目名", "registry", 4, "Harbor 中的项目名称", 1),
            # --- 服务配置 ---
            ("SERVICES", "服务列表", "service", 1, "空格分隔的服务名列表", 1),
            ("SERVICE_DOCKERFILE_PATHS", "Dockerfile 路径映射", "service", 2, "格式: 路径:服务名 路径:服务名", 1),
            # --- SSH 部署配置 ---
            ("SSH_CONFIG_NAMES", "SSH 目标服务器", "ssh", 1, "Jenkins SSH 配置名，多个逗号分隔", 1),
            ("SSH_REMOTE_DIR", "SSH 远程部署目录", "ssh", 2, "目标服务器上的部署目录", 1),
            # --- Jenkins 构建环境 ---
            ("MAVEN_HOME", "MAVEN_HOME", "jenkins", 1, "Maven 安装路径", 1),
            ("JAVA_HOME", "JAVA_HOME", "jenkins", 2, "JDK 安装路径", 1),
            ("MAVEN_OPTS", "MAVEN_OPTS", "jenkins", 3, "Maven JVM 参数", 1),
            ("DOCKER_BUILD_OPTS", "DOCKER_BUILD_OPTS", "jenkins", 4, "Docker build 额外参数", 1),
            ("JENKINS_NODE_LABEL", "Jenkins 节点标签", "jenkins", 5, "构建节点标签", 1),
            ("BUILD_TIMEOUT", "构建超时时间", "jenkins", 6, "超时时间的数值部分", 1),
            ("BUILD_TIMEOUT_UNIT", "超时时间单位", "jenkins", 7, "HOURS 或 MINUTES", 1),
            ("BUILD_KEEP_COUNT", "保留构建历史数量", "jenkins", 8, "Jenkins 保留的构建记录数", 1),
            # --- 企业微信通知 ---
            ("WECHAT_WEBHOOK_CREDENTIALS_ID", "Webhook 凭证 ID", "wechat", 1, "Jenkins 中企业微信机器人凭证 ID", 1),
            # --- Dockerfile 配置 ---
            ("DOCKERFILE_BASE_IMAGE", "基础镜像", "dockerfile", 1, "Dockerfile FROM 基础镜像", 1),
            ("DOCKERFILE_JAR_SOURCE_PATH", "JAR 源路径", "dockerfile", 2, "JAR 文件 COPY 源路径", 0),
            ("DOCKERFILE_JAR_TARGET_PATH", "JAR 目标路径", "dockerfile", 3, "JAR 文件容器内目标路径", 0),
            # --- 部署脚本配置 ---
            ("DEPLOY_IMAGE_REGISTRY_CHOICE", "默认镜像仓库", "deploy", 1, "deploy 脚本默认镜像仓库", 1),
            ("DEPLOY_IMAGE_PROJECT", "默认镜像项目", "deploy", 2, "deploy 脚本默认镜像项目", 1),
            ("DEPLOY_IMAGE_VERSION", "默认镜像版本", "deploy", 3, "deploy 脚本默认镜像版本", 1),
            ("DEPLOY_SSH_REMOTE_DIR", "默认 SSH 远程目录", "deploy", 4, "deploy 脚本默认远程目录", 1),
            ("DEPLOY_DEFAULT_SERVICES", "默认服务列表", "deploy", 5, "deploy 脚本默认服务列表", 1),
            ("DEPLOY_SERVICE_PORTS", "服务端口映射", "deploy", 6, "格式: svc=port;svc=port", 1),
            ("DEPLOY_HARBOR_USER", "Harbor 登录用户", "deploy", 7, "deploy 脚本 Harbor 用户名", 1),
            ("DEPLOY_HARBOR_PASSWORD", "Harbor 登录密码", "deploy", 8, "deploy 脚本 Harbor 密码", 1),
            ("CONTAINER_PREFIX", "容器名称前缀", "deploy", 9, "容器名前缀", 0),
            # --- Docker Compose ---
            ("DOCKER_COMPOSE_ENV_VARS", "docker-compose 环境变量", "compose", 1, "每行一个 KEY=VALUE", 0),
        ]

        inserted = 0
        for ck, cl, cg, so, desc, req in pipeline_configs_seed:
            cursor.execute(
                "INSERT IGNORE INTO pipeline_configs (config_key, config_label, config_group, sort_order, description, required) "
                "VALUES (%s, %s, %s, %s, %s, %s)",
                (ck, cl, cg, so, desc, req)
            )
            if cursor.rowcount > 0:
                inserted += 1
        conn.commit()
        print(f"  ✓ 配置字段: 新增 {inserted} 条 (共 {len(pipeline_configs_seed)} 条)")

        # ---- 3. 插入可选值种子数据 ----
        print("\n[3/4] 插入配置可选值...")
        cursor.execute("SELECT id, config_key FROM pipeline_configs")
        config_map = {row['config_key']: row['id'] for row in cursor.fetchall()}

        pipeline_options_seed = [
            # (config_key, option_value, is_default, sort_order)
            ("PROJECT_NAME", "water-park-pms后端", 1, 1),
            ("PROJECT_NAME", "sdc-platform", 0, 2),
            ("ENVIRONMENT", "测试环境", 1, 1),
            ("ENVIRONMENT", "生产环境", 0, 2),
            ("GIT_REPO_URL", "http://172.24.17.30/backend/water-park-pms.git", 1, 1),
            ("GIT_BRANCH", "dev", 1, 1),
            ("GIT_BRANCH", "test", 0, 2),
            ("GIT_BRANCH", "master", 0, 3),
            ("GIT_BRANCH", "main", 0, 4),
            ("GIT_CREDENTIALS_ID", "05fbd8f8-a85f-4346-a48c-9ee619fbd3f4", 1, 1),
            ("IMAGE_REGISTRY", "harbor.huazsz.com", 1, 1),
            ("IMAGE_REGISTRY_USER", "admin", 1, 1),
            ("IMAGE_REGISTRY_PASSWORD", "Pass4321.", 1, 1),
            ("IMAGE_PROJECT", "water-park-pms-dev", 1, 1),
            ("IMAGE_PROJECT", "sdc-dev", 0, 2),
            ("SERVICES", "park-admin", 1, 1),
            ("SERVICE_DOCKERFILE_PATHS", "park-admin/dockerfile:park-admin", 1, 1),
            ("SSH_CONFIG_NAMES", "172.24.1.32", 1, 1),
            ("SSH_REMOTE_DIR", "/data/water-park-pms", 1, 1),
            ("SSH_REMOTE_DIR", "/data/sdc", 0, 2),
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
            ("WECHAT_WEBHOOK_CREDENTIALS_ID", "wechat-robot-webhook", 1, 1),
            ("DOCKERFILE_BASE_IMAGE", "harbor.huazsz.com/jdk/openjdk:8-jre-FFmpeg", 1, 1),
            ("DOCKERFILE_JAR_SOURCE_PATH", "park-admin/target/park-admin.jar", 1, 1),
            ("DOCKERFILE_JAR_TARGET_PATH", "/app/park-admin.jar", 1, 1),
            ("DEPLOY_IMAGE_REGISTRY_CHOICE", "harbor.huazsz.com", 1, 1),
            ("DEPLOY_IMAGE_PROJECT", "sdc-dev", 1, 1),
            ("DEPLOY_IMAGE_VERSION", "v1.0.0", 1, 1),
            ("DEPLOY_SSH_REMOTE_DIR", "/data/sdc", 1, 1),
            ("DEPLOY_DEFAULT_SERVICES", "saas-biz saas-file saas-gateway saas-oauth saas-pub saas-ums", 1, 1),
            ("DEPLOY_SERVICE_PORTS", "saas-biz=10204:10204;saas-file=10102:10102;saas-gateway=10200:10200;saas-oauth=10103:10103;saas-pub=10101:10101;saas-ums=10104:10104", 1, 1),
            ("DEPLOY_HARBOR_USER", "admin", 1, 1),
            ("DEPLOY_HARBOR_PASSWORD", "Pass4321.", 1, 1),
            ("CONTAINER_PREFIX", "", 1, 1),
            ("DOCKER_COMPOSE_ENV_VARS", "", 1, 1),
        ]

        opt_inserted = 0
        for ck, ov, idef, so in pipeline_options_seed:
            cid = config_map.get(ck)
            if cid:
                cursor.execute(
                    "INSERT IGNORE INTO pipeline_config_options (config_id, option_value, is_default, sort_order) "
                    "VALUES (%s, %s, %s, %s)",
                    (cid, ov, idef, so)
                )
                if cursor.rowcount > 0:
                    opt_inserted += 1
        conn.commit()
        print(f"  ✓ 可选值: 新增 {opt_inserted} 条 (共 {len(pipeline_options_seed)} 条)")

        # ---- 4. 角色模块授权 ----
        print("\n[4/4] 配置角色模块授权...")
        cursor.execute(
            "INSERT IGNORE INTO role_modules (role, module) VALUES (%s, %s)",
            ('operator', 'deploy')
        )
        conn.commit()
        if cursor.rowcount > 0:
            print("  ✓ 已为 operator 角色添加 deploy 模块权限")
        else:
            print("  - deploy 模块权限已存在，跳过")

        # ---- 完成 ----
        print("\n" + "=" * 60)
        print("  升级完成！")
        print("=" * 60)
        print("  新增表: pipeline_configs / pipeline_config_options / pipeline_generations")
        print("  新增模块权限: operator → deploy")
        print("\n  请在 role_modules 管理页面确认 operator 角色已勾选「部署配置」")
        print("  或执行: python init_db.py (幂等，不会影响已有数据)")
        print("=" * 60)

    except Exception as e:
        conn.rollback()
        print(f"\n✗ 升级失败: {e}")
        sys.exit(1)
    finally:
        cursor.close()
        conn.close()


if __name__ == '__main__':
    upgrade()
