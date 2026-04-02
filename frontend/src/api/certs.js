import request from './request'

// 获取证书列表
export function getCerts(params) {
  return request.get('/certs', { params })
}

// 创建证书
export function createCert(data) {
  return request.post('/certs', data)
}

// 上传证书文件并自动解析创建证书记录
export function uploadAndCreateCert(formData) {
  return request.post('/certs/upload', formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

// 更新证书
export function updateCert(id, data) {
  return request.put(`/certs/${id}`, data)
}

// 删除证书
export function deleteCert(id) {
  return request.delete(`/certs/${id}`)
}

// SSL在线检测（批量）
export function checkCerts(ids) {
  return request.post('/certs/check', { ids })
}

// SSL在线检测（单个）
export function checkCert(id) {
  return request.post(`/certs/check/${id}`)
}

// 从阿里云同步证书
export function syncAliyunCerts(accountId) {
  return request.post('/certs/sync-aliyun', { account_id: accountId })
}

// 手动触发微信预警通知
export function notifyCerts() {
  return request.post('/certs/notify')
}

// 上传证书文件
export function uploadCertFiles(id, formData) {
  return request.post(`/certs/${id}/upload`, formData, {
    headers: { 'Content-Type': 'multipart/form-data' }
  })
}

// 下载证书文件
export function downloadCertFiles(id) {
  return request.get(`/certs/${id}/download`, { responseType: 'blob' })
}

// 删除证书文件
export function deleteCertFiles(id) {
  return request.delete(`/certs/${id}/files`)
}

// 远程部署证书
export function deployCert(id, data) {
  return request.post(`/certs/${id}/deploy`, data)
}
