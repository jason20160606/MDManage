import type { RouteRecordRaw } from 'vue-router'

const inventoryRoutes: RouteRecordRaw = {
  path: '/inventory',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '库存管理',
    icon: 'box'
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

export default inventoryRoutes 