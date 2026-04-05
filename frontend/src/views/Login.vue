<template>
  <div class="login-container">
    <div class="login-bg"></div>
    <div class="login-card">
      <div class="login-header">
        <el-icon :size="40" color="#409EFF"><Monitor /></el-icon>
        <h2>运维管理平台</h2>
        <p class="subtitle">Operations Management Platform</p>
      </div>
      <el-form ref="formRef" :model="form" :rules="rules" @keyup.enter="handleLogin" size="large">
        <el-form-item prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" :prefix-icon="User" />
        </el-form-item>
        <el-form-item prop="password">
          <el-input v-model="form.password" type="password" placeholder="请输入密码" :prefix-icon="Lock" show-password />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" :loading="loading" @click="handleLogin" style="width: 100%">
            登 录
          </el-button>
        </el-form-item>
      </el-form>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, type FormInstance, type FormRules } from 'element-plus'
import { User, Lock } from '@element-plus/icons-vue'
import { login } from '../api/auth'
import { useUserStore } from '../stores/user'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength } from '@/utils/validators'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref<FormInstance | null>(null)
const loading = ref<boolean>(false)

interface LoginForm {
  username: string
  password: string
}

const form = reactive<LoginForm>({
  username: '',
  password: ''
})

const rules: FormRules<LoginForm> = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { validator: maxLength(128), trigger: 'blur' }
  ]
}

async function handleLogin() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  loading.value = true
  try {
    const res = await login(form)
    userStore.setToken(res.data.token)
    userStore.setUserInfo(res.data.user)
    ElMessage.success('登录成功')
    router.push('/dashboard')
  } catch (e) {
    console.error('登录失败', e)
  } finally {
    loading.value = false
  }
}
</script>

<style scoped>
.login-container {
  width: 100vw;
  height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  /* 多层渐变叠加模拟流动色彩 */
  background:
    radial-gradient(ellipse at 10% 90%, rgba(131, 58, 180, 0.8) 0%, transparent 50%),
    radial-gradient(ellipse at 90% 20%, rgba(253, 164, 29, 0.7) 0%, transparent 50%),
    radial-gradient(ellipse at 50% 50%, rgba(252, 70, 107, 0.6) 0%, transparent 60%),
    radial-gradient(ellipse at 20% 30%, rgba(43, 210, 193, 0.7) 0%, transparent 50%),
    radial-gradient(ellipse at 80% 80%, rgba(59, 130, 246, 0.7) 0%, transparent 50%),
    linear-gradient(135deg, #667eea 0%, #f093fb 25%, #f5576c 50%, #4facfe 75%, #43e97b 100%);
  background-size: 200% 200%;
  animation: gradientShift 15s ease infinite;
}

@keyframes gradientShift {
  0% { background-position: 0% 50%; }
  50% { background-position: 100% 50%; }
  100% { background-position: 0% 50%; }
}

.login-bg {
  display: none;
}

.login-card {
  width: 420px;
  padding: 40px;
  background: rgba(255, 255, 255, 0.2);
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(20px);
  -webkit-backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  position: relative;
  z-index: 1;
}

.login-header {
  text-align: center;
  margin-bottom: 36px;
}

.login-header h2 {
  margin: 12px 0 4px;
  color: #fff;
  font-size: 24px;
  text-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
}

.subtitle {
  color: rgba(255, 255, 255, 0.85);
  font-size: 13px;
  text-shadow: 0 1px 4px rgba(0, 0, 0, 0.1);
}

/* 登录卡片内输入框毛玻璃适配 */
.login-card :deep(.el-input__wrapper) {
  background: rgba(255, 255, 255, 0.6) !important;
  border: 1px solid rgba(255, 255, 255, 0.5) !important;
  box-shadow: none !important;
  border-radius: 8px !important;
  transition: all 0.3s ease;
}

.login-card :deep(.el-input__wrapper:hover) {
  background: rgba(255, 255, 255, 0.75) !important;
  border-color: rgba(255, 255, 255, 0.7) !important;
}

.login-card :deep(.el-input__wrapper.is-focus) {
  background: rgba(255, 255, 255, 0.8) !important;
  border-color: rgba(64, 158, 255, 0.6) !important;
  box-shadow: 0 0 0 2px rgba(64, 158, 255, 0.15) !important;
}

.login-card :deep(.el-input__inner) {
  color: #303133;
  font-size: 14px;
}

.login-card :deep(.el-input__inner::placeholder) {
  color: rgba(100, 100, 120, 0.6);
}

/* 输入框前缀图标颜色适配 */
.login-card :deep(.el-input__prefix) {
  color: rgba(48, 49, 51, 0.6);
}

.login-card :deep(.el-input__prefix .el-icon) {
  color: rgba(48, 49, 51, 0.6);
}

/* 密码可见切换图标 */
.login-card :deep(.el-input__suffix) {
  color: rgba(48, 49, 51, 0.6);
}

.login-card :deep(.el-input__suffix .el-icon) {
  color: rgba(48, 49, 51, 0.6);
}

.login-card :deep(.el-input__suffix .el-icon:hover) {
  color: #409EFF;
}

/* 登录按钮样式 */
.login-card :deep(.el-button--primary) {
  width: 100%;
  height: 44px;
  border-radius: 8px;
  font-size: 16px;
  font-weight: 500;
  background: #3b82f6;
  border: none;
  transition: all 0.3s ease;
}

.login-card :deep(.el-button--primary:hover) {
  background: #2563eb;
}

.login-card :deep(.el-button--primary:active) {
  background: #1d4ed8;
}
</style>
