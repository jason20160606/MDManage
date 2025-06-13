//管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //工厂列表
    GETFactoryLIST_URL = '/Factory', 
}
//获取工厂列表
export const reqGetFactoryList = () => request.get<any, any>(API.GETFactoryLIST_URL);