<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="关键词">
          <el-input 
            v-model="searchParams.search" 
            placeholder="编号/修改人/位置/内容" 
            clearable 
            style="width: 280px"
            @keyup.enter="handleSearch"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
        <el-form-item style="float: right;">
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增记录</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="seq_no" label="编号" min-width="100" />
        <el-table-column prop="change_date" label="变更日期" min-width="120" />
        <el-table-column prop="modifier" label="修改人" min-width="100" />
        <el-table-column prop="location" label="修改位置" min-width="150" show-overflow-tooltip />
        <el-table-column prop="content" label="修改内容" min-width="300" show-overflow-tooltip />
        <el-table-column prop="remark" label="备注" min-width="150" show-overflow-tooltip />
        <el-table-column label="操作" min-width="100" fixed="right">
          <template #default="{ row }">
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!tableData.length && !loading" description="暂无数据" />
    </el-card>

    <!-- 新增弹窗 -->
    <el-dialog v-model="dialogVisible" title="新增更新记录" width="600px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="编号" prop="seq_no">
          <el-input v-model="form.seq_no" placeholder="如：REC001" />
        </el-form-item>
        <el-form-item label="变更日期" prop="change_date">
          <el-date-picker 
            v-model="form.change_date" 
            type="date" 
            placeholder="选择变更日期"
            style="width: 100%"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item label="修改人" prop="modifier">
          <el-input v-model="form.modifier" placeholder="请输入修改人姓名" />
        </el-form-item>
        <el-form-item label="修改位置" prop="location">
          <el-input v-model="form.location" placeholder="如：服务器管理-生产环境" />
        </el-form-item>
        <el-form-item label="修改内容" prop="content">
          <el-input 
            v-model="form.content" 
            type="textarea" 
            :rows="4" 
            placeholder="请详细描述修改内容"
          />
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input v-model="form.remark" type="textarea" :rows="2" placeholder="请输入备注（可选）" />
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
import { getRecords, createRecord, deleteRecord } from '../api/records'

const loading = ref(false)
const submitLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const formRef = ref(null)

const searchParams = reactive({
  search: ''
})

const form = reactive({
  seq_no: '',
  change_date: '',
  modifier: '',
  location: '',
  content: '',
  remark: ''
})

const rules = {
  seq_no: [{ required: true, message: '请输入编号', trigger: 'blur' }],
  change_date: [{ required: true, message: '请选择变更日期', trigger: 'change' }],
  modifier: [{ required: true, message: '请输入修改人', trigger: 'blur' }],
  location: [{ required: true, message: '请输入修改位置', trigger: 'blur' }],
  content: [{ required: true, message: '请输入修改内容', trigger: 'blur' }]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getRecords(searchParams)
    tableData.value = res.data || []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  fetchData()
}

function handleReset() {
  searchParams.search = ''
  fetchData()
}

function resetForm() {
  Object.assign(form, {
    seq_no: '',
    change_date: '',
    modifier: '',
    location: '',
    content: '',
    remark: ''
  })
}

function handleAdd() {
  resetForm()
  // 设置默认日期为今天
  form.change_date = new Date().toISOString().split('T')[0]
  dialogVisible.value = true
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return
  
  submitLoading.value = true
  try {
    await createRecord(form)
    ElMessage.success('创建成功')
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除编号为 "${row.seq_no}" 的记录吗？`, '提示', { 
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteRecord(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
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
