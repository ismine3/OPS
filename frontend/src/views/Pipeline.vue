<template>
  <div class="pipeline-page">
    <!-- Tab 切换 -->
    <el-tabs v-model="activeTab" class="pipeline-tabs" @tab-change="onTabChange">
      <el-tab-pane label="后端流水线" name="backend">
        <template #label>
          <span class="tab-label">
            <el-icon><Setting /></el-icon>
            后端流水线
          </span>
        </template>
      </el-tab-pane>
      <el-tab-pane label="前端流水线" name="frontend">
        <template #label>
          <span class="tab-label">
            <el-icon><Monitor /></el-icon>
            前端流水线
          </span>
        </template>
      </el-tab-pane>
      <el-tab-pane v-if="userStore.isAdmin" label="选项维护" name="options">
        <template #label>
          <span class="tab-label">
            <el-icon><Tools /></el-icon>
            选项维护
          </span>
        </template>
      </el-tab-pane>
    </el-tabs>

    <!-- 流水线配置 + 历史（非 options tab 时显示） -->
    <template v-if="activeTab !== 'options'">
    <el-card class="config-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span class="card-title">{{ activeTab === 'backend' ? '后端' : '前端' }}流水线配置</span>
        </div>
      </template>

      <!-- 项目名称（共用） -->
      <el-form :model="form" label-width="120px" class="config-form">
        <el-form-item label="项目名称" required>
          <el-input
            v-model="projectName"
            placeholder="请输入项目名称（用于创建输出目录）"
            style="max-width: 400px"
          />
        </el-form-item>
      </el-form>

      <!-- 分组折叠面板 -->
      <el-collapse v-model="activeGroups" class="groups-collapse">
        <el-collapse-item
          v-for="group in currentGroups"
          :key="group.group"
          :name="group.group"
        >
          <template #title>
            <span class="group-title">{{ group.label }}</span>
            <span class="group-field-count">{{ group.fields.length }} 项</span>
          </template>

          <el-form label-width="180px" class="group-form">
            <el-form-item
              v-for="field in group.fields"
              :key="field.config_key"
              :label="field.config_label"
              :required="field.required"
            >
              <!-- DOCKER_COMPOSE_ENV_VARS: 多行动态输入 -->
              <div v-if="field.config_key === 'DOCKER_COMPOSE_ENV_VARS'" class="compose-env-wrapper">
                <div v-for="(line, idx) in composeEnvLines" :key="idx" class="compose-env-row">
                  <el-input
                    v-model="composeEnvLines[idx]"
                    placeholder="KEY=VALUE"
                    style="width: 400px"
                    @input="syncComposeEnv"
                  />
                  <el-button
                    type="danger"
                    :icon="Delete"
                    circle
                    size="small"
                    @click="removeComposeLine(idx)"
                  />
                </div>
                <el-button type="primary" text :icon="Plus" @click="addComposeLine">
                  添加环境变量
                </el-button>
                <span v-if="field.description" class="field-desc">{{ field.description }}</span>
              </div>
              <!-- 其他字段: el-autocomplete（可编辑下拉） -->
              <div v-else class="field-wrapper">
                <el-autocomplete
                  v-model="currentFormConfigs[field.config_key]"
                  :fetch-suggestions="(query: string, cb: any) => queryOptions(query, field.options, cb)"
                  clearable
                  :placeholder="'选择或输入' + field.config_label"
                  style="width: 100%; max-width: 520px"
                  @select="(item: any) => handleFieldChange(field.config_key, item.value)"
                />
                <span v-if="field.description" class="field-desc">{{ field.description }}</span>
              </div>
            </el-form-item>
          </el-form>
        </el-collapse-item>
      </el-collapse>

      <div class="form-actions">
        <el-button @click="resetToDefaults">重置为默认值</el-button>
        <el-button type="primary" :loading="generating" @click="handleGenerate">
          生成文件
        </el-button>
      </div>
    </el-card>

    <!-- 生成历史区 -->
    <el-card class="history-card" shadow="never">
      <template #header>
        <div class="card-header">
          <span class="card-title">生成历史</span>
        </div>
      </template>

      <div class="history-toolbar">
        <el-input
          v-model="historySearch"
          placeholder="搜索项目名称"
          clearable
          style="width: 240px"
          @clear="loadGenerations()"
          @keyup.enter="loadGenerations()"
        >
          <template #prefix>
            <el-icon><Search /></el-icon>
          </template>
        </el-input>
        <el-button @click="loadGenerations()">查询</el-button>
      </div>

      <el-table :data="generations" stripe v-loading="historyLoading" class="history-table">
        <el-table-column prop="project_name" label="项目名称" min-width="160" />
        <el-table-column prop="file_count" label="文件数" width="70" align="center" />
        <el-table-column prop="created_by_name" label="创建人" width="110" />
        <el-table-column prop="created_at" label="生成时间" width="170">
          <template #default="{ row }">
            {{ formatTime(row.created_at) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="220" fixed="right">
          <template #default="{ row }">
            <el-button link type="primary" size="small" @click="showConfigDetail(row.id)">
              查看配置
            </el-button>
            <el-button link type="primary" size="small" @click="handleDownload(row)">
              下载ZIP
            </el-button>
            <el-popconfirm
              title="确定要删除该生成记录？"
              confirm-button-text="删除"
              @confirm="handleDelete(row.id)"
            >
              <template #reference>
                <el-button link type="danger" size="small">删除</el-button>
              </template>
            </el-popconfirm>
          </template>
        </el-table-column>
      </el-table>

      <div class="history-pagination">
        <el-pagination
          v-model:current-page="historyPage"
          v-model:page-size="historyPageSize"
          :total="historyTotal"
          :page-sizes="[10, 20, 50]"
          layout="total, sizes, prev, pager, next"
          @size-change="loadGenerations()"
          @current-change="loadGenerations()"
        />
      </div>
    </el-card>
    </template>

    <!-- 选项维护区（options tab 时显示） -->
    <el-card v-if="activeTab === 'options'" class="options-card" shadow="never" v-loading="optionsLoading">
      <template #header>
        <div class="card-header">
          <span class="card-title">配置选项维护</span>
          <span class="card-desc">管理各配置字段的下拉选项值，修改后即时生效</span>
        </div>
      </template>

      <div class="options-toolbar">
        <el-radio-group v-model="optionsFilterType" @change="loadOptionsData">
          <el-radio-button value="">全部</el-radio-button>
          <el-radio-button value="backend">仅后端</el-radio-button>
          <el-radio-button value="frontend">仅前端</el-radio-button>
        </el-radio-group>
      </div>

      <el-empty v-if="!optionsLoading && optionsGroups.length === 0" description="暂无配置数据" />

      <el-collapse v-model="optionsActiveGroups" v-else>
        <el-collapse-item v-for="group in optionsGroups" :key="group.group" :name="group.group">
          <template #title>
            <span class="group-title">{{ group.label }}</span>
            <el-tag size="small" type="info" style="margin-left: 12px;">{{ group.fields.length }} 字段</el-tag>
          </template>

          <div v-for="field in group.fields" :key="field.config_key" class="option-field-row">
            <div class="option-field-info">
              <span class="option-field-label">{{ field.config_label }}</span>
              <code class="option-field-key">{{ field.config_key }}</code>
              <el-tag v-if="field.pipeline_type" size="small" type="warning">{{ field.pipeline_type === 'backend' ? '后端' : '前端' }}</el-tag>
              <el-tag v-else size="small" type="success">共用</el-tag>
            </div>

            <div class="option-tags">
              <template v-if="field.options.length">
                <el-tag
                  v-for="opt in field.options"
                  :key="opt.id"
                  :type="opt.is_default ? 'primary' : 'info'"
                  size="small"
                  closable
                  class="option-tag"
                  @close="handleDeleteOption(field, opt)"
                  @click="handleEditOption(field, opt)"
                >
                  {{ opt.value || '（空值）' }}
                  <span v-if="opt.is_default" class="default-dot">默认</span>
                </el-tag>
              </template>
              <span v-else class="no-options-hint">暂无选项</span>

              <el-button type="primary" text size="small" :icon="Plus" @click="handleAddOption(field)">
                添加选项
              </el-button>
            </div>
          </div>
        </el-collapse-item>
      </el-collapse>
    </el-card>

    <!-- 选项编辑弹窗 -->
    <el-dialog v-model="optionDialogVisible" :title="optionDialogTitle" width="500px" destroy-on-close>
      <el-form ref="optionFormRef" :model="optionForm" :rules="optionRules" label-width="100px">
        <el-form-item label="配置字段">
          <el-input :model-value="optionCurrentField?.config_label" disabled />
        </el-form-item>
        <el-form-item label="选项值" prop="option_value">
          <el-input v-model="optionForm.option_value" placeholder="请输入选项值" />
        </el-form-item>
        <el-form-item label="设为默认">
          <el-switch v-model="optionForm.is_default" />
          <span class="switch-tip">每个字段仅保留一个默认值</span>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="optionDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="optionSubmitting" @click="handleSubmitOption">确定</el-button>
      </template>
    </el-dialog>

    <!-- 配置详情弹窗 -->
    <el-dialog v-model="configDialogVisible" title="生成配置详情" width="700px">
      <el-descriptions v-if="configDetail" :column="2" border size="small">
        <template v-for="(value, key) in configDetail.config_snapshot" :key="key">
          <el-descriptions-item :label="getConfigLabel(key)" :span="isLongValue(value) ? 2 : 1">
            <span v-if="isPasswordField(key)">******</span>
            <span v-else style="word-break: break-all">{{ value || '（空）' }}</span>
          </el-descriptions-item>
        </template>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Search, Setting, Monitor, Delete, Plus, Tools } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import {
  getPipelineConfig,
  generatePipeline,
  getGenerations,
  getGeneration,
  downloadGeneration,
  deleteGeneration,
  addConfigOption,
  updateConfigOption,
  deleteConfigOption,
  type PipelineGroup,
  type PipelineField,
  type PipelineOption,
  type GenerationItem,
  type GenerationDetail,
  type PipelineType,
} from '../api/pipeline'

const userStore = useUserStore()

// ---- Tabs ----
const activeTab = ref<PipelineType | 'options'>('backend')

// ---- 两端独立的配置数据 ----
const backendGroups = ref<PipelineGroup[]>([])
const frontendGroups = ref<PipelineGroup[]>([])
const backendConfigs = ref<Record<string, string>>({})
const frontendConfigs = ref<Record<string, string>>({})
const activeGroups = ref<string[]>([])

const currentGroups = computed(() =>
  activeTab.value === 'backend' ? backendGroups.value : frontendGroups.value
)
const currentFormConfigs = computed({
  get: () => activeTab.value === 'backend' ? backendConfigs.value : frontendConfigs.value,
  set: (val) => {
    if (activeTab.value === 'backend') backendConfigs.value = val
    else frontendConfigs.value = val
  }
})

// 加载当前 tab 配置
async function loadConfig() {
  if (activeTab.value === 'options') return
  try {
    const res: any = await getPipelineConfig(activeTab.value as PipelineType)
    const groups = res.data?.groups || res.groups || []
    if (activeTab.value === 'backend') {
      backendGroups.value = groups
    } else {
      frontendGroups.value = groups
    }
    activeGroups.value = groups.map((g: PipelineGroup) => g.group)
    initCurrentConfigs()
  } catch {
    ElMessage.error('加载配置失败')
  }
}

function initCurrentConfigs() {
  const configs: Record<string, string> = {}
  for (const group of currentGroups.value) {
    for (const field of group.fields) {
      const defaultOpt = field.options.find(o => o.is_default)
      configs[field.config_key] = defaultOpt?.value ?? (field.options[0]?.value ?? '')
    }
  }
  if (activeTab.value === 'backend') {
    backendConfigs.value = configs
  } else {
    frontendConfigs.value = configs
  }
  initComposeEnvLines()
}

function resetToDefaults() {
  initCurrentConfigs()
  ElMessage.success('已重置为默认值')
}

function onTabChange() {
  if (activeTab.value === 'options') {
    if (optionsGroups.value.length === 0) loadOptionsData()
    return
  }
  // 如果该 tab 配置未加载，则加载
  if (activeTab.value === 'backend' && backendGroups.value.length === 0) {
    loadConfig()
  } else if (activeTab.value === 'frontend' && frontendGroups.value.length === 0) {
    loadConfig()
  } else {
    activeGroups.value = currentGroups.value.map((g: PipelineGroup) => g.group)
    initComposeEnvLines()
  }
}

// ---- docker-compose 环境变量多行动态输入 ----
const composeEnvLines = ref<string[]>([''])

function parseComposeEnv(val: string): string[] {
  if (!val || !val.trim()) return ['']
  const normalized = val.replace(/\\n/g, '\n').replace(/;/g, '\n')
  const lines = normalized.split('\n').filter(l => l.trim() !== '')
  return lines.length > 0 ? lines : ['']
}

function initComposeEnvLines() {
  const val = currentFormConfigs.value['DOCKER_COMPOSE_ENV_VARS'] ?? ''
  composeEnvLines.value = parseComposeEnv(String(val))
}

function syncComposeEnv() {
  const nonEmpty = composeEnvLines.value.filter(l => l.trim() !== '')
  const joined = nonEmpty.join('\n')
  if (activeTab.value === 'backend') {
    backendConfigs.value['DOCKER_COMPOSE_ENV_VARS'] = joined
  } else {
    frontendConfigs.value['DOCKER_COMPOSE_ENV_VARS'] = joined
  }
}

function addComposeLine() {
  composeEnvLines.value.push('')
}

function removeComposeLine(idx: number) {
  composeEnvLines.value.splice(idx, 1)
  if (composeEnvLines.value.length === 0) composeEnvLines.value.push('')
  syncComposeEnv()
}

// ---- 共用项目名 ----
const projectName = ref('')
const form = reactive({})

function handleFieldChange(key: string, val: string) {
  if (activeTab.value === 'backend') {
    backendConfigs.value[key] = val ?? ''
  } else {
    frontendConfigs.value[key] = val ?? ''
  }
}

function queryOptions(query: string, options: PipelineOption[], cb: (results: { value: string }[]) => void) {
  const q = (query || '').toLowerCase()
  const results = options
    .filter(o => !q || (o.value || '').toLowerCase().includes(q))
    .map(o => ({ value: o.value }))
  cb(results)
}

function getConfigLabel(key: string): string {
  for (const group of [...backendGroups.value, ...frontendGroups.value]) {
    const field = group.fields.find(f => f.config_key === key)
    if (field) return field.config_label
  }
  return key
}

function isPasswordField(key: string): boolean {
  return key.toUpperCase().includes('PASSWORD')
}

function isLongValue(val: string): boolean {
  return val != null && val.length > 40
}

// ---- 生成 ----
const generating = ref(false)

async function handleGenerate() {
  if (!projectName.value.trim()) {
    ElMessage.warning('请输入项目名称')
    return
  }
  generating.value = true
  try {
    const configs = activeTab.value === 'backend' ? backendConfigs.value : frontendConfigs.value
    const res: any = await generatePipeline({
      project_name: projectName.value.trim(),
      pipeline_type: activeTab.value as PipelineType,
      configs,
    })
    ElMessage.success(`生成成功！共 ${res.data?.files?.length || res.files?.length || 0} 个文件`)
    loadGenerations()
  } catch {
    // 错误已在拦截器中处理
  } finally {
    generating.value = false
  }
}

// ---- 历史列表 ----
const generations = ref<GenerationItem[]>([])
const historyLoading = ref(false)
const historySearch = ref('')
const historyPage = ref(1)
const historyPageSize = ref(10)
const historyTotal = ref(0)

async function loadGenerations() {
  historyLoading.value = true
  try {
    const res: any = await getGenerations({
      page: historyPage.value,
      page_size: historyPageSize.value,
      search: historySearch.value || undefined,
    })
    generations.value = res.data?.items || res.items || []
    historyTotal.value = res.data?.total || res.total || 0
  } catch {
    // handled by interceptor
  } finally {
    historyLoading.value = false
  }
}

function formatTime(ts: string): string {
  if (!ts) return '-'
  return new Date(ts).toLocaleString('zh-CN')
}

async function handleDownload(row: GenerationItem) {
  try {
    const blob = await downloadGeneration(row.id)
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `${row.project_name}_pipeline.zip`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('下载成功')
  } catch {
    // handled
  }
}

async function handleDelete(id: number) {
  try {
    await deleteGeneration(id)
    ElMessage.success('删除成功')
    loadGenerations()
  } catch {
    // handled
  }
}

// ---- 选项维护 ----
const optionsLoading = ref(false)
const optionsGroups = ref<PipelineGroup[]>([])
const optionsActiveGroups = ref<string[]>([])
const optionsFilterType = ref<PipelineType | ''>('')

const optionDialogVisible = ref(false)
const optionDialogTitle = ref('添加选项')
const optionSubmitting = ref(false)
const optionFormRef = ref<any>(null)
const optionCurrentField = ref<PipelineField | null>(null)
const editingOptionRef = ref<PipelineOption | null>(null)

const optionForm = reactive({
  option_value: '',
  is_default: false,
})

const optionRules = {
  option_value: [{ required: true, message: '请输入选项值', trigger: 'blur' }],
}

async function loadOptionsData() {
  optionsLoading.value = true
  try {
    const res: any = await getPipelineConfig(optionsFilterType.value || undefined)
    const data = res.data?.groups || res.groups || []
    optionsGroups.value = data
    optionsActiveGroups.value = data.map((g: PipelineGroup) => g.group)
  } catch {
    ElMessage.error('加载配置失败')
  } finally {
    optionsLoading.value = false
  }
}

function handleAddOption(field: PipelineField) {
  optionCurrentField.value = field
  editingOptionRef.value = null
  optionDialogTitle.value = `添加选项 - ${field.config_label}`
  optionForm.option_value = ''
  optionForm.is_default = false
  optionDialogVisible.value = true
}

function handleEditOption(field: PipelineField, opt: PipelineOption) {
  optionCurrentField.value = field
  editingOptionRef.value = opt
  optionDialogTitle.value = `编辑选项 - ${field.config_label}`
  optionForm.option_value = opt.value
  optionForm.is_default = !!opt.is_default
  optionDialogVisible.value = true
}

async function handleSubmitOption() {
  const valid = await optionFormRef.value?.validate().catch(() => false)
  if (!valid) return

  optionSubmitting.value = true
  try {
    if (editingOptionRef.value) {
      await updateConfigOption(editingOptionRef.value.id, {
        option_value: optionForm.option_value,
        is_default: optionForm.is_default,
      })
      ElMessage.success('更新成功')
    } else {
      await addConfigOption({
        config_id: optionCurrentField.value!.config_id,
        option_value: optionForm.option_value,
        is_default: optionForm.is_default,
      })
      ElMessage.success('添加成功')
    }
    optionDialogVisible.value = false
    loadOptionsData()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '操作失败')
  } finally {
    optionSubmitting.value = false
  }
}

async function handleDeleteOption(field: PipelineField, opt: PipelineOption) {
  try {
    await ElMessageBox.confirm(
      `确定要删除选项 "${opt.value || '（空值）'}" 吗？`,
      '确认删除',
      { type: 'warning', confirmButtonText: '删除', cancelButtonText: '取消' }
    )
  } catch {
    return
  }

  try {
    await deleteConfigOption(opt.id)
    ElMessage.success('删除成功')
    loadOptionsData()
  } catch (e: any) {
    ElMessage.error(e?.response?.data?.message || '删除失败')
  }
}

// ---- 配置详情弹窗 ----
const configDialogVisible = ref(false)
const configDetail = ref<GenerationDetail | null>(null)

async function showConfigDetail(id: number) {
  try {
    const res: any = await getGeneration(id)
    configDetail.value = res.data || res
    configDialogVisible.value = true
  } catch {
    // handled
  }
}

// ---- 初始化 ----
onMounted(() => {
  loadConfig()
  loadGenerations()
})
</script>

<style scoped>
.pipeline-page {
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.pipeline-tabs {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(8px);
  border-radius: 12px;
  padding: 8px 16px 0;
}

.tab-label {
  display: flex;
  align-items: center;
  gap: 6px;
}

.config-card,
.history-card {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(8px);
  border-radius: 12px;
}

.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.card-title {
  font-size: 16px;
  font-weight: 600;
  color: #303133;
}

.group-title {
  font-weight: 500;
  color: #303133;
}

.group-field-count {
  margin-left: 12px;
  font-size: 12px;
  color: #909399;
  font-weight: normal;
}

.groups-collapse {
  margin-top: 8px;
}

.group-form {
  padding: 8px 0;
}

.field-wrapper {
  display: flex;
  flex-direction: column;
  gap: 4px;
  width: 100%;
}

.field-desc {
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}

.form-actions {
  display: flex;
  gap: 12px;
  justify-content: flex-end;
  margin-top: 20px;
  padding-top: 16px;
  border-top: 1px solid #ebeef5;
}

.history-toolbar {
  display: flex;
  gap: 12px;
  margin-bottom: 16px;
}

.history-table {
  width: 100%;
}

.history-pagination {
  display: flex;
  justify-content: flex-end;
  margin-top: 16px;
}

.compose-env-wrapper {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.compose-env-row {
  display: flex;
  align-items: center;
  gap: 8px;
}

/* ---- 选项维护 ---- */
.options-card {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(8px);
  border-radius: 12px;
}

.card-desc {
  font-size: 13px;
  color: #909399;
  font-weight: normal;
}

.options-toolbar {
  margin-bottom: 16px;
}

.option-field-row {
  padding: 12px 0;
  border-bottom: 1px solid #f0f0f0;
}

.option-field-row:last-child {
  border-bottom: none;
}

.option-field-info {
  display: flex;
  align-items: center;
  gap: 10px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.option-field-label {
  font-weight: 500;
  color: #303133;
}

.option-field-key {
  background: #f5f7fa;
  padding: 2px 8px;
  border-radius: 4px;
  font-size: 12px;
  color: #909399;
}

.option-tags {
  display: flex;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
  padding-left: 12px;
}

.option-tag {
  cursor: pointer;
  transition: opacity 0.2s;
}

.option-tag:hover {
  opacity: 0.8;
}

.default-dot {
  margin-left: 4px;
  font-size: 11px;
}

.no-options-hint {
  font-size: 12px;
  color: #c0c4cc;
}

.switch-tip {
  margin-left: 12px;
  font-size: 12px;
  color: #909399;
}
</style>
