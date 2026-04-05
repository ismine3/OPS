import request from './request'

export function getAliyunAccounts() {
  return request.get('/credentials')
}

export function createAliyunAccount(data: Record<string, any>) {
  return request.post('/credentials', data)
}

export function updateAliyunAccount(id: number | string, data: Record<string, any>) {
  return request.put(`/credentials/${id}`, data)
}

export function deleteAliyunAccount(id: number | string) {
  return request.delete(`/credentials/${id}`)
}
