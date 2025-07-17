import type { RouteRecordRaw } from 'vue-router'

const productRoutes: RouteRecordRaw = {
  path: '/product',
  component: () => import('@/layout/index.vue'), //首页 
  name: 'product',//数据路由
  meta: {
    title: '产品管理', //标题
    hidden: false, //隐藏菜单
    icon: 'Goods' //图标
  },
  redirect: '/product/category', //重定向
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
      path: '/product/spu',
      component: () => import('@/views/product/spu/index.vue'), //首页
      name: 'spu', //数据路由
      meta: {
        title: 'SPU管理', //标题
        hidden: false, //隐藏菜单
        icon: 'Calendar' //图标
      }
    },
    {
      path: '/product/sku',
      component: () => import('@/views/product/sku/index.vue'), //首页
      name: 'sku', //数据路由 
      meta: {
        title: 'SKU管理', //标题
        hidden: false, //隐藏菜单
        icon: 'Orange' //图标 
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