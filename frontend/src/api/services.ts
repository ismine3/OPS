import request from './request'

export function getServices(params: Record<string, any>) {
  return request.get('/services', { params })
}

export function createService(data: Record<string, any>) {
  return request.post('/services', data)
}

export function updateService(id: number | string, data: Record<string, any>) {
  return request.put(`/services/${id}`, data)
}

export function deleteService(id: number | string) {
  return request.delete(`/services/${id}`)
}
