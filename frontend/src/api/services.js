import request from './request'

export function getServices(params) {
  return request.get('/services', { params })
}

export function createService(data) {
  return request.post('/services', data)
}

export function updateService(id, data) {
  return request.put(`/services/${id}`, data)
}

export function deleteService(id) {
  return request.delete(`/services/${id}`)
}
