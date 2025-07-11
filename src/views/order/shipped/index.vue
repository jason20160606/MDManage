<template>
  <div class="app-container">
    <!-- 已发货订单列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>已发货订单管理</span>
          <div class="header-actions">
            <el-button type="success" @click="handleBatchComplete">批量确认收货</el-button>
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <div style="display: flex; flex-wrap: wrap;">
          <!-- 第一行 -->
          <div style="display: flex; flex: 1 1 100%; flex-wrap: wrap;">
            <el-form-item label="订单编号">
              <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable style="width: 180px;" />
            </el-form-item>
            <el-form-item label="经销商名称">
              <el-input v-model="queryForm.dealerName" placeholder="请输入经销商名称" clearable style="width: 180px;" />
            </el-form-item>
            <el-form-item label="收货人">
              <el-input v-model="queryForm.receiverName" placeholder="请输入收货人姓名" clearable style="width: 150px;" />
            </el-form-item>
            <el-form-item label="收货人电话">
              <el-input v-model="queryForm.receiverPhone" placeholder="请输入收货人电话" clearable style="width: 150px;" />
            </el-form-item>
          </div>
          <!-- 第二行 -->
          <div style="display: flex; flex: 1 1 100%; flex-wrap: wrap; align-items: center;">
            <el-form-item label="订单日期">
              <el-date-picker
                v-model="queryForm.shipTime"
                type="daterange"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                style="width: 240px;"
              />
            </el-form-item>
            <el-form-item label="订单总额区间">
              <el-input v-model="queryForm.TotalAmountMin" placeholder="最小金额" style="width: 100px;" clearable />
              <span style="margin: 0 8px;">-</span>
              <el-input v-model="queryForm.TotalAmountMax" placeholder="最大金额" style="width: 100px;" clearable />
            </el-form-item>
            <el-form-item label="运费金额区间">
              <el-input v-model="queryForm.freightMin" placeholder="最小运费" style="width: 100px;" clearable />
              <span style="margin: 0 8px;">-</span>
              <el-input v-model="queryForm.freightMax" placeholder="最大运费" style="width: 100px;" clearable />
            </el-form-item>
          </div>
          <!-- 第三行 -->
          <div style="display: flex; flex: 1 1 100%; flex-wrap: wrap; align-items: center;">
            <el-form-item label="运费方式">
              <el-select v-model="queryForm.deliveryType" placeholder="请选择运费方式" clearable style="width: 150px;">
                <el-option label="自提" :value="1" />
                <el-option label="到付" :value="2" />
                <el-option label="现付" :value="3" />
              </el-select>
            </el-form-item>
            <el-form-item label="物流公司">
              <el-select v-model="queryForm.logisticsCompany" placeholder="请选择物流公司" clearable style="width: 150px;">
                <el-option v-for="item in logisticsCompanyList" :key="item.Code" :label="item.Name" :value="item.Name" />
              </el-select>
            </el-form-item>
            <el-form-item label="物流单号">
              <el-input v-model="queryForm.trackingNo" placeholder="请输入物流单号" clearable style="width: 180px;" />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleQuery">查询</el-button>
              <el-button @click="resetQuery">重置</el-button>
            </el-form-item>
          </div>
        </div>
      </el-form>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" v-loading="loading" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column label="订单信息" min-width="200">
          <template #default="{ row }">
            <div class="order-info">
              <div class="order-no">{{ row.OrderNo }}</div>
              <div class="order-date">订单日期: {{ formatDateTime(row.OrderDate) }}</div>
              <div class="order-status">
                <el-tag type="success">已发货</el-tag>
                <el-tag style="margin-left: 8px;" size="small" :type="getDeliveryTypeTagType(row.DeliveryType)">
                  {{ getDeliveryTypeText(row.DeliveryType) }}
                </el-tag>
              </div>              
            </div>
          </template>
        </el-table-column>
        <el-table-column label="经销商信息" min-width="180">
          <template #default="{ row }">
            <div class="dealer-info">
              <div class="dealer-name">{{ row.DealerName }}</div>
              <div class="dealer-sendname">发件人: {{ row.SenderName }}</div>
              
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="180">
          <template #default="{ row }">
            <div class="receiver-info">
              <div class="receiver-name">{{ row.ReceiverName }}</div>
              <div class="receiver-phone">电话: {{ row.ReceiverPhone }}</div>
              <div class="receiver-address">地址: {{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="物流信息" min-width="200">
          <template #default="{ row }">
            <div class="logistics-info">
              <div>物流公司: {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].LogisticsCompany : '-' }}</div>
              <div>物流单号: {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].TrackingNo : '-' }}</div>              
            </div>
          </template>
        </el-table-column>        
        <el-table-column label="产品信息" min-width="200">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-list">
                <div v-for="(item, index) in row.OrderItems || []" :key="index" class="product-item">
                  <span class="product-name">{{ item.ProductName || '未知产品' }}</span>
                  <span class="product-quantity">×{{ item.Quantity || 0 }}</span>
                </div>
                <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                <span class="total-count">共 {{ row.OrderItems?.length || 0 }} 种产品</span>
                <span class="total-amount">差价: {{ formatPrice(row.PriceDiff) }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="订单总额" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ row.TotalAmount }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <div class="action-col">
              <div class="action-row">                
                <el-button type="success" link @click="handleTrack()" class="action-btn">物流跟踪</el-button>
                <el-button type="primary" link @click="viewOrder(row)" class="action-btn">查看</el-button>
              </div>
              <div class="action-row">
                <el-button type="warning" link @click="handleComplete(row)" class="action-btn">确认收货</el-button>
                <el-button type="danger" link @click="handleCancel(row)" class="action-btn">取消</el-button>
              </div>
            </div>
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

    <!-- 订单查看对话框 -->
    <orderView ref="orderViewRef" v-show="scene === 1" @change-scene="changeScene"></orderView>

    <!-- 物流跟踪对话框 -->
    <el-dialog v-model="trackDialogVisible" title="物流跟踪" width="600px">
      <el-timeline>
        <el-timeline-item
          v-for="(activity, index) in logisticsTrack"
          :key="index"
          :type="activity.type"
          :timestamp="activity.timestamp"
        >
          {{ activity.content }}
        </el-timeline-item>
      </el-timeline>
    </el-dialog>

    <el-dialog v-model="resultDialogVisible" title="操作结果" width="400px">
      <div style="font-size: 16px; color: #333; white-space: pre-line;">{{ resultDialogMessage }}</div>
      <template #footer>
        <el-button type="primary" @click="resultDialogVisible = false">确定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import orderView from '../waiting/orderView.vue'
import { reqShippedOrderList, reqConfirmReceipt, reqBatchConfirmReceipt, reqCancelOrder } from '@/api/order'
import { getLogisticsCompanyNames } from '@/api/shipping'

// 场景值：0-数据展示，1-订单查看
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  orderNo: '',
  dealerName: '',
  receiverName: '',
  deliveryType: '',
  trackingNo: '',
  shipTime: [],
  receiverPhone: '', // 新增收货人电话
  logisticsCompany: '', // 新增物流公司
  freightMin: '', // 新增最小运费
  freightMax: '', // 新增最大运费
  TotalAmountMin:'',
  TotalAmountMax:'',
})

// 订单列表
const orderList = ref<any[]>([])
const loading = ref(false)

// 选中的订单
const selectedOrders = ref<any[]>([])

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 物流跟踪对话框
const trackDialogVisible = ref(false)
const logisticsTrack = ref([
  {
    content: '快件已签收，签收人：张三',
    timestamp: '2024-03-16 15:30:00',
    type: 'success'
  },
  {
    content: '快件已到达【北京朝阳区xxx营业点】',
    timestamp: '2024-03-16 10:20:00',
    type: 'primary'
  },
  {
    content: '快件已到达【北京转运中心】',
    timestamp: '2024-03-15 20:15:00',
    type: 'primary'
  },
  {
    content: '快件已从【上海转运中心】发出',
    timestamp: '2024-03-15 15:30:00',
    type: 'primary'
  },
  {
    content: '快件已揽收',
    timestamp: '2024-03-15 10:00:00',
    type: 'primary'
  }
])

// 物流公司下拉选项
const logisticsCompanyList = ref<any[]>([])

// 获取子组件实例
const orderViewRef = ref()

// 操作结果对话框
const resultDialogVisible = ref(false)
const resultDialogMessage = ref('')

// 查询订单列表（已发货订单专用）
const handleQuery = async () => {
  loading.value = true
  try {
    // 查询参数处理：物流公司传Code
    const selectedCompany = logisticsCompanyList.value.find(item => item.Name === queryForm.logisticsCompany)
    const params: any = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNo: queryForm.orderNo || undefined,
      DealerName: queryForm.dealerName || undefined,
      ReceiverName: queryForm.receiverName || undefined,
      DeliveryType: queryForm.deliveryType || undefined,
      TrackingNo: queryForm.trackingNo || undefined,
      StartDate: queryForm.shipTime && queryForm.shipTime.length > 0 ? queryForm.shipTime[0] : undefined,
      EndDate: queryForm.shipTime && queryForm.shipTime.length > 1 ? queryForm.shipTime[1] : undefined,
      ReceiverPhone: queryForm.receiverPhone || undefined, // 添加收货人电话参数
      LogisticsCompany: selectedCompany ? selectedCompany.Code : undefined, // 添加物流公司参数
      FreightMin: queryForm.freightMin || undefined, // 添加最小运费参数
      FreightMax: queryForm.freightMax || undefined, // 添加最大运费参数
      TotalAmountMin: queryForm.TotalAmountMin || undefined, // 添加最小订单总额参数
      TotalAmountMax: queryForm.TotalAmountMax || undefined, // 添加最大订单总额参数
    }
    const result = await reqShippedOrderList(params)
    orderList.value = result.data || []
    if (result.headers && result.headers['x-pagination']) {
      const pagination = JSON.parse(result.headers['x-pagination'])
      currentPage.value = pagination.PageIndex || 1
      pageSize.value = pagination.PageSize || 10
      total.value = pagination.TotalCount || 0
    } else {
      total.value = orderList.value.length
    }
    loading.value = false
  } catch (error) {
    ElMessage.error('获取已发货订单列表失败')
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.dealerName = ''
  queryForm.receiverName = ''
  queryForm.deliveryType = ''
  queryForm.trackingNo = ''
  queryForm.shipTime = []
  queryForm.receiverPhone = ''
  queryForm.logisticsCompany = ''
  queryForm.freightMin = ''
  queryForm.freightMax = ''
  queryForm.TotalAmountMin = ''
  queryForm.TotalAmountMax = ''
  currentPage.value = 1
  handleQuery()
}

// 处理选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}

// 批量确认收货
const handleBatchComplete = async () => {
  if (selectedOrders.value.length === 0) {
    ElMessage.warning('请选择要确认收货的订单')
    return
  }
  ElMessageBox.confirm('确认选中订单已收货吗？', '批量确认收货', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(async () => {
    // 1. 确保ID为数字数组
    const ids = selectedOrders.value.map(o => Number(o.Id))
    // 2. 直接传递数组给API    
    await reqBatchConfirmReceipt(ids)
    ElMessage.success('批量确认收货成功')
    handleQuery()
  })
}

// 查看订单
const viewOrder = (row: any) => {
  scene.value = 1
  nextTick(() => {
    orderViewRef.value?.initView(row)
  })
}

// 物流跟踪
const handleTrack = () => {
  trackDialogVisible.value = true
}

// 单个确认收货
const handleComplete = async (row: any) => {
  ElMessageBox.confirm('确认该订单已收货吗？', '确认收货', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(async () => {
    // 调用后端单个确认收货API
    await reqConfirmReceipt(row.Id)
    ElMessage.success('确认收货成功')
    handleQuery()
  })
}

// 取消订单
const handleCancel = (row: any) => {
  // 二次确认弹窗
  ElMessageBox.confirm('确定要取消该订单吗？', '取消订单', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(async () => {
    try {
      // 调用后端取消订单接口
      const res = await reqCancelOrder(row.Id)
      resultDialogMessage.value = (res.Message || '订单已取消').split('@').join('\n')
      resultDialogVisible.value = true
      handleQuery() // 刷新列表
    } catch (error) {
      resultDialogMessage.value = '取消订单失败'
      resultDialogVisible.value = true
    }
  })
}

// 导出订单
const handleExport = () => {
  if (selectedOrders.value.length === 0) {
    ElMessage.warning('请选择要导出的订单')
    return
  }
  // TODO: 调用导出API
  ElMessage.success('导出成功')
}

// 子组件自定义事件 - 切换场景
const changeScene = (num: number) => {
  scene.value = num
  if (num === 0) {
    handleQuery()
  }
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
  currentPage.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1
  handleQuery()
}

// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 格式化价格
const formatPrice = (price: number) => {
  if (!price) return '0.00'
  return price.toFixed(2)
}

// 获取运费方式文本
const getDeliveryTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    1: '自提',
    2: '到付',
    3: '现付'
  }
  return typeMap[type] || '未知'
}

// 运费方式el-tag类型
const getDeliveryTypeTagType = (type: number) => {
  switch (type) {
    case 1: return 'info'; // 自提
    case 2: return 'warning'; // 到付
    case 3: return 'success'; // 现付
    default: return 'default';
  }
}

// 初始化
onMounted(async () => {
  handleQuery()
  // 动态获取物流公司名称列表
  const res = await getLogisticsCompanyNames()
  if (res && Array.isArray(res.data)) {
    logisticsCompanyList.value = res.data
  }
})
</script>

<style lang="scss" scoped>
.app-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-actions {
  display: flex;
  gap: 10px;
}

.search-form {
  margin-bottom: 20px;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.order-info {
  .order-no {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  .order-date {
    font-size: 12px;
    color: #909399;
    margin-bottom: 4px;
  }
  .order-status {
    margin-top: 4px;
  }
  .order-delivery-type {
    font-size: 12px;
    color: #909399;
    margin-top: 4px;
  }
}

.dealer-info {
  .dealer-name {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  .dealer-sendname {
    font-size: 12px;
    color: #606266;
    margin-bottom: 2px;
  }
}

.receiver-info {
  .receiver-name {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  .receiver-phone,
  .receiver-address {
    font-size: 12px;
    color: #606266;
    margin-bottom: 2px;
  }
}

.logistics-info {
  font-size: 12px;
  color: #606266;
  line-height: 1.6;
}

.product-info {
  .product-list {
    margin-bottom: 6px;
  }
  .product-item {
    display: block;
    margin-bottom: 2px;
    line-height: 1.4;
  }
  .product-name {
    font-size: 12px;
    color: #303133;
    font-weight: 500;
  }
  .product-quantity {
    font-size: 12px;
    color: #409eff;
    font-weight: bold;
    margin-left: 4px;
  }
  .no-products {
    font-size: 12px;
    color: #909399;
    font-style: italic;
  }
  .product-summary {
    margin-top: 6px;
    padding-top: 4px;
    border-top: 1px solid #f0f0f0;
  }
  .total-count {
    font-size: 11px;
    color: #606266;
    margin-right: 8px;
  }
  .total-amount {
    font-size: 11px;
    color: #f56c6c;
    font-weight: bold;
  }
}

.amount-info {
  .amount {
    font-size: 16px;
    font-weight: bold;
    color: #f56c6c;
  }
}

.action-col {
  display: flex;
  flex-direction: column;
  align-items: flex-start; // 左对齐，如需居中可改为center
  justify-content: center;
  gap: 4px;
}
.action-row {
  display: flex;
  flex-direction: row;
  gap: 12px;
}
.action-btn {
  min-width: 80px;
  text-align: center;
  padding: 0 8px;
}
</style> 