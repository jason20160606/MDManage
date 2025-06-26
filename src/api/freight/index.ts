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