import type { RouteRecordRaw } from 'vue-router'

const shippingRoutes: RouteRecordRaw = {
  path: '/shipping',
        name: 'shipping',
        component: () => import('@/layout/index.vue'),        
        meta: {
            title: '发货管理',
            icon: 'Van',
            hidden: false, //隐藏菜单
            roles: ['shipping']
        },
        redirect: '/shipping/pending', // 添加重定向
        children: [
            {
                path: '/shipping/pending',
                name: 'pendingdelivery',
                component: () => import('@/views/shipping/delivery/pending.vue'),
                meta: {
                    title: '待发货列表',
                    keepAlive: true,
                    icon: 'Box',
                    roles: ['pendingdelivery']
                }
            },
            {
                path: '/shipping/shipped',
                name: 'shippeddelivery',
                component: () => import('@/views/shipping/delivery/shipped.vue'),
                meta: {
                    title: '已发货列表',
                    keepAlive: true,
                    icon: 'Ship',
                    roles: ['shippeddelivery']
                },
            },
            {
                path: '/shipping/info',
                name: 'logisticsInfo',
                component: () => import('@/views/shipping/logistics/info.vue'),
                meta: {
                    title: '物流公司',
                    keepAlive: true,
                    icon: 'Location',
                    roles: ['logisticsInfo']
                }
            },
            {
                path: '/shipping/self-pickup',
                name: 'selfpickup',
                component: () => import('@/views/shipping/logistics/self-pickup.vue'),
                meta: {
                    title: '自提管理',
                    keepAlive: true,
                    icon: 'TakeawayBox',
                    roles: ['selfpickup']
                }
            },
            {
                path: '/shipping/record',
                name: 'shippingrecord',
                component: () => import('@/views/shipping/record/index.vue'),
                meta: {
                    title: '发货记录',
                    icon: 'Document',
                    keepAlive: true,
                    roles: ['shippingrecord']
                }
            },
            {
                path: '/shipping/freightrule',
                name: 'freightrule',
                component: () => import('@/views/shipping/freightrule/index.vue'),
                meta: {
                    title: '运费规则',
                    icon: 'Setting',
                    roles: ['freightrule']
                }
            }
        ]
}

export default shippingRoutes 