<template>
  <div class="ship-form-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>订单发货</span>
          <el-button @click="goBack">返回列表</el-button>
        </div>
      </template>

      <!-- 订单信息展示 -->
      <div class="order-info-section">
        <h3>待发货订单</h3>
        <el-table :data="orderList" border style="width: 100%" size="small">
          <el-table-column type="index" width="50" />
          <el-table-column prop="orderNo" label="订单编号" width="180" />
          <el-table-column prop="dealerName" label="经销商" width="150" />
          <el-table-column prop="receiverName" label="收货人" width="100" />
          <el-table-column prop="totalAmount" label="订单金额" width="120">
            <template #default="{ row }">
              ¥{{ formatPrice(row.totalAmount) }}
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 发货信息表单 -->
      <el-form :model="shipForm" :rules="rules" ref="formRef" label-width="120px" class="ship-form">
        <el-form-item label="物流公司" prop="logisticsCompany">
          <el-select v-model="shipForm.logisticsCompany" placeholder="请选择物流公司" style="width: 100%;">
            <el-option
              v-for="item in logisticsCompanies"
              :key="item.value"
              :label="item.label"
              :value="item.value"
            />
          </el-select>
        </el-form-item>

        <el-form-item label="物流单号" prop="trackingNo">
          <el-input v-model="shipForm.trackingNo" placeholder="请输入物流单号" />
        </el-form-item>

        <el-form-item label="发货时间" prop="shipTime">
          <el-date-picker
            v-model="shipForm.shipTime"
            type="datetime"
            placeholder="选择发货时间"
            style="width: 100%;"
          />
        </el-form-item>

        <el-form-item label="发货备注" prop="remark">
          <el-input
            v-model="shipForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入发货备注信息"
          />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleSubmit" :loading="submitting">确认发货</el-button>
          <el-button @click="goBack">取消</el-button>
        </el-form-item>
      </el-form>
    </el-card>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

// 定义事件
const emit = defineEmits(['change-scene'])

// 订单列表
const orderList = ref<any[]>([])

// 发货表单
const shipForm = reactive({
  logisticsCompany: '',
  trackingNo: '',
  shipTime: '',
  remark: ''
})

// 表单验证规则
const rules = {
  logisticsCompany: [
    { required: true, message: '请选择物流公司', trigger: 'change' }
  ],
  trackingNo: [
    { required: true, message: '请输入物流单号', trigger: 'blur' }
  ],
  shipTime: [
    { required: true, message: '请选择发货时间', trigger: 'change' }
  ]
}

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

// 初始化表单
const initForm = (orders: any[]) => {
  orderList.value = orders
  // 重置表单
  shipForm.logisticsCompany = ''
  shipForm.trackingNo = ''
  shipForm.shipTime = ''
  shipForm.remark = ''
}

// 提交发货
const handleSubmit = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    submitting.value = true
    
    // TODO: 调用发货API
    // const result = await reqShipOrders({
    //   orderIds: orderList.value.map(order => order.id),
    //   ...shipForm
    // })
    
    // 模拟API调用
    setTimeout(() => {
      ElMessage.success('发货成功')
      submitting.value = false
      goBack()
    }, 1000)
    
  } catch (error) {
    submitting.value = false
    console.error('发货失败:', error)
  }
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

// 格式化价格
const formatPrice = (price: number) => {
  if (!price) return '0.00'
  return price.toFixed(2)
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

.order-info-section {
  margin-bottom: 30px;
  
  h3 {
    margin-bottom: 15px;
    color: #303133;
    font-size: 16px;
  }
}

.ship-form {
  max-width: 600px;
  margin: 0 auto;
}
</style> 