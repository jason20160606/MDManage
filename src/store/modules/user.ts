//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqLogin, reqUserInfo } from '@/api/user/index';
import { removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoutes, asyncRoutes } from '@/router/routes';
import type { loginFormData } from '@/api/user/type';
import router from '@/router';

// 权限过滤函数：返回新对象，不改写共享的 asyncRoutes
function filterAsyncRoutes(routes: any[], permissions: string[]): any[] {
    const result: any[] = [];
    routes.forEach(route => {
        if (route.meta && route.meta.roles) {
            const hasPermission = route.meta.roles.some((role: string) => permissions.includes(role));
            if (!hasPermission) {
                return;
            }
        }
        const item = { ...route };
        if (route.children && route.children.length) {
            item.children = filterAsyncRoutes(route.children, permissions);
        }
        result.push(item);
    });
    return result;
}

// 注册异步路由
function setUserAsyncRoutes(asyncRoutes: any[]) {
    asyncRoutes.forEach(route => {
        if (route.name && router.hasRoute(route.name)) {
            router.removeRoute(route.name);
        }
        router.addRoute(route);
    });
}

// 注册常量路由
function setConstantRoutes() {
    constantRoutes.forEach(route => {
        if (!router.hasRoute(route.name)) {
            router.addRoute(route);
        }
    });
}

//创建一个新的小仓库
const useUserStore = defineStore('user', {
    //小仓库存储数据
    state: (): any => {
        return {
            //token
            token: localStorage.getItem('access_token') || '',
            refreshToken: localStorage.getItem('refresh_token') || '',
            //用户名
            username: localStorage.getItem('username') || '',
            //头像
            avatar: localStorage.getItem('avatar') || '',
            //昵称
            nickname: localStorage.getItem('nickname') || '',
            //用户信息
            userInfo: JSON.parse(localStorage.getItem('userInfo') || 'null'),
            //菜单路由 - 从localStorage恢复
            menuRoutes: JSON.parse(localStorage.getItem('menuRoutes') || JSON.stringify(constantRoutes)),
            // 权限码唯一来源是服务端 userinfo：不从 localStorage 恢复，避免本地篡改放出菜单
            buttons: [],
            permissions: [],
            // 仅内存态：刷新页面后为 false，守卫会重新向服务端拉取权限码
            permissionsVerified: false,
            // 校验过的 token：换账号（token 变化）时强制重新校验权限
            verifiedToken: ''
        };
    },
    actions: {
        //用户登录
        async UserLogin(data: loginFormData) {
            try {
                //登录请求
                const res: any = await reqLogin(data);
                // 响应拦截器已解包 Data，这里兼容解包前后两种结构
                const auth = res?.Data ?? res;
                if (auth?.AccessToken) {
                    this.token = auth.AccessToken;
                    this.refreshToken = auth.RefreshToken;
                    localStorage.setItem('access_token', auth.AccessToken);
                    localStorage.setItem('refresh_token', auth.RefreshToken);
                } else {
                    // 没拿到 token 说明登录未成功，直接终止，避免后续 userinfo 请求 401
                    throw new Error('登录失败：未获取到 Token');
                }
                //获取用户信息
                const userInfoRes = await reqUserInfo(); 
                this.userInfo = userInfoRes;              
                this.username = userInfoRes.Username;
                this.avatar = userInfoRes.Avatar;
                this.nickname = userInfoRes.Nickname;
                this.permissions = userInfoRes.Permissions;
                
                // 动态路由权限处理
                const userAsyncRoutes = filterAsyncRoutes(asyncRoutes, this.permissions.map(p => p.Code));
                // 合并常量路由和用户有权限的异步路由
                this.menuRoutes = [...constantRoutes, ...userAsyncRoutes];
                
                // 注册异步路由，防止点击菜单白页
                setUserAsyncRoutes(userAsyncRoutes);
                // 注册常量路由，防止刷新后丢失
                setConstantRoutes();
                
                // 同步到localStorage
                this.permissionsVerified = true;
                this.verifiedToken = this.token;
                this.syncToLocalStorage();
                
                return "OK";
            } catch (error) {                
                return Promise.reject(error);
            }
        },
        
        //获取用户信息方法
        async getUserInfo() {
            try {
                //获取用户信息
                const userInfoRes = await reqUserInfo(); 
                this.userInfo = userInfoRes;              
                this.username = userInfoRes.Username;
                this.avatar = userInfoRes.Avatar;
                this.nickname = userInfoRes.Nickname;
                this.permissions = userInfoRes.Permissions;
                
                // 动态路由权限处理 - 这里保留，用于生成菜单
                const userAsyncRoutes = filterAsyncRoutes(asyncRoutes, this.permissions.map(p => p.Code));
                // 合并常量路由和用户有权限的异步路由
                this.menuRoutes = [...constantRoutes, ...userAsyncRoutes];
                
                // 注册异步路由，防止刷新后路由丢失
                setUserAsyncRoutes(userAsyncRoutes);
                // 注册常量路由
                setConstantRoutes();
                
                // 同步到localStorage
                this.permissionsVerified = true;
                this.verifiedToken = this.token;
                this.syncToLocalStorage();
                
                return "OK";
            } catch (error) {                
                return Promise.reject(error);
            }
        },
        
        //退出登录
        userLogout() {
            this.token = '';
            this.refreshToken = '';
            this.userInfo = null;
            this.username = '';
            this.avatar = '';
            this.nickname = '';
            this.permissions = [];
            this.buttons = [];
            // 撤销本次登录动态注册的路由，避免换账号后残留上一个账号的页面
            try {
                const dynamicNames = (this.menuRoutes || [])
                    .filter((r: any) => r.name && !constantRoutes.some(cr => cr.name === r.name))
                    .map((r: any) => r.name);
                dynamicNames.forEach((name: string) => {
                    if (router.hasRoute(name)) {
                        router.removeRoute(name);
                    }
                });
            } catch (e) {
                console.warn('清理动态路由失败:', e);
            }
            this.menuRoutes = constantRoutes;
            this.permissionsVerified = false;
            this.verifiedToken = '';
            
            // 清除localStorage
            this.clearLocalStorage();
            removeToken();
        },
        
        // 同步数据到localStorage
        syncToLocalStorage() {
            localStorage.setItem('username', this.username || '');
            localStorage.setItem('avatar', this.avatar || '');
            localStorage.setItem('nickname', this.nickname || '');
            localStorage.setItem('userInfo', JSON.stringify(this.userInfo || null));
            // 不存储 menuRoutes，因为会丢失组件信息
            localStorage.setItem('buttons', JSON.stringify(this.buttons || []));
            localStorage.setItem('permissions', JSON.stringify(this.permissions || []));
        },
        
        // 清除localStorage
        clearLocalStorage() {
            localStorage.removeItem('access_token');
            localStorage.removeItem('refresh_token');
            localStorage.removeItem('username');
            localStorage.removeItem('avatar');
            localStorage.removeItem('nickname');
            localStorage.removeItem('userInfo');
            localStorage.removeItem('buttons');
            localStorage.removeItem('permissions');
        },
        
        // 从localStorage恢复状态
        restoreFromLocalStorage() {
            this.token = localStorage.getItem('access_token') || '';
            this.refreshToken = localStorage.getItem('refresh_token') || '';
            this.username = localStorage.getItem('username') || '';
            this.avatar = localStorage.getItem('avatar') || '';
            this.nickname = localStorage.getItem('nickname') || '';
            this.userInfo = JSON.parse(localStorage.getItem('userInfo') || 'null');

            // 恢复后重新生成路由
            if (this.username && this.permissions.length > 0) {
                const userAsyncRoutes = filterAsyncRoutes(asyncRoutes, this.permissions.map(p => p.Code));
                this.menuRoutes = [...constantRoutes, ...userAsyncRoutes];
            } else {
                this.menuRoutes = constantRoutes;
            }
        }
    },
    //小仓库的计算属性
    getters: {

    },
});

// 默认导出
export default useUserStore;
