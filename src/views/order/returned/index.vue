<template>
  <div class="app-container">
    <el-card class="search-card">
      <el-form :inline="true" class="search-form">
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.OrderNumber" placeholder="请输入订单编号" clearable style="width: 220px" />
        </el-form-item>
        <el-form-item label="经销商">
          <el-select v-model="queryForm.DealerId" placeholder="全部经销商" clearable filterable style="width: 180px">
            <el-option v-for="d in dealerList" :key="d.Id" :label="d.Name" :value="d.Id" />
          </el-select>
        </el-form-item>
        <el-form-item label="退货日期">
          <el-date-picker v-model="queryForm.DateRange" type="daterange" value-format="YYYY-MM-DD"
            range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" style="width: 250px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>退货记录</span>
          <span class="hint">整单退货凭证：额度、库存、运费/差价冲销均可追溯</span>
        </div>
      </template>
      <el-table v-loading="loading" :data="list" border style="width: 100%" empty-text="暂无退货记录">
        <el-table-column prop="ReturnNo" label="退货单号" width="200" show-overflow-tooltip />
        <el-table-column prop="OrderNo" label="订单编号" width="220" show-overflow-tooltip />
        <el-table-column prop="DealerName" label="经销商" width="110" show-overflow-tooltip />
        <el-table-column label="状态变化" width="150">
          <template #default="{ row }">{{ statusText(row.BeforeStatus) }} → {{ statusText(row.AfterStatus) }}</template>
        </el-table-column>
        <el-table-column label="退回箱数" width="100" align="right">
          <template #default="{ row }">{{ fmtQty(Number(row.TotalQty || 0)) }}</template>
        </el-table-column>
        <el-table-column label="返还额度" width="100" align="right">
          <template #default="{ row }">{{ fmtQty(Number(row.QuotaRestored || 0)) }}</template>
        </el-table-column>
        <el-table-column label="运费冲销" width="100" align="right">
          <template #default="{ row }">¥{{ Number(row.FreightReversed || 0).toFixed(2) }}</template>
        </el-table-column>
        <el-table-column label="差价冲销" width="100" align="right">
          <template #default="{ row }">¥{{ Number(row.PriceDiffReversed || 0).toFixed(2) }}</template>
        </el-table-column>
        <el-table-column prop="Reason" label="退货原因" width="140" show-overflow-tooltip />
        <el-table-column prop="CreatedByName" label="操作人" width="110" show-overflow-tooltip />
        <el-table-column label="退货时间" width="165">
          <template #default="{ row }">{{ formatDate(row.CreatedAt) }}</template>
        </el-table-column>
        <el-table-column prop="Remark" label="备注" min-width="160" show-overflow-tooltip>
          <template #default="{ row }">{{ row.Remark || '—' }}</template>
        </el-table-column>
      </el-table>
      <div class="pagination-wrapper">
        <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50]" :total="total" layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleQuery" @current-change="handleQuery" />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { reqReturnList } from '@/api/order'
import { reqGetDealerList } from '@/api/organization/dealer'
import { showError, getTotal } from '@/utils/request'
import { fmtQty } from '@/utils/orderQty'

const queryForm = reactive<{ OrderNumber: string; DealerId: number | string; DateRange: string[] }>({
  OrderNumber: '', DealerId: '', DateRange: []
})
const dealerList = ref<any[]>([])
const list = ref<any[]>([])
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

const statusMap: Record<number, string> = {
  1: '待审核', 2: '待发货', 3: '部分发货', 4: '已发货', 5: '已签收', 6: '已取消', 7: '已驳回', 8: '已退货'
}
const statusText = (s: number) => statusMap[s] || '未知'
const formatDate = (v: string) => v ? String(v).replace('T', ' ').slice(0, 19) : '—'

const handleQuery = async () => {
  loading.value = true
  try {
    const params: any = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNumber: queryForm.OrderNumber.trim() || undefined,
      DealerId: Number(queryForm.DealerId) || 0
    }
    if (queryForm.DateRange?.length === 2) {
      params.StartDate = queryForm.DateRange[0]
      params.EndDate = queryForm.DateRange[1]
    }
    const res: any = await reqReturnList(params)
    list.value = Array.isArray(res?.data) ? res.data : (Array.isArray(res) ? res : [])
    total.value = getTotal(res, list.value.length)
  } catch (e) {
    showError(e, '获取退货记录失败')
    list.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

const handleReset = () => {
  queryForm.OrderNumber = ''
  queryForm.DealerId = ''
  queryForm.DateRange = []
  currentPage.value = 1
  handleQuery()
}

onMounted(async () => {
  try {
    const res: any = await reqGetDealerList({ PageNumber: 1, pageSize: 1000 })
    dealerList.value = Array.isArray(res?.data) ? res.data : []
  } catch {
    dealerList.value = []
  }
  handleQuery()
})
</script>

<style scoped>
.app-container { padding: 20px; }
.card-header { display: flex; justify-content: space-between; align-items: center; }
.hint { font-size: 12px; color: #909399; }
.search-card { margin-bottom: 16px; }
.search-form { margin-bottom: -18px; }
.pagination-wrapper { margin-top: 20px; display: flex; justify-content: flex-end; }
</style>
