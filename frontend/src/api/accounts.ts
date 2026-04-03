import request from './request'

export function getAccounts(params: Record<string, any>) {
  return request.get('/accounts', { params })
}

export function createAccount(data: Record<string, any>) {
  return request.post('/accounts', data)
}

export function updateAccount(id: number | string, data: Record<string, any>) {
  return request.put(`/accounts/${id}`, data)
}

export function deleteAccount(id: number | string) {
  return request.delete(`/accounts/${id}`)
}
