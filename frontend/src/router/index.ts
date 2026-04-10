import { createRouter, createWebHistory } from 'vue-router'
import type { RouteRecordRaw } from 'vue-router'
import { useUserStore } from '../stores/user'

const routes: RouteRecordRaw[] = [
  {
    path: '/login',
    name: 'Login',
    component: () => import('../views/Login.vue'),
    meta: { requiresAuth: false }
  },
  {
    path: '/',
    component: () => import('../layouts/MainLayout.vue'),
    redirect: '/dashboard',
    children: [
      { path: 'dashboard', name: 'Dashboard', component: () => import('../views/Dashboard.vue'), meta: { title: '仪表盘' } },
      { path: 'monitoring', name: 'Monitoring', component: () => import('../views/Monitoring.vue'), meta: { title: '监控中心', moduleCode: 'monitoring' } },
      { path: 'projects', name: 'Projects', component: () => import('../views/Projects.vue'), meta: { title: '项目管理', requiresAuth: true, moduleCode: 'projects' } },
      { path: 'projects/:id', name: 'ProjectDetail', component: () => import('../views/ProjectDetail.vue'), meta: { title: '项目详情', requiresAuth: true, moduleCode: 'projects' } },
      { path: 'servers', name: 'Servers', component: () => import('../views/Servers.vue'), meta: { title: '服务器管理', moduleCode: 'servers' } },
      { path: 'servers/:id', name: 'ServerDetail', component: () => import('../views/ServerDetail.vue'), meta: { title: '服务器详情', moduleCode: 'servers' } },
      { path: 'services', name: 'Services', component: () => import('../views/Services.vue'), meta: { title: '服务管理', moduleCode: 'services' } },
      { path: 'accounts', name: 'Apps', component: () => import('../views/Apps.vue'), meta: { title: '账号管理', moduleCode: 'apps' } },
      { path: 'domains', name: 'Domains', component: () => import('../views/Domains.vue'), meta: { title: '域名管理', moduleCode: 'domains' } },
      { path: 'certs', name: 'Certs', component: () => import('../views/Certs.vue'), meta: { title: '证书管理', moduleCode: 'certs' } },
      { path: 'credentials', name: 'AliyunAccounts', component: () => import('../views/AliyunAccounts.vue'), meta: { title: '凭证管理', requiresAdmin: true } },
      { path: 'tasks', name: 'Tasks', component: () => import('../views/Tasks.vue'), meta: { title: '定时任务', moduleCode: 'tasks' } },
      { path: 'users', name: 'Users', component: () => import('../views/Users.vue'), meta: { title: '用户管理', requiresAdmin: true } },
      { path: 'change-password', name: 'ChangePassword', component: () => import('../views/ChangePassword.vue'), meta: { title: '修改密码' } },
      { path: 'operation-logs', name: 'OperationLogs', component: () => import('../views/OperationLogs.vue'), meta: { title: '操作日志' } },
    ]
  }
]

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),
  routes
})

router.beforeEach(async (to, from, next) => {
  const token = localStorage.getItem('token')
  if (to.meta.requiresAuth === false) {
    if (token && to.path === '/login') {
      next('/dashboard')
    } else {
      next()
    }
  } else if (!token) {
    next('/login')
  } else if (to.meta.requiresAdmin) {
    const userStore = useUserStore()
    try {
      await userStore.fetchProfile()
    } catch {
      /* 401 由 axios 拦截器处理 */
    }
    if (userStore.isAdmin) {
      next()
    } else {
      next('/dashboard')
    }
  } else {
    // 检查模块权限
    const moduleCode = to.meta.moduleCode as string | undefined
    if (moduleCode) {
      const userStore = useUserStore()
      // 确保用户信息已加载（包括 modules）
      if (!userStore.userInfo.id || !Array.isArray(userStore.userInfo.modules)) {
        try {
          await userStore.fetchProfile()
        } catch {
          /* 401 由 axios 拦截器处理 */
        }
      }
      if (!userStore.hasModuleAccess(moduleCode)) {
        next('/dashboard')
        return
      }
    }
    next()
  }
})

export default router
