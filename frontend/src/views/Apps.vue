<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="账号名称/单位/用户名" 
            clearable 
            style="width: 280px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right;">
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增账号</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="seq_no" label="编号" min-width="100" show-overflow-tooltip />
        <el-table-column prop="name" label="账号名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="company" label="所属单位" min-width="150" show-overflow-tooltip />
        <el-table-column prop="access_url" label="访问地址" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <el-link 
              v-if="isHttpUrl(row.access_url)" 
              type="primary" 
              :href="row.access_url" 
              target="_blank"
              :underline="false"
            >
              {{ row.access_url }}
            </el-link>
            <span v-else>{{ row.access_url || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="password" label="密码" min-width="120">
          <template #default="{ row }">
            <PasswordDisplay :password="row.password" />
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" min-width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!tableData.length && !loading" description="暂无数据" />
      <el-pagination
        v-model:current-page="pagination.page"
        v-model:page-size="pagination.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="pagination.total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="fetchData"
        @current-change="fetchData"
        style="margin-top: 16px; justify-content: flex-end;"
      />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="550px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="编号" prop="seq_no">
          <el-input v-model="form.seq_no" placeholder="如：APP001" />
        </el-form-item>
        <el-form-item label="账号名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入账号名称" />
        </el-form-item>
        <el-form-item label="所属单位" prop="company">
          <el-input v-model="form.company" placeholder="请输入所属单位" />
        </el-form-item>
        <el-form-item label="访问地址" prop="access_url">
          <el-input v-model="form.access_url" placeholder="如：https://www.example.com" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="form.username" placeholder="请输入用户名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="密码" prop="password">
              <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="3" placeholder="请输入备注" />
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
import { getApps, createApp, updateApp, deleteApp } from '../api/apps'
import PasswordDisplay from '../components/PasswordDisplay.vue'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength, urlValidator, isSafeSearch } from '@/utils/validators'

const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增账号')
const editingId = ref(null)
/** @type {any} */
const formRef = ref(null)

const searchParams = reactive({
  search: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const form = reactive({
  seq_no: '',
  name: '',
  company: '',
  access_url: '',
  username: '',
  password: '',
  remark: ''
})

const rules = {
  seq_no: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
  ],
  name: [
    { required: true, message: '请输入账号名称', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  company: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  access_url: [
    { validator: urlValidator, trigger: 'blur' }
  ],
  username: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  password: [
    { validator: maxLength(200), trigger: 'blur' }
  ],
  remark: [
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
    const res = await getApps({ ...searchParams, page: pagination.page, page_size: pagination.pageSize })
    tableData.value = res.data.items || []
    pagination.total = res.data.total || 0
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  if (!isSafeSearch(searchParams.search)) {
    ElMessage.warning('搜索内容包含非法字符')
    return
  }
  pagination.page = 1
  fetchData()
}

function handleReset() {
  searchParams.search = ''
  pagination.page = 1
  fetchData()
}

function resetForm() {
  form.seq_no = ''
  form.name = ''
  form.company = ''
  form.access_url = ''
  form.username = ''
  form.password = ''
  form.remark = ''
}

function handleAdd() {
  dialogTitle.value = '新增账号'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

/**
 * @param {any} row
 */
function handleEdit(row) {
  dialogTitle.value = '编辑账号'
  editingId.value = row.id
  Object.assign(form, row)
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  
  submitLoading.value = true
  try {
    if (editingId.value) {
      await updateApp(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createApp(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

/**
 * @param {any} row
 */
function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除账号 "${row.name}" 吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteApp(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

/**
 * @param {any} url
 */
function isHttpUrl(url) {
  return url && (url.startsWith('http://') || url.startsWith('https://'))
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
