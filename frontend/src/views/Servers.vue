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
        <el-form-item label="平台">
          <el-select v-model="searchParams.platform" placeholder="全部平台" clearable style="width: 150px">
            <el-option v-for="item in platforms" :key="item.id" :label="item.name" :value="item.name" />
          </el-select>
        </el-form-item>
        <el-form-item label="所属项目">
          <el-select v-model="searchParams.project_id" placeholder="全部项目" clearable style="width: 180px">
            <el-option v-for="p in projectList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="主机名/IP/用途" 
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增服务器</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="env_type" label="环境类型" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getEnvTagType(row.env_type)" size="small">{{ row.env_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="platform" label="平台" min-width="100" show-overflow-tooltip />
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
        <el-table-column prop="hostname" label="主机名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="inner_ip" label="内网IP" min-width="120" />
        <el-table-column prop="mapped_ip" label="映射IP" min-width="120" />
        <el-table-column prop="cpu" label="CPU" min-width="80" align="center" />
        <el-table-column prop="memory" label="内存" min-width="80" align="center" />
        <el-table-column prop="purpose" label="用途" min-width="150" show-overflow-tooltip />
        <el-table-column label="密码轮换" min-width="120" align="center">
          <template #default="{ row }">
            <template v-if="row.password_rotation_enabled">
              <el-tooltip 
                :content="row.password_rotation_error || '上次更新: ' + (row.password_last_rotated_at || '未更新')"
                placement="top"
              >
                <el-tag 
                  :type="getRotationStatusType(row.password_rotation_status)" 
                  size="small"
                >
                  {{ getRotationStatusText(row.password_rotation_status) }}
                </el-tag>
              </el-tooltip>
            </template>
            <span v-else style="color: #909399;">未启用</span>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="环境类型" prop="env_type">
              <el-select v-model="form.env_type" placeholder="请选择" style="width: 100%">
                <el-option v-for="item in envTypes" :key="item.id" :label="item.name" :value="item.name" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="平台" prop="platform">
              <el-select v-model="form.platform" placeholder="请选择" style="width: 100%">
                <el-option v-for="item in platforms" :key="item.id" :label="item.name" :value="item.name" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="主机名" prop="hostname">
              <el-input v-model="form.hostname" placeholder="请输入主机名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内网IP" prop="inner_ip">
              <el-input v-model="form.inner_ip" placeholder="请输入内网IP" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="映射IP" prop="mapped_ip">
              <el-input v-model="form.mapped_ip" placeholder="请输入映射IP" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="公网IP" prop="public_ip">
              <el-input v-model="form.public_ip" placeholder="请输入公网IP" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="CPU" prop="cpu">
              <el-input v-model="form.cpu" placeholder="如：8核" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内存" prop="memory">
              <el-input v-model="form.memory" placeholder="如：16GB" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统盘" prop="sys_disk">
              <el-input v-model="form.sys_disk" placeholder="如：100GB" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="数据盘" prop="data_disk">
              <el-input v-model="form.data_disk" placeholder="如：500GB" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="用途" prop="purpose">
          <el-input v-model="form.purpose" type="textarea" :rows="2" placeholder="请输入用途" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统用户" prop="os_user">
              <el-input v-model="form.os_user" placeholder="如：root" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="系统密码" prop="os_password">
              <el-input v-model="form.os_password" type="password" show-password placeholder="请输入系统密码" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="普通用户" prop="regular_user">
              <el-input v-model="form.regular_user" placeholder="如：docker（可选）" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="普通用户密码" prop="regular_password">
              <el-input v-model="form.regular_password" type="password" show-password placeholder="普通用户密码（可选）" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="证书路径" prop="cert_path">
          <el-input v-model="form.cert_path" placeholder="/etc/nginx/ssl/" />
        </el-form-item>
        <el-form-item label="所属项目">
          <el-select v-model="form.project_ids" multiple placeholder="请选择所属项目" style="width: 100%">
            <el-option v-for="p in projectList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="请输入备注" />
        </el-form-item>
        <el-divider content-position="left">密码定期更新</el-divider>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="定期更新密码">
              <el-switch v-model="form.password_rotation_enabled" active-text="启用" inactive-text="关闭" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="更新周期(天)" prop="password_rotation_days" v-if="form.password_rotation_enabled">
              <el-input-number 
                v-model="form.password_rotation_days" 
                :min="1" 
                :max="365" 
                :step="1"
                placeholder="如：30"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
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
import { useRouter, useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getServers, createServer, updateServer, deleteServer } from '../api/servers'
import { getEnvTypes, getPlatforms } from '../api/dicts'
import { getProjectOptions } from '../api/projects'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { ipValidator, safeText, maxLength, isSafeSearch } from '@/utils/validators'

const router = useRouter()
const route = useRoute()
const loading = ref<boolean>(false)
const submitLoading = ref<boolean>(false)
const tableData = ref<any[]>([])
const dialogVisible = ref<boolean>(false)
const dialogTitle = ref<string>('新增服务器')
const editingId = ref<number | null>(null)
const formRef = ref<any>(null)

// 字典数据
const envTypes = ref<any[]>([])
const platforms = ref<any[]>([])
const projectList = ref<any[]>([])

const searchParams = reactive({
  env_type: '',
  platform: '',
  project_id: null as number | null,
  search: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const form = reactive({
  env_type: '',
  platform: '',
  hostname: '',
  inner_ip: '',
  mapped_ip: '',
  public_ip: '',
  cpu: '',
  memory: '',
  sys_disk: '',
  data_disk: '',
  purpose: '',
  os_user: '',
  os_password: '',
  regular_user: '',
  regular_password: '',
  cert_path: '',
  remark: '',
  project_ids: [] as number[],
  password_rotation_enabled: false,
  password_rotation_days: 30
})

const rules = {
  env_type: [{ required: true, message: '请选择环境类型', trigger: 'change' }],
  hostname: [
    { required: true, message: '请输入主机名', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(200), trigger: 'blur' }
  ],
  inner_ip: [
    { required: true, message: '请输入内网IP', trigger: 'blur' },
    { validator: ipValidator, trigger: 'blur' }
  ],
  mapped_ip: [
    { validator: ipValidator, trigger: 'blur' }
  ],
  public_ip: [
    { validator: ipValidator, trigger: 'blur' }
  ],
  cpu: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
  ],
  memory: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
  ],
  sys_disk: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
  ],
  data_disk: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(50), trigger: 'blur' }
  ],
  purpose: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
  ],
  os_user: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  os_password: [
    { validator: maxLength(200), trigger: 'blur' }
  ],
  regular_user: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  regular_password: [
    { validator: maxLength(200), trigger: 'blur' }
  ],
  cert_path: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
  ],
  remark: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
  ]
}

onMounted(() => {
  // 从 URL 恢复筛选状态（从详情页返回时保持筛选条件）
  const q = route.query
  if (q.env_type) searchParams.env_type = q.env_type as string
  if (q.platform) searchParams.platform = q.platform as string
  if (q.project_id) searchParams.project_id = Number(q.project_id)
  if (q.search) searchParams.search = q.search as string
  if (q.page) pagination.page = Number(q.page)
  if (q.page_size) pagination.pageSize = Number(q.page_size)

  fetchDicts()
  fetchProjects()
  fetchData()
})

async function fetchDicts() {
  try {
    const [envRes, platformRes] = await Promise.all([
      getEnvTypes(),
      getPlatforms()
    ])
    envTypes.value = envRes.data || []
    platforms.value = platformRes.data || []
  } catch (e) {
    console.error('加载字典数据失败', e)
  }
}

async function fetchProjects() {
  try {
    const res = await getProjectOptions()
    projectList.value = res.data || []
  } catch (e) {
    console.error('加载项目列表失败', e)
  }
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getServers({ ...searchParams, page: pagination.page, page_size: pagination.pageSize })
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
  searchParams.env_type = ''
  searchParams.platform = ''
  searchParams.project_id = null
  searchParams.search = ''
  pagination.page = 1
  fetchData()
}

function resetForm() {
  form.env_type = ''
  form.platform = ''
  form.hostname = ''
  form.inner_ip = ''
  form.mapped_ip = ''
  form.public_ip = ''
  form.cpu = ''
  form.memory = ''
  form.sys_disk = ''
  form.data_disk = ''
  form.purpose = ''
  form.os_user = ''
  form.os_password = ''
  form.regular_user = ''
  form.regular_password = ''
  form.cert_path = ''
  form.remark = ''
  form.project_ids = []
  form.password_rotation_enabled = false
  form.password_rotation_days = 30
}

function handleAdd() {
  dialogTitle.value = '新增服务器'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

/**
 * @param {any} row
 */
function handleView(row: any) {
  const query: Record<string, string> = {}
  if (searchParams.env_type) query.env_type = searchParams.env_type
  if (searchParams.platform) query.platform = searchParams.platform
  if (searchParams.project_id) query.project_id = String(searchParams.project_id)
  if (searchParams.search) query.search = searchParams.search
  if (pagination.page > 1) query.page = String(pagination.page)
  if (pagination.pageSize !== 20) query.page_size = String(pagination.pageSize)
  router.push({ path: `/servers/${row.id}`, query })
}

/**
 * @param {any} row
 */
function handleEdit(row: any) {
  dialogTitle.value = '编辑服务器'
  editingId.value = row.id
  Object.assign(form, row)
  form.project_ids = row.project_ids || []
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  
  submitLoading.value = true
  try {
    if (editingId.value) {
      await updateServer(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createServer(form)
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
  ElMessageBox.confirm(`确定要删除服务器 "${row.hostname}" 吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteServer(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

/**
 * @param {any} env
 */
function getEnvTagType(env: string) {
  const map: Record<string, string> = {
    '生产': 'danger',
    '测试': 'warning',
    '智慧环保': 'success',
    '水电集团': 'primary'
  }
  return map[env] || 'info'
}

function getRotationStatusType(status: string) {
  const map: Record<string, string> = {
    'idle': 'info',
    'running': 'warning',
    'success': 'success',
    'failed': 'danger'
  }
  return map[status] || 'info'
}

function getRotationStatusText(status: string) {
  const map: Record<string, string> = {
    'idle': '待更新',
    'running': '更新中',
    'success': '已更新',
    'failed': '失败'
  }
  return map[status] || status || '未知'
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

.clickable-tag {
  cursor: pointer;
}

.clickable-tag:hover {
  opacity: 0.8;
}
</style>
