//属性相关API
import request from "@/utils/request";
import type { CategoryResponseData,AttrResponseData,Attr } from "./type";
//属性管理模块的url地址
enum API {
    //获取一级分类地址
    C1_URL = '/product/getCategory1',
    //获取二级分类地址
    C2_URL = '/product/getCategory2/',
    //获取三级分类地址
    C3_URL = '/product/getCategory3/',
    //获取分类下已有属性及属性值
    ATTR_URL = '/product/attrInfoList/',
    //保存或修改已有属性
    SAVEORUPDATEATTR_URL = '/product/saveOrUpdateAttr/',
    //删除已有属性
    DELETEATTR_URL = '/product/deleteAttr/'
    
}
//获取一级分类接口方法
export const reqC1 = () => request.get<any, CategoryResponseData>(API.C1_URL)
//获取二级分类接口方法
export const reqC2 = (category1Id: number|string) => request.get<any, CategoryResponseData>(API.C2_URL)
//获取三级分类接口方法
export const reqC3 = (category2Id: number|string) => request.get<any, CategoryResponseData>(API.C3_URL)
//获取分类下已有属性及属性值的接口方法
export const reqAttr = (category1Id: number|string, category2Id: number|string, category3Id: number|string) => 
    request.get<any, AttrResponseData>(API.ATTR_URL)
//保存或修改已有属性的接口方法
export const reqSaveOrUpdateAttr = (data: Attr) => request.post<any, any>(API.SAVEORUPDATEATTR_URL, data)
//删除已有属性的接口方法
export const reqDeleteAttr = (attrId: number) => request.delete<any, any>(API.DELETEATTR_URL+attrId)