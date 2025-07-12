<template>
  <div class="app-container">
    <!-- 统计卡片放最顶端 -->
    <el-row :gutter="22" class="statistics-cards">
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>待结算差价</span>
              <el-tag type="warning">待处理</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">¥{{ statistics.pendingTotal }}</span>            
          </div>
        </el-card>
      </el-col>      
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>差价账单数</span>
              <el-tag type="info">总计</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">{{ statistics.totalOrders }}</span>           
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>本月差价总额</span>
              <el-tag type="success">实时</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">¥{{ statistics.monthTotal }}</span>            
          </div>
        </el-card>
      </el-col>
    </el-row>
    <!-- 搜索表单 -->
    <el-card class="search-card">
      <el-form :model="queryForm" :inline="true" class="search-form">
        <el-form-item label="经销商">
          <el-select
            v-model="queryForm.DealerId"
            placeholder="请选择经销商"
            clearable
            filterable
            style="width: 200px"
          >
            <el-option
              v-for="dealer in dealerList"
              :key="dealer.id"
              :label="dealer.name"
              :value="dealer.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="handleBatchSettle">差价结算</el-button>
          <el-button :type="showDiffLogView ? 'primary' : 'info'" @click="handleToggleDiffLog">
            {{ showDiffLogView ? '差价账单列表' : '差价日志' }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>
    <!-- 视图切换：账单表格/弹窗 <-> 差价日志 -->
    <div v-if="!showDiffLogView">
      <!-- 差价账单列表 -->
      <el-card class="table-card">
        <template #header>
          <div class="card-header">
            <span>差价账单列表</span>
            <div class="header-buttons">
              <el-button type="primary" @click="handleExport">导出账单</el-button>            
            </div>
          </div>
        </template>

        <el-table
          v-loading="loading"
          :data="billList"
          border
          style="width: 100%"
          @selection-change="handleSelectionChange"
        >        
          <el-table-column type="index" lable="序号" width="50" />
          <el-table-column prop="OrderDate" label="订单日期" width="160">
            <template #default="{ row }">
              <!-- 只显示日期部分 -->
              {{ row.OrderDate ? row.OrderDate.slice(0,10) : '' }}
            </template>
          </el-table-column>     
          <el-table-column prop="OrderNo" label="订单编号" min-width="180" />
          <!-- 新增：订单明细列，展示商品名称及数量 -->
          <el-table-column label="订单明细" min-width="220">
            <template #default="{ row }">
              <span v-if="row.OrderItems && row.OrderItems.length">
                {{ row.OrderItems.map(item => item.ProductName + '×' + item.Quantity).join('，') }}
              </span>
              <span v-else>--</span>
            </template>
          </el-table-column>
          <el-table-column prop="PriceDiff" label="差价金额" width="120">
            <template #default="{ row }">¥{{ row.PriceDiff }}</template>
          </el-table-column>        
            
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link @click="handleView(row)">查看</el-button>
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>

      <!-- 账单详情对话框 -->
      <el-dialog v-model="detailDialogVisible" title="差价账单详情" width="800px">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="订单编号">{{ currentBill.OrderNo }}</el-descriptions-item>
          <el-descriptions-item label="经销商">{{ currentBill.DealerName }}</el-descriptions-item>
          <el-descriptions-item label="收货人">{{ currentBill.ReceiverName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentBill.ReceiverPhone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ currentBill.ReceiverAddress }}</el-descriptions-item>
          <el-descriptions-item label="差价金额">¥{{ currentBill.PriceDiff }}</el-descriptions-item>
          <el-descriptions-item label="运费金额">¥{{ currentBill.Freight }}</el-descriptions-item>
          <el-descriptions-item label="发货方式">{{ getDeliveryTypeText(currentBill.DeliveryType) }}</el-descriptions-item>
          <el-descriptions-item label="订单日期">{{ currentBill.OrderDate }}</el-descriptions-item>
          <el-descriptions-item label="状态">{{ getStatusText(currentBill.Status) }}</el-descriptions-item>
          <el-descriptions-item label="备注">{{ currentBill.Remark || '无' }}</el-descriptions-item>
        </el-descriptions>
        <!-- 新增：订单明细表格，展示产品名称及数量 -->
        <div style="margin-top: 20px">
          <h3>订单明细</h3>
          <el-table :data="currentBill.OrderItems || []" border size="small" style="width: 100%; margin-top: 10px">
            <el-table-column prop="ProductName" label="产品名称" min-width="200" />
            <el-table-column prop="Quantity" label="数量" width="100" />
          </el-table>
        </div>
      </el-dialog>

      <!-- 结算对话框 -->
      <el-dialog v-model="settleDialogVisible" title="差价结算" width="500px">
        <el-form :model="settleForm" label-width="100px">
          <el-form-item label="类型">
            <!-- 新增类型选择，1为结算，0为新增 -->
            <el-radio-group v-model="settleForm.type">
              <el-radio :label="1">结算</el-radio>
              <el-radio :label="0">新增</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="经销商">
            <el-input v-model="settleForm.dealerName" disabled />
          </el-form-item>
          <el-form-item label="待结算差价">
            <el-input v-model="settleForm.pendingAmount" disabled>
              <template #append>元</template>
            </el-input>
          </el-form-item>
          <el-form-item label="结算金额">
            <el-input-number v-model="settleForm.amount" :min="0" :max="settleForm.pendingAmount" :step="1" style="width: 100%" />
          </el-form-item>        
          <el-form-item label="结算备注">
            <el-input v-model="settleForm.remark" type="textarea" :rows="3" placeholder="请输入结算备注" />
          </el-form-item>
        </el-form>
        <template #footer>
          <div class="dialog-footer">
            <el-button @click="settleDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleSettleSubmit">确认结算</el-button>
          </div>
        </template>
      </el-dialog>
    </div>
    <div v-else>
      <!-- 差价日志视图内容 -->
      <el-card style="margin-top: 20px;">
        <!-- 只保留日志时间轴和分页，不显示搜索栏 -->
        <el-timeline>
          <el-timeline-item
            v-for="log in diffLogList"
            :key="log.CreatedAt + log.Operator"
            :timestamp="formatDate(log.CreatedAt)"
            placement="top"
          >
            <div>
              <strong>{{ operationTypeMap[log.OperationType] || log.OperationType }}</strong>
              <span style="margin-left:10px;">操作人：{{ log.Operator }}</span>
              <div>变动金额：<span :style="{color: getAmountColor(log)}">{{ getAmountSign(log) }}{{ log.Quantity }}</span></div>
              <div>变动前金额：{{ log.BeforeAmount }}，变动后金额：{{ log.AfterAmount }}</div>
              <div v-if="log.Source">来源单号：{{ log.Source }}</div>
            </div>
          </el-timeline-item>
        </el-timeline>
        <div style="text-align:right;margin-top:10px;">
          <el-pagination
            v-model:current-page="diffLogPage"
            v-model:page-size="diffLogPageSize"
            :total="diffLogTotal"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            @current-change="handleDiffLogPageChange"
            @size-change="handleDiffLogSizeChange"
          />
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick, watch } from 'vue'
import { reqGetDealerList } from '@/api/organization/dealer/index'
import { reqDiffPriceStatistics, reqDiffPriceOrderList } from '@/api/order'
import { reqDealerPriceDiff } from '@/api/organization/dealer/index'
import { reqDealerLogList } from '@/api/organization/dealer/index'

// 统计数据
const statistics = reactive({
  monthTotal: 0,
  monthTrend: 0,
  pendingTotal: 0,
  pendingCount: 0,
  settledTotal: 0,
  settledCount: 0,
  totalOrders: 0,
  todayOrders: 0
})

// 查询表单
const queryForm = reactive({
  DealerId: '', // 直接存储经销商id
  orderNo: '',
  status: '',
  settleTime: []
})

// 经销商列表，页面加载时通过API动态获取
const dealerList = ref<{ id: string; name: string }[]>([])
onMounted(async () => {
  try {
    const res = await reqGetDealerList()
    if (res && res.data) {
      dealerList.value = res.data.map((dealer: any) => ({
        id: dealer.Id,
        name: dealer.Name
      }))
    }
  } catch (e) {
    dealerList.value = []
  }
})

// 差价账单列表
const loading = ref(false)
const billList = ref([]) // 差价账单列表由后台API获取，初始为空数组

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 账单详情对话框
const detailDialogVisible = ref(false)
const currentBill = ref<any>({})

// 结算对话框
const settleDialogVisible = ref(false)
const settleForm = reactive({
  dealerName: '',      // 经销商名称
  pendingAmount: 0,    // 待结算差价
  amount: 0,           // 结算金额
  method: '',
  account: '',
  remark: '',
  type: 1              // 结算类型，1为结算，0为新增，默认为1
})

// 选中的账单
const selectedBills = ref<any[]>([])

// 日志视图切换
import { ElMessage } from 'element-plus'
const showDiffLogView = ref(false)
const logQueryForm = reactive({
  DealerId: '',
  OperationType: undefined,
  dateRange: [] as string[]
})
const diffLogList = ref<any[]>([])
const diffLogPage = ref(1)
const diffLogPageSize = ref(10)
const diffLogTotal = ref(0)
// 操作类型映射表
const operationTypeMap: Record<number, string> = {
  3: '取消订单',
  4: '发货新增',
  5: '退货扣减',
  7: '财务结算',
  8: '财务新增',  

  // 可根据实际后端类型继续补充
}
// 金额符号
const getAmountSign = (log: any) => {
  if ([1, 3].includes(log.OperationType)) return '-'
  if ([2].includes(log.OperationType)) return '+'
  return ''
}
// 金额颜色
const getAmountColor = (log: any) => {
  return getAmountSign(log) === '+' ? '#67c23a' : '#f56c6c'
}
// 时间格式化
const formatDate = (dateStr: string) => {
  if (!dateStr) return ''
  return dateStr.replace('T', ' ').slice(0, 19)
}
// 日志分页请求
const fetchDiffLog = async () => {
  const params = {
    DealerId: logQueryForm.DealerId,
    OperationType: logQueryForm.OperationType,
    StartDate: logQueryForm.dateRange[0] || '',
    EndDate: logQueryForm.dateRange[1] || '',
    LogType: 3, // 3为差价日志
    PageNumber: diffLogPage.value,
    pageSize: diffLogPageSize.value
  }
  try {
    const res = await reqDealerLogList(params)
    if (res && res.data) {
      if (res.headers && res.headers['x-pagination']) {
        const pagination = JSON.parse(res.headers['x-pagination'])
        diffLogPage.value = pagination.PageIndex || 1
        diffLogPageSize.value = pagination.PageSize || 10
        diffLogTotal.value = pagination.TotalCount || 0
      } else if (res.data.total) {
        diffLogTotal.value = res.data.total
      } else if (Array.isArray(res.data)) {
        diffLogTotal.value = res.data.length
      } else {
        diffLogTotal.value = 0
      }
      if (Array.isArray(res.data.records)) {
        diffLogList.value = res.data.records
      } else if (Array.isArray(res.data)) {
        diffLogList.value = res.data
      } else {
        diffLogList.value = []
      }
    } else {
      diffLogList.value = []
      diffLogTotal.value = 0
    }
  } catch (e) {
    diffLogList.value = []
    diffLogTotal.value = 0
  }
}
// 日志查询
const handleLogQuery = () => {
  diffLogPage.value = 1
  fetchDiffLog()
}
// 日志重置
const handleLogReset = () => {
  logQueryForm.DealerId = ''
  logQueryForm.OperationType = undefined
  logQueryForm.dateRange = []
}
// 日志分页
const handleDiffLogPageChange = (val: number) => {
  diffLogPage.value = val
  fetchDiffLog()
}
const handleDiffLogSizeChange = (val: number) => {
  diffLogPageSize.value = val
  diffLogPage.value = 1
  fetchDiffLog()
}
// 切换日志视图
const handleToggleDiffLog = () => {
  if (!showDiffLogView.value && !queryForm.DealerId) {
    ElMessage.warning('请先选择经销商')
    return
  }
  showDiffLogView.value = !showDiffLogView.value
  if (showDiffLogView.value) {
    logQueryForm.DealerId = queryForm.DealerId
    handleLogQuery()
  }
}

// 获取状态文本
const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    3: '已发货',
    5: '已签收',
    6: '已取消'
  }
  return textMap[status] || '未知'
}

// 发货方式转中文
const getDeliveryTypeText = (type: number) => {
  switch (type) {
    case 1: return '自提'
    case 2: return '快递'
    case 3: return '现付'
    default: return '未知'
  }
}

// 获取差价统计数据
const fetchDiffPriceStatistics = async (dealerId) => {
  if (!dealerId) {
    statistics.monthTotal = 0
    statistics.pendingTotal = 0
    statistics.settledTotal = 0
    statistics.totalOrders = 0
    return
  }
  try {
    const res = await reqDiffPriceStatistics(dealerId)
    if (res && res.data) {
      statistics.monthTotal = res.data.MonthsPriceDiff || 0
      statistics.pendingTotal = res.data.UnsettledPriceDiff || 0
      statistics.settledTotal = res.data.SettledPriceDiff || 0
      statistics.totalOrders = res.data.PriceDiffOrderNum || 0
    }
  } catch {
    statistics.monthTotal = 0
    statistics.pendingTotal = 0
    statistics.settledTotal = 0
    statistics.totalOrders = 0
  }
}

// 页面加载时和经销商选择后获取统计
watch(() => queryForm.DealerId, (val) => {
  fetchDiffPriceStatistics(val)
  // 新增：选择经销商后自动请求订单列表，未选时清空
  if (val) {
    handleQuery()
  } else {
    billList.value = []
    total.value = 0
  }
})

// 查询账单时分页参数统一
const handleQuery = async () => {
  if (!queryForm.DealerId) {
    billList.value = []
    total.value = 0
    await nextTick()
    return
  }
  loading.value = true
  try {
    const params = {
      DealerId: queryForm.DealerId,
      orderNo: queryForm.orderNo,
      DeliveryType: 3,
      OrderStatus: 4,
      DiffPriceMin: 0,
      PageNumber: currentPage.value,
      pageSize: pageSize.value
    }
    const res = await reqDiffPriceOrderList(params)
    if (res && res.data) {
      if (res.headers && res.headers['x-pagination']) {
        const pagination = JSON.parse(res.headers['x-pagination'])
        currentPage.value = pagination.PageIndex || 1
        pageSize.value = pagination.PageSize || 10
        total.value = pagination.TotalCount || 0
      } else if (res.data.total) {
        total.value = res.data.total
      } else if (Array.isArray(res.data)) {
        total.value = res.data.length
      } else {
        total.value = 0
      }
      if (Array.isArray(res.data.records)) {
        billList.value = res.data.records
      } else if (Array.isArray(res.data)) {
        billList.value = res.data
      } else {
        billList.value = []
      }
    }
  } finally {
    loading.value = false
  }
}

// 重置
const handleReset = () => {
  queryForm.DealerId = ''
  queryForm.orderNo = ''
  queryForm.status = ''
  queryForm.settleTime = []
}

// 导出
const handleExport = () => {
  // TODO: 调用导出接口
  ElMessage.success('导出成功')
}

// 查看账单
const handleView = (row: any) => {
  currentBill.value = row
  detailDialogVisible.value = true
}


// 提交结算
const handleSettleSubmit = async () => {
  if (!settleForm.method) {
    ElMessage.warning('请选择结算方式')
    return
  }
  if (!settleForm.account) {
    ElMessage.warning('请输入结算账号')
    return
  }
  // 直接使用表单中的经销商id
  const dealerId = Number(queryForm.DealerId)
  try {
    // 构造参数并调用API
    const params = {
      Id: dealerId, // 传递正确的经销商ID
      Type: settleForm.type, // 结算类型
      Price: settleForm.amount // 结算金额
    }
    await reqDealerPriceDiff(params)
    ElMessage.success('结算成功')
    settleDialogVisible.value = false
    handleQuery()
  } catch (e) {
    ElMessage.error('结算失败')
  }
}

// 批量结算
const handleBatchSettle = () => {
  if (!queryForm.DealerId) {
    ElMessage.warning('请先选择经销商')
    return
  }
  // 通过id查找经销商名称
  const dealer = dealerList.value.find(d => d.id === queryForm.DealerId)
  settleForm.dealerName = dealer ? dealer.name : ''
  settleForm.pendingAmount = statistics.pendingTotal
  settleForm.amount = statistics.pendingTotal
  settleForm.method = ''
  settleForm.account = ''
  settleForm.remark = ''
  settleForm.type = 1
  settleDialogVisible.value = true
}

// 选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedBills.value = selection
}

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  handleQuery()
}
</script>

<style lang="scss" scoped>
.statistics-cards {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-content {
  text-align: center;

  .amount {
    font-size: 24px;
    font-weight: bold;
    color: #303133;
  }

  .trend {
    margin-top: 10px;
    font-size: 14px;
    color: #909399;

    .up {
      color: #67c23a;
    }

    .down {
      color: #f56c6c;
    }
  }
}

.search-card {
  margin-bottom: 20px;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.table-card {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.settle-amount {
  font-size: 20px;
  font-weight: bold;
  color: #f56c6c;
}
</style> 