import request from './request'

export function getCerts(params) {
  return request.get('/certs', { params })
}

export function createCert(data) {
  return request.post('/certs', data)
}

export function updateCert(id, data) {
  return request.put(`/certs/${id}`, data)
}

export function deleteCert(id) {
  return request.delete(`/certs/${id}`)
}
