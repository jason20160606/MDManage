import type { RouteRecordRaw } from 'vue-router'

const aclRoutes: RouteRecordRaw = {
  path: '/acl',
  component: () => import('@/layout/index.vue'),
  name: 'acl',
  meta: {
    title: '系统管理',
    hidden: false,
    icon: 'Lock',
    roles: ['acl']
  },
  redirect: '/acl/user',
  children: [
    {
      path: '/acl/user', // 改为相对路径
      component: () => import('@/views/acl/user/index.vue'),
      name: 'user',
      meta: {
        title: '用户管理',
        hidden: false,
        icon: 'User',
        roles: ['user']
      }
    },
    {
      path: '/acl/role', // 改为相对路径
      component: () => import('@/views/acl/role/index.vue'),
      name: 'role',
      meta: {
        title: '角色管理',
        hidden: false,
        icon: 'Avatar',
        roles: ['role']
      }
    },
    {
      path: '/acl/permission', // 改为相对路径
      component: () => import('@/views/acl/permission/index.vue'),
      name: 'permission',
      meta: {
        title: '权限管理',
        hidden: false,
        icon: 'Fold',
        roles: ['permission']
      }
    }
  ]
}

export default aclRoutes
