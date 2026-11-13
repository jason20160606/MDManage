// 运费 / 差价账单：订单级应收行与结算单
import service from '@/utils/request'

// 应收行列表（裸数组 + X-Pagination）
export const reqReceivableList = (params: any) =>
  service.get<any, any>('/Bill/receivables', { params })

// 勾选结算：生成结算单并回写每行的状态/时间/结算人
export const reqSettle = (data: { DealerId: number; BillType: number; ReceivableIds: number[]; Remark?: string }) =>
  service.post<any, any>('/Bill/settle', data)

// 撤销结算单
export const reqReverseSettle = (data: { SettlementId: number; Reason?: string }) =>
  service.post<any, any>('/Bill/reverse', data)
