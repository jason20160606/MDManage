//用户管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //角色列表
    GETRoleLIST_URL = '/Role', 
}

// 用户列表请求参数类型
export interface RoleListParams {
    PageNumber: number
    PageSize: number    
}
//获取角色列表
export const reqGetRoleList = (params:RoleListParams) => request.get<any, any>(API.GETRoleLIST_URL, { params });