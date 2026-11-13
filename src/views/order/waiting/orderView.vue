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
            <el-tag :type="statusTagType(orderInfo.Status)">{{ statusText(orderInfo.Status) }}</el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="创建人">{{ orderInfo.CreatedBy }}</el-descriptions-item>
          <el-descriptions-item label="创建时间">{{ formatDateTime(orderInfo.CreatedAt) }}</el-descriptions-item>
          <el-descriptions-item label="合计箱数">
            应发 {{ fmtQty(orderInfo.TotalShipQty) }} 箱 / 已发 {{ fmtQty(orderInfo.ShippedQty) }} 箱
          </el-descriptions-item>
          <el-descriptions-item label="审核人">{{ orderInfo.AuditBy }}</el-descriptions-item>
          <el-descriptions-item label="审核时间">{{ formatDateTime(orderInfo.AuditAt) }}</el-descriptions-item>
          <el-descriptions-item label="产品种类">{{ orderInfo.OrderItemDetails?.length || 0 }}</el-descriptions-item>
          <el-descriptions-item label="签收时间" v-if="orderInfo.Status === 5">
            {{ formatDateTime(orderInfo.ReceivedAt) }}
          </el-descriptions-item>
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
            <el-table-column prop="Quantity" label="数量(额度箱)" width="120" align="center" />
            <el-table-column label="应发箱数" width="110" align="center">
              <template #default="{ row }">{{ fmtQty(itemShipQty(row)) }}</template>
            </el-table-column>
            <el-table-column label="已发箱数" width="110" align="center">
              <template #default="{ row }">{{ fmtQty(row.ShippedQty || 0) }}</template>
            </el-table-column>
          </el-table>
          <div class="product-total">
            合计：应发 <strong>{{ fmtQty(orderBoxTotal(orderInfo)) }}</strong> 箱，
            已发 <strong>{{ fmtQty(orderInfo.ShippedQty || 0) }}</strong> 箱
          </div>
        </div>

        <!-- 发货信息 -->
        <div style="margin-top: 20px;" v-if="orderInfo?.ShipmentInfos && orderInfo.ShipmentInfos.length">
          <h3>发货信息</h3>
          <el-alert
            :title="`共 ${orderInfo.ShipmentInfos.length} 次发货，合计 ${fmtQty(orderInfo.ShippedQty)} 箱`"
            type="success"
            :closable="false"
            show-icon
            style="margin-bottom: 12px;"
          />
          <el-alert
            v-if="orderInfo.DeliveryType === 1"
            type="info"
            :closable="false"
            show-icon
            :title="`自提订单 · 司机：${orderInfo.DriverName || '-'}　电话：${orderInfo.DriverPhone || '-'}　车牌：${orderInfo.CarPlateNumber || '-'}`"
            style="margin-bottom: 12px;"
          />
          <el-table :data="orderInfo.ShipmentInfos" border style="width: 100%">
            <el-table-column type="index" label="序号" width="70" />
            <el-table-column prop="ShipmentNo" label="发货单号" width="230" show-overflow-tooltip />
            <el-table-column v-if="orderInfo.DeliveryType !== 1" label="物流公司" width="120" align="center">
              <template #default="{ row }">{{ row.LogisticsCompany || '-' }}</template>
            </el-table-column>
            <el-table-column v-if="orderInfo.DeliveryType !== 1" label="运单号" width="150" align="center">
              <template #default="{ row }">{{ row.TrackingNo || '-' }}</template>
            </el-table-column>
            <el-table-column label="发货时间" width="160" align="center">
              <template #default="{ row }">{{ formatDateTime(row.CreatedAt) }}</template>
            </el-table-column>
            <el-table-column label="类型" width="100" align="center">
              <template #default="{ row }">{{ shipmentTypeText(row.ShipmentType) }}</template>
            </el-table-column>
            <el-table-column label="本次箱数" width="100" align="center">
              <template #default="{ row }">{{ fmtQty(row.TotalQuantity) }}</template>
            </el-table-column>
            <el-table-column label="发货明细" min-width="200">
              <template #default="{ row }">
                <div v-for="(g, gi) in row.Items || []" :key="gi">
                  {{ g.ProductName }} × {{ fmtQty(g.Quantity) }} 箱
                </div>
                <span v-if="!row.Items || !row.Items.length">-</span>
              </template>
            </el-table-column>
            <el-table-column label="备注" min-width="100" show-overflow-tooltip>
              <template #default="{ row }">{{ row.Remark || '-' }}</template>
            </el-table-column>
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
import { showError } from '@/utils/request'
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
import { reqCheckOrder } from '@/api/order'
import { fmtQty, boxQty, orderBoxTotal } from '@/utils/orderQty'

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
      showError(e, '获取订单详情失败')
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


// 订单状态文案与标签色（1待审核 2待发货 3部分发货 4已发货 5已签收 6已取消 7已驳回）
const STATUS_TEXT: Record<number, string> = {
  1: '待审核', 2: '待发货', 3: '部分发货', 4: '已发货', 5: '已签收', 6: '已取消', 7: '已驳回', 8: '已退货'
}
const STATUS_TAG: Record<number, string> = {
  1: 'info', 2: 'warning', 3: 'warning', 4: 'success', 5: 'success', 6: 'info', 7: 'danger', 8: 'danger'
}
const statusText = (status: number) => STATUS_TEXT[Number(status)] || '未知'
const statusTagType = (status: number) => (STATUS_TAG[Number(status)] || 'info') as any

// 发货类型：1-全部发货，2-部分发货
const shipmentTypeText = (type: number) => (Number(type) === 2 ? '部分发货' : '全部发货')

// 明细应发箱数（实物箱）
const itemShipQty = (item: any) => boxQty(item)

// 日志类型映射
const getLogTypeText = (type: number) => {  const typeMap: Record<number, string> = {
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
    // 10 = 部分发货（后端部分发货写 10，全部发货写 4）
    10: '部分发货',
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

.product-total {
  margin-top: 10px;
  text-align: right;
  font-size: 14px;
  color: #606266;
}

.no-data {
  text-align: center;
  padding: 40px 0;
}
</style> 