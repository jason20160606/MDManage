//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqLogin, reqUserInfo } from '@/api/user/index';
import { removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoutes, asyncRoutes } from '@/router/routes';
import type { loginFormData } from '@/api/user/type';
import router from '@/router';

//创建一个新的小仓库
export const useUserStore = defineStore('user', {
    //小仓库存储数据
    state: (): any => {
        // 从本地存储恢复token和用户信息，防止刷新丢失
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
            userInfo: null,
            //菜单路由
            menuRoutes: constantRoutes,         //初始路由
            //按钮权限
            buttons: [],
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
                console.log(asyncRoutes)
                const userAsyncRoutes = filterAsyncRoutes(asyncRoutes, this.permissions.map(p => p.Code));
                console.log(userAsyncRoutes)
                // 合并常量路由和用户有权限的异步路由
                this.menuRoutes = [...constantRoutes, ...userAsyncRoutes];
                // 注册异步路由，防止点击菜单白页
                setUserAsyncRoutes(userAsyncRoutes);
                // 注册常量路由，防止刷新后丢失
                setConstantRoutes();
                // 同步本地存储
                localStorage.setItem('username', this.username || '');
                localStorage.setItem('avatar', this.avatar || '');
                localStorage.setItem('nickname', this.nickname || '');
                localStorage.setItem('permissions', JSON.stringify(this.permissions || []));
                
                return "OK";
            } catch (error) {                
                return Promise.reject(error);
            }
        },
        //获取用户信息方法
        async getUserInfo() {
            try {
                //获取用户信息
                let result: any = await reqUserInfo();                
                //如果获取用户信息成功
                if (result.status == 200) {
                    //存储用户信息
                    this.username = result.username;
                    this.avatar = result.avatar;
                    this.nickname = result.nickname;
                    this.roles = result.roles;
                    this.permissions = result.Permissions;
                    // 动态路由权限处理
                    const userAsyncRoutes = filterAsyncRoutes(asyncRoutes, this.permissions.map(p => p.Code));
                    // 合并常量路由和用户有权限的异步路由
                    this.menuRoutes = [...constantRoutes, ...userAsyncRoutes];
                    // 注册异步路由，防止点击菜单白页
                    setUserAsyncRoutes(userAsyncRoutes);
                    // 注册常量路由，防止刷新后丢失
                    setConstantRoutes();
                    // 同步本地存储
                    localStorage.setItem('username', this.username || '');
                    localStorage.setItem('avatar', this.avatar || '');
                    localStorage.setItem('nickname', this.nickname || '');                    
                    localStorage.setItem('permissions', JSON.stringify(this.permissions || []));                    
                    return "OK";
                } else {
                    return Promise.reject(new Error(result.message || '获取用户信息失败'));
                }
            } catch (error) {
                // 如果接口失败，尝试从本地恢复（兼容token有效但接口异常场景）
                if (this.token && this.username) {
                    setConstantRoutes();
                    this.menuRoutes = constantRoutes;
                    return "OK";
                }
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
            this.menuRoutes = [];
            // 清除本地存储
            localStorage.removeItem('access_token');
            localStorage.removeItem('refresh_token');
            localStorage.removeItem('username');
            localStorage.removeItem('avatar');
            localStorage.removeItem('nickname');
            localStorage.removeItem('permissions');
            removeToken();
        }
    },
    //小仓库的计算属性
    getters: {

    },
});
//导出小仓库
export default useUserStore;
// 注册常量路由到Vue Router，防止刷新后丢失
function setConstantRoutes() {
    constantRoutes.forEach(route => {
        if (!router.hasRoute(route.name)) {
            router.addRoute(route);
        }
        // 递归注册子路由
        if (route.children && route.children.length > 0) {
            route.children.forEach(child => {
                if (!router.hasRoute(child.name)) {
                    router.addRoute(route.name, child);
                }
            });
        }
    });
}

// 恢复动态路由（用于刷新后自动注册）
export function restoreUserRoutes() {    
    const permissions = JSON.parse(localStorage.getItem('permissions') || '[]');
    const token = localStorage.getItem('access_token');
    if (token && permissions.length > 0) {
        const codes = permissions.map((p: any) => p.Code);
        const userAsyncRoutes = filterAsyncRoutes(asyncRoutes, codes);
        setUserAsyncRoutes(userAsyncRoutes);
        setConstantRoutes();
        // 恢复菜单路由到pinia        
        // 强制刷新当前路由，确保页面渲染
        if (!router.hasRoute(router.currentRoute.value.name)) {
            router.replace(router.currentRoute.value.fullPath);
        }
    }
}

// 注册用户有权限的异步路由到Vue Router
function setUserAsyncRoutes(userAsyncRoutes) {
    userAsyncRoutes.forEach(route => {
        if (!router.hasRoute(route.name)) {
            router.addRoute(route);
        }
        // 递归注册子路由
        if (route.children && route.children.length > 0) {
            route.children.forEach(child => {
                if (!router.hasRoute(child.name)) {
                    router.addRoute(route.name, child);
                }
            });
        }
    });
}

// 工具函数：根据权限集合筛选异步路由（用name字段匹配权限Code）
function filterAsyncRoutes(routes: any[], permissions: any[]): any[] {
    return routes.reduce((acc, route) => {
        const r = { ...route };
        if (r.children && r.children.length > 0) {
            r.children = filterAsyncRoutes(r.children, permissions);
        }
        // 用name字段作为权限标识
        if (!r.name || permissions.includes(r.name)) {
            acc.push(r);
        }
        return acc;
    }, []);
}
