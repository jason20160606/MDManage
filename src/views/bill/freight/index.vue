<template>
  <div class="app-container">
    <!-- 统计卡片始终显示，放到页面最顶部 -->
    <el-row :gutter="22" class="statistics-cards">
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>待结算运费</span>
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
              <span>本月运费总额</span>
              <el-tag type="success">实时</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">¥{{ statistics.monthTotal }}</span>            
          </div>
        </el-card>
      </el-col>
      <el-col :span="8">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>本月运费订单数</span>
              <el-tag type="info">总计</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">{{ statistics.totalOrders }}</span>            
          </div>
        </el-card>
      </el-col>
    </el-row>
    <!-- 搜索表单始终显示 -->
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
          <el-input v-model="queryForm.OrderNumber" placeholder="请输入订单编号" clearable />
        </el-form-item>                
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
          <el-button type="success" @click="handleBatchSettle">运费结算</el-button>
          <el-button :type="showFreightLogView ? 'primary' : 'info'" @click="handleToggleFreightLog">
            {{ showFreightLogView ? '运费订单列表' : '运费日志' }}
          </el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 视图切换：订单表格/弹窗 <-> 运费日志 -->
    <div v-if="!showFreightLogView">
      <!-- 订单表格、分页、弹窗等 -->
      <el-card class="table-card">
        <template #header>
          <div class="card-header">
            <span>运费订单列表</span>
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
          empty-text="暂无数据"
          @selection-change="handleSelectionChange"
        >       
          <el-table-column type="index" width="50" />  
          <el-table-column prop="OrderDate" label="订单日期" width="160">
            <template #default="{ row }">
              {{ row.OrderDate ? row.OrderDate.slice(0,10) : '' }}
            </template>
          </el-table-column>    
          <el-table-column prop="OrderNo" label="订单编号" width="280"/>       
          <el-table-column label="物流公司" width="120">
            <template #default="{ row }">
              {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].LogisticsCompany : '-' }}
            </template>
          </el-table-column>
          <el-table-column label="运单号" width="220">
            <template #default="{ row }">
              {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].TrackingNo : '-' }}
            </template>
          </el-table-column>
          <el-table-column prop="Freight" label="运费金额" width="100">
            <template #default="{ row }">
              ¥{{ row.Freight }}
            </template>
          </el-table-column>
          <el-table-column label="操作" width="200" fixed="right">
            <template #default="{ row }">
              <el-button type="primary" link @click="handleView(row)">查看</el-button>
              <el-button type="primary" link @click="handlePrint(row)">打印</el-button>            
            </template>
          </el-table-column>
        </el-table>

        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination 
            v-model:current-page="currentPage" 
            v-model:page-size="pageSize" 
            :page-sizes="[10, 20, 50, 100]"
            :background="background" 
            layout="total, sizes, prev, pager, next, jumper" 
            :total="total"
            @current-change="handleCurrentChange" 
            @size-change="handleSizeChange" 
          />
        </div>
      </el-card>

      <!-- 账单详情对话框 -->
      <el-dialog v-model="detailDialogVisible" title="账单详情" width="800px">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="订单编号">{{ currentBill.OrderNo }}</el-descriptions-item>
          <el-descriptions-item label="经销商">{{ currentBill.DealerName }}</el-descriptions-item>
          <el-descriptions-item label="收货人">{{ currentBill.ReceiverName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentBill.ReceiverPhone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ currentBill.ReceiverAddress }}</el-descriptions-item>
          <el-descriptions-item label="运费金额">¥{{ currentBill.Freight }}</el-descriptions-item>
          <el-descriptions-item label="差价">¥{{ currentBill.PriceDiff }}</el-descriptions-item>
          <el-descriptions-item label="发货方式">{{ getDeliveryTypeText(currentBill.DeliveryType) }}</el-descriptions-item>        
          <el-descriptions-item label="物流公司">{{ currentBill.ShipmentInfos && currentBill.ShipmentInfos.length > 0 ? currentBill.ShipmentInfos[0].LogisticsCompany : '-' }}</el-descriptions-item>
          <el-descriptions-item label="运单号">{{ currentBill.ShipmentInfos && currentBill.ShipmentInfos.length > 0 ? currentBill.ShipmentInfos[0].TrackingNo : '-' }}</el-descriptions-item>
          <el-descriptions-item label="订单日期">{{ currentBill.OrderDate }}</el-descriptions-item>        
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

      <!-- 运费结算弹窗 -->
      <el-dialog v-model="freightSettleDialogVisible" title="运费结算" width="400px">
        <el-form :model="freightSettleForm" label-width="100px">
          <el-form-item label="类型">
            <!-- 新增类型选择，1为结算，0为新增 -->
            <el-radio-group v-model="freightSettleForm.type">
              <el-radio :label="1">结算</el-radio>
              <el-radio :label="0">新增</el-radio>
            </el-radio-group>
          </el-form-item>
          <el-form-item label="经销商">
            <el-input v-model="freightSettleForm.dealerName" disabled />
          </el-form-item>
          <el-form-item label="待结算运费">
            <el-input v-model="freightSettleForm.pendingAmount" disabled>
              <template #append>元</template>
            </el-input>
          </el-form-item>
          <el-form-item label="结算金额">
            <el-input-number v-model="freightSettleForm.amount" :min="0" :max="freightSettleForm.pendingAmount" :step="1" style="width: 100%" />
          </el-form-item>
          <el-form-item label="备注">
            <el-input v-model="freightSettleForm.remark" type="textarea" :rows="2" />
          </el-form-item>
        </el-form>
        <template #footer>
          <el-button @click="freightSettleDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleFreightSettleSubmit">确认</el-button>
        </template>
      </el-dialog>
    </div>
    <div v-else>
      <!-- 运费日志视图内容 -->
      <el-card style="margin-top: 20px;">        
        <!-- 日志时间轴 -->
        <el-timeline>
          <el-timeline-item
            v-for="log in freightLogList"
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
            v-model:current-page="freightLogPage"
            v-model:page-size="freightLogPageSize"
            :total="freightLogTotal"
            :page-sizes="[10, 20, 50]"
            layout="total, sizes, prev, pager, next, jumper"
            @current-change="handleFreightLogPageChange"
            @size-change="handleFreightLogSizeChange"
          />
        </div>
      </el-card>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { reqFreightStatistics, reqFreightOrderList } from '@/api/order' // 正确引入运费统计和运费订单接口
import { reqGetDealerList,reqDealerFreight, reqDealerLogList } from '@/api/organization/dealer/index' // 引入经销商列表接口

const showFreightLogView = ref(false) // 控制视图切换
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
  OrderNumber: '', 
})

// 经销商列表，页面加载时通过API动态获取
const dealerList = ref<{ id: string; name: string }[]>([])

// 页面加载时只获取经销商列表，不请求账单数据
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

// 账单列表，初始为空，只有查询后才有数据
const loading = ref(false)
const billList = ref([])

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 账单详情对话框
const detailDialogVisible = ref(false)
const currentBill = ref<any>({})

// 运费结算弹窗相关变量
const freightSettleDialogVisible = ref(false) // 控制弹窗显示
const freightSettleForm = reactive({
  dealerName: '',      // 经销商名称
  pendingAmount: 0,    // 待结算运费
  amount: 0,           // 结算金额
  remark: '',          // 备注
  type: 1              // 结算类型，1为结算，0为新增，默认为1
})

// 选中的账单
const selectedBills = ref<any[]>([])

// 发货方式转中文
const getDeliveryTypeText = (type: number) => {
  switch (type) {
    case 1: return '自提'
    case 2: return '快递'
    case 3: return '现付'
    default: return '未知'
  }
}

// 操作类型映射表
const operationTypeMap: Record<number, string> = {
  4: '现付运费',
  7: '手动结算',
  8: '运费退款',
  9: '运费补扣',
  10: '其他增加',
  11: '其他减少',
  // 可根据实际后端类型继续补充
}
// 判断变动金额符号
const getAmountSign = (log: any) => {
  // 账户减少的类型
  if ([4, 9, 11].includes(log.OperationType)) return '+'
  // 账户增加的类型
  if ([7, 8, 10].includes(log.OperationType)) return '-'
  return ''
}
// 判断变动金额颜色
const getAmountColor = (log: any) => {
  return getAmountSign(log) === '+' ? '#67c23a' : '#f56c6c'
}
// 时间格式化方法
const formatDate = (dateStr: string) => {
  if (!dateStr) return ''
  return dateStr.replace('T', ' ').slice(0, 19)
}

// 获取运费统计数据
const fetchFreightStatistics = async (dealerId) => {
  if (!dealerId) {
    statistics.monthTotal = 0
    statistics.pendingTotal = 0
    statistics.settledTotal = 0
    statistics.totalOrders = 0
    return
  }
  try {
    const res = await reqFreightStatistics(dealerId)
    if (res && res.data) {
      statistics.monthTotal = res.data.MonthsFreight || 0
      statistics.pendingTotal = res.data.UnsettledFreight || 0
      statistics.settledTotal = res.data.SettledFreight || 0
      statistics.totalOrders = res.data.FreightOrderNum || 0
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
  fetchFreightStatistics(val)
  // 新增：选择经销商后自动请求订单列表，未选时清空
  if (val) {
    handleQuery()
  } else {
    billList.value = []
    total.value = 0
  }
})

// 查询
const handleQuery = async () => {
  if (!queryForm.DealerId) {
    ElMessage.warning('请先选择经销商')
    return
  }
  loading.value = true
  try {
    const params = {
      DealerId: queryForm.DealerId, // 直接传递经销商id
      OrderNumber: queryForm.OrderNumber,
      FreightMin: 0.01,
      DeliveryType: 3,
      PageNumber: currentPage.value, // 使用PageNumber
      pageSize: pageSize.value
    }
    const res = await reqFreightOrderList(params)
    if (res && res.data) {
      billList.value = res.data.records || res.data
      // 处理分页信息，兼容后端X-Pagination头
      if (res.headers && res.headers['x-pagination']) {
        const pagination = JSON.parse(res.headers['x-pagination'])
        currentPage.value = pagination.PageIndex || 1
        pageSize.value = pagination.PageSize || 10
        total.value = pagination.TotalCount || 0
      } else {
        total.value = billList.value.length
      }
    } else {
      billList.value = []
      total.value = 0
    }
  } finally {
    loading.value = false
  }
}

// 重置
const handleReset = () => {
  queryForm.DealerId = ''
  queryForm.OrderNumber = ''  
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

// 打印账单
const handlePrint = (row: any) => {
  ElMessage.success('打印成功')
  // 整理详细信息
  const detail = [
    `订单编号：${row.OrderNo}`,
    `订单日期：${row.OrderDate ? row.OrderDate.slice(0,10) : ''}`,
    `经销商：${row.DealerName || '-'}`,
    `收货人：${row.ReceiverName || '-'}`,
    `联系电话：${row.ReceiverPhone || '-'}`,
    `收货地址：${row.ReceiverAddress || '-'}`,
    `运费金额：¥${row.Freight}`,
    `物流公司：${row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].LogisticsCompany : '-'}`,
    `运单号：${row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].TrackingNo : '-'}`,
    `发货方式：${getDeliveryTypeText(row.DeliveryType)}`,
    `备注：${row.Remark || '-'}`
  ]
  if (row.OrderItems && row.OrderItems.length > 0) {
    detail.push('订单明细:')
    row.OrderItems.forEach((item: any, idx: number) => {
      detail.push(`  ${idx+1}. ${item.ProductName} × ${item.Quantity}`)
    })
  }
  console.log(detail.join('\n'))
}

// 运费结算弹窗提交方法
const handleFreightSettleSubmit = async () => {
  if (!freightSettleForm.amount || freightSettleForm.amount <= 0) {
    ElMessage.warning('请输入有效的结算金额')
    return
  }
  // 直接使用表单中的经销商id
  const dealerId = Number(queryForm.DealerId)

  try {
    const params = {
      Id: dealerId, // 传递正确的经销商ID
      Type: freightSettleForm.type,
      Price: freightSettleForm.amount
    }
    await reqDealerFreight(params)
    ElMessage.success('结算成功')
    freightSettleDialogVisible.value = false
    handleQuery()
  } catch (e) {
    ElMessage.error('结算失败')
  }
}

// 修改批量结算按钮事件，弹出结算弹窗
const handleBatchSettle = (row: any) => {
  if (!row.DealerId) {
    ElMessage.warning('请先选择经销商')
    return
  }
  // 设置弹窗内容
  // 通过id查找经销商名称
  const dealer = dealerList.value.find(d => d.id === row.DealerId)
  freightSettleForm.dealerName = dealer ? dealer.name : ''
  freightSettleForm.pendingAmount = statistics.pendingTotal
  freightSettleForm.amount = statistics.pendingTotal
  freightSettleForm.remark = ''
  freightSettleForm.type = 1
  freightSettleDialogVisible.value = true
}

// 选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedBills.value = selection
}

// 分页
const handleCurrentChange = (val: number) => {
  currentPage.value = val
  handleQuery()
}

const handleSizeChange = (val: number) => {
  pageSize.value = val
  currentPage.value = 1 // 重置到第一页
  handleQuery()
}

// 运费日志相关变量
const freightLogList = ref<any[]>([])
const freightLogPage = ref(1)
const freightLogPageSize = ref(10)
const freightLogTotal = ref(0)
const logQueryForm = reactive({
  DealerId: '',
  OperationType: '',
  dateRange: [] as string[]
})

// 获取运费日志
const fetchFreightLog = async () => {
  const params = {
    DealerId: logQueryForm.DealerId,
    OperationType: logQueryForm.OperationType,
    StartDate: logQueryForm.dateRange[0] || '',
    EndDate: logQueryForm.dateRange[1] || '',
    LogType: 2, // 补充日志类型，2为运费日志
    PageNumber: freightLogPage.value, // 使用PageNumber
    pageSize: freightLogPageSize.value
  }
  try {
    const res = await reqDealerLogList(params)
    if (res && res.data) {
      // 优先解析 headers 分页信息
      if (res.headers && res.headers['x-pagination']) {
        const pagination = JSON.parse(res.headers['x-pagination'])
        freightLogPage.value = pagination.PageIndex || 1
        freightLogPageSize.value = pagination.PageSize || 10
        freightLogTotal.value = pagination.TotalCount || 0
      } else if (res.data.total) {
        freightLogTotal.value = res.data.total
      } else if (Array.isArray(res.data)) {
        freightLogTotal.value = res.data.length
      } else {
        freightLogTotal.value = 0
      }
      // 取日志数据
      if (Array.isArray(res.data.records)) {
        freightLogList.value = res.data.records
      } else if (Array.isArray(res.data)) {
        freightLogList.value = res.data
      } else {
        freightLogList.value = []
      }
    } else {
      freightLogList.value = []
      freightLogTotal.value = 0
    }
  } catch (e) {
    freightLogList.value = []
    freightLogTotal.value = 0
  }
}

// 运费日志查询
const handleLogQuery = () => {
  freightLogPage.value = 1
  fetchFreightLog()
}

// 运费日志分页
const handleFreightLogPageChange = (val: number) => {
  freightLogPage.value = val
  fetchFreightLog()
}

const handleFreightLogSizeChange = (val: number) => {
  freightLogPageSize.value = val
  freightLogPage.value = 1 // 重置到第一页
  fetchFreightLog()
}

// 切换运费日志视图
const handleToggleFreightLog = () => {
  if (!showFreightLogView.value && !queryForm.DealerId) {
    ElMessage.warning('请先选择经销商')
    return
  }
  showFreightLogView.value = !showFreightLogView.value
  if (showFreightLogView.value) {
    logQueryForm.DealerId = queryForm.DealerId // 同步经销商ID
    handleLogQuery() // 切换到日志视图时自动请求日志
  }
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

.shipping-info {
  margin-top: 20px;

  h3 {
    margin-bottom: 15px;
  }
}

.settle-amount {
  font-size: 20px;
  font-weight: bold;
  color: #f56c6c;
}

:deep(.el-descriptions) {
  margin-bottom: 20px;
}
</style> 