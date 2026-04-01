import request from './request'

export function login(data) {
  return request.post('/auth/login', data)
}

export function getProfile() {
  return request.get('/auth/profile')
}

export function changePassword(data) {
  return request.put('/auth/password', data)
}
