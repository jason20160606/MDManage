//对外暴漏路由
import type { RouteRecordRaw } from 'vue-router';

//系统管理路由
import aclRoutes from './routers/acl'
//组织架构路由
import organizationRoutes from './routers/organization'
//库存路由
import stockRoutes from './routers/stock'
//订单路由
import orderRoutes from './routers/order'
//产品路由
import productRoutes from './routers/product'
//财务管理
import billRoutes from './routers/bill'
//发货管理路由
import shippingRoutes from './routers/shipping'


//常量路由
export const constantRoutes: RouteRecordRaw[] = [
    //登录
    {
        path: '/login',
        component: () => import('@/views/login/index.vue'), //登录页面
        name: 'login',//登录路由
        meta: {
            title: '登录', //标题
            hidden: true, //隐藏菜单
            icon: 'Promotion' //左侧图标支持elment-plus图标库
        }
    },
    //无权限页面（常量路由，任何登录用户都能到达）
    {
        path: '/403',
        component: () => import('@/views/403/index.vue'),
        name: '403',
        meta: {
            title: '无权限',
            hidden: true,
            icon: 'Lock'
        }
    },
    //首页
    {
        path: '/',
        component: () => import('@/layout/index.vue'),
        name: 'layout',//数据路由
        redirect: '/home', //重定向到首页
        meta: {
            title: '', //标题  
            hidden: false, //隐藏菜单
            icon: '' //图标
        },
        children: [
            {
                path: 'home',
                component: () => import('@/views/home/index.vue'), //首页
                meta: {
                    title: '首页', //标题
                    hidden: false, //隐藏菜单
                    icon: 'Avatar' //图标
                }
            },
        ]
    },
    //大屏数据
    {
        path: '/screen',
        component: () => import('@/views/screen/index.vue'), //首页
        name: 'screen',//数据路由
        meta: {
            title: '大屏数据', //标题
            hidden: false, //隐藏菜单
            icon: 'Platform' //图标
        }
    },
    //大屏数据3
    {
        path: '/dashboard',
        component: () => import('@/views/screen/dashboard.vue'), //首页
        name: 'Enterprisedashboard',        
        meta: {
            title: '企业大屏2',
            icon: 'Platform'
        }
    }    
]

//异步路由（左侧菜单顺序 = 数组顺序）
export const asyncRoutes: RouteRecordRaw[]=[
    organizationRoutes, //组织管理
    stockRoutes,        //库存管理
    productRoutes,      //商品管理
    orderRoutes,        //订单管理
    shippingRoutes,     //发货管理
    billRoutes,         //财务管理
    aclRoutes           //系统管理
]

// 任意路由
export const anyRoutes: RouteRecordRaw[] = [
    //404页面
    {
        path: '/404',
        component: () => import('@/views/404/index.vue'),
        name: '404',
        meta: {
            title: '404',
            hidden: true,
            icon: 'DocumentDelete'
        }
    },
    {
        path: '/:pathMatch(.*)*',
        redirect: '/404',
        name: 'any',
        meta: {
            title: '任意路由',
            hidden: true,
            icon: 'Message'
        }
    }
]
