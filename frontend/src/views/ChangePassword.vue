<template>
  <div class="page-container">
    <el-card class="password-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span>修改密码</span>
        </div>
      </template>
      
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
        class="password-form"
      >
        <el-form-item label="旧密码" prop="old_password">
          <el-input
            v-model="form.old_password"
            type="password"
            show-password
            placeholder="请输入旧密码"
          />
        </el-form-item>
        <el-form-item label="新密码" prop="new_password">
          <el-input
            v-model="form.new_password"
            type="password"
            show-password
            placeholder="请输入新密码（最少6位）"
          />
        </el-form-item>
        <el-form-item label="确认密码" prop="confirm_password">
          <el-input
            v-model="form.confirm_password"
            type="password"
            show-password
            placeholder="请再次输入新密码"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSubmit" :loading="submitLoading">
            提交
          </el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage } from 'element-plus'
import type { FormItemRule, FormInstance } from 'element-plus'
import { changePassword } from '../api/auth'
import { useUserStore } from '../stores/user'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { maxLength, passwordStrength } from '@/utils/validators'

const router = useRouter()
const userStore = useUserStore()
const formRef = ref<FormInstance | null>(null)
const submitLoading = ref(false)

const form = reactive({
  old_password: '',
  new_password: '',
  confirm_password: ''
})

const validateConfirmPassword = (_rule: FormItemRule, value: string, callback: (error?: Error) => void) => {
  if (value === '') {
    callback(new Error('请再次输入新密码'))
  } else if (value !== form.new_password) {
    callback(new Error('两次输入的密码不一致'))
  } else {
    callback()
  }
}

const rules = {
  old_password: [
    { required: true, message: '请输入旧密码', trigger: 'blur' },
    { validator: maxLength(128), trigger: 'blur' }
  ],
  new_password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { validator: passwordStrength, trigger: 'blur' }
  ],
  confirm_password: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: validateConfirmPassword, trigger: 'blur' }
  ]
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitLoading.value = true
  try {
    await changePassword({
      old_password: form.old_password,
      new_password: form.new_password
    })
    ElMessage.success('密码修改成功，请重新登录')
    userStore.logout()
    router.push('/login')
  } catch (e) {
    console.error('修改密码失败', e)
  } finally {
    submitLoading.value = false
  }
}

function handleReset() {
  formRef.value?.resetFields()
}
</script>

<style scoped>
.page-container {
  padding: 20px;
  display: flex;
  justify-content: center;
}

.password-card {
  width: 100%;
  max-width: 500px;
}

.card-header {
  font-size: 16px;
  font-weight: 600;
}

.password-form {
  padding: 20px 10px 10px;
}
</style>
