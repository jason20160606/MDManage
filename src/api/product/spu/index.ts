//SPU管理模块的接口
import service from '@/utils/request';
enum API {
    //获取SPU数据
    GETSPU_URL = '/ProductSKU',    
}
//获取三级分类下已有的SPU数据的接口方法
export const reqSPU = () => service.get<any, any>(API.GETSPU_URL);