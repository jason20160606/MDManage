//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    ORDERlIST_URL = '/Order', //订单列表接口（增删改查）    
    IMPORT_ORDERS_URL = '/Order/import',       //导入订单接口
    AUDIT_ORDER_URL = '/Order/audit',          //审核订单接口
    BATCHAUDIT_ORDER_URL = '/Order/batch-audit'//批量审核订单
    

    
}
//暴漏请求函数  
//获取订单接口 list
export const reqOrderlist = (data: any) => service.get<any, any>(API.ORDERlIST_URL, { params: data })
//查看订单接口(单个)
export const reqCheckOrder = (orderId: string) => service.get<any, any>(`${API.ORDERlIST_URL}/${orderId}`)
//创建订单接口
export const reqAddOrder = (orderData: any) => service.post<any, any>(API.ORDERlIST_URL, orderData)
//更新订单接口
export const reqUpdateOrder = (orderId: string, orderData: any) => service.put<any, any>(`${API.ORDERlIST_URL}/${orderId}`, orderData)

//删除订单接口
export const reqDeleteOrder = (orderId: string) => service.delete<any, any>(`${API.ORDERlIST_URL}/${orderId}`)
//导入订单接口
export const reqImportOrders = (formData: FormData) => service.post<any, any>(API.IMPORT_ORDERS_URL, formData, {
  headers: {
    'Content-Type': 'multipart/form-data'
  }
})

//审核订单接口
export const reqAuditOrder = (orderId: string, auditDto: any) => service.post<any, any>(`${API.AUDIT_ORDER_URL}/${orderId}`, auditDto)

//取消订单接口
export const reqCancelOrder = (orderId: string) => service.put<any, any>(`${API.ORDERlIST_URL}/${orderId}/cancel`)

//批量审核订单接口
export const reqBatchAuditOrder = (orderIds: number[], remark: string) => service.post<any, any>(API.BATCHAUDIT_ORDER_URL, { orderIds, remark })





