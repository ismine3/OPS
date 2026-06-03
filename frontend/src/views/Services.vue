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
            placeholder="服务名称/IP"
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
        <el-table-column label="端口映射" min-width="180" align="center">
          <template #default="{ row }">
            <template v-if="row.ports && row.ports.length">
              <div v-for="(p, idx) in row.ports" :key="idx" class="port-mapping-row">
                {{ p.inner_port }}<template v-if="p.mapped_port">→{{ p.mapped_port }}</template>
                <span class="port-protocol-tag">{{ p.protocol }}</span>
              </div>
            </template>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="account" label="账户" min-width="130" show-overflow-tooltip>
          <template #default="{ row }">
            <span v-if="row.account" class="account-cell">
              <span class="account-text">{{ row.account }}</span>
              <el-icon class="copy-icon" @click="copyText(row.account)" title="复制"><CopyDocument /></el-icon>
            </span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column label="密码" min-width="140">
          <template #default="{ row }">
            <PasswordDisplay :password="row.password" />
          </template>
        </el-table-column>
        <el-table-column label="所属项目" min-width="180">
          <template #default="{ row }">
            <template v-if="row.project_names && row.project_names.length">
              <el-tag
                v-for="(name, idx) in row.project_names"
                :key="idx"
                size="small"
                type="primary"
                style="margin-right: 4px; margin-bottom: 2px;"
                @click="$router.push(`/projects/${row.project_ids[idx]}`)"
                class="clickable-tag"
              >{{ name }}</el-tag>
            </template>
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
        <el-form-item label="端口映射">
          <el-table :data="portList" size="small" border style="width: 100%" max-height="228">
            <el-table-column label="内网端口" width="115">
              <template #default="{ row, $index }">
                <el-input-number v-model="row.inner_port" :min="1" :max="65535" placeholder="80" size="small" controls-position="right" style="width: 100%" />
              </template>
            </el-table-column>
            <el-table-column label="映射端口" width="115">
              <template #default="{ row }">
                <el-input-number v-model="row.mapped_port" :min="1" :max="65535" placeholder="180" size="small" controls-position="right" style="width: 100%" />
              </template>
            </el-table-column>
            <el-table-column label="协议" width="82">
              <template #default="{ row }">
                <el-select v-model="row.protocol" size="small" style="width: 100%">
                  <el-option label="TCP" value="TCP" />
                  <el-option label="UDP" value="UDP" />
                  <el-option label="HTTP" value="HTTP" />
                  <el-option label="HTTPS" value="HTTPS" />
                </el-select>
              </template>
            </el-table-column>
            <el-table-column label="备注" width="106">
              <template #default="{ row }">
                <el-input v-model="row.remark" placeholder="备注" size="small" />
              </template>
            </el-table-column>
            <el-table-column label="操作" width="54" align="center">
              <template #default="{ $index }">
                <el-button type="danger" size="small" :icon="Delete" circle @click="removePortRow($index)" />
              </template>
            </el-table-column>
          </el-table>
          <el-button type="primary" size="small" style="margin-top: 8px" @click="addPortRow">
            <el-icon><Plus /></el-icon>添加端口映射
          </el-button>
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="账户" prop="account">
              <el-input v-model="form.account" placeholder="如：root" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="密码" prop="password">
              <el-input v-model="form.password" placeholder="请输入密码" show-password />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="所属项目" prop="project_ids">
          <el-select v-model="form.project_ids" placeholder="请选择项目（可多选）" multiple clearable style="width: 100%">
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
import { Plus, CopyDocument, Delete } from '@element-plus/icons-vue'
import { getServices, createService, updateService, deleteService } from '../api/services'
import { getServerOptions } from '../api/servers'
import { getEnvTypes, getServiceCategories } from '../api/dicts'
import { getProjectOptions } from '../api/projects'
import PasswordDisplay from '../components/PasswordDisplay.vue'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength, isSafeSearch } from '@/utils/validators'

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
  project_ids: [] as number[],
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
  account: '',
  password: '',
  project_ids: [] as number[],
  remark: ''
})

const portList = ref<any[]>([])

const rules = {
  server_id: [{ required: true, message: '请选择所属服务器', trigger: 'change' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  service_name: [
    { required: true, message: '请输入服务名称', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  version: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
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
    const params: Record<string, any> = { page: pagination.page, page_size: pagination.pageSize, search: searchParams.search }
    if (searchParams.env_type) params.env_type = searchParams.env_type
    if (searchParams.category) params.category = searchParams.category
    if (searchParams.project_id) params.project_id = searchParams.project_id
    const res = await getServices(params)
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
  searchParams.project_ids = []
  searchParams.project_id = null
  searchParams.search = ''
  pagination.page = 1
  fetchData()
}

function addPortRow() {
  portList.value.push({ inner_port: null, mapped_port: null, protocol: 'TCP', remark: '' })
}

function removePortRow(index: number) {
  portList.value.splice(index, 1)
}

function resetForm() {
  form.server_id = ''
  form.category = ''
  form.service_name = ''
  form.version = ''
  form.account = ''
  form.password = ''
  form.project_ids = []
  form.remark = ''
  portList.value = []
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
  form.project_ids = row.project_ids || []
  // 填充端口映射表
  portList.value = (row.ports && row.ports.length > 0)
    ? row.ports.map((p: any) => ({ ...p }))
    : []
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  
  submitLoading.value = true
  try {
    // 从端口映射表构建 ports 数据
    const ports = portList.value
      .filter((p: any) => p.inner_port)
      .map((p: any) => ({
        inner_port: p.inner_port,
        mapped_port: p.mapped_port || null,
        protocol: p.protocol || 'TCP',
        remark: p.remark || ''
      }))
    
    // 构建提交数据，确保字段类型正确
    const submitData = {
      server_id: Number(form.server_id) || null,
      category: form.category,
      service_name: form.service_name,
      version: form.version,
      ports: ports,
      account: form.account,
      password: form.password,
      project_ids: form.project_ids,
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

function copyText(text: string) {
  if (!text) return
  navigator.clipboard.writeText(text).then(() => {
    ElMessage.success('已复制')
  }).catch(() => {
    const textarea = document.createElement('textarea')
    textarea.value = text
    textarea.style.position = 'fixed'
    textarea.style.opacity = '0'
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand('copy')
    document.body.removeChild(textarea)
    ElMessage.success('已复制')
  })
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

.account-cell {
  display: inline-flex;
  align-items: center;
  gap: 8px;
  max-width: 100%;
}

.account-text {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  min-width: 0;
}

.account-cell .copy-icon {
  cursor: pointer;
  color: #909399;
  font-size: 14px;
  flex-shrink: 0;
}

.account-cell .copy-icon:hover {
  color: #409eff;
}

.clickable-tag {
  cursor: pointer;
}

.clickable-tag:hover {
  opacity: 0.8;
}

.port-mapping-row {
  line-height: 1.8;
  font-size: 13px;
}

.port-protocol-tag {
  margin-left: 4px;
  font-size: 11px;
  color: #909399;
  background: #f0f2f5;
  padding: 0 4px;
  border-radius: 2px;
}

</style>
