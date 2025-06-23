//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {
    FactorySockList_URL = 'Dealer',
}

// 获取工厂库存列表
export const getFactorySockList = () => service.get<any, any>(API.FactorySockList_URL)