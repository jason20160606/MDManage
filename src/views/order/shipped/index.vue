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
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable style="width: 180px;" />
        </el-form-item>
        <el-form-item label="经销商名称">
          <el-input v-model="queryForm.dealerName" placeholder="请输入经销商名称" clearable style="width: 180px;" />
        </el-form-item>
        <el-form-item label="收货人">
          <el-input v-model="queryForm.receiverName" placeholder="请输入收货人姓名" clearable style="width: 150px;" />
        </el-form-item>
        <el-form-item label="物流单号">
          <el-input v-model="queryForm.trackingNo" placeholder="请输入物流单号" clearable style="width: 180px;" />
        </el-form-item>
        <el-form-item label="发货时间">
          <el-date-picker
            v-model="queryForm.shipTime"
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
              <div class="order-no">{{ row.orderNo }}</div>
              <div class="order-date">发货时间: {{ formatDateTime(row.shipTime) }}</div>
              <div class="order-status">
                <el-tag type="success">已发货</el-tag>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="经销商信息" min-width="180">
          <template #default="{ row }">
            <div class="dealer-info">
              <div class="dealer-name">{{ row.dealerName }}</div>
              <div class="dealer-contact">联系人: {{ row.contactPerson }}</div>
              <div class="dealer-phone">电话: {{ row.contactPhone }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="180">
          <template #default="{ row }">
            <div class="receiver-info">
              <div class="receiver-name">{{ row.receiverName }}</div>
              <div class="receiver-phone">电话: {{ row.receiverPhone }}</div>
              <div class="receiver-address">地址: {{ row.receiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="物流信息" min-width="200">
          <template #default="{ row }">
            <div class="logistics-info">
              <div>物流公司: {{ row.logisticsCompany }}</div>
              <div>物流单号: {{ row.trackingNo }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="产品信息" min-width="200">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-list">
                <div v-for="(item, index) in row.orderItems || []" :key="index" class="product-item">
                  <span class="product-name">{{ item.productName || '未知产品' }}</span>
                  <span class="product-quantity">×{{ item.quantity || 0 }}</span>
                </div>
                <div v-if="!row.orderItems || row.orderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                <span class="total-count">共 {{ row.productCount || 0 }} 种产品</span>
                <span class="total-amount">合计: {{ row.totalAmount }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="订单金额" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">¥{{ formatPrice(row.totalAmount) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="viewOrder(row)">查看</el-button>
            <el-button type="success" link @click="handleTrack(row)">物流跟踪</el-button>
            <el-button type="warning" link @click="handleComplete(row)">确认收货</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPageNo"
          v-model:page-size="pageSizeNo"
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import orderView from '../waiting/orderView.vue'

// 场景值：0-数据展示，1-订单查看
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  orderNo: '',
  dealerName: '',
  receiverName: '',
  trackingNo: '',
  shipTime: []
})

// 订单列表
const orderList = ref<any[]>([])
const loading = ref(false)

// 选中的订单
const selectedOrders = ref<any[]>([])

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
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

// 获取子组件实例
const orderViewRef = ref()

// 查询订单列表
const handleQuery = async () => {
  loading.value = true
  try {
    // TODO: 调用已发货订单API
    // const result = await reqShippedOrderList(queryForm)
    // orderList.value = result.data
    // total.value = result.total
    // 模拟数据
    setTimeout(() => {
      orderList.value = [
        {
          id: '1',
          orderNo: 'ORD20240115001',
          shipTime: '2024-01-16 10:00:00',
          dealerName: '北京经销商',
          contactPerson: '张三',
          contactPhone: '13800138001',
          receiverName: '李四',
          receiverPhone: '13900139001',
          receiverAddress: '北京市朝阳区xxx街道xxx号',
          logisticsCompany: '顺丰快递',
          trackingNo: 'SF123456789',
          productCount: 3,
          totalQuantity: 150,
          totalAmount: 15000.00,
          orderItems: [
            { productName: '产品A', quantity: 50 },
            { productName: '产品B', quantity: 60 },
            { productName: '产品C', quantity: 40 }
          ]
        },
        {
          id: '2',
          orderNo: 'ORD20240114002',
          shipTime: '2024-01-15 09:30:00',
          dealerName: '上海经销商',
          contactPerson: '王五',
          contactPhone: '13700137001',
          receiverName: '赵六',
          receiverPhone: '13600136001',
          receiverAddress: '上海市浦东新区xxx路xxx号',
          logisticsCompany: '中通快递',
          trackingNo: 'ZTO987654321',
          productCount: 2,
          totalQuantity: 80,
          totalAmount: 8000.00,
          orderItems: [
            { productName: '产品D', quantity: 30 },
            { productName: '产品E', quantity: 50 }
          ]
        }
      ]
      total.value = orderList.value.length
      loading.value = false
    }, 500)
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
  queryForm.trackingNo = ''
  queryForm.shipTime = []
  currentPageNo.value = 1
  handleQuery()
}

// 处理选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}

// 批量确认收货
const handleBatchComplete = () => {
  if (selectedOrders.value.length === 0) {
    ElMessage.warning('请选择要确认收货的订单')
    return
  }
  ElMessageBox.confirm('确认选中订单已收货吗？', '批量确认收货', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(() => {
    // TODO: 批量确认收货API
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
const handleTrack = (row: any) => {
  trackDialogVisible.value = true
}

// 单个确认收货
const handleComplete = (row: any) => {
  ElMessageBox.confirm('确认该订单已收货吗？', '确认收货', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
  }).then(() => {
    // TODO: 单个确认收货API
    ElMessage.success('确认收货成功')
    handleQuery()
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
  currentPageNo.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSizeNo.value = size
  currentPageNo.value = 1
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
  .dealer-contact,
  .dealer-phone {
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
</style> 