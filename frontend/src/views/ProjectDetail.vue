<template>
  <div class="page-container">
    <!-- 面包屑导航 -->
    <el-card class="breadcrumb-card">
      <div class="breadcrumb-wrapper">
        <el-breadcrumb separator="/">
          <el-breadcrumb-item>
            <el-link @click="$router.push('/projects')">项目管理</el-link>
          </el-breadcrumb-item>
          <el-breadcrumb-item>项目详情</el-breadcrumb-item>
        </el-breadcrumb>
        <el-button class="back-btn" @click="$router.push('/projects')">
          <el-icon><ArrowLeft /></el-icon>返回
        </el-button>
      </div>
    </el-card>

    <!-- 基本信息 -->
    <el-card class="info-card" v-loading="loading">
      <template #header>
        <div class="card-header">
          <el-icon><Folder /></el-icon>
          <span>项目基本信息</span>
        </div>
      </template>
      <el-descriptions :column="2" border v-if="project">
        <el-descriptions-item label="项目名称">{{ project.name }}</el-descriptions-item>
        <el-descriptions-item label="负责人">{{ project.owner || '-' }}</el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="getStatusTagType(project.status)">{{ project.status }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ project.created_at || '-' }}</el-descriptions-item>
        <el-descriptions-item label="描述" :span="2">{{ project.description || '-' }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">{{ project.remark || '-' }}</el-descriptions-item>
      </el-descriptions>
      <el-empty v-else description="暂无数据" />
    </el-card>

    <!-- 关联资源标签页 -->
    <el-card class="resources-card">
      <el-tabs v-model="activeTab" type="border-card">
        <!-- 服务器 Tab -->
        <el-tab-pane label="服务器" name="servers">
          <div class="tab-toolbar">
            <el-button type="primary" :icon="Plus" @click="handleBindServers">关联服务器</el-button>
          </div>
          <el-table :data="servers" stripe v-loading="loading">
            <el-table-column prop="hostname" label="主机名" min-width="150" show-overflow-tooltip>
              <template #default="{ row }">
                <el-link type="primary" @click="$router.push(`/servers/${row.id}`)">{{ row.hostname }}</el-link>
              </template>
            </el-table-column>
            <el-table-column prop="inner_ip" label="内网IP" min-width="120" />
            <el-table-column prop="env_type" label="环境类型" min-width="100">
              <template #default="{ row }">
                <el-tag :type="getEnvTagType(row.env_type)" size="small">{{ row.env_type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column label="操作" min-width="120" fixed="right">
              <template #default="{ row }">
                <el-button type="danger" size="small" @click="handleUnbindServer(row)">取消关联</el-button>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!servers.length && !loading" description="暂无关联服务器" />
        </el-tab-pane>

        <!-- 服务 Tab -->
        <el-tab-pane label="服务" name="services">
          <el-table :data="services" stripe v-loading="loading">
            <el-table-column prop="service_name" label="服务名称" min-width="150" show-overflow-tooltip />
            <el-table-column prop="category" label="分类" min-width="100" />
            <el-table-column prop="server_hostname" label="所在服务器" min-width="150" show-overflow-tooltip />
            <el-table-column prop="version" label="版本" min-width="100" />
            <el-table-column prop="inner_port" label="端口" min-width="80" align="center" />
            <el-table-column prop="mapped_port" label="映射端口" min-width="100" align="center" />
          </el-table>
          <el-empty v-if="!services.length && !loading" description="暂无关联服务" />
        </el-tab-pane>

        <!-- 域名 Tab -->
        <el-tab-pane label="域名" name="domains">
          <el-table :data="domains" stripe v-loading="loading">
            <el-table-column prop="domain" label="域名" min-width="200" show-overflow-tooltip />
            <el-table-column prop="expire_date" label="到期时间" min-width="120" />
            <el-table-column prop="status" label="状态" min-width="100">
              <template #default="{ row }">
                <el-tag :type="getDomainStatusType(row.status)" size="small">{{ getDomainStatusLabel(row.status) }}</el-tag>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!domains.length && !loading" description="暂无关联域名" />
        </el-tab-pane>

        <!-- 证书 Tab -->
        <el-tab-pane label="证书" name="certs">
          <el-table :data="certs" stripe v-loading="loading">
            <el-table-column prop="domain" label="域名" min-width="200" show-overflow-tooltip />
            <el-table-column prop="project_name" label="项目名" min-width="150" show-overflow-tooltip />
            <el-table-column prop="expire_date" label="到期时间" min-width="120" />
            <el-table-column prop="days_remaining" label="剩余天数" min-width="100">
              <template #default="{ row }">
                <el-tag :type="getDaysTagType(row.days_remaining)" size="small">{{ row.days_remaining }}天</el-tag>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!certs.length && !loading" description="暂无关联证书" />
        </el-tab-pane>

        <!-- 账号 Tab -->
        <el-tab-pane label="账号" name="accounts">
          <el-table :data="accounts" stripe v-loading="loading">
            <el-table-column prop="name" label="名称" min-width="150" show-overflow-tooltip />
            <el-table-column prop="unit" label="所属单位" min-width="150" show-overflow-tooltip />
            <el-table-column prop="access_url" label="访问地址" min-width="200" show-overflow-tooltip>
              <template #default="{ row }">
                <el-link v-if="row.access_url" type="primary" :href="row.access_url" target="_blank">{{ row.access_url }}</el-link>
                <span v-else>-</span>
              </template>
            </el-table-column>
            <el-table-column prop="username" label="用户名" min-width="120" />
            <el-table-column prop="password" label="密码" min-width="120">
              <template #default="{ row }">
                <PasswordDisplay :password="row.password" />
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!accounts.length && !loading" description="暂无关联账号" />
        </el-tab-pane>
      </el-tabs>
    </el-card>

    <!-- 关联服务器弹窗 -->
    <el-dialog v-model="bindDialogVisible" title="关联服务器" width="500px" destroy-on-close>
      <el-form label-width="80px">
        <el-form-item label="选择服务器">
          <el-select
            v-model="selectedServerIds"
            multiple
            filterable
            placeholder="请选择要关联的服务器"
            style="width: 100%"
          >
            <el-option
              v-for="server in availableServers"
              :key="server.id"
              :label="`${server.hostname} (${server.inner_ip})`"
              :value="server.id"
            />
          </el-select>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="bindDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleConfirmBind" :loading="bindLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Folder, ArrowLeft, Plus } from '@element-plus/icons-vue'
import { getProjectDetail, bindProjectServers, unbindProjectServer } from '../api/projects'
import { getServers } from '../api/servers'
import PasswordDisplay from '../components/PasswordDisplay.vue'

interface Project {
  id: number
  name: string
  owner: string
  status: string
  created_at: string
  description: string
  remark: string
}

interface Server {
  id: number
  hostname: string
  inner_ip: string
  env_type: string
}

interface Service {
  id: number
  service_name: string
  category: string
  server_hostname: string
  version: string
  inner_port: number
  mapped_port: number | null
}

interface Domain {
  id: number
  domain: string
  expire_date: string
  status: string
}

interface Cert {
  id: number
  domain: string
  project_name: string
  expire_date: string
  days_remaining: number
}

interface Account {
  id: number
  name: string
  unit: string
  access_url: string
  username: string
  password: string
}

const route = useRoute()
const loading = ref<boolean>(false)
const bindLoading = ref<boolean>(false)
const project = ref<Project | null>(null)
const servers = ref<Server[]>([])
const services = ref<Service[]>([])
const domains = ref<Domain[]>([])
const certs = ref<Cert[]>([])
const accounts = ref<Account[]>([])
const activeTab = ref<string>('servers')

// 关联服务器弹窗
const bindDialogVisible = ref<boolean>(false)
const availableServers = ref<Server[]>([])
const selectedServerIds = ref<number[]>([])

onMounted(() => {
  fetchData()
})

async function fetchData() {
  const id = route.params.id
  if (!id) return

  loading.value = true
  try {
    const res = await getProjectDetail(Number(id))
    const data = res.data || {}
    project.value = data.project || null
    servers.value = data.servers || []
    services.value = data.services || []
    domains.value = data.domains || []
    certs.value = data.certs || []
    accounts.value = data.accounts || []
  } finally {
    loading.value = false
  }
}

async function handleBindServers() {
  selectedServerIds.value = []
  try {
    const res = await getServers({ page: 1, page_size: 1000 })
    const allServers = res.data?.items || []
    // 过滤掉已关联的服务器
    const boundIds = servers.value.map((s) => s.id)
    availableServers.value = allServers.filter((s) => !boundIds.includes(s.id))
    bindDialogVisible.value = true
  } catch (e) {
    console.error('加载服务器列表失败', e)
    ElMessage.error('加载服务器列表失败')
  }
}

async function handleConfirmBind() {
  if (selectedServerIds.value.length === 0) {
    ElMessage.warning('请至少选择一个服务器')
    return
  }

  bindLoading.value = true
  try {
    const id = Number(route.params.id)
    await bindProjectServers(id, selectedServerIds.value)
    ElMessage.success('关联成功')
    bindDialogVisible.value = false
    fetchData()
  } finally {
    bindLoading.value = false
  }
}

function handleUnbindServer(row: Server) {
  ElMessageBox.confirm(`确定要取消关联服务器 "${row.hostname}" 吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    const id = Number(route.params.id)
    await unbindProjectServer(id, row.id)
    ElMessage.success('取消关联成功')
    fetchData()
  }).catch(() => {})
}

function getStatusTagType(status: string): 'success' | 'info' | 'warning' | 'danger' {
  const map: Record<string, 'success' | 'info' | 'warning' | 'danger'> = {
    '运行中': 'success',
    '已下线': 'info',
    '规划中': 'warning'
  }
  return map[status] || 'info'
}

function getEnvTagType(env: string): 'success' | 'info' | 'warning' | 'danger' | 'primary' {
  const map: Record<string, 'success' | 'info' | 'warning' | 'danger' | 'primary'> = {
    '生产': 'danger',
    '测试': 'warning',
    '智慧环保': 'success',
    '水电集团': 'primary'
  }
  return map[env] || 'info'
}

function getDaysTagType(days: number): 'success' | 'warning' | 'danger' {
  if (days <= 7) return 'danger'
  if (days <= 30) return 'warning'
  return 'success'
}

function getDomainStatusLabel(status: string | number): string {
  const map: Record<string, string> = {
    '1': '域名未过期',
    '2': '域名已过期',
    '3': '正常',
    '域名未过期': '域名未过期',
    '域名已过期': '域名已过期',
    '正常': '正常'
  }
  return map[String(status)] || String(status)
}

function getDomainStatusType(status: string | number): 'success' | 'warning' | 'danger' | 'info' {
  const map: Record<string, 'success' | 'warning' | 'danger' | 'info'> = {
    '1': 'success',
    '2': 'danger',
    '3': 'success',
    '域名未过期': 'success',
    '域名已过期': 'danger',
    '正常': 'success'
  }
  return map[String(status)] || 'info'
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

.resources-card {
  margin-bottom: 0;
}

.tab-toolbar {
  margin-bottom: 16px;
}
</style>
