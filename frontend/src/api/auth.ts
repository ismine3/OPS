import request from './request'

export function login(data: Record<string, any>) {
  return request.post('/auth/login', data)
}

export function getProfile() {
  return request.get('/auth/profile')
}

export function changePassword(data: Record<string, any>) {
  return request.put('/auth/password', data)
}
