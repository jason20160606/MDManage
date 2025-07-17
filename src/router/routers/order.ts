import type { RouteRecordRaw } from 'vue-router'

const orderRoutes: RouteRecordRaw = {
  path: '/order',
  component: () => import('@/layout/index.vue'),
  name:'order',
  meta: {
    title: '订单管理',
    icon: 'shopping-cart'
  },
  redirect: '/order/create', // 重定向到新增订单
  children: [
    {
      path: '/order/create',
      name: 'ordercreate',
      component: () => import('@/views/order/create/index.vue'),
      meta: {
        title: '待审核订单',
        icon: 'Plus',
        roles: ['admin', 'manager', 'sales', 'customer_service']
      }
    },
    {
      path: '/order/waiting',
      name: 'orderwaiting',
      component: () => import('@/views/order/waiting/index.vue'),
      meta: {
        title: '待发货订单',
        icon: 'Document',
        roles: ['admin', 'manager', 'operator']
      }
    },
    {
      path: '/order/shipped',
      name: 'shipped',
      component: () => import('@/views/order/shipped/index.vue'),
      meta: {
        title: '已发货订单',
        icon: 'Ship',
        roles: ['admin', 'manager', 'operator']
      }
    },
    {
      path: '/order/completed',
      name: 'completed',
      component: () => import('@/views/order/completed/index.vue'),
      meta: {
        title: '已完成订单',
        icon: 'CircleCheck',
        roles: ['admin', 'manager']
      }
    },
    {
      path: '/order/cancel',
      name: 'cancel',
      component: () => import('@/views/order/cancel/index.vue'),
      meta: {
        title: '已取消订单',
        icon: 'CircleClose',
        roles: ['admin', 'manager']
      }
    }
  ]
}

export default orderRoutes 