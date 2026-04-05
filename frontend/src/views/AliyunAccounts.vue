<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item style="float: right;">
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增凭证</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="credential_name" label="凭证名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="access_key_id" label="AccessKey ID" min-width="200" show-overflow-tooltip />
        <el-table-column prop="access_key_secret" label="AccessKey Secret" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <PasswordDisplay :password="row.access_key_secret" />
          </template>
        </el-table-column>
        <el-table-column prop="is_active" label="状态" min-width="80">
          <template #default="{ row }">
            <el-tag :type="row.is_active ? 'success' : 'danger'" size="small">
              {{ row.is_active ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="description" label="描述" min-width="200" show-overflow-tooltip />
        <el-table-column label="操作" min-width="150" fixed="right">
          <template #default="{ row }">
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!tableData.length && !loading" description="暂无数据" />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="550px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="130px">
        <el-form-item label="凭证名称" prop="credential_name">
          <el-input v-model="form.credential_name" placeholder="请输入凭证名称" />
        </el-form-item>
        <el-form-item label="AccessKey ID" prop="access_key_id">
          <el-input v-model="form.access_key_id" placeholder="请输入AccessKey ID" />
        </el-form-item>
        <el-form-item label="AccessKey Secret" prop="access_key_secret">
          <el-input 
            v-model="form.access_key_secret" 
            type="password" 
            show-password 
            :placeholder="editingId ? '不修改请留空' : '请输入AccessKey Secret'" 
          />
        </el-form-item>
        <el-form-item label="是否启用" prop="is_active">
          <el-switch v-model="form.is_active" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getAliyunAccounts, createAliyunAccount, updateAliyunAccount, deleteAliyunAccount } from '../api/aliyunAccounts'
import PasswordDisplay from '../components/PasswordDisplay.vue'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength } from '@/utils/validators'

const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增凭证')
const editingId = ref(null)
const formRef = ref(/** @type {any} */(null))

const searchParams = reactive({})

const form = reactive({
  credential_name: '',
  access_key_id: '',
  access_key_secret: '',
  is_active: true,
  description: ''
})

const rules = {
  credential_name: [
    { required: true, message: '请输入凭证名称', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  access_key_id: [
    { required: true, message: '请输入AccessKey ID', trigger: 'blur' },
    { validator: maxLength(128), trigger: 'blur' }
  ],
  access_key_secret: [
    { required: true, message: '请输入AccessKey Secret', trigger: 'blur' },
    { validator: maxLength(128), trigger: 'blur' }
  ],
  description: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
  ]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getAliyunAccounts()
    tableData.value = res.data || []
  } finally {
    loading.value = false
  }
}

function resetForm() {
  form.credential_name = ''
  form.access_key_id = ''
  form.access_key_secret = ''
  form.is_active = true
  form.description = ''
}

function handleAdd() {
  dialogTitle.value = '新增凭证'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

/** @param {any} row */
function handleEdit(row) {
  dialogTitle.value = '编辑凭证'
  editingId.value = row.id
  Object.assign(form, row)
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  submitLoading.value = true
  try {
    const submitData = { ...form }
    
    // 编辑时如果 access_key_secret 包含 *（脱敏值），提交时不传该字段
    if (editingId.value && submitData.access_key_secret && submitData.access_key_secret.includes('*')) {
      // @ts-ignore
      delete submitData.access_key_secret
    }
    
    // 新增时 access_key_secret 不能为空
    if (!editingId.value && !submitData.access_key_secret) {
      ElMessage.error('请输入AccessKey Secret')
      submitLoading.value = false
      return
    }

    if (editingId.value) {
      await updateAliyunAccount(editingId.value, submitData)
      ElMessage.success('更新成功')
    } else {
      await createAliyunAccount(submitData)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

/** @param {any} row */
function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除凭证 "${row.credential_name}" 吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteAliyunAccount(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
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
