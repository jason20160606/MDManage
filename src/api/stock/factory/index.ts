//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    FactoryNameList = 'Factory',
    FactorySockList_URL = 'FactoryStock',
}

// 获取工厂列表
export const getFactoryList = () => service.get<any, any>(API.FactoryNameList)

// 获取工厂库存列表，支持参数
export const getFactorySockList = (params?: any) => service.get<any, any>(API.FactorySockList_URL, { params })

// 根据id获取工厂库存详情
export const getFactoryStockDetail = (id: number|string) => service.get<any, any>(`FactoryStock/${id}`)

// 更新工厂库存
export const updateFactoryStock = (id: number|string, data: any) => service.put<any, any>(`FactoryStock/${id}`, data)

// 新增工厂库存
export const createFactoryStock = (data: any) => service.post<any, any>('FactoryStock', data)

// 获取工厂库存调整记录
export const getFactoryStockLog = (params: any) => service.get<any, any>('FactoryStockLog', { params })