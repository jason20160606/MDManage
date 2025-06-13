//品牌管理模块接口
import service from "@/utils/request";
import type { TrademarkResponseData, Trademark } from "./type";
//品牌管理模块接口地址
const enum API {
    //获取已有品牌接口
    TRADEMARK_URL = "/Brand",
    //添加品牌
    ADDTRADEMARK_URL = "/Brand",
    //修改已有品牌
    UPDATETRADEMARK_URL = "/Brand",
    //删除已有品牌
    DELETETRADEMARK_URL = "/Brand",
}
//获取已有品牌数据的接口方法
//page:获取第几页---默认第一页
//limit获取几个已有品牌数据
export const reqHasTrademark = () => service.get<any, any>(API.TRADEMARK_URL);
//添加与修改已有品牌接口方法
export const reqAddOrUpdateTrademark = (data: Trademark) => {
    //修改
    if (data.id) {
        return service.put<any, any>(API.UPDATETRADEMARK_URL, data);
    } else {
        //新增
        return service.post<any, any>(API.ADDTRADEMARK_URL, data);
    }
}
//删除已有品牌
export const reqDeleteTrademark = (id: number) => service.delete<any, any>(API.DELETETRADEMARK_URL + `/${id}`);
