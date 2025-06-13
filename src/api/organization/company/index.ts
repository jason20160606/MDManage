//管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //公司列表
    GETBrandLIST_URL = '/Brand', 
}
//获取公司列表
export const reqGetBrandList = () => request.get<any, any>(API.GETBrandLIST_URL);