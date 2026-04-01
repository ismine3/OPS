import { createRouter, createWebHistory } from 'vue-router'

const routes = [
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
      { path: 'servers', name: 'Servers', component: () => import('../views/Servers.vue'), meta: { title: '服务器管理' } },
      { path: 'servers/:id', name: 'ServerDetail', component: () => import('../views/ServerDetail.vue'), meta: { title: '服务器详情' } },
      { path: 'services', name: 'Services', component: () => import('../views/Services.vue'), meta: { title: '服务管理' } },

      { path: 'apps', name: 'Apps', component: () => import('../views/Apps.vue'), meta: { title: '应用系统' } },
      { path: 'certs', name: 'Certs', component: () => import('../views/Certs.vue'), meta: { title: '域名/证书' } },
      { path: 'records', name: 'Records', component: () => import('../views/Records.vue'), meta: { title: '更新记录' } },
      { path: 'tasks', name: 'Tasks', component: () => import('../views/Tasks.vue'), meta: { title: '定时任务' } },
      { path: 'users', name: 'Users', component: () => import('../views/Users.vue'), meta: { title: '用户管理', requiresAdmin: true } },
      { path: 'change-password', name: 'ChangePassword', component: () => import('../views/ChangePassword.vue'), meta: { title: '修改密码' } },
    ]
  }
]

const router = createRouter({
  history: createWebHistory(),
  routes
})

// 路由守卫
router.beforeEach((to, from, next) => {
  const token = localStorage.getItem('token')
  
  if (to.meta.requiresAuth === false) {
    // 登录页面不需要认证
    if (token && to.path === '/login') {
      next('/dashboard')
    } else {
      next()
    }
  } else if (!token) {
    next('/login')
  } else if (to.meta.requiresAdmin) {
    const userInfo = JSON.parse(localStorage.getItem('userInfo') || '{}')
    if (userInfo.role === 'admin') {
      next()
    } else {
      next('/dashboard')
    }
  } else {
    next()
  }
})

export default router
