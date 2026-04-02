import request from './request'

export function getDomains(params) {
  return request.get('/domains', { params })
}

export function createDomain(data) {
  return request.post('/domains', data)
}

export function updateDomain(id, data) {
  return request.put(`/domains/${id}`, data)
}

export function deleteDomain(id) {
  return request.delete(`/domains/${id}`)
}

export function syncAliyunDomains(accountId) {
  return request.post('/domains/sync-aliyun', { account_id: accountId })
}

export function notifyDomains() {
  return request.post('/domains/notify')
}
