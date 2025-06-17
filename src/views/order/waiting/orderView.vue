<template>
  <div class="order-view-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>订单详情</span>
          <el-button @click="goBack">返回列表</el-button>
        </div>
      </template>

      <div v-if="orderInfo" class="order-detail">
        <!-- 订单基本信息 -->
        <el-descriptions title="订单基本信息" :column="3" border>
          <el-descriptions-item label="订单编号">{{ orderInfo.orderNo }}</el-descriptions-item>
          <el-descriptions-item label="下单时间">{{ formatDateTime(orderInfo.orderDate) }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag type="warning">待发货</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="订单金额">¥{{ formatPrice(orderInfo.totalAmount) }}</el-descriptions-item>
          <el-descriptions-item label="产品种类">{{ orderInfo.productCount }} 种</el-descriptions-item>
          <el-descriptions-item label="总数量">{{ orderInfo.totalQuantity }} 件</el-descriptions-item>
        </el-descriptions>

        <!-- 经销商信息 -->
        <el-descriptions title="经销商信息" :column="2" border style="margin-top: 20px;">
          <el-descriptions-item label="经销商名称">{{ orderInfo.dealerName }}</el-descriptions-item>
          <el-descriptions-item label="联系人">{{ orderInfo.contactPerson }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ orderInfo.contactPhone }}</el-descriptions-item>
          <el-descriptions-item label="经销商地址">{{ orderInfo.dealerAddress || '暂无' }}</el-descriptions-item>
        </el-descriptions>

        <!-- 收货信息 -->
        <el-descriptions title="收货信息" :column="2" border style="margin-top: 20px;">
          <el-descriptions-item label="收货人">{{ orderInfo.receiverName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ orderInfo.receiverPhone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ orderInfo.receiverAddress }}</el-descriptions-item>
        </el-descriptions>

        <!-- 产品信息 -->
        <div style="margin-top: 20px;">
          <h3>产品信息</h3>
          <el-table :data="orderInfo.orderItems || []" border style="width: 100%">
            <el-table-column type="index" label="序号" width="80" />
            <el-table-column prop="productName" label="产品名称" min-width="200" />
            <el-table-column prop="quantity" label="数量" width="100" align="center" />
            <el-table-column prop="unitPrice" label="单价" width="120" align="center">
              <template #default="{ row }">
                ¥{{ formatPrice(row.unitPrice) }}
              </template>
            </el-table-column>
            <el-table-column prop="subtotal" label="小计" width="120" align="center">
              <template #default="{ row }">
                ¥{{ formatPrice(row.subtotal) }}
              </template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 订单备注 -->
        <el-descriptions title="订单备注" :column="1" border style="margin-top: 20px;">
          <el-descriptions-item label="备注信息">{{ orderInfo.remark || '无' }}</el-descriptions-item>
        </el-descriptions>
      </div>

      <div v-else class="no-data">
        <el-empty description="暂无订单信息" />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'

// 定义事件
const emit = defineEmits(['change-scene'])

// 订单信息
const orderInfo = ref<any>(null)

// 初始化查看
const initView = (order: any) => {
  orderInfo.value = order
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
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

// 暴露方法给父组件
defineExpose({
  initView
})
</script>

<style lang="scss" scoped>
.order-view-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.order-detail {
  h3 {
    margin-bottom: 15px;
    color: #303133;
    font-size: 16px;
  }
}

.no-data {
  text-align: center;
  padding: 40px 0;
}
</style> 