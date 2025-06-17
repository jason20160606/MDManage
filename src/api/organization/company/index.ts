//管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //公司列表
    GETBrandLIST_URL = '/Brand', 
    //新增公司
    ADDBRAND_URL = '/Brand',
    //更新公司
    UPDATEBRAND_URL = '/Brand',
    //删除公司
    DELETEBRAND_URL = '/Brand'
}

// 查询参数类型
export interface BrandQueryParams {
    name?: string;
    PageNumber?: number;
    pageSize?: number;
}

//获取公司列表
export const reqGetBrandList = (params?: BrandQueryParams) => request.get<any, any>(API.GETBrandLIST_URL, { params });

//新增公司
export const reqAddBrand = (data: any) => request.post<any, any>(API.ADDBRAND_URL, data);

//更新公司
export const reqUpdateBrand = (id: number, data: any) => request.put<any, any>(`${API.UPDATEBRAND_URL}/${id}`, data);

//删除公司
export const reqDeleteBrand = (id: number) => request.delete<any, any>(`${API.DELETEBRAND_URL}/${id}`);