//用户管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //用户列表
    GETUSERLIST_URL = '/User',
    //根据用户名称获取用户信息
    GETUSER_URL = '/User',    
    //删除用户地址
    DELETEUSER_URL = '/User',
    //添加用户地址
    ADDUSER_URL = '/User',
    //更新用户地址
    UPDATEUSER_URL = '/User',    
}

// 用户列表请求参数类型


//获取用户列表
export const reqUserList = (params: any) => request.get<any, any>(API.GETUSERLIST_URL, { params })
//添加用户接口方法
export const reqAddUser = (data: any) => request.post<any, null>(API.ADDUSER_URL, data)
//删除用户接口方法
export const reqDeleteUser = (userId: number) => request.delete<any, any>(API.DELETEUSER_URL + `/${userId}`)

// 获取用户已分配角色
export const reqGetUserRoles = (userId: number) => request.get<any, any>(`/User/WithRoles/${userId}`)

// 重置用户密码接口方法
export const reqResetPassword = (userId: number | string) => request.put<any, any>(`/User/${userId}`);

// 切换用户启用状态接口方法
export const reqEnableUser = (data: { Id: number | string, IsEnabled: boolean }) => request.put<any, any>(`/User/enable`, data);

// 分配用户角色接口方法，参数为用户ID和角色ID数组
export const reqAssignRoles = (userId: number|string, roleIds: number[]) => request.post<any, any>(`/User/roles/${userId}`, roleIds);


