//菜单管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //获取菜单地址
    GETMENU_URL = '/Premission',     
}   
//获取菜单信息接口方法，支持分页参数
export const reqMenuInfo = (params?: any) => request.get<any, any>(API.GETMENU_URL, { params });