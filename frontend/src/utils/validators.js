/**
 * 前端统一验证工具库
 * 提供纯函数和 Element Plus validator 两种形式
 */

// ==================== 安全类验证器 ====================

/**
 * SQL注入防护 - 纯函数
 * 检测 SQL 关键字和危险字符
 */
export const isSafeInput = (value) => {
  if (!value || typeof value !== 'string') return true
  const sqlPatterns = /\b(union|select|drop|delete|insert|update)\b|--|;|'|"/i
  return !sqlPatterns.test(value)
}

/**
 * SQL注入防护 - Element Plus validator
 */
export const sanitizeInput = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isSafeInput(value)) {
    callback(new Error('输入包含不允许的SQL关键字或特殊字符'))
  } else {
    callback()
  }
}

/**
 * XSS防护 - 纯函数
 * 检测危险HTML/JS模式
 */
export const isSafeHTML = (value) => {
  if (!value || typeof value !== 'string') return true
  const xssPatterns = /<script|<\/script>|<iframe|javascript:|onerror\s*=|onclick\s*=|onload\s*=/i
  return !xssPatterns.test(value)
}

/**
 * XSS防护 - Element Plus validator
 */
export const sanitizeHTML = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isSafeHTML(value)) {
    callback(new Error('输入包含不允许的HTML或脚本代码'))
  } else {
    callback()
  }
}

/**
 * 通用安全文本验证 - 纯函数（SQL注入 + XSS防护）
 */
export const isSafeText = (value) => {
  return isSafeInput(value) && isSafeHTML(value)
}

/**
 * 通用安全文本验证 - Element Plus validator
 */
export const safeText = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isSafeInput(value)) {
    callback(new Error('输入包含不允许的SQL关键字或特殊字符'))
  } else if (!isSafeHTML(value)) {
    callback(new Error('输入包含不允许的HTML或脚本代码'))
  } else {
    callback()
  }
}

// ==================== 格式类验证器 ====================

/**
 * IPv4地址验证 - 纯函数
 */
export const isValidIP = (value) => {
  if (!value) return true
  const ipPattern = /^(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})$/
  const match = value.match(ipPattern)
  if (!match) return false
  return match.slice(1, 5).every(seg => parseInt(seg, 10) >= 0 && parseInt(seg, 10) <= 255)
}

/**
 * IPv4地址验证 - Element Plus validator
 */
export const ipValidator = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isValidIP(value)) {
    callback(new Error('请输入有效的IP地址'))
  } else {
    callback()
  }
}

/**
 * 端口号验证 - 纯函数
 * 支持 1-65535，支持逗号分隔的多端口
 */
export const isValidPort = (value) => {
  if (!value) return true
  const ports = value.toString().split(',')
  const portPattern = /^\d+$/
  return ports.every(p => {
    const trimmed = p.trim()
    if (!portPattern.test(trimmed)) return false
    const num = parseInt(trimmed, 10)
    return num >= 1 && num <= 65535
  })
}

/**
 * 端口号验证 - Element Plus validator
 */
export const portValidator = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isValidPort(value)) {
    callback(new Error('请输入有效的端口号（1-65535），多个端口用逗号分隔'))
  } else {
    callback()
  }
}

/**
 * 域名验证 - 纯函数
 * 支持通配符域名（*.example.com）
 */
export const isValidDomain = (value) => {
  if (!value) return true
  // 支持通配符域名
  const domainPattern = /^(\*\.)?([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$/
  return domainPattern.test(value)
}

/**
 * 域名验证 - Element Plus validator
 */
export const domainValidator = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isValidDomain(value)) {
    callback(new Error('请输入有效的域名，支持通配符格式如 *.example.com'))
  } else {
    callback()
  }
}

/**
 * URL验证 - 纯函数
 * 支持 http/https
 */
export const isValidURL = (value) => {
  if (!value) return true
  try {
    const url = new URL(value)
    return ['http:', 'https:'].includes(url.protocol)
  } catch {
    return false
  }
}

/**
 * URL验证 - Element Plus validator
 */
export const urlValidator = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isValidURL(value)) {
    callback(new Error('请输入有效的URL地址（http或https）'))
  } else {
    callback()
  }
}

/**
 * Cron表达式验证 - 纯函数
 * 5段格式：分 时 日 月 周
 */
export const isValidCron = (value) => {
  if (!value) return true
  const parts = value.trim().split(/\s+/)
  if (parts.length !== 5) return false

  // 每段的有效字符
  const validPattern = /^(\*|(\d{1,2}(-\d{1,2})?(,\d{1,2}(-\d{1,2})?)*)(\/\d+)?|\*\/\d+)$/

  // 分钟: 0-59
  if (!validPattern.test(parts[0])) return false
  // 小时: 0-23
  if (!validPattern.test(parts[1])) return false
  // 日: 1-31
  if (!validPattern.test(parts[2])) return false
  // 月: 1-12
  if (!validPattern.test(parts[3])) return false
  // 周: 0-6 (0是周日)
  if (!validPattern.test(parts[4])) return false

  return true
}

/**
 * Cron表达式验证 - Element Plus validator
 */
export const cronValidator = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isValidCron(value)) {
    callback(new Error('请输入有效的Cron表达式（5段格式：分 时 日 月 周）'))
  } else {
    callback()
  }
}

/**
 * Unix/Linux路径验证 - 纯函数
 * 以 / 开头
 */
export const isValidPath = (value) => {
  if (!value) return true
  return /^\/[^\s]*$/.test(value)
}

/**
 * Unix/Linux路径验证 - Element Plus validator
 */
export const pathValidator = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isValidPath(value)) {
    callback(new Error('请输入有效的Unix/Linux路径（以/开头）'))
  } else {
    callback()
  }
}

// ==================== 逻辑类验证器 ====================

/**
 * 长度限制验证器工厂函数
 * @param {number} n 最大长度
 * @returns {Function} Element Plus validator
 */
export const maxLength = (n) => (rule, value, callback) => {
  if (!value) { callback(); return }
  if (value.length > n) {
    callback(new Error(`长度不能超过${n}个字符`))
  } else {
    callback()
  }
}

/**
 * 密码强度验证 - 纯函数
 * 至少6位，包含字母和数字
 */
export const isStrongPassword = (value) => {
  if (!value) return true
  if (value.length < 6) return false
  const hasLetter = /[a-zA-Z]/.test(value)
  const hasNumber = /\d/.test(value)
  return hasLetter && hasNumber
}

/**
 * 密码强度验证 - Element Plus validator
 */
export const passwordStrength = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (value.length < 6) {
    callback(new Error('密码长度至少6位'))
  } else if (!/[a-zA-Z]/.test(value)) {
    callback(new Error('密码必须包含字母'))
  } else if (!/\d/.test(value)) {
    callback(new Error('密码必须包含数字'))
  } else {
    callback()
  }
}

/**
 * 端口范围验证 - 纯函数
 * 验证单个端口是否在指定范围内
 */
export const isValidPortRange = (value, min = 1, max = 65535) => {
  if (!value) return true
  const port = parseInt(value, 10)
  return !isNaN(port) && port >= min && port <= max
}

/**
 * 端口范围验证 - Element Plus validator
 * 可指定范围
 */
export const validatePortRange = (min = 1, max = 65535) => (rule, value, callback) => {
  if (!value) { callback(); return }
  const port = parseInt(value, 10)
  if (isNaN(port) || port < min || port > max) {
    callback(new Error(`端口号必须在${min}-${max}之间`))
  } else {
    callback()
  }
}

// ==================== 搜索专用验证器 ====================

/**
 * 搜索框安全验证 - 纯函数
 * 允许空值，非空时做安全检查
 */
export const isSafeSearch = (value) => {
  if (!value) return true
  return isSafeText(value)
}

/**
 * 搜索框安全验证 - Element Plus validator
 */
export const searchValidator = (rule, value, callback) => {
  if (!value) { callback(); return }
  if (!isSafeInput(value)) {
    callback(new Error('搜索内容包含非法字符'))
  } else if (!isSafeHTML(value)) {
    callback(new Error('搜索内容包含非法字符'))
  } else {
    callback()
  }
}
