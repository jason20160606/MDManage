//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    HTStock_URL = 'Dealer/adjust-stock',
    HTStockList_URL = 'Dealer/stock-xml',
    HTStockUpdate_URL = 'Dealer/stock-xml',    
}

//后台经销商库存计算
export const HTStock = (data: any) => service.post<any, any>(API.HTStock_URL, data)
//获取经销商后台列表
export const HTStockList = (dealerId: number | string) => service.get<any, any>(`${API.HTStockList_URL}/${dealerId}`)
//更新经销商后台列表
export const HTStockUpdate = (dealerId: number | string, data: any) => service.put<any, any>(`${API.HTStockUpdate_URL}/${dealerId}`, data)
