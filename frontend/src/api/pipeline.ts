import request from './request'

export interface PipelineOption {
  id: number
  value: string
  is_default: boolean
}

export interface PipelineField {
  config_key: string
  config_label: string
  description: string
  required: boolean
  options: PipelineOption[]
}

export interface PipelineGroup {
  group: string
  label: string
  fields: PipelineField[]
}

export interface GenerationItem {
  id: number
  project_name: string
  pipeline_type: string
  file_count: number
  created_by_name: string
  created_at: string
}

export interface GenerationDetail {
  id: number
  project_name: string
  pipeline_type: string
  config_snapshot: Record<string, string>
  files: { name: string; path: string }[]
  output_dir: string
  created_by_name: string
  created_at: string
}

export type PipelineType = 'backend' | 'frontend'

export function getPipelineConfig(type?: PipelineType) {
  const params = type ? { type } : {}
  return request.get<{ code: number; data: { groups: PipelineGroup[] } }>('/pipeline/config', { params })
}

export function addConfigOption(data: { config_id: number; option_value: string; is_default?: boolean }) {
  return request.post('/pipeline/config/options', data)
}

export function updateConfigOption(id: number, data: { option_value?: string; is_default?: boolean }) {
  return request.put(`/pipeline/config/options/${id}`, data)
}

export function deleteConfigOption(id: number) {
  return request.delete(`/pipeline/config/options/${id}`)
}

export function generatePipeline(data: { project_name: string; pipeline_type: PipelineType; configs: Record<string, string> }) {
  return request.post<{ code: number; message: string; data: GenerationDetail }>('/pipeline/generate', data)
}

export function getGenerations(params: { page?: number; page_size?: number; search?: string }) {
  return request.get<{ code: number; data: { items: GenerationItem[]; total: number; page: number; page_size: number } }>('/pipeline/generations', { params })
}

export function getGeneration(id: number) {
  return request.get<{ code: number; data: GenerationDetail }>(`/pipeline/generations/${id}`)
}

export function downloadGeneration(id: number): Promise<Blob> {
  return request.get(`/pipeline/generations/${id}/download`, { responseType: 'blob' }) as unknown as Promise<Blob>
}

export function deleteGeneration(id: number) {
  return request.delete(`/pipeline/generations/${id}`)
}
