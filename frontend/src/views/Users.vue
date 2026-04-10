<template>
  <div class="page-container">
    <el-tabs v-model="activeTab" class="user-tabs">
      <!-- 用户管理 Tab -->
      <el-tab-pane label="用户管理" name="users">
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
      </el-tab-pane>

      <!-- 角色授权 Tab -->
      <el-tab-pane label="角色授权" name="roles">
        <el-row :gutter="20" v-loading="roleLoading">
          <el-col :span="12" v-for="roleKey in ['operator', 'viewer']" :key="roleKey">
            <el-card class="role-card">
              <template #header>
                <div class="card-header">
                  <span>{{ roleKey === 'operator' ? '操作员' : '只读用户' }}</span>
                </div>
              </template>
              <el-checkbox-group v-model="roleModules[roleKey]">
                <el-row>
                  <el-col :span="12" v-for="module in availableModules" :key="module.code">
                    <el-checkbox :value="module.code">{{ module.name }}</el-checkbox>
                  </el-col>
                </el-row>
              </el-checkbox-group>
              <div class="card-footer">
                <el-checkbox 
                  v-model="selectAllFlags[roleKey]" 
                  @change="handleSelectAll(roleKey, $event)"
                  :indeterminate="isIndeterminate(roleKey)"
                >全选</el-checkbox>
                <el-button type="primary" size="small" @click="handleSaveRoleModules(roleKey)" :loading="saveLoading[roleKey]">
                  保存
                </el-button>
              </div>
            </el-card>
          </el-col>
        </el-row>
      </el-tab-pane>
    </el-tabs>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getUsers, createUser, updateUser, deleteUser, resetPassword, getRoleModules, updateRoleModules } from '../api/users'
import { useUserStore } from '../stores/user'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength, passwordStrength, isSafeSearch } from '@/utils/validators'

const userStore = useUserStore()
const loading = ref(false)
const submitLoading = ref(false)
const resetLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const resetDialogVisible = ref(false)
const dialogTitle = ref('新增用户')
const editingId = ref(null)
const formRef = ref<any>(null)
const resetFormRef = ref<any>(null)

// Tab 相关
const activeTab = ref('users')

// 角色授权相关
const roleLoading = ref(false)
const availableModules = ref<{ code: string; name: string }[]>([])
const roleModules = reactive<Record<string, string[]>>({
  operator: [],
  viewer: []
})
const saveLoading = reactive<Record<string, boolean>>({
  operator: false,
  viewer: false
})
const selectAllFlags = reactive<Record<string, boolean>>({
  operator: false,
  viewer: false
})

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
  userId: null as number | null,
  username: '',
  new_password: ''
})

const rules = {
  username: [
    { required: true, message: '请输入用户名', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
  ],
  password: [
    { required: true, message: '请输入密码', trigger: 'blur' },
    { validator: passwordStrength, trigger: 'blur' }
  ],
  display_name: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  role: [{ required: true, message: '请选择角色', trigger: 'change' }]
}

const resetRules = {
  new_password: [
    { required: true, message: '请输入新密码', trigger: 'blur' },
    { validator: passwordStrength, trigger: 'blur' }
  ]
}

onMounted(() => {
  fetchData()
  fetchRoleModules()
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

async function fetchRoleModules() {
  roleLoading.value = true
  try {
    const res = await getRoleModules()
    if (res.data) {
      availableModules.value = res.data.available_modules || []
      if (res.data.roles) {
        roleModules.operator = res.data.roles.operator || []
        roleModules.viewer = res.data.roles.viewer || []
      }
      // 初始化全选状态
      updateSelectAllFlags()
    }
  } finally {
    roleLoading.value = false
  }
}

function handleSearch() {
  if (!isSafeSearch(searchParams.search)) {
    ElMessage.warning('搜索内容包含非法字符')
    return
  }
  fetchData()
}

function handleReset() {
  searchParams.search = ''
  fetchData()
}

function resetFormData() {
  form.username = ''
  form.password = ''
  form.display_name = ''
  form.role = ''
  form.is_active = true
}

function handleAdd() {
  dialogTitle.value = '新增用户'
  editingId.value = null
  resetFormData()
  dialogVisible.value = true
}

function handleEdit(row: any) {
  dialogTitle.value = '编辑用户'
  editingId.value = row.id
  Object.assign(form, row)
  dialogVisible.value = true
}

function handleResetPassword(row: any) {
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
    await resetPassword(resetForm.userId!, { new_password: resetForm.new_password })
    ElMessage.success('密码重置成功')
    resetDialogVisible.value = false
  } finally {
    resetLoading.value = false
  }
}

function handleDelete(row: any) {
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

function getRoleTagType(role: string) {
  const map: Record<string, string> = {
    'admin': 'danger',
    'operator': 'warning',
    'viewer': 'info'
  }
  return map[role] || 'info'
}

function getRoleText(role: string) {
  const map: Record<string, string> = {
    'admin': '管理员',
    'operator': '操作员',
    'viewer': '只读用户'
  }
  return map[role] || role
}

// 角色授权相关方法
function handleSelectAll(roleKey: string, checked: boolean) {
  if (checked) {
    roleModules[roleKey] = availableModules.value.map(m => m.code)
  } else {
    roleModules[roleKey] = []
  }
}

function isIndeterminate(roleKey: string): boolean {
  const selected = roleModules[roleKey].length
  const total = availableModules.value.length
  return selected > 0 && selected < total
}

function updateSelectAllFlags() {
  for (const roleKey of ['operator', 'viewer'] as const) {
    selectAllFlags[roleKey] = roleModules[roleKey].length === availableModules.value.length && availableModules.value.length > 0
  }
}

// 监听角色模块变化，更新全选状态
watch(roleModules, () => {
  updateSelectAllFlags()
}, { deep: true })

async function handleSaveRoleModules(roleKey: string) {
  saveLoading[roleKey] = true
  try {
    await updateRoleModules(roleKey, roleModules[roleKey])
    ElMessage.success('更新成功')
    // 如果当前用户不是admin，刷新用户信息以更新modules
    if (!userStore.isAdmin) {
      await userStore.fetchProfile()
    }
  } finally {
    saveLoading[roleKey] = false
  }
}
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.user-tabs {
  background: #fff;
  border-radius: 8px;
  padding: 16px;
}

.search-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 0;
}

.role-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  font-weight: 600;
}

.card-footer {
  margin-top: 16px;
  padding-top: 16px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.role-card :deep(.el-checkbox) {
  margin-bottom: 12px;
}
</style>
