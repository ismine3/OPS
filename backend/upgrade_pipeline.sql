-- =============================================================================
-- OPS 数据库升级脚本 — 部署配置（流水线生成器）模块 v2
-- =============================================================================
-- 用途: 在已有 OPS 数据库上增量添加 pipeline_configs / pipeline_config_options /
--       pipeline_generations 三张表及种子数据，并为 operator 角色授予 deploy 权限。
--       v2 新增: pipeline_type 字段区分后端/前端流水线、前端配置种子数据。
--
-- 用法:  mysql -u root -p ops_platform < upgrade_pipeline.sql
--
-- 幂等:  所有 DDL 使用 IF NOT EXISTS，DML 使用 INSERT IGNORE，
--        重复执行不会报错或产生重复数据。
-- =============================================================================

-- =============================================================================
-- 1. 创建数据表
-- =============================================================================

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

-- =============================================================================
-- 1.5 补加 ALTER（如果表已存在但缺少列）
-- =============================================================================
-- 使用存储过程安全添加列（忽略已存在错误）
DROP PROCEDURE IF EXISTS `add_column_if_not_exists`;

DELIMITER //
CREATE PROCEDURE `add_column_if_not_exists`(
    IN tbl_name VARCHAR(128),
    IN col_name VARCHAR(128),
    IN col_def TEXT
)
BEGIN
    SET @cnt = 0;
    SELECT COUNT(*) INTO @cnt
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl_name
      AND COLUMN_NAME = col_name;
    IF @cnt = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', tbl_name, '` ADD COLUMN ', col_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
    END IF;
END//
DELIMITER ;

CALL add_column_if_not_exists('pipeline_configs', 'pipeline_type', '`pipeline_type` VARCHAR(20) DEFAULT NULL COMMENT "适用流水线类型: backend=后端, frontend=前端, NULL=共用" AFTER `required`');
CALL add_column_if_not_exists('pipeline_generations', 'pipeline_type', '`pipeline_type` VARCHAR(20) DEFAULT "backend" COMMENT "流水线类型: backend/frontend" AFTER `project_name`');

DROP PROCEDURE IF EXISTS `add_column_if_not_exists`;

-- =============================================================================
-- 2. 插入配置字段元数据（35条后端 + 4条前端）= 39条
--    pipeline_type: NULL=共用, 'backend'=后端专用, 'frontend'=前端专用
-- =============================================================================

INSERT IGNORE INTO pipeline_configs (config_key, config_label, config_group, sort_order, description, required, pipeline_type) VALUES
-- 项目基本信息（共用）
('PROJECT_NAME',               '项目名称',               'project',    1, '用于企业微信通知标题', 1, NULL),
('ENVIRONMENT',                 '部署环境',               'project',    2, '测试环境或生产环境', 1, NULL),
-- Git 仓库配置（共用）
('GIT_REPO_URL',                'Git 仓库地址',           'git',        1, 'Git 仓库完整 URL', 1, NULL),
('GIT_BRANCH',                  'Git 分支',               'git',        2, '要构建的分支名', 1, NULL),
('GIT_CREDENTIALS_ID',          'Git 凭据 ID',            'git',        3, 'Jenkins 中配置的 Git 凭据 ID', 1, NULL),
-- 镜像仓库配置（后端专用）
('IMAGE_REGISTRY',              'Harbor 镜像仓库地址',    'registry',   1, 'Harbor 镜像仓库地址', 1, 'backend'),
('IMAGE_REGISTRY_USER',         'Harbor 仓库登录用户',    'registry',   2, 'Harbor 登录用户名', 1, 'backend'),
('IMAGE_REGISTRY_PASSWORD',     'Harbor 仓库登录密码',    'registry',   3, 'Harbor 登录密码', 1, 'backend'),
('IMAGE_PROJECT',               '镜像项目名',             'registry',   4, 'Harbor 中的项目名称', 1, 'backend'),
-- 服务配置（后端专用）
('SERVICES',                    '服务列表',               'service',    1, '空格分隔的服务名列表', 1, 'backend'),
('SERVICE_DOCKERFILE_PATHS',    'Dockerfile 路径映射',    'service',    2, '格式: 路径:服务名 路径:服务名', 1, 'backend'),
-- SSH 部署配置（共用）
('SSH_CONFIG_NAMES',            'SSH 目标服务器',         'ssh',        1, 'Jenkins SSH 配置名，多个逗号分隔', 1, NULL),
('SSH_REMOTE_DIR',              'SSH 远程部署目录',       'ssh',        2, '目标服务器上的部署目录', 1, NULL),
-- Jenkins 构建环境（后端专用）
('MAVEN_HOME',                  'MAVEN_HOME',             'jenkins',    1, 'Maven 安装路径', 1, 'backend'),
('JAVA_HOME',                   'JAVA_HOME',              'jenkins',    2, 'JDK 安装路径', 1, 'backend'),
('MAVEN_OPTS',                  'MAVEN_OPTS',             'jenkins',    3, 'Maven JVM 参数', 1, 'backend'),
('DOCKER_BUILD_OPTS',           'DOCKER_BUILD_OPTS',      'jenkins',    4, 'Docker build 额外参数', 1, 'backend'),
('JENKINS_NODE_LABEL',          'Jenkins 节点标签',       'jenkins',    5, '构建节点标签', 1, 'backend'),
('BUILD_TIMEOUT',               '构建超时时间',           'jenkins',    6, '超时时间的数值部分', 1, 'backend'),
('BUILD_TIMEOUT_UNIT',          '超时时间单位',           'jenkins',    7, 'HOURS 或 MINUTES', 1, 'backend'),
('BUILD_KEEP_COUNT',            '保留构建历史数量',       'jenkins',    8, 'Jenkins 保留的构建记录数', 1, 'backend'),
-- 企业微信通知（共用）
('WECHAT_WEBHOOK_CREDENTIALS_ID','Webhook 凭证 ID',       'wechat',     1, 'Jenkins 中企业微信机器人凭证 ID', 1, NULL),
-- Dockerfile 配置（后端专用）
('DOCKERFILE_BASE_IMAGE',       '基础镜像',               'dockerfile', 1, 'Dockerfile FROM 基础镜像', 1, 'backend'),
('DOCKERFILE_JAR_SOURCE_PATH',  'JAR 源路径',             'dockerfile', 2, 'JAR 文件 COPY 源路径（由服务名自动推导可留空）', 0, 'backend'),
('DOCKERFILE_JAR_TARGET_PATH',  'JAR 目标路径',           'dockerfile', 3, 'JAR 文件容器内目标路径（由服务名自动推导可留空）', 0, 'backend'),
-- 部署脚本配置（后端专用）
('DEPLOY_IMAGE_REGISTRY_CHOICE','默认镜像仓库',           'deploy',     1, 'deploy 脚本默认镜像仓库', 1, 'backend'),
('DEPLOY_IMAGE_PROJECT',        '默认镜像项目',           'deploy',     2, 'deploy 脚本默认镜像项目', 1, 'backend'),
('DEPLOY_IMAGE_VERSION',        '默认镜像版本',           'deploy',     3, 'deploy 脚本默认镜像版本', 1, 'backend'),
('DEPLOY_SSH_REMOTE_DIR',       '默认 SSH 远程目录',      'deploy',     4, 'deploy 脚本默认远程目录', 1, 'backend'),
('DEPLOY_DEFAULT_SERVICES',     '默认服务列表',           'deploy',     5, 'deploy 脚本默认服务列表（空格分隔）', 1, 'backend'),
('DEPLOY_SERVICE_PORTS',        '服务端口映射',           'deploy',     6, '格式: svc=port;svc=port', 1, 'backend'),
('DEPLOY_HARBOR_USER',          'Harbor 登录用户',        'deploy',     7, 'deploy 脚本 Harbor 用户名', 1, 'backend'),
('DEPLOY_HARBOR_PASSWORD',      'Harbor 登录密码',        'deploy',     8, 'deploy 脚本 Harbor 密码', 1, 'backend'),
('CONTAINER_PREFIX',            '容器名称前缀',           'deploy',     9, '容器名前缀，默认为空', 0, 'backend'),
-- Docker Compose（后端专用）
('DOCKER_COMPOSE_ENV_VARS',     'docker-compose 环境变量','compose',    1, 'docker-compose.yml 环境变量，每行一个 KEY=VALUE', 0, 'backend'),
-- ============ 前端流水线专用配置(新增) ============
('NODE_VERSION',                'Node.js 版本',           'frontend',   1, 'NVM 安装的 Node.js 版本号', 1, 'frontend'),
('BUILD_COMMAND',               '构建命令',               'frontend',   2, '前端构建命令，如 npm run build', 1, 'frontend'),
('NPM_REGISTRY',                'NPM 镜像源',             'frontend',   3, 'npm 镜像仓库地址', 1, 'frontend'),
('FRONTEND_DEPLOY_DIR',         '前端部署目录',           'frontend',   4, '目标服务器上前端文件部署目录', 1, 'frontend');

-- =============================================================================
-- 2.5 修正已有配置的 pipeline_type（修复 v1 升级时未设类型的问题）
--     v1 脚本插入的配置 pipeline_type 为 NULL，需要标记后端专用字段
-- =============================================================================
UPDATE pipeline_configs SET pipeline_type = 'backend'
WHERE config_key IN (
    'IMAGE_REGISTRY','IMAGE_REGISTRY_USER','IMAGE_REGISTRY_PASSWORD','IMAGE_PROJECT',
    'SERVICES','SERVICE_DOCKERFILE_PATHS',
    'MAVEN_HOME','JAVA_HOME','MAVEN_OPTS','DOCKER_BUILD_OPTS',
    'JENKINS_NODE_LABEL','BUILD_TIMEOUT','BUILD_TIMEOUT_UNIT','BUILD_KEEP_COUNT',
    'DOCKERFILE_BASE_IMAGE',
    'DOCKERFILE_JAR_SOURCE_PATH','DOCKERFILE_JAR_TARGET_PATH',
    'DEPLOY_IMAGE_REGISTRY_CHOICE','DEPLOY_IMAGE_PROJECT','DEPLOY_IMAGE_VERSION',
    'DEPLOY_SSH_REMOTE_DIR','DEPLOY_DEFAULT_SERVICES','DEPLOY_SERVICE_PORTS',
    'DEPLOY_HARBOR_USER','DEPLOY_HARBOR_PASSWORD','CONTAINER_PREFIX',
    'DOCKER_COMPOSE_ENV_VARS'
) AND (pipeline_type IS NULL OR pipeline_type = '');

-- =============================================================================
-- 2.6 清理已废弃的配置项（新版 Docker 不支持 MAINTAINER 指令）
-- =============================================================================
-- 先删选项（外键 CASCADE 会自动清理，此处显式删除确保幂等）
DELETE FROM pipeline_config_options WHERE config_id = (SELECT id FROM pipeline_configs WHERE config_key = 'DOCKERFILE_MAINTAINER');
DELETE FROM pipeline_configs WHERE config_key = 'DOCKERFILE_MAINTAINER';

-- =============================================================================
-- 3. 插入可选值种子数据（46条后端 + 5条前端）= 51条
--    使用子查询获取 config_id，确保数据一致性
-- =============================================================================

INSERT IGNORE INTO pipeline_config_options (config_id, option_value, is_default, sort_order) VALUES
-- 项目基本信息
((SELECT id FROM pipeline_configs WHERE config_key = 'PROJECT_NAME'),               'water-park-pms后端',                                       1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'PROJECT_NAME'),               'sdc-platform',                                             0, 2),
((SELECT id FROM pipeline_configs WHERE config_key = 'ENVIRONMENT'),                 '测试环境',                                                 1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'ENVIRONMENT'),                 '生产环境',                                                 0, 2),
-- Git 仓库配置
((SELECT id FROM pipeline_configs WHERE config_key = 'GIT_REPO_URL'),                'http://172.24.17.30/backend/water-park-pms.git',            1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'GIT_BRANCH'),                  'dev',                                                      1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'GIT_BRANCH'),                  'test',                                                     0, 2),
((SELECT id FROM pipeline_configs WHERE config_key = 'GIT_BRANCH'),                  'master',                                                   0, 3),
((SELECT id FROM pipeline_configs WHERE config_key = 'GIT_BRANCH'),                  'main',                                                     0, 4),
((SELECT id FROM pipeline_configs WHERE config_key = 'GIT_CREDENTIALS_ID'),          '05fbd8f8-a85f-4346-a48c-9ee619fbd3f4',                     1, 1),
-- 镜像仓库配置
((SELECT id FROM pipeline_configs WHERE config_key = 'IMAGE_REGISTRY'),              'harbor.huazsz.com',                                        1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'IMAGE_REGISTRY_USER'),         'admin',                                                    1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'IMAGE_REGISTRY_PASSWORD'),     'Pass4321.',                                                1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'IMAGE_PROJECT'),               'water-park-pms-dev',                                       1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'IMAGE_PROJECT'),               'sdc-dev',                                                  0, 2),
-- 服务配置
((SELECT id FROM pipeline_configs WHERE config_key = 'SERVICES'),                    'park-admin',                                               1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'SERVICE_DOCKERFILE_PATHS'),    'park-admin/dockerfile:park-admin',                         1, 1),
-- SSH 部署配置
((SELECT id FROM pipeline_configs WHERE config_key = 'SSH_CONFIG_NAMES'),            '172.24.1.32',                                              1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'SSH_REMOTE_DIR'),              '/data/water-park-pms',                                     1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'SSH_REMOTE_DIR'),              '/data/sdc',                                                0, 2),
-- Jenkins 构建环境
((SELECT id FROM pipeline_configs WHERE config_key = 'MAVEN_HOME'),                  '/opt/apache-maven-3.9.8',                                  1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'JAVA_HOME'),                   '/opt/jdk1.8.0_301',                                        1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'MAVEN_OPTS'),                  '-Xmx2048m -XX:+UseG1GC',                                   1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DOCKER_BUILD_OPTS'),           '--compress',                                               1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'JENKINS_NODE_LABEL'),          'master',                                                   1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'JENKINS_NODE_LABEL'),          'slave',                                                    0, 2),
((SELECT id FROM pipeline_configs WHERE config_key = 'BUILD_TIMEOUT'),               '1',                                                        1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'BUILD_TIMEOUT_UNIT'),          'HOURS',                                                    1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'BUILD_TIMEOUT_UNIT'),          'MINUTES',                                                  0, 2),
((SELECT id FROM pipeline_configs WHERE config_key = 'BUILD_KEEP_COUNT'),            '10',                                                       1, 1),
-- 企业微信通知
((SELECT id FROM pipeline_configs WHERE config_key = 'WECHAT_WEBHOOK_CREDENTIALS_ID'),'wechat-robot-webhook',                                    1, 1),
-- Dockerfile 配置
((SELECT id FROM pipeline_configs WHERE config_key = 'DOCKERFILE_BASE_IMAGE'),       'harbor.huazsz.com/jdk/openjdk:8-jre-FFmpeg',               1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DOCKERFILE_JAR_SOURCE_PATH'),  'park-admin/target/park-admin.jar',                         1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DOCKERFILE_JAR_TARGET_PATH'),  '/app/park-admin.jar',                                      1, 1),
-- 部署脚本配置
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_IMAGE_REGISTRY_CHOICE'),'harbor.huazsz.com',                                        1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_IMAGE_PROJECT'),        'sdc-dev',                                                  1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_IMAGE_VERSION'),        'v1.0.0',                                                   1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_SSH_REMOTE_DIR'),       '/data/sdc',                                                1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_DEFAULT_SERVICES'),     'saas-biz saas-file saas-gateway saas-oauth saas-pub saas-ums', 1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_SERVICE_PORTS'),        'saas-biz=10204:10204;saas-file=10102:10102;saas-gateway=10200:10200;saas-oauth=10103:10103;saas-pub=10101:10101;saas-ums=10104:10104', 1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_HARBOR_USER'),          'admin',                                                    1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'DEPLOY_HARBOR_PASSWORD'),      'Pass4321.',                                                1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'CONTAINER_PREFIX'),            '',                                                         1, 1),
-- Docker Compose
((SELECT id FROM pipeline_configs WHERE config_key = 'DOCKER_COMPOSE_ENV_VARS'),     '',                                                         1, 1),
-- ============ 前端流水线专用选项(新增) ============
((SELECT id FROM pipeline_configs WHERE config_key = 'NODE_VERSION'),                'v24.11.0',                                                 1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'NODE_VERSION'),                'v20.19.0',                                                 0, 2),
((SELECT id FROM pipeline_configs WHERE config_key = 'NODE_VERSION'),                'v18.20.8',                                                 0, 3),
((SELECT id FROM pipeline_configs WHERE config_key = 'BUILD_COMMAND'),               'npm run build',                                            1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'BUILD_COMMAND'),               'npm run build:dev',                                        0, 2),
((SELECT id FROM pipeline_configs WHERE config_key = 'BUILD_COMMAND'),               'npm run build:prod',                                       0, 3),
((SELECT id FROM pipeline_configs WHERE config_key = 'NPM_REGISTRY'),                'https://registry.npmmirror.com',                           1, 1),
((SELECT id FROM pipeline_configs WHERE config_key = 'NPM_REGISTRY'),                'https://registry.npmjs.org',                               0, 2),
((SELECT id FROM pipeline_configs WHERE config_key = 'FRONTEND_DEPLOY_DIR'),         '/data/sdc/html',                                           1, 1);

-- =============================================================================
-- 4. 角色模块授权
-- =============================================================================

INSERT IGNORE INTO role_modules (role, module) VALUES ('operator', 'deploy');
