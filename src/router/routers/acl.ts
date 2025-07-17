import type { RouteRecordRaw } from 'vue-router'

const aclRoutes: RouteRecordRaw = {
  path: '/acl',
  component: () => import('@/layout/index.vue'), //首页 
  name: 'acl',//数据路由
  meta: {
    title: '系统管理', //标题
    hidden: false, //隐藏菜单
    icon: 'Lock' //图标
  },
  redirect: '/acl/user', //重定向
  children: [
    {
      path: '/acl/user',
      component: () => import('@/views/acl/user/index.vue'), //首页
      name: 'user',
      meta: {
        title: '用户管理', //标题
        hidden: false, //隐藏菜单
        icon: 'User' //图标
      }
    },
    {
      path: '/acl/role',
      component: () => import('@/views/acl/role/index.vue'), //首页
      name: 'role',
      meta: {
        title: '角色管理', //标题
        hidden: false, //隐藏菜单
        icon: 'Avatar' //图标 
      }
    },
    {
      path: '/acl/permission',
      component: () => import('@/views/acl/permission/index.vue'), //首页
      name: 'permission', //数据路由
      meta: {
        title: '权限管理', //标题
        hidden: false, //隐藏菜单
        icon: 'Fold' //图标
      }
    }
  ]
}

export default aclRoutes 