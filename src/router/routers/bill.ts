import type { RouteRecordRaw } from 'vue-router'

const billRoutes: RouteRecordRaw = {
  path: '/bill',
  component: () => import('@/layout/index.vue'),
  name: 'bill',//数据路由
  meta: {
    title: '财务管理',
    icon: 'Van'
  },
  redirect: '/bill/freight', // 添加重定向
  children: [
    {
      path: '/bill/freight',
      name: 'freightbill',
      component: () => import('@/views/bill/freight/index.vue'),
      meta: {
        title: '运费账单',
        icon: 'Document',
        roles: ['admin', 'manager']
      }
    },
    {
      path: '/bill/diffprice',
      name: 'diffpricebill',
      component: () => import('@/views/bill/diffprice/index.vue'),
      meta: {
        title: '差价账单',
        icon: 'Document',
        roles: ['admin', 'manager']
      }
    }
  ]
}

export default billRoutes 