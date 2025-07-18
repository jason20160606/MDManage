import type { RouteRecordRaw } from 'vue-router'

const organizationRoutes: RouteRecordRaw = {
  path: '/organization',
  component: () => import('@/layout/index.vue'),
  name:'organization',
  meta: {
    title: '组织管理',
    icon: 'OfficeBuilding',
    roles: ['organization']
  },
  redirect: '/organization/company',
  children: [
    {
      path: '/organization/company', // 改为相对路径
      name: 'company',
      component: () => import('@/views/organization/company/index.vue'),
      meta: {
        title: '公司管理',
        icon: 'OfficeBuilding',
        keepAlive: true,
        roles: ['company'] 
      }
    },
    {
      path: '/organization/factory', // 改为相对路径
      name: 'factory',
      component: () => import('@/views/organization/factory/index.vue'),
      meta: {
        title: '工厂管理',
        icon: 'House',
        keepAlive: true,
        roles: ['factory'] 
      }
    },
    {
      path: '/organization/dealer', // 改为相对路径
      name: 'dealer',
      component: () => import('@/views/organization/dealer/index.vue'),
      meta: {
        title: '经销商管理',
        icon: 'Shop',
        keepAlive: true,
        roles: ['dealer'] 
      }
    }
  ]
}

export default organizationRoutes 
