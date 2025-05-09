//统一管理项目接口
import request from '@/utils/request'
import type  { LoginParams } from '@/api/user/type'
//统一管理接口
const enum API {
    LOGIN_URL = '/login', //登录接口
    USER_INFO_URL = '/user/info', //获取用户信息接口
} 
//暴漏请求函数  
//登录接口
export const login = (data: LoginParams) => {
    return request({
        url: API.LOGIN_URL,
        method: 'post',
        data
    })
}
//获取用户信息接口
export const getUserInfo = () => {
    return request({
        url: API.USER_INFO_URL,
        method: 'get'
    })
}