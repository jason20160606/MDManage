<template>
  <div class="app-container">
    <!-- 待发货订单列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>待发货订单管理</span>
          <div class="header-actions">
            <el-button type="success" @click="handleBatchShip">批量发货</el-button>
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="经销商名称">
          <el-input v-model="queryForm.dealerName" placeholder="请输入经销商名称" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="收货人">
          <el-input v-model="queryForm.receiverName" placeholder="请输入收货人姓名" clearable style="width: 150px;" />
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker
            v-model="queryForm.dateRange"
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
              <div class="order-date">下单时间: {{ formatDateTime(row.orderDate) }}</div>
              <div class="order-status">
                <el-tag type="warning">待发货</el-tag>
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
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleShip(row)">发货</el-button>
            <el-button type="info" link @click="viewOrder(row)">查看</el-button>
            <el-button type="warning" link @click="handleCancel(row)">取消</el-button>
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

    <!-- 发货表单 -->
    <shipForm ref="shipFormRef" v-show="scene === 1" @change-scene="changeScene"></shipForm>

    <!-- 订单查看对话框 -->
    <orderView ref="orderViewRef" v-show="scene === 2" @change-scene="changeScene"></orderView>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import shipForm from './shipForm.vue'
import orderView from './orderView.vue'

// 场景值：0-数据展示，1-发货编辑，2-订单查看
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  orderNo: '',
  dealerName: '',
  receiverName: '',
  dateRange: []
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

// 获取子组件实例
const shipFormRef = ref()
const orderViewRef = ref()

// 查询订单列表
const handleQuery = async () => {
  loading.value = true
  try {
    // TODO: 调用待发货订单列表API
    // const result = await reqWaitingOrderList(queryForm)
    
    // 模拟数据
    setTimeout(() => {
      orderList.value = [
        {
          id: '1',
          orderNo: 'ORD20240115001',
          orderDate: '2024-01-15 14:30:00',
          orderStatus: 'waiting_ship',
          dealerName: '北京经销商',
          contactPerson: '张三',
          contactPhone: '13800138001',
          receiverName: '李四',
          receiverPhone: '13900139001',
          receiverAddress: '北京市朝阳区xxx街道xxx号',
          productCount: 3,
          totalQuantity: 150,
          totalAmount: 15000.00,
          orderItems: [
            { productName: '产品A', quantity: 50, unitPrice: 100, subtotal: 5000 },
            { productName: '产品B', quantity: 60, unitPrice: 120, subtotal: 7200 },
            { productName: '产品C', quantity: 40, unitPrice: 70, subtotal: 2800 }
          ]
        },
        {
          id: '2',
          orderNo: 'ORD20240114002',
          orderDate: '2024-01-14 16:20:00',
          orderStatus: 'waiting_ship',
          dealerName: '上海经销商',
          contactPerson: '王五',
          contactPhone: '13700137001',
          receiverName: '赵六',
          receiverPhone: '13600136001',
          receiverAddress: '上海市浦东新区xxx路xxx号',
          productCount: 2,
          totalQuantity: 80,
          totalAmount: 8000.00,
          orderItems: [
            { productName: '产品D', quantity: 30, unitPrice: 150, subtotal: 4500 },
            { productName: '产品E', quantity: 50, unitPrice: 70, subtotal: 3500 }
          ]
        }
      ]
      total.value = orderList.value.length
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取待发货订单列表失败')
    console.error('订单查询错误:', error)
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.dealerName = ''
  queryForm.receiverName = ''
  queryForm.dateRange = []
  currentPageNo.value = 1
  handleQuery()
}

// 处理选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}

// 批量发货
const handleBatchShip = () => {
  if (selectedOrders.value.length === 0) {
    ElMessage.warning('请选择要发货的订单')
    return
  }
  
  scene.value = 1
  nextTick(() => {
    shipFormRef.value?.initForm(selectedOrders.value)
  })
}

// 单个发货
const handleShip = (row: any) => {
  scene.value = 1
  nextTick(() => {
    shipFormRef.value?.initForm([row])
  })
}

// 查看订单
const viewOrder = (row: any) => {
  scene.value = 2
  nextTick(() => {
    orderViewRef.value?.initView(row)
  })
}

// 取消订单
const handleCancel = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要取消订单"${row.orderNo}"吗？`,
      '取消订单',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    // TODO: 调用取消订单API
    ElMessage.success('订单取消成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('订单取消失败')
    }
  }
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