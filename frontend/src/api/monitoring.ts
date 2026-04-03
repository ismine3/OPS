import request from './request'

export function getMonitoringConfig() {
  return request.get('/monitoring/config')
}
