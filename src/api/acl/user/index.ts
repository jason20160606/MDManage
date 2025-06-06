//用户管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //获取用户地址
    GETUSER_URL = '/sysUser/',
    //删除用户地址
    DELETEUSER_URL = '/sysUser/',
    //添加用户地址
    ADDUSER_URL = '/sysUser/add',
    //更新用户地址
    UPDATEUSER_URL = '/sysUser/update',
    //获取用户列表
    GETUSERLIST_URL = '/sysUser/',
    //获取用户角色列表
    GETUSERROLE_URL = '/sysUser/toAssign/',
    //给用户分配角色
    ASSIGNROLE_URL = '/sysUser/doAssignRole',
    //批量删除用户
    BATCHDELETEUSER_URL = '/sysUser/batchRemove',
    //修改用户状态
    UPDATESTATUS_URL = '/sysUser/updateStatus/',
    //获取用户信息
    GETUSERINFO_URL = '/sysUser/getInfo',
}
//获取用户信息接口方法
export const reqUserInfo = () => request.get<any, any>(API.GETUSERINFO_URL);
//获取用户列表接口方法
export const reqUserList = (page: number, limit: number) => request.get<any, any>(API.GETUSERLIST_URL + `${page}/${limit}`)
//删除用户接口方法
export const reqDeleteUser = (userId: number) => request.delete<any, null>(API.DELETEUSER_URL + userId)
//添加用户接口方法
export const reqAddUser = (data: UserData) => request.post<any, null>(API.ADDUSER_URL, data)
//更新用户接口方法
export const reqUpdateUser = (data: UserData) => request.put<any, null>(API.UPDATEUSER_URL, data)
//获取用户角色列表接口方法
export const reqUserRole = (userId: number) => request.get<any, UserRoleData>(API.GETUSERROLE_URL + userId)
//给用户分配角色接口方法
export const reqAssignRole = (roleId: number, userId: number) => request.post<any, null>(API.ASSIGNROLE_URL + `/${roleId}/${userId}`)
//批量删除用户接口方法
export const reqBatchDeleteUser = (idList: number[]) => request.delete<any, null>(API.BATCHDELETEUSER_URL, { data: idList })
//修改用户状态接口方法
export const reqUpdateStatus = (userId: number, status: number) => request.get<any, null>(API.UPDATESTATUS_URL + `${userId}/${status}`)