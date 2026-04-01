<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="分组">
          <el-select v-model="searchParams.group_name" placeholder="全部分组" clearable style="width: 180px">
            <el-option 
              v-for="group in groupList" 
              :key="group" 
              :label="group" 
              :value="group" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="名称/用户名/地址" 
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增账户</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="group_name" label="分组" min-width="120" show-overflow-tooltip />
        <el-table-column prop="name" label="名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="url" label="地址" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">
            <el-link 
              v-if="isHttpUrl(row.url)" 
              type="primary" 
              :href="row.url" 
              target="_blank"
              :underline="false"
            >
              {{ row.url }}
            </el-link>
            <span v-else>{{ row.url || '-' }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="username" label="用户名" min-width="120" />
        <el-table-column prop="password" label="密码" min-width="120">
          <template #default="{ row }">
            <PasswordDisplay :password="row.password" />
          </template>
        </el-table-column>
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" min-width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!tableData.length && !loading" description="暂无数据" />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="550px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="90px">
        <el-form-item label="分组" prop="group_name">
          <el-select 
            v-model="form.group_name" 
            placeholder="请选择或输入分组" 
            style="width: 100%" 
            filterable 
            allow-create
            default-first-option
          >
            <el-option 
              v-for="group in groupList" 
              :key="group" 
              :label="group" 
              :value="group" 
            />
          </el-select>
        </el-form-item>
        <el-form-item label="名称" prop="name">
          <el-input v-model="form.name" placeholder="如：阿里云控制台" />
        </el-form-item>
        <el-form-item label="地址" prop="url">
          <el-input v-model="form.url" placeholder="如：https://www.example.com" />
        </el-form-item>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="用户名" prop="username">
              <el-input v-model="form.username" placeholder="请输入用户名" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="密码" prop="password">
              <el-input v-model="form.password" type="password" show-password placeholder="请输入密码" />
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
  </div>
</template>

<script setup>
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { getAccounts, createAccount, updateAccount, deleteAccount } from '../api/accounts'
import PasswordDisplay from '../components/PasswordDisplay.vue'

const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])
const groupList = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增账户')
const editingId = ref(null)
const formRef = ref(null)

const searchParams = reactive({
  group_name: '',
  search: ''
})

const form = reactive({
  group_name: '',
  name: '',
  url: '',
  username: '',
  password: '',
  remark: ''
})

const rules = {
  group_name: [{ required: true, message: '请输入分组', trigger: 'blur' }],
  name: [{ required: true, message: '请输入名称', trigger: 'blur' }],
  username: [{ required: true, message: '请输入用户名', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getAccounts(searchParams)
    tableData.value = res.data || []
    // 提取分组列表
    const groups = [...new Set(tableData.value.map(item => item.group_name).filter(Boolean))]
    groupList.value = groups
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  fetchData()
}

function handleReset() {
  searchParams.group_name = ''
  searchParams.search = ''
  fetchData()
}

function resetForm() {
  Object.keys(form).forEach(key => {
    form[key] = ''
  })
}

function handleAdd() {
  dialogTitle.value = '新增账户'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑账户'
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
      await updateAccount(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createAccount(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除账户 "${row.name}" 吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteAccount(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

function isHttpUrl(url) {
  return url && (url.startsWith('http://') || url.startsWith('https://'))
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
