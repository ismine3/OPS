import request from './request'

// 获取操作日志列表
export function getOperationLogs(params: Record<string, any>) {
  return request.get('/operation-logs', { params })
}

// 获取所有操作模块
export function getOperationModules() {
  return request.get('/operation-logs/modules')
}

// 获取所有操作类型
export function getOperationActions() {
  return request.get('/operation-logs/actions')
}
