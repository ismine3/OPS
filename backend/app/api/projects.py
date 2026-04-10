"""
项目管理 API
"""
from flask import Blueprint, request, jsonify
from ..utils.db import get_db
from ..utils.decorators import jwt_required, role_required, module_required
from ..utils.operation_log import log_operation
from ..utils.password_utils import decrypt_data

projects_bp = Blueprint('projects', __name__, url_prefix='/api')


@projects_bp.route('/projects', methods=['GET'])
@jwt_required
@module_required('projects')
def get_projects():
    """
    获取项目列表
    支持查询参数: search(搜索project_name/owner), status, page, per_page
    每个项目返回关联资源计数
    """
    db = get_db()
    cursor = db.cursor()
    try:
        search = request.args.get('search', '')
        status = request.args.get('status', '')
        page = request.args.get('page', '1')
        per_page = request.args.get('per_page', '10')

        # 分页参数处理
        try:
            page = int(page)
            per_page = int(per_page)
            if page < 1:
                page = 1
            if per_page < 1:
                per_page = 10
            if per_page > 100:
                per_page = 100
        except ValueError:
            page = 1
            per_page = 10

        # 构建基础查询条件
        where_clause = "WHERE 1=1"
        params = []
        if status:
            where_clause += " AND p.status = %s"
            params.append(status)
        if search:
            where_clause += " AND (p.project_name LIKE %s OR p.owner LIKE %s)"
            params.extend([f'%{search}%'] * 2)

        # 查询总数
        count_sql = f"SELECT COUNT(*) as total FROM projects p {where_clause}"
        cursor.execute(count_sql, params)
        total = cursor.fetchone()['total']

        # 查询项目列表，包含关联资源计数
        sql = f"""
            SELECT 
                p.*,
                (SELECT COUNT(*) FROM project_servers ps WHERE ps.project_id = p.id) as server_count,
                (SELECT COUNT(*) FROM services s WHERE s.project_id = p.id) as service_count,
                (SELECT COUNT(*) FROM domains d WHERE d.project_id = p.id) as domain_count,
                (SELECT COUNT(*) FROM ssl_certificates c WHERE c.project_id = p.id) as cert_count,
                (SELECT COUNT(*) FROM accounts a WHERE a.project_id = p.id) as account_count
            FROM projects p
            {where_clause}
            ORDER BY p.id DESC
            LIMIT %s OFFSET %s
        """
        offset = (page - 1) * per_page
        cursor.execute(sql, params + [per_page, offset])
        projects = cursor.fetchall()

        return jsonify({
            'code': 200,
            'data': {
                'items': projects,
                'total': total,
                'page': page,
                'per_page': per_page
            }
        })
    finally:
        cursor.close()


@projects_bp.route('/projects/options', methods=['GET'])
@jwt_required
def get_project_options():
    """
    获取项目选项列表（供其他模块下拉选择，仅需登录认证）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        cursor.execute("SELECT id, project_name AS name FROM projects ORDER BY id DESC")
        projects = cursor.fetchall()
        return jsonify({
            'code': 200,
            'data': projects
        })
    finally:
        cursor.close()


@projects_bp.route('/projects', methods=['POST'])
@jwt_required
@module_required('projects')
@role_required(['admin', 'operator'])
def create_project():
    """
    创建项目
    必填: project_name
    可选: description, owner, status, remark
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.get_json(silent=True) or {}
        if not data:
            return jsonify({"code": 400, "message": "请求体不能为空"}), 400

        project_name = data.get('project_name', '').strip()
        if not project_name:
            return jsonify({"code": 400, "message": "项目名称不能为空"}), 400

        # 检查项目名称是否已存在
        cursor.execute("SELECT id FROM projects WHERE project_name = %s", (project_name,))
        if cursor.fetchone():
            return jsonify({"code": 400, "message": "项目名称已存在"}), 400

        description = data.get('description', '').strip()
        owner = data.get('owner', '').strip()
        status = data.get('status', '运行中').strip()
        remark = data.get('remark', '').strip()

        cursor.execute(
            """
            INSERT INTO projects (project_name, description, owner, status, remark)
            VALUES (%s, %s, %s, %s, %s)
            """,
            (project_name, description or None, owner or None, status or '运行中', remark or None)
        )
        db.commit()
        project_id = cursor.lastrowid

        # 记录操作日志
        log_operation(
            module='项目管理',
            action='create',
            target_id=project_id,
            target_name=project_name,
            detail={'owner': owner, 'status': status}
        )

        return jsonify({
            'code': 200,
            'message': '创建成功',
            'data': {'id': project_id}
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'创建失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@projects_bp.route('/projects/<int:project_id>', methods=['GET'])
@jwt_required
@module_required('projects')
def get_project_detail(project_id):
    """
    获取项目详情，聚合返回关联资源
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 查询项目基本信息
        cursor.execute("SELECT * FROM projects WHERE id = %s", (project_id,))
        project = cursor.fetchone()
        if not project:
            return jsonify({
                'code': 404,
                'message': '项目不存在'
            }), 404

        # 查询关联的服务器列表
        cursor.execute(
            """
            SELECT s.id, s.hostname, s.inner_ip, s.env_type
            FROM servers s
            INNER JOIN project_servers ps ON s.id = ps.server_id
            WHERE ps.project_id = %s
            ORDER BY s.env_type, s.hostname
            """,
            (project_id,)
        )
        servers = cursor.fetchall()

        # 查询关联的服务列表
        cursor.execute(
            """
            SELECT s.id, s.service_name, s.category, s.server_id,
                   srv.hostname AS server_hostname,
                   s.version, s.inner_port, s.mapped_port
            FROM services s
            LEFT JOIN servers srv ON s.server_id = srv.id
            WHERE s.project_id = %s
            ORDER BY s.service_name
            """,
            (project_id,)
        )
        services = cursor.fetchall()

        # 查询关联的域名列表
        cursor.execute(
            """
            SELECT id, domain_name AS domain, expire_date, status
            FROM domains
            WHERE project_id = %s
            ORDER BY domain_name
            """,
            (project_id,)
        )
        domains = cursor.fetchall()

        # 查询关联的证书列表
        cursor.execute(
            """
            SELECT c.id, c.domain, c.cert_expire_time AS expire_date,
                   c.remaining_days AS days_remaining,
                   p.project_name
            FROM ssl_certificates c
            LEFT JOIN projects p ON c.project_id = p.id
            WHERE c.project_id = %s
            ORDER BY c.cert_expire_time ASC
            """,
            (project_id,)
        )
        certificates = cursor.fetchall()

        # 查询关联的账号列表
        cursor.execute(
            """
            SELECT id, name, company AS unit, access_url, username, password
            FROM accounts
            WHERE project_id = %s
            ORDER BY name
            """,
            (project_id,)
        )
        accounts = cursor.fetchall()
        
        # 解密密码字段
        for account in accounts:
            if account.get('password'):
                try:
                    account['password'] = decrypt_data(account['password'])
                except:
                    pass
        
        return jsonify({
            'code': 200,
            'data': {
                'project': project,
                'servers': servers,
                'services': services,
                'domains': domains,
                'certs': certificates,
                'accounts': accounts
            }
        })
    finally:
        cursor.close()


@projects_bp.route('/projects/<int:project_id>', methods=['PUT'])
@jwt_required
@module_required('projects')
@role_required(['admin', 'operator'])
def update_project(project_id):
    """
    更新项目信息
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.get_json(silent=True) or {}
        if not data:
            return jsonify({"code": 400, "message": "请求体不能为空"}), 400

        # 检查项目是否存在
        cursor.execute("SELECT project_name FROM projects WHERE id = %s", (project_id,))
        existing = cursor.fetchone()
        if not existing:
            return jsonify({
                'code': 404,
                'message': '项目不存在'
            }), 404

        # 如果更新项目名称，检查是否与其他项目冲突
        if 'project_name' in data:
            new_name = data['project_name'].strip()
            if not new_name:
                return jsonify({"code": 400, "message": "项目名称不能为空"}), 400
            cursor.execute(
                "SELECT id FROM projects WHERE project_name = %s AND id != %s",
                (new_name, project_id)
            )
            if cursor.fetchone():
                return jsonify({"code": 400, "message": "项目名称已存在"}), 400

        # 构建更新字段
        fields = []
        values = []
        allowed_fields = ['project_name', 'description', 'owner', 'status', 'remark']

        for key in allowed_fields:
            if key in data:
                fields.append(f"`{key}` = %s")
                value = data[key]
                if isinstance(value, str):
                    value = value.strip()
                values.append(value if value else None)

        if fields:
            values.append(project_id)
            cursor.execute(
                f"UPDATE projects SET {', '.join(fields)} WHERE id = %s",
                values
            )
            db.commit()

            # 记录操作日志
            log_operation(
                module='项目管理',
                action='update',
                target_id=project_id,
                target_name=data.get('project_name') or existing['project_name']
            )

        return jsonify({
            'code': 200,
            'message': '更新成功'
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'更新失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@projects_bp.route('/projects/<int:project_id>', methods=['DELETE'])
@jwt_required
@module_required('projects')
@role_required(['admin', 'operator'])
def delete_project(project_id):
    """
    删除项目（同时删除关联的 project_servers 记录）
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 先获取项目信息用于日志
        cursor.execute("SELECT project_name FROM projects WHERE id = %s", (project_id,))
        project = cursor.fetchone()
        if not project:
            return jsonify({
                'code': 404,
                'message': '项目不存在'
            }), 404
        project_name = project['project_name']

        # 删除项目（关联的 project_servers 会通过外级联删除）
        cursor.execute("DELETE FROM projects WHERE id = %s", (project_id,))
        db.commit()

        # 记录操作日志
        log_operation(
            module='项目管理',
            action='delete',
            target_id=project_id,
            target_name=project_name
        )

        return jsonify({
            'code': 200,
            'message': '删除成功'
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'删除失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@projects_bp.route('/projects/<int:project_id>/servers', methods=['POST'])
@jwt_required
@module_required('projects')
@role_required(['admin', 'operator'])
def add_project_servers(project_id):
    """
    关联服务器到项目
    接收JSON body: { server_ids: [1, 2, 3] }
    """
    db = get_db()
    cursor = db.cursor()
    try:
        data = request.get_json(silent=True) or {}
        server_ids = data.get('server_ids', [])

        if not isinstance(server_ids, list) or not server_ids:
            return jsonify({
                'code': 400,
                'message': 'server_ids 必须是包含服务器ID的数组'
            }), 400

        # 检查项目是否存在
        cursor.execute("SELECT project_name FROM projects WHERE id = %s", (project_id,))
        project = cursor.fetchone()
        if not project:
            return jsonify({
                'code': 404,
                'message': '项目不存在'
            }), 404

        # 过滤掉不存在的服务器ID
        placeholders = ','.join(['%s'] * len(server_ids))
        cursor.execute(
            f"SELECT id FROM servers WHERE id IN ({placeholders})",
            tuple(server_ids)
        )
        existing_ids = {row['id'] for row in cursor.fetchall()}

        valid_ids = [sid for sid in server_ids if sid in existing_ids]
        if not valid_ids:
            return jsonify({
                'code': 400,
                'message': '没有有效的服务器ID'
            }), 400

        # 批量插入关联关系（忽略重复）
        added_count = 0
        for server_id in valid_ids:
            try:
                cursor.execute(
                    "INSERT IGNORE INTO project_servers (project_id, server_id) VALUES (%s, %s)",
                    (project_id, server_id)
                )
                if cursor.rowcount > 0:
                    added_count += 1
            except Exception:
                pass  # 忽略插入错误

        db.commit()

        # 记录操作日志
        log_operation(
            module='项目管理',
            action='update',
            target_id=project_id,
            target_name=project['project_name'],
            detail={'action': '关联服务器', 'server_ids': valid_ids, 'added_count': added_count}
        )

        return jsonify({
            'code': 200,
            'message': f'成功关联 {added_count} 台服务器',
            'data': {'added_count': added_count}
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'关联服务器失败: {str(e)}'
        }), 500
    finally:
        cursor.close()


@projects_bp.route('/projects/<int:project_id>/servers/<int:server_id>', methods=['DELETE'])
@jwt_required
@module_required('projects')
@role_required(['admin', 'operator'])
def remove_project_server(project_id, server_id):
    """
    取消关联单个服务器
    """
    db = get_db()
    cursor = db.cursor()
    try:
        # 检查项目是否存在
        cursor.execute("SELECT project_name FROM projects WHERE id = %s", (project_id,))
        project = cursor.fetchone()
        if not project:
            return jsonify({
                'code': 404,
                'message': '项目不存在'
            }), 404

        # 删除关联关系
        cursor.execute(
            "DELETE FROM project_servers WHERE project_id = %s AND server_id = %s",
            (project_id, server_id)
        )
        db.commit()

        if cursor.rowcount == 0:
            return jsonify({
                'code': 404,
                'message': '该服务器未关联到此项目'
            }), 404

        # 记录操作日志
        log_operation(
            module='项目管理',
            action='update',
            target_id=project_id,
            target_name=project['project_name'],
            detail={'action': '取消关联服务器', 'server_id': server_id}
        )

        return jsonify({
            'code': 200,
            'message': '取消关联成功'
        })
    except Exception as e:
        db.rollback()
        return jsonify({
            'code': 500,
            'message': f'取消关联失败: {str(e)}'
        }), 500
    finally:
        cursor.close()
