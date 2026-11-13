import { Dec } from '@/utils/decimal'

/**
 * 后台库存计算（纯前端版）
 *
 * 本文件是后端 DealerService「#region XML 后台库存管理」那套算法的逐行移植。
 * 硬性约束：最终生成的文字必须与旧后端输出**逐字一致**，
 * 因此下面的分支、括号、标点、小数位数处理一律照抄，不要按「看起来更合理」去改：
 *   - 洗衣液整箱的邮费不进本条正文，只进最后「合计」；
 *   - 「特惠9件套」「3瓶装洗护」正文没有「之前余」；
 *   - 3 瓶 / 3 份换 1 箱是写死的业务规则；
 *   - 家庭套、洗衣液、洗脸巾、3瓶装、4瓶装用各自的扣减口径，不要合并。
 */

export interface BackstageSku {
  skuId: number
  name: string
  /** 扣减比例（原 XML 的 DeductRatio） */
  deductRatio: string
  /** 单件邮费（原 XML 的 Postage） */
  postage: string
  /** 洗脸巾差价单价（原 XML 的 Agio） */
  agio?: string
}

/** 商品配置：原先是每个经销商一份 XML，实际 7 份内容等价，这里收敛成一张常量表 */
export const BACKSTAGE_SKUS: BackstageSku[] = [
  { skuId: 1, name: '家庭套', deductRatio: '0.7', postage: '14' },
  { skuId: 2, name: '家庭套（新疆西藏）', deductRatio: '0.7', postage: '54' },
  { skuId: 3, name: '特惠9件套', deductRatio: '1', postage: '14' },
  { skuId: 4, name: '洗衣液', deductRatio: '0.1', postage: '4' },
  { skuId: 5, name: '洗衣液（整箱）', deductRatio: '1', postage: '1' },
  { skuId: 6, name: '洗脸巾', deductRatio: '1', postage: '5', agio: '18.5' },
  { skuId: 9, name: '洗脸巾（新疆西藏）', deductRatio: '1', postage: '16', agio: '18.5' },
  { skuId: 7, name: '3瓶装洗护', deductRatio: '0', postage: '5.5' },
  { skuId: 8, name: '4瓶装洗护', deductRatio: '0.44', postage: '5.5' }
]

export interface CalcItem {
  skuId: number
  quantity: number
  /** 洗衣液（整箱）才用：手工填的整单邮费 */
  userInputPostage?: number
}

export interface CalcResult {
  /** 计算结果文字，一行一条，顺序与旧后端一致 */
  details: string[]
  /** 邮费+差价合计（旧接口的 TotalPostage，页面未展示） */
  totalPostage: string
  /** 计算后的库存余量，skuId => 字面量（保留小数位） */
  stock: Record<string, string>
}

const SKU_MAP = new Map<number, BackstageSku>(BACKSTAGE_SKUS.map(s => [s.skuId, s]))

function meta(skuId: number): BackstageSku {
  return SKU_MAP.get(skuId) as BackstageSku
}

/** 通用扣减与余量计算（对应后端 CalcDeductAndRemain，scale=10 是「一箱 10 瓶」） */
function calcDeductAndRemain(
  beforeRemain: Dec,
  bottleCount: number,
  ratio: Dec,
  scale = 10
): { deductStock: Dec; afterRemain: Dec } {
  const bottles = Dec.parse(bottleCount)
  if (bottles.gt(beforeRemain)) {
    const tempDeduct = bottles.mul(ratio)
    const tempDeductStock = tempDeduct.floor()
    const tempRemain = tempDeduct.sub(tempDeductStock).mul(Dec.parse(scale))
    if (tempRemain.gt(beforeRemain)) {
      return {
        deductStock: tempDeductStock.add(Dec.parse(1)),
        afterRemain: beforeRemain.sub(tempRemain).add(Dec.parse(scale))
      }
    }
    return { deductStock: tempDeductStock, afterRemain: beforeRemain.sub(tempRemain) }
  }
  return { deductStock: Dec.zero(), afterRemain: beforeRemain.sub(bottles) }
}

/** 洗衣液正文（整箱邮费不进正文，只进合计） */
function buildLaundryLog(
  boxCount: number,
  bottleCount: number,
  beforeRemain: Dec,
  deductStock: Dec,
  afterRemain: Dec,
  normalPostageFormula: string,
  normalPostage: Dec
): string {
  const qtyPart = `${boxCount}箱${bottleCount}瓶`
  const postagePart = `邮费${normalPostageFormula}=${normalPostage}`
  return `后台洗衣液${qtyPart}，之前余${beforeRemain.truncInt()}，减库存${deductStock}箱余${afterRemain.truncInt()}瓶，${postagePart}`
}

/**
 * 计算入口
 * @param items 页面提交的 9 个商品行（数量可为 0，仍需参与，旧逻辑就是这么算的）
 * @param stockIn 当前余量 skuId => 字面量
 */
export function calcBackstageStock(
  items: CalcItem[],
  stockIn: Record<string, string>
): CalcResult {
  const details: string[] = []
  const stock = new Map<number, Dec>()
  BACKSTAGE_SKUS.forEach(s => {
    stock.set(s.skuId, Dec.parse(stockIn[String(s.skuId)] ?? '0'))
  })
  const stockOf = (skuId: number): Dec => stock.get(skuId) ?? Dec.zero()
  const setStock = (skuId: number, value: Dec): void => {
    stock.set(skuId, value)
  }

  // 只认配置表里存在的商品（对应后端 TryGetValue 过滤）
  const rows = items.filter(i => SKU_MAP.has(i.skuId))
  const qty = (i: CalcItem): Dec => Dec.parse(i.quantity)

  let totalPostage = Dec.zero()
  let totalDeductStock = Dec.zero()
  let totalPriceDifference = Dec.zero()

  // 1. 家庭套（「家庭套」与「家庭套（新疆西藏）」合并按家庭套的余量/比例扣）
  const familyItems = rows.filter(i => meta(i.skuId).name.includes('家庭套'))
  if (familyItems.length > 0) {
    const familyTotal = familyItems.reduce((sum, i) => sum.add(qty(i)), Dec.zero())
    const beforeRemain = stockOf(1)
    const deductRatio = Dec.parse(meta(1).deductRatio)
    const tempDeduct = familyTotal.mul(deductRatio)

    let deductStock = Dec.zero()
    let afterRemain = Dec.zero()
    if (beforeRemain.sub(tempDeduct).lt(Dec.zero())) {
      const tempDeductStock = tempDeduct.floor()
      const tempRemain = tempDeduct.sub(tempDeductStock)
      if (beforeRemain.sub(tempRemain).lt(Dec.zero())) {
        deductStock = tempDeductStock.add(Dec.parse(1))
        afterRemain = beforeRemain.add(Dec.parse(1)).sub(tempRemain)
      } else {
        deductStock = tempDeductStock
        afterRemain = beforeRemain.sub(tempRemain)
      }
    } else {
      deductStock = Dec.zero()
      afterRemain = beforeRemain.sub(tempDeduct)
    }

    let totalPostageForFamily = Dec.zero()
    const postageParts: string[] = []
    familyItems.forEach(i => {
      const unit = Dec.parse(meta(i.skuId).postage)
      totalPostageForFamily = totalPostageForFamily.add(qty(i).mul(unit))
      postageParts.push(`${qty(i)}*${unit}`)
    })

    setStock(1, afterRemain)
    const jtItem = familyItems.find(i => meta(i.skuId).name === '家庭套')
    const xjItem = familyItems.find(i => meta(i.skuId).name === '家庭套（新疆西藏）')
    const jtQty = jtItem ? qty(jtItem) : Dec.zero()
    const xjQty = xjItem ? qty(xjItem) : Dec.zero()
    details.push(
      `后台家庭套${jtQty}件+新疆${xjQty}件=${familyTotal}*${deductRatio}=${tempDeduct}，之前余${beforeRemain}，扣减库存${deductStock}箱余${afterRemain}，邮费${postageParts.join('+')}=${totalPostageForFamily}`
    )
    totalPostage = totalPostage.add(totalPostageForFamily)
    totalDeductStock = totalDeductStock.add(deductStock)
  }

  // 2. 特惠9件套
  rows
    .filter(i => meta(i.skuId).name.includes('特惠9件套'))
    .forEach(i => {
      const m = meta(i.skuId)
      const beforeRemain = stockOf(i.skuId)
      const deductRatio = Dec.parse(m.deductRatio)
      const deduct = qty(i).mul(deductRatio)
      const deductInt = deduct.floor()
      const deductDec = deduct.sub(deductInt)
      const remain = beforeRemain.sub(deductDec)
      let deductStock = Dec.zero()
      let afterRemain = Dec.zero()
      if (remain.lt(Dec.zero())) {
        deductStock = deductInt.add(Dec.parse(1))
        afterRemain = remain.add(Dec.parse(1))
      } else {
        deductStock = deductInt
        afterRemain = remain
      }
      if (afterRemain.lt(Dec.zero())) afterRemain = Dec.zero()

      const postageUnit = Dec.parse(m.postage)
      const postage = qty(i).mul(postageUnit)
      details.push(
        `后台${m.name}${qty(i)}组，扣减库存${deductStock}，邮费${qty(i)}*${postageUnit}=${postage}`
      )
      setStock(i.skuId, afterRemain)
      totalPostage = totalPostage.add(postage)
      totalDeductStock = totalDeductStock.add(deductStock)
    })

  // 3. 洗衣液（整箱 + 散瓶共用一瓶装余量）
  const laundryItems = rows.filter(i => meta(i.skuId).name.includes('洗衣液'))
  if (laundryItems.length > 0) {
    const boxItems = laundryItems.filter(i => meta(i.skuId).name.includes('洗衣液（整箱）'))
    const normalItems = laundryItems.filter(
      i => meta(i.skuId).name.includes('洗衣液') && !meta(i.skuId).name.includes('整箱')
    )
    const boxCount = boxItems.reduce((sum, i) => sum + Math.trunc(i.quantity), 0)
    const bottleCount = normalItems.reduce((sum, i) => sum + Math.trunc(i.quantity), 0)

    const beforeRemain = normalItems.length > 0 ? stockOf(normalItems[0].skuId) : Dec.zero()
    const deductRatio = normalItems.length > 0 ? Dec.parse(meta(normalItems[0].skuId).deductRatio) : Dec.zero()

    let normalDeductStock = Dec.zero()
    let afterRemain = Dec.zero()
    if (normalItems.length > 0) {
      const r = calcDeductAndRemain(beforeRemain, bottleCount, deductRatio)
      normalDeductStock = r.deductStock
      afterRemain = r.afterRemain
      setStock(normalItems[0].skuId, afterRemain)
    }
    const boxDeductStock = Dec.parse(boxCount)
    const totalDeductStockLaundry = normalDeductStock.add(boxDeductStock)

    let normalPostage = Dec.zero()
    const normalParts: string[] = []
    normalItems.forEach(i => {
      const unit = Dec.parse(meta(i.skuId).postage)
      normalPostage = normalPostage.add(qty(i).mul(unit))
      normalParts.push(`${qty(i)}*${unit}`)
    })
    let boxPostage = Dec.zero()
    boxItems.forEach(i => {
      boxPostage = boxPostage.add(Dec.parse(i.userInputPostage ?? 0).mul(Dec.parse(1)))
    })

    details.push(
      buildLaundryLog(
        boxCount,
        bottleCount,
        beforeRemain,
        totalDeductStockLaundry,
        afterRemain,
        normalParts.join('+'),
        normalPostage
      )
    )
    totalPostage = totalPostage.add(normalPostage).add(boxPostage)
    totalDeductStock = totalDeductStock.add(totalDeductStockLaundry)
  }

  // 4. 洗脸巾（3 份扣 1 箱，另计差价；新疆款只出邮费，余量跟随普通款）
  const faceTowelItem = rows.find(i => meta(i.skuId).name === '洗脸巾')
  const xinjiangItem = rows.find(i => meta(i.skuId).name === '洗脸巾（新疆西藏）')
  if (faceTowelItem || xinjiangItem) {
    let beforeRemain = Dec.zero()
    let priceDifference = Dec.zero()
    let postageUnit = Dec.zero()
    if (faceTowelItem) {
      beforeRemain = stockOf(faceTowelItem.skuId)
      postageUnit = Dec.parse(meta(faceTowelItem.skuId).postage)
      priceDifference = Dec.parse(meta(faceTowelItem.skuId).agio ?? '0')
    }
    let xjPostageUnit = Dec.zero()
    if (xinjiangItem) {
      xjPostageUnit = Dec.parse(meta(xinjiangItem.skuId).postage)
    }

    const faceQty = faceTowelItem ? qty(faceTowelItem) : Dec.zero()
    const xjQty = xinjiangItem ? qty(xinjiangItem) : Dec.zero()
    const totalQty = faceQty.add(xjQty)

    const totalQuantity = totalQty.sub(beforeRemain)
    const tempDeductStock = totalQuantity.divFloorInt(3)
    const tempRemain = totalQuantity.modInt(3)
    let deductStock = Dec.zero()
    let afterRemain = Dec.zero()
    if (totalQuantity.lt(Dec.zero())) {
      afterRemain = beforeRemain.sub(totalQty)
    } else if (tempRemain.gt(Dec.zero())) {
      deductStock = tempDeductStock.add(Dec.parse(1))
      afterRemain = Dec.parse(3).sub(tempRemain)
    } else {
      deductStock = tempDeductStock
      afterRemain = Dec.zero()
    }

    const itemPriceDifference = totalQty.mul(priceDifference)
    const postage = faceQty.mul(postageUnit)
    const xjPostage = xjQty.mul(xjPostageUnit)

    let log = `后台洗脸巾${faceQty}份`
    if (xjQty.gt(Dec.zero())) log += `+新疆${xjQty}份`
    log += `，3份扣1箱库存，之前余${beforeRemain}，扣减库存${deductStock}箱余${afterRemain}，差价${totalQty}*${priceDifference}=${itemPriceDifference}，邮费${faceQty}*${postageUnit}=${postage}`
    if (xjQty.gt(Dec.zero())) log += `，新疆邮费${xjQty}*${xjPostageUnit}=${xjPostage}`
    details.push(log)

    if (faceTowelItem) setStock(faceTowelItem.skuId, afterRemain)
    totalPostage = totalPostage.add(postage).add(xjPostage)
    totalDeductStock = totalDeductStock.add(deductStock)
    totalPriceDifference = totalPriceDifference.add(itemPriceDifference)
  }

  // 5. 3瓶装洗护（3 组扣 1 箱）
  rows
    .filter(i => meta(i.skuId).name.includes('3瓶装洗护'))
    .forEach(i => {
      const m = meta(i.skuId)
      const beforeRemain = stockOf(i.skuId)
      const totalQuantity = qty(i).sub(beforeRemain)
      const tempDeductStock = totalQuantity.divFloorInt(3)
      const tempRemain = totalQuantity.modInt(3)
      let deductStock = Dec.zero()
      let afterRemain = Dec.zero()
      if (totalQuantity.lt(Dec.zero())) {
        afterRemain = beforeRemain.sub(qty(i))
      } else if (tempRemain.gt(Dec.zero())) {
        deductStock = tempDeductStock.add(Dec.parse(1))
        afterRemain = Dec.parse(3).sub(tempRemain)
      } else {
        deductStock = tempDeductStock
        afterRemain = Dec.zero()
      }

      const postageUnit = Dec.parse(m.postage)
      const postage = qty(i).mul(postageUnit)
      details.push(
        `后台${m.name}${qty(i)}组，3组扣1箱库存，之前余${beforeRemain}，扣减库存${deductStock}箱余${afterRemain}，邮费${qty(i)}*${postageUnit}=${postage}`
      )
      setStock(i.skuId, afterRemain)
      totalPostage = totalPostage.add(postage)
      totalDeductStock = totalDeductStock.add(deductStock)
    })

  // 6. 4瓶装洗护（按比例扣）
  rows
    .filter(i => meta(i.skuId).name.includes('4瓶装洗护'))
    .forEach(i => {
      const m = meta(i.skuId)
      const beforeRemain = stockOf(i.skuId)
      const deductRatio = Dec.parse(m.deductRatio)
      const deduct = qty(i).mul(deductRatio)
      const deductInt = deduct.floor()
      const deductDec = deduct.sub(deductInt)
      const remain = beforeRemain.sub(deductDec)
      let deductStock = Dec.zero()
      let afterRemain = Dec.zero()
      if (remain.lt(Dec.zero())) {
        deductStock = deductInt.add(Dec.parse(1))
        afterRemain = remain.add(Dec.parse(1))
      } else {
        deductStock = deductInt
        afterRemain = remain
      }
      if (afterRemain.lt(Dec.zero())) afterRemain = Dec.zero()

      const postageUnit = Dec.parse(m.postage)
      const postage = qty(i).mul(postageUnit)
      details.push(
        `后台${m.name}${qty(i)}组，${qty(i)}*${deductRatio}=${deduct}，之前余${beforeRemain}，扣减库存${deductStock}箱余${afterRemain}，邮费${qty(i)}*${postageUnit}=${postage}`
      )
      setStock(i.skuId, afterRemain)
      totalPostage = totalPostage.add(postage)
      totalDeductStock = totalDeductStock.add(deductStock)
    })

  // 7. 合计（按行顺序拼裸数字，整箱邮费以手工值为最后一项）
  const postageMap = new Map<string, Dec>()
  let boxPostages = Dec.zero()
  rows.forEach(i => {
    const m = meta(i.skuId)
    const postageUnit = Dec.parse(m.postage)
    let productPostage = Dec.zero()
    const hasInputPostage =
      m.name.includes('洗衣液（整箱）') &&
      i.userInputPostage !== undefined &&
      i.userInputPostage !== null
    if (hasInputPostage) {
      boxPostages = Dec.parse(i.userInputPostage)
    } else {
      productPostage = qty(i).mul(postageUnit)
    }
    if (productPostage.gt(Dec.zero())) {
      postageMap.set(m.name, productPostage)
    }
  })
  if (boxPostages.gt(Dec.zero())) {
    postageMap.set(String(postageMap.size + 1), boxPostages)
  }
  const postageFormula = Array.from(postageMap.values(), v => v.toString()).join('+')
  if (totalPriceDifference.gt(Dec.zero())) {
    details.push(
      `合计${postageFormula}=${totalPostage}+${totalPriceDifference}=${totalPostage.add(totalPriceDifference)}`
    )
  } else {
    details.push(`合计${postageFormula}=${totalPostage}`)
  }
  details.push(`总扣减库存：${totalDeductStock}`)

  const outStock: Record<string, string> = {}
  stock.forEach((value, skuId) => {
    outStock[String(skuId)] = value.toString()
  })

  return {
    details,
    totalPostage: totalPostage.add(totalPriceDifference).toString(),
    stock: outStock
  }
}
