#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# =============================================================================
# generate-pipeline.py — 流水线文件自动生成器 (Python版)
# =============================================================================
# 功能: 基于当前项目模板(deploy-to-production.sh / dockerfile / Jenkinsfile),
#       为新项目自动生成对应的流水线文件,支持通过参数覆盖所有可配置项。
#
# 用法:
#   python generate-pipeline.py [OPTIONS] [OUTPUT_DIR]
#
#   若不指定 OUTPUT_DIR,默认输出到 ./generated-pipeline/ 目录。
#
# 参数注入方式(优先级从高到低):
#   1. 命令行参数
#   2. 环境变量(前缀 PIPELINE_)
#   3. 脚本内部默认值(当前基板数值)
# =============================================================================

import os
import sys
import argparse
import shutil
from pathlib import Path

# =============================================================================
#              启用 Windows 终端 ANSI 颜色支持
# =============================================================================
def _enable_ansi_support():
    """在 Windows 上启用虚拟终端处理，使 ANSI 转义码正常渲染"""
    if os.name != 'nt':
        return  # 非 Windows 系统原生支持
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32
        STD_OUTPUT_HANDLE = -11
        ENABLE_VIRTUAL_TERMINAL_PROCESSING = 0x0004
        handle = kernel32.GetStdHandle(STD_OUTPUT_HANDLE)
        mode = ctypes.c_ulong()
        kernel32.GetConsoleMode(handle, ctypes.byref(mode))
        if not (mode.value & ENABLE_VIRTUAL_TERMINAL_PROCESSING):
            kernel32.SetConsoleMode(handle, mode.value | ENABLE_VIRTUAL_TERMINAL_PROCESSING)
    except Exception:
        # ctypes 方式失败时尝试 colorama
        try:
            import colorama
            colorama.init()
        except ImportError:
            pass  # 无 ANSI 支持，颜色码将显示为原始字符

_enable_ansi_support()

# =============================================================================
#                          ANSI 颜色码
# =============================================================================
C_RESET  = '\033[0m'
C_BOLD   = '\033[1m'
C_CYAN   = '\033[36m'
C_GREEN  = '\033[32m'
C_YELLOW = '\033[33m'
C_DIM    = '\033[2m'

def section_header(text: str):
    print(f"\n{C_CYAN}{C_BOLD}━━━ {text} ━━━{C_RESET}")

def info(text: str):
    print(f"{C_CYAN}{text}{C_RESET}")

def success(text: str):
    print(f"{C_GREEN}{text}{C_RESET}")

def warn(text: str):
    print(f"{C_YELLOW}{text}{C_RESET}")

def dim(text: str):
    print(f"{C_DIM}{text}{C_RESET}")

# =============================================================================
#                            默认值(当前基板数值)
# =============================================================================
class Config:
    """所有可配置参数的默认值"""
    # 项目基本信息
    PROJECT_NAME = "water-park-pms后端"
    ENVIRONMENT = "测试环境"

    # Jenkins 基础环境
    MAVEN_HOME = "/opt/apache-maven-3.9.8"
    JAVA_HOME = "/opt/jdk1.8.0_301"
    MAVEN_OPTS = "-Xmx2048m -XX:+UseG1GC"
    DOCKER_BUILD_OPTS = "--compress"

    # 镜像仓库
    IMAGE_REGISTRY = "harbor.huazsz.com"
    IMAGE_REGISTRY_USER = "admin"
    IMAGE_REGISTRY_PASSWORD = "Pass4321."
    IMAGE_PROJECT = "water-park-pms-dev"

    # 服务 & Dockerfile 路径
    SERVICES = "park-admin"
    SERVICE_DOCKERFILE_PATHS = "park-admin/dockerfile:park-admin"

    # SSH 部署
    SSH_CONFIG_NAMES = "172.24.1.32"
    SSH_REMOTE_DIR = "/data/water-park-pms"

    # Git
    GIT_CREDENTIALS_ID = "05fbd8f8-a85f-4346-a48c-9ee619fbd3f4"
    GIT_REPO_URL = "http://172.24.17.30/backend/water-park-pms.git"
    GIT_BRANCH = "dev"

    # 企业微信
    WECHAT_WEBHOOK_CREDENTIALS_ID = "wechat-robot-webhook"

    # Jenkins 流水线选项
    JENKINS_NODE_LABEL = "master"
    BUILD_TIMEOUT = "1"
    BUILD_TIMEOUT_UNIT = "HOURS"
    BUILD_KEEP_COUNT = "10"

    # deploy-to-production.sh 默认参数
    DEPLOY_IMAGE_REGISTRY_CHOICE = "harbor.huazsz.com"
    DEPLOY_IMAGE_PROJECT = "sdc-dev"
    DEPLOY_IMAGE_VERSION = "v1.0.0"
    DEPLOY_SSH_REMOTE_DIR = "/data/sdc"
    DEPLOY_DEFAULT_SERVICES = ["saas-biz", "saas-file", "saas-gateway",
                                "saas-oauth", "saas-pub", "saas-ums"]

    # 服务端口映射
    DEPLOY_SERVICE_PORTS = ("saas-biz=10204:10204;saas-file=10102:10102;"
                             "saas-gateway=10200:10200;saas-oauth=10103:10103;"
                             "saas-pub=10101:10101;saas-ums=10104:10104")

    # deploy-to-production.sh 镜像仓库登录凭据
    DEPLOY_HARBOR_USER = "admin"
    DEPLOY_HARBOR_PASSWORD = "Pass4321."

    # Dockerfile
    DOCKERFILE_BASE_IMAGE = "harbor.huazsz.com/jdk/openjdk:8-jre-FFmpeg"
    DOCKERFILE_MAINTAINER = "WaterPark <water-park@example.com>"
    DOCKERFILE_JAR_SOURCE_PATH = "park-admin/target/park-admin.jar"
    DOCKERFILE_JAR_TARGET_PATH = "/app/park-admin.jar"

    # docker-compose.yml 环境变量(默认为空)
    DOCKER_COMPOSE_ENV_VARS = ""

    # 容器名称前缀
    CONTAINER_PREFIX = ""

    # 输出目录
    OUTPUT_DIR = ""


# =============================================================================
#                     环境变量覆盖 (前缀 PIPELINE_)
# =============================================================================
def override_from_env():
    """用 PIPELINE_ 前缀的环境变量覆盖 Config 属性"""
    for attr in dir(Config):
        if attr.startswith('_') or attr == 'OUTPUT_DIR':
            continue
        env_name = f"PIPELINE_{attr}"
        env_val = os.environ.get(env_name)
        if env_val is not None:
            val = getattr(Config, attr)
            # 对于列表类型的属性，按空格拆分
            if isinstance(val, list):
                setattr(Config, attr, env_val.split())
            else:
                setattr(Config, attr, env_val)

# =============================================================================
#                         交互式输入函数
# =============================================================================
def ask(prompt_text: str, attr_name: str, default_override: str = None):
    """单行交互式提示，回车=默认值，输入内容=覆盖"""
    default_val = default_override if default_override is not None else getattr(Config, attr_name)
    if isinstance(default_val, list):
        display_val = " ".join(default_val)
    else:
        display_val = str(default_val)

    # 密码字段遮蔽显示
    if "PASSWORD" in attr_name.upper():
        display_val = "******"
    # 空值显示
    if not display_val:
        display_val = "（空）"

    prompt = f"{C_BOLD}{prompt_text:<42}{C_RESET} {C_DIM}[{display_val}]{C_RESET}: "
    user_input = input(prompt).strip()

    if user_input:
        val = getattr(Config, attr_name)
        if isinstance(val, list):
            setattr(Config, attr_name, user_input.split())
        else:
            setattr(Config, attr_name, user_input)


def ask_multiline(prompt_text: str, attr_name: str):
    """多行输入辅助(输入空行结束)"""
    current_val = getattr(Config, attr_name)
    print(f"{C_BOLD}{prompt_text}{C_RESET}")
    if current_val:
        print(f"{C_DIM}当前值:{C_RESET}")
        print(current_val)
    else:
        dim("  （当前为空）")
    dim("  (每行一个 KEY=VALUE，输入空行结束，回车保留当前值)")

    lines = []
    first_line = True
    ml_prompt = f"  {C_DIM}>{C_RESET} "
    while True:
        line = input(ml_prompt).strip()
        if not line:
            break
        lines.append(line)

    if lines:
        setattr(Config, attr_name, "\n".join(lines))


def confirm(msg: str = "是否继续?") -> bool:
    """确认提示"""
    prompt = f"{C_YELLOW}{C_BOLD}{msg}{C_RESET} {C_DIM}[Y/n]{C_RESET}: "
    ans = input(prompt).strip().lower()
    return ans == "" or ans.startswith("y")


# =============================================================================
#                         交互式配置向导
# =============================================================================
def interactive_config():
    print(f"{C_CYAN}{C_BOLD}")
    print("╔══════════════════════════════════════════════╗")
    print("║        🔧 流水线文件生成器 (交互式)          ║")
    print("║                                              ║")
    print("║  回车 = 使用默认值  |  输入内容 = 覆盖默认值  ║")
    print("╚══════════════════════════════════════════════╝")
    print(f"{C_RESET}")

    # ==================== 第1步: 项目基本信息 ====================
    section_header("第1步: 项目基本信息")
    ask("  项目名称 (企业微信通知标题)",       "PROJECT_NAME")
    ask("  部署环境 (测试/生产)",              "ENVIRONMENT")

    # ==================== 第2步: Git 配置 ====================
    section_header("第2步: Git 仓库配置")
    ask("  Git 仓库地址",                      "GIT_REPO_URL")
    ask("  Git 分支",                          "GIT_BRANCH")
    ask("  Git 凭据 ID (Jenkins)",             "GIT_CREDENTIALS_ID")

    # ==================== 第3步: 镜像仓库 ====================
    section_header("第3步: 镜像仓库配置")
    ask("  Harbor 镜像仓库地址",               "IMAGE_REGISTRY")
    ask("  镜像项目名 (IMAGE_PROJECT)",        "IMAGE_PROJECT")
    ask("  Harbor 仓库登录用户",               "IMAGE_REGISTRY_USER")
    ask("  Harbor 仓库登录密码",               "IMAGE_REGISTRY_PASSWORD")

    # ==================== 第4步: 服务配置 ====================
    section_header("第4步: 服务 & Dockerfile 配置")
    ask("  服务列表 (空格分隔)",               "SERVICES")
    ask("  Dockerfile 路径映射 (格式: 路径:服务名 路径:服务名)", "SERVICE_DOCKERFILE_PATHS")

    # ==================== 第5步: SSH 部署 ====================
    section_header("第5步: SSH 部署配置")
    ask("  SSH 目标服务器 (逗号分隔)",         "SSH_CONFIG_NAMES")
    ask("  SSH 远程部署目录",                  "SSH_REMOTE_DIR")

    # ==================== 第6步: Jenkins 环境 ====================
    section_header("第6步: Jenkins 构建环境")
    ask("  MAVEN_HOME",                         "MAVEN_HOME")
    ask("  JAVA_HOME",                          "JAVA_HOME")
    ask("  MAVEN_OPTS",                         "MAVEN_OPTS")
    ask("  DOCKER_BUILD_OPTS",                  "DOCKER_BUILD_OPTS")
    ask("  Jenkins 节点标签",                   "JENKINS_NODE_LABEL")
    ask("  构建超时时间",                       "BUILD_TIMEOUT")
    ask("  超时时间单位 (HOURS/MINUTES)",       "BUILD_TIMEOUT_UNIT")
    ask("  保留构建历史数量",                   "BUILD_KEEP_COUNT")

    # ==================== 第7步: 企业微信 ====================
    section_header("第7步: 企业微信通知")
    ask("  Webhook 凭证 ID",                    "WECHAT_WEBHOOK_CREDENTIALS_ID")

    # ==================== 第8步: Dockerfile ====================
    section_header("第8步: Dockerfile 配置 (JAR路径由服务名自动推导)")
    ask("  基础镜像",                            "DOCKERFILE_BASE_IMAGE")
    ask("  维护者信息",                          "DOCKERFILE_MAINTAINER")

    # ==================== 第9步: deploy-to-production.sh ====================
    section_header("第9步: deploy-to-production.sh 部署脚本配置")
    ask("  默认镜像仓库",                        "DEPLOY_IMAGE_REGISTRY_CHOICE")
    ask("  默认镜像项目",                        "DEPLOY_IMAGE_PROJECT")
    ask("  默认镜像版本",                        "DEPLOY_IMAGE_VERSION")
    ask("  默认 SSH 远程目录",                  "DEPLOY_SSH_REMOTE_DIR")
    ask("  容器名称前缀",                        "CONTAINER_PREFIX")
    # 默认服务列表(特殊处理)
    def_svcs_str = " ".join(Config.DEPLOY_DEFAULT_SERVICES)
    ask("  默认服务列表 (空格分隔)",            "DEPLOY_DEFAULT_SERVICES", def_svcs_str)
    ask("  服务端口映射 (格式: svc=port;svc=port)", "DEPLOY_SERVICE_PORTS")
    ask("  Harbor 登录用户",                     "DEPLOY_HARBOR_USER")
    ask("  Harbor 登录密码",                     "DEPLOY_HARBOR_PASSWORD")

    # ==================== 第10步: docker-compose 环境变量 ====================
    section_header("第10步: docker-compose.yml 环境变量 (默认空)")
    ask_multiline("  docker-compose 环境变量",  "DOCKER_COMPOSE_ENV_VARS")

    # ==================== 第11步: 输出目录 ====================
    section_header("第11步: 输出目录")
    if not Config.OUTPUT_DIR:
        Config.OUTPUT_DIR = "./generated-pipeline"
    ask("  输出目录",                            "OUTPUT_DIR")

    # ==================== 汇总确认 ====================
    print()
    section_header("配置汇总")
    print(f"{C_BOLD}项目名称:{C_RESET}         {Config.PROJECT_NAME}")
    print(f"{C_BOLD}部署环境:{C_RESET}         {Config.ENVIRONMENT}")
    print(f"{C_BOLD}Git 仓库:{C_RESET}         {Config.GIT_REPO_URL} ({Config.GIT_BRANCH})")
    print(f"{C_BOLD}镜像仓库:{C_RESET}         {Config.IMAGE_REGISTRY}")
    print(f"{C_BOLD}镜像项目:{C_RESET}         {Config.IMAGE_PROJECT}")
    print(f"{C_BOLD}服务列表:{C_RESET}         {Config.SERVICES}")
    print(f"{C_BOLD}SSH 目标:{C_RESET}         {Config.SSH_CONFIG_NAMES}")
    print(f"{C_BOLD}远程目录:{C_RESET}         {Config.SSH_REMOTE_DIR}")
    print(f"{C_BOLD}基础镜像:{C_RESET}         {Config.DOCKERFILE_BASE_IMAGE}")
    print(f"{C_BOLD}Dockerfile 映射:{C_RESET}")
    for item in Config.SERVICE_DOCKERFILE_PATHS.split():
        parts = item.rsplit(":", 1)
        if len(parts) == 2:
            df_path, df_svc = parts
            print(f"                    {df_path}  →  {df_svc}  (JAR: {df_svc}/target/{df_svc}.jar)")
    print(f"{C_BOLD}输出目录:{C_RESET}         {Config.OUTPUT_DIR}")
    if Config.DOCKER_COMPOSE_ENV_VARS:
        print(f"{C_BOLD}Compose环境变量:{C_RESET}")
        print(Config.DOCKER_COMPOSE_ENV_VARS)
    else:
        print(f"{C_BOLD}Compose环境变量:{C_RESET} （空）")

    print()
    if not confirm("确认以上配置并开始生成?"):
        print(f"{C_YELLOW}已取消。{C_RESET}")
        sys.exit(0)


# =============================================================================
#                    生成 Jenkinsfile
# =============================================================================
# 模板文件路径(与脚本同目录)
_JENKINSFILE_TEMPLATE_PATH = Path(__file__).parent / "Jenkinsfile.template"


def _load_jenkinsfile_template() -> str:
    """加载 Jenkinsfile 模板文件"""
    if not _JENKINSFILE_TEMPLATE_PATH.exists():
        sys.exit(f"错误: 找不到 Jenkinsfile 模板文件: {_JENKINSFILE_TEMPLATE_PATH}")
    return _JENKINSFILE_TEMPLATE_PATH.read_text(encoding="utf-8")


def generate_jenkinsfile(output_dir: str):
    """生成 Jenkinsfile"""
    out = Path(output_dir) / "Jenkinsfile"
    notify_title = f"{Config.PROJECT_NAME}：{Config.ENVIRONMENT}"

    content = _load_jenkinsfile_template()
    replacements = {
        "{{NOTIFY_TITLE}}":                  notify_title,
        "{{ENVIRONMENT}}":                  Config.ENVIRONMENT,
        "{{JENKINS_NODE_LABEL}}":            Config.JENKINS_NODE_LABEL,
        "{{BUILD_TIMEOUT}}":                 Config.BUILD_TIMEOUT,
        "{{BUILD_TIMEOUT_UNIT}}":            Config.BUILD_TIMEOUT_UNIT,
        "{{BUILD_KEEP_COUNT}}":              Config.BUILD_KEEP_COUNT,
        "{{MAVEN_HOME}}":                    Config.MAVEN_HOME,
        "{{JAVA_HOME}}":                     Config.JAVA_HOME,
        "{{MAVEN_OPTS}}":                    Config.MAVEN_OPTS,
        "{{DOCKER_BUILD_OPTS}}":             Config.DOCKER_BUILD_OPTS,
        "{{IMAGE_REGISTRY}}":              Config.IMAGE_REGISTRY,
        "{{IMAGE_REGISTRY_USER}}":         Config.IMAGE_REGISTRY_USER,
        "{{IMAGE_REGISTRY_PASSWORD}}":     Config.IMAGE_REGISTRY_PASSWORD,
        "{{IMAGE_PROJECT}}":                 Config.IMAGE_PROJECT,
        "{{SERVICES}}":                      Config.SERVICES,
        "{{SERVICE_DOCKERFILE_PATHS}}":      Config.SERVICE_DOCKERFILE_PATHS,
        "{{SSH_CONFIG_NAMES}}":              Config.SSH_CONFIG_NAMES,
        "{{SSH_REMOTE_DIR}}":                Config.SSH_REMOTE_DIR,
        "{{GIT_CREDENTIALS_ID}}":            Config.GIT_CREDENTIALS_ID,
        "{{GIT_REPO_URL}}":                  Config.GIT_REPO_URL,
        "{{GIT_BRANCH}}":                    Config.GIT_BRANCH,
        "{{WECHAT_WEBHOOK_CREDENTIALS_ID}}": Config.WECHAT_WEBHOOK_CREDENTIALS_ID,
    }

    for placeholder, value in replacements.items():
        content = content.replace(placeholder, value)

    out.write_text(content, encoding="utf-8")
    print(f"✅ 已生成: {out}")


# =============================================================================
#                    生成 dockerfile (按服务拆分)
# =============================================================================
DOCKERFILE_TEMPLATE = """FROM  {base_image}

MAINTAINER {maintainer}

ENV LANG=C.UTF-8
ENV TZ=Asia/Shanghai

# 设置时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

COPY {jar_source} {jar_target}

ENTRYPOINT ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "{jar_target}"]
"""


def generate_dockerfiles(output_dir: str):
    """按 SERVICES_DOCKERFILE_PATHS 拆分，每个服务生成一个 dockerfile"""
    items = Config.SERVICE_DOCKERFILE_PATHS.split()
    if not items:
        warn("⚠️ 未找到有效的 Dockerfile 路径映射，跳过生成")
        return

    for item in items:
        parts = item.rsplit(":", 1)
        if len(parts) != 2:
            warn(f"⚠️ 无效映射: {item}, 跳过")
            continue
        dockerfile_path, svc_name = parts
        out = Path(output_dir) / dockerfile_path
        jar_source = f"{svc_name}/target/{svc_name}.jar"
        jar_target = f"/app/{svc_name}.jar"

        out.parent.mkdir(parents=True, exist_ok=True)

        content = DOCKERFILE_TEMPLATE.format(
            base_image=Config.DOCKERFILE_BASE_IMAGE,
            maintainer=Config.DOCKERFILE_MAINTAINER,
            jar_source=jar_source,
            jar_target=jar_target,
        )
        out.write_text(content, encoding="utf-8")
        print(f"✅ 已生成: {out} (服务: {svc_name})")


# =============================================================================
#                    生成 deploy-to-production.sh
# =============================================================================
def generate_deploy_sh(output_dir: str):
    """生成 deploy-to-production.sh"""
    out = Path(output_dir) / "deploy-to-production.sh"

    # 构建服务端口关联数组声明
    ports_decl = ""
    for entry in Config.DEPLOY_SERVICE_PORTS.split(";"):
        entry = entry.strip()
        if "=" in entry:
            svc, port = entry.split("=", 1)
            ports_decl += f'SERVICE_PORTS["{svc}"]="{port}"\n'

    # 构建默认服务列表
    defaults_str = '"' + '" "'.join(Config.DEPLOY_DEFAULT_SERVICES) + '"'

    # 构建 docker-compose.yml 环境变量部分(默认为空)
    compose_env_section = ""
    if Config.DOCKER_COMPOSE_ENV_VARS:
        # 支持 \n 字面量和 ; 分号作为分隔符
        normalized = Config.DOCKER_COMPOSE_ENV_VARS.replace("\\n", "\n").replace(";", "\n")
        lines = [l.strip() for l in normalized.split("\n") if l.strip()]
        if lines:
            compose_env_section = "    environment:\n"
            for line in lines:
                compose_env_section += f"      - {line}\n"

    content = f"""#!/bin/bash
# 此文件由 generate-pipeline.py 自动生成
# 从命令行参数获取环境变量，设置默认值
IMAGE_REGISTRY_CHOICE=${{1:-{Config.DEPLOY_IMAGE_REGISTRY_CHOICE}}}
IMAGE_PROJECT=${{2:-{Config.DEPLOY_IMAGE_PROJECT}}}
IMAGE_VERSION=${{3:-{Config.DEPLOY_IMAGE_VERSION}}}
SSH_REMOTE_DIR=${{4:-{Config.DEPLOY_SSH_REMOTE_DIR}}}

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
CONTAINER_PREFIX="{Config.CONTAINER_PREFIX}"

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
        # 读取现有docker-compose.yml文件中的image行
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
            # 提取现有镜像仓库地址
            existing_registry=$(echo $existing_image | cut -d'/' -f1)

            echo "现有镜像仓库: $existing_registry"
            echo "目标镜像仓库: $IMAGE_REGISTRY_CHOICE"

            if [ "$existing_registry" == "$IMAGE_REGISTRY_CHOICE" ]; then
                echo "镜像仓库地址相同，仅更新版本号"
                # 仅替换版本号
                sed -i "s|image: $existing_registry/$IMAGE_PROJECT/$service:.*|image: $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION|g" "$docker_compose_file"
            else
                echo "镜像仓库地址不同，替换整个镜像地址"
                # 替换整个镜像地址
                sed -i "s|image: $existing_image|image: $IMAGE_REGISTRY_CHOICE/$IMAGE_PROJECT/$service:$IMAGE_VERSION|g" "$docker_compose_file"
            fi
        fi
    fi

    echo "✅  服务 $service 的docker-compose.yml文件版本更新完成"
done

# 登录到镜像仓库
echo "在部署节点登录到镜像仓库: $IMAGE_REGISTRY_CHOICE"
docker login -u {Config.DEPLOY_HARBOR_USER} -p {Config.DEPLOY_HARBOR_PASSWORD} $IMAGE_REGISTRY_CHOICE

# 并行拉取最新镜像
echo "开始并行拉取最新镜像..."

# 创建一个函数来拉取单个镜像
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

# 并行执行镜像拉取
declare -a pull_pids
declare -A pull_results
for service in "${{SERVICES[@]}}"; do
    pull_image $service &
    pull_pid=$!
    pull_pids+=($pull_pid)
    pull_results["$pull_pid"]=$service
done

# 等待所有镜像拉取完成
echo "等待所有镜像拉取完成..."
for pid in "${{pull_pids[@]}}"; do
    wait $pid
    exit_code=$?
    service=${{pull_results["$pid"]}}
    if [ $exit_code -ne 0 ]; then
        echo "⚠️ 服务 $service 镜像拉取失败，将跳过该服务"
    fi
done

# 并行停止并启动服务，进一步提高效率
echo "并行停止并启动服务..."

# 创建一个函数来停止并启动单个服务
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

# 并行执行服务部署
declare -a deploy_pids
declare -A deploy_results
for service in "${{SERVICES[@]}}"; do
    deploy_service $service &
    deploy_pid=$!
    deploy_pids+=($deploy_pid)
    deploy_results["$deploy_pid"]=$service
done

# 等待所有服务部署完成
echo "等待所有服务部署完成..."
for pid in "${{deploy_pids[@]}}"; do
    wait $pid
    exit_code=$?
    service=${{deploy_results["$pid"]}}
    if [ $exit_code -ne 0 ]; then
        echo "⚠️ 服务 $service 部署可能失败"
    fi
done

# 验证服务启动状态
echo "验证服务启动状态..."
for service in "${{SERVICES[@]}}"; do
    service_dir="$SSH_REMOTE_DIR/$service"
    echo "验证服务 $service 启动状态..."
    cd $service_dir
    docker-compose ps 2>/dev/null || echo "⚠️ 无法获取服务 $service 状态"
done

# 等待服务完全启动
sleep 5

# 检查每个服务的健康状态
echo "检查服务健康状态..."
for service in "${{SERVICES[@]}}"; do
    service_dir="$SSH_REMOTE_DIR/$service"
    echo "检查服务 $service 的健康状态..."
    cd $service_dir

    # 检查容器是否正在运行
    container_name="${{CONTAINER_PREFIX}}${{service}}"
    container_status=$(docker ps -f name="^/${{container_name}}$" --format "{{{{.Status}}}}" 2>/dev/null)

    if [ -n "$container_status" ]; then
        echo "✅  服务 $service 容器正在运行，状态: $container_status"
        # 显示容器日志的最后几行，帮助调试
        echo "服务 $service 日志预览:"
        docker logs --tail 5 "$container_name" 2>/dev/null || echo "⚠️ 无法获取日志"
    else
        echo "❌  服务 $service 容器未运行"
        # 显示容器的详细信息，帮助调试
        echo "服务 $service 容器详细信息:"
        docker ps -a -f name="^/${{container_name}}$" 2>/dev/null || echo "⚠️ 无法获取容器信息"
    fi
done

# 清理未使用的镜像
echo "清理未使用的镜像..."
docker system prune -a -f 2>/dev/null || echo "⚠️ 清理操作失败"

echo "===== 部署完成 ===="
"""

    out.write_text(content, encoding="utf-8")
    # 设置可执行权限
    try:
        out.chmod(0o755)
    except OSError:
        pass
    print(f"✅ 已生成: {out}")


# =============================================================================
#                         命令行参数解析
# =============================================================================
def parse_args():
    parser = argparse.ArgumentParser(
        description="流水线文件自动生成器 — 基于模板生成 deploy-to-production.sh / dockerfile / Jenkinsfile",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
环境变量方式:
  所有参数均可通过 PIPELINE_<变量名> 环境变量设置。
  例如: set PIPELINE_MAVEN_HOME=/opt/maven
        export PIPELINE_MAVEN_HOME=/opt/maven
        """
    )
    parser.add_argument("output_dir", nargs="?", default="",
                        help="输出目录 (默认: ./generated-pipeline)")
    parser.add_argument("--batch", action="store_true",
                        help="跳过交互，直接使用默认值(或环境变量)生成")

    # 所有可配置参数
    parser.add_argument("--project-name", help="项目名称 (企业微信通知标题)")
    parser.add_argument("--environment", help="部署环境")
    parser.add_argument("--maven-home", help="MAVEN_HOME 路径")
    parser.add_argument("--java-home", help="JAVA_HOME 路径")
    parser.add_argument("--maven-opts", help="MAVEN_OPTS")
    parser.add_argument("--docker-build-opts", help="DOCKER_BUILD_OPTS")
    parser.add_argument("--image-registry", help="Harbor 镜像仓库地址")
    parser.add_argument("--image-registry-user", help="Harbor 仓库登录用户")
    parser.add_argument("--image-registry-password", help="Harbor 仓库登录密码")
    parser.add_argument("--image-project", help="镜像项目名")
    parser.add_argument("--services", help="服务列表 (空格分隔)")
    parser.add_argument("--dockerfile-paths", help="Dockerfile 路径映射")
    parser.add_argument("--ssh-config-names", help="SSH 目标服务器 (逗号分隔)")
    parser.add_argument("--ssh-remote-dir", help="SSH 远程部署目录")
    parser.add_argument("--git-credentials-id", help="Git 凭据 ID")
    parser.add_argument("--git-repo-url", help="Git 仓库地址")
    parser.add_argument("--git-branch", help="Git 分支")
    parser.add_argument("--wechat-webhook-id", help="企业微信 Webhook 凭证 ID")
    parser.add_argument("--jenkins-node-label", help="Jenkins 节点标签")
    parser.add_argument("--build-timeout", help="构建超时时间")
    parser.add_argument("--build-timeout-unit", help="超时时间单位")
    parser.add_argument("--build-keep-count", help="保留构建历史数量")
    parser.add_argument("--deploy-registry", help="默认镜像仓库 (deploy脚本)")
    parser.add_argument("--deploy-image-project", help="默认镜像项目 (deploy脚本)")
    parser.add_argument("--deploy-image-version", help="默认镜像版本 (deploy脚本)")
    parser.add_argument("--deploy-ssh-remote-dir", help="默认 SSH 远程目录 (deploy脚本)")
    parser.add_argument("--deploy-default-services", nargs="*",
                        help="默认服务列表 (deploy脚本)")
    parser.add_argument("--deploy-service-ports", help="服务端口映射")
    parser.add_argument("--deploy-harbor-user", help="Harbor 登录用户 (deploy脚本)")
    parser.add_argument("--deploy-harbor-password", help="Harbor 登录密码 (deploy脚本)")
    parser.add_argument("--container-prefix", help="容器名称前缀")
    parser.add_argument("--dockerfile-base-image", help="Dockerfile 基础镜像")
    parser.add_argument("--dockerfile-maintainer", help="Dockerfile 维护者信息")
    parser.add_argument("--dockerfile-jar-source", help="Dockerfile JAR 源路径")
    parser.add_argument("--dockerfile-jar-target", help="Dockerfile JAR 目标路径")
    parser.add_argument("--docker-compose-env-vars", help="docker-compose.yml 环境变量")

    return parser.parse_args()


def apply_args(args):
    """将命令行参数应用到 Config"""
    mapping = {
        "project_name": "PROJECT_NAME",
        "environment": "ENVIRONMENT",
        "maven_home": "MAVEN_HOME",
        "java_home": "JAVA_HOME",
        "maven_opts": "MAVEN_OPTS",
        "docker_build_opts": "DOCKER_BUILD_OPTS",
        "image_registry": "IMAGE_REGISTRY",
        "image_registry_user": "IMAGE_REGISTRY_USER",
        "image_registry_password": "IMAGE_REGISTRY_PASSWORD",
        "image_project": "IMAGE_PROJECT",
        "services": "SERVICES",
        "dockerfile_paths": "SERVICE_DOCKERFILE_PATHS",
        "ssh_config_names": "SSH_CONFIG_NAMES",
        "ssh_remote_dir": "SSH_REMOTE_DIR",
        "git_credentials_id": "GIT_CREDENTIALS_ID",
        "git_repo_url": "GIT_REPO_URL",
        "git_branch": "GIT_BRANCH",
        "wechat_webhook_id": "WECHAT_WEBHOOK_CREDENTIALS_ID",
        "jenkins_node_label": "JENKINS_NODE_LABEL",
        "build_timeout": "BUILD_TIMEOUT",
        "build_timeout_unit": "BUILD_TIMEOUT_UNIT",
        "build_keep_count": "BUILD_KEEP_COUNT",
        "deploy_registry": "DEPLOY_IMAGE_REGISTRY_CHOICE",
        "deploy_image_project": "DEPLOY_IMAGE_PROJECT",
        "deploy_image_version": "DEPLOY_IMAGE_VERSION",
        "deploy_ssh_remote_dir": "DEPLOY_SSH_REMOTE_DIR",
        "deploy_service_ports": "DEPLOY_SERVICE_PORTS",
        "deploy_harbor_user": "DEPLOY_HARBOR_USER",
        "deploy_harbor_password": "DEPLOY_HARBOR_PASSWORD",
        "container_prefix": "CONTAINER_PREFIX",
        "dockerfile_base_image": "DOCKERFILE_BASE_IMAGE",
        "dockerfile_maintainer": "DOCKERFILE_MAINTAINER",
        "dockerfile_jar_source": "DOCKERFILE_JAR_SOURCE_PATH",
        "dockerfile_jar_target": "DOCKERFILE_JAR_TARGET_PATH",
        "docker_compose_env_vars": "DOCKER_COMPOSE_ENV_VARS",
    }

    for arg_name, attr_name in mapping.items():
        val = getattr(args, arg_name, None)
        if val is not None:
            if attr_name == "DEPLOY_DEFAULT_SERVICES" and isinstance(val, list):
                setattr(Config, attr_name, val)
            else:
                setattr(Config, attr_name, str(val))

    if args.output_dir:
        Config.OUTPUT_DIR = args.output_dir


# =============================================================================
#                            主入口
# =============================================================================
def main():
    args = parse_args()

    # 1. 环境变量覆盖
    override_from_env()

    # 2. 命令行参数覆盖
    apply_args(args)

    if args.batch:
        # 批处理模式
        if not Config.OUTPUT_DIR:
            Config.OUTPUT_DIR = "./generated-pipeline"
        Path(Config.OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
        print("==============================================")
        print("  流水线文件生成器 (批处理模式)")
        print("==============================================")
        print(f"输出目录: {Config.OUTPUT_DIR}")
        print(f"项目名称: {Config.PROJECT_NAME}")
        print(f"环境:     {Config.ENVIRONMENT}")
        print()
    else:
        # 交互模式
        interactive_config()
        Path(Config.OUTPUT_DIR).mkdir(parents=True, exist_ok=True)

    # 生成文件
    print(">>> 生成 Jenkinsfile...")
    generate_jenkinsfile(Config.OUTPUT_DIR)

    print(">>> 生成 dockerfile（按服务拆分）...")
    generate_dockerfiles(Config.OUTPUT_DIR)

    print(">>> 生成 deploy-to-production.sh...")
    generate_deploy_sh(Config.OUTPUT_DIR)

    print()
    print("==============================================")
    print("  生成完成!")
    print("==============================================")
    print(f"输出目录: {Config.OUTPUT_DIR}")
    print()
    print("生成的文件:")
    out_path = Path(Config.OUTPUT_DIR)
    for f in sorted(out_path.rglob("*")):
        if f.is_file():
            print(f"  {f.relative_to(out_path)}")
    print()
    # 检测脚本文件名
    script_name = Path(__file__).name if "__file__" in dir() else "generate-pipeline.py"
    print("提示: 可通过以下方式自定义参数:")
    print(f"  1. 命令行参数: python {script_name} --project-name '新项目' --environment '生产环境'")
    print(f"  2. 环境变量:   PIPELINE_PROJECT_NAME='新项目' python {script_name}")
    print(f"  3. 查看所有参数: python {script_name} --help")


if __name__ == "__main__":
    main()
