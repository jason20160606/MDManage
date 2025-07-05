//对外暴漏路由
import type { RouteRecordRaw } from 'vue-router';
// import type { AppRouteRecordRaw } from './types'
// // 导入路由模块
// //大屏路由
// import datascreenRoutes from './routers/datascreen'
// //运费管理路由
// import freightRoutes from './routers/freight'
// //库存路由
// import inventoryRoutes from './routers/inventory'
// //订单路由
// import orderRoutes from './routers/order'
// //组织架构路由
// import organizationRoutes from './routers/organization'
// //产品路由
// import productRoutes from './routers/product'
// //数据统计路由
// import reportRoutes from './routers/report'
// //发货管理路由
// import shippingRoutes from './routers/shipping'
// //系统管理路由
// import systemRoutes from './routers/system'


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
    //大屏数据2
    {
        path: '/screen/enterprise',
        component: () => import('@/views/screen/enterprise.vue'), //首页
        name: 'EnterpriseScreen',        
        meta: {
            title: '企业大屏',
            icon: 'Platform'
        }
    },
    //系统管理
    {

        path: '/acl',
        component: () => import('@/layout/index.vue'), //首页 
        name: 'Acl',//数据路由
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
    },
    //组织架构
    {
        path: '/organization',
        component: () => import('@/layout/index.vue'),
        meta: {
            title: '组织管理',
            icon: 'OfficeBuilding',
            roles: ['admin', 'manager']
        },
        redirect: '/organization/company', // 添加重定向到公司管理
        children: [
            {
                path: '/organization/company', // 修改为完整路径
                name: 'Company',
                component: () => import('@/views/organization/company/index.vue'),
                meta: {
                    title: '公司管理',
                    icon: 'OfficeBuilding',
                    roles: ['admin', 'manager']
                }
            },
            {
                path: '/organization/factory', // 修改为完整路径
                name: 'Factory',
                component: () => import('@/views/organization/factory/index.vue'),
                meta: {
                    title: '工厂管理',
                    icon: 'House',
                    roles: ['admin', 'manager']
                }
            },
            {
                path: '/organization/dealer', // 修改为完整路径
                name: 'Dealer',
                component: () => import('@/views/organization/dealer/index.vue'),
                meta: {
                    title: '经销商管理',
                    icon: 'Shop',
                    roles: ['admin', 'manager']
                }
            }
        ]
    },
    //产品管理
    {

        path: '/product',
        component: () => import('@/layout/index.vue'), //首页 
        name: 'Product',//数据路由
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
            {
                path: '/product/attr',
                component: () => import('@/views/product/attr/index.vue'), //首页
                name: 'attr',
                meta: {
                    title: '属性管理', //标题
                    hidden: false, //隐藏菜单
                    icon: 'ChromeFilled' //图标
                }
            }
        ]
    },
    //库存管理
    {
        path: '/stock',
        component: () => import('@/layout/index.vue'),
        name: 'Stock',
        meta: {
            title: '库存管理',
            hidden: false,
            icon: 'TakeawayBox' // 您可以选择更合适的图标
        },
        redirect: '/stock/dealer', // 默认重定向到经销商库存
        children: [
            {
                path: '/stock/dealer',
                name: 'DealerInventory',
                component: () => import('@/views/stock/dealer/index.vue'),
                meta: {
                    title: '经销商库存',
                    hidden: false,
                    icon: 'Shop'
                }
            },
            {
                path: '/stock/factory',
                name: 'FactoryInventory',
                component: () => import('@/views/stock/factory/index.vue'),
                meta: {
                    title: '工厂库存',
                    hidden: false,
                    icon: 'House'
                }
            },
            {
                path: '/stock/backstage',
                name: 'BackstageInventory',
                component: () => import('@/views/stock/backstage/index.vue'),
                meta: {
                    title: '后台库存管理',
                    hidden: false,
                    icon: 'Coin'
                }
            }
        ]
    },
    //订单管理
    {
        path: '/order',
        component: () => import('@/layout/index.vue'),
        meta: {
            title: '订单管理',
            icon: 'shopping-cart'
        },
        redirect: '/order/create', // 重定向到新增订单
        children: [
            {
                path: '/order/create',
                name: 'OrderCreate',
                component: () => import('@/views/order/create/index.vue'),
                meta: {
                    title: '新增订单',
                    icon: 'Plus',
                    roles: ['admin', 'manager', 'sales', 'customer_service']
                }
            },
            {
                path: '/order/waiting',
                name: 'OrderWaiting',
                component: () => import('@/views/order/waiting/index.vue'),
                meta: {
                    title: '待发货订单',
                    icon: 'Document',
                    roles: ['admin', 'manager', 'operator']
                }
            },
            {
                path: '/order/shipped',
                name: 'Shipped',
                component: () => import('@/views/order/shipped/index.vue'),
                meta: {
                    title: '已发货订单',
                    icon: 'Ship',
                    roles: ['admin', 'manager', 'operator']
                }
            },
            {
                path: '/order/completed',
                name: 'Completed',
                component: () => import('@/views/order/completed/index.vue'),
                meta: {
                    title: '已完成订单',
                    icon: 'CircleCheck',
                    roles: ['admin', 'manager']
                }
            },
            {
                path: '/order/cancel',
                name: 'Cancel',
                component: () => import('@/views/order/cancel/index.vue'),
                meta: {
                    title: '已取消订单',
                    icon: 'CircleClose',
                    roles: ['admin', 'manager']
                }
            }
        ]
    },
    //发货管理
    {
        path: '/shipping',
        name: 'Shipping',
        component: () => import('@/layout/index.vue'),
        meta: {
            title: '发货管理',
            icon: 'Van',
            hidden: false, //隐藏菜单
        },
        redirect: '/shipping/pending', // 添加重定向
        children: [
            {
                path: '/shipping/pending',
                name: 'PendingDelivery',
                component: () => import('@/views/shipping/delivery/pending.vue'),
                meta: {
                    title: '待发货列表',
                    keepAlive: true,
                    icon: 'Box'
                }
            },
            {
                path: '/shipping/shipped',
                name: 'ShippedDelivery',
                component: () => import('@/views/shipping/delivery/shipped.vue'),
                meta: {
                    title: '已发货列表',
                    keepAlive: true,
                    icon: 'Ship'
                },
            },
            {
                path: '/shipping/info',
                name: 'LogisticsInfo',
                component: () => import('@/views/shipping/logistics/info.vue'),
                meta: {
                    title: '物流公司',
                    keepAlive: true,
                    icon: 'Location'
                }
            },
            {
                path: '/shipping/self-pickup',
                name: 'SelfPickup',
                component: () => import('@/views/shipping/logistics/self-pickup.vue'),
                meta: {
                    title: '自提管理',
                    keepAlive: true,
                    icon: 'TakeawayBox'
                }
            },
            {
                path: '/shipping/record',
                name: 'ShippingRecord',
                component: () => import('@/views/shipping/record/index.vue'),
                meta: {
                    title: '发货记录',
                    icon: 'Document',
                    keepAlive: true
                }
            },
            {
                path: '/shipping/freightrule',
                name: 'FreightRule',
                component: () => import('@/views/shipping/freightrule/index.vue'),
                meta: {
                    title: '运费规则',
                    icon: 'Setting',
                    roles: ['admin', 'manager']
                }
            }
        ]
    },
    //财务管理
    {
        path: '/bill',
        component: () => import('@/layout/index.vue'),
        meta: {
            title: '财务管理',
            icon: 'Van'
        },
        redirect: '/bill/freight', // 添加重定向
        children: [
            {
                path: '/bill/freight',
                name: 'FreightBill',
                component: () => import('@/views/bill/freight/index.vue'),
                meta: {
                    title: '运费账单',
                    icon: 'Document',
                    roles: ['admin', 'manager']
                }
            },
            {
                path: '/bill/diffprice',
                name: 'DiffPrice',
                component: () => import('@/views/bill/diffprice/index.vue'),
                meta: {
                    title: '差价账单',
                    icon: 'Document',
                    roles: ['admin', 'manager']
                }
            }
        ]
    },
    //404
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
    ////任意路由
    ,
    {
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