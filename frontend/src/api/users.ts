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
