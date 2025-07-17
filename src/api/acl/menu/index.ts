//菜单管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //获取菜单地址
    GETMENU_URL = '/Premission',     
}   
//获取菜单信息接口方法
export const reqMenuInfo = () => request.get<any, any>(API.GETMENU_URL);
// 修改权限信息API
export const reqUpdatePermission = (data: { Id: number; Name: string; Code: string; Description: string; Type: number }) =>
  request.put(`/Premission/${data.Id}`, data);
// 新增权限API
export const reqAddPermission = (data: { Name: string; Code: string; Description: string; ParentId: string | number; Type: number }) =>
  request.post('/Premission', data);
// 删除权限API
export const reqDeletePermission = (id: number|string) =>
  request.delete(`/Premission/${id}`);