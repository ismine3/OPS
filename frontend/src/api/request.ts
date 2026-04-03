import axios from 'axios'
import type { AxiosResponse, InternalAxiosRequestConfig } from 'axios'
import { ElMessage } from 'element-plus'
import router from '../router'

const request = axios.create({
  baseURL: '/api',
  timeout: 15000,
  headers: {
    'Content-Type': 'application/json'
  }
})

request.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    const token = localStorage.getItem('token')
    if (token) {
      config.headers.Authorization = `Bearer ${token}`
    }
    return config
  },
  (error: any) => Promise.reject(error)
)

request.interceptors.response.use(
  (response: AxiosResponse) => {
    if (response.config.responseType === 'blob') {
      const ct = (response.headers['content-type'] || '').toLowerCase()
      if (ct.includes('application/json')) {
        return Promise.reject(new Error('导出失败：服务器返回了错误信息'))
      }
      return response.data
    }
    const res = response.data
    if (
      res &&
      typeof res === 'object' &&
      Object.prototype.hasOwnProperty.call(res, 'code') &&
      Number(res.code) !== 200
    ) {
      ElMessage.error(res.message || '请求失败')
      return Promise.reject(new Error(res.message || '请求失败'))
    }
    return res
  },
  (error: any) => {
    if (error.response) {
      const { status, data } = error.response
      const config = error.response.config || error.config
      if (status === 401) {
        // 登录请求的 401 是密码错误，显示后端返回的信息
        if (config && config.url && config.url.includes('/auth/login')) {
          ElMessage.error(data?.message || '登录失败')
        } else {
          // 其他请求的 401 是 Token 过期
          localStorage.removeItem('token')
          localStorage.removeItem('userInfo')
          router.push('/login')
          ElMessage.error('登录已过期，请重新登录')
        }
      } else {
        ElMessage.error(data?.message || `请求失败(${status})`)
      }
    } else {
      ElMessage.error('网络连接失败')
    }
    return Promise.reject(error)
  }
)

export default request
