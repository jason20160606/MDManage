import type { RouteRecordRaw } from 'vue-router'

const reportRoutes: RouteRecordRaw = {
  path: '/report',
  name: 'Report',
  component: () => import('@/layout/index.vue'),
  redirect: '/report/dashboard',
  meta: {
    title: '数据统计',
    icon: 'DataLine'
  },
  children: [    
    {
      path: 'sales',
      name: 'SalesReport',
      component: () => import('@/views/report/sales/index.vue'),
      meta: {
        title: '销售统计',
        icon: 'TrendCharts'
      }
    },
    {
      path: 'inventory',
      name: 'InventoryReport',
      component: () => import('@/views/report/inventory/index.vue'),
      meta: {
        title: '库存统计',
        icon: 'Box'
      }
    }
  ]
}

export default reportRoutes 