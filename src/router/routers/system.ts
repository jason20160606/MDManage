import type { RouteRecordRaw } from 'vue-router'

const systemRoutes: RouteRecordRaw = {
  path: '/system',
  name: 'System',
  component: () => import('@/layout/index.vue'),
  redirect: '/system/user',
  meta: {
    title: '系统管理',
    icon: 'Setting'
  },
  children: [
    {
      path: 'user',
      name: 'User',
      component: () => import('@/views/system/user/index.vue'),
      meta: {
        title: '用户管理',
        icon: 'User'
      }
    },
    {
      path: 'role',
      name: 'Role',
      component: () => import('@/views/system/role/index.vue'),
      meta: {
        title: '角色管理',
        icon: 'UserFilled'
      }
    },
    {
      path: 'perm',
      name: 'Perm',
      component: () => import('@/views/system/perm/index.vue'),
      meta: {
        title: '权限管理',
        icon: 'Lock'
      }
    }
  ]
}

export default systemRoutes 