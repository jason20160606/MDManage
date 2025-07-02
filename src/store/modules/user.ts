//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqAuthLogin, reqUserInfo } from '@/api/user/index';
import { removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoutes } from '@/router/routes';
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
            roles: JSON.parse(localStorage.getItem('roles') || '[]')
        };
    },
    actions: {
        //用户登录
        async UserLogin(data: loginFormData) {
            try {
                //登录请求
                const res = await reqAuthLogin(data);               
                this.token = res.data.access_token;
                this.refreshToken = res.data.refresh_token;
                localStorage.setItem('access_token', res.data.access_token);
                localStorage.setItem('refresh_token', res.data.refresh_token);
                //获取用户信息
                const userInfoRes = await reqUserInfo();               
                this.userInfo = userInfoRes;
                this.username = userInfoRes.data.Username;
                this.avatar = userInfoRes.data.Avatar;
                this.nickname = userInfoRes.data.Nickname;
                this.roles = userInfoRes.data.Roles;
                // 同步本地存储
                localStorage.setItem('username', this.username || '');
                localStorage.setItem('avatar', this.avatar || '');
                localStorage.setItem('nickname', this.nickname || '');
                localStorage.setItem('roles', JSON.stringify(this.roles || []));
                // 注册常量路由，防止刷新后丢失
                setConstantRoutes();
                // 更新菜单路由，包含基础路由和动态路由
                this.menuRoutes = constantRoutes;
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
                    // 同步本地存储
                    localStorage.setItem('username', this.username || '');
                    localStorage.setItem('avatar', this.avatar || '');
                    localStorage.setItem('nickname', this.nickname || '');
                    localStorage.setItem('roles', JSON.stringify(this.roles || []));
                    // 注册常量路由，防止刷新后丢失
                    setConstantRoutes();
                    // 更新菜单路由，包含基础路由和动态路由
                    this.menuRoutes = constantRoutes;
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
            this.roles = [];
            this.buttons = [];
            this.menuRoutes = [];
            // 清除本地存储
            localStorage.removeItem('access_token');
            localStorage.removeItem('refresh_token');
            localStorage.removeItem('username');
            localStorage.removeItem('avatar');
            localStorage.removeItem('nickname');
            localStorage.removeItem('roles');
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