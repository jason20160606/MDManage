//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
   
    DealerList_URL = 'Dealer',
    DealerStock_URL = 'DealerQuotaLog',

}

//获取订单接口


// 获取经销商列表，支持名称模糊查询和分页
export const getDealerList = (params: any = {}) => service.get<any, any>(API.DealerList_URL, { params })

// 获取经销商库存日志
export const getDealerQuotaLog = (params: any = {}) => service.get<any, any>(API.DealerStock_URL, { params })

// 获取经销商详情（通过id）
export const getDealerDetail = (id: number|string) => service.get<any, any>(`${API.DealerList_URL}/${id}`)