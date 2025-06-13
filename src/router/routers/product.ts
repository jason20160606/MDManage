import type { RouteRecordRaw } from 'vue-router'

const productRoutes: RouteRecordRaw = {
  path: '/product',
  name: 'Product',
  component: () => import('@/layout/index.vue'),
  meta: {
    title: '产品管理',
    icon: 'Goods',
    roles: ['admin', 'manager']
  },
  children: [
    {
      path: 'category',
      name: 'Category',
      component: () => import('@/views/product/category/index.vue'),
      meta: {
        title: '产品分类',
        icon: 'Menu',
        roles: ['admin', 'manager']
      }
    },
    {
      path: 'list',
      name: 'ProductList',
      component: () => import('@/views/product/list/index.vue'),
      meta: {
        title: '产品列表',
        icon: 'List',
        roles: ['admin', 'manager']
      }
    },
    {
      path: 'brand',
      name: 'Brand',
      component: () => import('@/views/product/brand/index.vue'),
      meta: {
        title: '品牌管理',
        icon: 'Stamp',
        roles: ['admin', 'manager']
      }
    },
    {
      path: 'quota-rule',
      name: 'QuotaRule',
      component: () => import('@/views/product/quota-rule/index.vue'),
      meta: {
        title: '特殊计量规则',
        icon: 'ScaleToOriginal',
        roles: ['admin', 'manager']
      }
    }
  ]
}

export default productRoutes 