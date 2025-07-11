//统一管理项目接口
import service from '@/utils/request'
//统一管理接口
const enum API {    
    LOGISTICSCOMPANY_URL = 'LogisticsCompany',      //物流公司
    LOGISTICSCOMPANYNAME = 'LogisticsCompany/namelist',  //物流公司名称
    

    PICKUPPOINT_URL = 'PickupPoint',                //自提点
    SHIPMENTTRACK_URL = 'ShipmentTrack',            //物流信息
}

// 获取所有物流公司
export const getLogisticsCompanies = () => service.get(API.LOGISTICSCOMPANY_URL)
// 获取所有物流公司名称列表
export const getLogisticsCompanyNames = () => service.get(API.LOGISTICSCOMPANYNAME)
// 新增物流公司
export const addLogisticsCompany = (data: any) => service.post(API.LOGISTICSCOMPANY_URL, data)
// 更新物流公司
export const updateLogisticsCompany = (id: any, data: any) => service.put(`${API.LOGISTICSCOMPANY_URL}/${id}`, data)
// 删除物流公司
export const deleteLogisticsCompany = (id: string | number) => service.delete(`${API.LOGISTICSCOMPANY_URL}/${id}`)

// 获取所有自提点
export const getPickupPoints = () => service.get(API.PICKUPPOINT_URL)
// 新增自提点
export const addPickupPoint = (data: any) => service.post(API.PICKUPPOINT_URL, data)
// 更新自提点
export const updatePickupPoint = (code: string, data: any) => service.put(`${API.PICKUPPOINT_URL}/${code}`, data)
// 删除自提点
export const deletePickupPoint = (code: string) => service.delete(`${API.PICKUPPOINT_URL}/${code}`)

// 获取物流轨迹（物流信息）
export const getShipmentTrack = (id: number) => service.get(`${API.SHIPMENTTRACK_URL}/${id}`)
// 获取所有物流轨迹
export const getAllShipmentTracks = () => service.get(API.SHIPMENTTRACK_URL)
