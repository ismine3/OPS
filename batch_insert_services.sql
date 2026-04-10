-- ============================================
-- 批量插入服务数据
-- 自动添加服务分类到dict_service_categories（如不存在）
-- ============================================

-- 首先，确保所有需要的服务分类已存在
-- 检查并添加缺失的服务分类（使用INSERT IGNORE简化）
INSERT IGNORE INTO dict_service_categories (name, sort_order, created_at) VALUES
('关系型数据库', 1, NOW()),
('NoSQL数据库', 2, NOW()),
('分布式缓存', 3, NOW()),
('消息队列', 4, NOW()),
('搜索引擎', 5, NOW()),
('数据平台与大数据', 6, NOW()),
('计算服务', 7, NOW()),
('存储服务', 8, NOW()),
('网络服务', 9, NOW()),
('API网关与服务网格', 10, NOW()),
('微服务框架与运行时', 11, NOW()),
('服务发现与配置中心', 12, NOW()),
('前端与用户体验服务', 13, NOW()),
('日志、监控与可观测性', 14, NOW()),
('安全与身份认证', 15, NOW()),
('容器编排', 16, NOW()),
('CI/CD流水线', 17, NOW()),
('任务调度与工作流', 18, NOW()),
('可视化工具', 19, NOW()),
('流计算', 20, NOW());

-- ============================================
-- 批量插入服务数据
-- 注意：需要先确保servers表中存在对应的内网IP
-- ============================================

-- 172.24.11.7 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.11.2', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '37022', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848/9848', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000/9001', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '7.4.2', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '4369/5671/5672/15671/15672/15692', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.7';

-- 172.24.11.10 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '28.1.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.35.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '40022', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.20.1', '80/443/8080/8099/18080', '40080/40443/8098/8099', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tender-uas', '', '10103', '10103', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tender-bup', '', '10102', '10102', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'tender-gateway', '', '7777/8989', '27777/28989', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'tender-oauth', '', '10101', '10101', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.10';

-- 172.24.11.11 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '28.1.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.35.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '41022', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tender-uas', '', '10103', '10103', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tender-bup', '', '10102', '10102', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'tender-gateway', '', '7777/8989', '27777/28989', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'tender-oauth', '', '10101', '10101', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.11';

-- 172.24.11.12 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '28.1.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.35.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '42022', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848/9848', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000/9001', '11290/11291', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '7.4.2', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '4369/5671/5672/15671/15672/15692', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.12';

-- 172.24.11.16 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '22068', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'CI/CD流水线', 'nexus3', '', '8081', '18081', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.28.0', '80/443/8080/8443/18080', '11680/11643', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.16';

-- 172.24.11.17 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '22069', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'pay-pay', '', '31008', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'keepalived', '', '80/443/31508/10080', '12180/12143/12108/12181', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.27.5', '80/1072/5072/10080/10672/17091/180', '11780/11743', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.17';

-- 172.24.11.18 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '22070', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', '2.2.0', '8848/9848', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'pay-pay', '', '31008', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '7091/8091', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '数据平台与大数据', 'kafka-ui', '', '38080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'cp-kafka', '', '9092', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'zookeeper', '3.8.0', '2181', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '4369/5671/5672/15671/15672/15692', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000/9001', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'keepalived', '', '80/1072/5072/10080/10672/17091/180', '12280/12243/12208/12281', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.27.5', '80/19000/19001/31508', '11880/11843', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.18';

-- 172.24.11.19 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.39.2', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '22071', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', '2.2.0', '8848/9848', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '7091/8091', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '数据平台与大数据', 'kafka-ui', '', '38080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'cp-kafka', '', '9092', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'zookeeper', '3.8.0', '2181', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '4369/5671/5672/15671/15672/15692', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000/9001', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'haproxy', '', '23300/23306', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'keepalived', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.19';

-- 172.24.11.20 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.38.2', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '22072', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', '2.2.0', '8848/9848', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '7091/8091', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '数据平台与大数据', 'kafka-ui', '', '38080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'cp-kafka', '', '9092', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'zookeeper', '3.8.0', '2181', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '4369/5671/5672/15671/15672/15692', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000/9001', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'haproxy', '', '23300/23306', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'keepalived', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'cadvisor', '', '8080', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', NULL FROM servers WHERE inner_ip = '172.24.11.20';

-- 172.24.1.52 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '52002', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.13.2', '9200/9300', '52920/52930', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'mysql-exporter', '', '9104', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '52014', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '前端与用户体验服务', 'zentao', '', '8080', '52880', '', NULL FROM servers WHERE inner_ip = '172.24.1.52';

-- 172.24.1.53 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '53022', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '前端与用户体验服务', 'formal', '', '8888', '53888', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000/9001', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '', '80/443', '53080/53443', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'saas-biz', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'saas-pub', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'saas-oauth', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'saas-gateway', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.53';

-- 172.24.17.38 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '7.4p1', '22', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024T01ST133411Z', '9000/9001', '38900/38901', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.13.2', '9200/9300', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.28', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'NoSQL数据库', 'mongo', '7.0.0', '27017', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6', '6379', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'v2.4.3', '5671/5672/15671/15672', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848/9848', '', '', NULL FROM servers WHERE inner_ip = '172.24.17.38';

-- ============================================
-- 新增服务器数据（2026-04-10）
-- ============================================

-- 172.24.1.27 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '27022', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-order', '', '20016', '27016', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-pms', '', '20012', '27012', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-file', '', '20013', '27013', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'guan-oauth', '', '20011', '27011', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'guan-gateway', '', '20010', '27010', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-merchant', '', '20015', '27015', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-business', '', '20014', '27014', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '7091,8091,9898', '27791,27891', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos-server', 'v2.4.3', '28848,29848', '27848', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '可视化工具', 'rocketmq-dashboard', '', '8080', '27880', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rocketmq-mqbroker', '4.9.4', '9876,10909,10911,10912', '27876,27909,27911,27912', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rocketmq-mqnamesrv', '4.9.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '4369,5671,5672,15671,15672,15691,15692', '27672,27172', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '7.4.2', '26379', '27379', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '27000,27001', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'CI/CD流水线', 'jenkins-master', '', '18080,50000', '18027', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '23306', '27306', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.20.1', '80,443', '27080,27443', '', NULL FROM servers WHERE inner_ip = '172.24.1.27';

-- 172.24.1.28 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '14022', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '可视化工具', 'kibana', '7.17.18', '5601', '28561', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.17.18', '9200,9300', '28920,28930', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41-debian', '13306', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41-debian', '3306', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'nginx-prometheus-exporter', '', '9113', '9113', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', 'latest', '9100', '9128', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.20.1', '80,18080', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.28';

-- 172.24.1.31 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '15022', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'dj-server', '', '20000', '20031', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'clsp-file', '', '31010', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'clsp-visual-display', '', '31005', '31005', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'clsp-order', '', '31006', '31006', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'clsp-merchant', '', '31009', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'clsp-iam', '', '31004', '31004', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'clsp-oauth', '', '31001', '31001', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'clsp-gateway', '', '31000', '31000', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '3692,7091,8091,9898', '3692', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '前端与用户体验服务', 'clsp-swagger', '', '31002', '31002', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'tdgateway', '', '7777', '31777', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tdums', '', '31006', '31103', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'tdoauth', '', '31006', '31101', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tdbup', '', '10102', '31102', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'sentinel-dashboard', '', '8858,8989', '31989', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '可视化工具', 'kafka-ui', '', '8080', '20080', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'cp-kafka', '', '9092', '20092', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'zookeeper', '', '2181,2888,3888', '2181,2888,3888', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,15692', '20672,20156', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '23306', '23331', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '13306', '13331', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '31306', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'NoSQL数据库', 'mongo', '4.0.10', '27017', '13117', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '16379', '16331', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '6379', '63792', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '26379', '26331', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '19000,19001', '31190,31191', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '29031,29131', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '20000,20001', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848,9849', '18848,19848,19849', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.20.1', '80,8098,8099,10080,19002,20080,22080,31008,33080', '13180,28031,23180,31080,31443,31098,31099,31008,33080,33081', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.31';

-- 172.24.1.30 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '30022', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'park-file', '', '10102', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'park-ums', '', '10104', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'park-oauth', '', '10103', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'park-gateway', '', '10100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'park-bup', '', '10101', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tlxx-modules-system', '', '9016', '30916', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'tlxx-gateway', '', '9010', '30910', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tlxx-modules-annex', '', '9012', '30912', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tlxx-modules-magic-api', '', '9014', '30914', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tlxx-modules-monitor', '', '9011', '30911', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tlxx-modules-cms', '', '9018', '30918', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'tlxx_cms', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '3291,27091,29898', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '3191,17091,19898', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.5.2', '7091,8091', '30791,30891', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '26379', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '16379', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '6.2.6', '6379', '30379', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '15691,15692,4169,1671,1672,11671', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '4369,15691,4269,2671,2672,12671,12672,22672', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'CI/CD流水线', 'jenkins-slave', '', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'registry', '', '5000', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.12.1', '9200,9300', '30920,30930', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '19000,19001', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '30900', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'NoSQL数据库', 'mongo', '4.0.10', '27017', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41-debian', '3306', '30306', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41-debian', '23306', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41-debian', '13306', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.18.0', '80,10003,10004,10005', '19080,30103,30104,30105', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v1.4.2', '8848,9848', '30848', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '18848,19848,19849', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '28848,29848,29849', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.30';

-- 172.24.1.29 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '29022', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.17.18', '9200,9300', '29920,29930', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '33306', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '59000,59001', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '6379', '56379', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v1.4.2', '8848,9848', '58848', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,15692,25672', '55672,56725', '', NULL FROM servers WHERE inner_ip = '172.24.1.29';

-- 172.24.1.32 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '18022', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'vehicle-bup', '', '11112', '32112', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'vehicle-ums', '', '11113', '32113', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'vehicle-oauth', '', '11111', '32111', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'attractinv', '', '9002', '9002', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'saas-gateway', '', '8989', '32989', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'vehicle-gateway', '', '9999', '29999', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'saas-gateway', '', '10200', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'saas-oauth', '', '10103', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'saas-pub', '', '10101', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'saas-file', '', '10102', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'saas-biz', '', '10204', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.20.1', '80,19002', '32080,19002', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '', '3306', '25306', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '6379', '23379', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '23000', '', NULL FROM servers WHERE inner_ip = '172.24.1.32';

-- 172.24.1.33 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '19022', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '6379', '26379', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '', '3306', '23306', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', '', '9000,9001', '39000,9001', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', '', '8848,9848', '28848', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', '', '5671,5672,15671,15672,15691,15692,25672', '33672', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '', '80', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.33';

-- 172.24.1.36 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '28.0.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.34.0', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '20022', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'oa-oauth', '', '11111', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'oa-project', '', '10089', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'oa-gateway', '', '9999', '22999', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'oa-oa', '', '10087', '10087', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'oa-meeting', '', '10086', '10086', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'oa-asset', '', '10088', '10088', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'oa-camunda', '', '10076', '10076', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'oa-file', '', '10100', '10100', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'oa-bup', '', '11112', '11112', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-file', '', '20013', '20013', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-order', '', '20016', '20016', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-merchant', '', '20015', '20015', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-business', '', '20014', '20014', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'guan-oauth', '', '20011', '20011', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'guan-gateway', '', '20010', '20010', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'guan-pms', '', '20012', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'dc-pay', '', '38666', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'seata-server', '1.6.1', '3691,7091,9898,8091', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '28848,29848,29849', '20008', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,25672', '36672,36172', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '37672,30672,37671,35672,37673', '35672,30672', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.13.2', '9200,9300', '36920', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'NoSQL数据库', 'mongo', '4.0.10', '37107', '37107', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '36379', '21379', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '26379', '20009', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '33306', '21306', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '23306', '20006', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '39000,39001', '21000,39001', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '29000,29001', '29000,29001', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.20.1', '80,443,30080', '22080,22443,21080', '', NULL FROM servers WHERE inner_ip = '172.24.1.36';

-- 172.24.1.34 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '28.0.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.34.0', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '21022', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.13.2', '9201,9301', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '7.13.2', '9200,9300', '49200', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '9100', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-09-09T16-59-28Z', '9000,9001', '24000,24001', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '48848', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '43306', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '6379', '46379', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'redis-exporter', '', '9121', '9121', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'mysqld-exporter', '', '9104', '9104', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '5671,5672,15671,15672,15691,15692,25672', '24672,24156', '', NULL FROM servers WHERE inner_ip = '172.24.1.34';

-- 172.24.1.35 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '22022', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'eps-biz', '', '10014,10026', '10014,10026', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'API网关与服务网格', 'eps-gateway', '', '9999', '35999', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '安全与身份认证', 'eps-oauth', '', '10011', '10011', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '微服务框架与运行时', 'eps-pms', '', '10012', '10012', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'nginx', '1.20.1', '80', '16080', '', NULL FROM servers WHERE inner_ip = '172.24.1.35';

-- 172.24.1.51 服务器的服务
INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker', '26.1.4', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '容器编排', 'docker-compose', 'v2.27.1', '', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '网络服务', 'ssh', '', '22', '51022', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '存储服务', 'minio', 'RELEASE.2024-10-13T13-34-11Z', '9000,9001', '19000,19001', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, 'NoSQL数据库', 'mongo', '4.0.10', '27017', '57037', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '搜索引擎', 'elasticsearch', '4.0.10', '9200,9300', '19200', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '可视化工具', 'kafka-ui', '', '8000', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'cp-kafka', '', '9092', '9092', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '消息队列', 'rabbitmq', 'management', '5671,5672,4369,15671,15672,15691,15692,25672', '51672', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'zookeeper', '', '2181,2888,3888', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '流计算', 'flink', '1.13.2', '6123,8081,15005', '28081,15005', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '服务发现与配置中心', 'nacos', 'v2.4.3', '8848,9848', '51848', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '分布式缓存', 'redis', '', '6379', '16379', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '关系型数据库', 'mysql', '8.0.41', '3306', '13306', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';

INSERT INTO services (server_id, category, service_name, version, inner_port, mapped_port, remark, project_id) 
SELECT id, '日志、监控与可观测性', 'node-exporter', '', '9100', '', '', NULL FROM servers WHERE inner_ip = '172.24.1.51';
