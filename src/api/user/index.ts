//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    LOGIN_URL = '/login', //登录接口
    USER_INFO_URL = '/SysUser', //获取用户信息接口
    LOGOUT_URL = '/logout' //退出登录接口
}
//暴漏请求函数  
//登录接口
export const reqLogin = (data: any) => service.post<any, any>(API.LOGIN_URL, data)
//获取用户信息接口
export const reqUserInfo = () => service.get<any, any>(API.USER_INFO_URL);
//退出登录接口
export const reqLogout = () => service.post<any, any>(API.LOGOUT_URL);