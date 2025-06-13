import type { RouteRecordRaw } from 'vue-router'

const organizationRoutes: RouteRecordRaw = {
  path: '/organization',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '组织管理',
    icon: 'OfficeBuilding',
    roles: ['admin', 'manager']
  },
  children: [
    {
      path: 'company',
      name: 'Company',
      component: () => import('@/views/organization/company/index.vue'),
      meta: {
        title: '公司管理',
        icon: 'OfficeBuilding',
        roles: ['admin', 'manager']
      }
    },
    {
      path: 'factory',
      name: 'Factory',
      component: () => import('@/views/organization/factory/index.vue'),
      meta: {
        title: '工厂管理',
        icon: 'House',
        roles: ['admin', 'manager']
      }
    },
    {
      path: 'dealer',
      name: 'Dealer',
      component: () => import('@/views/organization/dealer/index.vue'),
      meta: {
        title: '经销商管理',
        icon: 'Shop',
        roles: ['admin', 'manager']
      }
    }
  ]
}

export default organizationRoutes 