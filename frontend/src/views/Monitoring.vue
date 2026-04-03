<template>
  <div class="monitoring-container" v-loading="loading">
    <!-- 顶部 Tab 切换 -->
    <div class="monitoring-header">
      <el-tabs v-model="activeTab" type="card" v-if="dashboards.length > 0">
        <el-tab-pane
          v-for="dashboard in dashboards"
          :key="dashboard.uid"
          :label="dashboard.name"
          :name="dashboard.uid"
        />
      </el-tabs>
      <el-button
        v-if="grafanaUrl && activeDashboard"
        type="primary"
        :icon="FullScreen"
        @click="toggleFullscreen"
        class="fullscreen-btn"
      >
        全屏
      </el-button>
    </div>

    <!-- 未配置提示 -->
    <el-empty
      v-if="!grafanaUrl"
      description="监控服务未配置，请联系管理员配置 Grafana 地址"
      class="empty-tip"
    >
      <template #image>
        <el-icon :size="60" color="#909399"><DataLine /></el-icon>
      </template>
    </el-empty>

    <!-- Grafana iframe -->
    <div v-else-if="activeDashboard" class="iframe-wrapper">
      <iframe
        :src="iframeUrl"
        frameborder="0"
        class="grafana-iframe"
        @load="handleIframeLoad"
      />
    </div>
  </div>
</template>

<script setup>
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { FullScreen, DataLine } from '@element-plus/icons-vue'
import { getMonitoringConfig } from '../api/monitoring'
import { ElMessage } from 'element-plus'

const loading = ref(false)
const grafanaUrl = ref('')
const dashboards = ref([])
const activeTab = ref('')
const iframeLoading = ref(true)

const activeDashboard = computed(() => {
  return dashboards.value.find(d => d.uid === activeTab.value)
})

const iframeUrl = computed(() => {
  if (!grafanaUrl.value || !activeDashboard.value) return ''
  const baseUrl = grafanaUrl.value.replace(/\/$/, '')
  return `${baseUrl}/d/${activeDashboard.value.uid}?orgId=1&kiosk`
})

onMounted(() => {
  fetchConfig()
})

async function fetchConfig() {
  loading.value = true
  try {
    const res = await getMonitoringConfig()
    grafanaUrl.value = res.data.grafana_url || ''
    dashboards.value = res.data.dashboards || []
    
    // 默认选中第一个看板
    if (dashboards.value.length > 0) {
      activeTab.value = dashboards.value[0].uid
    }
  } catch (error) {
    ElMessage.error('获取监控配置失败')
  } finally {
    loading.value = false
  }
}

function handleIframeLoad() {
  iframeLoading.value = false
}

function toggleFullscreen() {
  const iframeWrapper = document.querySelector('.iframe-wrapper')
  if (!iframeWrapper) return

  if (!document.fullscreenElement) {
    iframeWrapper.requestFullscreen().catch(err => {
      ElMessage.error(`全屏模式错误: ${err.message}`)
    })
  } else {
    document.exitFullscreen()
  }
}
</script>

<style scoped>
.monitoring-container {
  height: calc(100vh - 60px);
  display: flex;
  flex-direction: column;
  background: #f0f2f5;
}

.monitoring-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 16px 20px 0;
  background: #fff;
  border-bottom: 1px solid #ebeef5;
}

.monitoring-header :deep(.el-tabs) {
  flex: 1;
}

.monitoring-header :deep(.el-tabs__header) {
  margin-bottom: 0;
}

.fullscreen-btn {
  margin-left: 16px;
  margin-bottom: 8px;
}

.empty-tip {
  flex: 1;
  display: flex;
  flex-direction: column;
  justify-content: center;
  align-items: center;
}

.iframe-wrapper {
  flex: 1;
  position: relative;
  overflow: hidden;
}

.grafana-iframe {
  width: 100%;
  height: 100%;
  border: none;
}
</style>
