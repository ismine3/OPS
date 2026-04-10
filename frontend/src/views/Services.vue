<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="环境类型">
          <el-select v-model="searchParams.env_type" placeholder="全部环境" clearable style="width: 150px">
            <el-option v-for="item in envTypes" :key="item.id" :label="item.name" :value="item.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="分类">
          <el-select v-model="searchParams.category" placeholder="全部分类" clearable style="width: 150px">
            <el-option v-for="item in serviceCategories" :key="item.id" :label="item.name" :value="item.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="所属项目">
          <el-select v-model="searchParams.project_id" placeholder="所属项目" clearable style="width: 160px">
            <el-option v-for="p in projectList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="服务名称"
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增服务</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="hostname" label="主机名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="server_inner_ip" label="服务器IP" min-width="120" />
        <el-table-column prop="mapped_ip" label="映射IP" min-width="120" />
        <el-table-column prop="env_type" label="环境类型" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getEnvTagType(row.env_type)" size="small">{{ row.env_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="category" label="分类" min-width="100" />
        <el-table-column prop="service_name" label="服务名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="version" label="版本" min-width="100" />
        <el-table-column prop="inner_port" label="内部端口" min-width="100" align="center" />
        <el-table-column prop="mapped_port" label="映射端口" min-width="100" align="center" />
        <el-table-column prop="project_name" label="所属项目" min-width="120">
          <template #default="{ row }">
            <el-link v-if="row.project_id" type="primary" @click="$router.push(`/projects/${row.project_id}`)">
              {{ row.project_name }}
            </el-link>
            <span v-else>-</span>
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="600px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="所属服务器" prop="server_id">
          <el-select v-model="form.server_id" placeholder="请选择服务器" style="width: 100%" filterable>
            <el-option 
              v-for="server in serverList" 
              :key="server.id" 
              :label="`${server.inner_ip} (${server.name})`" 
              :value="server.id" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="分类" prop="category">
          <el-select v-model="form.category" placeholder="请选择分类" style="width: 100%">
            <el-option 
              v-for="item in serviceCategories" 
              :key="item.id" 
              :label="item.name" 
              :value="item.name" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="服务名称" prop="service_name">
          <el-input v-model="form.service_name" placeholder="如：MySQL、Redis、Nginx" />
        </el-form-item>
        <el-form-item label="版本" prop="version">
          <el-input v-model="form.version" placeholder="如：8.0、6.2" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="内部端口" prop="inner_port">
              <el-input v-model="form.inner_port" placeholder="如：3306" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="映射端口" prop="mapped_port">
              <el-input v-model="form.mapped_port" placeholder="如：13306" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="所属项目" prop="project_id">
          <el-select v-model="form.project_id" placeholder="请选择项目" clearable style="width: 100%">
            <el-option v-for="p in projectList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
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

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getServices, createService, updateService, deleteService } from '../api/services'
import { getServerOptions } from '../api/servers'
import { getEnvTypes, getServiceCategories } from '../api/dicts'
import { getProjectOptions } from '../api/projects'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength, portValidator, isSafeSearch } from '@/utils/validators'

const loading = ref<boolean>(false)
const submitLoading = ref<boolean>(false)
const tableData = ref<any[]>([])
const serverList = ref<any[]>([])
const projectList = ref<any[]>([])
const dialogVisible = ref<boolean>(false)
const dialogTitle = ref<string>('新增服务')
const editingId = ref<number | null>(null)
const formRef = ref<any>(null)
const envTypes = ref<any[]>([])
const serviceCategories = ref<any[]>([])

const searchParams = reactive({
  env_type: '',
  category: '',
  project_id: null as number | null,
  search: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const form = reactive({
  server_id: '',
  category: '',
  service_name: '',
  version: '',
  inner_port: '',
  mapped_port: '',
  project_id: null as number | null,
  remark: ''
})

const rules = {
  server_id: [{ required: true, message: '请选择所属服务器', trigger: 'change' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  service_name: [
    { required: true, message: '请输入服务名称', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(200), trigger: 'blur' }
  ],
  version: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  inner_port: [
    { validator: portValidator, trigger: 'blur' }
  ],
  mapped_port: [
    { validator: portValidator, trigger: 'blur' }
  ],
  remark: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
  ]
}

onMounted(() => {
  fetchData()
  fetchServerList()
  loadDicts()
  fetchProjects()
})

async function fetchProjects() {
  try {
    const res = await getProjectOptions()
    projectList.value = res.data || []
  } catch (e) {
    console.error('获取项目列表失败', e)
  }
}

async function loadDicts() {
  try {
    const [envRes, catRes] = await Promise.all([getEnvTypes(), getServiceCategories()])
    envTypes.value = envRes.data || []
    serviceCategories.value = catRes.data || []
  } catch(e) { console.error(e) }
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getServices({ ...searchParams, page: pagination.page, page_size: pagination.pageSize })
    tableData.value = res.data.items || []
    pagination.total = res.data.total || 0
  } finally {
    loading.value = false
  }
}

async function fetchServerList() {
  try {
    const res = await getServerOptions()
    serverList.value = res.data || []
  } catch (e) {
    console.error('获取服务器列表失败', e)
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
  searchParams.env_type = ''
  searchParams.category = ''
  searchParams.project_id = null
  searchParams.search = ''
  pagination.page = 1
  fetchData()
}

function resetForm() {
  form.server_id = ''
  form.category = ''
  form.service_name = ''
  form.version = ''
  form.inner_port = ''
  form.mapped_port = ''
  form.project_id = null
  form.remark = ''
}

function handleAdd() {
  dialogTitle.value = '新增服务'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

/**
 * @param {any} row
 */
function handleEdit(row: any) {
  dialogTitle.value = '编辑服务'
  editingId.value = row.id
  Object.assign(form, row)
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  
  submitLoading.value = true
  try {
    // 构建提交数据，确保字段类型正确
    const submitData = {
      server_id: Number(form.server_id) || null,
      category: form.category,
      service_name: form.service_name,
      version: form.version,
      inner_port: form.inner_port,
      mapped_port: form.mapped_port,
      project_id: form.project_id,
      remark: form.remark
    }
    
    if (editingId.value) {
      await updateService(editingId.value, submitData)
      ElMessage.success('更新成功')
    } else {
      await createService(submitData)
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
  ElMessageBox.confirm(`确定要删除服务 "${row.service_name}" 吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteService(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

/**
 * @param {string} env
 */
function getEnvTagType(env: string) {
  /** @type {Record<string, string>} */
  const map: Record<string, string> = {
    '生产': 'danger',
    '测试': 'warning',
    '智慧环保': 'success',
    '水电集团': 'primary'
  }
  return map[env] || 'info'
}

/**
 * @param {string} ports
 */
function parsePorts(ports: string) {
  return ports.split(',').map(port => port.trim()).filter(port => port)
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

.port-list {
  display: flex;
  flex-wrap: wrap;
}

</style>
