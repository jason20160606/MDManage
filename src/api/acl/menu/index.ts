//菜单管理模块的接口
import request from '@/utils/request';
//枚举地址
const enum API {
    //获取菜单地址
    GETMENU_URL = '/menu/', 
    //删除菜单地址
    DELETEMENU_URL = '/menu/',
    //添加菜单地址
    ADDMENU_URL = '/menu/add',
    //更新菜单地址
    UPDATEMENU_URL = '/menu/update',
    //获取菜单列表
    GETMENULIST_URL = '/menu/',
}   
//获取菜单信息接口方法
export const reqMenuInfo = () => request.get<any, any>(API.GETMENU_URL);
//获取菜单列表接口方法
export const reqMenuList = (page: number, limit: number) => request.get<any, any>(API.GETMENULIST_URL + `${page}/${limit}`);
//删除菜单接口方法
export const reqDeleteMenu = (menuId: number) => request.delete<any, null>(API.DELETEMENU_URL + menuId);
//添加菜单接口方法
export const reqAddMenu = (data: any) => request.post<any, null>(API.ADDMENU_URL, data);
//更新菜单接口方法
export const reqUpdateMenu = (data: any) => request.put<any, null>(API.UPDATEMENU_URL, data);
//获取全部菜单接口方法
export const reqAllMenuList = () => request.get<any, any>(API.GETMENULIST_URL);