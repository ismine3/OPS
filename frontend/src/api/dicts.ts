import request from './request'

export function getEnvTypes() {
  return request({
    url: '/dicts/env-types',
    method: 'get'
  })
}

export function getPlatforms() {
  return request({
    url: '/dicts/platforms',
    method: 'get'
  })
}

export function getServiceCategories() {
  return request({
    url: '/dicts/service-categories',
    method: 'get'
  })
}
