import request from './request'

export function getApps(params: Record<string, any>) {
  return request.get('/accounts', { params })
}

export function createApp(data: Record<string, any>) {
  return request.post('/accounts', data)
}

export function updateApp(id: number | string, data: Record<string, any>) {
  return request.put(`/accounts/${id}`, data)
}

export function deleteApp(id: number | string) {
  return request.delete(`/accounts/${id}`)
}
