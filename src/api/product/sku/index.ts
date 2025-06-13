//SKU模块管理接口
import request from '@/utils/request'
//枚举地址
const enum API {
    //获取SKU数据
    GETSKU_URL = '/ProductSKU',
    //删除SKU数据
    DELETESKU_URL = '/ProductSKU',
    //添加SKU数据
    ADDSKU_URL = '/ProductSKU',
    //更新SKU数据
    UPDATESKU_URL = '/ProductSKU',

}
//SKU列表接口方法
export const reqSkuList = () => request.get<any, any>(API.ADDSKU_URL)
//获取SKU信息接口方法
export const reqSkuInfo = (skuId: number) => request.get<any, any>(API.GETSKU_URL + skuId)
//删除SKU接口方法
export const reqDeleteSku = (skuId: number) => request.delete<any, null>(API.DELETESKU_URL + skuId)
//添加SKU接口方法
export const reqAddSku = (data: SkuData) => request.post<any, null>(API.ADDSKU_URL, data)

