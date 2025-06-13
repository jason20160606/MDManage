import type { RouteRecordRaw } from 'vue-router'

const orderRoutes: RouteRecordRaw = {
  path: '/order',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '订单管理',
    icon: 'shopping-cart'
  },
  children: [
    {
      path: 'list',
      name: 'OrderList',
      component: () => import('@/views/order/index.vue'),
      meta: {
        title: '订单列表',
        icon: 'list',
        roles: ['admin', 'manager', 'sales', 'customer_service']
      }
    },
    {
      path: 'detail/:id',
      name: 'OrderDetail',
      component: () => import('@/views/order/detail/index.vue'),
      meta: {
        title: '订单详情',
        icon: 'Document',
        roles: ['admin', 'manager', 'operator'],
        hidden: true
      }
    },
    {
      path: 'create',
      name: 'OrderCreate',
      component: () => import('@/views/order/create/index.vue'),
      meta: {
        title: '创建订单',
        icon: 'Plus',
        roles: ['admin', 'manager', 'operator']
      }
    },
    {
      path: 'freight',
      name: 'Freight',
      component: () => import('@/views/order/freight/index.vue'),
      meta: {
        title: '运费管理',
        icon: 'Van',
        roles: ['admin', 'manager']
      }
    }
  ]
}

export default orderRoutes 