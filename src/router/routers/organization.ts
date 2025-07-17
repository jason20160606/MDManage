import type { RouteRecordRaw } from 'vue-router'

const organizationRoutes: RouteRecordRaw = {
  path: '/organization',
  component: () => import('@/layout/index.vue'),
  name:'organization',
  meta: {
    title: '组织管理',
    icon: 'OfficeBuilding',
    roles: ['admin', 'manager']
  },
  redirect: '/organization/company', // 添加重定向到公司管理
  children: [
    {
      path: '/organization/company', // 修改为完整路径
      name: 'company',
      component: () => import('@/views/organization/company/index.vue'),
      meta: {
        title: '公司管理',
        icon: 'OfficeBuilding',
        roles: ['admin', 'manager']
      }
    },
    {
      path: '/organization/factory', // 修改为完整路径
      name: 'factory',
      component: () => import('@/views/organization/factory/index.vue'),
      meta: {
        title: '工厂管理',
        icon: 'House',
        roles: ['admin', 'manager']
      }
    },
    {
      path: '/organization/dealer', // 修改为完整路径
      name: 'dealer',
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