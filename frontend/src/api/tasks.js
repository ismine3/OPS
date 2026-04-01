import request from './request'

export function getTasks(params) {
  return request.get('/tasks', { params })
}

export function createTask(data) {
  return request.post('/tasks', data, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function updateTask(id, data) {
  return request.put(`/tasks/${id}`, data, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

export function deleteTask(id) {
  return request.delete(`/tasks/${id}`)
}

export function toggleTask(id) {
  return request.post(`/tasks/${id}/toggle`)
}

export function runTask(id) {
  return request.post(`/tasks/${id}/run`)
}

export function getTaskLogs(id, params) {
  return request.get(`/tasks/${id}/logs`, { params })
}
