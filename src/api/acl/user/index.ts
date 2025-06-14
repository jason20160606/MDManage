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
export interface UserListParams {
    PageNumber: number
    PageSize: number
    UserName?: string
}


//获取用户列表
export const reqUserList = (params: UserListParams) => request.get<any, any>(API.GETUSERLIST_URL, { params })
//查询某个用户
export const reqUserInfo = (account: string) => request.get<any, any>(API.GETUSER_URL+ `/${account}`);
//删除用户接口方法
export const reqDeleteUser = (userId: number) => request.delete<any, null>(API.DELETEUSER_URL + `/${userId}`)
//添加用户接口方法
export const reqAddUser = (data: any) => request.post<any, null>(API.ADDUSER_URL, data)
//更新用户接口方法
export const reqUpdateUser = (data: any) => request.put<any, null>(API.UPDATEUSER_URL, data)
