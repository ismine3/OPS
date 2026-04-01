<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="环境类型">
          <el-select v-model="searchParams.env_type" placeholder="全部环境" clearable style="width: 150px">
            <el-option label="测试" value="测试" />
            <el-option label="生产" value="生产" />
            <el-option label="智慧环保" value="智慧环保" />
            <el-option label="水电集团" value="水电集团" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="主机名/IP/用途" 
            clearable 
            style="width: 220px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right;">
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增服务器</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="env_type" label="环境类型" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getEnvTagType(row.env_type)" size="small">{{ row.env_type }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="platform" label="平台" min-width="100" show-overflow-tooltip />
        <el-table-column prop="hostname" label="主机名" min-width="120" show-overflow-tooltip />
        <el-table-column prop="inner_ip" label="内网IP" min-width="120" />
        <el-table-column prop="mapped_ip" label="映射IP" min-width="120" />
        <el-table-column prop="cpu" label="CPU" min-width="80" align="center" />
        <el-table-column prop="memory" label="内存" min-width="80" align="center" />
        <el-table-column prop="purpose" label="用途" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" min-width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleView(row)">查看</el-button>
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
            <el-form-item label="环境类型" prop="env_type">
              <el-select v-model="form.env_type" placeholder="请选择" style="width: 100%">
                <el-option label="测试" value="测试" />
                <el-option label="生产" value="生产" />
                <el-option label="智慧环保" value="智慧环保" />
                <el-option label="水电集团" value="水电集团" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="平台" prop="platform">
              <el-input v-model="form.platform" placeholder="如：阿里云、VMware" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="主机名" prop="hostname">
              <el-input v-model="form.hostname" placeholder="请输入主机名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内网IP" prop="inner_ip">
              <el-input v-model="form.inner_ip" placeholder="请输入内网IP" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="映射IP" prop="mapped_ip">
              <el-input v-model="form.mapped_ip" placeholder="请输入映射IP" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="公网IP" prop="public_ip">
              <el-input v-model="form.public_ip" placeholder="请输入公网IP" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="CPU" prop="cpu">
              <el-input v-model="form.cpu" placeholder="如：8核" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="内存" prop="memory">
              <el-input v-model="form.memory" placeholder="如：16GB" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统盘" prop="sys_disk">
              <el-input v-model="form.sys_disk" placeholder="如：100GB" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="数据盘" prop="data_disk">
              <el-input v-model="form.data_disk" placeholder="如：500GB" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="用途" prop="purpose">
          <el-input v-model="form.purpose" type="textarea" :rows="2" placeholder="请输入用途" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="系统用户" prop="os_user">
              <el-input v-model="form.os_user" placeholder="如：root" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="系统密码" prop="os_password">
              <el-input v-model="form.os_password" type="password" show-password placeholder="请输入系统密码" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-form-item label="Docker密码" prop="docker_password">
          <el-input v-model="form.docker_password" type="password" show-password placeholder="请输入Docker密码" />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="请输入备注" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getServers, createServer, updateServer, deleteServer } from '../api/servers'

const router = useRouter()
const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增服务器')
const editingId = ref(null)
const formRef = ref(null)

const searchParams = reactive({
  env_type: '',
  search: ''
})

const pagination = reactive({
  page: 1,
  pageSize: 20,
  total: 0
})

const form = reactive({
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
  docker_password: '',
  remark: ''
})

const rules = {
  env_type: [{ required: true, message: '请选择环境类型', trigger: 'change' }],
  hostname: [{ required: true, message: '请输入主机名', trigger: 'blur' }],
  inner_ip: [{ required: true, message: '请输入内网IP', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getServers({ ...searchParams, page: pagination.page, page_size: pagination.pageSize })
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
  searchParams.env_type = ''
  searchParams.search = ''
  pagination.page = 1
  fetchData()
}

function resetForm() {
  Object.keys(form).forEach(key => {
    form[key] = ''
  })
}

function handleAdd() {
  dialogTitle.value = '新增服务器'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

function handleView(row) {
  router.push(`/servers/${row.id}`)
}

function handleEdit(row) {
  dialogTitle.value = '编辑服务器'
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
      await updateServer(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createServer(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除服务器 "${row.hostname}" 吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteServer(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
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
