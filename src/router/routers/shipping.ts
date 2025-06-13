import type { RouteRecordRaw } from 'vue-router'

const shippingRoutes: RouteRecordRaw = {
  path: '/shipping',
  name: 'Shipping',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '发货管理',
    icon: 'Van',
    keepAlive: true
  },
  children: [
    {
      path: 'pending',
      name: 'PendingDelivery',
      component: () => import('@/views/shipping/delivery/pending.vue'),
      meta: {
        title: '待发货列表',
        keepAlive: true
      }
    },
    {
      path: 'shipped',
      name: 'ShippedDelivery',
      component: () => import('@/views/shipping/delivery/shipped.vue'),
      meta: {
        title: '已发货列表',
        keepAlive: true
      },
    },

    {
      path: 'info',
      name: 'LogisticsInfo',
      component: () => import('@/views/shipping/logistics/info.vue'),
      meta: {
        title: '物流信息',
        keepAlive: true
      }
    },
    {
      path: 'self-pickup',
      name: 'SelfPickup',
      component: () => import('@/views/shipping/logistics/self-pickup.vue'),
      meta: {
        title: '自提管理',
        keepAlive: true
      }
    }
    ,
    {
      path: 'record',
      name: 'ShippingRecord',
      component: () => import('@/views/shipping/record/index.vue'),
      meta: {
        title: '发货记录',
        icon: 'Notebook',
        keepAlive: true
      }
    }
  ]
}

export default shippingRoutes 