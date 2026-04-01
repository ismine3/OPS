<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="关键词">
          <el-input
            v-model="searchParams.search"
            placeholder="用户名/显示名"
            clearable
            style="width: 220px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right;">
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增用户</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="username" label="用户名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="display_name" label="显示名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="role" label="角色" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getRoleTagType(row.role)" size="small">{{ getRoleText(row.role) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="is_active" label="状态" min-width="80">
          <template #default="{ row }">
            <el-tag :type="row.is_active ? 'success' : 'info'" size="small">
              {{ row.is_active ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="created_at" label="创建时间" min-width="160" />
        <el-table-column label="操作" min-width="220" fixed="right">
          <template #default="{ row }">
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="info" size="small" @click="handleResetPassword(row)">重置密码</el-button>
            <el-button 
              type="danger" 
              size="small" 
              @click="handleDelete(row)"
              :disabled="row.id === currentUserId"
            >删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!tableData.length && !loading" description="暂无数据" />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="500px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="用户名" prop="username">
          <el-input v-model="form.username" placeholder="请输入用户名" :disabled="!!editingId" />
        </el-form-item>
        <el-form-item v-if="!editingId" label="密码" prop="password">
          <el-input v-model="form.password" type="password" show-password placeholder="请输入密码（最少6位）" />
        </el-form-item>
        <el-form-item label="显示名" prop="display_name">
          <el-input v-model="form.display_name" placeholder="请输入显示名" />
        </el-form-item>
        <el-form-item label="角色" prop="role">
          <el-select v-model="form.role" placeholder="请选择角色" style="width: 100%" :disabled="editingId === currentUserId">
            <el-option label="管理员" value="admin" />
            <el-option label="操作员" value="operator" />
            <el-option label="只读用户" value="viewer" />
          </el-select>
          <el-text v-if="editingId === currentUserId" type="warning" size="small">
            不能修改当前登录用户的角色
          </el-text>
        </el-form-item>
        <el-form-item v-if="editingId" label="状态" prop="is_active">
          <el-switch v-model="form.is_active" active-text="启用" inactive-text="禁用" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>

    <!-- 重置密码弹窗 -->
    <el-dialog v-model="resetDialogVisible" title="重置密码" width="400px" destroy-on-close>
      <el-form ref="resetFormRef" :model="resetForm" :rules="resetRules" label-width="100px">
        <el-form-item label="用户名">
          <el-input v-model="resetForm.username" disabled />
        </el-form-item>
        <el-form-item label="新密码" prop="new_password">
          <el-input v-model="resetForm.new_password" type="password" show-password placeholder="请输入新密码（最少6位）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="resetDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleResetSubmit" :loading="resetLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getUsers, createUser, updateUser, deleteUser, resetPassword } from '../api/users'
import { useUserStore } from '../stores/user'

const userStore = useUserStore()
const loading = ref(false)
const submitLoading = ref(false)
const resetLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const resetDialogVisible = ref(false)
const dialogTitle = ref('新增用户')
const editingId = ref(null)
const formRef = ref(null)
const resetFormRef = ref(null)

const currentUserId = computed(() => userStore.userInfo.id)

const searchParams = reactive({
  search: ''
})

const form = reactive({
  username: '',
  password: '',
  display_name: '',
  role: '',
  is_active: true
})

const resetForm = reactive({
  userId: null,
  username: '',
  new_password: ''
})

const rules = {
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { min: 6, message: '密码最少6位', trigger: 'blur' }
  ],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const resetRules = {
  new_password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { min: 6, message: '密码最少6位', trigger: 'blur' }
  ]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getUsers(searchParams)
    tableData.value = res.data || []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  fetchData()
}

function handleReset() {
  searchParams.search = ''
  fetchData()
}

function resetFormData() {
  Object.keys(form).forEach(key => {
    form[key] = key === 'is_active' ? true : ''
  })
}

function handleAdd() {
  dialogTitle.value = '新增用户'
  editingId.value = null
  resetFormData()
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑用户'
  editingId.value = row.id
  Object.assign(form, row)
  dialogVisible.value = true
}

function handleResetPassword(row) {
  resetForm.userId = row.id
  resetForm.username = row.username
  resetForm.new_password = ''
  resetDialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitLoading.value = true
  try {
    if (editingId.value) {
      const { username, password, ...updateData } = form
      await updateUser(editingId.value, updateData)
      ElMessage.success('更新成功')
    } else {
      await createUser(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

async function handleResetSubmit() {
  const valid = await resetFormRef.value?.validate().catch(() => false)
  if (!valid) return

  resetLoading.value = true
  try {
    await resetPassword(resetForm.userId, { new_password: resetForm.new_password })
    ElMessage.success('密码重置成功')
    resetDialogVisible.value = false
  } finally {
    resetLoading.value = false
  }
}

function handleDelete(row) {
  if (row.id === currentUserId.value) {
    ElMessage.warning('不能删除当前登录用户')
    return
  }
  ElMessageBox.confirm(`确定要删除用户 "${row.username}" 吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteUser(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

function getRoleTagType(role) {
  const map = {
    'admin': 'danger',
    'operator': 'warning',
    'viewer': 'info'
  }
  return map[role] || 'info'
}

function getRoleText(role) {
  const map = {
    'admin': '管理员',
    'operator': '操作员',
    'viewer': '只读用户'
  }
  return map[role] || role
}
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 0;
}
</style>
