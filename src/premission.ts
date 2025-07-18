//路由鉴权（路由权限设置）
import router from './router'
import nprogress from 'nprogress';
import useUserStore from './store/modules/user';
import pinia from './store';
import 'nprogress/nprogress.css';
import { constantRoutes, asyncRoutes, anyRoutes } from '@/router/routes';

nprogress.configure({ showSpinner: false });

// 注册异步路由
function setUserAsyncRoutes(asyncRoutes: any[]) {
    asyncRoutes.forEach(route => {
        if (!router.hasRoute(route.name)) {
            router.addRoute(route);
        }
    });
}

// 注册常量路由和404路由
function setConstantRoutes() {
    constantRoutes.forEach(route => {
        if (!router.hasRoute(route.name)) {
            router.addRoute(route);
        }
    });
    
    // 注册404等任意路由
    anyRoutes.forEach(route => {
        if (!router.hasRoute(route.name)) {
            router.addRoute(route);
        }
    });
}

//全局前置守卫
router.beforeEach(async (to, from, next) => {
    nprogress.start();
    
    const userStore = useUserStore(pinia);
    
    // 确保数据完整性，强制恢复
    userStore.restoreFromLocalStorage();
    
    let token = userStore.token;
    let username = userStore.username;
    
    if (token) {
        if (to.path == '/login') {
            next({ path: '/' });
        } else {
            // 检查是否有完整的用户信息（包括权限）
            if (username && userStore.permissions && userStore.permissions.length > 0) {
                // 从菜单路由中提取异步路由进行注册
                const asyncRoutesToRegister = userStore.menuRoutes.filter(route => 
                    !constantRoutes.some(cr => cr.name === route.name)
                );
                
                // 只在路由不存在时注册
                const needRegister = asyncRoutesToRegister.some(route => !router.hasRoute(route.name));
                if (needRegister) {
                    setUserAsyncRoutes(asyncRoutesToRegister);
                    setConstantRoutes();
                    next({ ...to, replace: true });
                } else {
                    next();
                }
            } else {
                try {
                    await userStore.getUserInfo(); 
                    next({ ...to, replace: true });
                } catch (error) {
                    console.error('getUserInfo失败:', error);
                    await userStore.userLogout();                    
                    next({ path: '/login', query: { redirect: to.path } });
                }
            }
        }
    } else {
        if (to.path == '/login') {
            next();
        } else {
            next({ path: "/login", query: { redirect: to.path } });
        }
    }
})

//全局后置守卫
router.afterEach(() => {
    nprogress.done();
})
