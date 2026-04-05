<template>
  <span v-if="password" class="password-display">
    <span class="password-text" @click="toggleShow">
      {{ showPlain ? password : '••••••' }}
    </span>
    <el-icon class="copy-icon" @click="copyPassword" title="复制"><CopyDocument /></el-icon>
  </span>
  <span v-else class="empty-text">-</span>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { CopyDocument } from '@element-plus/icons-vue'

const props = defineProps({
  password: {
    type: String,
    default: ''
  }
})

const showPlain = ref<boolean>(false)

function toggleShow() {
  showPlain.value = !showPlain.value
}

function copyPassword() {
  if (!props.password) return
  navigator.clipboard.writeText(props.password).then(() => {
    ElMessage.success('密码已复制')
  }).catch(() => {
    // 降级方案
    const textarea = document.createElement('textarea')
    textarea.value = props.password
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    ElMessage.success('密码已复制')
  })
}
</script>

<style scoped>
.password-display {
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.password-text {
  font-family: monospace;
  cursor: pointer;
  user-select: none;
  padding: 2px 8px;
  background: #f5f7fa;
  border-radius: 4px;
  min-width: 60px;
  text-align: center;
  display: inline-block;
}

.password-text:hover {
  background: #e4e7ed;
}

.copy-icon {
  cursor: pointer;
  color: #909399;
  font-size: 14px;
}

.copy-icon:hover {
  color: #409eff;
}

.empty-text {
  color: #909399;
}
</style>
