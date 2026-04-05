<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="关键词">
          <el-input
            v-model="searchParams.search"
            placeholder="项目名称/负责人"
            clearable
            style="width: 220px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchParams.status" placeholder="全部状态" clearable style="width: 150px">
            <el-option label="运行中" value="运行中" />
            <el-option label="已下线" value="已下线" />
            <el-option label="规划中" value="规划中" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right;">
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增项目</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="project_name" label="项目名称" min-width="180" show-overflow-tooltip>
          <template #default="{ row }">
            <el-link type="primary" @click="handleView(row)">{{ row.project_name }}</el-link>
          </template>
        </el-table-column>
        <el-table-column prop="owner" label="负责人" min-width="120" />
        <el-table-column prop="status" label="状态" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="server_count" label="服务器数" min-width="100" align="center" />
        <el-table-column prop="service_count" label="服务数" min-width="100" align="center" />
        <el-table-column prop="domain_count" label="域名数" min-width="100" align="center" />
        <el-table-column prop="cert_count" label="证书数" min-width="100" align="center" />
        <el-table-column prop="account_count" label="账号数" min-width="100" align="center" />
        <el-table-column label="操作" min-width="180" fixed="right">
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="项目名称" prop="project_name">
          <el-input v-model="form.project_name" placeholder="请输入项目名称" />
        </el-form-item>
        <el-form-item label="负责人" prop="owner">
          <el-input v-model="form.owner" placeholder="请输入负责人" />
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-select v-model="form.status" placeholder="请选择状态" style="width: 100%">
            <el-option label="运行中" value="运行中" />
            <el-option label="已下线" value="已下线" />
            <el-option label="规划中" value="规划中" />
          </el-select>
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="3" placeholder="请输入项目描述" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getProjects, createProject, updateProject, deleteProject } from '../api/projects'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength, isSafeSearch } from '@/utils/validators'

const router = useRouter()
const loading = ref<boolean>(false)
const submitLoading = ref<boolean>(false)
const tableData = ref<any[]>([])
const dialogVisible = ref<boolean>(false)
const dialogTitle = ref<string>('新增项目')
const editingId = ref<number | null>(null)
const formRef = ref<any>(null)

const searchParams = reactive({
  search: '',
  status: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const form = reactive({
  project_name: '',
  owner: '',
  status: '',
  description: '',
  remark: ''
})

const rules = {
  project_name: [
    { required: true, message: '请输入项目名称', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(200), trigger: 'blur' }
  ],
  owner: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ],
  description: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
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
    const res = await getProjects({ ...searchParams, page: pagination.page, page_size: pagination.pageSize })
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
  searchParams.status = ''
  pagination.page = 1
  fetchData()
}

function resetForm() {
  form.project_name = ''
  form.owner = ''
  form.status = ''
  form.description = ''
  form.remark = ''
}

function handleAdd() {
  dialogTitle.value = '新增项目'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

/**
 * @param {any} row
 */
function handleView(row: any) {
  router.push(`/projects/${row.id}`)
}

/**
 * @param {any} row
 */
function handleEdit(row: any) {
  dialogTitle.value = '编辑项目'
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
      await updateProject(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createProject(form)
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
function handleDelete(row: any) {
  ElMessageBox.confirm(`确定要删除项目 "${row.project_name}" 吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteProject(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

/**
 * @param {string} status
 */
function getStatusTagType(status: any) {
  /** @type {Record<string, string>} */
  const map = {
    '运行中': 'success',
    '已下线': 'info',
    '规划中': 'warning'
  }
  return map[status] || 'info'
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
