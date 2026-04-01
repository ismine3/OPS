import request from './request'

export function getApps(params) {
  return request.get('/apps', { params })
}

export function createApp(data) {
  return request.post('/apps', data)
}

export function updateApp(id, data) {
  return request.put(`/apps/${id}`, data)
}

export function deleteApp(id) {
  return request.delete(`/apps/${id}`)
}
