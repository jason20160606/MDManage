//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    ORDERlIST_URL = '/Order/AllOrder', //订单列表接口
    CONFIRM_ORDER_URL = '/Order/ConfirmOrder', //确认订单接口
    CANCEL_ORDER_URL = '/Order/CancelOrder', //取消订单接口
    DELETE_ORDER_URL = '/Order/DeleteOrder', //删除订单接口
    IMPORT_ORDERS_URL = '/Order/ImportOrders', //导入订单接口
}
//暴漏请求函数  
//获取订单接口
export const reqOrderlist = (data: any) => service.get<any, any>(API.ORDERlIST_URL, { params: data })

//确认订单接口
export const reqConfirmOrder = (orderId: string) => service.put<any, any>(`${API.CONFIRM_ORDER_URL}/${orderId}`)

//取消订单接口
export const reqCancelOrder = (orderId: string) => service.put<any, any>(`${API.CANCEL_ORDER_URL}/${orderId}`)

//删除订单接口
export const reqDeleteOrder = (orderId: string) => service.delete<any, any>(`${API.DELETE_ORDER_URL}/${orderId}`)

//导入订单接口
export const reqImportOrders = (formData: FormData) => service.post<any, any>(API.IMPORT_ORDERS_URL, formData, {
  headers: {
    'Content-Type': 'multipart/form-data'
  }
})