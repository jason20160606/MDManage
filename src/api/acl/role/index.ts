//用户管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //角色列表
    GETRoleLIST_URL = '/Role', 
    GETRoleName_URL = '/Role/namelist', 
}

// 用户列表请求参数类型
export interface RoleListParams {
    PageNumber: number
    PageSize: number    
}
//获取角色列表
export const reqGetRoleList = (params:RoleListParams) => request.get<any, any>(API.GETRoleLIST_URL, { params });

//获取角色名称
export const reqGetRoleName = () => request.get<any, any>(API.GETRoleName_URL);

// 新增：添加角色
export const reqAddRole = (data: { Name: string; Description: string }) =>
  request.post('/Role', data);

// 新增：编辑角色
export const reqUpdateRole = (data: { Id: number; Name: string; Description: string }) =>
  request.put(`/Role/${data.Id}`, data);

// 新增：删除角色
export const reqDeleteRole = (id: number) =>
  request.delete(`/Role/${id}`);

// 新增：获取角色已分配权限
export const reqGetRolePermissions = (id: number) =>request.get<any,any>(`/Role/${id}`);

// 新增：分配权限
export const reqAssignPermission = (id: number, permissionIds: number[]) =>
  request.post(`/Role/assignPremission/${id}`, permissionIds);