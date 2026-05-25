-- =============================================================================
-- OPS 系统升级脚本 - 新增 system_config 表（内置任务参数可配置化）
-- =============================================================================
-- 版本: v3.0
-- 用途: 为已有部署添加 system_config 表，使内置定时任务（SSL证书检测、
--       域名到期通知、密码轮换）的执行时间和阈值天数可通过界面动态配置。
-- 幂等: 使用 IF NOT EXISTS 和 INSERT IGNORE，重复执行安全。
-- 用法: mysql -u root -p ops_platform < update.sql
-- =============================================================================

USE `ops_platform`;

-- =============================================================================
-- 1. 创建 system_config 表
-- =============================================================================
CREATE TABLE IF NOT EXISTS `system_config` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `config_key` VARCHAR(100) NOT NULL UNIQUE COMMENT '配置键',
    `config_value` VARCHAR(500) NOT NULL COMMENT '配置值',
    `description` VARCHAR(200) COMMENT '配置说明',
    `updated_at` DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='系统配置表';

-- =============================================================================
-- 2. 插入默认配置（保留现有环境变量值作为默认值）
-- =============================================================================
INSERT IGNORE INTO `system_config` (`config_key`, `config_value`, `description`) VALUES
('cert_auto_check_cron', '0 8 * * *',   'SSL证书自动检测Cron表达式（默认每天08:00执行）'),
('ssl_warning_days',     '30',           'SSL证书到期预警天数（距到期≤该天数时触发企业微信告警）'),
('domain_auto_notify_cron', '0 8 * * *', '域名到期通知Cron表达式（默认每天08:00执行）'),
('domain_warning_days',  '30',           '域名到期预警天数（距到期≤该天数时触发企业微信告警）'),
('password_rotation_cron','0 3 * * *',   '密码轮换检查Cron表达式（默认每天03:00执行）');

-- =============================================================================
-- 完成 - 重启后端服务后生效
-- =============================================================================
