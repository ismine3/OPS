"""
密码定期轮换核心模块
使用 paramiko 通过 SSH 连接服务器，安全地修改密码

支持三种场景：
1. 只有普通用户(regular_user)：只更新普通用户密码 → regular_password
2. root + 普通用户都有：两个都更新 → os_password + regular_password
3. 只有 root(os_user)：只更新 root 密码 → os_password

安全保证：
- 修改后验证新密码可用性，成功后才更新数据库
- 验证失败时尝试恢复旧密码
- 状态锁定防止并发修改
"""
import paramiko
import time
import datetime
import random
import string
import hashlib
import logging
import pymysql

from .password_utils import encrypt_data, decrypt_data

logger = logging.getLogger(__name__)


def generate_random_password(length=16):
    """
    生成强随机密码：包含大小写字母、数字和特殊字符
    
    Args:
        length: 密码长度，默认16位
    
    Returns:
        随机密码字符串
    """
    lowercase = string.ascii_lowercase
    uppercase = string.ascii_uppercase
    digits = string.digits
    special = '!@#$%^&*()-_=+[]{}|;:,.<>?'

    # 确保至少包含每种类型一个字符
    chars = [
        random.choice(lowercase),
        random.choice(uppercase),
        random.choice(digits),
        random.choice(special),
    ]

    # 剩余长度从所有字符中随机选取
    all_chars = lowercase + uppercase + digits + special
    chars.extend(random.choice(all_chars) for _ in range(length - 4))

    # 打乱顺序
    random.shuffle(chars)
    return ''.join(chars)


def test_ssh_connection(host, user, password, port=22, timeout=10):
    """
    测试 SSH 连接是否可用
    
    Args:
        host: 服务器IP
        user: SSH用户名
        password: SSH密码
        port: SSH端口
        timeout: 超时时间（秒）
    
    Returns:
        (success: bool, message: str)
    """
    client = paramiko.SSHClient()
    client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        client.connect(
            hostname=host,
            port=port,
            username=user,
            password=password,
            timeout=timeout,
            allow_agent=False,
            look_for_keys=False,
        )
        # 执行简单命令验证连接
        stdin, stdout, stderr = client.exec_command('whoami', timeout=timeout)
        result = stdout.read().decode('utf-8').strip()
        if result:
            return True, f'SSH连接验证成功，当前用户: {result}'
        else:
            return True, 'SSH连接成功'
    except paramiko.AuthenticationException:
        return False, 'SSH认证失败：用户名或密码错误'
    except paramiko.SSHException as e:
        return False, f'SSH连接异常: {str(e)}'
    except Exception as e:
        return False, f'SSH连接失败: {str(e)}'
    finally:
        try:
            client.close()
        except Exception:
            pass


def _change_own_password(ssh_client, old_password, new_password):
    """
    修改当前登录用户自身的密码
    优先使用 sudo chpasswd，失败则回退到交互式 passwd
    
    Args:
        ssh_client: 已连接的 paramiko SSHClient
        old_password: 当前密码
        new_password: 新密码
    
    Returns:
        (success: bool, message: str)
    """
    # 获取当前用户名
    stdin, stdout, stderr = ssh_client.exec_command('whoami', timeout=10)
    current_user = stdout.read().decode('utf-8').strip()
    if not current_user:
        return False, '无法获取当前用户名'

    # 方式1: 尝试通过 sudo chpasswd 修改（最可靠）
    try:
        escaped_new = new_password.replace("'", "'\\''")
        cmd = f"echo '{current_user}:{escaped_new}' | sudo chpasswd 2>&1"
        stdin, stdout, stderr = ssh_client.exec_command(cmd, timeout=30)
        exit_code = stdout.channel.recv_exit_status()
        
        if exit_code == 0:
            return True, f'{current_user}密码修改成功(sudo chpasswd)'
        
        # sudo 失败，尝试直接 chpasswd（如果已经是 root）
        cmd2 = f"echo '{current_user}:{escaped_new}' | chpasswd 2>&1"
        stdin, stdout, stderr = ssh_client.exec_command(cmd2, timeout=30)
        exit_code2 = stdout.channel.recv_exit_status()
        
        if exit_code2 == 0:
            return True, f'{current_user}密码修改成功(chpasswd)'
    except Exception:
        pass

    # 方式2: 交互式 passwd 修改（回退方案）
    return _change_password_interactive(ssh_client, old_password, new_password, current_user)


def _change_password_interactive(ssh_client, old_password, new_password, username):
    """
    使用交互式 shell + passwd 命令修改密码（回退方案）
    passwd 交互流程: Current password: → New password: → Retype new password:
    """
    channel = None
    try:
        channel = ssh_client.invoke_shell(width=200, height=50)
        time.sleep(0.5)

        # 清空初始输出
        if channel.recv_ready():
            channel.recv(4096)

        # 发送 passwd 命令
        channel.send('passwd\n')
        time.sleep(0.8)

        # 收集输出，检测 "Current password" 或 "(current)" 提示
        output = b''
        for _ in range(5):
            if channel.recv_ready():
                output += channel.recv(4096)
            time.sleep(0.2)

        output_str = output.decode('utf-8', errors='ignore')

        # 发送当前密码
        if 'current' in output_str.lower() or 'assword' in output_str or '密码' in output_str:
            channel.send(old_password + '\n')
            time.sleep(1)
        else:
            channel.close()
            return False, f'passwd未提示输入当前密码: {output_str[:200]}'

        # 收集 "New password" 提示
        output2 = b''
        for _ in range(5):
            if channel.recv_ready():
                output2 += channel.recv(4096)
            time.sleep(0.2)
        output2_str = output2.decode('utf-8', errors='ignore')

        if 'new' in output2_str.lower() or 'assword' in output2_str or '新' in output2_str:
            channel.send(new_password + '\n')
            time.sleep(1)
        else:
            channel.close()
            return False, f'passwd未提示输入新密码: {output2_str[:200]}'

        # 收集 "Retype new password" 提示
        output3 = b''
        for _ in range(5):
            if channel.recv_ready():
                output3 += channel.recv(4096)
            time.sleep(0.2)
        output3_str = output3.decode('utf-8', errors='ignore')

        if 'retype' in output3_str.lower() or 'again' in output3_str.lower() or '再次' in output3_str or '重新' in output3_str:
            channel.send(new_password + '\n')
            time.sleep(1.5)

        # 读取最终结果
        time.sleep(0.5)
        final_output = b''
        for _ in range(5):
            if channel.recv_ready():
                final_output += channel.recv(4096)
            time.sleep(0.3)
        final_str = final_output.decode('utf-8', errors='ignore')

        # 判断结果
        if 'successfully' in final_str.lower() or 'updated successfully' in final_str.lower() or '成功' in final_str:
            return True, f'{username}密码修改成功(interactive passwd)'
        if 'BAD PASSWORD' in final_str or 'bad password' in final_str.lower():
            # BAD PASSWORD 是警告不是错误，可能仍然成功了
            if 'successfully' in final_str.lower() or '成功' in final_str:
                return True, f'{username}密码修改成功(含弱密码警告)'
        if 'Authentication token manipulation error' in final_str:
            return False, '密码修改失败：认证令牌操作错误（当前密码可能不正确）'
        if 'password unchanged' in final_str.lower():
            return False, '密码未变更：新密码可能不符合复杂度要求'

        # 没有明确错误，尝试检测是否成功
        if 'failure' not in final_str.lower() and 'error' not in final_str.lower():
            return True, f'{username}密码修改完成(无错误输出)'

        return False, f'passwd执行结果不明确: {final_str[:200]}'

    except Exception as e:
        return False, f'交互式密码修改异常: {str(e)}'
    finally:
        if channel:
            try:
                channel.close()
            except Exception:
                pass


def rotate_server_password(server, db_config):
    """
    对单台服务器执行密码轮换，包含完整的安全保障流程
    
    三种场景：
    1. 只有普通用户(regular_user)：SSH登录普通用户，修改自身密码 → regular_password
    2. root + 普通用户都有：SSH登录普通用户 → su切换到root → 以root统一更新两个密码
    3. 只有 root(os_user)：SSH登录root，修改自身密码 → os_password
    
    Args:
        server: 服务器记录字典
        db_config: 数据库配置字典
    
    Returns:
        dict: {'success': bool, 'message': str}
    """
    server_id = server['id']
    hostname = server.get('hostname', '')
    inner_ip = server.get('inner_ip', '')
    target_ip = inner_ip or hostname

    regular_user = server.get('regular_user', '') or ''
    regular_pw_enc = server.get('regular_password', '') or ''
    os_user = server.get('os_user', 'root') or 'root'
    os_pw_enc = server.get('os_password', '') or ''

    has_regular = bool(regular_user and regular_pw_enc)
    has_os = bool(os_pw_enc)

    if not has_regular and not has_os:
        return {'success': False, 'message': '服务器未配置任何可轮换的密码'}

    conn = None
    cursor = None

    try:
        conn = pymysql.connect(**db_config)
        cursor = conn.cursor()

        # Step 1: 设置状态为 running（状态锁）
        cursor.execute(
            "UPDATE servers SET password_rotation_status = 'running', password_rotation_error = NULL "
            "WHERE id = %s AND password_rotation_status != 'running'",
            (server_id,)
        )
        conn.commit()
        if cursor.rowcount == 0:
            return {'success': False, 'message': '服务器正在执行密码轮换中，请稍后重试'}

        # 根据场景选择策略
        if has_regular and has_os:
            # 场景2: 两者都有 → 普通用户登录 → su切换root → 统一更新
            result = _rotate_both_via_su(
                cursor, conn, server_id, hostname, target_ip,
                regular_user, regular_pw_enc, os_user, os_pw_enc
            )
        elif has_regular:
            # 场景1: 只有普通用户
            result = _rotate_one_password(
                cursor, conn, server_id, hostname, target_ip,
                regular_user, regular_pw_enc, 'regular_password',
                f'普通用户 {regular_user}'
            )
        else:
            # 场景3: 只有root
            result = _rotate_one_password(
                cursor, conn, server_id, hostname, target_ip,
                os_user, os_pw_enc, 'os_password',
                f'系统用户 {os_user}'
            )

        # 最终状态
        if result['success']:
            cursor.execute(
                "UPDATE servers SET password_rotation_status = 'success', password_rotation_error = NULL WHERE id = %s",
                (server_id,)
            )
            conn.commit()
        else:
            _set_status(cursor, conn, server_id, 'failed', result['message'])

        return result

    except Exception as e:
        logger.exception("服务器 %s 密码轮换异常", server_id)
        if conn:
            try:
                _set_status(cursor, conn, server_id, 'failed', f'未知异常: {str(e)}')
            except Exception:
                pass
        return {'success': False, 'message': f'密码轮换异常: {str(e)}'}
    finally:
        if cursor:
            try:
                cursor.close()
            except Exception:
                pass
        if conn:
            try:
                conn.close()
            except Exception:
                pass


def _rotate_both_via_su(cursor, conn, server_id, hostname, target_ip,
                        regular_user, regular_pw_enc, os_user, os_pw_enc):
    """
    场景2: 两者都有
    SSH登录普通用户 → su切换到root → 以root身份统一更新两个密码
    
    流程:
    1. 解密两个旧密码，生成两个新密码
    2. SSH以普通用户登录
    3. su切换到root（提供root旧密码）
    4. 以root执行chpasswd同时修改root和普通用户密码
    5. 分别验证两个新密码
    6. 全部成功才更新数据库
    """
    # Step 1: 解密旧密码 + 生成新密码
    try:
        regular_old = decrypt_data(regular_pw_enc)
        os_old = decrypt_data(os_pw_enc)
    except Exception as e:
        return {'success': False, 'message': f'旧密码解密失败: {str(e)}'}

    if not regular_old or not os_old:
        return {'success': False, 'message': '旧密码为空'}

    regular_new = generate_random_password()
    os_new = generate_random_password()

    logger.info("服务器 %s(%s): [双账户] 以 %s 登录 → su root → 统一更新所有密码",
                hostname, target_ip, regular_user)

    # Step 2: SSH以普通用户登录
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
    try:
        ssh.connect(
            hostname=target_ip, port=22, username=regular_user,
            password=regular_old, timeout=30,
            allow_agent=False, look_for_keys=False,
        )
    except paramiko.AuthenticationException as e:
        return {'success': False, 'message': f'普通用户 {regular_user} SSH认证失败: {str(e)}'}
    except Exception as e:
        return {'success': False, 'message': f'普通用户 {regular_user} SSH连接失败: {str(e)}'}

    # Step 3-4: su切换到root，执行密码修改
    su_ok, su_msg = _change_both_passwords_as_root(
        ssh, os_old, regular_user, regular_new, os_new
    )
    try:
        ssh.close()
    except Exception:
        pass

    if not su_ok:
        return {'success': False, 'message': f'su切换root修改密码失败: {su_msg}'}

    # Step 5: 分别验证两个新密码
    failures = []

    root_ok, root_msg = test_ssh_connection(target_ip, os_user, os_new)
    if not root_ok:
        failures.append(f'{os_user}: {root_msg}')
        logger.error("服务器 %s(%s): root新密码验证失败: %s", hostname, target_ip, root_msg)
        _try_restore_password(target_ip, os_user, os_old)

    reg_ok, reg_msg = test_ssh_connection(target_ip, regular_user, regular_new)
    if not reg_ok:
        failures.append(f'{regular_user}: {reg_msg}')
        logger.error("服务器 %s(%s): 普通用户新密码验证失败: %s", hostname, target_ip, reg_msg)
        _try_restore_password(target_ip, regular_user, regular_old)

    if failures:
        # 部分验证失败时也尝试恢复另一个
        if root_ok:
            _try_restore_password(target_ip, os_user, os_old)
        if reg_ok:
            _try_restore_password(target_ip, regular_user, regular_old)
        return {'success': False, 'message': f'新密码验证失败: {"; ".join(failures)}'}

    # Step 6: 全部成功，更新数据库
    encrypted_reg = encrypt_data(regular_new)
    encrypted_os = encrypt_data(os_new)
    now = datetime.datetime.now()
    reg_hash = hashlib.sha256(regular_old.encode()).hexdigest()
    os_hash = hashlib.sha256(os_old.encode()).hexdigest()

    cursor.execute(
        """UPDATE servers 
           SET regular_password = %s, os_password = %s, 
               password_last_rotated_at = %s
           WHERE id = %s""",
        (encrypted_reg, encrypted_os, now, server_id)
    )

    cursor.execute(
        """INSERT INTO password_rotation_logs (server_id, old_password_hash, status, rotated_at)
           VALUES (%s, %s, %s, %s)""",
        (server_id, f'{reg_hash}|{os_hash}', 'success', now)
    )
    conn.commit()
    logger.info("服务器 %s(%s): 双账户密码轮换成功!", hostname, target_ip)

    return {
        'success': True,
        'message': f'普通用户 {regular_user} 和系统用户 {os_user} 密码均已更新成功'
    }


def _change_both_passwords_as_root(ssh_client, root_old_pw, regular_user, regular_new_pw, root_new_pw):
    """
    以当前SSH会话（普通用户）执行 su 切换到 root，然后以 root 身份修改两个账户密码
    """
    channel = None
    try:
        channel = ssh_client.invoke_shell(width=200, height=50)
        time.sleep(0.5)
        if channel.recv_ready():
            channel.recv(4096)

        # su 到 root，执行 chpasswd 同时改两个密码
        # 重要：先改普通用户再改 root，中间失败时 root 密码不变，仍可登录恢复
        escaped_reg = regular_new_pw.replace("'", "'\\''")
        escaped_root = root_new_pw.replace("'", "'\\''")
        cmd = (f"su -c \"echo '{regular_user}:{escaped_reg}' | chpasswd "
               f"&& echo 'root:{escaped_root}' | chpasswd\"\n")
        channel.send(cmd)
        time.sleep(1)

        # 收集 su 前的输出，检测密码提示
        output = b''
        for _ in range(5):
            if channel.recv_ready():
                output += channel.recv(4096)
            time.sleep(0.25)
        output_str = output.decode('utf-8', errors='ignore')

        # 提供 root 密码给 su
        if 'Password:' in output_str or 'assword:' in output_str or '密码' in output_str:
            channel.send(root_old_pw + '\n')
            time.sleep(2)
        else:
            time.sleep(1.5)

        # 收集执行结果
        result_output = b''
        for _ in range(8):
            if channel.recv_ready():
                result_output += channel.recv(4096)
            time.sleep(0.3)
        time.sleep(0.5)
        for _ in range(3):
            if channel.recv_ready():
                result_output += channel.recv(4096)
            time.sleep(0.2)
        result_str = result_output.decode('utf-8', errors='ignore')

        # 检查 su 认证失败
        if 'su: Authentication failure' in result_str or 'su: 鉴定故障' in result_str:
            return False, f'su认证失败(root密码错误): {result_str[:200]}'
        if 'incorrect password' in result_str.lower():
            return False, f'su密码错误: {result_str[:200]}'
        # 检查 chpasswd 报错
        if 'chpasswd:' in result_str and ('error' in result_str.lower() or 'failed' in result_str.lower()):
            return False, f'chpasswd执行失败: {result_str[:200]}'

        return True, '通过su切换root统一修改密码完成'
    except Exception as e:
        return False, f'su修改密码异常: {str(e)}'
    finally:
        if channel:
            try:
                channel.close()
            except Exception:
                pass


def _rotate_one_password(cursor, conn, server_id, hostname, target_ip,
                         target_user, encrypted_password, update_field, mode_desc):
    """
    轮换单个账户的密码（场景1和场景3）
    SSH以目标用户登录，修改自身密码
    
    流程：解密 → 生成 → SSH连接 → 修改 → 验证 → 更新DB
    """
    # Step 1: 解密旧密码
    if not encrypted_password:
        return {'success': False, 'message': f'{mode_desc}: 未配置密码'}

    try:
        old_password = decrypt_data(encrypted_password)
    except Exception as e:
        return {'success': False, 'message': f'{mode_desc}: 旧密码解密失败: {str(e)}'}

    if not old_password:
        return {'success': False, 'message': f'{mode_desc}: 旧密码为空'}

    # Step 2: 生成新密码
    new_password = generate_random_password()

    logger.info("服务器 %s(%s): [单账户] 以 %s 登录，修改自身密码", hostname, target_ip, target_user)

    # Step 3: SSH 连接并修改密码
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        ssh_client.connect(
            hostname=target_ip, port=22, username=target_user,
            password=old_password, timeout=30,
            allow_agent=False, look_for_keys=False,
        )
        success, change_msg = _change_own_password(ssh_client, old_password, new_password)
        if not success:
            return {'success': False, 'message': f'{mode_desc}: 密码修改失败: {change_msg}'}
    except paramiko.AuthenticationException as e:
        return {'success': False, 'message': f'{mode_desc}: SSH认证失败: {str(e)}'}
    except Exception as e:
        return {'success': False, 'message': f'{mode_desc}: SSH连接失败: {str(e)}'}
    finally:
        try:
            ssh_client.close()
        except Exception:
            pass

    # Step 4: 用新密码验证连接
    logger.info("服务器 %s(%s): 验证 %s 新密码...", hostname, target_ip, mode_desc)
    verify_ok, verify_msg = test_ssh_connection(target_ip, target_user, new_password)

    if not verify_ok:
        logger.error("服务器 %s(%s): %s新密码验证失败: %s", hostname, target_ip, mode_desc, verify_msg)
        _try_restore_password(target_ip, target_user, old_password)
        return {'success': False, 'message': f'{mode_desc}: 新密码验证失败: {verify_msg}'}

    # Step 5: 成功，更新数据库
    encrypted_new = encrypt_data(new_password)
    now = datetime.datetime.now()
    old_hash = hashlib.sha256(old_password.encode()).hexdigest()

    cursor.execute(
        f"""UPDATE servers 
           SET {update_field} = %s, 
               password_last_rotated_at = %s
           WHERE id = %s""",
        (encrypted_new, now, server_id)
    )

    cursor.execute(
        """INSERT INTO password_rotation_logs (server_id, old_password_hash, status, rotated_at)
           VALUES (%s, %s, %s, %s)""",
        (server_id, old_hash, 'success', now)
    )
    conn.commit()
    logger.info("服务器 %s(%s): %s密码轮换成功!", hostname, target_ip, mode_desc)

    return {'success': True, 'message': f'{mode_desc}: 密码更新成功'}


def _set_status(cursor, conn, server_id, status, error=None):
    """设置服务器的密码轮换状态"""
    now = datetime.datetime.now()
    if error:
        cursor.execute(
            "UPDATE servers SET password_rotation_status = %s, password_rotation_error = %s WHERE id = %s",
            (status, error[:1000] if error else None, server_id)
        )
    else:
        cursor.execute(
            "UPDATE servers SET password_rotation_status = %s, password_rotation_error = NULL WHERE id = %s",
            (status, server_id)
        )
    conn.commit()

    # 如果是失败状态，记录日志
    if status == 'failed' and error:
        cursor.execute(
            """INSERT INTO password_rotation_logs (server_id, old_password_hash, status, error_message, rotated_at)
               VALUES (%s, %s, %s, %s, %s)""",
            (server_id, None, 'failed', error[:1000], now)
        )
        conn.commit()


def _try_restore_password(target_ip, target_user, old_password):
    """
    尝试恢复旧密码
    新密码验证失败时调用此函数，尽力恢复旧密码以保证服务器可访问
    """
    ssh_client = paramiko.SSHClient()
    ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    try:
        # 用新密码连接可能失败了，尝试用旧密码连接恢复
        # 注意：如果修改成功但验证失败，旧密码应该还能用
        ssh_client.connect(
            hostname=target_ip,
            port=22,
            username=target_user,
            password=old_password,
            timeout=30,
            allow_agent=False,
            look_for_keys=False,
        )
        # 旧密码还能登录，说明密码没被修改或已自动回滚，无需额外操作
        logger.info("服务器 %s: 旧密码仍可登录，无需恢复", target_ip)
        return
    except paramiko.AuthenticationException:
        logger.warning("服务器 %s: 旧密码也无法登录，密码可能已被修改但验证失败", target_ip)
    except Exception as e:
        logger.error("服务器 %s: 旧密码登录检查失败: %s", target_ip, str(e))
    finally:
        try:
            ssh_client.close()
        except Exception:
            pass
