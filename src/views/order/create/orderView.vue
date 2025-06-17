<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>订单详情 - {{ currentOrder?.orderNo }}</span>
        <el-button @click="goBack">返回列表</el-button>
      </div>
    </template>

    <!-- 订单概览 -->
    <el-row :gutter="20" class="overview-section">
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">订单状态</div>
            <div class="overview-value">
              <el-tag :type="getOrderStatusType(currentOrder?.orderStatus)">
                {{ getOrderStatusText(currentOrder?.orderStatus) }}
              </el-tag>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">产品总数</div>
            <div class="overview-value">{{ currentOrder?.productCount || 0 }}</div>
            <div class="overview-unit">种产品</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">总数量</div>
            <div class="overview-value success">{{ currentOrder?.totalQuantity || 0 }}</div>
            <div class="overview-unit">件</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">订单金额</div>
            <div class="overview-value danger">{{ currentOrder?.totalAmount }}</div>            
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 基本信息 -->
    <el-divider content-position="left">基本信息</el-divider>
    
    <el-descriptions :column="3" border>
      <el-descriptions-item label="订单编号">{{ currentOrder?.orderNo }}</el-descriptions-item>
      <el-descriptions-item label="下单时间">{{ formatDateTime(currentOrder?.orderDate) }}</el-descriptions-item>
      <el-descriptions-item label="订单状态">
        <el-tag :type="getOrderStatusType(currentOrder?.orderStatus)">
          {{ getOrderStatusText(currentOrder?.orderStatus) }}
        </el-tag>
      </el-descriptions-item>
      <el-descriptions-item label="经销商">{{ currentOrder?.dealerName }}</el-descriptions-item>
      <el-descriptions-item label="运费类型">{{ getPaymentMethodText(currentOrder?.paymentMethod) }}</el-descriptions-item>     
    </el-descriptions>

    <!-- 经销商信息 -->
    <el-divider content-position="left">经销商信息</el-divider>
    
    <el-descriptions :column="3" border>
      <el-descriptions-item label="联系人">{{ currentOrder?.contactPerson }}</el-descriptions-item>
      <el-descriptions-item label="联系电话">{{ currentOrder?.contactPhone }}</el-descriptions-item>      
    </el-descriptions>

    <!-- 收货信息 -->
    <el-divider content-position="left">收货信息</el-divider>
    
    <el-descriptions :column="3" border>
      <el-descriptions-item label="收货人">{{ currentOrder?.receiverName }}</el-descriptions-item>
      <el-descriptions-item label="联系电话">{{ currentOrder?.receiverPhone }}</el-descriptions-item>
      <el-descriptions-item label="收货地址">{{ currentOrder?.receiverAddress }}</el-descriptions-item>
    </el-descriptions>

    <!-- 产品信息 -->
    <el-divider content-position="left">产品信息</el-divider>
    
    <el-table :data="currentOrder?.orderItems || []" border style="width: 100%">
      <el-table-column type="index" label="序号" width="80" />
      <el-table-column label="产品名称" min-width="200">
        <template #default="{ row }">
          <div class="product-info">
            <div class="product-name">{{ row.productName }}</div>
            <div class="product-spec">规格: {{ row.specification || '-' }}</div>
          </div>
        </template>
      </el-table-column>
      <el-table-column label="单价" width="120" align="center">
        <template #default="{ row }">
          <span>¥{{ formatPrice(row.unitPrice) }}</span>
        </template>
      </el-table-column>
      <el-table-column label="数量" width="120" align="center">
        <template #default="{ row }">
          <span class="quantity">{{ row.quantity }}</span>
        </template>
      </el-table-column>
      <el-table-column label="小计" width="120" align="center">
        <template #default="{ row }">
          <span class="subtotal">¥{{ formatPrice(row.subtotal) }}</span>
        </template>
      </el-table-column>
    </el-table>
  
    <!-- 备注信息 -->
    <el-divider content-position="left">备注信息</el-divider>
    
    <el-card shadow="hover">
      <div class="remark-content">
        {{ currentOrder?.remark || '暂无备注信息' }}
      </div>
    </el-card>
  </el-card>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// 定义事件
const emit = defineEmits(['change-scene'])

// 当前订单信息
const currentOrder = ref<any>(null)

// 初始化查看
const initView = (order: any) => {
  currentOrder.value = order
}

// 获取订单状态类型
const getOrderStatusType = (status: string) => {
  const statusMap: Record<string, string> = {
    'pending': 'info',
    'confirmed': 'success',
    'producing': 'warning',
    'completed': 'success',
    'cancelled': 'danger'
  }
  return statusMap[status] || 'info'
}

// 获取订单状态文本
const getOrderStatusText = (status: string) => {
  const statusMap: Record<string, string> = {
    'pending': '待确认',
    'confirmed': '已确认',
    'producing': '生产中',
    'completed': '已完成',
    'cancelled': '已取消'
  }
  return statusMap[status] || '未知'
}

// 获取付款方式文本
const getPaymentMethodText = (method: string) => {
  const methodMap: Record<string, string> = {
    'cash': '现金',
    'bank_transfer': '银行转账',
    'check': '支票',
    'other': '其他'
  }
  return methodMap[method] || method || '-'
}

// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 格式化日期
const formatDate = (dateStr: string) => {
  if (!dateStr) return '-'
  return new Date(dateStr).toLocaleDateString('zh-CN')
}

// 格式化价格
const formatPrice = (price: number) => {
  if (!price) return '0.00'
  return price.toFixed(2)
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

// 暴露方法给父组件
defineExpose({
  initView
})
</script>

<style lang="scss" scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.overview-section {
  margin-bottom: 20px;
}

.overview-card {
  .overview-item {
    text-align: center;
    
    .overview-label {
      font-size: 14px;
      color: #909399;
      margin-bottom: 8px;
    }
    
    .overview-value {
      font-size: 24px;
      font-weight: bold;
      color: #409eff;
      margin-bottom: 4px;
      
      &.success {
        color: #67c23a;
      }
      
      &.danger {
        color: #f56c6c;
      }
    }
    
    .overview-unit {
      font-size: 12px;
      color: #909399;
    }
  }
}

.product-info {
  .product-name {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  
  .product-spec {
    font-size: 12px;
    color: #909399;
  }
}

.quantity {
  color: #409eff;
  font-weight: bold;
}

.subtotal {
  color: #f56c6c;
  font-weight: bold;
}

.summary-card {
  .summary-item {
    text-align: center;
    
    .summary-label {
      font-size: 14px;
      color: #909399;
      margin-bottom: 8px;
    }
    
    .summary-value {
      font-size: 20px;
      font-weight: bold;
      color: #303133;
      
      &.total-amount {
        color: #f56c6c;
      }
      
      &.discount-amount {
        color: #e6a23c;
      }
      
      &.final-amount {
        color: #67c23a;
      }
    }
  }
  
  &.final {
    border: 2px solid #67c23a;
  }
}

.remark-content {
  padding: 16px;
  min-height: 60px;
  color: #606266;
  line-height: 1.6;
}
</style> 