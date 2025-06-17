import request from "@/utils/request";
//产品分类管理模块接口
import type { Category, CategoryQueryParams } from "./type";

//产品分类管理模块接口地址
const enum API {
    //获取分类列表
    CATEGORY_URL = "/ProductCategory",
    //添加分类
    ADDCATEGORY_URL = "/ProductCategory",
    //修改分类
    UPDATECATEGORY_URL = "/ProductCategory",
    //删除分类
    DELETECATEGORY_URL = "/ProductCategory",
}

//获取分类列表的接口方法
export const reqGetCategoryList = (params?: CategoryQueryParams) => request.get<any, any>(API.CATEGORY_URL, { params });

//新增分类接口方法
export const reqAddCategory = (data: Category) => request.post<any, any>(API.ADDCATEGORY_URL, data);

//修改分类接口方法
export const reqUpdateCategory = (id: number, data: Category) => request.put<any, any>(`${API.UPDATECATEGORY_URL}/${id}`, data);

//删除分类
export const reqDeleteCategory = (id: number) => request.delete<any, any>(`${API.DELETECATEGORY_URL}/${id}`);
