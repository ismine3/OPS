-- ============================================================
-- 用户环境权限表升级脚本
-- 影响范围：服务器管理、服务管理（按环境类型过滤可见性）
-- 兼容 MySQL 5.7+ / MariaDB 10.2+
-- ============================================================

-- 创建 user_env_permissions 表（如果不存在）
CREATE TABLE IF NOT EXISTS `user_env_permissions` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `user_id` INT NOT NULL COMMENT '用户ID',
    `env_type` VARCHAR(50) NOT NULL COMMENT '环境类型',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY `uk_user_env` (`user_id`, `env_type`),
    INDEX `idx_user_id` (`user_id`),
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='用户环境权限表';

SELECT 'user_env_permissions 表升级完成' AS result;
