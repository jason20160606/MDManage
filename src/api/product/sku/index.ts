//SKU模块管理接口
import request from '@/utils/request'
//枚举地址
const enum API {
    //获取SKU地址
    GETSKU_URL = '/product/getSkuInfo/',
    //删除SKU地址
    DELETESKU_URL = '/product/deleteSku/',
    //添加SKU地址
    ADDSKU_URL = '/product/onSale/',
    //更新SKU地址
    UPDATESKU_URL = '/product/updateSku/',

}
//SKU列表接口方法
export const reqSkuList = (page: number, limit: number) => request.get<any, SkuResponseData>(`/product/list/${page}/${limit}`)
//获取SKU信息接口方法
export const reqSkuInfo = (skuId: number) => request.get<any, SkuInfoData>(API.GETSKU_URL + skuId)
//删除SKU接口方法
export const reqDeleteSku = (skuId: number) => request.delete<any, null>(API.DELETESKU_URL + skuId)
//添加SKU接口方法
export const reqAddSku = (data: SkuData) => request.post<any, null>(API.ADDSKU_URL, data)

