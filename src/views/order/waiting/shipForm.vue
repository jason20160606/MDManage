<template>
  <div class="ship-form-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>{{ formList.length > 1 ? '批量订单发货' : '订单发货' }}</span>
          <el-button @click="goBack">返回列表</el-button>
        </div>
      </template>
      <el-form :model="formList" ref="formRef" class="ship-form">
        <el-table :data="formList" border style="width: 100%">
          <el-table-column type="index" label="序号" width="60" />
          <el-table-column prop="SenderName" label="发货人" width="120" />
          <el-table-column prop="ReceiverName" label="收货人" width="120" />
          <el-table-column label="商品信息" min-width="200">
            <template #default="{ row }">
              {{ row.ProductMessage }}
            </template>
          </el-table-column>
          <el-table-column label="发货总量" width="100">
            <template #default="{ row }">
              {{ getOrderTotal(row) }}
            </template>
          </el-table-column>
          <!-- 仅自提订单显示司机相关列（只读显示） -->
          <el-table-column v-if="isAllSelfPickup" label="司机姓名" width="120">
            <template #default="{ row }">
              {{ row.DriverName }}
            </template>
          </el-table-column>
          <el-table-column v-if="isAllSelfPickup" label="车牌号" width="120">
            <template #default="{ row }">
              {{ row.CarNumber }}
            </template>
          </el-table-column>
          <el-table-column v-if="isAllSelfPickup" label="电话" width="140">
            <template #default="{ row }">
              {{ row.DriverPhone }}
            </template>
          </el-table-column>
          <!-- 仅非自提订单显示物流相关列 -->
          <el-table-column v-if="!isAllSelfPickup" label="物流公司" width="150">
            <template #default="{ row }">
              <el-select v-model="row.ExpressCompany" placeholder="请选择物流公司" style="width: 100%;">
                <el-option v-for="opt in logisticsCompanies" :key="opt.value" :label="opt.label" :value="opt.value" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column v-if="!isAllSelfPickup" label="物流单号" width="160">
            <template #default="{ row }">
              <el-input v-model="row.ExpressNo" placeholder="请输入物流单号" />
            </template>
          </el-table-column>
          <el-table-column v-if="!isAllSelfPickup" label="邮费" width="180">
            <template #default="{ row }">
              <el-input-number v-model="row.Freight" :min="0" :step="0.01" :precision="2" :controls="true" placeholder="请输入邮费" style="width: 100%;" />
            </template>
          </el-table-column>
          <el-table-column label="备注" width="180">
            <template #default="{ row }">
              <el-input v-model="row.Remark" placeholder="请输入备注" />
            </template>
          </el-table-column>
        </el-table>
        <div style="margin-top: 24px; text-align: center;">
          <el-button type="primary" @click="handleSubmit" :loading="submitting">确认发货</el-button>
          <el-button @click="goBack">取消</el-button>
        </div>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqShipOrder, reqBatchShipOrder } from '@/api/order'

// 定义事件
const emit = defineEmits(['change-scene'])

// 批量发货表单数据
const formList = ref<any[]>([])

// 物流公司选项
const logisticsCompanies = [
  { value: 'SF', label: '顺丰快递' },
  { value: 'YTO', label: '圆通快递' },
  { value: 'ZTO', label: '中通快递' },
  { value: 'STO', label: '申通快递' },
  { value: 'YD', label: '韵达快递' },
  { value: 'JD', label: '京东物流' },
  { value: 'EMS', label: 'EMS' },
  { value: 'OTHER', label: '其他' }
]

// 表单引用
const formRef = ref()
const submitting = ref(false)

// 判断当前订单列表是否全部为自提订单
const isAllSelfPickup = computed(() => formList.value.length > 0 && formList.value.every(item => item.DeliveryType == 1))

// 初始化表单，orders为订单详情数组
const initForm = (orders: any[]) => {
  // 兼容后端返回的不同ID字段名，确保Id一定有值
  formList.value = orders.map(order => ({
    Id: order.Id || order.id || order.orderId || '', // 订单ID，必须
    DealerName: order.DealerName || order.dealerName || '',
    SenderName: order.SenderName || order.senderName || '',
    ReceiverName: order.ReceiverName || order.receiverName || '',
    OrderItems: order.OrderItems || order.orderItems || [],
    ProductMessage: (order.OrderItems || order.orderItems || []).map(i => `${i.ProductName || i.productName}*${i.Quantity || i.quantity}`).join(', '),
    DeliveryType: order.DeliveryType, // 订单配送类型，1为自提
    // 物流信息
    ExpressCompany: '',
    ExpressNo: '',
    Freight: 0,
    // 自提信息
    DriverName: '', // 司机姓名
    CarNumber: '', // 车牌号
    DriverPhone: '', // 司机电话
    Remark: ''
  }))
}

// 获取订单总量
const getOrderTotal = (order: any) => {
  if (!order.OrderItems) return 0
  return order.OrderItems.reduce((sum: number, item: any) => sum + (item.Quantity || 0), 0)
}

// 提交批量发货
const handleSubmit = async () => {
  // 提交前打印所有数据，便于调试
  console.log('批量发货提交数据：', JSON.parse(JSON.stringify(formList.value)))
  for (const [idx, item] of formList.value.entries()) {
    if (!item.Id) {
      ElMessage.error(`第${idx + 1}行订单ID缺失，无法发货，原始数据：${JSON.stringify(item)}`)
      return
    }
    // 自提订单校验司机信息
    if (item.DeliveryType == 1) {
      if (!item.DriverName || !item.CarNumber || !item.DriverPhone) {
        ElMessage.error('请完善所有自提订单的司机信息')
        return
      }
    } else {
      // 普通订单校验物流信息
      if (!item.ExpressCompany || !item.ExpressNo || !item.Freight) {
        ElMessage.error('请完善所有订单的物流信息')
        return
      }
    }
  }
  submitting.value = true
  try {
    let res;
    if (formList.value.length === 1) {
      const item = formList.value[0]
      let params;
      if (item.DeliveryType == 1) {
        // 自提订单参数
        params = {
          OrderId: item.Id,
          DriverName: item.DriverName,
          CarNumber: item.CarNumber,
          DriverPhone: item.DriverPhone,
          Remark: item.Remark
        }
      } else {
        // 普通订单参数
        params = {
          OrderId: item.Id,
          Carrier: item.ExpressCompany,
          TrackingNo: item.ExpressNo,
          Freight: item.Freight,
          Remark: item.Remark
        }
      }
      res = await reqShipOrder(params)
    } else if (formList.value.length > 1) {
      // 批量订单发货
      const orderShipmentDtos = formList.value.map(item => {
        if (item.DeliveryType == 1) {
          // 自提订单
          return {
            OrderId: item.Id,
            DriverName: item.DriverName,
            CarNumber: item.CarNumber,
            DriverPhone: item.DriverPhone,
            Remark: item.Remark
          }
        } else {
          // 普通订单
          return {
            OrderId: item.Id,
            Carrier: item.ExpressCompany,
            TrackingNo: item.ExpressNo,
            Freight: item.Freight,
            Remark: item.Remark
          }
        }
      })
      res = await reqBatchShipOrder({ orderShipmentDtos })
    }
    // 美化弹窗展示
    if (res && res.data && res.data.Success) {
      const info = res.data;
      let html = `
        <div>
          <div style="font-weight:bold;margin-bottom:8px;">发货成功！</div>
          <div>订单号：${info.OrderNumber}</div>
          <div>发货总量：${info.ShipTotal}</div>
          <div style="margin-top:8px;">发货明细：</div>
          <ul style="margin:0;padding-left:20px;">
            ${info.shipmentInfos.map(i => `<li>订单ID：${i.OrderId}，${i.ProductMessage}</li>`).join('')}
          </ul>
        </div>
      `;
      ElMessageBox({
        title: '发货结果',
        message: html,
        dangerouslyUseHTMLString: true,
        confirmButtonText: '确定',
        customClass: 'shipment-success-messagebox'
      });
      goBack();
    } else {
      ElMessage.error(res?.data?.Message || '批量发货失败');
    }
  } catch (e) {
    ElMessage.error('批量发货失败');
  } finally {
    submitting.value = false;
  }
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

// 暴露方法给父组件
defineExpose({
  initForm
})
</script>

<style lang="scss" scoped>
.ship-form-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.ship-form {
  max-width: 100%;
  margin: 0 auto;
}

.shipment-success-messagebox .el-message-box__content {
  font-size: 16px;
  color: #222;
}
.shipment-success-messagebox ul {
  margin: 0;
  padding-left: 20px;
}
.shipment-success-messagebox li {
  margin-bottom: 4px;
  color: #409eff;
}
</style> 