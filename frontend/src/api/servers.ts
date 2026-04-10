import request from './request'

export function getServers(params: Record<string, any>) {
  return request.get('/servers', { params })
}

export function getServerOptions() {
  return request.get('/servers/options')
}

export function getServerDetail(id: number | string) {
  return request.get(`/servers/${id}`)
}

export function getServerList() {
  return request.get('/servers/list')
}

export function createServer(data: Record<string, any>) {
  return request.post('/servers', data)
}

export function updateServer(id: number | string, data: Record<string, any>) {
  return request.put(`/servers/${id}`, data)
}

export function deleteServer(id: number | string) {
  return request.delete(`/servers/${id}`)
}
