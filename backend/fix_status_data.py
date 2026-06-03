"""
批量修复 ssl_certificates 和 domains 表的 status 字段数据不一致问题
将历史数据中的数字状态码统一转换为中文文本
"""
import sys
import pymysql
from app.config import Config


def get_connection():
    return pymysql.connect(
        host=Config.DB_HOST,
        port=Config.DB_PORT,
        user=Config.DB_USER,
        password=Config.DB_PASSWORD,
        database=Config.DB_NAME,
        charset='utf8mb4',
        cursorclass=pymysql.cursors.DictCursor,
    )


def fix_cert_status():
    """修复 ssl_certificates.status：数字→中文，并基于 remaining_days 重新计算"""
    conn = get_connection()
    cursor = conn.cursor()

    # 读取预警天数阈值
    warning_days = 30
    try:
        cursor.execute(
            "SELECT config_value FROM system_config WHERE config_key = 'ssl_warning_days'"
        )
        row = cursor.fetchone()
        if row and row['config_value']:
            warning_days = int(row['config_value'])
    except Exception:
        pass

    print(f"[证书] SSL 预警天数阈值: {warning_days} 天")

    # 1. 数字 '0' → '已过期'
    cursor.execute("UPDATE ssl_certificates SET status = '已过期' WHERE status IN ('0')")
    affected0 = cursor.rowcount

    # 2. 数字 '2' → '即将过期'
    cursor.execute("UPDATE ssl_certificates SET status = '即将过期' WHERE status IN ('2')")
    affected2 = cursor.rowcount

    # 3. 数字 '1' → 根据 remaining_days / cert_expire_time 重新计算
    cursor.execute("""
        UPDATE ssl_certificates
        SET status = CASE
            WHEN cert_expire_time IS NULL THEN '正常'
            WHEN DATEDIFF(cert_expire_time, NOW()) <= 0 THEN '已过期'
            WHEN DATEDIFF(cert_expire_time, NOW()) <= %s THEN '即将过期'
            ELSE '正常'
        END
        WHERE status IN ('1')
    """, (warning_days,))
    affected1 = cursor.rowcount

    conn.commit()
    total = affected0 + affected1 + affected2
    print(f"[证书] 修复完成: '0'→已过期 {affected0} 条, '1'→按天数重算 {affected1} 条, '2'→即将过期 {affected2} 条, 共 {total} 条")

    # 验证结果
    cursor.execute("SELECT status, COUNT(*) as cnt FROM ssl_certificates GROUP BY status ORDER BY status")
    print("[证书] 当前状态分布:")
    for row in cursor.fetchall():
        print(f"  {row['status']}: {row['cnt']} 条")

    cursor.close()
    conn.close()


def fix_domain_status():
    """修复 domains.status：数字→中文"""
    conn = get_connection()
    cursor = conn.cursor()

    mapping = [
        ('1', '急需续费'),
        ('2', '急需赎回'),
        ('3', '正常'),
        ('4', '已过期'),
    ]

    total = 0
    for old_val, new_val in mapping:
        cursor.execute(
            "UPDATE domains SET status = %s WHERE status = %s",
            (new_val, old_val)
        )
        cnt = cursor.rowcount
        if cnt > 0:
            print(f"[域名] '{old_val}' → '{new_val}': {cnt} 条")
        total += cnt

    conn.commit()
    print(f"[域名] 修复完成，共 {total} 条")

    # 验证结果
    cursor.execute("SELECT status, COUNT(*) as cnt FROM domains GROUP BY status ORDER BY status")
    print("[域名] 当前状态分布:")
    for row in cursor.fetchall():
        print(f"  {row['status']}: {row['cnt']} 条")

    cursor.close()
    conn.close()


if __name__ == '__main__':
    try:
        fix_cert_status()
        print()
        fix_domain_status()
        print("\n✅ 全部修复完成")
    except Exception as e:
        print(f"\n❌ 修复失败: {e}", file=sys.stderr)
        sys.exit(1)
