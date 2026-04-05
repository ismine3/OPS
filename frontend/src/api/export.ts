import request from './request'

export function exportExcel() {
  return request.get('/export/excel', {
    responseType: 'blob'
  })
}
