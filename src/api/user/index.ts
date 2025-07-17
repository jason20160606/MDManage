//统一管理项目接口
import service from '@/utils/request'
import type { loginFormData, loginResponseData } from './type'
//统一管理接口
const enum API {
    LOGIN_URL = '/User/Login', //登录接口
    USER_INFO_URL = '/User/userinfo', //获取用户信息接口
    LOGOUT_URL = '/logout', //退出登录接口
    AUTH_URL = '/Login', //获取token
    AUTHREFRESH_URL = '/Auth/refresh', //刷新token
    
}
//暴漏请求函数  
//登录接口
export const reqLogin = (data: loginFormData) => service.post<any, any>(API.LOGIN_URL, data)
//获取用户信息接口
export const reqUserInfo = () => service.get<any, any>(API.USER_INFO_URL);
//退出登录接口
export const reqLogout = () => service.post<any, any>(API.LOGOUT_URL);
// 修改密码接口
export const reqChangePassword = (data: { OldPassword: string, NewPassword: string }) =>
  service.put<any, any>('/User/pwd', data)
// 修改头像接口
export const reqChangeAvatar = (data: { Avatar: string }) =>
  service.put<any, any>('/User/avatar', data)