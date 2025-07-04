//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    ORDERFREIGHTlIST_URL = '/Order', //订单接口    
    FreightRule_URL = 'FreightRule',    //运费接口    
}
//暴漏请求函数  
//获取订单接口
export const reqOrderFreightlist = (data: any) => service.get<any, any>(API.ORDERFREIGHTlIST_URL, { params: data })
// 获取运费规则列表（支持分页）
export const reqFreightRuleList = (params: any) => service.get<any, any>(API.FreightRule_URL, { params })

// 获取单个产品运费规则详情（通过ID拼接URL）
export const reqFreightRuleDetail = (id: string) => 
  service.get<any, any>(`${API.FreightRule_URL}/${id}`) 

// 新增单个产品运费规则详情（通过ID拼接URL）
export const reqFreightRuleCreate = (id: string) => 
    service.post<any, any>(`${API.FreightRule_URL}/${id}`) 
// 新增单个产品运费规则详情（通过ID拼接URL）
export const reqFreightRuleUpdate = (id: string) => 
    service.put<any, any>(`${API.FreightRule_URL}/${id}`) // 例如 /FreightRule/123