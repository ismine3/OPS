import request from './request'

export function getAliyunAccounts() {
  return request.get('/aliyun-accounts')
}

export function createAliyunAccount(data) {
  return request.post('/aliyun-accounts', data)
}

export function updateAliyunAccount(id, data) {
  return request.put(`/aliyun-accounts/${id}`, data)
}

export function deleteAliyunAccount(id) {
  return request.delete(`/aliyun-accounts/${id}`)
}
