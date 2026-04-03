import request from './request'

export function getAliyunAccounts() {
  return request.get('/aliyun-accounts')
}

export function createAliyunAccount(data: Record<string, any>) {
  return request.post('/aliyun-accounts', data)
}

export function updateAliyunAccount(id: number | string, data: Record<string, any>) {
  return request.put(`/aliyun-accounts/${id}`, data)
}

export function deleteAliyunAccount(id: number | string) {
  return request.delete(`/aliyun-accounts/${id}`)
}
