//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqLogin, reqUserInfo,reqLogout } from '@/api/user';
import type { UserState } from './types/type';
import { setToken, getToken, removeToken } from '@/utils/token';
//引入路由(常量路由)
import { constantRoute } from '@/router/routes';
import type { loginFormData, loginResponseData, userInfoData } from '@/api/user/type';

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
        async UserLogin(data:loginFormData) {
            //登录请求
            let result:loginResponseData = await reqLogin(data);  
            console.log(result);
            if(result.code == 200){
                //获取token
                this.token = result.data;
                //本地存储token
                setToken(result.data);
                return "OK";
            }else{
                return Promise.reject(new Error(result.message || '密码错误'));
            }
        },
        //获取用户信息方法
        async getUserInfo() {
            //获取用户信息
            let result:userInfoData = await reqUserInfo();
            //如果获取用户信息成功
            if (result.code == 200) {
                //存储用户信息
                this.username = result.data.username;
                this.avatar = result.data.avatar;
                this.name = result.data.username;
                return "OK";
            }else{
                return Promise.reject(new Error(result.message || '获取用户信息失败')); 
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
            removeToken();
        }
    },
    //小仓库的计算属性
    getters: {

    },
});
//导出小仓库
export default useUserStore;