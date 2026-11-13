<template>
  <el-dialog
    v-model="visible"
    :title="dialogTitle"
    width="1040px"
    top="5vh"
    destroy-on-close
  >
    <div v-loading="loading" class="detail-body">
      <template v-if="detail">
        <!-- 一、账单本身 -->
        <div class="section-title">账单信息</div>
        <el-descriptions :column="3" border size="small">
          <el-descriptions-item label="订单编号">{{ detail.OrderNo || '—' }}</el-descriptions-item>
          <el-descriptions-item label="经销商">{{ detail.DealerName || '—' }}</el-descriptions-item>
          <el-descriptions-item label="账单类型">{{ detail.BillTypeName }}</el-descriptions-item>
          <el-descriptions-item label="金额">
            <span :class="{ negative: Number(detail.Amount) < 0 }">¥{{ money(detail.Amount) }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="结算状态">
            <el-tag :type="statusTag(detail.Status)" size="small">{{ detail.StatusName }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="结算单号">{{ detail.SettlementNo || '—' }}</el-descriptions-item>
          <el-descriptions-item label="结算时间">{{ datetime(detail.SettledAt) || '—' }}</el-descriptions-item>
          <el-descriptions-item label="结算人">{{ detail.SettledByName || '—' }}</el-descriptions-item>
          <el-descriptions-item label="生成时间">{{ datetime(detail.CreatedAt) }}</el-descriptions-item>
          <el-descriptions-item label="备注" :span="3">{{ detail.Remark || '—' }}</el-descriptions-item>
        </el-descriptions>

        <!-- 二、订单与收货 -->
        <div class="section-title">订单与收货信息</div>
        <el-descriptions :column="3" border size="small">
          <el-descriptions-item label="订单状态">{{ detail.OrderStatusName }}</el-descriptions-item>
          <el-descriptions-item label="发货仓">{{ detail.WarehouseName || '—' }}</el-descriptions-item>
          <el-descriptions-item label="配送方式">{{ detail.DeliveryTypeName }}</el-descriptions-item>
          <el-descriptions-item label="应发箱数">{{ fmtQty(detail.TotalShipQty) }} 箱</el-descriptions-item>
          <el-descriptions-item label="已发箱数">{{ fmtQty(detail.ShippedQty) }} 箱</el-descriptions-item>
          <el-descriptions-item label="发货单数">{{ detail.ShipmentCount }} 张</el-descriptions-item>
          <el-descriptions-item label="收件人">{{ detail.ReceiverName || '—' }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ detail.ReceiverPhone || '—' }}</el-descriptions-item>
          <el-descriptions-item label="审核时间">{{ datetime(detail.AuditAt) || '—' }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ detail.ReceiverAddress || '—' }}</el-descriptions-item>
          <el-descriptions-item label="订单运费">¥{{ money(detail.OrderFreight) }}</el-descriptions-item>
          <el-descriptions-item label="订单差价">¥{{ money(detail.OrderPriceDiff) }}</el-descriptions-item>
          <el-descriptions-item label="司机 / 车牌">
            {{ detail.DriverName || '—' }}<span v-if="detail.CarPlateNumber"> / {{ detail.CarPlateNumber }}</span>
          </el-descriptions-item>
          <el-descriptions-item label="司机电话">{{ detail.DriverPhone || '—' }}</el-descriptions-item>
        </el-descriptions>

        <!-- 三、发货商品 / 快递明细 -->
        <el-tabs v-model="activeTab" class="detail-tabs">
          <el-tab-pane :label="`发货商品明细 (${detail.Items?.length || 0})`" name="goods">
            <el-table :data="detail.Items || []" border size="small" empty-text="该订单没有商品明细">
              <el-table-column label="商品" min-width="180">
                <template #default="{ row }">
                  <div>{{ row.ProductName }}</div>
                  <div v-if="row.Specs" class="sub">{{ row.Specs }}</div>
                </template>
              </el-table-column>
              <el-table-column label="额度箱" width="90" align="right">
                <template #default="{ row }">{{ fmtQty(row.QuotaQty) }}</template>
              </el-table-column>
              <el-table-column label="应发(箱)" width="90" align="right">
                <template #default="{ row }">{{ fmtQty(row.ShipQty) }}</template>
              </el-table-column>
              <el-table-column label="已发(箱)" width="90" align="right">
                <template #default="{ row }">
                  <span :class="{ warn: Number(row.ShippedQty) < Number(row.ShipQty) }">{{ fmtQty(row.ShippedQty) }}</span>
                </template>
              </el-table-column>
              <el-table-column label="单价" width="100" align="right">
                <template #default="{ row }">¥{{ money(row.UnitPrice) }}</template>
              </el-table-column>
              <el-table-column label="金额" width="110" align="right">
                <template #default="{ row }">¥{{ money(row.TotalPrice) }}</template>
              </el-table-column>
              <el-table-column label="差价单价" width="100" align="right">
                <template #default="{ row }">¥{{ money(row.PriceDiffUnit) }}</template>
              </el-table-column>
              <el-table-column label="差价金额" width="110" align="right">
                <template #default="{ row }">
                  <span :class="{ 'diff-amount': Number(row.PriceDiffAmount) !== 0 }">¥{{ money(row.PriceDiffAmount) }}</span>
                </template>
              </el-table-column>
            </el-table>

            <div v-if="(detail.Shipments || []).length" class="ship-block">
              <div class="block-title">按发货单拆分</div>
              <div v-for="s in detail.Shipments" :key="'g' + s.Id" class="ship-card">
                <div class="ship-head">
                  <span class="ship-no">{{ s.ShipmentNo }}</span>
                  <el-tag size="small" type="info">{{ s.ShipmentTypeName }}</el-tag>
                  <span class="sub">{{ datetime(s.CreatedAt) }}</span>
                  <span class="sub">本次发出 {{ fmtQty(s.TotalQuantity) }} 箱</span>
                  <span class="sub" v-if="s.CarrierName">· {{ s.CarrierName }} {{ s.TrackingNo || '' }}</span>
                </div>
                <el-table :data="s.Items || []" border size="small">
                  <el-table-column label="商品" min-width="200">
                    <template #default="{ row }">
                      <div>{{ row.ProductName }}</div>
                      <div v-if="row.Specs" class="sub">{{ row.Specs }}</div>
                    </template>
                  </el-table-column>
                  <el-table-column label="数量(箱)" width="110" align="right">
                    <template #default="{ row }">{{ fmtQty(row.Quantity) }}</template>
                  </el-table-column>
                  <el-table-column label="单价" width="110" align="right">
                    <template #default="{ row }">¥{{ money(row.UnitPrice) }}</template>
                  </el-table-column>
                  <el-table-column label="金额" width="120" align="right">
                    <template #default="{ row }">¥{{ money(row.Amount) }}</template>
                  </el-table-column>
                </el-table>
              </div>
            </div>
            <el-empty v-else description="还没有发货记录（账单可能来自历史数据重建）" :image-size="70" />
          </el-tab-pane>

          <el-tab-pane :label="`快递 / 物流明细 (${detail.ShipmentCount || 0})`" name="express">
            <el-table :data="detail.Shipments || []" border size="small" empty-text="暂无发货单">
              <el-table-column prop="ShipmentNo" label="发货单号" min-width="210" show-overflow-tooltip />
              <el-table-column prop="ShipmentTypeName" label="发货类型" width="100" />
              <el-table-column label="物流公司" width="120">
                <template #default="{ row }">{{ row.CarrierName || '—' }}</template>
              </el-table-column>
              <el-table-column label="运单号" min-width="180" show-overflow-tooltip>
                <template #default="{ row }">{{ row.TrackingNo || '—' }}</template>
              </el-table-column>
              <el-table-column label="司机 / 车牌" min-width="140">
                <template #default="{ row }">
                  <span v-if="row.DriverName || row.CarNumber">{{ row.DriverName || '—' }}<span v-if="row.CarNumber"> / {{ row.CarNumber }}</span></span>
                  <span v-else>—</span>
                </template>
              </el-table-column>
              <el-table-column label="发货时间" width="160">
                <template #default="{ row }">{{ datetime(row.CreatedAt) }}</template>
              </el-table-column>
            </el-table>

            <div v-for="s in detail.Shipments || []" :key="'t' + s.Id" class="ship-block">
              <div class="block-title">
                {{ s.ShipmentNo }} 物流轨迹
                <span class="sub" v-if="s.TrackingNo">（{{ s.CarrierName }} {{ s.TrackingNo }}）</span>
              </div>
              <div v-if="(s.Tracks || []).length" class="track-box">
                <el-timeline>
                  <el-timeline-item
                    v-for="(t, idx) in s.Tracks"
                    :key="idx"
                    :timestamp="datetime(t.Time)"
                    :type="idx === 0 ? 'primary' : ''"
                    placement="top"
                  >
                    <div class="track-line">
                      <el-tag v-if="t.Status" size="small" :type="idx === 0 ? 'success' : 'info'">{{ t.Status }}</el-tag>
                      <span v-if="t.Location" class="track-loc">{{ t.Location }}</span>
                      <span class="track-remark">{{ t.Remark }}</span>
                    </div>
                  </el-timeline-item>
                </el-timeline>
              </div>
              <div v-else class="sub">暂无物流轨迹（发货单没有回传轨迹，或为自提）</div>
            </div>
          </el-tab-pane>
        </el-tabs>
      </template>
      <el-empty v-else-if="!loading" description="暂无详情" />
    </div>

    <template #footer>
      <el-button @click="visible = false">关闭</el-button>
    </template>
  </el-dialog>
</template>

<script setup lang="ts">
// 运费 / 差价账单「详情」：账单信息 + 订单商品明细 + 逐张发货单的快递与轨迹
import { computed, ref, watch } from 'vue'
import { reqReceivableDetail } from '@/api/bill'
import { fmtQty } from '@/utils/orderQty'

const props = defineProps<{
  modelValue: boolean
  receivableId: number | null
  billTitle: string
}>()
const emit = defineEmits<{ (e: 'update:modelValue', val: boolean): void }>()

const visible = computed({
  get: () => props.modelValue,
  set: (val: boolean) => emit('update:modelValue', val)
})

const loading = ref(false)
const detail = ref<any>(null)
const activeTab = ref<'goods' | 'express'>('goods')

const dialogTitle = computed(() =>
  `${props.billTitle}账单详情${detail.value?.OrderNo ? '：' + detail.value.OrderNo : ''}`
)

const money = (v: any) => Number(v || 0).toFixed(2)
const datetime = (v: any) => (v ? String(v).replace('T', ' ').slice(0, 19) : '')
const statusTag = (s: number) => ({ 1: 'warning', 2: 'success', 3: 'info' }[s] || 'info')

const load = async () => {
  if (!props.receivableId) return
  loading.value = true
  detail.value = null
  activeTab.value = 'goods'
  try {
    detail.value = await reqReceivableDetail(props.receivableId)
  } catch {
    detail.value = null
  } finally {
    loading.value = false
  }
}

watch(
  () => [props.modelValue, props.receivableId],
  ([open]) => {
    if (open) load()
  },
  { immediate: true }
)
</script>

<style lang="scss" scoped>
.detail-body {
  min-height: 160px;
  max-height: 72vh;
  overflow-y: auto;
  padding-right: 4px;
}

.section-title {
  font-size: 14px;
  font-weight: 600;
  color: #303133;
  margin: 4px 0 8px;
  padding-left: 8px;
  border-left: 3px solid #409eff;

  &:not(:first-child) {
    margin-top: 18px;
  }
}

.detail-tabs {
  margin-top: 16px;
}

.sub {
  font-size: 12px;
  color: #909399;
}

.warn {
  color: #e6a23c;
  font-weight: 600;
}

.negative {
  color: #f56c6c;
}

.diff-amount {
  color: #e6a23c;
  font-weight: 600;
}

.ship-block {
  margin-top: 14px;
}

.block-title {
  font-size: 13px;
  font-weight: 600;
  color: #606266;
  margin-bottom: 8px;
}

.ship-card {
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 10px 12px;
  margin-bottom: 12px;
  background: #fafafa;
}

.ship-head {
  display: flex;
  align-items: center;
  gap: 10px;
  font-size: 13px;
  margin-bottom: 8px;
  flex-wrap: wrap;
}

.ship-no {
  font-weight: 600;
  color: #303133;
}

.track-box {
  max-height: 320px;
  overflow-y: auto;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 12px 12px 0;
  background: #fff;
}

.track-line {
  display: flex;
  align-items: flex-start;
  gap: 8px;
}

.track-loc {
  flex: none;
  font-size: 12px;
  color: #409eff;
  line-height: 22px;
}

.track-remark {
  font-size: 12px;
  color: #606266;
  line-height: 1.6;
  word-break: break-all;
}
</style>
