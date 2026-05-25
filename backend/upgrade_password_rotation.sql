-- =============================================================================
-- OPS 数据库升级脚本 — 服务器密码定期轮换功能 + 字段重命名
-- =============================================================================
-- 用途: 为 servers 表增加密码轮换相关字段，将 docker_user/docker_password
--       重命名为 regular_user/regular_password，创建密码轮换日志表。
--
-- 用法:  mysql -u root -p ops_platform < upgrade_password_rotation.sql
--
-- 幂等:  所有 DDL 通过 INFORMATION_SCHEMA 检测后执行，
--        重复执行不会报错或产生重复数据。
-- =============================================================================

-- =============================================================================
-- 1. 创建存储过程 — 安全添加列（列不存在才添加）
-- =============================================================================
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

-- =============================================================================
-- 2. 为 servers 表添加密码定期更新相关字段
-- =============================================================================
CALL add_column_if_not_exists('servers', 'password_rotation_enabled',
    '`password_rotation_enabled` TINYINT(1) DEFAULT 0 COMMENT "是否启用定期更新密码 0:否 1:是"');
CALL add_column_if_not_exists('servers', 'password_rotation_days',
    '`password_rotation_days` INT DEFAULT 30 COMMENT "密码更新周期(天)"');
CALL add_column_if_not_exists('servers', 'password_last_rotated_at',
    '`password_last_rotated_at` DATETIME DEFAULT NULL COMMENT "上次更新密码时间"');
CALL add_column_if_not_exists('servers', 'password_rotation_status',
    '`password_rotation_status` VARCHAR(20) DEFAULT "idle" COMMENT "密码轮换状态: idle/running/success/failed"');
CALL add_column_if_not_exists('servers', 'password_rotation_error',
    '`password_rotation_error` TEXT DEFAULT NULL COMMENT "最近一次密码更新失败的错误信息"');

-- =============================================================================
-- 3. 重命名 docker_user/docker_password → regular_user/regular_password
--    仅在旧列名存在且新列名不存在时执行
-- =============================================================================

-- 3.1 创建重命名存储过程
DROP PROCEDURE IF EXISTS `rename_column_if_needed`;

DELIMITER //
CREATE PROCEDURE `rename_column_if_needed`(
    IN tbl_name VARCHAR(128),
    IN old_name VARCHAR(128),
    IN new_name VARCHAR(128),
    IN col_def TEXT
)
BEGIN
    DECLARE old_cnt INT DEFAULT 0;
    DECLARE new_cnt INT DEFAULT 0;

    SELECT COUNT(*) INTO old_cnt
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl_name
      AND COLUMN_NAME = old_name;

    SELECT COUNT(*) INTO new_cnt
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl_name
      AND COLUMN_NAME = new_name;

    IF old_cnt > 0 AND new_cnt = 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', tbl_name,
                          '` CHANGE COLUMN `', old_name, '` ', col_def);
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('已重命名 ', tbl_name, '.', old_name, ' → ', new_name) AS result;
    END IF;
END//
DELIMITER ;

-- 3.2 执行重命名
CALL rename_column_if_needed('servers', 'docker_user', 'regular_user',
    '`regular_user` VARCHAR(100) COMMENT "普通用户名"');
CALL rename_column_if_needed('servers', 'docker_password', 'regular_password',
    '`regular_password` VARCHAR(255) COMMENT "普通用户密码"');

-- =============================================================================
-- 4. 创建密码轮换日志表
-- =============================================================================
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

-- =============================================================================
-- 5. 清理存储过程（可选，不留存过程依赖）
-- =============================================================================
DROP PROCEDURE IF EXISTS `add_column_if_not_exists`;
DROP PROCEDURE IF EXISTS `rename_column_if_needed`;

-- =============================================================================
-- 完成
-- =============================================================================
