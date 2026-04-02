<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="操作模块">
          <el-select v-model="searchParams.module" placeholder="全部模块" clearable style="width: 150px">
            <el-option v-for="m in moduleOptions" :key="m" :label="m" :value="m" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作类型">
          <el-select v-model="searchParams.action" placeholder="全部类型" clearable style="width: 150px">
            <el-option v-for="a in actionOptions" :key="a" :label="getActionLabel(a)" :value="a" />
          </el-select>
        </el-form-item>
        <el-form-item label="操作用户">
          <el-input v-model="searchParams.username" placeholder="用户名" clearable style="width: 150px" />
        </el-form-item>
        <el-form-item label="日期范围">
          <el-date-picker
            v-model="dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
            style="width: 240px"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="id" label="ID" width="80" />
        <el-table-column prop="created_at" label="操作时间" width="160" />
        <el-table-column prop="username" label="操作用户" width="120" />
        <el-table-column prop="module" label="操作模块" width="120">
          <template #default="{ row }">
            <el-tag size="small">{{ row.module }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="action" label="操作类型" width="100">
          <template #default="{ row }">
            <el-tag :type="getActionTagType(row.action)" size="small">
              {{ getActionLabel(row.action) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="target_name" label="操作对象" min-width="180" show-overflow-tooltip />
        <el-table-column prop="detail" label="操作详情" min-width="200">
          <template #default="{ row }">
            <span v-if="row.detail" class="detail-text">{{ formatDetail(row.detail) }}</span>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="ip" label="IP地址" width="130" />
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { getOperationLogs, getOperationModules, getOperationActions } from '../api/operationLogs'

const loading = ref(false)
const tableData = ref([])
const moduleOptions = ref([])
const actionOptions = ref([])
const dateRange = ref([])

const searchParams = reactive({
  module: '',
  action: '',
  username: '',
  start_date: '',
  end_date: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

onMounted(() => {
  fetchData()
  fetchFilters()
})

async function fetchData() {
  loading.value = true
  try {
    const params = {
      page: pagination.page,
      page_size: pagination.pageSize,
      ...searchParams
    }
    const res = await getOperationLogs(params)
    tableData.value = res.data.items || []
    pagination.total = res.data.total || 0
  } finally {
    loading.value = false
  }
}

async function fetchFilters() {
  try {
    const [modulesRes, actionsRes] = await Promise.all([
      getOperationModules(),
      getOperationActions()
    ])
    moduleOptions.value = modulesRes.data || []
    actionOptions.value = actionsRes.data || []
  } catch (e) {
    console.error('获取筛选选项失败', e)
  }
}

function handleSearch() {
  if (dateRange.value && dateRange.value.length === 2) {
    searchParams.start_date = dateRange.value[0]
    searchParams.end_date = dateRange.value[1]
  } else {
    searchParams.start_date = ''
    searchParams.end_date = ''
  }
  pagination.page = 1
  fetchData()
}

function handleReset() {
  searchParams.module = ''
  searchParams.action = ''
  searchParams.username = ''
  searchParams.start_date = ''
  searchParams.end_date = ''
  dateRange.value = []
  pagination.page = 1
  fetchData()
}

function getActionLabel(action) {
  const map = {
    'create': '新增',
    'update': '更新',
    'delete': '删除',
    'import': '导入',
    'export': '导出',
    'login': '登录',
    'logout': '登出',
    'login_failed': '登录失败',
    'check': '检测',
    'deploy': '部署',
    'sync': '同步',
    'upload': '上传',
    'download': '下载'
  }
  return map[action] || action
}

function getActionTagType(action) {
  const map = {
    'create': 'success',
    'update': 'warning',
    'delete': 'danger',
    'login': 'success',
    'login_failed': 'danger',
    'upload': 'success',
    'deploy': 'primary'
  }
  return map[action] || 'info'
}

function formatDetail(detail) {
  if (!detail) return '-'
  try {
    const obj = typeof detail === 'string' ? JSON.parse(detail) : detail
    return Object.entries(obj)
      .map(([k, v]) => `${k}: ${v}`)
      .join(', ')
  } catch {
    return String(detail).substring(0, 100)
  }
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

.detail-text {
  color: #606266;
  font-size: 13px;
}
</style>
