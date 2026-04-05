<template>
  <div class="page-container">
    <!-- 搜索区 -->
    <el-card class="search-card">
      <el-form :model="searchParams" inline>
        <el-form-item label="关键词">
          <el-input
            v-model="searchParams.search"
            placeholder="任务名称/描述"
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
          <el-button type="primary" :icon="Plus" @click="handleAdd">新增任务</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 数据表格 -->
    <el-card class="table-card">
      <el-table :data="tableData" stripe v-loading="loading" style="width: 100%">
        <el-table-column prop="name" label="任务名称" min-width="150" show-overflow-tooltip />
        <el-table-column prop="description" label="描述" min-width="180" show-overflow-tooltip />
        <el-table-column prop="cron_expression" label="Cron表达式" min-width="130">
          <template #default="{ row }">
            <el-tag type="info" size="small">{{ row.cron_expression }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="script_files" label="脚本文件" min-width="120">
          <template #default="{ row }">
            <template v-if="row.script_files && row.script_files.length > 0">
              <el-tooltip placement="top">
                <template #content>
                  <div v-for="fileName in row.script_files" :key="fileName">{{ fileName }}</div>
                </template>
                <el-tag type="info" size="small" style="cursor: pointer;">
                  {{ row.script_files.length }} 个文件
                </el-tag>
              </el-tooltip>
            </template>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="execute_command" label="执行命令" min-width="150">
          <template #default="{ row }">
            <el-tooltip v-if="row.execute_command" :content="row.execute_command" placement="top">
              <span class="command-text">{{ row.execute_command }}</span>
            </el-tooltip>
            <el-tag v-else type="warning" size="small">自动</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="is_active" label="状态" min-width="80">
          <template #default="{ row }">
            <el-switch v-model="row.is_active" @change="handleToggle(row)" />
          </template>
        </el-table-column>
        <el-table-column prop="last_run" label="上次执行" min-width="160" />
        <el-table-column prop="last_status" label="执行状态" min-width="100">
          <template #default="{ row }">
            <el-tag v-if="row.last_status" :type="getStatusTagType(row.last_status)" size="small">
              {{ getStatusText(row.last_status) }}
            </el-tag>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="created_by" label="创建者" min-width="100" />
        <el-table-column label="操作" min-width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" size="small" @click="handleRun(row)">手动执行</el-button>
            <el-button type="info" size="small" @click="handleViewLogs(row)">查看日志</el-button>
            <el-button type="warning" size="small" @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" size="small" @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!tableData.length && !loading" description="暂无数据" />
    </el-card>

    <!-- 新增/编辑弹窗 -->
    <el-dialog v-model="dialogVisible" :title="dialogTitle" width="550px" destroy-on-close>
      <el-form ref="formRef" :model="form" :rules="rules" label-width="100px">
        <el-form-item label="任务名称" prop="name">
          <el-input v-model="form.name" placeholder="请输入任务名称" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input v-model="form.description" type="textarea" :rows="2" placeholder="请输入任务描述" />
        </el-form-item>
        <el-form-item label="Cron表达式" prop="cron_expression">
          <el-input v-model="form.cron_expression" placeholder="例如: 0 2 * * *">
            <template #append>
              <el-tooltip content="格式: 分 时 日 月 周，例如: 0 2 * * * 表示每天凌晨2点" placement="top">
                <el-icon><QuestionFilled /></el-icon>
              </el-tooltip>
            </template>
          </el-input>
          <el-text type="info" size="small">格式: 分 时 日 月 周，例如: 0 2 * * * 表示每天凌晨2点</el-text>
        </el-form-item>
        <el-form-item label="执行命令" prop="execute_command">
          <el-input
            v-model="form.execute_command"
            placeholder="如：python main.py --env prod"
            clearable
          />
          <el-text type="info" size="small">
            当设置执行命令时，系统会在脚本文件目录下执行该命令；未设置时按文件类型自动执行
          </el-text>
        </el-form-item>
        <el-form-item label="脚本文件" prop="scriptFiles">
          <!-- 编辑模式：展示已有文件 -->
          <div v-if="editingId && form.existingFiles.length > 0" class="existing-files">
            <div class="existing-files-label">已上传文件：</div>
            <el-tag
              v-for="fileName in form.existingFiles"
              :key="fileName"
              closable
              type="info"
              class="file-tag"
              @close="handleRemoveExistingFile(fileName)"
            >
              {{ fileName }}
            </el-tag>
          </div>
          <el-upload
            ref="uploadRef"
            action="#"
            :auto-upload="false"
            :on-change="handleFileChange"
            :on-remove="handleFileRemove"
            :file-list="fileList"
            accept=".py,.sh"
            multiple
          >
            <el-button type="primary">选择文件</el-button>
            <template #tip>
              <div class="el-upload__tip">支持 .py 和 .sh 文件，可选择多个文件{{ editingId ? '，不选择则保留原文件' : '' }}</div>
            </template>
          </el-upload>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="dialogVisible = false">取消</el-button>
        <el-button type="primary" @click="handleSubmit" :loading="submitLoading">确定</el-button>
      </template>
    </el-dialog>

    <!-- 查看日志抽屉 -->
    <el-drawer v-model="logDrawerVisible" :title="`执行日志 - ${currentTaskName}`" size="700px">
      <el-table :data="logData" stripe v-loading="logLoading" style="width: 100%">
        <el-table-column prop="start_time" label="开始时间" min-width="160" />
        <el-table-column prop="end_time" label="结束时间" min-width="160" />
        <el-table-column prop="status" label="状态" min-width="80">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.status)" size="small">{{ getStatusText(row.status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="output" label="输出" min-width="150" show-overflow-tooltip>
          <template #default="{ row }">
            <el-button v-if="row.output" type="primary" link size="small" @click="showDetail(row.output, '输出')">查看</el-button>
            <span v-else>-</span>
          </template>
        </el-table-column>
        <el-table-column prop="error" label="错误" min-width="150" show-overflow-tooltip>
          <template #default="{ row }">
            <el-button v-if="row.error" type="danger" link size="small" @click="showDetail(row.error, '错误')">查看</el-button>
            <span v-else>-</span>
          </template>
        </el-table-column>
      </el-table>
      <el-empty v-if="!logData.length && !logLoading" description="暂无日志" />
    </el-drawer>

    <!-- 日志详情弹窗 -->
    <el-dialog v-model="detailDialogVisible" :title="detailTitle" width="600px">
      <pre class="detail-content">{{ detailContent }}</pre>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Plus, QuestionFilled } from '@element-plus/icons-vue'
import { getTasks, createTask, updateTask, deleteTask, toggleTask, runTask, getTaskLogs } from '../api/tasks'
// @ts-ignore: validators.js is a JavaScript file without type declarations
import { safeText, maxLength, cronValidator, isSafeSearch } from '@/utils/validators'

const loading = ref(false)
const submitLoading = ref(false)
const logLoading = ref(false)
const tableData = ref([])
const dialogVisible = ref(false)
const logDrawerVisible = ref(false)
const detailDialogVisible = ref(false)
const dialogTitle = ref('新增任务')
const editingId = ref(null)
/** @type {any} */
const formRef = ref(null)
/** @type {any} */
const uploadRef = ref(null)
const currentTaskId = ref(null)
const currentTaskName = ref('')
const logData = ref([])
const detailTitle = ref('')
const detailContent = ref('')

const searchParams = reactive({
  search: ''
})

const form = reactive({
  name: '',
  description: '',
  cron_expression: '',
  execute_command: '',
  scriptFiles: [] as File[],
  existingFiles: [] as string[],
  removeFiles: [] as string[]
})

const fileList = ref<any[]>([])

const rules = {
  name: [
    { required: true, message: '请输入任务名称', trigger: 'blur' },
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(100), trigger: 'blur' }
  ],
  description: [
    { validator: safeText, trigger: 'blur' },
    { validator: maxLength(500), trigger: 'blur' }
  ],
  cron_expression: [
    { required: true, message: '请输入Cron表达式', trigger: 'blur' },
    { validator: cronValidator, trigger: 'blur' }
  ]
}

onMounted(() => {
  fetchData()
})

async function fetchData() {
  loading.value = true
  try {
    const res = await getTasks(searchParams)
    tableData.value = res.data || []
  } finally {
    loading.value = false
  }
}

function handleSearch() {
  if (!isSafeSearch(searchParams.search)) {
    ElMessage.warning('搜索内容包含非法字符')
    return
  }
  fetchData()
}

function handleReset() {
  searchParams.search = ''
  fetchData()
}

function resetFormData() {
  form.name = ''
  form.description = ''
  form.cron_expression = ''
  form.execute_command = ''
  form.scriptFiles = []
  form.existingFiles = []
  form.removeFiles = []
  fileList.value = []
}

function handleAdd() {
  dialogTitle.value = '新增任务'
  editingId.value = null
  resetFormData()
  if (uploadRef.value) {
    uploadRef.value.clearFiles()
  }
  fileList.value = []
  dialogVisible.value = true
}

/**
 * @param {any} row
 */
function handleEdit(row) {
  dialogTitle.value = '编辑任务'
  editingId.value = row.id
  form.name = row.name
  form.description = row.description || ''
  form.cron_expression = row.cron_expression
  form.execute_command = row.execute_command || ''
  form.existingFiles = row.script_files ? [...row.script_files] : []
  form.scriptFiles = []
  form.removeFiles = []
  fileList.value = []
  if (uploadRef.value) {
    uploadRef.value.clearFiles()
  }
  dialogVisible.value = true
}

/**
 * @param {any} file
 * @param {any} fileListParam
 */
function handleFileChange(file, fileListParam) {
  form.scriptFiles = fileListParam.map((f: any) => f.raw).filter(Boolean)
}

/**
 * @param {any} file
 * @param {any} fileListParam
 */
function handleFileRemove(file, fileListParam) {
  form.scriptFiles = fileListParam.map((f: any) => f.raw).filter(Boolean)
}

/**
 * 删除已有文件
 * @param {string} fileName
 */
function handleRemoveExistingFile(fileName) {
  const index = form.existingFiles.indexOf(fileName)
  if (index > -1) {
    form.existingFiles.splice(index, 1)
    form.removeFiles.push(fileName)
  }
}

async function handleSubmit() {
  const valid = await formRef.value?.validate().catch(() => false)
  if (!valid) return

  // 创建时至少需要一个文件，编辑时需要有文件（已有+新上传）
  const totalFiles = form.existingFiles.length + form.scriptFiles.length
  if (!editingId.value && form.scriptFiles.length === 0) {
    ElMessage.warning('请选择至少一个脚本文件')
    return
  }
  if (editingId.value && totalFiles === 0) {
    ElMessage.warning('任务至少需要一个脚本文件')
    return
  }

  submitLoading.value = true
  try {
    const formData = new FormData()
    formData.append('name', form.name)
    formData.append('description', form.description)
    formData.append('cron_expression', form.cron_expression)
    
    // 添加执行命令（如果有）
    if (form.execute_command) {
      formData.append('execute_command', form.execute_command)
    }
    
    // 添加新上传的文件（多文件）
    form.scriptFiles.forEach(file => {
      formData.append('script_files', file)
    })
    
    // 编辑模式：添加要删除的文件列表
    if (editingId.value && form.removeFiles.length > 0) {
      formData.append('remove_files', JSON.stringify(form.removeFiles))
    }

    if (editingId.value) {
      await updateTask(editingId.value, formData)
      ElMessage.success('更新成功')
    } else {
      await createTask(formData)
      ElMessage.success('创建成功')
    }
    dialogVisible.value = false
    fetchData()
  } finally {
    submitLoading.value = false
  }
}

/**
 * @param {any} row
 */
async function handleToggle(row) {
  try {
    await toggleTask(row.id)
    ElMessage.success(row.is_active ? '任务已启用' : '任务已禁用')
    fetchData()
  } catch (e) {
    row.is_active = !row.is_active
  }
}

/**
 * @param {any} row
 */
async function handleRun(row) {
  try {
    await runTask(row.id)
    ElMessage.success('任务已开始执行')
  } catch (e) {
    console.error('执行任务失败', e)
  }
}

/**
 * @param {any} row
 */
async function handleViewLogs(row) {
  currentTaskId.value = row.id
  currentTaskName.value = row.name
  logDrawerVisible.value = true
  await fetchLogs()
}

async function fetchLogs() {
  logLoading.value = true
  try {
    const res = await getTaskLogs(currentTaskId.value, {})
    logData.value = res.data || []
  } finally {
    logLoading.value = false
  }
}

/**
 * @param {any} content
 * @param {any} type
 */
function showDetail(content, type) {
  detailTitle.value = type
  detailContent.value = content
  detailDialogVisible.value = true
}

/**
 * @param {any} row
 */
function handleDelete(row) {
  ElMessageBox.confirm(`确定要删除任务 "${row.name}" 吗？`, '提示', {
    type: 'warning',
    confirmButtonText: '确定',
    cancelButtonText: '取消'
  }).then(async () => {
    await deleteTask(row.id)
    ElMessage.success('删除成功')
    fetchData()
  }).catch(() => {})
}

/**
 * @param {any} status
 */
function getStatusTagType(status) {
  /** @type {Record<string, string>} */
  const map = {
    'success': 'success',
    'failed': 'danger',
    'running': 'primary'
  }
  return map[status] || 'info'
}

/**
 * @param {any} status
 */
function getStatusText(status) {
  /** @type {Record<string, string>} */
  const map = {
    'success': '成功',
    'failed': '失败',
    'running': '运行中'
  }
  return map[status] || status
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

.detail-content {
  background-color: #f5f5f5;
  padding: 16px;
  border-radius: 4px;
  max-height: 400px;
  overflow: auto;
  white-space: pre-wrap;
  word-wrap: break-word;
  font-family: monospace;
  font-size: 13px;
  margin: 0;
}

.existing-files {
  margin-bottom: 12px;
}

.existing-files-label {
  font-size: 13px;
  color: #606266;
  margin-bottom: 8px;
}

.file-tag {
  margin-right: 8px;
  margin-bottom: 8px;
}

.command-text {
  font-family: monospace;
  font-size: 12px;
  color: #606266;
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
  display: inline-block;
  max-width: 140px;
  vertical-align: middle;
}
</style>
