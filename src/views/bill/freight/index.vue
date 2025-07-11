<template>
  <div class="app-container">
    <!-- 搜索表单 -->
    <el-card class="search-card">
      <el-form :model="queryForm" :inline="true" class="search-form">
        <el-form-item label="经销商">
          <el-select
            v-model="queryForm.DealerName"
            placeholder="请选择经销商"
            clearable
            filterable
            style="width: 200px"
          >
            <el-option
              v-for="dealer in dealerList"
              :key="dealer.id"
              :label="dealer.name"
              :value="dealer.name"
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
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 统计卡片，已移动到搜索表单下方 -->
    <el-row :gutter="20" class="statistics-cards">
      
      <el-col :span="6">
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
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>已结算运费</span>
              <el-tag type="success">已处理</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">¥{{ statistics.settledTotal }}</span>            
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
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
      <el-col :span="6">
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

    <!-- 账单列表 -->
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
        <el-table-column prop="OrderNo" label="订单编号" width="280"/>       
        <el-table-column prop="Freight" label="运费金额" width="100">
          <template #default="{ row }">
            ¥{{ row.Freight }}
          </template>
        </el-table-column>
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
        <el-table-column prop="OrderDate" label="订单日期" width="160">
          <template #default="{ row }">
            {{ row.OrderDate ? row.OrderDate.slice(0,10) : '' }}
          </template>
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
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { reqFreightStatistics, reqFreightOrderList } from '@/api/order' // 正确引入运费统计和运费订单接口
import { reqGetDealerList } from '@/api/organization/dealer/index' // 引入经销商列表接口


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
  DealerName: '', // 传递经销商名称
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
  remark: ''           // 备注
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
watch(() => queryForm.DealerName, (val) => {
  const dealer = dealerList.value.find(d => d.name === val)
  fetchFreightStatistics(dealer ? dealer.id : null)
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
  // 如果未选择经销商，直接清空列表并返回
  if (!queryForm.DealerName) {
    billList.value = []
    total.value = 0
    return
  }
  loading.value = true
  try {
    // 构造查询参数，筛选运费大于0、发货状态为现付
    const params = {
      DealerName: queryForm.DealerName, // 只传递经销商名称
      OrderNumber: queryForm.OrderNumber,
      FreightMin: 0.01,         // 运费大于0
      DeliveryType: 3,      // 发货状态为现付
      // OrderStatus: 4,    // 订单状态为4（去除）
      page: currentPage.value,
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
    }
  } finally {
    loading.value = false
  }
}

// 重置
const handleReset = () => {
  queryForm.DealerName = ''
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

// 运费结算弹窗提交方法
const handleFreightSettleSubmit = () => {
  if (!freightSettleForm.amount || freightSettleForm.amount <= 0) {
    ElMessage.warning('请输入有效的结算金额')
    return
  }
  // TODO: 调用结算API
  ElMessage.success('结算成功')
  freightSettleDialogVisible.value = false
  handleQuery()
}

// 修改批量结算按钮事件，弹出结算弹窗
const handleBatchSettle = () => {
  if (!queryForm.DealerName) {
    ElMessage.warning('请先选择经销商')
    return
  }
  // 设置弹窗内容
  freightSettleForm.dealerName = queryForm.DealerName
  freightSettleForm.pendingAmount = statistics.pendingTotal
  freightSettleForm.amount = statistics.pendingTotal
  freightSettleForm.remark = ''
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