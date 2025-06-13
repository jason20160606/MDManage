//统一管理项目接口
import service from '@/utils/request'
import type { loginFormData, loginResponseData, userInfoData } from './type'
//统一管理接口
const enum API {
    LOGIN_URL = '/User/Login', //登录接口
    USER_INFO_URL = '/User', //获取用户信息接口
    LOGOUT_URL = '/logout' //退出登录接口
}
//暴漏请求函数  
//登录接口
export const reqLogin = (data: loginFormData) => service.post<any, loginResponseData>(API.LOGIN_URL, data)
//获取用户信息接口
export const reqUserInfo = (token:string) => service.get<any, userInfoData>(API.USER_INFO_URL+`/${token}`);
//退出登录接口
export const reqLogout = () => service.post<any, any>(API.LOGOUT_URL);