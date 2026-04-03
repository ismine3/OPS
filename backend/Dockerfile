# 使用官方 Python 3.11  slim 镜像作为基础镜像
FROM python:3.11-slim

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    FLASK_APP=run.py \
    FLASK_HOST=0.0.0.0 \
    FLASK_PORT=5000

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 复制 requirements.txt 并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制应用代码
COPY . .

# 创建上传目录
RUN mkdir -p /app/app/uploads/scripts /app/app/uploads/certs

# 暴露端口
EXPOSE 5000

# Gunicorn：单 worker 多线程（避免 APScheduler 多进程重复注册定时任务）
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "1", "--threads", "8", "--timeout", "120", "--log-level", "info", "--access-logfile", "-", "--error-logfile", "-", "run:app"]
