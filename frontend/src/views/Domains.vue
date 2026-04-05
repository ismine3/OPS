<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="所属项目">
          <el-select v-model="searchParams.project_id" placeholder="所属项目" clearable style="width: 160px">
            <el-option v-for="p in projectList" :key="p.id" :label="p.project_name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="搜索域名/持有者/注册商" 
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增域名</el-button>
          <el-button type="warning" :icon="Refresh" @click="handleSync">云同步</el-button>
          <el-button type="warning" :icon="Bell" @click="handleNotify" :loading="notifyLoading">微信通知</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="domain_name" label="域名" min-width="200" show-overflow-tooltip />
        <el-table-column prop="registrar" label="注册商" min-width="120" />
        <el-table-column prop="registration_date" label="注册日期" min-width="110" />
        <el-table-column prop="expire_date" label="到期日期" min-width="110" />
        <el-table-column label="剩余天数" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getRemainingDaysTagType(row.expire_date)" size="small">
              {{ getRemainingDays(row.expire_date) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="owner" label="持有者" min-width="120" />
        <el-table-column prop="project_name" label="所属项目" min-width="120">
          <template #default="{ row }">
            <el-link v-if="row.project_id" type="primary" @click="$router.push(`/projects/${row.project_id}`)">
              {{ row.project_name }}
            </el-link>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" min-width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="source" label="来源" min-width="80">
          <template #default="{ row }">
            <el-tag :type="row.source === 'aliyun' ? 'primary' : 'info'" size="small">
              {{ row.source === 'aliyun' ? '阿里云' : '手动' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="cost" label="费用" min-width="100">
          <template #default="{ row }">
            {{ formatCost(row.cost) }}
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" min-width="150" fixed="right">
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="700px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="域名" prop="domain_name">
              <el-input v-model="form.domain_name" placeholder="请输入域名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="注册商" prop="registrar">
              <el-input v-model="form.registrar" placeholder="请输入注册商" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="注册日期" prop="registration_date">
              <el-date-picker 
                v-model="form.registration_date" 
                type="date" 
                placeholder="选择注册日期"
                value-format="YYYY-MM-DD"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="到期日期" prop="expire_date">
              <el-date-picker 
                v-model="form.expire_date" 
                type="date" 
                placeholder="选择到期日期"
                value-format="YYYY-MM-DD"
                style="width: 100%"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="持有者" prop="owner">
              <el-input v-model="form.owner" placeholder="请输入持有者" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="DNS服务器" prop="dns_server">
              <el-input v-model="form.dns_server" placeholder="请输入DNS服务器" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" placeholder="请选择状态" style="width: 100%">
                <el-option label="正常" value="正常" />
                <el-option label="即将过期" value="即将过期" />
                <el-option label="已过期" value="已过期" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="费用" prop="cost">
              <el-input-number v-model="form.cost" :min="0" :precision="2" style="width: 100%" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="所属项目" prop="project_id">
          <el-select v-model="form.project_id" placeholder="请选择项目" clearable style="width: 100%">
            <el-option v-for="p in projectList" :key="p.id" :label="p.project_name" :value="p.id" />
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

    <!-- 云同步弹窗 -->
    <el-dialog v-model="syncDialogVisible" title="云同步" width="450px" destroy-on-close>
      <el-alert type="info" :closable="false" description="暂时仅支持阿里云" show-icon style="margin-bottom: 16px" />
      <el-form ref="syncFormRef" :model="syncForm" :rules="syncRules" label-width="120px">
        <el-form-item label="云账户" prop="accountIds">
          <el-select v-model="syncForm.accountIds" placeholder="请选择云账户（支持多选）" style="width: 100%" filterable multiple collapse-tags>
            <el-option
              v-for="item in aliyunAccountList"
              :key="item.id"
              :label="item.credential_name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="syncDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSyncSubmit" :loading="syncLoading">确认同步</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh, Bell } from '@element-plus/icons-vue'
import { getDomains, createDomain, updateDomain, deleteDomain, syncAliyunDomains, notifyDomains } from '../api/domains'
import { getAliyunAccounts } from '../api/aliyunAccounts'
import { getProjects } from '../api/projects'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { domainValidator, safeText, maxLength, isSafeSearch } from '@/utils/validators'

const loading = ref<boolean>(false)
const submitLoading = ref<boolean>(false)
const syncLoading = ref<boolean>(false)
const notifyLoading = ref<boolean>(false)
const tableData = ref<any[]>([])
const dialogVisible = ref<boolean>(false)
const syncDialogVisible = ref<boolean>(false)
const dialogTitle = ref<string>('新增域名')
const editingId = ref<number | null>(null)
const formRef = ref<any>(null)
const syncFormRef = ref<any>(null)
const projectList = ref<any[]>([])

const searchParams = reactive({
  search: '',
  project_id: null as number | null
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const form = reactive({
  domain_name: '',
  registrar: '',
  registration_date: '',
  expire_date: '',
  owner: '',
  dns_server: '',
  status: '',
  cost: 0,
  project_id: null as number | null,
  remark: ''
})

const syncForm = reactive({
  accountIds: [] as number[]
})

const aliyunAccountList = ref<any[]>([])

const rules = {
  domain_name: [
    { required: true, message: '请输入域名', trigger: 'blur' },
    { validator: domainValidator, trigger: 'blur' }
  ],
  registrar: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  owner: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  dns_server: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  cost: [
    { type: 'number', min: 0, max: 999999, message: '费用范围 0-999999', trigger: 'blur' }
  ],
  remark: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
  ]
}

const syncRules = {
  accountIds: [{ 
    required: true, 
    type: 'array',
    min: 1,
    message: '请选择至少一个云账户', 
    trigger: 'change' 
  }]
}

onMounted(() => {
  fetchData()
  fetchProjects()
})

async function fetchProjects() {
  try {
    const res = await getProjects({ per_page: 1000 })
    projectList.value = res.data?.items || res.data || []
  } catch (e) {
    console.error('获取项目列表失败', e)
  }
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getDomains({ 
      ...searchParams, 
      page: pagination.page, 
      page_size: pagination.pageSize 
    })
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
  searchParams.project_id = null
  pagination.page = 1
  fetchData()
}

function resetForm() {
  form.domain_name = ''
  form.registrar = ''
  form.registration_date = ''
  form.expire_date = ''
  form.owner = ''
  form.dns_server = ''
  form.status = ''
  form.cost = 0
  form.project_id = null
  form.remark = ''
}

function handleAdd() {
  dialogTitle.value = '新增域名'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

/**
 * @param {any} row
 */
function handleEdit(row: any) {
  dialogTitle.value = '编辑域名'
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
      await updateDomain(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createDomain(form)
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
  ElMessageBox.confirm(`确定要删除域名 "${row.domain_name}" 吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteDomain(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

async function handleSync() {
  syncForm.accountIds = []
  syncDialogVisible.value = true
  // 在弹窗打开时加载账户列表
  try {
    const res = await getAliyunAccounts()
    aliyunAccountList.value = res.data || []
  } catch (e) {
    // @ts-ignore
    console.error('获取云账户列表失败:', e)
    aliyunAccountList.value = []
  }
}

async function handleSyncSubmit() {
  const valid = await syncFormRef.value?.validate().catch(() => false)
  if (!valid) return

  syncLoading.value = true
  try {
    const results = await Promise.allSettled(
      syncForm.accountIds.map(id => syncAliyunDomains(id))
    )
    const succeeded = results.filter(r => r.status === 'fulfilled')
    const failed = results.filter(r => r.status === 'rejected')

    if (failed.length === 0) {
      ElMessage.success(`同步成功，共同步 ${succeeded.length} 个账户`)
    } else if (succeeded.length === 0) {
      ElMessage.error('所有账户同步失败')
    } else {
      ElMessage.warning(`${succeeded.length} 个账户同步成功，${failed.length} 个失败`)
    }

    syncDialogVisible.value = false
    fetchData()
  } finally {
    syncLoading.value = false
  }
}

async function handleNotify() {
  notifyLoading.value = true
  try {
    const res = await notifyDomains()
    if (res.data?.notified > 0) {
      ElMessage.success(`通知发送成功，已通知 ${res.data.notified} 个即将到期域名`)
    } else {
      ElMessage.info('没有需要预警的域名')
    }
  } catch (e) {
    // @ts-ignore
    ElMessage.error(e.response?.data?.message || '通知发送失败')
  } finally {
    notifyLoading.value = false
  }
}

// 计算剩余天数
/**
 * @param {any} expireDate
 */
function getRemainingDays(expireDate: any) {
  if (!expireDate) return '-'
  const today = new Date()
  const expire = new Date(expireDate)
  const diffTime = expire.getTime() - today.getTime()
  const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  return diffDays
}

// 根据剩余天数获取标签类型
/**
 * @param {any} expireDate
 */
function getRemainingDaysTagType(expireDate: any) {
  const days = getRemainingDays(expireDate)
  if (days === '-') return 'info'
  if (days <= 0) return 'danger'
  if (days < 30) return 'danger'
  if (days < 90) return 'warning'
  return 'success'
}

// 根据状态获取标签类型
/**
 * @param {any} status
 */
function getStatusTagType(status: any) {
  // 支持数字和中文两种格式
  /** @type {Record<string, string>} */
  const statusMap = {
    '正常': 'success',
    '即将过期': 'warning',
    '已过期': 'danger',
    '申请中': 'info',
    // 阿里云状态码映射
    '1': 'danger',   // 急需续费
    '2': 'danger',   // 急需赎回
    '3': 'success',  // 正常
    '4': 'danger'    // 已过期
  }
  return statusMap[status] || 'info'
}

// 状态显示文本转换
/**
 * @param {any} status
 */
function getStatusText(status: any) {
  /** @type {Record<string, string>} */
  const textMap = {
    '正常': '正常',
    '即将过期': '即将过期',
    '已过期': '已过期',
    '申请中': '申请中',
    // 阿里云状态码映射
    '1': '急需续费',
    '2': '急需赎回',
    '3': '正常',
    '4': '已过期'
  }
  return textMap[status] || status || '-'
}

// 格式化费用
/**
 * @param {any} cost
 */
function formatCost(cost: any) {
  if (cost === null || cost === undefined) return '-'
  return `¥${Number(cost).toFixed(2)}`
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
