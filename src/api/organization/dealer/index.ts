//管理模块的接口
import request from '@/utils/request';

//枚举地址
const enum API {
    //经销商列表
    GETDealerLIST_URL = '/Dealer',
    //经销商详情
    GETDealerDETAIL_URL = '/Dealer',
    //新增经销商
    ADDDealer_URL = '/Dealer',
    //更新经销商
    UPDATEDealer_URL = '/Dealer',
    //删除经销商
    DELETEDealer_URL = '/Dealer',
    //经销商名称
    DEALERNAMELIST = '/Dealer/namelist',
}

// 查询参数类型
export interface DealerQueryParams {
    name?: string;
    code?: string;
    PageNumber?: number;
    pageSize?: number;
}

//获取经销商列表
export const reqGetDealerList = (params?: DealerQueryParams) => request.get<any, any>(API.GETDealerLIST_URL, { params });

//获取经销商详情
export const reqGetDealerDetail = (id: number) => request.get<any, any>(`${API.GETDealerDETAIL_URL}/${id}`);

//新增经销商
export const reqAddDealer = (data: any) => request.post<any, any>(API.ADDDealer_URL, data);

//更新经销商
export const reqUpdateDealer = (id: number, data: any) => request.put<any, any>(`${API.UPDATEDealer_URL}/${id}`, data);

//删除经销商
export const reqDeleteDealer = (id: number) => request.delete<any, any>(`${API.DELETEDealer_URL}/${id}`);

//获取经销商名称列表
export const reqDealerNameList = () => request.get<any, any>(API.DEALERNAMELIST);

// 新增：经销商运费结算/新增接口
// 参数示例：{ Id: number, Type: number, Price: number }
export const reqDealerFreight = (data: { Id: number; Type: number; Price: number }) =>
  request.put<any, any>('/Dealer/freight', data);

// 新增：经销商差价结算/新增接口
// 参数示例：{ Id: number, Type: number, Price: number }
export const reqDealerPriceDiff = (data: { Id: number; Type: number; Price: number }) =>
  request.put<any, any>('/Dealer/pricediff', data);

// 获取账户变动日志列表
// 参数示例：{ DealerId: number, LogType: 1额度/2运费/3差价, CreatedAtMin, CreatedAtMax, PageNumber, PageSize }
export const reqDealerLogList = (params: Record<string, any>) =>
  request.get<any, any>('/DealerQuotaLog', { params });

// 账户变动日志汇总：同一筛选条件下的总增加 / 总扣减 / 记录数（不是当前页）
export const reqDealerLogStatistics = (params: Record<string, any>) =>
  request.get<any, any>('/DealerQuotaLog/statistics', { params });