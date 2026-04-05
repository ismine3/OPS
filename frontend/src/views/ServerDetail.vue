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
        <el-button class="back-btn" @click="$router.push('/servers')">
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
        <el-descriptions-item label="普通用户">{{ server.docker_user || '-' }}</el-descriptions-item>
        <el-descriptions-item label="普通用户密码">
          <PasswordDisplay :password="server.docker_password" />
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
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { useRoute } from 'vue-router'
import { Monitor, SetUp, ArrowLeft, Folder } from '@element-plus/icons-vue'
import { getServerDetail } from '../api/servers'
import PasswordDisplay from '../components/PasswordDisplay.vue'

const route = useRoute()
const loading = ref<boolean>(false)
const server = ref<any>(null)
const services = ref<any[]>([])
const projects = ref<any[]>([])

onMounted(() => {
  fetchData()
})

async function fetchData() {
  const id = route.params.id
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

/**
 * @param {any} env
 */
function getEnvTagType(env: any) {
  /** @type {Record<string, string>} */
  const map = {
    '生产': 'danger',
    '测试': 'warning',
    '智慧环保': 'success',
    '水电集团': 'primary'
  }
  return map[env] || 'info'
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
