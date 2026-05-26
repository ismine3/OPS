# OPS - 运维平台

> 一个现代化的基础设施运维管理平台，专注于服务器、域名、SSL证书、阿里云账号等资源的集中化管理与自动化监控。

[![Vue 3](https://img.shields.io/badge/Vue-3.5-brightgreen.svg)](https://vuejs.org/)
[![Flask](https://img.shields.io/badge/Flask-3.0-blue.svg)](https://flask.palletsprojects.com/)
[![MySQL](https://img.shields.io/badge/MySQL-8.0-orange.svg)](https://www.mysql.com/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 📋 目录

- [项目简介](#项目简介)
- [核心功能](#核心功能)
- [技术栈](#技术栈)
- [系统架构](#系统架构)
- [快速开始](#快速开始)
- [项目结构](#项目结构)
- [配置说明](#配置说明)
- [API 文档](#api-文档)
- [部署指南](#部署指南)
- [开发指南](#开发指南)
- [常见问题](#常见问题)
- [贡献指南](#贡献指南)

## 🎯 项目简介

OPS（运维平台）是一个前后端分离的全栈运维管理系统，旨在帮助运维团队高效管理服务器资源、监控SSL证书和域名到期时间、集成Grafana监控看板，并提供自动化的告警通知机制。

**主要特点：**
- 🚀 前后端分离架构，部署灵活
- 📊 直观的可视化仪表盘，数据一目了然
- 🔔 自动化监控与告警，支持企业微信通知
- 🔐 JWT认证 + 数据加密，安全可靠
- 🐳 Docker一键部署，开箱即用
- 📱 响应式设计，支持移动端访问

## ✨ 核心功能

### 1. 仪表盘 (Dashboard) 🔒 管理员专属
- 资源概览卡片：服务器、项目、服务、账号、域名统计
- 可视化饼图：服务器环境占比、服务类型占比、账号类型占比、项目服务器占比
- 到期提醒：域名/SSL证书即将到期提醒列表
- 快捷导航：点击卡片快速跳转到对应管理页面
- 仅管理员可访问，非管理员自动跳转至服务器管理

### 2. 服务器管理
- 服务器CRUD操作（创建、查询、更新、删除）
- 环境类型分类（由字典动态管理）
- SSH远程连接与脚本执行
- 项目关联管理
- 服务器详情页展示
- 🔐 环境类型权限过滤：非管理员仅可见授权环境的服务器
- 密码字段加密存储（Fernet对称加密）

### 3. 项目管理
- 项目信息管理
- 关联服务器、应用、域名、证书
- 项目详情页面，集中展示所有关联资源
- 项目服务器统计与可视化

### 4. SSL证书管理
- 证书信息录入与管理
- SSL证书自动检测（支持定时任务）
- 证书到期预警（可配置预警天数）
- 手动触发微信告警通知
- 阿里云证书同步与下载
- 证书文件上传（PEM格式）

### 5. 域名管理
- 域名信息登记与管理
- 域名到期自动监控
- 到期预警通知
- 阿里云域名同步（自动更新到期日期和剩余天数）
- 域名所有者管理

### 6. 阿里云账号管理
- 多云账号集中管理
- AccessKey安全管理
- 账号类型分类统计

### 7. 服务管理
- 服务信息登记（服务器关联、分类、版本、端口）
- 🔐 服务账户与密码管理（加密存储，支持复制）
- 关键词搜索（服务名/IP 模糊匹配）
- 环境类型权限过滤：非管理员仅可见授权环境的服务
- 服务分类统计与可视化

### 8. 部署配置
- 流水线文件一键生成（Jenkinsfile / Dockerfile / 部署脚本 / Docker Compose）
- Docker Registry 镜像仓库配置
- SSH 远程部署配置
- Git 仓库与分支配置
- 企业微信通知配置
- 前端构建配置（Node.js 镜像、构建命令、输出目录）
- 配置历史记录与 Zip 打包下载
- 按 pipeline_type（backend/frontend）区分配置分组

### 9. 用户与权限
- 三级角色控制（Admin / Operator / Viewer）
- JWT Token 认证
- 密码加密存储（bcrypt）
- 🔐 环境类型用户授权：管理员可为非管理员配置可见的环境类型
- 📋 角色模块授权：管理员可为 Operator/Viewer 配置模块级访问权限
- 修改密码功能

### 10. 监控集成
- Grafana监控看板嵌入
- 主机监控（预设看板）
- 容器监控（预设看板）
- 自定义Grafana URL配置

### 11. 任务调度
- 定时任务管理（APScheduler）
- SSL证书自动检测（默认每天8:00）
- 域名到期通知（默认每天8:00）
- 可配置的Cron表达式

### 12. 操作日志 🔒 管理员专属
- 完整的操作审计日志
- 操作人、操作时间、操作内容记录
- 日志查询与筛选
- 仅管理员可查看

### 13. 数据导出 🔒 管理员专属
- Excel格式导出（服务器/服务/应用/域名/证书多Sheet）
- 仅管理员可导出

### 14. 字典管理
- 环境类型、平台、服务分类、项目状态等字典动态配置

## 🛠 技术栈

### 后端
- **框架**: Flask 3.0+
- **数据库**: MySQL 8.0 (PyMySQL驱动)
- **认证**: PyJWT 2.8+
- **定时任务**: APScheduler 3.10+
- **SSH连接**: Paramiko 3.0+
- **数据加密**: Cryptography 41.0+
- **密码哈希**: Bcrypt 4.0+
- **阿里云SDK**: 
  - alibabacloud_domain20180129
  - alibabacloud_cas20200407
- **Excel处理**: OpenPyXL 3.1+
- **CORS**: Flask-CORS 4.0+
- **生产服务器**: Gunicorn 22.0+

### 前端
- **框架**: Vue 3.5+ (Composition API)
- **构建工具**: Vite 8.0+
- **UI组件库**: Element Plus 2.13+
- **图标**: @element-plus/icons-vue
- **HTTP客户端**: Axios 1.7+
- **状态管理**: Pinia 3.0+
- **路由**: Vue Router 4.6+
- **图表**: ECharts 6.0+
- **语言**: TypeScript

### 部署与运维
- **容器化**: Docker + Docker Compose
- **Web服务器**: Nginx Alpine
- **网络**: 自定义桥接网络

## 🏗 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                        用户浏览器                             │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP/HTTPS
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                    Nginx (前端静态服务)                       │
│                  代理 /api 到后端服务                         │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────────┐
│                  Flask Backend (API服务)                      │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │ 认证模块  │ │ 业务逻辑  │ │ 定时任务  │ │ 阿里云集成    │   │
│  └──────────┘ └──────────┘ └──────────┘ └──────────────┘   │
└──────────┬───────────────────────────────┬──────────────────┘
           │                               │
           ▼                               ▼
┌──────────────────┐          ┌────────────────────────────┐
│   MySQL 8.0      │          │   Grafana 监控看板          │
│  ops_platform    │          │   (外部集成)                │
└──────────────────┘          └────────────────────────────┘
```

### 数据流
1. 用户通过浏览器访问前端页面（Nginx托管）
2. 前端通过 `/api/*` 发起HTTP请求
3. Nginx将 `/api` 请求代理到Flask后端
4. 后端处理业务逻辑，读写MySQL数据库
5. 定时任务自动执行SSL检测和域名监控
6. 告警信息通过企业微信Webhook推送

## 🚀 快速开始

### 前置要求

- Docker 20.10+
- Docker Compose 1.29+
- Git

### 方式一：Docker一键部署（推荐）

```bash
# 1. 克隆项目
git clone https://github.com/ismine3/OPS.git
cd OPS

# 2. 启动服务
docker-compose up -d

# 3. 初始化数据库
docker exec -it ops-backend python init_db.py

# 4. 访问应用
# 前端: http://localhost
# 后端API: http://localhost:5000/api
```

### 方式二：本地开发环境

#### 后端启动

```bash
cd backend

# 创建虚拟环境
python -m venv venv
source venv/bin/activate  # Linux/Mac
# 或
venv\Scripts\activate     # Windows

# 安装依赖
pip install -r requirements.txt

# 配置环境变量（复制并修改）
cp .env.example .env

# 初始化数据库
python init_db.py

# 启动开发服务器
python run.py
```

#### 前端启动

```bash
cd frontend

# 安装依赖
npm install

# 启动开发服务器
npm run dev

# 访问 http://localhost:5173
```

#### 生产构建

```bash
cd frontend

# 构建生产版本
npm run build

# 构建产物在 dist/ 目录
# Docker会自动使用此目录
```

## 📁 项目结构

```
OPS/
├── backend/                    # 后端Flask应用
│   ├── app/
│   │   ├── api/               # API路由模块
│   │   │   ├── auth.py        # 认证接口
│   │   │   ├── dashboard.py   # 仪表盘统计
│   │   │   ├── servers.py     # 服务器管理
│   │   │   ├── projects.py    # 项目管理
│   │   │   ├── pipeline.py    # 部署配置
│   │   │   ├── certs.py       # SSL证书管理
│   │   │   ├── domains.py     # 域名管理
│   │   │   ├── apps.py        # 应用管理
│   │   │   ├── services.py    # 服务管理
│   │   │   ├── aliyun_accounts.py  # 阿里云账号
│   │   │   ├── users.py       # 用户管理
│   │   │   ├── role_modules.py # 角色模块授权
│   │   │   ├── monitoring.py  # 监控集成
│   │   │   ├── tasks.py       # 任务调度
│   │   │   ├── dicts.py       # 字典管理
│   │   │   ├── export.py      # 数据导出
│   │   │   └── operation_logs.py  # 操作日志
│   │   ├── models/            # 数据模型
│   │   │   ├── user.py
│   │   │   └── role_module.py  # 角色模块授权
│   │   ├── utils/             # 工具模块
│   │   │   ├── auth.py        # JWT认证
│   │   │   ├── db.py          # 数据库连接
│   │   │   ├── scheduler.py   # 定时任务
│   │   │   ├── ssl_checker.py # SSL检测
│   │   │   ├── script_runner.py # 脚本执行
│   │   │   ├── validators.py  # 数据验证
│   │   │   ├── operation_log.py # 操作日志
│   │   │   ├── decorators.py  # 权限装饰器
│   │   │   ├── schema.py      # 表结构定义
│   │   │   └── password_utils.py # 密码工具
│   │   ├── uploads/           # 文件上传目录
│   │   │   ├── pipelines/templates/ # Jenkinsfile 模板
│   │   │   └── scripts/            # 部署脚本
│   │   ├── config.py          # 配置管理
│   │   └── extensions.py      # Flask扩展
│   ├── Dockerfile
│   ├── upgrade_pipeline.py    # 流水线表迁移脚本
│   ├── upgrade_pipeline.sql
│   ├── upgrade_services.sql   # 服务表迁移脚本
│   ├── requirements.txt       # Python依赖
│   ├── run.py                 # 应用入口
│   └── init_db.py             # 数据库初始化
│
├── frontend/                   # 前端Vue应用
│   ├── src/
│   │   ├── api/               # API请求模块
│   │   │   ├── request.ts     # Axios配置
│   │   │   └── *.ts           # 各模块API
│   │   ├── views/             # 页面组件
│   │   │   ├── Dashboard.vue  # 仪表盘
│   │   │   ├── Servers.vue    # 服务器管理
│   │   │   ├── Projects.vue   # 项目管理
│   │   │   ├── Certs.vue      # 证书管理
│   │   │   ├── Domains.vue    # 域名管理
│   │   │   └── ...
│   │   ├── components/        # 公共组件
│   │   │   └── PasswordDisplay.vue  # 密码展示/复制组件
│   │   ├── layouts/           # 布局组件
│   │   │   └── MainLayout.vue
│   │   ├── router/            # 路由配置
│   │   ├── stores/            # Pinia状态管理
│   │   ├── types/             # TypeScript类型定义
│   │   ├── utils/             # 工具函数
│   │   ├── App.vue
│   │   └── main.ts
│   ├── public/                # 静态资源
│   ├── dist/                  # 构建产物
│   ├── package.json
│   ├── vite.config.ts
│   └── tsconfig.json
│
├── docker-compose.yml          # Docker编排文件
├── nginx.conf                  # Nginx配置
└── README.md                   # 项目文档
```

## ⚙️ 配置说明

### 环境变量

在 `docker-compose.yml` 中配置以下关键参数：

#### 数据库配置
```yaml
DB_HOST: mysql
DB_PORT: "3306"
DB_USER: root
DB_PASSWORD: your-mysql-password  # 修改为强密码
DB_NAME: ops_platform
```

#### 安全配置
```yaml
SECRET_KEY: "your-secret-key"           # Flask密钥
JWT_SECRET_KEY: "your-jwt-secret"       # JWT加密密钥
JWT_EXPIRATION_HOURS: "24"              # Token过期时间（小时）
DATA_ENCRYPTION_KEY: "your-encryption-key"  # 数据加密密钥
```

#### CORS配置
```yaml
CORS_ORIGINS: "http://localhost,https://yourdomain.com"
CORS_ALLOW_ALL: "false"
```

#### 自动化任务配置
```yaml
CERT_AUTO_CHECK_CRON: "0 8 * * *"       # SSL证书检测（每天8:00）
DOMAIN_AUTO_NOTIFY_CRON: "0 8 * * *"    # 域名通知（每天8:00）
SSL_WARNING_DAYS: "30"                  # SSL预警天数
DOMAIN_WARNING_DAYS: "30"               # 域名预警天数
```

#### 企业微信通知
```yaml
WECHAT_WEBHOOK_URL: ""  # 填入企业微信群机器人Webhook地址
```

#### Grafana集成
```yaml
GRAFANA_URL: "https://your-grafana-url"
GRAFANA_DASHBOARDS: '[
  {"name":"主机监控","uid":"StarsL-JOB-node"},
  {"name":"容器监控","uid":"pMEd7m0Mz"}
]'
```

### Cloudflare配置提示

> ⚠️ **注意**: 若使用Cloudflare且源站仅开放80端口：
> - 面板SSL请选「灵活」(Flexible)模式
> - 否则CF用HTTPS回源而源站无443证书时会出现502错误

## 📖 API 文档

### 认证接口

#### 登录
```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "your_password"
}

Response:
{
  "code": 200,
  "data": {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### 获取当前用户信息
```http
GET /api/auth/current
Authorization: Bearer <token>
```

### 仪表盘接口

#### 获取统计数据 🔒 管理员
```http
GET /api/dashboard/stats
Authorization: Bearer <token>

Response:
{
  "code": 200,
  "data": {
    "counts": {
      "servers": 10,
      "projects": 5,
      "services": 20,
      "accounts": 8,
      "domains": 15,
      "certs": 12,
      "expiring_certs": 3,
      "expiring_domains": 2
    },
    "env_distribution": [...],
    "service_distribution": [...],
    "account_distribution": [...],
    "project_distribution": [...],
    "recent_certs": [...]
  }
}
```

### 完整API列表

| 模块 | 基础路径 | 权限 | 说明 |
|------|---------|------|------|
| 认证 | `/api/auth` | 公开/登录 | 登录、用户信息、修改密码 |
| 仪表盘 | `/api/dashboard` | 🔒 Admin | 统计数据 |
| 服务器 | `/api/servers` | 模块授权 + 环境过滤 | 服务器CRUD |
| 项目 | `/api/projects` | 模块授权 | 项目管理 |
| SSL证书 | `/api/certs` | 模块授权 | 证书管理、检测、通知 |
| 域名 | `/api/domains` | 模块授权 | 域名管理、同步、通知 |
| 阿里云账号 | `/api/credentials` | 🔒 Admin | 多云账号管理（含 AK/SK 加密存储） |
| 应用 | `/api/apps` | 模块授权 | 账号台账管理 |
| 服务 | `/api/services` | 模块授权 + 环境过滤 | 服务管理（含账户密码） |
| 部署配置 | `/api/pipeline` | 模块授权 | 流水线文件生成与配置管理 |
| 用户 | `/api/users` | 🔒 Admin | 用户CRUD、环境权限配置 |
| 用户环境权限 | `/api/users/<id>/env-permissions` | 🔒 Admin | 用户环境类型授权 |
| 角色模块 | `/api/role-modules` | 🔒 Admin | 角色模块级授权 |
| 监控 | `/api/monitoring` | 模块授权 | Grafana集成 |
| 任务 | `/api/tasks` | 模块授权 | 定时任务 |
| 字典 | `/api/dicts` | 登录即可 | 字典数据 |
| 导出 | `/api/export` | 🔒 Admin | 数据导出 |
| 操作日志 | `/api/operation-logs` | 🔒 Admin | 审计日志 |

## 🚢 部署指南

### Docker Compose部署

#### 1. 准备工作

```bash
# 确保Docker和Docker Compose已安装
docker --version
docker-compose --version

# 克隆项目
git clone https://github.com/ismine3/OPS.git
cd OPS
```

#### 2. 修改配置

编辑 `docker-compose.yml`，修改以下配置：
- `DB_PASSWORD`: 数据库密码
- `SECRET_KEY`: Flask密钥
- `JWT_SECRET_KEY`: JWT密钥
- `DATA_ENCRYPTION_KEY`: 数据加密密钥
- `CORS_ORIGINS`: 允许的域名
- `WECHAT_WEBHOOK_URL`: 企业微信Webhook（可选）

#### 3. 启动服务

```bash
# 启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

#### 4. 初始化数据库

```bash
# 首次运行需要初始化数据库
docker exec -it ops-backend python init_db.py
```

#### 5. 访问应用

- **前端**: http://localhost
- **后端API**: http://localhost:5000/api
- **MySQL**: localhost:3306

### Nginx反向代理配置

项目根目录的 `nginx.conf` 已配置好反向代理：

```nginx
server {
    listen 80;
    server_name yourdomain.com;
    
    # 前端静态文件
    location / {
        root /usr/share/nginx/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }
    
    # 后端API代理
    location /api {
        proxy_pass http://backend:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

### HTTPS配置

使用Let's Encrypt免费证书：

```bash
# 安装certbot
sudo apt install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d yourdomain.com

# 自动续期
sudo certbot renew --dry-run
```

## 💻 开发指南

### 后端开发

```bash
cd backend

# 激活虚拟环境
source venv/bin/activate

# 启动开发服务器（热重载）
python run.py

# 添加新的API路由
# 1. 在 app/api/ 创建新文件
# 2. 在 app/__init__.py 注册蓝图
# 3. 实现CRUD逻辑
```

#### 添加新模块示例

```python
# app/api/example.py
from flask import Blueprint, jsonify
from ..utils.decorators import jwt_required

example_bp = Blueprint('example', __name__, url_prefix='/api/example')

@example_bp.route('', methods=['GET'])
@jwt_required
def get_examples():
    """获取示例列表"""
    return jsonify({
        'code': 200,
        'data': []
    })
```

```python
# app/__init__.py
from .api.example import example_bp

def create_app():
    # ...
    app.register_blueprint(example_bp)
    # ...
```

### 前端开发

```bash
cd frontend

# 启动开发服务器
npm run dev

# 访问 http://localhost:5173
```

#### 添加新页面

```vue
<!-- src/views/Example.vue -->
<template>
  <div class="example-container">
    <h1>示例页面</h1>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
</script>
```

```typescript
// src/router/index.ts
import Example from '../views/Example.vue'

const routes = [
  // ...
  {
    path: '/example',
    name: 'Example',
    component: Example
  }
]
```

### 数据库迁移

```bash
# 进入后端容器
docker exec -it ops-backend bash

# 执行SQL脚本
mysql -h mysql -u root -p ops_platform < migration.sql
```

## ❓ 常见问题

### 1. 数据库连接失败

**问题**: `Can't connect to MySQL server`

**解决**:
```bash
# 检查MySQL是否启动
docker-compose ps

# 查看MySQL日志
docker logs ops-mysql

# 确保backend配置了正确的DB_HOST=mysql
```

### 2. 前端页面空白

**问题**: 访问前端页面显示空白

**解决**:
```bash
# 检查是否已构建前端
ls frontend/dist/

# 重新构建
cd frontend && npm run build

# 重启frontend容器
docker-compose restart frontend
```

### 3. CORS跨域错误

**问题**: `Access-Control-Allow-Origin` 错误

**解决**:
```yaml
# docker-compose.yml
environment:
  CORS_ORIGINS: "http://yourdomain.com,https://yourdomain.com"
  CORS_ALLOW_ALL: "false"  # 生产环境设为false
```

### 4. SSL检测失败

**问题**: SSL证书检测超时或失败

**解决**:
```yaml
# 增加超时时间
SSL_CHECK_TIMEOUT: "15"

# 检查服务器网络是否可达
docker exec -it ops-backend ping target-domain.com
```

### 5. 定时任务不执行

**问题**: SSL检测或域名通知未自动执行

**解决**:
```bash
# 查看后端日志
docker logs ops-backend | grep scheduler

# 检查Cron表达式
CERT_AUTO_CHECK_CRON: "0 8 * * *"  # 每天8:00

# 手动触发
# 通过前端页面手动执行检测
```

### 6. 企业微信通知收不到

**问题**: Webhook通知发送失败

**解决**:
```bash
# 检查Webhook URL配置
WECHAT_WEBHOOK_URL: "https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxx"

# 测试Webhook
curl -X POST "YOUR_WEBHOOK_URL" \
  -H "Content-Type: application/json" \
  -d '{"msgtype":"text","text":{"content":"测试"}}'
```

## 🤝 贡献指南

欢迎提交Issue和Pull Request！

### 提交Issue
- Bug报告：描述问题、复现步骤、期望行为
- 功能建议：说明需求场景、期望功能

### 提交PR
1. Fork本仓库
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 提交Pull Request

### 代码规范
- 后端：遵循PEP 8规范
- 前端：使用ESLint + Prettier
- 提交信息：使用语义化提交

## 📝 更新日志

### v1.2.1 (2026-05)
- 🔒 安全加固：服务管理/用户管理新增输入验证（防 XSS / 长度限制）
- 🔒 安全加固：修复 datetime.utcfromtimestamp 弃用警告
- 📋 操作日志完善：补全密码修改、任务执行、域名同步、定时任务等关键操作日志
- 🛡 日志增强：服务密码解密失败增加警告日志；更新操作增加变更字段详情
- 🐛 逻辑修复：修复任务目录变量在异常分支中未定义的问题
- 🐛 逻辑修复：服务端口校验改为仅用户输入时才校验（允许为空）
- 📋 授权完善：补齐部署配置(deploy)模块到可用模块列表，非管理员可被授权
- 🎨 前后端一致性：服务名/版本验证长度对齐（100/50）、凭证路径文档修复
- 🐛 SQL修复：自动证书检测任务 `project_name` 列不存在导致定时任务报错（改用 LEFT JOIN）
- 🐛 SQL修复：证书手动预警通知 `status` 字段 VARCHAR/INT 类型不一致
- 🐛 SQL修复：证书 Excel 导出 `project_name` 列缺失导致项目名始终为空
- 🐛 SQL修复：服务 Excel 导出 `public_ip`/`inner_ip` 列缺失导致字段始终为空

### v1.2.0 (2026-05)
- 🔐 环境类型用户授权：管理员可为非管理员配置可见的环境类型（影响服务器管理、服务管理）
- 📋 角色模块授权：管理员可为 Operator/Viewer 配置模块级访问权限
- 🔒 权限加固：仪表盘、操作日志、数据导出改为管理员专属
- 🔐 服务管理新增账户与密码字段（加密存储）
- 🔍 服务管理支持按服务名/IP 模糊搜索
- 🐛 修复阿里云域名同步不更新到期日期的问题
- 🐛 修复服务编辑清除项目ID后不保存为null的问题
- 🐛 修复长账户/密码导致复制按钮被遮挡的问题
- 🐛 修复非管理员访问仪表盘的重定向死循环
- 🚀 Dockerfile 使用阿里云 apt/pip 镜像源加速构建
- 📄 新增独立数据库迁移脚本

### v1.0.0 (2024)
- ✨ 初始版本发布
- 🎨 前后端分离架构
- 📊 仪表盘可视化
- 🔔 SSL/域名到期监控
- 🐳 Docker一键部署

## 📄 许可证

MIT License

## 📧 联系方式

- **作者**: ismine3
- **GitHub**: https://github.com/ismine3/OPS
- **项目地址**: https://github.com/ismine3/OPS

## 🙏 致谢

感谢以下开源项目：
- [Vue.js](https://vuejs.org/)
- [Flask](https://flask.palletsprojects.com/)
- [Element Plus](https://element-plus.org/)
- [ECharts](https://echarts.apache.org/)
- [Docker](https://www.docker.com/)

---

**⭐ 如果这个项目对你有帮助，请给个Star！**
