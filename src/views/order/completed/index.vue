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
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable style="width: 180px;" />
        </el-form-item>
        <el-form-item label="经销商名称">
          <el-input v-model="queryForm.dealerName" placeholder="请输入经销商名称" clearable style="width: 180px;" />
        </el-form-item>
        <el-form-item label="收货人">
          <el-input v-model="queryForm.receiverName" placeholder="请输入收货人姓名" clearable style="width: 150px;" />
        </el-form-item>
        <el-form-item label="运费方式">
          <el-select v-model="queryForm.deliveryType" placeholder="请选择运费方式" clearable style="width: 150px;">
            <el-option label="自提" :value="1" />
            <el-option label="到付" :value="2" />
            <el-option label="现付" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="物流公司">
          <el-input v-model="queryForm.logisticsCompany" placeholder="请输入物流公司" clearable style="width: 150px;" />
        </el-form-item>
        <el-form-item label="物流单号">
          <el-input v-model="queryForm.trackingNo" placeholder="请输入物流单号" clearable style="width: 180px;" />
        </el-form-item>
        <el-form-item label="订单日期">
          <el-date-picker
            v-model="queryForm.completeTime"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 240px;"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
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
                  <span class="product-quantity">×{{ item.Quantity || 0 }}</span>
                </div>
                <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                <span class="total-count">共 {{ row.OrderItems?.length || 0 }} 种产品</span>
                <span class="total-amount">合计: {{ formatPrice(row.TotalAmount) }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="订单差价" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ row.TotalAmount }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="120" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="viewOrder(row)">查看</el-button>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import orderView from '../waiting/orderView.vue'
import { reqCompletedOrderList } from '@/api/order'

// 场景值：0-数据展示，1-订单查看
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  orderNo: '',
  dealerName: '',
  receiverName: '',
  deliveryType: '',
  logisticsCompany: '',
  trackingNo: '',
  completeTime: []
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

// 查询订单列表
const handleQuery = async () => {
  loading.value = true
  try {
    // 构造与后端接口一致的查询参数
    const params: any = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNo: queryForm.orderNo || undefined,
      DealerName: queryForm.dealerName || undefined,
      ReceiverName: queryForm.receiverName || undefined,
      DeliveryType: queryForm.deliveryType || undefined,
      LogisticsCompany: queryForm.logisticsCompany || undefined,
      TrackingNo: queryForm.trackingNo || undefined,
      StartDate: queryForm.completeTime && queryForm.completeTime.length > 0 ? queryForm.completeTime[0] : undefined,
      EndDate: queryForm.completeTime && queryForm.completeTime.length > 1 ? queryForm.completeTime[1] : undefined
    }
    // 调用后端已完成订单分页接口，字段与后端保持一致
    const result = await reqCompletedOrderList(params)
    orderList.value = result.data || []
    // 处理分页信息，兼容后端X-Pagination头
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
    ElMessage.error('获取已完成订单列表失败')
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.dealerName = ''
  queryForm.receiverName = ''
  queryForm.deliveryType = ''
  queryForm.logisticsCompany = ''
  queryForm.trackingNo = ''
  queryForm.completeTime = []
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
  return Number(price).toFixed(2)
}

// 新增：订单状态文本和标签类型方法
const getStatusText = (status: number) => {
  const map: Record<number, string> = {
    1: '待审核',
    2: '待发货',
    3: '已发货',
    4: '已完成',
    5: '已取消'
  }
  return map[status] || '未知状态'
}

const getStatusTagType = (status: number) => {
  switch (status) {
    case 1: return 'info' // 待审核
    case 2: return 'warning' // 待发货
    case 3: return 'primary' // 已发货
    case 4: return 'success' // 已完成
    case 5: return 'danger' // 已取消
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
onMounted(() => {
  handleQuery()
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
</style> 