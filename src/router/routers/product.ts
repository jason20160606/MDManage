import type { RouteRecordRaw } from 'vue-router'

const productRoutes: RouteRecordRaw = {
  path: '/product',
  component: () => import('@/layout/index.vue'),
  name: 'product',
  meta: {
    title: '商品管理',
    icon: 'Goods',
    roles: ['product']
  },
  redirect: '/product/trademark',
  children: [
    {
      path: '/product/category',
      component: () => import('@/views/product/category/index.vue'), //首页
      name: 'category',
      meta: {
        title: '分类管理', //标题
        hidden: false, //隐藏菜单
        icon: 'ShoppingCartFull' //图标
      }
    },    
    {
      path: '/product/spu', // 改为相对路径
      name: 'spu',
      component: () => import('@/views/product/spu/index.vue'),
      meta: {
        title: 'SPU管理',
        icon: 'Calendar',
        roles: ['spu']
      }
    },
    {
      path: '/product/sku', // 改为相对路径
      name: 'sku',
      component: () => import('@/views/product/sku/index.vue'),
      meta: {
        title: 'SKU管理',
        icon: 'Orange',
        roles: ['sku']
      }
    },
    // {
    //     path: '/product/attr',
    //     component: () => import('@/views/product/attr/index.vue'), //首页
    //     name: 'attr',
    //     meta: {
    //         title: '属性管理', //标题
    //         hidden: false, //隐藏菜单
    //         icon: 'ChromeFilled' //图标
    //     }
    // }
  ]
}

export default productRoutes 
