"""
部署配置 - 流水线文件生成器 API
"""
import os
import json
import shutil
import zipfile
import io
from pathlib import Path
from datetime import datetime

from flask import Blueprint, request, jsonify, g, send_file
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required, module_required
from ..utils.operation_log import log_operation

pipeline_bp = Blueprint('pipeline', __name__, url_prefix='/api/pipeline')

# ============================================================
#  分组中文标签映射
# ============================================================
GROUP_LABELS = {
    "project":   "项目基本信息",
    "git":       "Git 仓库配置",
    "registry":  "镜像仓库配置",
    "service":   "服务 & Dockerfile 配置",
    "ssh":       "SSH 部署配置",
    "jenkins":   "Jenkins 构建环境",
    "wechat":    "企业微信通知",
    "dockerfile":"Dockerfile 配置",
    "deploy":    "部署脚本配置",
    "compose":   "Docker Compose 环境变量",
    "frontend":  "前端构建配置",
}

# ============================================================
#  输出根目录 & 模板目录
# ============================================================
_BASE_DIR = Path(__file__).resolve().parent.parent  # backend/app/
UPLOADS_DIR = _BASE_DIR / "uploads"
PIPELINE_ROOT = UPLOADS_DIR / "pipelines"
TEMPLATES_DIR = PIPELINE_ROOT / "templates"

# ============================================================
#  从 DB 加载配置（按 key 映射，可选按 pipeline_type 过滤）
# ============================================================
def _load_config_map(pipeline_type=None):
    db = get_db()
    cursor = db.cursor()
    try:
        if pipeline_type:
            cursor.execute(
                "SELECT config_key, default_value FROM pipeline_configs "
                "WHERE pipeline_type IS NULL OR pipeline_type = %s",
                (pipeline_type,))
        else:
            cursor.execute("SELECT config_key, default_value FROM pipeline_configs")
        return {row['config_key']: row['default_value'] or '' for row in cursor.fetchall()}
    finally:
        cursor.close()


def _load_default_options_map(pipeline_type=None):
    """返回 {config_key: default_option_value}，可选按 pipeline_type 过滤"""
    db = get_db()
    cursor = db.cursor()
    try:
        if pipeline_type:
            cursor.execute("""
                SELECT pc.config_key, pco.option_value
                FROM pipeline_configs pc
                JOIN pipeline_config_options pco ON pc.id = pco.config_id AND pco.is_default = 1
                WHERE pc.pipeline_type IS NULL OR pc.pipeline_type = %s
            """, (pipeline_type,))
        else:
            cursor.execute("""
                SELECT pc.config_key, pco.option_value
                FROM pipeline_configs pc
                JOIN pipeline_config_options pco ON pc.id = pco.config_id AND pco.is_default = 1
            """)
        return {row['config_key']: row['option_value'] or '' for row in cursor.fetchall()}
    finally:
        cursor.close()


# ============================================================
#  GET /api/pipeline/config — 获取完整配置（分组+选项列表）
#  支持 ?type=backend|frontend 过滤
# ============================================================
@pipeline_bp.route('/config', methods=['GET'])
@jwt_required
@module_required('deploy')
def get_config():
    pipeline_type = request.args.get('type', '').strip() or None
    db = get_db()
    cursor = db.cursor()
    try:
        where = "WHERE 1=1"
        params = []
        if pipeline_type:
            where += " AND (pc.pipeline_type IS NULL OR pc.pipeline_type = %s)"
            params.append(pipeline_type)

        cursor.execute(f"""
            SELECT pc.id, pc.config_key, pc.config_label, pc.config_group,
                   pc.sort_order, pc.description, pc.required, pc.pipeline_type,
                   pco.id AS option_id, pco.option_value, pco.is_default, pco.sort_order AS opt_sort
            FROM pipeline_configs pc
            LEFT JOIN pipeline_config_options pco ON pc.id = pco.config_id
            {where}
            ORDER BY FIELD(pc.config_group, 'project','git','registry','service','ssh','jenkins','wechat','dockerfile','deploy','compose','frontend'),
                     pc.sort_order, pco.sort_order
        """, params)
        rows = cursor.fetchall()

        groups_dict = {}
        for row in rows:
            group = row['config_group']
            if group not in groups_dict:
                groups_dict[group] = {
                    "group": group,
                    "label": GROUP_LABELS.get(group, group),
                    "fields": [],
                }
            field_map = groups_dict[group]["fields"]
            # 检查是否已有该字段
            existing = next((f for f in field_map if f["config_key"] == row['config_key']), None)
            if not existing:
                existing = {
                    "config_id": row['id'],
                    "config_key": row['config_key'],
                    "config_label": row['config_label'],
                    "description": row['description'] or '',
                    "required": bool(row['required']),
                    "pipeline_type": row['pipeline_type'] or '',
                    "options": [],
                }
                field_map.append(existing)
            if row['option_id']:
                existing["options"].append({
                    "id": row['option_id'],
                    "value": row['option_value'] or '',
                    "is_default": bool(row['is_default']),
                })

        groups = [groups_dict[k] for k in [
            'project', 'git', 'registry', 'service', 'ssh',
            'jenkins', 'wechat', 'dockerfile', 'deploy', 'compose', 'frontend'
        ] if k in groups_dict]

        return jsonify({"code": 200, "data": {"groups": groups}})
    finally:
        cursor.close()


# ============================================================
#  POST /api/pipeline/config/options — 管理员添加选项
# ============================================================
@pipeline_bp.route('/config/options', methods=['POST'])
@jwt_required
@role_required(['admin'])
def add_config_option():
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        config_id = data.get('config_id')
        option_value = data.get('option_value', '')
        is_default = data.get('is_default', False)

        if not config_id or option_value is None:
            return jsonify({"code": 400, "message": "config_id 和 option_value 为必填项"}), 400

        # 如果设为首选，清除同字段其他默认标记
        if is_default:
            cursor.execute("UPDATE pipeline_config_options SET is_default = 0 WHERE config_id = %s", (config_id,))

        cursor.execute(
            "INSERT INTO pipeline_config_options (config_id, option_value, is_default) VALUES (%s, %s, %s)",
            (config_id, option_value, 1 if is_default else 0)
        )
        db.commit()
        return jsonify({"code": 200, "message": "添加成功", "data": {"id": cursor.lastrowid}})
    except Exception as e:
        db.rollback()
        return jsonify({"code": 500, "message": f"添加失败: {str(e)}"}), 500
    finally:
        cursor.close()


# ============================================================
#  PUT /api/pipeline/config/options/<int:option_id> — 修改选项值
# ============================================================
@pipeline_bp.route('/config/options/<int:option_id>', methods=['PUT'])
@jwt_required
@role_required(['admin'])
def update_config_option(option_id):
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.json
        option_value = data.get('option_value')
        is_default = data.get('is_default')

        if option_value is not None:
            # 获取所属 config_id
            cursor.execute("SELECT config_id FROM pipeline_config_options WHERE id = %s", (option_id,))
            row = cursor.fetchone()
            if not row:
                return jsonify({"code": 404, "message": "选项不存在"}), 404

            if is_default:
                cursor.execute("UPDATE pipeline_config_options SET is_default = 0 WHERE config_id = %s", (row['config_id'],))

            cursor.execute(
                "UPDATE pipeline_config_options SET option_value = %s, is_default = %s WHERE id = %s",
                (option_value, 1 if is_default else 0, option_id)
            )
            db.commit()

        return jsonify({"code": 200, "message": "更新成功"})
    except Exception as e:
        db.rollback()
        return jsonify({"code": 500, "message": f"更新失败: {str(e)}"}), 500
    finally:
        cursor.close()


# ============================================================
#  DELETE /api/pipeline/config/options/<int:option_id> — 删除选项
# ============================================================
@pipeline_bp.route('/config/options/<int:option_id>', methods=['DELETE'])
@jwt_required
@role_required(['admin'])
def delete_config_option(option_id):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("DELETE FROM pipeline_config_options WHERE id = %s", (option_id,))
        db.commit()
        return jsonify({"code": 200, "message": "删除成功"})
    except Exception as e:
        db.rollback()
        return jsonify({"code": 500, "message": f"删除失败: {str(e)}"}), 500
    finally:
        cursor.close()


# ============================================================
#  生成逻辑：搬运自 generate-pipeline.py
# ============================================================
DOCKERFILE_TEMPLATE = """FROM  {base_image}

ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY {jar_source} {jar_target}

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "{jar_target}"]
"""


def _generate_jenkinsfile(configs: dict, output_dir: Path):
    """生成 Jenkinsfile"""
    template_path = TEMPLATES_DIR / "Jenkinsfile.template"
    if not template_path.exists():
        raise FileNotFoundError(f"找不到 Jenkinsfile 模板: {template_path}")

    content = template_path.read_text(encoding="utf-8")
    notify_title = f"{configs.get('PROJECT_NAME', '')}：{configs.get('ENVIRONMENT', '')}"

    replacements = {
        "{{NOTIFY_TITLE}}":                  notify_title,
        "{{ENVIRONMENT}}":                  configs.get("ENVIRONMENT", ""),
        "{{JENKINS_NODE_LABEL}}":           configs.get("JENKINS_NODE_LABEL", ""),
        "{{BUILD_TIMEOUT}}":                configs.get("BUILD_TIMEOUT", "1"),
        "{{BUILD_TIMEOUT_UNIT}}":           configs.get("BUILD_TIMEOUT_UNIT", "HOURS"),
        "{{BUILD_KEEP_COUNT}}":             configs.get("BUILD_KEEP_COUNT", "10"),
        "{{MAVEN_HOME}}":                   configs.get("MAVEN_HOME", ""),
        "{{JAVA_HOME}}":                    configs.get("JAVA_HOME", ""),
        "{{MAVEN_OPTS}}":                   configs.get("MAVEN_OPTS", ""),
        "{{DOCKER_BUILD_OPTS}}":            configs.get("DOCKER_BUILD_OPTS", ""),
        "{{IMAGE_REGISTRY}}":              configs.get("IMAGE_REGISTRY", ""),
        "{{IMAGE_REGISTRY_USER}}":         configs.get("IMAGE_REGISTRY_USER", ""),
        "{{IMAGE_REGISTRY_PASSWORD}}":     configs.get("IMAGE_REGISTRY_PASSWORD", ""),
        "{{IMAGE_PROJECT}}":                configs.get("IMAGE_PROJECT", ""),
        "{{SERVICES}}":                     configs.get("SERVICES", ""),
        "{{SERVICE_DOCKERFILE_PATHS}}":     configs.get("SERVICE_DOCKERFILE_PATHS", ""),
        "{{SSH_CONFIG_NAMES}}":             configs.get("SSH_CONFIG_NAMES", ""),
        "{{SSH_REMOTE_DIR}}":               configs.get("SSH_REMOTE_DIR", ""),
        "{{GIT_CREDENTIALS_ID}}":           configs.get("GIT_CREDENTIALS_ID", ""),
        "{{GIT_REPO_URL}}":                 configs.get("GIT_REPO_URL", ""),
        "{{GIT_BRANCH}}":                   configs.get("GIT_BRANCH", ""),
        "{{WECHAT_WEBHOOK_CREDENTIALS_ID}}":configs.get("WECHAT_WEBHOOK_CREDENTIALS_ID", ""),
    }

    for placeholder, value in replacements.items():
        content = content.replace(placeholder, value)

    out = output_dir / "Jenkinsfile"
    out.write_text(content, encoding="utf-8")
    return out


def _generate_jenkinsfile_frontend(configs: dict, output_dir: Path):
    """生成前端 Jenkinsfile（基于 Jenkinsfile-frontend.template）"""
    template_path = TEMPLATES_DIR / "Jenkinsfile-frontend.template"
    if not template_path.exists():
        raise FileNotFoundError(f"找不到前端 Jenkinsfile 模板: {template_path}")

    content = template_path.read_text(encoding="utf-8")
    notify_title = f"{configs.get('PROJECT_NAME', '')}：{configs.get('ENVIRONMENT', '')}"

    replacements = {
        "{{NOTIFY_TITLE}}":                  notify_title,
        "{{GIT_REPO_URL}}":                 configs.get("GIT_REPO_URL", ""),
        "{{GIT_CREDENTIALS_ID}}":           configs.get("GIT_CREDENTIALS_ID", ""),
        "{{GIT_BRANCH}}":                   configs.get("GIT_BRANCH", ""),
        "{{SSH_CONFIG_NAMES}}":             configs.get("SSH_CONFIG_NAMES", ""),
        "{{FRONTEND_DEPLOY_DIR}}":          configs.get("FRONTEND_DEPLOY_DIR", ""),
        "{{WECHAT_WEBHOOK_CREDENTIALS_ID}}":configs.get("WECHAT_WEBHOOK_CREDENTIALS_ID", ""),
        "{{NODE_VERSION}}":                 configs.get("NODE_VERSION", ""),
        "{{BUILD_COMMAND}}":                configs.get("BUILD_COMMAND", ""),
        "{{NPM_REGISTRY}}":                 configs.get("NPM_REGISTRY", ""),
    }

    for placeholder, value in replacements.items():
        content = content.replace(placeholder, value)

    out = output_dir / "Jenkinsfile-frontend"
    out.write_text(content, encoding="utf-8")
    return out


def _generate_dockerfiles(configs: dict, output_dir: Path):
    """按 SERVICE_DOCKERFILE_PATHS 拆分，每个服务生成一个 dockerfile"""
    paths_str = configs.get("SERVICE_DOCKERFILE_PATHS", "")
    items = paths_str.split()
    files = []
    if not items:
        return files

    base_image = configs.get("DOCKERFILE_BASE_IMAGE", "")

    for item in items:
        parts = item.rsplit(":", 1)
        if len(parts) != 2:
            continue
        dockerfile_rel, svc_name = parts
        out = output_dir / dockerfile_rel
        jar_source = f"{svc_name}/target/{svc_name}.jar"
        jar_target = f"/app/{svc_name}.jar"

        out.parent.mkdir(parents=True, exist_ok=True)
        content = DOCKERFILE_TEMPLATE.format(
            base_image=base_image,
            jar_source=jar_source,
            jar_target=jar_target,
        )
        out.write_text(content, encoding="utf-8")
        files.append(out)
    return files


def _generate_deploy_sh(configs: dict, output_dir: Path):
    """生成 deploy-to-production.sh"""
    out = output_dir / "deploy-to-production.sh"

    ports_str = configs.get("DEPLOY_SERVICE_PORTS", "")
    ports_decl = ""
    for entry in ports_str.split(";"):
        entry = entry.strip()
        if "=" in entry:
            svc, port = entry.split("=", 1)
            ports_decl += f'SERVICE_PORTS["{svc}"]="{port}"\n'

    defaults_str = '"' + '" "'.join(configs.get("DEPLOY_DEFAULT_SERVICES", "").split()) + '"'

    compose_env_section = ""
    compose_env_raw = configs.get("DOCKER_COMPOSE_ENV_VARS", "").strip()
    if compose_env_raw:
        normalized = compose_env_raw.replace("\\n", "\n").replace(";", "\n")
        lines = [l.strip() for l in normalized.split("\n") if l.strip()]
        if lines:
            compose_env_section = "    environment:\n"
            for line in lines:
                compose_env_section += f"      - {line}\n"

    content = f"""#!/bin/bash
# 此文件由 OPS 部署配置模块自动生成
# 从命令行参数获取环境变量，设置默认值
IMAGE_REGISTRY_CHOICE=${{1:-{configs.get('DEPLOY_IMAGE_REGISTRY_CHOICE', '')}}}
IMAGE_PROJECT=${{2:-{configs.get('DEPLOY_IMAGE_PROJECT', '')}}}
IMAGE_VERSION=${{3:-{configs.get('DEPLOY_IMAGE_VERSION', '')}}}
SSH_REMOTE_DIR=${{4:-{configs.get('DEPLOY_SSH_REMOTE_DIR', '')}}}

# 确保在正确的目录中
cd $SSH_REMOTE_DIR

echo "===== 部署到生产环境 ===="

# 读取要部署的服务列表
SERVICES_RAW=($(cat $SSH_REMOTE_DIR/services_to_deploy.txt 2>/dev/null || echo ""))
if [ ${{#SERVICES_RAW[@]}} -eq 0 ]; then
    echo "警告: 未读取到服务列表，使用默认服务"
    SERVICES_RAW=({defaults_str})
fi

# 将服务名称转换为小写
SERVICES=()
for service in "${{SERVICES_RAW[@]}}"; do
    SERVICES+=($(echo $service | tr '[:upper:]' '[:lower:]'))
done
echo "要部署的服务列表: ${{SERVICES[*]}}"

# 定义服务端口映射
declare -A SERVICE_PORTS
{ports_decl}
# 定义服务容器名称前缀
CONTAINER_PREFIX="{configs.get('CONTAINER_PREFIX', '')}"

# 使用变量来处理$符号，避免bash heredoc转义问题
DOLLAR='$'

# 为每个服务创建单独的部署目录并生成docker-compose.yml
for service in "${{SERVICES[@]}}"; do
    service_dir="$SSH_REMOTE_DIR/$service"
    echo "创建服务部署目录: $service_dir"
    mkdir -p $service_dir

    # 获取服务端口
    PORT=${{SERVICE_PORTS[$service]:-"9000:9000"}}

    # 获取容器名称
    CONTAINER_NAME="${{CONTAINER_PREFIX}}${{service}}"

    # 生成docker-compose.yml文件
    docker_compose_file="$service_dir/docker-compose.yml"
    echo "处理docker-compose.yml文件: $docker_compose_file"

    # 如果文件不存在，则创建新文件
    if [ ! -f "$docker_compose_file" ]; then
        echo "文件不存在，创建新文件"
        cat > "$docker_compose_file" << EOF
services:
  $service:
    image: $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION
    container_name: $CONTAINER_NAME
    restart: always
    network_mode: "host"
    ports:
      - "$PORT"
    volumes:
      - ./logs:/logs
      - /etc/localtime:/etc/localtime:ro
    ulimits:
      nofile:
        soft: 65535
        hard: 65535
      nproc:
        soft: 65535
        hard: 65535
EOF
    else
        echo "文件已存在，检查镜像仓库地址"
        existing_image=$(grep -E "^    image:" "$docker_compose_file" | awk '{{print $2}}')

        if [ -z "$existing_image" ]; then
            echo "未找到现有image配置，重新创建文件"
            cat > "$docker_compose_file" << EOF
services:
  $service:
    image: $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION
    container_name: $CONTAINER_NAME
    restart: always
    network_mode: "host"
    ports:
      - "$PORT"
{compose_env_section}    volumes:
      - ./logs:/logs
      - /etc/localtime:/etc/localtime:ro
    ulimits:
      nofile:
        soft: 65535
        hard: 65535
      nproc:
        soft: 65535
        hard: 65535
EOF
        else
            existing_registry=$(echo $existing_image | cut -d'/' -f1)
            echo "现有镜像仓库: $existing_registry"
            echo "目标镜像仓库: $IMAGE_REGISTRY_CHOICE"

            if [ "$existing_registry" == "$IMAGE_REGISTRY_CHOICE" ]; then
                echo "镜像仓库地址相同，仅更新版本号"
                sed -i "s|image: $existing_registry/$IMAGE_PROJECT/$service:.*|image: $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION|g" "$docker_compose_file"
            else
                echo "镜像仓库地址不同，替换整个镜像地址"
                sed -i "s|image: $existing_image|image: $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION|g" "$docker_compose_file"
            fi
        fi
    fi

    echo "✅  服务 $service 的docker-compose.yml文件版本更新完成"
done

# 登录到镜像仓库
echo "在部署节点登录到镜像仓库: $IMAGE_REGISTRY_CHOICE"
docker login -u {configs.get('DEPLOY_HARBOR_USER', '')} -p {configs.get('DEPLOY_HARBOR_PASSWORD', '')} $IMAGE_REGISTRY_CHOICE

# 并行拉取最新镜像
echo "开始并行拉取最新镜像..."

pull_image() {{
    local service=$1
    echo "拉取服务 $service 的镜像: $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION"
    docker pull $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION
    if [ $? -eq 0 ]; then
        echo "✅ 服务 $service 镜像拉取完成"
    else
        echo "❌ 服务 $service 镜像拉取失败，跳过部署"
        return 1
    fi
    return 0
}}

declare -a pull_pids
declare -A pull_results
for service in "${{SERVICES[@]}}"; do
    pull_image $service &
    pull_pid=$!
    pull_pids+=($pull_pid)
    pull_results["$pull_pid"]=$service
done

echo "等待所有镜像拉取完成..."
for pid in "${{pull_pids[@]}}"; do
    wait $pid
    exit_code=$?
    service=${{pull_results["$pid"]}}
    if [ $exit_code -ne 0 ]; then
        echo "⚠️ 服务 $service 镜像拉取失败，将跳过该服务"
    fi
done

echo "并行停止并启动服务..."

deploy_service() {{
    local service=$1
    local service_dir="$SSH_REMOTE_DIR/$service"
    echo "处理服务 $service..."
    cd $service_dir
    echo "停止并移除旧服务容器..."
    docker-compose down 2>/dev/null || true
    echo "启动新服务容器..."
    docker-compose up -d
    if [ $? -eq 0 ]; then
        echo "✅ 服务 $service 部署完成"
    else
        echo "❌ 服务 $service 部署失败"
        return 1
    fi
    return 0
}}

declare -a deploy_pids
declare -A deploy_results
for service in "${{SERVICES[@]}}"; do
    deploy_service $service &
    deploy_pid=$!
    deploy_pids+=($deploy_pid)
    deploy_results["$deploy_pid"]=$service
done

echo "等待所有服务部署完成..."
for pid in "${{deploy_pids[@]}}"; do
    wait $pid
    exit_code=$?
    service=${{deploy_results["$pid"]}}
    if [ $exit_code -ne 0 ]; then
        echo "⚠️ 服务 $service 部署可能失败"
    fi
done

echo "验证服务启动状态..."
for service in "${{SERVICES[@]}}"; do
    service_dir="$SSH_REMOTE_DIR/$service"
    echo "验证服务 $service 启动状态..."
    cd $service_dir
    docker-compose ps 2>/dev/null || echo "⚠️ 无法获取服务 $service 状态"
done

sleep 5

echo "检查服务健康状态..."
for service in "${{SERVICES[@]}}"; do
    service_dir="$SSH_REMOTE_DIR/$service"
    echo "检查服务 $service 的健康状态..."
    cd $service_dir
    container_name="${{CONTAINER_PREFIX}}${{service}}"
    container_status=$(docker ps -f name="^/${{container_name}}$" --format "{{{{.Status}}}}" 2>/dev/null)
    if [ -n "$container_status" ]; then
        echo "✅  服务 $service 容器正在运行，状态: $container_status"
        echo "服务 $service 日志预览:"
        docker logs --tail 5 "$container_name" 2>/dev/null || echo "⚠️ 无法获取日志"
    else
        echo "❌  服务 $service 容器未运行"
        echo "服务 $service 容器详细信息:"
        docker ps -a -f name="^/${{container_name}}$" 2>/dev/null || echo "⚠️ 无法获取容器信息"
    fi
done

echo "清理未使用的镜像..."
docker system prune -a -f 2>/dev/null || echo "⚠️ 清理操作失败"

echo "===== 部署完成 ===="
"""
    out.write_text(content, encoding="utf-8")
    # 尝试设置可执行权限
    try:
        out.chmod(0o755)
    except OSError:
        pass
    return out


def _run_generation(configs: dict, project_name: str, pipeline_type: str = 'backend') -> tuple:
    """执行生成，返回 (output_dir, files_relative_list)"""
    output_dir = PIPELINE_ROOT / project_name
    output_dir.mkdir(parents=True, exist_ok=True)

    files = []

    if pipeline_type == 'frontend':
        # 前端：仅生成 Jenkinsfile-frontend
        jf = _generate_jenkinsfile_frontend(configs, output_dir)
        files.append({"name": "Jenkinsfile-frontend", "path": f"{project_name}/Jenkinsfile-frontend"})
    else:
        # 后端：生成 Jenkinsfile + Dockerfiles + deploy-to-production.sh
        jf = _generate_jenkinsfile(configs, output_dir)
        files.append({"name": "Jenkinsfile", "path": f"{project_name}/Jenkinsfile"})

        df_files = _generate_dockerfiles(configs, output_dir)
        for df in df_files:
            rel = str(df.relative_to(PIPELINE_ROOT)).replace("\\", "/")
            files.append({"name": df.name, "path": rel})

        ds = _generate_deploy_sh(configs, output_dir)
        files.append({"name": "deploy-to-production.sh", "path": f"{project_name}/deploy-to-production.sh"})

    return output_dir, files


# ============================================================
#  POST /api/pipeline/generate — 生成流水线文件
# ============================================================
@pipeline_bp.route('/generate', methods=['POST'])
@jwt_required
@module_required('deploy')
@role_required(['admin', 'operator'])
def generate():
    data = request.json
    project_name = (data.get('project_name') or '').strip()
    pipeline_type = (data.get('pipeline_type') or 'backend').strip()
    user_configs = data.get('configs') or {}

    # 校验 pipeline_type
    if pipeline_type not in ('backend', 'frontend'):
        return jsonify({"code": 400, "message": "pipeline_type 必须为 backend 或 frontend"}), 400

    # 校验项目名
    if not project_name:
        return jsonify({"code": 400, "message": "项目名称不能为空"}), 400
    forbidden_chars = set('/\\:;*?"<>|')
    if any(c in project_name for c in forbidden_chars):
        return jsonify({"code": 400, "message": "项目名称包含非法字符"}), 400

    # 合并配置：用户提交值优先，未提供则回退到 DB 默认值
    db_defaults = _load_default_options_map(pipeline_type)
    final_configs = {}
    for key, default_val in db_defaults.items():
        final_configs[key] = user_configs.get(key, default_val)

    # 确保模板目录存在
    TEMPLATES_DIR.mkdir(parents=True, exist_ok=True)

    try:
        output_dir, files = _run_generation(final_configs, project_name, pipeline_type)
    except FileNotFoundError as e:
        return jsonify({"code": 500, "message": str(e)}), 500
    except Exception as e:
        return jsonify({"code": 500, "message": f"生成失败: {str(e)}"}), 500

    # 记录到数据库
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute(
            "INSERT INTO pipeline_generations (project_name, pipeline_type, config_snapshot, output_dir, files, created_by) "
            "VALUES (%s, %s, %s, %s, %s, %s)",
            (project_name, pipeline_type, json.dumps(final_configs, ensure_ascii=False),
             f"pipelines/{project_name}", json.dumps(files, ensure_ascii=False),
             g.current_user.get('user_id'))
        )
        db.commit()
        gen_id = cursor.lastrowid

        log_operation('部署配置', 'generate', gen_id, project_name,
                      {'file_count': len(files), 'pipeline_type': pipeline_type})

        return jsonify({
            "code": 200,
            "message": "生成成功",
            "data": {
                "id": gen_id,
                "project_name": project_name,
                "pipeline_type": pipeline_type,
                "files": files,
                "output_dir": f"uploads/pipelines/{project_name}"
            }
        })
    except Exception as e:
        db.rollback()
        return jsonify({"code": 500, "message": f"记录保存失败: {str(e)}"}), 500
    finally:
        cursor.close()


# ============================================================
#  GET /api/pipeline/generations — 历史列表
# ============================================================
@pipeline_bp.route('/generations', methods=['GET'])
@jwt_required
@module_required('deploy')
def get_generations():
    db = get_db()
    cursor = db.cursor()
    try:
        search = request.args.get('search', '').strip()
        page = int(request.args.get('page', '1'))
        page_size = int(request.args.get('page_size', '10'))
        if page < 1:
            page = 1
        if page_size < 1 or page_size > 100:
            page_size = 10

        where = "WHERE 1=1"
        params = []
        if search:
            where += " AND pg.project_name LIKE %s"
            params.append(f"%{search}%")

        cursor.execute(f"SELECT COUNT(*) AS total FROM pipeline_generations pg {where}", params)
        total = cursor.fetchone()['total']

        offset = (page - 1) * page_size
        cursor.execute(
            f"""SELECT pg.id, pg.project_name, pg.pipeline_type, pg.files, pg.created_at,
                       u.display_name AS created_by_name
                FROM pipeline_generations pg
                LEFT JOIN users u ON pg.created_by = u.id
                {where}
                ORDER BY pg.created_at DESC
                LIMIT %s OFFSET %s""",
            params + [page_size, offset]
        )
        items = []
        for row in cursor.fetchall():
            files_data = row['files']
            if isinstance(files_data, str):
                files_data = json.loads(files_data)
            items.append({
                "id": row['id'],
                "project_name": row['project_name'],
                "pipeline_type": row['pipeline_type'] or 'backend',
                "file_count": len(files_data) if isinstance(files_data, list) else 0,
                "created_by_name": row['created_by_name'] or '系统',
                "created_at": row['created_at'].isoformat() if row['created_at'] else None,
            })

        return jsonify({
            "code": 200,
            "data": {"items": items, "total": total, "page": page, "page_size": page_size}
        })
    finally:
        cursor.close()


# ============================================================
#  GET /api/pipeline/generations/<int:gen_id> — 详情
# ============================================================
@pipeline_bp.route('/generations/<int:gen_id>', methods=['GET'])
@jwt_required
@module_required('deploy')
def get_generation(gen_id):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute(
            """SELECT pg.*, u.display_name AS created_by_name
               FROM pipeline_generations pg
               LEFT JOIN users u ON pg.created_by = u.id
               WHERE pg.id = %s""",
            (gen_id,)
        )
        row = cursor.fetchone()
        if not row:
            return jsonify({"code": 404, "message": "记录不存在"}), 404

        files_data = row['files']
        if isinstance(files_data, str):
            files_data = json.loads(files_data)
        config_data = row['config_snapshot']
        if isinstance(config_data, str):
            config_data = json.loads(config_data)

        return jsonify({
            "code": 200,
            "data": {
                "id": row['id'],
                "project_name": row['project_name'],
                "pipeline_type": row['pipeline_type'] or 'backend',
                "config_snapshot": config_data,
                "files": files_data,
                "output_dir": row['output_dir'],
                "created_by_name": row['created_by_name'] or '系统',
                "created_at": row['created_at'].isoformat() if row['created_at'] else None,
            }
        })
    finally:
        cursor.close()


# ============================================================
#  GET /api/pipeline/generations/<int:gen_id>/download — ZIP 下载
# ============================================================
@pipeline_bp.route('/generations/<int:gen_id>/download', methods=['GET'])
@jwt_required
@module_required('deploy')
def download_generation(gen_id):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT project_name, output_dir FROM pipeline_generations WHERE id = %s", (gen_id,))
        row = cursor.fetchone()
        if not row:
            return jsonify({"code": 404, "message": "记录不存在"}), 404

        project_name = row['project_name']
        output_dir = PIPELINE_ROOT / project_name
        if not output_dir.exists():
            return jsonify({"code": 404, "message": "文件目录不存在"}), 404

        buf = io.BytesIO()
        with zipfile.ZipFile(buf, 'w', zipfile.ZIP_DEFLATED) as zf:
            for fpath in sorted(output_dir.rglob("*")):
                if fpath.is_file():
                    arcname = str(fpath.relative_to(output_dir))
                    zf.write(fpath, arcname)
        buf.seek(0)

        return send_file(
            buf,
            mimetype='application/zip',
            as_attachment=True,
            download_name=f"{project_name}_pipeline_{datetime.now().strftime('%Y%m%d%H%M%S')}.zip"
        )
    finally:
        cursor.close()


# ============================================================
#  DELETE /api/pipeline/generations/<int:gen_id> — 删除
# ============================================================
@pipeline_bp.route('/generations/<int:gen_id>', methods=['DELETE'])
@jwt_required
@module_required('deploy')
@role_required(['admin', 'operator'])
def delete_generation(gen_id):
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT project_name, output_dir FROM pipeline_generations WHERE id = %s", (gen_id,))
        row = cursor.fetchone()
        if not row:
            return jsonify({"code": 404, "message": "记录不存在"}), 404

        project_name = row['project_name']
        output_dir = PIPELINE_ROOT / project_name
        if output_dir.exists():
            shutil.rmtree(output_dir)

        cursor.execute("DELETE FROM pipeline_generations WHERE id = %s", (gen_id,))
        db.commit()

        log_operation('部署配置', 'delete', gen_id, project_name)
        return jsonify({"code": 200, "message": "删除成功"})
    except Exception as e:
        db.rollback()
        return jsonify({"code": 500, "message": f"删除失败: {str(e)}"}), 500
    finally:
        cursor.close()
