<template>
  <div class="ship-form-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>批量订单发货</span>
          <el-button @click="goBack">返回列表</el-button>
        </div>
      </template>
      <el-form :model="formList" ref="formRef" class="ship-form">
        <el-table :data="formList" border style="width: 100%">
          <el-table-column type="index" label="序号" width="60" />
          <el-table-column prop="OrderNo" label="订单编号" width="180" />
          <el-table-column prop="DealerName" label="经销商" width="150" />
          <el-table-column prop="ReceiverName" label="收货人" width="100" />
          <el-table-column label="订单总量" width="100">
            <template #default="{ row }">
              {{ getOrderTotal(row) }}
            </template>
          </el-table-column>
          <el-table-column label="物流公司" width="150">
            <template #default="{ row }">
              <el-select v-model="row.ExpressCompany" placeholder="请选择物流公司" style="width: 100%;">
                <el-option v-for="opt in logisticsCompanies" :key="opt.value" :label="opt.label" :value="opt.value" />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="物流单号" width="160">
            <template #default="{ row }">
              <el-input v-model="row.ExpressNo" placeholder="请输入物流单号" />
            </template>
          </el-table-column>
          <el-table-column label="发货时间" width="180">
            <template #default="{ row }">
              <el-date-picker v-model="row.ShipTime" type="datetime" placeholder="请选择发货时间" style="width: 100%;" />
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
import { ref } from 'vue'
import { ElMessage } from 'element-plus'

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

// 初始化表单，orders为订单详情数组
const initForm = (orders: any[]) => {
  // 兼容后端返回的不同ID字段名，确保Id一定有值
  formList.value = orders.map(order => ({
    Id: order.Id || order.id || order.orderId || '', // 订单ID，必须
    OrderNo: order.OrderNo || order.orderNo || '',
    DealerName: order.DealerName || order.dealerName || '',
    ReceiverName: order.ReceiverName || order.receiverName || '',
    OrderItems: order.OrderItems || order.orderItems || [],
    ExpressCompany: '',
    ExpressNo: '',
    ShipTime: '',
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
    if (!item.ExpressCompany || !item.ExpressNo || !item.ShipTime) {
      ElMessage.error('请完善所有订单的物流信息')
      return
    }
  }
  submitting.value = true
  // TODO: 调用批量发货API，传formList.value
  setTimeout(() => {
    ElMessage.success('批量发货成功')
    submitting.value = false
    goBack()
  }, 1000)
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
</style> 