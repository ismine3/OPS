import request from './request'

export function getTasks(params: Record<string, any>) {
  return request.get('/tasks', { params })
}

export function createTask(data: Record<string, any>) {
  return request.post('/tasks', data, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function updateTask(id: number | string, data: Record<string, any>) {
  return request.put(`/tasks/${id}`, data, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function deleteTask(id: number | string) {
  return request.delete(`/tasks/${id}`)
}

export function toggleTask(id: number | string) {
  return request.post(`/tasks/${id}/toggle`)
}

export function runTask(id: number | string) {
  return request.post(`/tasks/${id}/run`)
}

export function getTaskLogs(id: number | string, params: Record<string, any>) {
  return request.get(`/tasks/${id}/logs`, { params })
}
