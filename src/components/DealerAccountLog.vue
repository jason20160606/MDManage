<template>
  <el-dialog
    v-model="visible"
    :title="dialogTitle"
    width="1080px"
    top="6vh"
    destroy-on-close
    @open="handleOpen"
  >
    <!-- 筛选条件：经销商 + 时间范围 -->
    <div class="log-toolbar">
      <div class="toolbar-item">
        <span class="label">经销商</span>
        <span v-if="lockedDealer" class="locked-dealer">{{ dealerName || '—' }}</span>
        <el-select
          v-else
          v-model="dealerId"
          placeholder="请选择经销商"
          filterable
          clearable
          style="width: 220px"
          @change="handleQuery"
        >
          <el-option v-for="d in dealerList" :key="d.id" :label="d.name" :value="d.id" />
        </el-select>
      </div>
      <div class="toolbar-item">
        <span class="label">变动时间</span>
        <el-date-picker
          v-model="dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          value-format="YYYY-MM-DD"
          style="width: 260px"
          @change="handleQuery"
        />
      </div>
      <div class="toolbar-item">
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="handleReset">重置</el-button>
      </div>
    </div>

    <!-- 账户切换：仅在未锁定账户类型时显示（额度变动请到库存管理的库存记录查看） -->
    <el-tabs v-if="!lockedType" v-model="activeType" class="account-tabs" @tab-change="handleTypeChange">
      <el-tab-pane label="运费账户" name="2" />
      <el-tab-pane label="差价账户" name="3" />
    </el-tabs>

    <template v-if="hasDealer">
      <!-- 汇总：按当前筛选条件统计全部记录，不是当前页 -->
      <div class="summary-bar">
        <div class="summary-item">
          <span class="summary-label">账户余额</span>
          <span class="summary-value">{{ balanceText }}</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">总增加</span>
          <span class="summary-value increase">{{ signedTotal(statistics.TotalIn, '+') }}</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">总扣减</span>
          <span class="summary-value decrease">{{ signedTotal(statistics.TotalOut, '-') }}</span>
        </div>
        <div class="summary-item">
          <span class="summary-label">记录数</span>
          <span class="summary-value">{{ statistics.Count }} 条</span>
        </div>
      </div>

      <el-table
        v-loading="loading"
        :data="logs"
        border
        size="small"
        max-height="440"
        empty-text="暂无变动记录"
      >
        <el-table-column label="变动时间" width="140">
          <template #default="{ row }">{{ datetime(row.CreatedAt) }}</template>
        </el-table-column>
        <el-table-column label="业务类型" width="100">
          <template #default="{ row }">
            <el-tag :type="operationTag(row.OperationType)" size="small">
              {{ operationText(row.OperationType) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="变动金额" width="100" align="right">
          <template #default="{ row }">
            <span :class="deltaOf(row) >= 0 ? 'increase' : 'decrease'">{{ signedMoney(row) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="变动前" width="90" align="right">
          <template #default="{ row }">{{ money(row.BeforeAmount) }}</template>
        </el-table-column>
        <el-table-column label="变动后" width="90" align="right">
          <template #default="{ row }">{{ money(row.AfterAmount) }}</template>
        </el-table-column>
        <el-table-column label="来源单号" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ row.Source || '—' }}</template>
        </el-table-column>
        <el-table-column label="操作人" width="80" show-overflow-tooltip>
          <template #default="{ row }">{{ row.Operator || '系统' }}</template>
        </el-table-column>
        <el-table-column label="备注" min-width="200" show-overflow-tooltip>
          <template #default="{ row }">{{ row.Remark || '—' }}</template>
        </el-table-column>
      </el-table>

      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleQuery"
          @current-change="fetchLogs"
        />
      </div>
    </template>

    <el-empty v-else description="请先选择经销商，再查看账户变动记录" :image-size="90" />
  </el-dialog>
</template>

<script setup lang="ts">
import { ref, reactive, computed, watch, onMounted } from 'vue'
import { getList, getTotal } from '@/utils/request'
import {
  reqDealerLogList,
  reqDealerLogStatistics,
  reqDealerNameList,
  reqGetDealerDetail
} from '@/api/organization/dealer'

const props = defineProps<{
  modelValue: boolean
  /** 外部指定的经销商，传入后弹窗内不可切换 */
  dealerId?: number | string | null
  dealerName?: string
  /** 账户类型 2=运费 3=差价；不传则弹窗内用 Tab 切换 */
  logType?: number | null
}>()

const emit = defineEmits<{ (e: 'update:modelValue', val: boolean): void }>()

const visible = computed({
  get: () => props.modelValue,
  set: (val: boolean) => emit('update:modelValue', val)
})

const lockedDealer = computed(() => Number(props.dealerId) > 0)
const lockedType = computed(() => props.logType !== null && props.logType !== undefined)

const dealerList = ref<{ id: number; name: string }[]>([])
const dealerId = ref<number | string>('')
const activeType = ref<string>('2')
const dateRange = ref<[string, string] | []>([])
const logs = ref<any[]>([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const statistics = reactive({ TotalIn: 0, TotalOut: 0, Count: 0 })
const balance = ref<number | null>(null)

const currentLogType = computed(() => (Number(activeType.value) === 3 ? 3 : 2))
const hasDealer = computed(() => Number(dealerId.value) > 0)

const typeName = computed(() => ({ 2: '运费', 3: '差价' }[currentLogType.value] || ''))

const dialogTitle = computed(() => {
  const who = lockedDealer.value ? props.dealerName || '' : ''
  return `${who}${typeName.value}账户变动记录`
})

/** 账户余额取自经销商档案上的当前欠款（Freight / PriceDiff），与列表口径一致 */
const balanceText = computed(() => (balance.value === null ? '—' : money(balance.value)))

const money = (v: any) => Number(v ?? 0).toFixed(2)
const signedTotal = (v: any, sign: '+' | '-') => {
  const n = Number(v ?? 0)
  return n > 0 ? `${sign}${money(n)}` : money(0)
}
const datetime = (v: any) => (v ? String(v).replace('T', ' ').slice(0, 19) : '')

/** 方向只看 after - before，不能用 OperationType 判断（它是业务来源，不是增减） */
const deltaOf = (row: any) => Number(row.AfterAmount ?? 0) - Number(row.BeforeAmount ?? 0)
const signedMoney = (row: any) => {
  const delta = deltaOf(row)
  return `${delta >= 0 ? '+' : '-'}${money(Math.abs(delta))}`
}

const OPERATION_TEXT: Record<number, string> = {
  1: '业绩录入',
  2: '订单审核',
  3: '订单取消',
  4: '订单发货',
  5: '退货',
  6: '库存盘点',
  7: '账单结算',
  8: '结算撤销/新增',
  9: '运费补扣',
  10: '其他增加',
  11: '其他减少',
  12: '退货冲减'
}
const operationText = (type: number) => OPERATION_TEXT[type] || `类型${type}`
const operationTag = (type: number) => {
  if (type === 7) return 'success'
  if (type === 3 || type === 11 || type === 12) return 'danger'
  if (type === 4) return 'warning'
  return 'info'
}

const buildParams = () => {
  const params: any = {
    DealerId: Number(dealerId.value),
    LogType: currentLogType.value,
    PageNumber: currentPage.value,
    PageSize: pageSize.value
  }
  if (dateRange.value?.length === 2) {
    params.CreatedAtMin = dateRange.value[0]
    params.CreatedAtMax = dateRange.value[1]
  }
  return params
}

const fetchLogs = async () => {
  if (!hasDealer.value) {
    logs.value = []
    total.value = 0
    return
  }
  loading.value = true
  try {
    const res: any = await reqDealerLogList(buildParams())
    logs.value = getList(res)
    total.value = getTotal(res, logs.value.length)
  } catch (e) {
    console.warn('获取账户变动记录失败', e)
    logs.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const fetchStatistics = async () => {
  if (!hasDealer.value) {
    statistics.TotalIn = 0
    statistics.TotalOut = 0
    statistics.Count = 0
    return
  }
  try {
    const res: any = await reqDealerLogStatistics(buildParams())
    statistics.TotalIn = Number(res?.TotalIn ?? 0)
    statistics.TotalOut = Number(res?.TotalOut ?? 0)
    statistics.Count = Number(res?.Count ?? 0)
  } catch {
    statistics.TotalIn = 0
    statistics.TotalOut = 0
    statistics.Count = 0
  }
}

/** 账户余额：取经销商档案上的当前运费/差价欠款，避免用分页数据的首行推算 */
const fetchBalance = async () => {
  if (!hasDealer.value) {
    balance.value = null
    return
  }
  try {
    const res: any = await reqGetDealerDetail(Number(dealerId.value))
    balance.value = Number((currentLogType.value === 2 ? res?.Freight : res?.PriceDiff) ?? 0)
  } catch {
    balance.value = null
  }
}

const refresh = () => {
  fetchLogs()
  fetchStatistics()
  fetchBalance()
}

const handleQuery = () => {
  currentPage.value = 1
  refresh()
}

const handleTypeChange = () => {
  currentPage.value = 1
  refresh()
}

const handleReset = () => {
  dateRange.value = []
  currentPage.value = 1
  refresh()
}

const loadDealers = async () => {
  if (dealerList.value.length > 0) return
  try {
    const res: any = await reqDealerNameList()
    const rows: any[] = Array.isArray(res) ? res : getList(res)
    dealerList.value = rows.map((d: any) => ({ id: d.Id, name: d.Name }))
  } catch {
    dealerList.value = []
  }
}

const handleOpen = () => {
  dealerId.value = props.dealerId ? Number(props.dealerId) : ''
  activeType.value = String(props.logType ?? 2)
  dateRange.value = []
  currentPage.value = 1
  logs.value = []
  total.value = 0
  balance.value = null
  statistics.TotalIn = 0
  statistics.TotalOut = 0
  statistics.Count = 0
  loadDealers()
  refresh()
}

// 外部经销商变化时（同一页面连续打开不同经销商的记录）同步刷新
watch(
  () => props.dealerId,
  (val) => {
    if (!visible.value) return
    dealerId.value = val ? Number(val) : ''
    handleQuery()
  }
)

onMounted(() => {
  if (!lockedDealer.value) loadDealers()
})
</script>

<style lang="scss" scoped>
.log-toolbar {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 16px;
  margin-bottom: 8px;
}

.toolbar-item {
  display: flex;
  align-items: center;
  gap: 8px;

  .label {
    font-size: 13px;
    color: #606266;
  }
}

.locked-dealer {
  font-weight: 500;
  color: #303133;
}

.account-tabs {
  margin-bottom: 4px;
}

.summary-bar {
  display: flex;
  flex-wrap: wrap;
  gap: 32px;
  padding: 10px 16px;
  margin-bottom: 12px;
  background: #f5f7fa;
  border-radius: 4px;
}

.summary-item {
  display: flex;
  align-items: baseline;
  gap: 8px;

  .summary-label {
    font-size: 13px;
    color: #909399;
  }

  .summary-value {
    font-size: 16px;
    font-weight: 600;
    color: #303133;
  }
}

.increase {
  color: #67c23a;
}

.decrease {
  color: #f56c6c;
}

.pagination-wrapper {
  margin-top: 16px;
  display: flex;
  justify-content: flex-end;
}
</style>
