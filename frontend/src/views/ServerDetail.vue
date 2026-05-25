<template>
  <div class="page-container">
    <!-- 面包屑导航 -->
    <el-card class="breadcrumb-card">
      <div class="breadcrumb-wrapper">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item>
            <el-link @click="$router.push('/servers')">服务器管理</el-link>
          </el-breadcrumb-item>
          <el-breadcrumb-item>服务器详情</el-breadcrumb-item>
        </el-breadcrumb>
        <el-button class="back-btn" @click="$router.push({ path: '/servers', query: $route.query })">
          <el-icon><ArrowLeft /></el-icon>返回
        </el-button>
      </div>
    </el-card>

    <!-- 基本信息 -->
    <el-card class="info-card" v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-icon><Monitor /></el-icon>
          <span>服务器基本信息</span>
        </div>
      </template>
      <el-descriptions :column="2" border v-if="server">
        <el-descriptions-item label="环境类型">
          <el-tag :type="getEnvTagType(server.env_type)">{{ server.env_type }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="平台">{{ server.platform || '-' }}</el-descriptions-item>
        <el-descriptions-item label="主机名">{{ server.hostname }}</el-descriptions-item>
        <el-descriptions-item label="内网IP">{{ server.inner_ip }}</el-descriptions-item>
        <el-descriptions-item label="映射IP">{{ server.mapped_ip || '-' }}</el-descriptions-item>
        <el-descriptions-item label="公网IP">{{ server.public_ip || '-' }}</el-descriptions-item>
        <el-descriptions-item label="CPU">{{ server.cpu || '-' }}</el-descriptions-item>
        <el-descriptions-item label="内存">{{ server.memory || '-' }}</el-descriptions-item>
        <el-descriptions-item label="系统盘">{{ server.sys_disk || '-' }}</el-descriptions-item>
        <el-descriptions-item label="数据盘">{{ server.data_disk || '-' }}</el-descriptions-item>
        <el-descriptions-item label="用途" :span="2">{{ server.purpose || '-' }}</el-descriptions-item>
        <el-descriptions-item label="系统用户">{{ server.os_user || 'root' }}</el-descriptions-item>
        <el-descriptions-item label="系统密码">
          <PasswordDisplay :password="server.os_password" />
        </el-descriptions-item>
        <el-descriptions-item label="普通用户">{{ server.regular_user || '-' }}</el-descriptions-item>
        <el-descriptions-item label="普通用户密码">
          <PasswordDisplay :password="server.regular_password" />
        </el-descriptions-item>
        <el-descriptions-item label="定期更新密码">
          <el-tag v-if="server.password_rotation_enabled" type="success" size="small">已启用</el-tag>
          <span v-else style="color: #909399;">未启用</span>
        </el-descriptions-item>
        <el-descriptions-item label="更新周期">
          {{ server.password_rotation_enabled ? server.password_rotation_days + ' 天' : '-' }}
        </el-descriptions-item>
        <el-descriptions-item label="上次更新时间">
          {{ server.password_last_rotated_at || '未更新' }}
        </el-descriptions-item>
        <el-descriptions-item label="轮换状态">
          <el-tag :type="getRotationStatusType(server.password_rotation_status || 'idle')" size="small">
            {{ getRotationStatusText(server.password_rotation_status || 'idle') }}
          </el-tag>
          <span v-if="server.password_rotation_error" style="color: #f56c6c; margin-left: 8px; font-size: 12px;">
            {{ server.password_rotation_error }}
          </span>
        </el-descriptions-item>
        <el-descriptions-item label="操作" :span="2">
          <el-button v-if="canEdit" type="primary" size="small" @click="handleEdit">编辑</el-button>
          <el-button type="warning" size="small" @click="handleManualRotate">手动更新密码</el-button>
        </el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ server.remark || '-' }}</el-descriptions-item>
      </el-descriptions>
      <el-empty v-else description="暂无数据" />
    </el-card>

    <!-- 关联项目 -->
    <el-card class="projects-card">
      <template #header>
        <div class="card-header">
          <el-icon><Folder /></el-icon>
          <span>关联项目</span>
          <el-tag type="info" size="small" style="margin-left: 10px;">{{ projects.length }}个项目</el-tag>
        </div>
      </template>
      <div v-if="projects.length" class="project-tags">
        <el-tag
          v-for="p in projects"
          :key="p.id"
          class="project-tag"
          @click="$router.push(`/projects/${p.id}`)"
        >
          {{ p.project_name }}
        </el-tag>
      </div>
      <el-empty v-else description="暂无关联项目" :image-size="60" />
    </el-card>
    
    <!-- 关联服务列表 -->
    <el-card class="services-card">
      <template #header>
        <div class="card-header">
          <el-icon><SetUp /></el-icon>
          <span>关联服务列表</span>
          <el-tag type="info" size="small" style="margin-left: 10px;">{{ services.length }}个服务</el-tag>
        </div>
      </template>
      <el-table :data="services" stripe v-loading="loading">
        <el-table-column prop="category" label="分类" min-width="100" />
        <el-table-column prop="service_name" label="服务名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="version" label="版本" min-width="100" />
        <el-table-column prop="inner_port" label="内部端口" min-width="100" align="center" />
        <el-table-column prop="mapped_port" label="映射端口" min-width="100" align="center" />
        <el-table-column prop="remark" label="备注" min-width="200" show-overflow-tooltip />
      </el-table>
      <el-empty v-if="!services.length && !loading" description="暂无关联服务" />
    </el-card>

    <!-- 编辑服务器弹窗 -->
    <el-dialog v-model="editDialogVisible" title="编辑服务器" width="700px" destroy-on-close>
      <el-form ref="editFormRef" :model="editForm" :rules="editRules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="环境类型" prop="env_type">
              <el-select v-model="editForm.env_type" placeholder="请选择" style="width: 100%">
                <el-option v-for="item in envTypes" :key="item.id" :label="item.name" :value="item.name" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="平台" prop="platform">
              <el-select v-model="editForm.platform" placeholder="请选择" style="width: 100%">
                <el-option v-for="item in platforms" :key="item.id" :label="item.name" :value="item.name" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="主机名" prop="hostname">
              <el-input v-model="editForm.hostname" placeholder="请输入主机名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内网IP" prop="inner_ip">
              <el-input v-model="editForm.inner_ip" placeholder="请输入内网IP" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="映射IP" prop="mapped_ip">
              <el-input v-model="editForm.mapped_ip" placeholder="请输入映射IP" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="公网IP" prop="public_ip">
              <el-input v-model="editForm.public_ip" placeholder="请输入公网IP" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="CPU" prop="cpu">
              <el-input v-model="editForm.cpu" placeholder="如：8核" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内存" prop="memory">
              <el-input v-model="editForm.memory" placeholder="如：16GB" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统盘" prop="sys_disk">
              <el-input v-model="editForm.sys_disk" placeholder="如：100GB" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="数据盘" prop="data_disk">
              <el-input v-model="editForm.data_disk" placeholder="如：500GB" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="用途" prop="purpose">
          <el-input v-model="editForm.purpose" type="textarea" :rows="2" placeholder="请输入用途" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统用户" prop="os_user">
              <el-input v-model="editForm.os_user" placeholder="如：root" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="系统密码" prop="os_password">
              <el-input v-model="editForm.os_password" type="password" show-password placeholder="请输入系统密码" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="普通用户" prop="regular_user">
              <el-input v-model="editForm.regular_user" placeholder="如：docker（可选）" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="普通用户密码" prop="regular_password">
              <el-input v-model="editForm.regular_password" type="password" show-password placeholder="普通用户密码（可选）" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="证书路径" prop="cert_path">
          <el-input v-model="editForm.cert_path" placeholder="/etc/nginx/ssl/" />
        </el-form-item>
        <el-form-item label="所属项目">
          <el-select v-model="editForm.project_ids" multiple placeholder="请选择所属项目" style="width: 100%">
            <el-option v-for="p in projectList" :key="p.id" :label="p.name" :value="p.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="editForm.remark" type="textarea" :rows="2" placeholder="请输入备注" />
        </el-form-item>
        <el-divider content-position="left">密码定期更新</el-divider>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="定期更新密码">
              <el-switch v-model="editForm.password_rotation_enabled" active-text="启用" inactive-text="关闭" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="更新周期(天)" prop="password_rotation_days" v-if="editForm.password_rotation_enabled">
              <el-input-number 
                v-model="editForm.password_rotation_days" 
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
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleEditSubmit" :loading="editSubmitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { Monitor, SetUp, ArrowLeft, Folder, Edit } from '@element-plus/icons-vue'
import { getServerDetail, updateServer, triggerPasswordRotation } from '../api/servers'
import { getEnvTypes, getPlatforms } from '../api/dicts'
import { getProjectOptions } from '../api/projects'
import { useUserStore } from '../stores/user'
import PasswordDisplay from '../components/PasswordDisplay.vue'
import { ElMessage, ElMessageBox } from 'element-plus'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { ipValidator, safeText, maxLength } from '@/utils/validators'

const route = useRoute()
const userStore = useUserStore()
const loading = ref<boolean>(false)

// 权限控制：admin 和 operator 可以编辑
const canEdit = computed(() => userStore.isAdmin || userStore.userInfo.role === 'operator')
const server = ref<any>(null)
const services = ref<any[]>([])
const projects = ref<any[]>([])

// 编辑对话框
const editDialogVisible = ref<boolean>(false)
const editSubmitLoading = ref<boolean>(false)
const editFormRef = ref<any>(null)
const envTypes = ref<any[]>([])
const platforms = ref<any[]>([])
const projectList = ref<any[]>([])

const editForm = reactive({
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

const editRules = {
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
  mapped_ip: [{ validator: ipValidator, trigger: 'blur' }],
  public_ip: [{ validator: ipValidator, trigger: 'blur' }],
  cpu: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(50), trigger: 'blur' }],
  memory: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(50), trigger: 'blur' }],
  sys_disk: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(50), trigger: 'blur' }],
  data_disk: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(50), trigger: 'blur' }],
  purpose: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(500), trigger: 'blur' }],
  os_user: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(100), trigger: 'blur' }],
  os_password: [{ validator: maxLength(200), trigger: 'blur' }],
  regular_user: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(100), trigger: 'blur' }],
  regular_password: [{ validator: maxLength(200), trigger: 'blur' }],
  cert_path: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(500), trigger: 'blur' }],
  remark: [{ validator: safeText, trigger: 'blur' }, { validator: maxLength(500), trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
  fetchDicts()
  fetchProjects()
})

async function fetchDicts() {
  try {
    const [envRes, platformRes] = await Promise.all([getEnvTypes(), getPlatforms()])
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
  const rawId = route.params.id
  const id = Array.isArray(rawId) ? rawId[0] : rawId
  if (!id) return
  
  loading.value = true
  try {
    const res = await getServerDetail(id)
    server.value = res.data?.server || null
    services.value = res.data?.services || []
    projects.value = res.data?.projects || []
  } finally {
    loading.value = false
  }
}

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

async function handleManualRotate() {
  if (!server.value) return
  try {
    await ElMessageBox.confirm(
      `确定要立即更新服务器 "${server.value.hostname}" 的登录密码吗？更新过程中请勿进行其他操作。`,
      '确认密码更新',
      {
        type: 'warning',
        confirmButtonText: '确定更新',
        cancelButtonText: '取消'
      }
    )
    await triggerPasswordRotation(server.value.id)
    ElMessage.success('密码更新任务已提交，请稍后刷新查看结果')
    fetchData()
  } catch (e: any) {
    if (e !== 'cancel' && e !== 'close') {
      ElMessage.error(e?.response?.data?.message || '触发密码更新失败')
    }
  }
}

function handleEdit() {
  if (!server.value) return
  Object.assign(editForm, {
    env_type: server.value.env_type || '',
    platform: server.value.platform || '',
    hostname: server.value.hostname || '',
    inner_ip: server.value.inner_ip || '',
    mapped_ip: server.value.mapped_ip || '',
    public_ip: server.value.public_ip || '',
    cpu: server.value.cpu || '',
    memory: server.value.memory || '',
    sys_disk: server.value.sys_disk || '',
    data_disk: server.value.data_disk || '',
    purpose: server.value.purpose || '',
    os_user: server.value.os_user || '',
    os_password: server.value.os_password || '',
    regular_user: server.value.regular_user || '',
    regular_password: server.value.regular_password || '',
    cert_path: server.value.cert_path || '',
    remark: server.value.remark || '',
    project_ids: server.value.project_ids || [],
    password_rotation_enabled: !!server.value.password_rotation_enabled,
    password_rotation_days: server.value.password_rotation_days || 30
  })
  editDialogVisible.value = true
}

async function handleEditSubmit() {
  if (!server.value) return
  const valid = await editFormRef.value?.validate().catch(() => false)
  if (!valid) return
  
  editSubmitLoading.value = true
  try {
    await updateServer(server.value.id, editForm)
    ElMessage.success('更新成功')
    editDialogVisible.value = false
    fetchData()
  } finally {
    editSubmitLoading.value = false
  }
}
</script>

<style scoped>
.page-container {
  padding: 20px;
}

.breadcrumb-card {
  margin-bottom: 20px;
}

.breadcrumb-wrapper {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.back-btn {
  display: flex;
  align-items: center;
  gap: 4px;
}

.info-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
  color: #303133;
}

.card-header .el-icon {
  color: #409eff;
}

.projects-card {
  margin-bottom: 20px;
}

.project-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
}

.project-tag {
  cursor: pointer;
  transition: transform 0.1s;
}

.project-tag:hover {
  transform: scale(1.05);
}

.services-card {
  margin-bottom: 0;
}
</style>
