//创建用户相关小仓库
import { defineStore } from 'pinia';
//引入接口
import { reqLogin, reqUserInfo,reqLogout } from '@/api/user';
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
        async UserLogin(data:any) {
            //登录请求
            let result:any = await reqLogin(data);  
            console.log(result);
            if(result.code === 200){
                //获取token
                this.token = result.data.token;
                //本地存储token
                setToken(result.data.token);
                return "OK";
            }else{
                return Promise.reject(result.message || '登录失败');
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
            reqLogout(); 
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