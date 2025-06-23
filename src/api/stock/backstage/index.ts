//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    HTStock_URL = 'Dealer/adjust-stock',
    HTStockList_URL = 'Dealer/stock-xml',
    HTStockUpdate_URL = 'Dealer/stock-xml',    
}

//获取订单接口

export const HTStock = (data: any) => service.post<any, any>(API.HTStock_URL, data)
export const HTStockList = (dealerId: number | string) => service.get<any, any>(`${API.HTStockList_URL}/${dealerId}`)
export const HTStockUpdate = (dealerId: number | string, data: any) =>
  service.put<any, any>(`${API.HTStockUpdate_URL}/${dealerId}`, data)
