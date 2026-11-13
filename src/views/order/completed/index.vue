<template>
  <div class="app-container">
    <!-- 已完成订单列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>已完成订单管理</span>
          <div class="header-actions">
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
          </div>
          <!-- 第三行 -->
          <div style="display: flex; flex: 1 1 100%; flex-wrap: wrap; align-items: center;">
            <el-form-item label="订单日期">
              <el-date-picker
                v-model="queryForm.completeTime"
                type="daterange" value-format="YYYY-MM-DD"
                range-separator="至"
                start-placeholder="开始日期"
                end-placeholder="结束日期"
                style="width: 240px;"
              />
            </el-form-item>
            <el-form-item label="合计箱数区间">
              <el-input v-model="queryForm.TotalAmountMin" placeholder="最小箱数" style="width: 100px;" clearable />
              <span style="margin: 0 8px;">-</span>
              <el-input v-model="queryForm.TotalAmountMax" placeholder="最大箱数" style="width: 100px;" clearable />
            </el-form-item>
            <el-form-item label="运费金额区间">
              <el-input v-model="queryForm.freightMin" placeholder="最小运费" style="width: 100px;" clearable />
              <span style="margin: 0 8px;">-</span>
              <el-input v-model="queryForm.freightMax" placeholder="最大运费" style="width: 100px;" clearable />
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
                <el-tag :type="getStatusTagType(row.Status)">{{ getStatusText(row.Status) }}</el-tag>
                <el-tag :type="getDeliveryTypeTag(row.DeliveryType)" style="margin-left: 8px;">
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
        <el-table-column label="产品信息" min-width="200">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-list">
                <div v-for="(item, index) in row.OrderItems || []" :key="index" class="product-item">
                  <span class="product-name">{{ item.ProductName || '未知产品' }}</span>
                  <span class="product-quantity">×{{ fmtQty(boxQty(item)) }}</span>
                  <span v-if="itemDiff(item) !== 0" class="product-diff">差价 {{ fmtMoney(itemDiff(item)) }}</span>
                </div>
                <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                <span class="total-count">共 {{ row.OrderItems?.length || 0 }} 种产品</span>
                <span class="total-amount">已发 {{ fmtQty(row.ShippedQty) }}/{{ fmtQty(orderBoxTotal(row)) }} 箱</span>
                <span class="total-diff">差价 {{ fmtMoney(orderDiffTotal(row)) }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="合计箱数" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ fmtQty(orderBoxTotal(row)) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="230" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="viewOrder(row)">查看</el-button>
            <el-button type="success" link @click="handleTrack(row)">{{ Number(row.DeliveryType) === 1 ? '自提信息' : '物流跟踪' }}</el-button>
            <el-button type="danger" link @click="openReturn(row)">退货</el-button>
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


    <!-- 物流跟踪 / 自提信息 -->
    <el-dialog v-model="trackDialogVisible" :title="trackIsSelfPickup ? '自提信息' : '物流跟踪'" width="520px">
      <template v-if="trackIsSelfPickup">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单号">{{ trackSelfInfo.OrderNo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="司机姓名">{{ trackSelfInfo.DriverName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="司机电话">{{ trackSelfInfo.DriverPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="车牌号">{{ trackSelfInfo.CarPlateNumber || '-' }}</el-descriptions-item>
        </el-descriptions>
        <el-alert type="info" :closable="false" show-icon title="自提订单不经过快递，无需物流跟踪" style="margin-top: 12px;" />
      </template>
      <template v-else>
        <div style="text-align:right;margin-bottom:10px;">
          <el-button size="small" :loading="trackLoading" @click="refreshTrack">刷新</el-button>
        </div>
        <el-alert v-if="trackMocked" type="warning" :closable="false" show-icon
          :title="trackMessage || '当前为模拟轨迹'" style="margin-bottom: 12px;" />
        <div v-else-if="trackMessage" style="margin-bottom:10px;color:#909399;">{{ trackMessage }}</div>
        <el-timeline v-loading="trackLoading">
          <el-timeline-item v-for="(a, i) in logisticsTrack" :key="i" :type="a.type" :timestamp="a.timestamp">
            <div>{{ a.content }}</div>
            <div v-if="a.location" style="color:#909399;font-size:12px;">{{ a.location }}</div>
          </el-timeline-item>
        </el-timeline>
        <el-empty v-if="!trackLoading && logisticsTrack.length === 0" description="暂无物流轨迹" :image-size="70" />
      </template>
    </el-dialog>

    <!-- 订单查看对话框 -->
    <orderView ref="orderViewRef" v-show="scene === 1" @change-scene="changeScene"></orderView>
  <ReturnOrderDialog v-model="returnDialogVisible" :order="currentReturnOrder" @success="handleQuery" />
  </div>
</template>

<script setup lang="ts">
import { getList, getTotal } from '@/utils/request'
import { exportSelectedOrders } from '@/utils/exportOrders'
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import orderView from '../waiting/orderView.vue'
import { reqCompletedOrderList } from '@/api/order'
import { getLogisticsCompanyNames, getShipmentTrack } from '@/api/shipping'
import { orderBoxTotal, fmtQty, boxQty, itemDiff, orderDiffTotal, fmtMoney } from '@/utils/orderQty'
import ReturnOrderDialog from '../components/ReturnOrderDialog.vue'

// 退货弹窗
const returnDialogVisible = ref(false)
const currentReturnOrder = ref<any>(null)
const openReturn = (row: any) => {
  currentReturnOrder.value = row
  returnDialogVisible.value = true
}

// 场景值：0-数据展示，1-订单查看
const scene = ref<number>(0)

// 物流公司下拉选项
const logisticsCompanyList = ref<any[]>([])

// 查询表单
const queryForm = reactive({
  orderNo: '',
  dealerName: '',
  receiverName: '',
  receiverPhone: '', // 新增收货人电话
  deliveryType: '',
  logisticsCompany: '',
  trackingNo: '',
  completeTime: [],
  TotalAmountMin: '',
  TotalAmountMax: '',
  freightMin: '',
  freightMax: ''
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

// 获取子组件实例
const orderViewRef = ref()

// 物流跟踪 / 自提信息
const trackDialogVisible = ref(false)
const trackLoading = ref(false)
const trackMocked = ref(false)
const trackMessage = ref('')
const trackTitle = ref('物流跟踪')
const logisticsTrack = ref<any[]>([])
const trackIsSelfPickup = ref(false)
const trackSelfInfo = ref<any>({})
const trackShipmentId = ref<number>(0)

const formatTrackTime = (value: string) => {
  if (!value) return ''
  if (String(value).startsWith('0001')) return ''
  const d = new Date(value)
  if (isNaN(d.getTime())) return value
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}
const renderTrack = (data: any) => {
  const list = data?.Tracks || data?.tracks || []
  trackMocked.value = !!data?.Mocked
  trackMessage.value = data?.Message || ''
  logisticsTrack.value = list.map((t: any) => ({
    content: t.Remark || t.remark || '',
    location: t.Location || t.location || '',
    timestamp: formatTrackTime(t.Time || t.time),
    type: (t.Status || t.status) === '已签收' || (t.Status || t.status) === '已自提'
      ? 'success'
      : (t.Status || t.status) === '异常' ? 'danger' : 'primary'
  }))
}
const loadTrack = async (shipmentId: number, refresh = false) => {
  trackLoading.value = true
  try {
    const res: any = await getShipmentTrack(shipmentId, refresh)
    renderTrack(res?.Tracks ? res : (res ?? {}))
  } catch (e: any) {
    if (e && (e.Tracks || e.Message)) renderTrack(e)
    else { console.error('获取物流轨迹失败', e); ElMessage.error('获取物流轨迹失败'); logisticsTrack.value = [] }
  } finally {
    trackLoading.value = false
  }
}
const handleTrack = (row: any) => {
  // 自提订单不经过快递：不调用物流接口，只显示车牌/司机信息
  if (Number(row.DeliveryType) === 1) {
    trackIsSelfPickup.value = true
    trackSelfInfo.value = { ...row }
    trackTitle.value = '自提信息'
    logisticsTrack.value = []
    trackDialogVisible.value = true
    return
  }
  trackIsSelfPickup.value = false
  const shipment = (row?.ShipmentInfos || [])[0]
  if (!shipment?.Id) {
    ElMessage.warning('该订单还没有发货记录，无法查看物流轨迹')
    return
  }
  trackShipmentId.value = shipment.Id
  trackTitle.value = [shipment.LogisticsCompany, shipment.TrackingNo].filter(Boolean).join(' · ') || '物流跟踪'
  logisticsTrack.value = []
  trackMessage.value = ''
  trackMocked.value = false
  trackDialogVisible.value = true
  loadTrack(shipment.Id)
}
const refreshTrack = () => {
  if (trackShipmentId.value) loadTrack(trackShipmentId.value, true)
}


// 查询订单列表
const handleQuery = async () => {
  loading.value = true
  try {
    // 查询参数处理：物流公司传Code
    const selectedCompany = logisticsCompanyList.value.find(item => item.Name === queryForm.logisticsCompany)
    const params: any = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNumber: queryForm.orderNo || undefined,
      DealerName: queryForm.dealerName || undefined,
      ReceiverName: queryForm.receiverName || undefined,
      ReceiverPhone: queryForm.receiverPhone || undefined,
      DeliveryType: queryForm.deliveryType || undefined,
      LogisticsCompany: selectedCompany ? selectedCompany.Code : undefined,
      TrackingNo: queryForm.trackingNo || undefined,
      StartDate: queryForm.completeTime && queryForm.completeTime.length > 0 ? queryForm.completeTime[0] : undefined,
      EndDate: queryForm.completeTime && queryForm.completeTime.length > 1 ? queryForm.completeTime[1] : undefined,
      AmountMin: queryForm.TotalAmountMin || undefined,
      AmountMax: queryForm.TotalAmountMax || undefined,
      FreightMin: queryForm.freightMin || undefined,
      FreightMax: queryForm.freightMax || undefined
    }
    const result = await reqCompletedOrderList(params)
    orderList.value = getList(result)
    total.value = getTotal(result)
    loading.value = false
  } catch (error) {
    ElMessage.error('获取已完成订单列表失败')
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.dealerName = ''
  queryForm.receiverName = ''
  queryForm.receiverPhone = ''
  queryForm.deliveryType = ''
  queryForm.logisticsCompany = ''
  queryForm.trackingNo = ''
  queryForm.completeTime = []
  queryForm.TotalAmountMin = ''
  queryForm.TotalAmountMax = ''
  queryForm.freightMin = ''
  queryForm.freightMax = ''
  currentPage.value = 1
  handleQuery()
}

// 处理选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}

// 查看订单
const viewOrder = (row: any) => {
  scene.value = 1
  nextTick(() => {
    orderViewRef.value?.initView(row)
  })
}

// 导出订单
// 导出订单（统一实现见 utils/exportOrders）
const handleExport = () => exportSelectedOrders(selectedOrders.value)

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

// 新增：订单状态文本和标签类型方法
const getStatusText = (status: number) => {
  const map: Record<number, string> = {
    1: '待审核',
    2: '待发货',
    3: '部分发货',
    4: '已发货',
    5: '已签收',
    6: '已取消',
    7: '已驳回',
    8: '已退货'
  }
  return map[status] || '未知状态'
}

const getStatusTagType = (status: number) => {
  switch (status) {
    case 1: return 'info' // 待审核
    case 2: return 'warning' // 待发货
    case 3: return 'primary' // 已发货
    case 4: return 'primary' // 已发货
    case 5: return 'success' // 已完成
    case 6: return 'danger' // 已取消
    default: return 'default'
  }
}

// 新增：运费方式文本和标签类型方法
const getDeliveryTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    1: '自提',
    2: '到付',
    3: '现付'
  }
  return typeMap[type] || '未知'
}

const getDeliveryTypeTag = (type: number) => {
  switch (type) {
    case 1: return 'info' // 自提
    case 2: return 'warning' // 到付
    case 3: return 'success' // 现付
    default: return 'default'
  }
}

// 初始化
onMounted(async () => {
  handleQuery()
  // 动态获取物流公司名称列表
  const res = await getLogisticsCompanyNames()
  if (Array.isArray(res)) {
    logisticsCompanyList.value = getList(res)
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

  .product-diff {
    font-size: 12px;
    color: #e6a23c;
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
    display: flex;
    flex-wrap: wrap;
    gap: 2px 8px;
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

  .total-diff {
    font-size: 11px;
    color: #e6a23c;
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
</style> 