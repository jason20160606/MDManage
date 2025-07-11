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
          <el-descriptions-item label="订单编号">{{ orderInfo.OrderNo }}</el-descriptions-item>
          <el-descriptions-item label="订单日期">{{ formatDate(orderInfo.OrderDate) }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag type="warning">待发货</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建人">{{ orderInfo.CreatedBy }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ formatDateTime(orderInfo.CreatedAt) }}</el-descriptions-item>
          <el-descriptions-item label="订单总额">{{ orderInfo.TotalAmount }}</el-descriptions-item>
          <el-descriptions-item label="审核人">{{ orderInfo.AuditBy }}</el-descriptions-item>
          <el-descriptions-item label="审核时间">{{ formatDateTime(orderInfo.AuditAt) }}</el-descriptions-item>          
          <el-descriptions-item label="产品种类">{{ orderInfo.OrderItemDetails?.length || 0 }}</el-descriptions-item>
          <!-- 自提时显示司机信息 -->
          <template v-if="orderInfo.DeliveryType === 1">
            <el-descriptions-item label="司机姓名">{{ orderInfo.DriverName || '-' }}</el-descriptions-item>
            <el-descriptions-item label="车牌号">{{ orderInfo.CarPlateNumber || '-' }}</el-descriptions-item>
            <el-descriptions-item label="联系电话">{{ orderInfo.DriverPhone || '-' }}</el-descriptions-item>
            
          </template>
        </el-descriptions>

        <!-- 经销商信息 -->
        <el-descriptions title="经销商信息" :column="2" border style="margin-top: 20px;">
          <el-descriptions-item label="经销商名称">{{ orderInfo.DealerName }}</el-descriptions-item>
          <el-descriptions-item label="发件人">{{ orderInfo.SenderName }}</el-descriptions-item>          
        </el-descriptions>

        <!-- 收货信息 -->
        <el-descriptions title="收货信息" :column="3" border style="margin-top: 20px;">
          <el-descriptions-item label="收货人">{{ orderInfo.ReceiverName }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ orderInfo.ReceiverPhone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ orderInfo.ReceiverAddress }}</el-descriptions-item>
        </el-descriptions>

        <!-- 产品信息 -->
        <div style="margin-top: 20px;">
          <h3>产品信息</h3>
          <el-table :data="orderInfo.OrderItemDetails || []" border style="width: 100%">
            <el-table-column type="index" label="序号" width="80" />
            <el-table-column prop="ProductName" label="产品名称" min-width="100" />
            
            <el-table-column prop="FactoryName" label="厂家" width="120" align="center">              
            </el-table-column>
            <el-table-column prop="BrandName" label="品牌" width="120" align="center">              
            </el-table-column>
            <el-table-column prop="Quantity" label="数量" width="100" align="center" />
          </el-table>
        </div>

        <!-- 订单备注 -->
        <el-descriptions title="订单备注" :column="1" border style="margin-top: 20px;">
          <el-descriptions-item label="备注信息">{{ orderInfo.Remark || '无' }}</el-descriptions-item>
        </el-descriptions>

        <!-- 订单日志信息 -->
        <div style="margin-top: 20px;" v-if="orderInfo?.OrderLogs && orderInfo.OrderLogs.length">
          <h3>订单日志</h3>
          <el-table :data="orderInfo.OrderLogs" border style="width: 100%">
            <el-table-column prop="CreatedAt" label="操作时间" width="180">
              <template #default="{ row }">
                {{ formatDateTime(row.CreatedAt) }}
              </template>
            </el-table-column>
            <el-table-column prop="CreatedName" label="操作人" width="120" />
            <el-table-column prop="CreatedType" label="类型" width="120">
              <template #default="{ row }">
                {{ getLogTypeText(row.CreatedType) }}
              </template>
            </el-table-column>
            <el-table-column prop="Remark" label="备注" />
          </el-table>
        </div>
      </div>

      <div v-else class="no-data">
        <el-empty description="暂无订单信息" />
      </div>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { reqCheckOrder } from '@/api/order'

// 定义事件
const emit = defineEmits(['change-scene'])

// 订单信息
const orderInfo = ref<any>(null)
const loading = ref(false)

// 初始化查看，支持传ID或对象
const initView = async (orderOrId: any) => {
  let orderId = null
  if (typeof orderOrId === 'string' || typeof orderOrId === 'number') {
    orderId = orderOrId
  } else if (orderOrId && (orderOrId.Id || orderOrId.id)) {
    orderId = orderOrId.Id || orderOrId.id
  }
  if (orderId) {
    loading.value = true
    try {
      const res = await reqCheckOrder(String(orderId))
      if (res && (res.success || res.status === 200)) {
        orderInfo.value = res.data
      } else {
        orderInfo.value = null
        ElMessage.error(res.message || '获取订单详情失败')
      }
    } catch (e) {
      orderInfo.value = null
      ElMessage.error('获取订单详情失败')
    } finally {
      loading.value = false
    }
  } else {
    // 没有Id才直接赋值
    orderInfo.value = orderOrId
  }
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

const formatDate = (dateStr: string) => {
  if (!dateStr || dateStr === '0001-01-01T00:00:00') return '--'
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
  })
}
// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr || dateStr === '0001-01-01T00:00:00') return '--'
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}


// 日志类型映射
const getLogTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    //-1.创建 -2.审核 -3.取消 -4.发货 -5.退货 -6.修改 -7.删除 -8.签收
    0: '未知',
    1: '创建',
    2: '审核',
    3: '取消',
    4: '发货',
    5: '退货',
    6: '修改',
    7: '删除',
    8: '签收',    
  }
  return typeMap[type] || '未知'
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