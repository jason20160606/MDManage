<template>
  <div class="app-container">
    <el-row :gutter="20" class="statistics-cards">
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header><div class="card-header"><span>待结算{{ title }}</span><el-tag type="warning">待处理</el-tag></div></template>
          <div class="card-content"><span class="amount">¥{{ Number(statistics.pendingTotal).toFixed(2) }}</span></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header><div class="card-header"><span>本月{{ title }}总额</span><el-tag type="success">实时</el-tag></div></template>
          <div class="card-content"><span class="amount">¥{{ Number(statistics.monthTotal).toFixed(2) }}</span></div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header><div class="card-header"><span>本月{{ title }}单数</span><el-tag type="info">总计</el-tag></div></template>
          <div class="card-content"><span class="amount">{{ statistics.totalOrders }}</span></div>
        </el-card>
      </el-col>
    </el-row>

    <el-card class="search-card">
      <el-form :inline="true" class="search-form">
        <el-form-item label="经销商">
          <el-select v-model="queryForm.DealerId" placeholder="全部经销商" clearable filterable style="width: 200px">
            <el-option v-for="d in dealerList" :key="d.id" :label="d.name" :value="d.id" />
          </el-select>
        </el-form-item>
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.OrderNumber" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item label="结算状态">
          <el-select v-model="queryForm.Status" placeholder="全部" clearable style="width: 130px">
            <el-option label="待结算" :value="1" />
            <el-option label="已结算" :value="2" />
            <el-option label="已作废" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" :disabled="selectedRows.length === 0" @click="openSettleDialog">
            {{ title }}结算 ({{ selectedRows.length }})
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>{{ title }}应收明细</span>
          <span class="hint">勾选待结算行进行结算；已结算行可撤销</span>
        </div>
      </template>
      <el-table
        v-loading="loading"
        :data="billList"
        border
        style="width: 100%"
        empty-text="暂无数据"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="45" :selectable="canSelect" />
        <el-table-column prop="OrderNo" label="订单编号" min-width="220" show-overflow-tooltip />
        <el-table-column prop="DealerName" label="经销商" width="120" show-overflow-tooltip />
        <el-table-column label="金额" width="110" align="right">
          <template #default="{ row }">
            <span :class="{ 'negative': Number(row.Amount) < 0 }">¥{{ Number(row.Amount).toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="结算状态" width="100">
          <template #default="{ row }">
            <el-tag :type="statusTag(row.Status)">{{ statusText(row.Status) }}</el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="SettlementNo" label="结算单号" width="190" show-overflow-tooltip>
          <template #default="{ row }">{{ row.SettlementNo || '—' }}</template>
        </el-table-column>
        <el-table-column label="结算时间" width="160">
          <template #default="{ row }">{{ formatDate(row.SettledAt) || '—' }}</template>
        </el-table-column>
        <el-table-column prop="SettledByName" label="结算人" width="110">
          <template #default="{ row }">{{ row.SettledByName || '—' }}</template>
        </el-table-column>
        <el-table-column prop="Remark" label="备注" min-width="180" show-overflow-tooltip>
          <template #default="{ row }">{{ row.Remark || '—' }}</template>
        </el-table-column>
        <el-table-column label="操作" width="110" fixed="right">
          <template #default="{ row }">
            <el-button v-if="row.Status === 2 && row.SettlementId" type="danger" link @click="handleReverse(row)">撤销结算</el-button>
            <span v-else>—</span>
          </template>
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
          @current-change="handleQuery"
        />
      </div>
    </el-card>

    <el-dialog v-model="settleDialogVisible" :title="`${title}结算`" width="460px">
      <el-descriptions :column="1" border>
        <el-descriptions-item label="经销商">{{ settleDealerName }}</el-descriptions-item>
        <el-descriptions-item label="勾选笔数">{{ selectedRows.length }} 笔</el-descriptions-item>
        <el-descriptions-item label="应收合计">¥{{ selectedTotal.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item v-if="reversalAmount > 0" label="红字冲销抵扣">-¥{{ reversalAmount.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="实际结算金额"><b>¥{{ netSettleTotal.toFixed(2) }}</b></el-descriptions-item>
      </el-descriptions>
      <el-alert type="info" :closable="false" show-icon title="金额由勾选项自动合计，不可手工修改；已取消订单的红字冲销行会自动抵扣本期" style="margin: 12px 0" />
      <el-form label-width="80px">
        <el-form-item label="结算备注">
          <el-input v-model="settleRemark" type="textarea" :rows="2" placeholder="选填，如付款方式、流水号" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="settleDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="settling" @click="submitSettle">确认结算</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqReceivableList, reqSettle, reqReverseSettle } from '@/api/bill'
import { reqFreightStatistics, reqDiffPriceStatistics } from '@/api/order'
import { reqGetDealerList } from '@/api/organization/dealer'

const props = defineProps<{ billType: number; title: string }>()

const statistics = reactive({ monthTotal: 0, pendingTotal: 0, totalOrders: 0 })
const dealerList = ref<{ id: number; name: string }[]>([])
const queryForm = reactive<{ DealerId: number | string; OrderNumber: string; Status: number | string }>({
  DealerId: '', OrderNumber: '', Status: ''
})
const billList = ref<any[]>([])
const loading = ref(false)
const selectedRows = ref<any[]>([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const settleDialogVisible = ref(false)
const settleRemark = ref('')
const settling = ref(false)
const reversalAmount = ref(0)

const selectedTotal = computed(() => selectedRows.value.reduce((sum, r) => sum + Number(r.Amount || 0), 0))
const netSettleTotal = computed(() => selectedTotal.value - reversalAmount.value)
const settleDealerName = computed(() => selectedRows.value[0]?.DealerName || '—')

const statusText = (s: number) => ({ 1: '待结算', 2: '已结算', 3: '已作废' }[s] || '未知')
const statusTag = (s: number) => ({ 1: 'warning', 2: 'success', 3: 'info' }[s] || 'info')
const canSelect = (row: any) => row.Status === 1 && Number(row.Amount) > 0
const formatDate = (v: string) => v ? String(v).replace('T', ' ').slice(0, 19) : ''

const fetchStatistics = async () => {
  try {
    const dealerId = Number(queryForm.DealerId) || 0
    const res: any = props.billType === 1
      ? await reqFreightStatistics(dealerId)
      : await reqDiffPriceStatistics(dealerId)
    const d = res?.data || {}
    statistics.monthTotal = d.MonthsFreight ?? d.MonthsPriceDiff ?? 0
    statistics.pendingTotal = d.UnsettledFreight ?? d.UnsettledPriceDiff ?? 0
    statistics.totalOrders = d.FreightOrderNum ?? d.PriceDiffOrderNum ?? 0
  } catch {
    statistics.monthTotal = 0
    statistics.pendingTotal = 0
    statistics.totalOrders = 0
  }
}

const handleQuery = async () => {
  loading.value = true
  try {
    const params: any = {
      BillType: props.billType,
      DealerId: Number(queryForm.DealerId) || 0,
      PageNumber: currentPage.value,
      PageSize: pageSize.value
    }
    if (queryForm.OrderNumber?.trim()) params.OrderNumber = queryForm.OrderNumber.trim()
    if (queryForm.Status !== '' && queryForm.Status !== null) params.Status = Number(queryForm.Status)
    const res: any = await reqReceivableList(params)
    billList.value = res?.data || []
    const raw = res?.headers?.['x-pagination']
    total.value = raw ? (typeof raw === 'string' ? JSON.parse(raw).TotalCount : raw.TotalCount) : billList.value.length
  } catch (e) {
    console.error('获取应收明细失败', e)
    billList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  queryForm.DealerId = ''
  queryForm.OrderNumber = ''
  queryForm.Status = ''
  currentPage.value = 1
  handleQuery()
}

const handleSelectionChange = (rows: any[]) => { selectedRows.value = rows }

const openSettleDialog = async () => {
  if (selectedRows.value.length === 0) {
    ElMessage.warning('请先勾选要结算的账单')
    return
  }
  const dealerId = selectedRows.value[0].DealerId
  if (selectedRows.value.some(r => r.DealerId !== dealerId)) {
    ElMessage.warning('一次只能结算同一个经销商的账单')
    return
  }
  // 预估本期可自动抵扣的红字冲销额（后端结算时会再次实时计算并纳入结算单）
  reversalAmount.value = 0
  try {
    const res: any = await reqReceivableList({
      BillType: props.billType, DealerId: dealerId, Status: 1, PageNumber: 1, PageSize: 1000
    })
    const rows: any[] = res?.data || (Array.isArray(res) ? res : [])
    reversalAmount.value = -rows.filter(r => Number(r.Amount) < 0).reduce((s, r) => s + Number(r.Amount), 0)
  } catch {
    reversalAmount.value = 0
  }
  if (netSettleTotal.value <= 0) {
    ElMessage.warning('红字冲销金额已覆盖本次勾选金额，无需结算')
    return
  }
  settleRemark.value = ''
  settleDialogVisible.value = true
}

const submitSettle = async () => {
  if (settling.value) return
  settling.value = true
  try {
    const res: any = await reqSettle({
      DealerId: Number(selectedRows.value[0].DealerId),
      BillType: props.billType,
      ReceivableIds: selectedRows.value.map(r => r.Id),
      Remark: settleRemark.value || undefined
    })
    // 响应拦截器已把 ApiResponse.Data 拆包成 SettleResultDto
    const actual = Number(res?.TotalAmount ?? netSettleTotal.value)
    const reversal = Number(res?.ReversalAmount ?? 0)
    ElMessage.success(`结算成功：${res?.SettlementNo || ''}，实结 ¥${actual.toFixed(2)}${reversal > 0 ? `（含红字抵扣 ¥${reversal.toFixed(2)}）` : ''}`)
    settleDialogVisible.value = false
    selectedRows.value = []
    fetchStatistics()
    handleQuery()
  } catch (e) {
    // 业务失败原因已由响应拦截器提示
    console.warn('结算失败', e)
  } finally {
    settling.value = false
  }
}

const handleReverse = async (row: any) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入撤销原因（留痕，可在额度日志中查看）', '撤销结算', {
      confirmButtonText: '确认撤销', cancelButtonText: '取消', inputPlaceholder: '如：金额填错、重复结算'
    })
    await reqReverseSettle({ SettlementId: Number(row.SettlementId), Reason: value || '' })
    ElMessage.success('已撤销结算，账单恢复为待结算')
    fetchStatistics()
    handleQuery()
  } catch (e) {
    if (e !== 'cancel' && e !== 'close') console.warn('撤销结算失败', e)
  }
}

watch(() => queryForm.DealerId, () => { currentPage.value = 1; fetchStatistics(); handleQuery() })

onMounted(async () => {
  try {
    const res: any = await reqGetDealerList({ PageNumber: 1, pageSize: 1000 })
    const rows: any[] = res?.data || (Array.isArray(res) ? res : [])
    dealerList.value = rows.map((d: any) => ({ id: d.Id, name: d.Name }))
  } catch {
    dealerList.value = []
  }
  fetchStatistics()
  handleQuery()
})
</script>

<style lang="scss" scoped>
.app-container { padding: 20px; }
.statistics-cards { margin-bottom: 16px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.card-content { .amount { font-size: 24px; font-weight: 500; color: #303133; } }
.hint { font-size: 12px; color: #909399; }
.search-card { margin-bottom: 16px; }
.search-form { margin-bottom: -18px; }
.table-card { margin-bottom: 20px; }
.pagination-wrapper { margin-top: 20px; display: flex; justify-content: flex-end; }
.negative { color: #f56c6c; }
</style>
