//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqLogin, reqUserInfo } from '@/api/user/index';
import { removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoutes, asyncRoutes } from '@/router/routes';
import type { loginFormData } from '@/api/user/type';
import router from '@/router';

// 权限过滤函数
function filterAsyncRoutes(routes: any[], permissions: string[]): any[] {
    return routes.filter(route => {
        if (route.meta && route.meta.roles) {
            // 如果路由有权限要求，检查用户是否有对应权限
            const hasPermission = route.meta.roles.some((role: string) => permissions.includes(role));
            if (!hasPermission) {
                return false;
            }
        }
        // 递归过滤子路由
        if (route.children && route.children.length) {
            route.children = filterAsyncRoutes(route.children, permissions);
        }
        return true;
    });
}

// 注册异步路由
function setUserAsyncRoutes(asyncRoutes: any[]) {
    asyncRoutes.forEach(route => {
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
            //按钮权限
            buttons: JSON.parse(localStorage.getItem('buttons') || '[]'),
            permissions: JSON.parse(localStorage.getItem('permissions') || '[]')
        };
    },
    actions: {
        //用户登录
        async UserLogin(data: loginFormData) {
            try {
                //登录请求
                const res = await reqLogin(data);     
                if(res.data.Data){
                    this.token = res.data.Data.AccessToken;
                    this.refreshToken = res.data.Data.RefreshToken;
                    localStorage.setItem('access_token', res.data.Data.AccessToken);
                    localStorage.setItem('refresh_token', res.data.Data.RefreshToken);
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
            this.menuRoutes = constantRoutes;
            
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
            this.permissions = JSON.parse(localStorage.getItem('permissions') || '[]');
            this.buttons = JSON.parse(localStorage.getItem('buttons') || '[]');
            
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
