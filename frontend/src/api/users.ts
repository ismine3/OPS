import request from './request'

export function getUsers(params: Record<string, any>) {
  return request.get('/users', { params })
}

export function createUser(data: Record<string, any>) {
  return request.post('/users', data)
}

export function updateUser(id: number | string, data: Record<string, any>) {
  return request.put(`/users/${id}`, data)
}

export function deleteUser(id: number | string) {
  return request.delete(`/users/${id}`)
}

export function resetPassword(id: number | string, data: Record<string, any>) {
  return request.put(`/users/${id}/reset-password`, data)
}

// 获取所有角色的模块授权配置
export function getRoleModules() {
  return request.get('/role-modules')
}

// 获取指定角色的模块授权
export function getRoleModulesByRole(role: string) {
  return request.get(`/role-modules/${role}`)
}

// 更新指定角色的模块授权
export function updateRoleModules(role: string, modules: string[]) {
  return request.put(`/role-modules/${role}`, { modules })
}
