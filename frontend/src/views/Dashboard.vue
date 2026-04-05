<template>
  <div class="dashboard-container">
    <!-- 第一行：4个核心数据概览卡片 -->
    <el-row :gutter="16" class="stat-row">
      <el-col :xs="12" :sm="12" class="stat-col">
        <div class="stat-card blue-gradient" @click="$router.push('/servers')">
          <el-icon :size="40" class="stat-icon"><Monitor /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.servers || 0 }}</div>
            <div class="stat-label">服务器</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" class="stat-col">
        <div class="stat-card teal-gradient" @click="$router.push('/projects')">
          <el-icon :size="40" class="stat-icon"><Folder /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.projects || 0 }}</div>
            <div class="stat-label">项目</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" class="stat-col">
        <div class="stat-card green-gradient" @click="$router.push('/services')">
          <el-icon :size="40" class="stat-icon"><SetUp /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.services || 0 }}</div>
            <div class="stat-label">服务</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" class="stat-col">
        <div class="stat-card purple-gradient" @click="$router.push('/accounts')">
          <el-icon :size="40" class="stat-icon"><Grid /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.accounts || 0 }}</div>
            <div class="stat-label">账号管理</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="12" :sm="12" class="stat-col">
        <div class="stat-card red-gradient" @click="$router.push('/domains')">
          <el-icon :size="40" class="stat-icon"><Link /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.domains || 0 }}</div>
            <div class="stat-label">域名</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 第二行：3个饼图并排 -->
    <el-row :gutter="16" class="chart-row">
      <el-col :xs="24" :sm="24" :md="6" :lg="6">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <el-icon><Monitor /></el-icon>
              <span>服务器环境占比</span>
            </div>
          </template>
          <div ref="envChartRef" class="chart-container"></div>
          <el-empty v-if="!stats.env_distribution?.length" description="暂无服务器数据" />
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="24" :md="6" :lg="6">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <el-icon><SetUp /></el-icon>
              <span>服务类型占比</span>
            </div>
          </template>
          <div ref="serviceChartRef" class="chart-container"></div>
          <el-empty v-if="!stats.service_distribution?.length" description="暂无服务数据" />
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="24" :md="6" :lg="6">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <el-icon><Grid /></el-icon>
              <span>账号类型占比</span>
            </div>
          </template>
          <div ref="accountChartRef" class="chart-container"></div>
          <el-empty v-if="!stats.account_distribution?.length" description="暂无账号数据" />
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="24" :md="6" :lg="6">
        <el-card class="chart-card">
          <template #header>
            <div class="card-header">
              <el-icon><Folder /></el-icon>
              <span>项目服务器占比</span>
            </div>
          </template>
          <div ref="projectChartRef" class="chart-container"></div>
          <el-empty v-if="!stats.project_distribution?.length" description="暂无项目数据" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 第三行：证书概览 + 到期提醒 -->
    <el-row :gutter="16" class="cert-row">
      <el-col :span="6" :xs="24" :sm="24" :md="6" :lg="6">
        <el-card class="cert-summary-card" @click="$router.push('/certs')">
          <div class="cert-summary-content">
            <div class="cert-stat-item">
              <el-icon :size="32" class="cert-icon"><Document /></el-icon>
              <div class="cert-stat-info">
                <div class="cert-stat-value">{{ stats.counts?.certs || 0 }}</div>
                <div class="cert-stat-label">SSL证书总数</div>
              </div>
            </div>
            <el-divider />
            <div class="cert-stat-item expiring">
              <el-icon :size="32" class="cert-icon warning"><Warning /></el-icon>
              <div class="cert-stat-info">
                <div class="cert-stat-value warning">{{ stats.counts?.expiring_certs || 0 }}</div>
                <div class="cert-stat-label">即将过期</div>
              </div>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="18" :xs="24" :sm="24" :md="18" :lg="18">
        <el-card class="table-card expiry-card">
          <template #header>
            <div class="card-header">
              <el-icon><Timer /></el-icon>
              <span>域名/证书到期提醒</span>
            </div>
          </template>
          <el-table :data="stats.recent_certs || []" stripe v-loading="loading" height="280">
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
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onUnmounted, nextTick } from 'vue'
import { Monitor, SetUp, Grid, Document, Timer, Link, Warning, Folder } from '@element-plus/icons-vue'
import { getDashboardStats } from '../api/dashboard'
import * as echarts from 'echarts'

const loading = ref<boolean>(false)

/**
 * @typedef {Object} Counts
 * @property {number} [servers]
 * @property {number} [services]
 * @property {number} [accounts]
 * @property {number} [domains]
 * @property {number} [certs]
 * @property {number} [expiring_certs]
 * @property {number} [projects]
 */

/**
 * @typedef {Object} EnvDistributionItem
 * @property {string} env_type
 * @property {number} count
 */

/**
 * @typedef {Object} ServiceDistributionItem
 * @property {string} category
 * @property {number} count
 */

/**
 * @typedef {Object} AccountDistributionItem
 * @property {string} name
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
 * @property {ServiceDistributionItem[]} service_distribution
 * @property {AccountDistributionItem[]} account_distribution
 * @property {RecentCertItem[]} recent_certs
 */

const stats = reactive({
  counts: {
    servers: 0,
    services: 0,
    accounts: 0,
    domains: 0,
    certs: 0,
    expiring_certs: 0,
    projects: 0
  },
  env_distribution: [] as any[],
  service_distribution: [] as any[],
  account_distribution: [] as any[],
  project_distribution: [] as any[],
  recent_certs: [] as any[]
})

// ECharts 相关
const envChartRef = ref<any>(null)
const serviceChartRef = ref<any>(null)
const accountChartRef = ref<any>(null)
const projectChartRef = ref<any>(null)
let envChart: any = null
let serviceChart: any = null
let accountChart: any = null
let projectChart: any = null

// 环境类型颜色映射
const envColorMap: Record<string, string> = {
  '生产': '#f56c6c',
  '测试': '#e6a23c',
  '智慧环保': '#67c23a',
  '水电集团': '#409eff'
}

// 服务分类配色方案
const serviceColorPalette = [
  '#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de',
  '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc', '#ff9f7f'
]

// 账号分类配色方案
const accountColorPalette = [
  '#36a2eb', '#ff6384', '#ffce56', '#4bc0c0', '#9966ff',
  '#ff9f40', '#c9cbcf', '#7bc8a4', '#e7846e', '#6c8ebf'
]

// 项目分布配色方案
const projectColorPalette = [
  '#5470c6', '#91cc75', '#fac858', '#ee6666', '#73c0de',
  '#3ba272', '#fc8452', '#9a60b4', '#ea7ccc', '#ff9f7f'
]

onMounted(() => {
  fetchData()
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  window.removeEventListener('resize', handleResize)
  envChart?.dispose()
  serviceChart?.dispose()
  accountChart?.dispose()
  projectChart?.dispose()
})

function handleResize() {
  envChart?.resize()
  serviceChart?.resize()
  accountChart?.resize()
  projectChart?.resize()
}

async function fetchData() {
  loading.value = true
  try {
    const res = await getDashboardStats()
    Object.assign(stats, res.data)
    // 数据加载完成后初始化图表
    await nextTick()
    initCharts()
  } finally {
    loading.value = false
  }
}

function initCharts() {
  initEnvChart()
  initServiceChart()
  initAccountChart()
  initProjectChart()
}

function initEnvChart() {
  if (!envChartRef.value || !stats.env_distribution?.length) return
  
  if (envChart) {
    envChart.dispose()
  }
  
  envChart = echarts.init(envChartRef.value)
  
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c}台 ({d}%)'
    },
    legend: {
      bottom: '0',
      type: 'scroll',
      itemWidth: 12,
      itemHeight: 12,
      textStyle: {
        fontSize: 12
      }
    },
    color: stats.env_distribution.map(item => envColorMap[item.env_type] || '#909399'),
    series: [
      {
        type: 'pie',
        radius: ['0%', '65%'],
        center: ['50%', '40%'],
        selectedMode: 'single',
        selectedOffset: 15,
        avoidLabelOverlap: true,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}\n{d}%',
          fontSize: 10,
          overflow: 'break',
          width: 80
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 13,
            fontWeight: 'bold'
          }
        },
        data: stats.env_distribution.map(item => ({
          name: item.env_type,
          value: item.count
        }))
      }
    ]
  }
  
  envChart.setOption(option)
}

function initServiceChart() {
  if (!serviceChartRef.value || !stats.service_distribution?.length) return
  
  if (serviceChart) {
    serviceChart.dispose()
  }
  
  serviceChart = echarts.init(serviceChartRef.value)
  
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c}个 ({d}%)'
    },
    legend: {
      bottom: '0',
      type: 'scroll',
      itemWidth: 12,
      itemHeight: 12,
      textStyle: {
        fontSize: 12
      }
    },
    color: serviceColorPalette,
    series: [
      {
        type: 'pie',
        radius: ['0%', '65%'],
        center: ['50%', '40%'],
        selectedMode: 'single',
        selectedOffset: 15,
        avoidLabelOverlap: true,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}\n{d}%',
          fontSize: 10,
          overflow: 'break',
          width: 80
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 13,
            fontWeight: 'bold'
          }
        },
        data: stats.service_distribution.map(item => ({
          name: item.category,
          value: item.count
        }))
      }
    ]
  }
  
  serviceChart.setOption(option)
}

function initAccountChart() {
  if (!accountChartRef.value || !stats.account_distribution?.length) return
  
  if (accountChart) {
    accountChart.dispose()
  }
  
  accountChart = echarts.init(accountChartRef.value)
  
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c}个 ({d}%)'
    },
    legend: {
      bottom: '0',
      type: 'scroll',
      itemWidth: 12,
      itemHeight: 12,
      textStyle: {
        fontSize: 12
      }
    },
    color: accountColorPalette,
    series: [
      {
        type: 'pie',
        radius: ['0%', '65%'],
        center: ['50%', '40%'],
        selectedMode: 'single',
        selectedOffset: 15,
        avoidLabelOverlap: true,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}\n{d}%',
          fontSize: 10,
          overflow: 'break',
          width: 80
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 13,
            fontWeight: 'bold'
          }
        },
        data: stats.account_distribution.map(item => ({
          name: item.name,
          value: item.count
        }))
      }
    ]
  }
  
  accountChart.setOption(option)
}

function initProjectChart() {
  if (!projectChartRef.value || !stats.project_distribution?.length) return

  if (projectChart) {
    projectChart.dispose()
  }

  projectChart = echarts.init(projectChartRef.value)

  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c}个 ({d}%)'
    },
    legend: {
      bottom: '0',
      type: 'scroll',
      itemWidth: 12,
      itemHeight: 12,
      textStyle: {
        fontSize: 12
      }
    },
    color: projectColorPalette,
    series: [
      {
        type: 'pie',
        radius: ['0%', '65%'],
        center: ['50%', '40%'],
        selectedMode: 'single',
        selectedOffset: 15,
        avoidLabelOverlap: true,
        itemStyle: {
          borderRadius: 6,
          borderColor: '#fff',
          borderWidth: 2
        },
        label: {
          show: true,
          formatter: '{b}\n{d}%',
          fontSize: 10,
          overflow: 'break',
          width: 80
        },
        emphasis: {
          label: {
            show: true,
            fontSize: 13,
            fontWeight: 'bold'
          }
        },
        data: stats.project_distribution.map((item: any) => ({
          name: item.project_name,
          value: item.count
        }))
      }
    ]
  }

  projectChart.setOption(option)
}

/**
 * @param {any} days
 */
function getDaysTagType(days: any) {
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

.stat-row > .el-col {
  flex: 0 0 20%;
  max-width: 20%;
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
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
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

.purple-gradient {
  background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
}

.red-gradient {
  background: linear-gradient(135deg, #fa709a 0%, #fee140 100%);
}

.teal-gradient {
  background: linear-gradient(135deg, #2193b0 0%, #6dd5ed 100%);
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

/* 图表行样式 */
.chart-row {
  margin-bottom: 16px;
  display: flex;
  flex-wrap: wrap;
}

.chart-row > .el-col {
  display: flex;
  margin-bottom: 16px;
}

.chart-card {
  height: 100%;
  width: 100%;
  display: flex;
  flex-direction: column;
}

.chart-card :deep(.el-card__body) {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chart-container {
  min-height: 360px;
  height: 360px;
  width: 100%;
}

/* 证书区域样式 */
.cert-row {
  margin-bottom: 0;
}

.cert-row :deep(.el-col) {
  margin-bottom: 16px;
}

/* 证书统计卡片样式 */
.cert-summary-card {
  height: 100%;
  min-height: 350px;
  cursor: pointer;
  transition: transform 0.3s, box-shadow 0.3s;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  border: none;
  backdrop-filter: blur(4px);
  -webkit-backdrop-filter: blur(4px);
}

.cert-summary-card:hover {
  transform: translateY(-4px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.2);
}

.cert-summary-card :deep(.el-card__body) {
  padding: 0;
  height: 100%;
}

.cert-summary-content {
  display: flex;
  flex-direction: column;
  justify-content: center;
  height: 100%;
  padding: 24px;
}

.cert-stat-item {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 20px 0;
}

.cert-stat-item.expiring {
  padding-bottom: 0;
}

.cert-icon {
  color: rgba(255,255,255,0.9);
}

.cert-icon.warning {
  color: #ffeb3b;
}

.cert-stat-info {
  flex: 1;
}

.cert-stat-value {
  font-size: 36px;
  font-weight: bold;
  color: #fff;
  line-height: 1.2;
}

.cert-stat-value.warning {
  color: #ffeb3b;
}

.cert-stat-label {
  font-size: 14px;
  color: rgba(255,255,255,0.7);
  margin-top: 4px;
}

.cert-summary-card :deep(.el-divider) {
  margin: 16px 0;
  border-color: rgba(255,255,255,0.2);
}

/* 表格卡片样式 */
.table-card {
  height: 100%;
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

/* 到期提醒卡片样式 */
.expiry-card {
  margin-bottom: 0;
}

.expiry-card :deep(.el-card__body) {
  padding: 0;
}

.expiry-card :deep(.el-table) {
  border-radius: 0 0 4px 4px;
}
</style>
