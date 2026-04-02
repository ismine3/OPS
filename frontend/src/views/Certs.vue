<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="搜索">
          <el-input 
            v-model="searchParams.search" 
            placeholder="域名/项目名" 
            clearable 
            style="width: 220px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item label="证书类型">
          <el-select v-model="searchParams.cert_type" placeholder="全部类型" clearable style="width: 150px">
            <el-option label="自动检测" :value="0" />
            <el-option label="手动录入" :value="1" />
            <el-option label="阿里云证书" :value="2" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right;">
          <el-button type="success" :icon="Upload" @click="handleUploadCreateDialog">上传证书</el-button>
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增证书</el-button>
          <el-button type="success" :icon="Refresh" @click="handleBatchCheck" :loading="checkLoading">SSL检测</el-button>
          <el-button type="warning" :icon="Connection" @click="handleSyncDialog">阿里云同步</el-button>
          <el-button type="warning" :icon="Bell" @click="handleNotify" :loading="notifyLoading">微信通知</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="domain" label="域名" min-width="180" show-overflow-tooltip />
        <el-table-column prop="project_name" label="项目" min-width="120" show-overflow-tooltip />
        <el-table-column prop="cert_type" label="类型" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getCertTypeTag(row.cert_type)" size="small">
              {{ getCertTypeLabel(row.cert_type) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="issuer" label="颁发机构" min-width="120" show-overflow-tooltip />
        <el-table-column prop="cert_expire_time" label="到期时间" min-width="120">
          <template #default="{ row }">
            {{ formatDate(row.cert_expire_time) }}
          </template>
        </el-table-column>
        <el-table-column prop="remaining_days" label="剩余天数" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getDaysTagType(row.remaining_days)" size="small">
              {{ row.remaining_days <= 0 ? '已过期' : row.remaining_days + '天' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="brand" label="品牌" min-width="100" />
        <el-table-column prop="status" label="状态" min-width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">{{ row.status }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="last_check_time" label="最后检测" min-width="120">
          <template #default="{ row }">
            {{ formatDateTime(row.last_check_time) }}
          </template>
        </el-table-column>
        <el-table-column label="证书文件" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag v-if="row.has_cert_file === 1" type="success" size="small">已上传</el-tag>
            <el-tag v-else type="info" size="small">未上传</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" min-width="400" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleCheck(row)" :loading="row.checking">检测</el-button>
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
            <el-button v-if="row.has_cert_file !== 1" type="success" size="small" :icon="Upload" @click="handleUploadDialog(row)">上传</el-button>
            <el-button v-if="row.has_cert_file === 1" type="primary" size="small" :icon="Download" @click="handleDownload(row)">下载</el-button>
            <el-button v-if="row.has_cert_file === 1" type="success" size="small" :icon="Promotion" @click="handleDeployDialog(row)">部署</el-button>
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
            <el-form-item label="域名" prop="domain">
              <el-input v-model="form.domain" placeholder="请输入域名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="项目名称" prop="project_name">
              <el-input v-model="form.project_name" placeholder="请输入项目名称" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="证书类型" prop="cert_type">
              <el-select v-model="form.cert_type" placeholder="请选择证书类型" style="width: 100%">
                <el-option label="自动检测" :value="0" />
                <el-option label="手动录入" :value="1" />
                <el-option label="阿里云证书" :value="2" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="颁发机构" prop="issuer">
              <el-input v-model="form.issuer" placeholder="如：Let's Encrypt、DigiCert" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="到期时间" prop="cert_expire_time">
              <el-date-picker 
                v-model="form.cert_expire_time" 
                type="datetime" 
                placeholder="选择到期时间"
                style="width: 100%"
                value-format="YYYY-MM-DD HH:mm:ss"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="品牌" prop="brand">
              <el-input v-model="form.brand" placeholder="如：DigiCert、GeoTrust" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="费用" prop="cost">
              <el-input-number v-model="form.cost" :min="0" :precision="2" style="width: 100%" placeholder="请输入费用" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" placeholder="请选择状态" style="width: 100%">
                <el-option label="正常" value="正常" />
                <el-option label="即将过期" value="即将过期" />
                <el-option label="已过期" value="已过期" />
              </el-select>
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

    <!-- 阿里云同步弹窗 -->
    <el-dialog v-model="syncDialogVisible" title="阿里云证书同步" width="400px" destroy-on-close>
      <el-form :model="syncForm" label-width="120px">
        <el-form-item label="阿里云账户ID">
          <el-input-number v-model="syncForm.accountId" :min="1" style="width: 100%" placeholder="请输入阿里云账户ID" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="syncDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSync" :loading="syncLoading">确认同步</el-button>
      </template>
    </el-dialog>

    <!-- 上传证书文件弹窗 -->
    <el-dialog v-model="uploadDialogVisible" title="上传证书文件" width="500px" destroy-on-close>
      <el-form label-width="100px">
        <el-form-item label="证书域名">
          <span>{{ uploadTarget.domain }}</span>
        </el-form-item>
        <el-form-item label="证书文件" required>
          <el-upload
            ref="certUploadRef"
            :auto-upload="false"
            :limit="1"
            accept=".pem,.crt,.cer"
            :on-change="(file) => uploadFiles.certFile = file.raw"
            :on-remove="() => uploadFiles.certFile = null"
          >
            <el-button type="primary" :icon="Upload">选择证书文件</el-button>
            <template #tip>
              <div class="el-upload__tip">支持 .pem / .crt / .cer 格式</div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item label="私钥文件">
          <el-upload
            ref="keyUploadRef"
            :auto-upload="false"
            :limit="1"
            accept=".pem,.key"
            :on-change="(file) => uploadFiles.keyFile = file.raw"
            :on-remove="() => uploadFiles.keyFile = null"
          >
            <el-button type="primary" :icon="Upload">选择私钥文件</el-button>
            <template #tip>
              <div class="el-upload__tip">支持 .pem / .key 格式</div>
            </template>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="uploadDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleUpload" :loading="uploadLoading">上传</el-button>
      </template>
    </el-dialog>

    <!-- 上传并创建证书弹窗 -->
    <el-dialog v-model="uploadCreateDialogVisible" title="上传证书" width="550px" destroy-on-close>
      <el-form ref="uploadCreateFormRef" :model="uploadCreateForm" :rules="uploadCreateRules" label-width="100px">
        <el-form-item label="证书文件" prop="certFile">
          <el-upload
            ref="uploadCreateCertRef"
            :auto-upload="false"
            :limit="1"
            accept=".pem,.crt,.cer"
            :on-change="(file) => uploadCreateForm.certFile = file.raw"
            :on-remove="() => uploadCreateForm.certFile = null"
          >
            <el-button type="primary" :icon="Upload">选择证书文件</el-button>
            <template #tip>
              <div class="el-upload__tip">支持 .pem / .crt / .cer 格式，将自动解析域名、到期时间、颁发机构</div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item label="私钥文件">
          <el-upload
            ref="uploadCreateKeyRef"
            :auto-upload="false"
            :limit="1"
            accept=".pem,.key"
            :on-change="(file) => uploadCreateForm.keyFile = file.raw"
            :on-remove="() => uploadCreateForm.keyFile = null"
          >
            <el-button type="primary" :icon="Upload">选择私钥文件</el-button>
            <template #tip>
              <div class="el-upload__tip">支持 .pem / .key 格式（可选）</div>
            </template>
          </el-upload>
        </el-form-item>
        <el-form-item label="项目名称" prop="project_name">
          <el-input v-model="uploadCreateForm.project_name" placeholder="请输入项目名称" />
        </el-form-item>
        <el-form-item label="品牌">
          <el-input v-model="uploadCreateForm.brand" placeholder="如：DigiCert、GeoTrust（可选）" />
        </el-form-item>
        <el-form-item label="费用">
          <el-input-number v-model="uploadCreateForm.cost" :min="0" :precision="2" style="width: 100%" placeholder="请输入费用（可选）" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="uploadCreateForm.remark" type="textarea" :rows="2" placeholder="请输入备注（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="uploadCreateDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleUploadCreate" :loading="uploadCreateLoading">上传并创建</el-button>
      </template>
    </el-dialog>

    <!-- 部署证书弹窗 -->
    <el-dialog v-model="deployDialogVisible" title="部署证书到服务器" width="550px" destroy-on-close>
      <el-form :model="deployForm" label-width="100px">
        <el-form-item label="证书域名">
          <span>{{ deployTarget.domain }}</span>
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="环境类型">
              <el-select v-model="deployFilter.env_type" placeholder="全部环境" clearable style="width: 100%" @change="handleDeployFilterChange">
                <el-option label="测试" value="测试" />
                <el-option label="生产" value="生产" />
                <el-option label="智慧环保" value="智慧环保" />
                <el-option label="水电集团" value="水电集团" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="平台">
              <el-select v-model="deployFilter.platform" placeholder="全部平台" clearable style="width: 100%" @change="handleDeployFilterChange">
                <el-option v-for="p in platformOptions" :key="p" :label="p" :value="p" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="目标服务器" required>
          <el-select v-model="deployForm.server_id" placeholder="请选择服务器" style="width: 100%" filterable @change="handleServerChange">
            <el-option
              v-for="server in filteredServerList"
              :key="server.id"
              :label="`${server.hostname || ''} (${server.inner_ip || server.public_ip || ''})`"
              :value="server.id"
            >
              <div style="display: flex; justify-content: space-between;">
                <span>{{ server.hostname || '' }} ({{ server.inner_ip || server.public_ip || '' }})</span>
                <el-tag size="small" :type="getEnvTagType(server.env_type)" style="margin-left: 8px;">{{ server.env_type }}</el-tag>
              </div>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="SSH用户" required>
          <el-radio-group v-model="deployForm.ssh_user">
            <el-radio value="root">
              系统用户
              <span v-if="selectedServer" class="ssh-user-info">({{ selectedServer.os_user || 'root' }})</span>
            </el-radio>
            <el-radio value="docker" :disabled="!selectedServer || !selectedServer.docker_user">
              普通用户
              <span v-if="selectedServer && selectedServer.docker_user" class="ssh-user-info">({{ selectedServer.docker_user }})</span>
              <span v-else class="ssh-user-info text-muted">(未配置)</span>
            </el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="远程目录" required>
          <el-input v-model="deployForm.remote_path" placeholder="如 /etc/nginx/ssl/" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="deployDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleDeploy" :loading="deployLoading">确认部署</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, Refresh, Connection, Bell, Upload, Download, Promotion } from '@element-plus/icons-vue'
import { getCerts, createCert, updateCert, deleteCert, checkCert, checkCerts, syncAliyunCerts, notifyCerts, uploadCertFiles, downloadCertFiles, deleteCertFiles, deployCert, uploadAndCreateCert } from '../api/certs'
import { getServers } from '../api/servers'

const loading = ref(false)
const submitLoading = ref(false)
const checkLoading = ref(false)
const syncLoading = ref(false)
const notifyLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const syncDialogVisible = ref(false)
const dialogTitle = ref('新增证书')
const editingId = ref(null)
const formRef = ref(null)

const searchParams = reactive({
  search: '',
  cert_type: null
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const form = reactive({
  domain: '',
  project_name: '',
  cert_type: 0,
  issuer: '',
  cert_expire_time: '',
  brand: '',
  cost: 0,
  status: '正常',
  remark: ''
})

const syncForm = reactive({
  accountId: null
})

const uploadDialogVisible = ref(false)
const deployDialogVisible = ref(false)
const uploadLoading = ref(false)
const deployLoading = ref(false)
const uploadTarget = reactive({ id: null, domain: '' })
const deployTarget = reactive({ id: null, domain: '' })
const uploadFiles = reactive({ certFile: null, keyFile: null })
const deployForm = reactive({ server_id: null, remote_path: '', ssh_user: 'root' })
const deployFilter = reactive({ env_type: '', platform: '' })
const serverList = ref([])
const selectedServer = ref(null)
const certUploadRef = ref(null)
const keyUploadRef = ref(null)

// 上传并创建证书相关
const uploadCreateDialogVisible = ref(false)
const uploadCreateLoading = ref(false)
const uploadCreateFormRef = ref(null)
const uploadCreateCertRef = ref(null)
const uploadCreateKeyRef = ref(null)
const uploadCreateForm = reactive({
  certFile: null,
  keyFile: null,
  project_name: '',
  brand: '',
  cost: null,
  remark: ''
})
const uploadCreateRules = {
  certFile: [{ required: true, message: '请选择证书文件', trigger: 'change' }],
  project_name: [{ required: true, message: '请输入项目名称', trigger: 'blur' }]
}

const rules = {
  domain: [{ required: true, message: '请输入域名', trigger: 'blur' }],
  project_name: [{ required: true, message: '请输入项目名称', trigger: 'blur' }]
}

// 平台选项（从服务器列表提取）
const platformOptions = computed(() => {
  const platforms = new Set()
  serverList.value.forEach(s => {
    if (s.platform) platforms.add(s.platform)
  })
  return Array.from(platforms).sort()
})

// 筛选后的服务器列表
const filteredServerList = computed(() => {
  let list = serverList.value
  if (deployFilter.env_type) {
    list = list.filter(s => s.env_type === deployFilter.env_type)
  }
  if (deployFilter.platform) {
    list = list.filter(s => s.platform === deployFilter.platform)
  }
  return list
})

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const params = { ...searchParams, page: pagination.page, page_size: pagination.pageSize }
    // 移除空值参数
    Object.keys(params).forEach(key => {
      if (params[key] === '' || params[key] === null || params[key] === undefined) {
        delete params[key]
      }
    })
    const res = await getCerts(params)
    tableData.value = res.data.items || []
    pagination.total = res.data.total || 0
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  pagination.page = 1
  fetchData()
}

function handleReset() {
  searchParams.search = ''
  searchParams.cert_type = null
  pagination.page = 1
  fetchData()
}

function resetForm() {
  Object.assign(form, {
    domain: '',
    project_name: '',
    cert_type: 0,
    issuer: '',
    cert_expire_time: '',
    brand: '',
    cost: 0,
    status: '正常',
    remark: ''
  })
}

function handleAdd() {
  dialogTitle.value = '新增证书'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑证书'
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
      await updateCert(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createCert(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除证书 "${row.domain}" 吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteCert(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

async function handleCheck(row) {
  row.checking = true
  try {
    await checkCert(row.id)
    ElMessage.success('检测完成')
    fetchData()
  } finally {
    row.checking = false
  }
}

async function handleBatchCheck() {
  // 获取所有自动检测类型的证书ID
  const autoCheckCerts = tableData.value.filter(item => item.cert_type === 0)
  if (autoCheckCerts.length === 0) {
    ElMessage.warning('没有自动检测类型的证书')
    return
  }
  
  const ids = autoCheckCerts.map(item => item.id)
  checkLoading.value = true
  try {
    await checkCerts(ids)
    ElMessage.success('批量检测完成')
    fetchData()
  } finally {
    checkLoading.value = false
  }
}

function handleSyncDialog() {
  syncForm.accountId = null
  syncDialogVisible.value = true
}

async function handleSync() {
  if (!syncForm.accountId) {
    ElMessage.warning('请输入阿里云账户ID')
    return
  }
  
  syncLoading.value = true
  try {
    await syncAliyunCerts(syncForm.accountId)
    ElMessage.success('同步成功')
    syncDialogVisible.value = false
    fetchData()
  } finally {
    syncLoading.value = false
  }
}

async function handleNotify() {
  notifyLoading.value = true
  try {
    const res = await notifyCerts()
    if (res.data?.notified > 0) {
      ElMessage.success(`通知发送成功，已通知 ${res.data.notified} 个即将到期证书`)
    } else {
      ElMessage.info('没有需要预警的证书')
    }
  } catch (e) {
    ElMessage.error(e.response?.data?.message || '通知发送失败')
  } finally {
    notifyLoading.value = false
  }
}

function handleUploadDialog(row) {
  uploadTarget.id = row.id
  uploadTarget.domain = row.domain
  uploadFiles.certFile = null
  uploadFiles.keyFile = null
  uploadDialogVisible.value = true
}

async function handleUpload() {
  if (!uploadFiles.certFile) {
    ElMessage.warning('请选择证书文件')
    return
  }
  
  uploadLoading.value = true
  try {
    const formData = new FormData()
    formData.append('cert_file', uploadFiles.certFile)
    if (uploadFiles.keyFile) {
      formData.append('key_file', uploadFiles.keyFile)
    }
    await uploadCertFiles(uploadTarget.id, formData)
    ElMessage.success('证书文件上传成功')
    uploadDialogVisible.value = false
    fetchData()
  } catch (e) {
    ElMessage.error(e.response?.data?.message || '上传失败')
  } finally {
    uploadLoading.value = false
  }
}

async function handleDownload(row) {
  try {
    const res = await downloadCertFiles(row.id)
    const blob = new Blob([res], { type: 'application/zip' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${row.domain}_cert.zip`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('下载成功')
  } catch (e) {
    ElMessage.error('下载失败')
  }
}

async function handleDeployDialog(row) {
  deployTarget.id = row.id
  deployTarget.domain = row.domain
  deployForm.server_id = null
  deployForm.remote_path = ''
  deployForm.ssh_user = 'root'
  deployFilter.env_type = ''
  deployFilter.platform = ''
  selectedServer.value = null
  deployDialogVisible.value = true
  
  // 加载服务器列表
  if (serverList.value.length === 0) {
    try {
      const res = await getServers({ page: 1, page_size: 999 })
      serverList.value = res.data.items || res.data || []
    } catch (e) {
      ElMessage.error('获取服务器列表失败')
    }
  }
}

function handleDeployFilterChange() {
  // 筛选变化时清空已选服务器
  deployForm.server_id = null
  selectedServer.value = null
}

function handleServerChange(serverId) {
  selectedServer.value = serverList.value.find(s => s.id === serverId) || null
  // 如果服务器没有普通用户，自动选择系统用户
  if (selectedServer.value && !selectedServer.value.docker_user) {
    deployForm.ssh_user = 'root'
  }
}

async function handleDeploy() {
  if (!deployForm.server_id) {
    ElMessage.warning('请选择目标服务器')
    return
  }
  if (!deployForm.remote_path) {
    ElMessage.warning('请输入远程目录路径')
    return
  }
  
  deployLoading.value = true
  try {
    await deployCert(deployTarget.id, deployForm)
    ElMessage.success('部署成功')
    deployDialogVisible.value = false
  } catch (e) {
    ElMessage.error(e.response?.data?.message || '部署失败')
  } finally {
    deployLoading.value = false
  }
}

// 打开上传证书弹窗
function handleUploadCreateDialog() {
  Object.assign(uploadCreateForm, {
    certFile: null,
    keyFile: null,
    project_name: '',
    brand: '',
    cost: null,
    remark: ''
  })
  uploadCreateDialogVisible.value = true
}

// 上传证书并自动解析创建
async function handleUploadCreate() {
  // 手动验证
  if (!uploadCreateForm.certFile) {
    ElMessage.warning('请选择证书文件')
    return
  }
  if (!uploadCreateForm.project_name) {
    ElMessage.warning('请输入项目名称')
    return
  }
  
  uploadCreateLoading.value = true
  try {
    const formData = new FormData()
    formData.append('cert_file', uploadCreateForm.certFile)
    if (uploadCreateForm.keyFile) {
      formData.append('key_file', uploadCreateForm.keyFile)
    }
    formData.append('project_name', uploadCreateForm.project_name)
    if (uploadCreateForm.brand) {
      formData.append('brand', uploadCreateForm.brand)
    }
    if (uploadCreateForm.cost !== null && uploadCreateForm.cost !== undefined) {
      formData.append('cost', uploadCreateForm.cost)
    }
    if (uploadCreateForm.remark) {
      formData.append('remark', uploadCreateForm.remark)
    }
    
    const res = await uploadAndCreateCert(formData)
    ElMessage.success(`证书上传成功！域名: ${res.data.domain}, 剩余 ${res.data.remaining_days} 天`)
    uploadCreateDialogVisible.value = false
    fetchData()
  } catch (e) {
    ElMessage.error(e.response?.data?.message || '上传失败')
  } finally {
    uploadCreateLoading.value = false
  }
}

function formatDate(str) {
  if (!str) return '-'
  const date = new Date(str)
  if (isNaN(date.getTime())) return str
  return date.toLocaleDateString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' }).replace(/\//g, '-')
}

function formatDateTime(str) {
  if (!str) return '-'
  const date = new Date(str)
  if (isNaN(date.getTime())) return str
  const dateStr = date.toLocaleDateString('zh-CN', { year: 'numeric', month: '2-digit', day: '2-digit' }).replace(/\//g, '-')
  const timeStr = date.toLocaleTimeString('zh-CN', { hour: '2-digit', minute: '2-digit', hour12: false })
  return `${dateStr} ${timeStr}`
}

function getCertTypeLabel(type) {
  const map = {
    0: '自动检测',
    1: '手动录入',
    2: '阿里云证书'
  }
  return map[type] || '未知'
}

function getCertTypeTag(type) {
  const map = {
    0: 'primary',
    1: 'info',
    2: 'warning'
  }
  return map[type] || 'info'
}

function getEnvTagType(env) {
  const map = {
    '生产': 'danger',
    '测试': 'warning',
    '智慧环保': 'success',
    '水电集团': 'primary'
  }
  return map[env] || 'info'
}

function getDaysTagType(days) {
  if (days <= 0) return 'danger'
  if (days < 30) return 'danger'
  if (days < 90) return 'warning'
  return 'success'
}

function getStatusTagType(status) {
  const map = {
    '正常': 'success',
    '即将过期': 'warning',
    '已过期': 'danger'
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

.ssh-user-info {
  color: #909399;
  font-size: 12px;
  margin-left: 4px;
}

.text-muted {
  color: #c0c4cc;
}
</style>
