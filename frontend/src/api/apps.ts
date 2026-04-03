import request from './request'

export function getApps(params: Record<string, any>) {
  return request.get('/apps', { params })
}

export function createApp(data: Record<string, any>) {
  return request.post('/apps', data)
}

export function updateApp(id: number | string, data: Record<string, any>) {
  return request.put(`/apps/${id}`, data)
}

export function deleteApp(id: number | string) {
  return request.delete(`/apps/${id}`)
}
