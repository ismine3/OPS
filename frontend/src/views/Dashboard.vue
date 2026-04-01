<template>
  <div class="dashboard-container">
    <!-- 统计卡片 -->
    <el-row :gutter="16" class="stat-row">
      <el-col :xs="24" :sm="12" :md="8" class="stat-col">
        <div class="stat-card blue-gradient" @click="$router.push('/servers')">
          <el-icon :size="40" class="stat-icon"><Monitor /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.servers || 0 }}</div>
            <div class="stat-label">服务器</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8" class="stat-col">
        <div class="stat-card green-gradient" @click="$router.push('/services')">
          <el-icon :size="40" class="stat-icon"><SetUp /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.services || 0 }}</div>
            <div class="stat-label">服务</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8" class="stat-col">
        <div class="stat-card purple-gradient" @click="$router.push('/apps')">
          <el-icon :size="40" class="stat-icon"><Grid /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.apps || 0 }}</div>
            <div class="stat-label">应用系统</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8" class="stat-col">
        <div class="stat-card red-gradient" @click="$router.push('/certs')">
          <el-icon :size="40" class="stat-icon"><Document /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.certs || 0 }}</div>
            <div class="stat-label">域名证书</div>
          </div>
        </div>
      </el-col>
      <el-col :xs="24" :sm="12" :md="8" class="stat-col">
        <div class="stat-card cyan-gradient" @click="$router.push('/records')">
          <el-icon :size="40" class="stat-icon"><Notebook /></el-icon>
          <div class="stat-info">
            <div class="stat-value">{{ stats.counts?.records || 0 }}</div>
            <div class="stat-label">更新记录</div>
          </div>
        </div>
      </el-col>
    </el-row>

    <!-- 中间行：环境分布 + 到期提醒 -->
    <el-row :gutter="20" class="middle-row">
      <el-col :span="12">
        <el-card class="table-card">
          <template #header>
            <div class="card-header">
              <el-icon><Monitor /></el-icon>
              <span>服务器环境分布</span>
            </div>
          </template>
          <el-table :data="stats.env_distribution || []" stripe v-loading="loading">
            <el-table-column prop="env_type" label="环境类型" min-width="120">
              <template #default="{ row }">
                <el-tag :type="getEnvTagType(row.env_type)">{{ row.env_type }}</el-tag>
              </template>
            </el-table-column>
            <el-table-column prop="count" label="数量" min-width="80" align="center" />
            <el-table-column label="占比" min-width="100">
              <template #default="{ row }">
                <el-progress 
                  :percentage="getPercentage(row.count)" 
                  :color="getProgressColor(row.env_type)"
                  :show-text="false"
                  :stroke-width="8"
                />
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!stats.env_distribution?.length" description="暂无数据" />
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card class="table-card">
          <template #header>
            <div class="card-header">
              <el-icon><Timer /></el-icon>
              <span>域名/证书到期提醒</span>
            </div>
          </template>
          <el-table :data="stats.recent_certs || []" stripe v-loading="loading" max-height="300">
            <el-table-column prop="project" label="项目" min-width="120" show-overflow-tooltip />
            <el-table-column prop="entity" label="主体" min-width="150" show-overflow-tooltip />
            <el-table-column prop="expire_date" label="到期日期" min-width="100" />
            <el-table-column prop="remaining_days" label="剩余天数" min-width="90" align="center">
              <template #default="{ row }">
                <el-tag :type="getDaysTagType(row.remaining_days)" size="small">
                  {{ row.remaining_days }}天
                </el-tag>
              </template>
            </el-table-column>
          </el-table>
          <el-empty v-if="!stats.recent_certs?.length" description="暂无到期提醒" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 底部：最近更新记录 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <el-icon><Notebook /></el-icon>
          <span>最近更新记录</span>
        </div>
      </template>
      <el-table :data="stats.recent_records || []" stripe v-loading="loading">
        <el-table-column prop="seq_no" label="编号" min-width="80" />
        <el-table-column prop="change_date" label="变更日期" min-width="100" />
        <el-table-column prop="modifier" label="修改人" min-width="100" />
        <el-table-column prop="location" label="修改位置" min-width="150" show-overflow-tooltip />
        <el-table-column prop="content" label="修改内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
      </el-table>
      <el-empty v-if="!stats.recent_records?.length" description="暂无更新记录" />
    </el-card>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted, computed } from 'vue'
import { Monitor, SetUp, Grid, Document, Notebook, Timer } from '@element-plus/icons-vue'
import { getDashboardStats } from '../api/dashboard'

const loading = ref(false)
const stats = reactive({
  counts: {},
  env_distribution: [],
  recent_certs: [],
  recent_records: []
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

function getEnvTagType(env) {
  const map = {
    '生产': 'danger',
    '测试': 'warning',
    '智慧环保': 'success',
    '水电集团': 'primary'
  }
  return map[env] || 'info'
}

function getProgressColor(env) {
  const map = {
    '生产': '#f56c6c',
    '测试': '#e6a23c',
    '智慧环保': '#67c23a',
    '水电集团': '#409eff'
  }
  return map[env] || '#909399'
}

function getPercentage(count) {
  if (!totalServers.value) return 0
  return Math.round((count / totalServers.value) * 100)
}

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
  margin-bottom: 20px;
  display: flex;
  flex-wrap: wrap;
}

.stat-col {
  flex: 1 1 0;
  max-width: 20%;
}

.stat-card {
  border-radius: 12px;
  padding: 20px;
  color: #fff;
  position: relative;
  overflow: hidden;
  cursor: pointer;
  transition: transform 0.3s;
  display: flex;
  align-items: center;
  gap: 12px;
}

.stat-card:hover {
  transform: translateY(-4px);
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

.middle-row {
  margin-bottom: 20px;
  display: flex;
  align-items: stretch;
}

.middle-row > .el-col > .el-card {
  height: 100%;
}

.table-card {
  margin-bottom: 0;
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

</style>
