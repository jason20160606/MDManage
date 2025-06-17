//SPU管理模块的接口
import service from '@/utils/request';

// 查询参数类型
export interface SPUQueryParams {
    name?: string;
    categoryId?: number;
    status?: number;
    pageNumber?: number;
    pageSize?: number;
}

enum API {
    //获取SPU数据
    GETSPU_URL = '/ProductSPU',
    //新增SPU
    ADDSPU_URL = '/ProductSPU',
    //更新SPU
    UPDATESPU_URL = '/ProductSPU',
    //删除SPU
    DELETESPU_URL = '/ProductSPU',
    //切换SPU状态
    TOGGLESPUSTATUS_URL = '/ProductSPU/status'
}

//获取三级分类下已有的SPU数据的接口方法
export const reqSPU = (params?: SPUQueryParams) => service.get<any, any>(API.GETSPU_URL, { params });

//新增SPU
export const reqAddSPU = (data: any) => service.post<any, any>(API.ADDSPU_URL, data);

//更新SPU
export const reqUpdateSPU = (id: number, data: any) => service.put<any, any>(`${API.UPDATESPU_URL}/${id}`, data);

//删除SPU
export const reqDeleteSPU = (id: any) => service.delete<any, any>(`${API.DELETESPU_URL}/${id}`);

//切换SPU状态
export const reqToggleSPUStatus = (id: any, status: number) => service.patch<any, any>(`${API.TOGGLESPUSTATUS_URL}/${id}`, { status });