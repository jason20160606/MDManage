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
    DELETEFactory_URL = '/Factory',
    //工厂名称列表（用于下拉）
    FactoryNAMELIST_URL = '/Factory/namelist'
}

// 查询参数类型
export interface FactoryQueryParams {
    name?: string;
    PageNumber?: number;
    pageSize?: number;
    /** 只返回仓库（排除工厂本体） */
    onlyWarehouse?: boolean;
    /** 所属工厂ID */
    parentId?: number;
}

//获取工厂列表
export const reqGetFactoryList = (params?: FactoryQueryParams) => request.get<any, any>(API.GETFactoryLIST_URL, { params });

//新增工厂
export const reqAddFactory = (data: any) => request.post<any, any>(API.ADDFactory_URL, data);

//更新工厂
export const reqUpdateFactory = (id: number, data: any) => request.put<any, any>(`${API.UPDATEFactory_URL}/${id}`, data);

//删除工厂
export const reqDeleteFactory = (id: number) => request.delete<any, any>(`${API.DELETEFactory_URL}/${id}`);

//获取工厂/仓库名称列表（含 ParentId，ParentId 为空的是工厂本体）