import type { RouteRecordRaw } from 'vue-router'

const billRoutes: RouteRecordRaw = {
  path: '/bill',
  component: () => import('@/layout/index.vue'),
  name: 'bill',
  meta: {
    title: '财务管理',
    icon: 'Van',
    roles: ['bill']
  },
  redirect: '/bill/freight',
  children: [
    {
      path: '/bill/freight',
      name: 'freightbill',
      component: () => import('@/views/bill/freight/index.vue'),
      meta: {
        title: '运费账单',
        icon: 'Document',
        keepAlive: true,
        roles: ['freightbill']
      }
    },
    {
      path: '/bill/diffprice',
      name: 'diffpricebill',
      component: () => import('@/views/bill/diffprice/index.vue'),
      meta: {
        title: '差价账单',
        icon: 'Document',
        keepAlive: true,
        roles: ['diffpricebill']
      }
    }
  ]
}

export default billRoutes 
