//对外暴漏路由
import type { RouteRecordRaw } from 'vue-router';
export const constantRoute: RouteRecordRaw[] = [
    {
        //登录
        path: '/login',
        component: () => import('@/views/login/index.vue'), //登录页面
        name: 'login',//登录路由
        meta: {
            title: '登录', //标题
            hidden: true, //隐藏菜单
            icon: 'Promotion' //左侧图标支持elment-plus图标库
        }
    },
    {
        //首页
        path: '/',
        component: () => import('@/layout/index.vue'),
        name: 'layout',//数据路由
        redirect: '/home', //重定向到首页
        meta: {
            title: '首页', //标题  
            hidden: false, //隐藏菜单
            icon: 'Avatar' //图标
        },
        children: [
            {
                path: '/home',
                component: () => import('@/views/home/index.vue'), //首页
                meta: {
                    title: '首页', //标题
                    hidden: false, //隐藏菜单
                    icon: 'Avatar' //图标
                }
            },
        ]
    },
    {
        //大屏数据
        path: '/screen',
        component: () => import('@/views/screen/index.vue'), //首页
        name: 'screen',//数据路由
        meta: {
            title: '大屏数据', //标题
            hidden: false, //隐藏菜单
            icon: 'Platform' //图标
        }      
    },
    {
        //权限管理
        path: '/acl',
        component: () => import('@/layout/index.vue'), //首页 
        name: 'Acl',//数据路由
        meta: {
            title: '权限管理', //标题
            hidden: false, //隐藏菜单
            icon: 'Lock' //图标
        },
        children: [
            {
                path: '/acl/user',
                component: () => import('@/views/acl/user/index.vue'), //首页
                name:'user',
                meta: {
                    title: '用户管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'User' //图标
                }
            }, 
            {
                path: '/acl/role',
                component: () => import('@/views/acl/role/index.vue'), //首页
                name:'role', 
                meta: {
                    title: '角色管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'Avatar' //图标 
                }
            },
            {
                path: '/acl/permission',
                component: () => import('@/views/acl/permission/index.vue'), //首页
                name:'permission', //数据路由
                meta: {
                    title: '菜单管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'Fold' //图标
                } 
            }
        ]
    },
    {
        //商品管理
        path: '/product',
        component: () => import('@/layout/index.vue'), //首页 
        name: 'Product',//数据路由
        meta: {
            title: '商品管理', //标题
            hidden: false, //隐藏菜单
            icon: 'Goods' //图标
        },
        children: [
            {
                path: '/product/trademark',
                component: () => import('@/views/product/trademark/index.vue'), //首页
                name:'trademark',
                meta: {
                    title: '品牌管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'ShoppingCartFull' //图标
                }
            }, 
            {
                path: '/product/attr',
                component: () => import('@/views/product/attr/index.vue'), //首页
                name:'attr',
                meta: {
                    title: '属性管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'ChromeFilled' //图标
                }
            },
            {
                path: '/product/spu',
                component: () => import('@/views/product/spu/index.vue'), //首页
                name:'spu', //数据路由
                meta: {
                    title: 'SPU管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'Calendar' //图标
                }
            },
            {
                path: '/product/sku',
                component: () => import('@/views/product/sku/index.vue'), //首页
                name:'sku', //数据路由 
                meta: {
                    title: 'SKU管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'Orange' //图标 
                }
            }
        ]
    },
    {
        //404
        path: '/404',
        meta: {
            title: '404', //标题 
            hidden: true, //隐藏菜单
            icon: 'Crop' //图标
        },
        component: () => import('@/views/404/index.vue'), //首页
        name: '404'//404路由

    }
    ,
    {
        //任意路由
        path: '/:pathMach(.*)',
        meta: {
            title: '任意路由', //标题 
            hidden: true, //隐藏菜单
            icon: 'Message' //图标
        },
        redirect: '404', //重定向到404
        name: 'any'//任意路由
    }
]