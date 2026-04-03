<template>
  <div class="dashboard-container">
    <!-- 统计卡片 - 一行6个 -->
    <el-row :gutter="16" class="stat-row">
      <el-col :xs="24" :sm="12" :md="4" :lg="4" class="stat-col">
        <div class="stat-card blue-gradient" @click="$router.push('/servers')">
          <el-icon :size="40" class="stat-icon"><Monitor /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.servers || 0 }}</div>
            <div class="stat-label">服务器</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="4" :lg="4" class="stat-col">
        <div class="stat-card green-gradient" @click="$router.push('/services')">
          <el-icon :size="40" class="stat-icon"><SetUp /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.services || 0 }}</div>
            <div class="stat-label">服务</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="4" :lg="4" class="stat-col">
        <div class="stat-card purple-gradient" @click="$router.push('/apps')">
          <el-icon :size="40" class="stat-icon"><Grid /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.apps || 0 }}</div>
            <div class="stat-label">应用系统</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="4" :lg="4" class="stat-col">
        <div class="stat-card red-gradient" @click="$router.push('/domains')">
          <el-icon :size="40" class="stat-icon"><Link /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.domains || 0 }}</div>
            <div class="stat-label">域名</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="4" :lg="4" class="stat-col">
        <div class="stat-card orange-gradient" @click="$router.push('/certs')">
          <el-icon :size="40" class="stat-icon"><Document /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.certs || 0 }}</div>
            <div class="stat-label">SSL证书</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="4" :lg="4" class="stat-col">
        <div class="stat-card danger-gradient" @click="$router.push('/certs')">
          <el-icon :size="40" class="stat-icon"><Warning /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.expiring_certs || 0 }}</div>
            <div class="stat-label">即将过期证书</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 到期提醒（全宽） -->
    <el-card class="table-card expiry-card">
      <template #header>
        <div class="card-header">
          <el-icon><Timer /></el-icon>
          <span>域名/证书到期提醒</span>
        </div>
      </template>
      <el-table :data="stats.recent_certs || []" stripe v-loading="loading">
        <el-table-column prop="domain" label="域名" min-width="180" show-overflow-tooltip />
        <el-table-column prop="project_name" label="项目" min-width="150" show-overflow-tooltip />
        <el-table-column prop="cert_expire_time" label="到期时间" min-width="120">
          <template #default="{ row }">
            {{ row.cert_expire_time ? row.cert_expire_time.substring(0, 10) : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="remaining_days" label="剩余天数" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getDaysTagType(row.remaining_days)" size="small">
              {{ row.remaining_days }}天
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="类型" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag type="info" size="small">{{ row.type === 'domain' ? '域名' : '证书' }}</el-tag>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!stats.recent_certs?.length" description="暂无到期提醒" />
    </el-card>

    <!-- 服务器环境分布 -->
    <el-card class="table-card env-card">
      <template #header>
        <div class="card-header">
          <el-icon><Monitor /></el-icon>
          <span>服务器环境分布</span>
        </div>
      </template>
      <div class="env-distribution">
        <div v-for="item in stats.env_distribution || []" :key="item.env_type" class="env-item">
          <div class="env-header">
            <el-tag :type="getEnvTagType(item.env_type)" size="large">{{ item.env_type }}</el-tag>
            <span class="env-count">{{ item.count }} 台</span>
          </div>
          <el-progress 
            :percentage="getPercentage(item.count)" 
            :color="getProgressColor(item.env_type)"
            :stroke-width="12"
          />
        </div>
      </div>
      <el-empty v-if="!stats.env_distribution?.length" description="暂无服务器数据" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { Monitor, SetUp, Grid, Document, Timer, Link, Warning } from '@element-plus/icons-vue'
import { getDashboardStats } from '../api/dashboard'

const loading = ref(false)

/**
 * @typedef {Object} Counts
 * @property {number} [servers]
 * @property {number} [services]
 * @property {number} [apps]
 * @property {number} [domains]
 * @property {number} [certs]
 * @property {number} [expiring_certs]
 */

/**
 * @typedef {Object} EnvDistributionItem
 * @property {string} env_type
 * @property {number} count
 */

/**
 * @typedef {Object} RecentCertItem
 * @property {string} [domain]
 * @property {string} [project_name]
 * @property {string} [cert_expire_time]
 * @property {number} [remaining_days]
 * @property {string} [type]
 */

/**
 * @typedef {Object} Stats
 * @property {Counts} counts
 * @property {EnvDistributionItem[]} env_distribution
 * @property {RecentCertItem[]} recent_certs
 */

/** @type {Stats} */
const stats = reactive({
  counts: {
    servers: 0,
    services: 0,
    apps: 0,
    domains: 0,
    certs: 0,
    expiring_certs: 0
  },
  env_distribution: [],
  recent_certs: []
})

const totalServers = computed(() => {
  return stats.env_distribution?.reduce((sum, item) => sum + item.count, 0) || 0
})

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getDashboardStats()
    Object.assign(stats, res.data)
  } finally {
    loading.value = false
  }
}

/**
 * @param {any} env
 */
function getEnvTagType(env) {
  /** @type {Record<string, string>} */
  const map = {
    '生产': 'danger',
    '测试': 'warning',
    '智慧环保': 'success',
    '水电集团': 'primary'
  }
  return map[env] || 'info'
}

/**
 * @param {any} env
 */
function getProgressColor(env) {
  /** @type {Record<string, string>} */
  const map = {
    '生产': '#f56c6c',
    '测试': '#e6a23c',
    '智慧环保': '#67c23a',
    '水电集团': '#409eff'
  }
  return map[env] || '#909399'
}

/**
 * @param {any} count
 */
function getPercentage(count) {
  if (!totalServers.value) return 0
  return Math.round((count / totalServers.value) * 100)
}

/**
 * @param {any} days
 */
function getDaysTagType(days) {
  if (days < 30) return 'danger'
  if (days < 90) return 'warning'
  return 'success'
}
</script>

<style scoped>
.dashboard-container {
  padding: 20px;
}

.stat-row {
  margin-bottom: 16px;
  display: flex;
  flex-wrap: wrap;
}

.stat-col {
  margin-bottom: 12px;
}

.stat-card {
  border-radius: 12px;
  padding: 20px;
  color: #fff;
  position: relative;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
  display: flex;
  align-items: center;
  gap: 12px;
  height: 80px;
}

.stat-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.15);
}

.stat-card::before {
  content: '';
  position: absolute;
  top: -50%;
  right: -50%;
  width: 100%;
  height: 100%;
  background: radial-gradient(circle, rgba(255,255,255,0.15) 0%, transparent 70%);
  pointer-events: none;
}

.blue-gradient {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.green-gradient {
  background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
}

.orange-gradient {
  background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
}

.purple-gradient {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.red-gradient {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.cyan-gradient {
  background: linear-gradient(135deg, #30cfd0 0%, #330867 100%);
}

.danger-gradient {
  background: linear-gradient(135deg, #ff416c 0%, #ff4b2b 100%);
}

.stat-icon {
  opacity: 0.9;
}

.stat-info {
  flex: 1;
}

.stat-value {
  font-size: 28px;
  font-weight: bold;
  line-height: 1.2;
}

.stat-label {
  font-size: 14px;
  opacity: 0.9;
  margin-top: 4px;
}

.table-card {
  margin-bottom: 16px;
}

.table-card :deep(.el-card__header) {
  padding: 15px 20px;
  border-bottom: 1px solid #ebeef5;
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

/* 环境分布卡片样式 */
.env-card {
  margin-bottom: 0;
}

.env-distribution {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(280px, 1fr));
  gap: 20px;
  padding: 10px 0;
}

.env-item {
  padding: 16px;
  background: #f8f9fa;
  border-radius: 8px;
}

.env-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 12px;
}

.env-count {
  font-size: 18px;
  font-weight: 600;
  color: #606266;
}

/* 到期提醒卡片样式 */
.expiry-card {
  margin-bottom: 16px;
}
</style>
