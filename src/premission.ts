//路由鉴权（路由权限设置）
import router from './router'
import nprogress from 'nprogress';
import useUserStore from './store/modules/user';
import pinia from './store';
import 'nprogress/nprogress.css';
import { constantRoutes, anyRoutes } from '@/router/routes';

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
router.beforeEach(async (to, _from, next) => {
    nprogress.start();
    
    const userStore = useUserStore(pinia);
    
    // 仅恢复 token 等基础信息；权限码随后一律以服务端返回为准
    userStore.restoreFromLocalStorage();
    
    let token = userStore.token;
    
    if (token) {
        if (to.path == '/login') {
            next({ path: '/' });
        } else {
            // 每次页面加载都重新向服务端拉一次用户信息与权限码：
            // localStorage 里的 permissions 不参与判定，手改本地存储不能放出菜单。
            let justFetched = false;
            if (!userStore.permissionsVerified || userStore.verifiedToken !== userStore.token) {
                try {
                    await userStore.getUserInfo();
                    justFetched = true;
                } catch (error) {
                    console.error('getUserInfo失败:', error);
                    await userStore.userLogout();
                    next({ path: '/login', query: { redirect: to.path } });
                    return;
                }
            }

            // 页面级守卫：直接输入 URL、或本地权限被篡改时也要拦住
            const required = (to.meta as any)?.roles as string[] | undefined;
            const owned: string[] = (userStore.permissions || []).map((p: any) => p.Code);
            if (required && required.length > 0 && !required.some(r => owned.includes(r))) {
                next({ path: '/403' });
                return;
            }
            
            // 从菜单路由中提取异步路由进行注册
            const asyncRoutesToRegister = userStore.menuRoutes.filter(route => 
                !constantRoutes.some(cr => cr.name === route.name)
            );
            
            const missing = asyncRoutesToRegister.some(route => !router.hasRoute(route.name));
            if (missing) {
                setUserAsyncRoutes(asyncRoutesToRegister);
            }
            // 404 / 任意路由也要在重新导航前注册好，否则不存在的地址会一直 no-match
            setConstantRoutes();

            // 关键：F5 刷新或直接输入动态路由地址时，vue-router 在守卫执行前
            // 已经把该地址解析成 "no match"（此时动态路由还没注册）。
            // 即便这里补注册了路由，直接 next() 仍会沿用旧的空匹配结果 → 白页。
            // 必须重新导航一次，让路由表按注册后的结果重新解析。
            if (justFetched || missing || to.matched.length === 0) {
                next({ ...to, replace: true });
                return;
            }
            next();
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
