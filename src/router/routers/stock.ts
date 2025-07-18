import type { RouteRecordRaw } from 'vue-router'

const stockRoutes: RouteRecordRaw = {
  path: '/stock',
  name: 'stock',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '库存管理',
    hidden: false,
    icon: 'TakeawayBox',
    roles: ['stock']
  },
  redirect: '/stock/dealer',
  children: [
    {
      path: '/stock/dealer', // 改为相对路径
      name: 'dealerstock',
      component: () => import('@/views/stock/dealer/index.vue'),
      meta: {
        title: '经销商库存',
        hidden: false,
        icon: 'Shop',
        keepAlive: true,
        roles: ['dealerstock']
      }
    },
    {
      path: '/stock/factory', // 改为相对路径
      name: 'factorystock',
      component: () => import('@/views/stock/factory/index.vue'),
      meta: {
        title: '工厂库存',
        hidden: false,
        icon: 'House',
        keepAlive: true,
        roles: ['factorystock']
      }
    },
    {
      path: '/stock/backstage', // 改为相对路径
      name: 'backstagestock',
      component: () => import('@/views/stock/backstage/index.vue'),
      meta: {
        title: '后台库存管理',
        hidden: false,
        icon: 'Coin',
        keepAlive: true,
        roles: ['backstagestock']
      }
    }
  ]
}

export default stockRoutes 
