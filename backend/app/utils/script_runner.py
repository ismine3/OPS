"""
按扩展名执行定时任务脚本（.py / .sh / .sql），避免一律用 python 调用。
"""
import os
import sys
import shutil
import subprocess
import logging

logger = logging.getLogger(__name__)


def _ext(script_path: str) -> str:
    if not script_path or "." not in script_path:
        return ""
    return script_path.rsplit(".", 1)[-1].lower()


def run_script_file(script_path, db_config=None, timeout=300):
    """
    执行脚本文件，返回 subprocess.CompletedProcess。
    db_config: 执行 .sql 时必填，需含 host, port, user, password, database。
    """
    if not script_path or not os.path.isfile(script_path):
        raise FileNotFoundError(f"脚本不存在: {script_path}")

    ext = _ext(script_path)
    if ext == "py":
        return subprocess.run(
            [sys.executable, script_path],
            capture_output=True,
            text=True,
            timeout=timeout,
        )

    if ext == "sh":
        bash = shutil.which("bash")
        if bash:
            return subprocess.run(
                [bash, script_path],
                capture_output=True,
                text=True,
                timeout=timeout,
            )
        sh = shutil.which("sh")
        if sh:
            return subprocess.run(
                [sh, script_path],
                capture_output=True,
                text=True,
                timeout=timeout,
            )
        raise RuntimeError("未找到 bash/sh，无法执行 .sh 脚本")

    if ext == "sql":
        if not db_config:
            raise RuntimeError("执行 .sql 脚本需要提供数据库连接配置")
        mysql = shutil.which("mysql")
        if not mysql:
            raise RuntimeError("未找到 mysql 客户端，无法执行 .sql 脚本")
        env = os.environ.copy()
        pwd = db_config.get("password") or ""
        env["MYSQL_PWD"] = str(pwd)
        cmd = [
            mysql,
            "-h",
            str(db_config.get("host", "127.0.0.1")),
            "-P",
            str(db_config.get("port", 3306)),
            "-u",
            str(db_config.get("user", "root")),
            "--protocol=tcp",
            str(db_config.get("database", "")),
        ]
        with open(script_path, "rb") as f:
            return subprocess.run(
                cmd,
                stdin=f,
                capture_output=True,
                text=True,
                timeout=timeout,
                env=env,
            )

    raise ValueError(f"不支持的脚本类型: .{ext}")


def assert_allowed_script(filename: str) -> None:
    """上传脚本扩展名校验（与 tasks 白名单一致）"""
    allowed = {"py", "sh", "sql"}
    if not filename or "." not in filename:
        raise ValueError("无效的文件名")
    ext = filename.rsplit(".", 1)[1].lower()
    if ext not in allowed:
        raise ValueError(f"仅允许上传扩展名为 {', '.join(sorted(allowed))} 的脚本")
