import type { RouteRecordRaw } from 'vue-router'

const freightRoutes: RouteRecordRaw = {
  path: '/freight',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '运费管理',
    icon: 'money'
  },
  children: [
    {
      path: 'list',
      name: 'FreightList',
      component: () => import('@/views/freight/index.vue'),
      meta: {
        title: '运费规则',
        icon: 'list',
        roles: ['admin', 'manager']
      }
    }
  ]
}

export default freightRoutes 