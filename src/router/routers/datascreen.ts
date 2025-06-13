import type { RouteRecordRaw } from 'vue-router'

const datascreenRoutes: RouteRecordRaw = {
  path: '/datascreen',
  name: 'DataScreen',
  component: () => import('@/views/datascreen/index.vue'),
  meta: { 
    title: '数据大屏',
    icon: 'Monitor',
    keepAlive: true
  }
}

export default datascreenRoutes 