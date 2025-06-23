//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    FactorySockList_URL = 'FactoryStock',
}

// 获取工厂列表
export const getFactoryList = () => service.get<any, any>('Factory')

// 获取工厂库存列表，支持参数
export const getFactorySockList = (params?: any) => service.get<any, any>(API.FactorySockList_URL, { params })