//统一管理项目接口
import service from '@/utils/request'
import type { loginFormData } from './type'
//统一管理接口
const enum API {
    LOGIN_URL = '/User/Login', //登录接口
    USER_INFO_URL = '/User/userinfo', //获取用户信息接口
    LOGOUT_URL = '/logout', //退出登录接口
    AUTH_URL = '/Login', //获取token
    AUTHREFRESH_URL = '/Auth/refresh', //刷新token
    
}
//登录接口
export const reqLogin = (data: loginFormData) => service.post<any, any>(API.LOGIN_URL, data)
//获取用户信息接口
export const reqUserInfo = () => service.get<any, any>(API.USER_INFO_URL);
//退出登录接口
// 修改密码接口
export const reqChangePassword = (data: { OldPassword: string, NewPassword: string }) =>
  service.put<any, any>('/User', data)
// 修改头像接口
export const reqChangeAvatar = (data: { Avatar: string }) =>
  service.put<any, any>('/User', data)
/**
 * 上传图片，返回后端给的相对路径（Data/UserImages/xxx.webp）。
 * 走统一请求实例，才会带上 Authorization；el-upload 直接 POST 会返回 401。
 * type: UserImages / spuMain / skuMain / skuDetailed
 */
export const reqUploadImage = (file: File, type = 'UserImages') => {
    const fd = new FormData()
    fd.append('type', type)
    fd.append('file', file)
    return service.post<any, any>('/Upload', fd, {
        headers: { 'Content-Type': 'multipart/form-data' },
        silent: true
    } as any)
}
