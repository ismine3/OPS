-- =============================================================================
--  服务管理：project_id 一对多改造
--  支持一个服务关联多个项目（如 nacos、mysql 等共用服务）
-- =============================================================================

-- 1. 创建关联表
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

-- 2. 迁移现有数据：把 services.project_id 转入 service_projects
INSERT IGNORE INTO service_projects (service_id, project_id)
SELECT id, project_id FROM services WHERE project_id IS NOT NULL;

-- 3. 删除 services 表中已废弃的 project_id 列
--    先用存储过程安全删除
DROP PROCEDURE IF EXISTS `drop_column_if_exists`;
DELIMITER //
CREATE PROCEDURE `drop_column_if_exists`(
    IN tbl_name VARCHAR(128),
    IN col_name VARCHAR(128)
)
BEGIN
    SET @cnt = 0;
    SELECT COUNT(*) INTO @cnt
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = DATABASE()
      AND TABLE_NAME = tbl_name
      AND COLUMN_NAME = col_name;
    IF @cnt > 0 THEN
        SET @sql = CONCAT('ALTER TABLE `', tbl_name, '` DROP COLUMN `', col_name, '`');
        PREPARE stmt FROM @sql;
        EXECUTE stmt;
        DEALLOCATE PREPARE stmt;
        SELECT CONCAT('Dropped column ', col_name, ' from ', tbl_name) AS result;
    ELSE
        SELECT CONCAT('Column ', col_name, ' already absent from ', tbl_name) AS result;
    END IF;
END//
DELIMITER ;

CALL drop_column_if_exists('services', 'project_id');
DROP PROCEDURE IF EXISTS `drop_column_if_exists`;
