import request from './request'

export function getServers(params) {
  return request.get('/servers', { params })
}

export function getServerDetail(id) {
  return request.get(`/servers/${id}`)
}

export function getServerList() {
  return request.get('/servers/list')
}

export function createServer(data) {
  return request.post('/servers', data)
}

export function updateServer(id, data) {
  return request.put(`/servers/${id}`, data)
}

export function deleteServer(id) {
  return request.delete(`/servers/${id}`)
}
