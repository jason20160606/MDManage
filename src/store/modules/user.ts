//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqAuthLogin, reqUserInfo } from '@/api/user/index';
import { setToken, getToken, removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoutes } from '@/router/routes';
import type { loginFormData } from '@/api/user/type';

//创建一个新的小仓库
export const useUserStore = defineStore('user', {
    //小仓库存储数据
    state: (): any => {
        return {
            //用户信息            
            //token
            token: '',
            refreshToken: '',
            userInfo: null,
            //用户名
            username: '',
            //头像
            avatar: '',
            //昵称
            nickname: '',
            //菜单路由
            menuRoutes: [],
            //按钮权限
            buttons: [],
            roles: []
        };
    },
    actions: {
        //用户登录
        async UserLogin(data: loginFormData) {
            try {
                //登录请求
                const res = await reqAuthLogin(data);
                console.log(res)
                this.token = res.data.access_token;
                this.refreshToken = res.data.refresh_token;
                localStorage.setItem('access_token', res.access_token);
                localStorage.setItem('refresh_token', res.refresh_token);
                //获取用户信息
                const userInfoRes = await reqUserInfo();
                console.log(userInfoRes)
                this.userInfo = userInfoRes;
                this.username = userInfoRes.data.Username;
                this.avatar = userInfoRes.data.Avatar;
                this.nickname = userInfoRes.data.Nickname;
                this.roles = userInfoRes.data.Roles;
                // 更新菜单路由，包含基础路由和动态路由
                if (userInfoRes.data.Routes) {
                    // 合并基础路由和动态路由
                    this.menuRoutes = [...constantRoutes, ...userInfoRes.data.routes];
                } else {
                    this.menuRoutes = constantRoutes;
                }
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
                    // 更新菜单路由，包含基础路由和动态路由
                    if (result.routes) {
                        // 合并基础路由和动态路由
                        this.menuRoutes = [...constantRoutes, ...result.routes];
                    } else {
                        this.menuRoutes = constantRoutes;
                    }
                    return "OK";
                } else {
                    return Promise.reject(new Error(result.message || '获取用户信息失败'));
                }
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
            this.roles = [];
            this.buttons = [];
            this.menuRoutes = [];
            removeToken();
        }
    },
    //小仓库的计算属性
    getters: {

    },
});
//导出小仓库
export default useUserStore;