//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {    
    LOGISTICSCOMPANY_URL = '/LogisticsCompany',             //物流公司
    LOGISTICSCOMPANYNAME = '/LogisticsCompany/namelist',    //物流公司名称
    UPDATEENABLE_URL = '/LogisticsCompany/enable',          //物流公司状态   

    PICKUPPOINT_URL = '/PickupPoint',                       //自提点
    PICKUPPOINTNAME_URL = '/PickupPoint/namelist',          //自提点名称
    UPDATEPOINTENABLE_URL = '/PickupPoint/enable',          //自提点状态
    SHIPMENTTRACK_URL = '/ShipmentTrack',                   //物流信息
    SELFORDERlIST_URL = '/Order/self',                    //自提点订单列表
    
    SHIPMENT_URL = '/Order/shipment',                       //发货记录列表
    SHIPMENT_DETAIL_URL = '/Order/shipment',                //发货记录详情（按订单取最新一批）
    SHIPMENT_DETAIL_BY_ID_URL = '/Order/shipment/detail',   //发货记录详情（按发货单取）
    CARRIER_DISTRIBUTION_URL = '/Order/shipment/carrier-distribution', //物流公司发货量分布
}

// 获取所有物流公司
export const getLogisticsCompanies = () => service.get(API.LOGISTICSCOMPANY_URL)
// 获取所有物流公司名称列表
export const getLogisticsCompanyNames = () => service.get(API.LOGISTICSCOMPANYNAME)
// 新增物流公司
export const addLogisticsCompany = (data: any) => service.post<any, any>(API.LOGISTICSCOMPANY_URL, data)
// 更新物流公司
export const updateLogisticsCompany = (data: any) => service.put<any, any>(`${API.LOGISTICSCOMPANY_URL}`, data)
// 删除物流公司
export const deleteLogisticsCompany = (id: string | number) => service.delete(`${API.LOGISTICSCOMPANY_URL}/${id}`)

// 启用/禁用物流公司（PUT到LogisticsCompany/enable，参数为{Id, IsEnabled}）
export const updateLogisticsCompanyEnable = (Id: string | number, IsEnabled: boolean) => service.put<any, any>(API.UPDATEENABLE_URL, { Id, IsEnabled })

// 获取所有自提点
export const getPickupPoints = () => service.get(API.PICKUPPOINT_URL)
// 新增自提点
export const addPickupPoint = (data: any) => service.post<any, any>(API.PICKUPPOINT_URL, data)
// 更新自提点（PUT /PickupPoint，body为UpdatedPickupPointDto）
export const updatePickupPoint = (data: any) => service.put<any, any>(API.PICKUPPOINT_URL, data)
// 启用/禁用自提点（PUT /PickupPoint/enable，body为{Id, IsEnabled}）
export const updatePickupPointEnable = (Id: string | number, IsEnabled: boolean) => service.put<any, any>(API.UPDATEPOINTENABLE_URL, { Id, IsEnabled })
// 删除自提点
export const deletePickupPoint = (code: string) => service.delete<any, any>(`${API.PICKUPPOINT_URL}/${code}`)

// 获取物流轨迹（物流信息）：refresh=true 跳过缓存强制查一次
export const getShipmentTrack = (id: number, refresh = false) => service.get(`${API.SHIPMENTTRACK_URL}/${id}`, { params: { refresh } })
// 获取所有物流轨迹
export const getAllShipmentTracks = () => service.get(API.SHIPMENTTRACK_URL)

// 获取自提点订单列表
export const getSelfOrderList = (params: any) => service.get<any, any>(API.SELFORDERlIST_URL, { params })

// 获取发货记录列表
export const getShipmentList = (params: any) => service.get<any, any>(API.SHIPMENT_URL, { params })

// 获取发货记录详情
export const getShipmentDetail = (id: string | number) => service.get<any, any>(`${API.SHIPMENT_DETAIL_URL}/${id}`)

// 获取发货记录详情（按发货单ID，一单多批时用这个）
export const getShipmentDetailById = (id: string | number) => service.get<any, any>(`${API.SHIPMENT_DETAIL_BY_ID_URL}/${id}`)

// 物流公司发货量分布（最近 N 天）
export const getCarrierDistribution = (days = 30) => service.get<any, any>(API.CARRIER_DISTRIBUTION_URL, { params: { days } })

// 获取发货统计数据
export const getShipmentStatistical = () => service.get('/order/shipment/statistical')

// 获取发货趋势数据
export const getShipmentTrend = (days: number) => service.get('/order/shipment/trend', { params: { days } })
