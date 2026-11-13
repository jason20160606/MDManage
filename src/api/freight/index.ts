//统一管理项目接口
import service from '@/utils/request'

const enum API {
    FreightRule_URL = 'FreightRule',    //运费规则接口
}

// 获取运费规则列表（支持分页）
export const reqFreightRuleList = (params: any) => service.get<any, any>(API.FreightRule_URL, { params })

// 获取单个产品运费规则详情（通过ID拼接URL）
export const reqFreightRuleDetail = (id: string) =>
  service.get<any, any>(`${API.FreightRule_URL}/${id}`)
