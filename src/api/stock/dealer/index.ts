//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
   
    DealerList_URL = 'Dealer',
}

//获取订单接口


// 获取经销商列表，支持名称模糊查询
export const getDealerList = (Name?: string) => service.get<any, any>(API.DealerList_URL, { params: Name ? { Name } : {} })