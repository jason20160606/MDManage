/**
 * 订单箱数计算
 *
 * 商品明细里 quantity 是「额度箱」，ship_qty 是「实物箱」（= 额度箱 × 倍数）。
 * 列表上给仓管看的必须是实物箱数，所以统一走这里算，避免各页面各写一套。
 */

/** 单条明细的实物箱数：优先用后端算好的 ShipQty，缺失时按 额度箱 × 倍数 现算 */
export const boxQty = (item: any): number => {
  const ship = Number(item?.ShipQty) || 0
  if (ship > 0) return ship
  const conv = Number(item?.Conversion) || 1
  return (Number(item?.Quantity) || 0) * conv
}

/** 单条明细的剩余待发箱数（部分发货的订单只发剩下的） */
export const remainQty = (item: any): number => {
  const remain = boxQty(item) - (Number(item?.ShippedQty) || 0)
  return remain > 0 ? Number(remain.toFixed(2)) : 0
}

/** 订单的合计箱数：商品信息里各明细箱数之和 */
export const orderBoxTotal = (order: any): number => {
  const items = order?.OrderItems || order?.OrderItemDetails || []
  if (items.length > 0) {
    return Number(items.reduce((sum: number, item: any) => sum + boxQty(item), 0).toFixed(2))
  }
  // 列表没带明细时退回订单上的快照字段
  return Number(order?.TotalShipQty) || Number(order?.TotalQuotaQty) || 0
}

/** 订单的剩余待发箱数 */
export const orderRemainTotal = (order: any): number => {
  const items = order?.OrderItems || order?.OrderItemDetails || []
  if (items.length > 0) {
    return Number(items.reduce((sum: number, item: any) => sum + remainQty(item), 0).toFixed(2))
  }
  const total = Number(order?.TotalShipQty) || Number(order?.TotalQuotaQty) || 0
  const shipped = Number(order?.ShippedQty) || 0
  const remain = total - shipped
  return remain > 0 ? Number(remain.toFixed(2)) : 0
}

/** 去掉多余的 0，2 箱显示 2、2.50 箱显示 2.5 */
export const fmtQty = (value: number | string | null | undefined): string => {
  const num = Number(value)
  if (!isFinite(num)) return '0'
  return String(Number(num.toFixed(2)))
}

/** 单条明细的差价金额：优先取后端算好的 PriceDiffAmount，缺失时按 额度箱数 × 单箱差价 现算 */
export const itemDiff = (item: any): number => {
  const amount = Number(item?.PriceDiffAmount) || 0
  if (amount !== 0) return Number(amount.toFixed(2))
  const unit = Number(item?.PriceDiffUnit) || 0
  return Number(((Number(item?.Quantity) || 0) * unit).toFixed(2))
}

/** 单条明细的单箱差价 */

/** 订单的差价合计：明细差价之和，列表没带明细时退回订单快照字段 */
export const orderDiffTotal = (order: any): number => {
  const items = order?.OrderItems || order?.OrderItemDetails || []
  if (items.length > 0) {
    return Number(items.reduce((sum: number, item: any) => sum + itemDiff(item), 0).toFixed(2))
  }
  return Number(Number(order?.PriceDiff).toFixed(2)) || 0
}

/** 金额显示：¥12.5 */
export const fmtMoney = (value: number | string | null | undefined): string => {
  const num = Number(value)
  if (!isFinite(num)) return '¥0'
  return `¥${Number(num.toFixed(2))}`
}
