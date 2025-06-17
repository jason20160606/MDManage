//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    ORDERFREIGHTlIST_URL = '/Order', //订单接口    
}
//暴漏请求函数  
//获取订单接口
export const reqOrderFreightlist = (data: any) => service.get<any, any>(API.ORDERFREIGHTlIST_URL, { params: data })