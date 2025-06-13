//管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //经销商列表
    GETDealerLIST_URL = '/Dealer', 
}
//获取经销商列表
export const reqGetDealerList = () => request.get<any, any>(API.GETDealerLIST_URL);