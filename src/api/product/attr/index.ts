//属性相关API
import request from "@/utils/request";
//属性管理模块的url地址
enum API {
    //获取一级分类地址
    C1_URL = '/ProductCategory',
    //获取二级分类地址
    C2_URL = '/ProductCategory',
    //获取三级分类地址
    C3_URL = '/ProductCategory',
    //获取分类下已有属性及属性值
    ATTR_URL = '/ProductCategory',
    //保存或修改已有属性
    //删除已有属性
    
}
//获取一级分类接口方法
export const reqC1 = () => request.get<any, any>(API.C1_URL + '/0')
//获取二级分类接口方法
export const reqC2 = (category1Id: number|string) => request.get<any, any>(API.C2_URL+ `/${category1Id}`)
//获取三级分类接口方法
export const reqC3 = (category2Id: number|string) => request.get<any, any>(API.C3_URL+ `/${category2Id}`)
