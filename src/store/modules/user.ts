//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqLogin, reqUserInfo } from '@/api/user';
import { setToken, getToken, removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoutes } from '@/router/routes';
import type { loginFormData } from '@/api/user/type';

//创建一个新的小仓库
let useUserStore = defineStore('user', {
    //小仓库存储数据
    state: (): any => {
        return {
            //用户信息            
            //token
            token: getToken(),
            //用户名
            username: '',
            //头像
            avatar: '',
            //昵称
            nickname: '',
            //菜单路由
            menuRoutes: [],
            //按钮权限
            buttons: []
        };
    },
    actions: {
        //用户登录
        async UserLogin(data: loginFormData) {
            try {
                //登录请求
                let result: any = await reqLogin(data);
                if (result.status == 200) {
                    //获取token
                    this.token = result.data.id as string;
                    this.nickname = result.data.nickname;
                    //本地存储token
                    setToken(result.data.id);
                    return "OK";
                } else {
                    return Promise.reject(new Error(result.message || '登录失败'));
                }
            } catch (error) {
                return Promise.reject(error);
            }
        },
        //获取用户信息方法
        async getUserInfo(token: any) {
            try {
                //获取用户信息
                let result: any = await reqUserInfo(token);
                //如果获取用户信息成功
                if (result.status == 200) {
                    //存储用户信息
                    this.username = result.data.username;
                    this.avatar = result.data.avatar;
                    this.nickname = result.data.nickname;
                    // 更新菜单路由，包含基础路由和动态路由
                    if (result.data.routes) {
                        // 合并基础路由和动态路由
                        this.menuRoutes = [...constantRoutes, ...result.data.routes];
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
        async userLogout() {
            //let result:any = await reqLogout(); 
            //console.log(result);
            //清空本地存储token
            this.token = '';
            this.username = '';
            this.avatar = '';
            this.name = '';
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