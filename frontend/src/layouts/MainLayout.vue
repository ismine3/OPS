<template>
  <el-container class="layout-container">
    <!-- 左侧菜单 -->
    <el-aside :width="isCollapse ? '64px' : '220px'" class="aside-menu">
      <div class="logo-container">
        <el-icon :size="28" color="#409EFF"><Monitor /></el-icon>
        <span v-show="!isCollapse" class="logo-text">运维管理平台</span>
      </div>
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :collapse-transition="false"
        background-color="transparent"
        text-color="#bfcbd9"
        active-text-color="#409EFF"
        router
      >
        <el-menu-item index="/dashboard">
          <el-icon><Odometer /></el-icon>
          <template #title>仪表盘</template>
        </el-menu-item>
        <el-menu-item index="/monitoring">
          <el-icon><DataLine /></el-icon>
          <template #title>监控中心</template>
        </el-menu-item>
        <el-menu-item index="/projects">
          <el-icon><Folder /></el-icon>
          <template #title>项目管理</template>
        </el-menu-item>
        <el-menu-item index="/servers">
          <el-icon><Monitor /></el-icon>
          <template #title>服务器管理</template>
        </el-menu-item>
        <el-menu-item index="/services">
          <el-icon><SetUp /></el-icon>
          <template #title>服务管理</template>
        </el-menu-item>
        <el-menu-item index="/accounts">
          <el-icon><Grid /></el-icon>
          <template #title>账号管理</template>
        </el-menu-item>
        <el-menu-item index="/domains">
          <el-icon><Link /></el-icon>
          <template #title>域名管理</template>
        </el-menu-item>
        <el-menu-item index="/certs">
          <el-icon><Document /></el-icon>
          <template #title>证书管理</template>
        </el-menu-item>
        <el-menu-item index="/tasks">
          <el-icon><Timer /></el-icon>
          <template #title>定时任务</template>
        </el-menu-item>
        <el-menu-item v-if="userStore.isAdmin" index="/credentials">
          <el-icon><Key /></el-icon>
          <template #title>凭证管理</template>
        </el-menu-item>
        <el-menu-item v-if="userStore.isAdmin" index="/users">
          <el-icon><UserFilled /></el-icon>
          <template #title>用户管理</template>
        </el-menu-item>
        <el-menu-item index="/operation-logs">
          <el-icon><List /></el-icon>
          <template #title>操作日志</template>
        </el-menu-item>
      </el-menu>
    </el-aside>

    <!-- 右侧内容 -->
    <el-container>
      <!-- 顶部导航栏 -->
      <el-header class="header-bar">
        <div class="header-left">
          <el-icon class="collapse-btn" @click="isCollapse = !isCollapse" :size="20">
            <Fold v-if="!isCollapse" />
            <Expand v-else />
          </el-icon>
          <el-breadcrumb separator="/">
            <el-breadcrumb-item>{{ currentTitle }}</el-breadcrumb-item>
          </el-breadcrumb>
        </div>
        <div class="header-right">
          <el-button type="primary" plain size="small" @click="handleExport" :icon="Download">
            导出Excel
          </el-button>
          <el-dropdown @command="handleCommand">
            <span class="user-info">
              <el-avatar :size="32" :icon="UserFilled" />
              <span class="username">{{ userStore.displayName }}</span>
              <el-icon><ArrowDown /></el-icon>
            </span>
            <template #dropdown>
              <el-dropdown-menu>
                <el-dropdown-item command="password">
                  <el-icon><Lock /></el-icon>修改密码
                </el-dropdown-item>
                <el-dropdown-item command="logout" divided>
                  <el-icon><SwitchButton /></el-icon>退出登录
                </el-dropdown-item>
              </el-dropdown-menu>
            </template>
          </el-dropdown>
        </div>
      </el-header>

      <!-- 主内容区 -->
      <el-main class="main-content">
        <router-view />
      </el-main>
    </el-container>
  </el-container>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download, UserFilled, Link, Key, List, Folder } from '@element-plus/icons-vue'
import { useUserStore } from '../stores/user'
import { exportExcel } from '../api/export'

const route = useRoute()
const router = useRouter()
const userStore = useUserStore()
const isCollapse = ref<boolean>(false)

const activeMenu = computed(() => {
  const path = route.path
  // 对于子路由如 /servers/1, 激活 /servers
  if (path.startsWith('/servers/')) return '/servers'
  if (path.startsWith('/projects/')) return '/projects'
  return path
})

const currentTitle = computed(() => route.meta.title || '仪表盘')

onMounted(() => {
  userStore.fetchProfile()
})

function handleCommand(command: string): void {
  if (command === 'password') {
    router.push('/change-password')
  } else if (command === 'logout') {
    ElMessageBox.confirm('确定要退出登录吗？', '提示', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }).then(() => {
      userStore.logout()
      router.push('/login')
      ElMessage.success('已退出登录')
    }).catch(() => {})
  }
}

async function handleExport() {
  try {
    const res = await exportExcel()
    // @ts-ignore
    const blob = new Blob([res], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `运维数据导出_${new Date().toISOString().slice(0, 10)}.xlsx`
    link.click()
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (e) {
    console.error('导出失败', e)
  }
}
</script>

<style scoped>
.layout-container {
  height: 100vh;
}

.aside-menu {
  background: rgba(24, 25, 28, 0.85);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  transition: width 0.3s;
  overflow-x: hidden;
}

.logo-container {
  height: 60px;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 10px;
  border-bottom: 1px solid #333;
  padding: 0 16px;
}

.logo-text {
  color: #fff;
  font-size: 16px;
  font-weight: 600;
  white-space: nowrap;
}

.el-menu {
  border-right: none;
}

.header-bar {
  background: rgba(255, 255, 255, 0.7);
  backdrop-filter: blur(16px);
  -webkit-backdrop-filter: blur(16px);
  border-bottom: 1px solid rgba(0, 0, 0, 0.06);
  box-shadow: 0 4px 16px rgba(0, 0, 0, 0.04);
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 0 20px;
  z-index: 10;
}

.header-left {
  display: flex;
  align-items: center;
  gap: 16px;
}

.collapse-btn {
  cursor: pointer;
  color: #333;
}
.collapse-btn:hover {
  color: #409EFF;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 8px;
  cursor: pointer;
  color: #333;
}

.username {
  font-size: 14px;
}

.main-content {
  background: linear-gradient(135deg, #e8edf5 0%, #f0e6f0 30%, #e6f0ef 60%, #f5f0e8 100%);
  min-height: 0;
  overflow-y: auto;
}

/* 侧边栏菜单毛玻璃适配 */
.aside-menu :deep(.el-menu) {
  background: transparent;
  border-right: none;
}

.aside-menu :deep(.el-menu-item) {
  background: transparent;
  margin: 4px 8px;
  border-radius: 8px;
  transition: all 0.3s ease;
}

.aside-menu :deep(.el-menu-item:hover) {
  background: rgba(255, 255, 255, 0.08);
}

.aside-menu :deep(.el-menu-item.is-active) {
  background: rgba(64, 158, 255, 0.2);
  color: #409EFF;
}

.aside-menu :deep(.el-menu-item.is-active .el-icon) {
  color: #409EFF;
}

/* 菜单项图标统一颜色 */
.aside-menu :deep(.el-menu-item .el-icon) {
  color: rgba(191, 203, 217, 0.85);
  transition: color 0.3s ease;
}

.aside-menu :deep(.el-menu-item:hover .el-icon) {
  color: rgba(255, 255, 255, 0.95);
}

/* 折叠状态下的菜单项 */
.aside-menu :deep(.el-menu--collapse .el-menu-item) {
  margin: 4px;
}
</style>
