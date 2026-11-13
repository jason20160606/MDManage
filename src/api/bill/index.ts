// 运费 / 差价账单：订单级应收行与结算单
import service from '@/utils/request'

// 应收行列表（分页：Items + TotalCount）
export const reqReceivableList = (params: any) =>
  service.get<any, any>('/Bill/receivables', { params })

// 应收行详情：账单 + 订单商品明细 + 逐张发货单（快递公司/运单号/司机/轨迹）
export const reqReceivableDetail = (id: number | string) =>
  service.get<any, any>(`/Bill/receivables/${id}/detail`)

// 勾选结算：生成结算单并回写每行的状态/时间/结算人
export const reqSettle = (data: { DealerId: number; BillType: number; ReceivableIds: number[]; Remark?: string }) =>
  service.post<any, any>('/Bill/settle', data)

// 撤销结算单
export const reqReverseSettle = (data: { SettlementId: number; Reason?: string }) =>
  service.post<any, any>('/Bill/reverse', data)
