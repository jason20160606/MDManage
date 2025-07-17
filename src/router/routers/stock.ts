import type { RouteRecordRaw } from 'vue-router'

const stockRoutes: RouteRecordRaw = {
  path: '/stock',
  name: 'stock',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '库存管理',
    hidden: false,
    icon: 'TakeawayBox' // 您可以选择更合适的图标
  },
  redirect: '/stock/dealer', // 默认重定向到经销商库存
  children: [
    {
      path: '/stock/dealer',
      name: 'dealerstock',
      component: () => import('@/views/stock/dealer/index.vue'),
      meta: {
        title: '经销商库存',
        hidden: false,
        icon: 'Shop'
      }
    },
    {
      path: '/stock/factory',
      name: 'factorystock',
      component: () => import('@/views/stock/factory/index.vue'),
      meta: {
        title: '工厂库存',
        hidden: false,
        icon: 'House'
      }
    },
    {
      path: '/stock/backstage',
      name: 'backstagestock',
      component: () => import('@/views/stock/backstage/index.vue'),
      meta: {
        title: '后台库存管理',
        hidden: false,
        icon: 'Coin'
      }
    }
  ]
}

export default stockRoutes 