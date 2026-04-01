<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="分类">
          <el-select v-model="searchParams.category" placeholder="全部分类" clearable style="width: 150px">
            <el-option label="公众平台" value="公众平台" />
            <el-option label="域名" value="域名" />
            <el-option label="SSL证书" value="SSL证书" />
          </el-select>
        </el-form-item>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="项目/主体/品牌" 
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增证书</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="seq_no" label="编号" min-width="80" />
        <el-table-column prop="category" label="分类" min-width="100">
          <template #default="{ row }">
            <el-tag :type="getCategoryTagType(row.category)" size="small">{{ row.category }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="project" label="项目" min-width="150" show-overflow-tooltip />
        <el-table-column prop="entity" label="主体" min-width="150" show-overflow-tooltip />
        <el-table-column prop="purchase_date" label="购买日期" min-width="100" />
        <el-table-column prop="expire_date" label="到期日期" min-width="100" />
        <el-table-column prop="cost" label="费用" min-width="100" align="right">
          <template #default="{ row }">
            {{ row.cost ? `¥${row.cost}` : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="remaining_days" label="剩余天数" min-width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getDaysTagType(row.remaining_days)" size="small">
              {{ row.remaining_days }}天
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="brand" label="品牌" min-width="100" />
        <el-table-column prop="status" label="状态" min-width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">{{ row.status }}</el-tag>
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
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="650px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="编号" prop="seq_no">
              <el-input v-model="form.seq_no" placeholder="如：CERT001" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="分类" prop="category">
              <el-select v-model="form.category" placeholder="请选择分类" style="width: 100%">
                <el-option label="公众平台" value="公众平台" />
                <el-option label="域名" value="域名" />
                <el-option label="SSL证书" value="SSL证书" />
              </el-select>
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="项目" prop="project">
              <el-input v-model="form.project" placeholder="请输入项目名称" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="主体" prop="entity">
              <el-input v-model="form.entity" placeholder="如：example.com" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="购买日期" prop="purchase_date">
              <el-date-picker 
                v-model="form.purchase_date" 
                type="date" 
                placeholder="选择购买日期"
                style="width: 100%"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="到期日期" prop="expire_date">
              <el-date-picker 
                v-model="form.expire_date" 
                type="date" 
                placeholder="选择到期日期"
                style="width: 100%"
                value-format="YYYY-MM-DD"
              />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="费用" prop="cost">
              <el-input-number v-model="form.cost" :min="0" :precision="2" style="width: 100%" placeholder="请输入费用" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="剩余天数" prop="remaining_days">
              <el-input-number v-model="form.remaining_days" :min="0" style="width: 100%" placeholder="自动计算或手动输入" />
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="品牌" prop="brand">
              <el-input v-model="form.brand" placeholder="如：DigiCert、Let's Encrypt" />
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="状态" prop="status">
              <el-select v-model="form.status" placeholder="请选择状态" style="width: 100%">
                <el-option label="正常" value="正常" />
                <el-option label="即将过期" value="即将过期" />
                <el-option label="已过期" value="已过期" />
                <el-option label="已注销" value="已注销" />
              </el-select>
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
import { getCerts, createCert, updateCert, deleteCert } from '../api/certs'

const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const dialogTitle = ref('新增证书')
const editingId = ref(null)
const formRef = ref(null)

const searchParams = reactive({
  category: '',
  search: ''
})

const form = reactive({
  seq_no: '',
  category: '',
  project: '',
  entity: '',
  purchase_date: '',
  expire_date: '',
  cost: 0,
  remaining_days: 0,
  brand: '',
  status: '正常',
  remark: ''
})

const rules = {
  seq_no: [{ required: true, message: '请输入编号', trigger: 'blur' }],
  category: [{ required: true, message: '请选择分类', trigger: 'change' }],
  project: [{ required: true, message: '请输入项目', trigger: 'blur' }],
  entity: [{ required: true, message: '请输入主体', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getCerts(searchParams)
    tableData.value = res.data || []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  fetchData()
}

function handleReset() {
  searchParams.category = ''
  searchParams.search = ''
  fetchData()
}

function resetForm() {
  Object.assign(form, {
    seq_no: '',
    category: '',
    project: '',
    entity: '',
    purchase_date: '',
    expire_date: '',
    cost: 0,
    remaining_days: 0,
    brand: '',
    status: '正常',
    remark: ''
  })
}

function handleAdd() {
  dialogTitle.value = '新增证书'
  editingId.value = null
  resetForm()
  dialogVisible.value = true
}

function handleEdit(row) {
  dialogTitle.value = '编辑证书'
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
      await updateCert(editingId.value, form)
      ElMessage.success('更新成功')
    } else {
      await createCert(form)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除 "${row.project} - ${row.entity}" 吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteCert(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

function getCategoryTagType(category) {
  const map = {
    '公众平台': 'success',
    '域名': 'primary',
    'SSL证书': 'warning'
  }
  return map[category] || 'info'
}

function getDaysTagType(days) {
  if (days < 0) return 'info'
  if (days < 30) return 'danger'
  if (days < 90) return 'warning'
  return 'success'
}

function getStatusTagType(status) {
  const map = {
    '正常': 'success',
    '即将过期': 'warning',
    '已过期': 'danger',
    '已注销': 'info'
  }
  return map[status] || 'info'
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
