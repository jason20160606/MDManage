//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    ORDERlIST_URL = '/Order',                               //订单列表接口（增删改查）    
    IMPORT_ORDERS_URL = '/Order/import',                    //导入订单接口
    EXPORT_ORDERS_URL = '/Order/export',                    //导出订单接口
    AUDIT_ORDER_URL = '/Order/audit',                       //审核订单接口
    BATCHAUDIT_ORDER_URL = '/Order/batch-audit',            //批量审核订单
    SHIPPED_ORDER_URL = '/Order/ship',                      //发货订单
    BATCHSHIPPED_ORDER_URL = '/Order/batch-ship',           //批量发货订单
    SHIPPEDlIST_URL = '/Order/shipped',                     //获取已发货订单列表   
    CONFIRM_RECEIPT_URL = '/Order/confirm-receipt',         //单个确认收货
    BATCH_CONFIRM_RECEIPT_URL = '/Order/batch-confirm-receipt', //批量确认收货
    COMPLETED_ORDERlIST_URL = '/Order/completed',           //获取已完成订单
    ORDERADRESSUPDATE_URL = '/Order/address',               //修改地址
    DIFFPRICESTATISTICS =  '/Order/price-diff-statistics',  //差价统计
    FREIGHTSTATISTICS =  '/Order/freight-statistics',       //运费统计
    ORDERIMPORTTEMPLATE = '/Order/import/template',         //下载订单导入模版
    PENDINGlIST_URL = '/Order/pending',                     // 获取待发货订单列表
    SELFORDERlIST_URL = '/Order/self',                      //自提点订单列表接口、
    
    

}
//暴漏请求函数  
//获取订单接口 list
export const reqOrderlist = (data: any) => service.get<any, any>(API.ORDERlIST_URL, { params: data })
//查看订单接口(单个)
export const reqCheckOrder = (orderId: string) => service.get<any, any>(`${API.ORDERlIST_URL}/${orderId}`)
//创建订单接口
export const reqAddOrder = (orderData: any) => service.post<any, any>(API.ORDERlIST_URL, orderData)
//更新订单接口
export const reqUpdateOrder = (orderData: any) => service.put<any, any>(`${API.ORDERlIST_URL}`, orderData)

//删除订单接口
export const reqDeleteOrder = (orderId: string) => service.delete<any, any>(`${API.ORDERlIST_URL}/${orderId}`)
//导入订单接口
export const reqImportOrders = (formData: FormData) => service.post<any, any>(API.IMPORT_ORDERS_URL, formData, {
  headers: {
    'Content-Type': 'multipart/form-data'
  }
})
//取消订单接口
export const reqCancelOrder = (orderId: string) => service.post<any, any>(`${API.ORDERlIST_URL}/cancel/${orderId}`)
//审核订单接口
export const reqAuditOrder = (auditDto: any) => service.post<any, any>(`${API.AUDIT_ORDER_URL}`, auditDto)
//批量审核订单接口
export const reqBatchAuditOrder = (orderIds: number[], remark: string) => service.post<any, any>(API.BATCHAUDIT_ORDER_URL, { orderIds, remark })

//发货订单接口（单个）
export const reqShipOrder = (data: any) => service.post<any, any>(API.SHIPPED_ORDER_URL, data)
// 批量发货接口
export const reqBatchShipOrder = (formData: FormData) =>
  service.post<any, any>(API.BATCHSHIPPED_ORDER_URL, formData, {
    headers: {
      'Content-Type': 'multipart/form-data'
    }
  });

// 获取已发货订单列表
// data为查询参数对象，例如分页、筛选条件等
export const reqShippedOrderList = (data: any) =>
  service.get<any, any>(API.SHIPPEDlIST_URL, { params: data })

// 获取已签收订单列表
// data为查询参数对象，例如分页、筛选条件等
export const reqCompletedOrderList = (data: any) =>
  service.get<any, any>(API.COMPLETED_ORDERlIST_URL, { params: data })

// 单个确认收货接口
export const reqConfirmReceipt = (orderId: number) => service.post<any, any>(`${API.CONFIRM_RECEIPT_URL}/${orderId}`)

// 批量确认收货接口
export const reqBatchConfirmReceipt = (orderIds: number[]) => service.post<any, any>(API.BATCH_CONFIRM_RECEIPT_URL, orderIds)

// 修改地址专用接口
export const reqUpdateOrderAddress = (orderId: string, data: any) => service.put<any, any>(`${API.ORDERADRESSUPDATE_URL}/${orderId}`, data)

// 运费统计接口
export const reqFreightStatistics = (dealerId: string | number) => service.get<any, any>(`${API.FREIGHTSTATISTICS}/${dealerId}`)
// 差价统计接口
export const reqDiffPriceStatistics = (dealerId: string | number) => service.get<any, any>(`${API.DIFFPRICESTATISTICS}/${dealerId}`)

// 下载订单导入模板接口，返回文件流
export const reqOrderImportTemplate = () =>
  service.get<Blob>(API.ORDERIMPORTTEMPLATE, { responseType: 'blob' });

// 导出订单接口，支持传递订单ID数组，返回文件流
// 参数格式：{ OrderIds: [1,2,3] }
export const reqExportOrders = (orderIds: number[]) =>
  service.post<Blob>(API.EXPORT_ORDERS_URL, {
    OrderIds: orderIds // 直接传递订单ID数组，符合后台新接口要求
  }, {
    responseType: 'blob'
  });

// 获取待发货订单列表
// data为查询参数对象，例如分页、筛选条件等
export const reqPendingOrderList = (data: any) =>
  service.get<any, any>(API.PENDINGlIST_URL, { params: data })

// 获取运费订单列表
export const reqFreightOrderList = (params: any) => service.get<any, any>('/Order/freight', { params })

// 获取差价订单列表
export const reqDiffPriceOrderList = (params: any) => service.get<any, any>('/Order/pricediff', { params })





