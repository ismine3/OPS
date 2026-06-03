-- =============================================================================
-- OPS 数据库升级脚本 — 服务端口映射表改造
-- =============================================================================
-- 用途: 创建 service_ports 表替代 services 表中逗号分隔的 inner_port/mapped_port，
--       实现内网端口与外网映射端口的一对一映射关系。
--       迁移已有数据到新表中。
--
-- 用法:  mysql -u root -p ops_platform < upgrade_service_ports.sql
--
-- 幂等:  所有 DDL 使用 IF NOT EXISTS，重复执行安全。
-- =============================================================================

USE `ops_platform`;

-- =============================================================================
-- 1. 创建 service_ports 表
-- =============================================================================
CREATE TABLE IF NOT EXISTS `service_ports` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `service_id` INT NOT NULL COMMENT '服务ID',
    `inner_port` INT NOT NULL COMMENT '内网端口',
    `mapped_port` INT DEFAULT NULL COMMENT '外网映射端口',
    `protocol` VARCHAR(10) DEFAULT 'TCP' COMMENT '协议: TCP/UDP/HTTP/HTTPS',
    `remark` VARCHAR(100) COMMENT '备注',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX `idx_service_id` (`service_id`),
    FOREIGN KEY (`service_id`) REFERENCES `services`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='服务端口映射表';

-- =============================================================================
-- 2. 创建存储过程 — 迁移逗号分隔端口数据到 service_ports
-- =============================================================================
DROP PROCEDURE IF EXISTS `migrate_service_ports`;

DELIMITER //
CREATE PROCEDURE `migrate_service_ports`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE v_id INT;
    DECLARE v_inner TEXT;
    DECLARE v_mapped TEXT;
    DECLARE cur CURSOR FOR
        SELECT id, inner_port, mapped_port
        FROM services
        WHERE inner_port IS NOT NULL AND inner_port != '';
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO v_id, v_inner, v_mapped;
        IF done THEN
            LEAVE read_loop;
        END IF;

        -- 解析内网端口列表
        SET @inner_list = v_inner;
        SET @mapped_list = IFNULL(v_mapped, '');
        SET @pos = 1;

        WHILE CHAR_LENGTH(@inner_list) > 0 DO
            -- 取第 @pos 个内网端口
            SET @inner_val = TRIM(SUBSTRING_INDEX(@inner_list, ',', 1));
            SET @inner_list = SUBSTRING(@inner_list, CHAR_LENGTH(@inner_val) + 2);

            -- 取对应的映射端口
            IF CHAR_LENGTH(@mapped_list) > 0 THEN
                SET @mapped_val = TRIM(SUBSTRING_INDEX(@mapped_list, ',', 1));
                SET @mapped_list = SUBSTRING(@mapped_list, CHAR_LENGTH(@mapped_val) + 2);
            ELSE
                SET @mapped_val = NULL;
            END IF;

            -- 插入映射记录（跳过已存在的重复数据）
            IF @inner_val REGEXP '^[0-9]+$' THEN
                INSERT IGNORE INTO service_ports (service_id, inner_port, mapped_port)
                VALUES (v_id, CAST(@inner_val AS UNSIGNED),
                        IF(@mapped_val REGEXP '^[0-9]+$', CAST(@mapped_val AS UNSIGNED), NULL));
            END IF;
        END WHILE;

    END LOOP;
    CLOSE cur;
END//
DELIMITER ;

-- =============================================================================
-- 3. 执行数据迁移
-- =============================================================================
CALL migrate_service_ports();

-- =============================================================================
-- 4. 清理存储过程
-- =============================================================================
DROP PROCEDURE IF EXISTS `migrate_service_ports`;

-- =============================================================================
-- 5. 迁移完成后删除旧字段（确认数据完整后执行）
-- =============================================================================
-- 使用存储过程实现幂等删除（兼容 MySQL 5.7+ 无 IF EXISTS 语法）
DROP PROCEDURE IF EXISTS `drop_column_if_exists`;

DELIMITER //
CREATE PROCEDURE `drop_column_if_exists`()
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.COLUMNS
               WHERE TABLE_SCHEMA = 'ops_platform'
                 AND TABLE_NAME = 'services'
                 AND COLUMN_NAME = 'inner_port') THEN
        ALTER TABLE `services` DROP COLUMN `inner_port`;
    END IF;
    IF EXISTS (SELECT 1 FROM information_schema.COLUMNS
               WHERE TABLE_SCHEMA = 'ops_platform'
                 AND TABLE_NAME = 'services'
                 AND COLUMN_NAME = 'mapped_port') THEN
        ALTER TABLE `services` DROP COLUMN `mapped_port`;
    END IF;
END//
DELIMITER ;

CALL `drop_column_if_exists`();
DROP PROCEDURE IF EXISTS `drop_column_if_exists`;

-- =============================================================================
-- 完成 — 重启后端服务后新端口映射逻辑生效
-- =============================================================================
