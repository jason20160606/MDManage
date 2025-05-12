//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { login } from '@/api/user';
//引入登录参数类型
import type { LoginParams, LoginResponse } from '@/api/user/type';
import type { UserState } from './types/type';
import { setToken, getToken } from '@/utils/token';
//创建一个新的小仓库
let useUserStore = defineStore('user', {
    //小仓库存储数据
    state: (): UserState => {
        return {
            //用户信息            
            //token
            token: getToken(),
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
        //设置用户信息

    },
    //小仓库的计算属性
    getters: {

    },
});
//导出小仓库
export default useUserStore;