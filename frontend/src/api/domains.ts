import request from './request'

export function getDomains(params: Record<string, any>) {
  return request.get('/domains', { params })
}

export function createDomain(data: Record<string, any>) {
  return request.post('/domains', data)
}

export function updateDomain(id: number | string, data: Record<string, any>) {
  return request.put(`/domains/${id}`, data)
}

export function deleteDomain(id: number | string) {
  return request.delete(`/domains/${id}`)
}

export function syncAliyunDomains(accountId: number | string) {
  return request.post('/domains/sync-aliyun', { account_id: accountId })
}

export function notifyDomains() {
  return request.post('/domains/notify')
}
