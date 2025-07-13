// 统一管理大屏相关接口
import service from '@/utils/request'

const enum API {
  SHIPMENT_TREND = '/Order/shipment/trend',                    // 发货趋势
  DEALER_PERFORMANCE = '/Order/dealer-performance-ranking',     // 经销商业绩排行
  DEALER_VALID_MEMBER = '/Order/dealer-valid-member-ranking',   // 有效经销商地区
  FACTORY_SHIPMENT = '/Order/factory-product-shipment-ranking', // 工厂发货排行
  PROVINCE_SHIPMENT = '/Order/daily-province-shipment',         // 发货分布
  TODAY_SIMPLE_ORDERS = '/Order/today-simple-orders',           // 当日订单信息
  TODAY_ORDER_SUMMARY = '/Order/today-order-summary'            // 头部卡片统计
}

// 1. 发货趋势
export const getShipmentTrend = (params: { days: number }) =>
  service.get(API.SHIPMENT_TREND, { params })

// 2. 经销商业绩排行
export const getDealerPerformanceRanking = (params: { year: number }) =>
  service.get(API.DEALER_PERFORMANCE, { params })

// 3. 有效经销商地区
export const getDealerValidMemberRanking = () =>
  service.get(API.DEALER_VALID_MEMBER)

// 4. 工厂发货排行
export const getFactoryProductShipmentRanking = (params: { year: number }) =>
  service.get(API.FACTORY_SHIPMENT, { params })

// 5. 发货分布（省份）
export const getDailyProvinceShipment = (params: { date: string }) =>
  service.get(API.PROVINCE_SHIPMENT, { params })

// 6. 当日订单信息
export const getTodaySimpleOrders = (params: { date: string }) =>
  service.get(API.TODAY_SIMPLE_ORDERS, { params })

// 7. 头部卡片统计
export const getTodayOrderSummary = (params: { date: string }) =>
  service.get(API.TODAY_ORDER_SUMMARY, { params })
