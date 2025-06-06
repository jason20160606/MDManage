//SPU管理模块的接口
import service from '@/utils/request';
enum API {
    //获取SPU数据
    GETSPU_URL = '/product/spuInfoList',
    //获取SPU品牌数据
    GETSPU_BRAND_URL = '/product/baseTrademark/getTrademarkList',
    //获取SPU分类数据
    GETSPU_CATEGORY_URL = '/product/baseCategoryList',
    //获取SPU图片数据
    GETSPU_IMG_URL = '/product/spuImageList/',
    //获取SPU销售属性数据
    GETSPU_SALEATTR_URL = '/product/spuSaleAttrList/',
    //获取SPU全部属性数据
    GETSPU_AllSALEATTR_URL = '/product/allSaleAttrList/',
    //添加SPU
    ADDSPU_URL = '/product/saveSpuInfo',
    //修改SPU
    UPDATESPU_URL = '/product/updateSpuInfo',
    //删除SPU
    DELETESPU_URL = '/product/deleteSpu/'
}
//获取三级分类下已有的SPU数据的接口方法
export const reqSPU = () => service.get<any, any>(API.GETSPU_URL);
//获取SPU品牌数据的接口方法
export const reqSPU_BRAND = () => service.get<any, any>(API.GETSPU_BRAND_URL);
//获取SPU图片数据的接口方法
export const reqSPU_IMG = (spuId: number) => service.get<any, any>(API.GETSPU_IMG_URL);
//获取SPU销售属性数据的接口方法
export const reqSPU_SALEATTR = (spuId: number) => service.get<any, any>(API.GETSPU_SALEATTR_URL);
//获取SPU全部属性数据的接口方法
export const reqSPU_AllSALEATTR = () => service.get<any, any>(API.GETSPU_AllSALEATTR_URL);
