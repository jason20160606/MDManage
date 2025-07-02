//统一管理项目接口
import service from '@/utils/request'
import type { loginFormData, loginResponseData } from './type'
//统一管理接口
const enum API {
    LOGIN_URL = '/User/Login', //登录接口
    USER_INFO_URL = '/User/userinfo', //获取用户信息接口
    LOGOUT_URL = '/logout', //退出登录接口
    AUTH_URL = '/Auth/Login', //获取token
    AUTHREFRESH_URL = '/Auth/refresh', //刷新token
}
//暴漏请求函数  
//登录接口
export const reqLogin = (data: loginFormData) => service.post<any, loginResponseData>(API.LOGIN_URL, data)
//获取用户信息接口
export const reqUserInfo = () => service.get<any, any>(API.USER_INFO_URL);
//退出登录接口
export const reqLogout = () => service.post<any, any>(API.LOGOUT_URL);
// 登录接口（Auth）
export const reqAuthLogin = (data: loginFormData) => service.post<any,any>(API.AUTH_URL, data)