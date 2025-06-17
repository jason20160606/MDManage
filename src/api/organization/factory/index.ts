//管理模块的接口
import request from '@/utils/request';

//枚举地址
const enum API {
    //工厂列表
    GETFactoryLIST_URL = '/Factory',
    //新增工厂
    ADDFactory_URL = '/Factory',
    //更新工厂
    UPDATEFactory_URL = '/Factory',
    //删除工厂
    DELETEFactory_URL = '/Factory'
}

// 查询参数类型
export interface FactoryQueryParams {
    name?: string;
    PageNumber?: number;
    pageSize?: number;
}

//获取工厂列表
export const reqGetFactoryList = (params?: FactoryQueryParams) => request.get<any, any>(API.GETFactoryLIST_URL, { params });

//新增工厂
export const reqAddFactory = (data: any) => request.post<any, any>(API.ADDFactory_URL, data);

//更新工厂
export const reqUpdateFactory = (id: number, data: any) => request.put<any, any>(`${API.UPDATEFactory_URL}/${id}`, data);

//删除工厂
export const reqDeleteFactory = (id: number) => request.delete<any, any>(`${API.DELETEFactory_URL}/${id}`);