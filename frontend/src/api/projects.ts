import request from './request'

export function getProjects(params: Record<string, any>) {
  return request.get('/projects', { params })
}

export function getProjectOptions() {
  return request.get('/projects/options')
}

export function getProjectDetail(id: number | string) {
  return request.get(`/projects/${id}`)
}

export function createProject(data: Record<string, any>) {
  return request.post('/projects', data)
}

export function updateProject(id: number | string, data: Record<string, any>) {
  return request.put(`/projects/${id}`, data)
}

export function deleteProject(id: number | string) {
  return request.delete(`/projects/${id}`)
}

export function bindProjectServers(projectId: number | string, serverIds: number[]) {
  return request.post(`/projects/${projectId}/servers`, { server_ids: serverIds })
}

export function unbindProjectServer(projectId: number | string, serverId: number | string) {
  return request.delete(`/projects/${projectId}/servers/${serverId}`)
}
