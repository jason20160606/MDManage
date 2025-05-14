//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { login, reqUserInfo } from '@/api/user';
//引入登录参数类型
import type { LoginParams, LoginResponse } from '@/api/user/type';
import type { UserState } from './types/type';
import { setToken, getToken, removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoute } from '@/router/routes';
//创建一个新的小仓库
let useUserStore = defineStore('user', {
    //小仓库存储数据
    state: (): UserState => {
        return {
            //用户信息            
            //token
            token: getToken(),
            //菜单路由
            menuRoutes: constantRoute,
            //用户名
            username: '',
            //头像
            avatar: '',
            name: '',
            //按钮权限
            buttons: []
        };
    },
    actions: {
        //用户登录
        async userLogin(data: LoginParams) {
            let result: LoginResponse = await login(data);
            //console.log(result);
            if (result.code === 200) {
                //获取token
                this.token = result.data.token;
                //本地存储token
                setToken(result.data.token);
                //获取用户信息
                //this.userInfo = result.data.userInfo;
                return "OK";
            } else {
                //登录失败
                return Promise.reject(new Error(result.message));
            }
        },
        //获取用户信息方法
        async getUserInfo() {
            //获取用户信息
            let result = await reqUserInfo();
            //如果获取用户信息成功
            if (result.code === 200) {
                //存储用户信息
                this.username = result.data.username;
                this.avatar = result.data.avatar;
                this.name = result.data.name;
                return "OK";
            }else{
                return Promise.reject("获取用户信息失败"); 
            }
        },
        //退出登录
        userLogout() {
            //清空本地存储token
            this.token = '';
            this.username = '';
            this.avatar = '';
            this.name = '';
            this.buttons = [];
            removeToken();
        }
    },
    //小仓库的计算属性
    getters: {

    },
});
//导出小仓库
export default useUserStore;