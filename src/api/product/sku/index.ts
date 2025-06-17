//SKU模块管理接口
import request from '@/utils/request'

// SKU数据类型定义
export interface SkuData {
  id?: string
  name: string
  skuCode: string
  spuId: string
  status: number
  price: number
  costPrice: number
  stock: number
  warningStock: number
  weight: number
  volume: number
  mainImage: string
  images: string[]
  description: string
  specifications: SkuSpecification[]
}

// SKU规格类型定义
export interface SkuSpecification {
  specId: string
  specName: string
  specValue: string
}

// SKU查询参数类型
export interface SkuQueryParams {
  name?: string
  skuCode?: string
  status?: number
  spuId?: string
  pageIndex?: number
  pageSize?: number
}

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
    //切换SKU状态
    TOGGLESKU_STATUS_URL = '/ProductSKU/status',
}

//SKU列表接口方法
export const reqSkuList = (params?: SkuQueryParams) => request.get<any, any>(API.GETSKU_URL, { params })

//获取SKU信息接口方法
export const reqSkuInfo = (skuId: string) => request.get<any, any>(`${API.GETSKU_URL}/${skuId}`)

//删除SKU接口方法
export const reqDeleteSku = (skuId: string) => request.delete<any, null>(`${API.DELETESKU_URL}/${skuId}`)

//添加SKU接口方法
export const reqAddSku = (data: SkuData) => request.post<any, null>(API.ADDSKU_URL, data)

//更新SKU接口方法
export const reqUpdateSku = (data: SkuData) => request.put<any, null>(`${API.UPDATESKU_URL}/${data.id}`, data)

//切换SKU状态接口方法
export const reqToggleSkuStatus = (skuId: string, status: number) => request.put<any, null>(`${API.TOGGLESKU_STATUS_URL}/${skuId}`, { status })

