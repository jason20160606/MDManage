<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>订单详情 - {{ currentOrder?.OrderNo || '-' }}</span>
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
              <el-tag :type="getOrderStatusType(currentOrder?.Status)">
                {{ getOrderStatusText(currentOrder?.Status) }}
              </el-tag>
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">产品总数</div>
            <div class="overview-value">{{ currentOrder?.OrderItemDetails?.length || 0 }}</div>
            <div class="overview-unit">种产品</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">总数量</div>
            <div class="overview-value success">{{ getTotalQuantity(currentOrder?.OrderItemDetails) }}</div>
            <div class="overview-unit">件</div>
          </div>
        </el-card>
      </el-col> 
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">差价</div>
            <div class="overview-value success">{{ currentOrder?.PriceDiff }}</div>
            <div class="overview-unit">元</div>
          </div>
        </el-card>
      </el-col>           
    </el-row>

    <!-- 基本信息 -->
    <el-divider content-position="left">基本信息</el-divider>
    
    <el-descriptions :column="3" border>
      <el-descriptions-item label="订单编号">{{ currentOrder?.OrderNo || '-' }}</el-descriptions-item>
      <el-descriptions-item label="订单日期">{{ formatDate(currentOrder?.OrderDate) }}</el-descriptions-item>
      <el-descriptions-item label="运费类型">{{ getDeliveryTypeText(currentOrder?.DeliveryType) }}</el-descriptions-item>
      <el-descriptions-item label="经销商">{{ currentOrder?.DealerName || '-' }}</el-descriptions-item>
      <el-descriptions-item label="创建人">{{ currentOrder?.CreatedBy || '-' }}</el-descriptions-item>
      <el-descriptions-item label="创建时间">{{ formatDateTime(currentOrder?.CreatedAt) || '-' }}</el-descriptions-item>
      <!-- 自提时显示司机信息 -->
      <template v-if="currentOrder?.DeliveryType === 1">
        <el-descriptions-item label="司机姓名">{{ currentOrder?.DriverName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="车牌号">{{ currentOrder?.CarPlateNumber || '-' }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentOrder?.DriverPhone || '-' }}</el-descriptions-item>
        
      </template>
    </el-descriptions>

    <!-- 经销商信息 -->
    <el-divider content-position="left">发件人信息</el-divider>
    
    <el-descriptions :column="2" border>      
      <el-descriptions-item label="发件人">{{ currentOrder?.SenderName || '-' }}</el-descriptions-item>      
    </el-descriptions>

    <!-- 收货信息 -->
    <el-divider content-position="left">收货信息</el-divider>
    
    <el-descriptions :column="3" border>
      <el-descriptions-item label="收货人">{{ currentOrder?.ReceiverName || '-' }}</el-descriptions-item>
      <el-descriptions-item label="联系电话">{{ currentOrder?.ReceiverPhone || '-' }}</el-descriptions-item>
      <el-descriptions-item label="收货地址">{{ currentOrder?.ReceiverAddress || '-' }}</el-descriptions-item>
    </el-descriptions>

    <!-- 产品信息 -->
    <el-divider content-position="left">产品信息</el-divider>
    
    <el-table :data="currentOrder?.OrderItemDetails || []" border style="width: 100%">
      <el-table-column type="index" label="序号" width="80" />
      <el-table-column label="产品名称" min-width="200">
        <template #default="{ row }">
          <div class="product-info">
            <div class="product-name">{{ row.ProductName || '-' }}</div>            
          </div>
        </template>
      </el-table-column>    
      <el-table-column prop="FactoryName" label="厂家" width="120" align="center">        
      </el-table-column>
      <el-table-column prop="BrandName" label="品牌" width="120" align="center">        
      </el-table-column>  
      <el-table-column label="数量" width="120" align="center">
        <template #default="{ row }">
          <span class="quantity">{{ row.Quantity ?? '-' }}</span>
        </template>
      </el-table-column>
      
    </el-table>
  
    <!-- 备注信息 -->
    <el-divider content-position="left">备注信息</el-divider>
    
    <el-card shadow="hover">
      <div class="remark-content">
        {{ currentOrder?.Remark || '暂无备注信息' }}
      </div>
    </el-card>
  </el-card>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
// 引入查看订单API
import { reqCheckOrder } from '@/api/order'

// 定义事件
const emit = defineEmits(['change-scene'])

// 当前订单信息
const currentOrder = ref<any>(null)

// 初始化查看（支持传入订单id或订单对象）
const initView = async (orderId: string | number) => {
  if (orderId) {
    try {
      const res = await reqCheckOrder(orderId.toString())
      if (res && (res.status === 200 || res.success || res.Success)) {
        currentOrder.value = res.data || res.Data || res
      } else {
        ElMessage.error(res.message || res.Message || '获取订单详情失败')
        currentOrder.value = null
      }
    } catch (e) {
      ElMessage.error('获取订单详情失败')
      currentOrder.value = null
    }
  } else {
    ElMessage.error('订单Id无效')
    currentOrder.value = null
  }
}

// 计算产品总数量
const getTotalQuantity = (items: any[] = []) => {
  if (!items) return 0
  return items.reduce((sum, item) => sum + (item.Quantity || 0), 0)
}

// 适配新结构，优先取OrderItemDetails
const getOrderItems = () => {
  return currentOrder.value?.OrderItemDetails || []
}

// 获取订单状态类型
const getOrderStatusType = (status: number) => {
  const statusMap: Record<number, string> = {
    1: 'info',      // 待审核
    2: 'success',   // 已审核
    3: 'warning',   // 已发货
    4: 'success',   // 已完成
    5: 'danger'     // 已取消
  }
  return statusMap[status] || 'info'
}

// 获取订单状态文本
const getOrderStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    1: '待审核',
    2: '已审核',
    3: '已发货',
    4: '已完成',
    5: '已取消'
  }
  return statusMap[status] || '未知'
}

// 获取付款方式文本
const getDeliveryTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    1: '自提',
    2: '到付',
    3: '现付'
  }
  return typeMap[type] || '未知'
}
// 格式化日期时间
const formatDate = (dateStr: string) => {
  if (!dateStr || dateStr.startsWith('0001')) return '-'
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit'
    
  })
}
// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr || dateStr.startsWith('0001')) return '-'
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
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