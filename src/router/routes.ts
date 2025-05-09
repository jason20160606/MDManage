//对外暴漏路由
import type { RouteRecordRaw } from 'vue-router';
export const allroutes: RouteRecordRaw[] = [
    {
        //登录
        path: '/login',
        component: () => import('@/views/login/index.vue'), //登录页面
        name: 'login'//命名路由
    },
    {
        //首页
        path: '/',
        component: () => import('@/views/home/index.vue'), //首页
        name: 'home'//命名路由
    },
    {
        //404
        path: '/404',
        component: () => import('@/views/404/index.vue'), //首页
        name: '404'//命名路由
    }
    ,
    {
        //404
        path: '/:pathMach(.*)',
        redirect: '404', //重定向到404
        name: 'any'//命名路由
    }
]