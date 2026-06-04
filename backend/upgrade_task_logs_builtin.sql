-- 升级 task_logs 表，支持内置任务日志记录
-- 内置任务不在 scheduled_tasks 表中，需允许 task_id 为空并用 task_name 标识

-- 1. 删除原有外键约束（约束名可能因环境不同而异，先查询再删除）
-- MySQL 5.x/8.x 自动生成的外键名通常为 task_logs_ibfk_1
SET @fk_name = (
    SELECT CONSTRAINT_NAME 
    FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE 
    WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'task_logs' 
      AND COLUMN_NAME = 'task_id' 
      AND REFERENCED_TABLE_NAME IS NOT NULL
    LIMIT 1
);

SET @drop_fk_sql = IF(
    @fk_name IS NOT NULL,
    CONCAT('ALTER TABLE task_logs DROP FOREIGN KEY ', @fk_name),
    'SELECT 1'
);
PREPARE stmt FROM @drop_fk_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 2. task_id 改为可空
ALTER TABLE task_logs MODIFY COLUMN task_id INT NULL COMMENT '任务ID（内置任务为空）';

-- 3. 新增 task_name 列（幂等：先检查是否存在）
SET @col_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.COLUMNS 
    WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'task_logs' 
      AND COLUMN_NAME = 'task_name'
);

SET @add_col_sql = IF(
    @col_exists = 0,
    'ALTER TABLE task_logs ADD COLUMN task_name VARCHAR(100) NULL COMMENT ''任务名称（内置任务用）'' AFTER task_id',
    'SELECT 1'
);
PREPARE stmt FROM @add_col_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;

-- 4. 新增索引（幂等：先检查是否存在）
SET @idx_exists = (
    SELECT COUNT(*) 
    FROM INFORMATION_SCHEMA.STATISTICS 
    WHERE TABLE_SCHEMA = DATABASE() 
      AND TABLE_NAME = 'task_logs' 
      AND INDEX_NAME = 'idx_task_name'
);

SET @add_idx_sql = IF(
    @idx_exists = 0,
    'ALTER TABLE task_logs ADD INDEX idx_task_name (task_name)',
    'SELECT 1'
);
PREPARE stmt FROM @add_idx_sql;
EXECUTE stmt;
DEALLOCATE PREPARE stmt;
