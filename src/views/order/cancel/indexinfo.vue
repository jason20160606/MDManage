<template>
  <div class="order-detail-container">
    <!-- 页面标题 -->
    <div class="page-header">
      <el-page-header @back="goBack" :title="'订单详情'" />
    </div>

    <!-- 订单基本信息 -->
    <el-card class="detail-card">
      <template #header>
        <div class="card-header">
          <span>基本信息</span>
          <div class="header-operations">
            <el-button
              v-if="orderInfo.status === 'pending'"
              type="success"
              @click="handleApprove"
            >
              审核
            </el-button>
            <el-button
              v-if="orderInfo.status === 'to_ship'"
              type="warning"
              @click="handleShip"
            >
              发货
            </el-button>
            <el-button
              v-if="['pending', 'approved'].includes(orderInfo.status)"
              type="danger"
              @click="handleCancel"
            >
              取消订单
            </el-button>
          </div>
        </div>
      </template>

      <el-descriptions :column="3" border>
        <el-descriptions-item label="订单编号">{{ orderInfo.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">
          <el-tag :type="getStatusType(orderInfo.status)">{{ getStatusText(orderInfo.status) }}</el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ orderInfo.createTime }}</el-descriptions-item>
        <el-descriptions-item label="经销商">{{ orderInfo.dealerName }}</el-descriptions-item>
        <el-descriptions-item label="客户名称">{{ orderInfo.customerName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ orderInfo.customerPhone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="3">{{ orderInfo.shippingAddress }}</el-descriptions-item>
        <el-descriptions-item label="订单金额">¥{{ orderInfo.totalAmount?.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="运费">¥{{ orderInfo.freight?.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="实付金额">¥{{ orderInfo.actualAmount?.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="3">{{ orderInfo.remark || '无' }}</el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 商品明细 -->
    <el-card class="detail-card">
      <template #header>
        <div class="card-header">
          <span>商品明细</span>
        </div>
      </template>

      <el-table :data="orderInfo.items" border style="width: 100%">
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column prop="productCode" label="商品编码" width="120" />
        <el-table-column prop="productName" label="商品名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="specification" label="规格" width="120" />
        <el-table-column prop="unit" label="单位" width="80" />
        <el-table-column prop="quantity" label="数量" width="100" />
        <el-table-column prop="deductionRule" label="扣数规则" width="120" />
        <el-table-column prop="deductionQuantity" label="扣数数量" width="100" />
        <el-table-column prop="price" label="单价" width="100">
          <template #default="{ row }">
            ¥{{ row.price?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column prop="amount" label="金额" width="100">
          <template #default="{ row }">
            ¥{{ row.amount?.toFixed(2) }}
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 发货信息 -->
    <el-card v-if="orderInfo.status === 'shipped' || orderInfo.status === 'completed'" class="detail-card">
      <template #header>
        <div class="card-header">
          <span>发货信息</span>
        </div>
      </template>

      <el-descriptions :column="2" border>
        <el-descriptions-item label="发货方式">
          {{ (orderInfo as any)?.shippingMethod === 'factory' ? '工厂代发' : '经销商自提' }}
        </el-descriptions-item>
        <el-descriptions-item label="发货时间">{{ (orderInfo as any)?.shippingTime || '' }}</el-descriptions-item>
        <template v-if="(orderInfo as any)?.shippingMethod === 'factory'">
          <el-descriptions-item label="物流公司">{{ (orderInfo as any)?.logisticsCompany || '' }}</el-descriptions-item>
          <el-descriptions-item label="物流单号">{{ (orderInfo as any)?.trackingNo || '' }}</el-descriptions-item>
        </template>
        <template v-else>
          <el-descriptions-item label="车牌号">{{ (orderInfo as any)?.plateNumber || '' }}</el-descriptions-item>
          <el-descriptions-item label="司机电话">{{ (orderInfo as any)?.driverPhone || '' }}</el-descriptions-item>
        </template>
        <el-descriptions-item label="备注" :span="2">{{ (orderInfo as any)?.shippingRemark || '无' }}</el-descriptions-item>
      </el-descriptions>
    </el-card>

    <!-- 操作记录 -->
    <el-card class="detail-card">
      <template #header>
        <div class="card-header">
          <span>操作记录</span>
        </div>
      </template>

      <el-timeline>
        <el-timeline-item
          v-for="(activity, index) in orderInfo.activities"
          :key="index"
          :type="getActivityType(activity.type)"
          :timestamp="activity.time"
        >
          {{ activity.content }}
        </el-timeline-item>
      </el-timeline>
    </el-card>

    <!-- 审核对话框 -->
    <el-dialog
      v-model="approveDialogVisible"
      title="订单审核"
      width="500px"
    >
      <el-form
        ref="approveFormRef"
        :model="approveForm"
        :rules="approveRules"
        label-width="100px"
      >
        <el-form-item label="审核结果" prop="approved">
          <el-radio-group v-model="approveForm.approved">
            <el-radio :value="true">通过</el-radio>
            <el-radio :value="false">拒绝</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="审核意见" prop="comment">
          <el-input
            v-model="approveForm.comment"
            type="textarea"
            :rows="3"
            placeholder="请输入审核意见"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="approveDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleApproveSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>

    <!-- 发货对话框 -->
    <el-dialog
      v-model="shipDialogVisible"
      title="订单发货"
      width="500px"
    >
      <el-form
        ref="shipFormRef"
        :model="shipForm"
        :rules="shipRules"
        label-width="100px"
      >
        <el-form-item label="发货方式" prop="shippingMethod">
          <el-radio-group v-model="shipForm.shippingMethod">
            <el-radio :value="'factory'">工厂代发</el-radio>
            <el-radio :value="'self'">经销商自提</el-radio>
          </el-radio-group>
        </el-form-item>
        <template v-if="shipForm.shippingMethod === 'factory'">
          <el-form-item label="物流公司" prop="logisticsCompany">
            <el-input v-model="shipForm.logisticsCompany" placeholder="请输入物流公司" />
          </el-form-item>
          <el-form-item label="物流单号" prop="trackingNo">
            <el-input v-model="shipForm.trackingNo" placeholder="请输入物流单号" />
          </el-form-item>
        </template>
        <template v-else>
          <el-form-item label="车牌号" prop="plateNumber">
            <el-input v-model="shipForm.plateNumber" placeholder="请输入车牌号" />
          </el-form-item>
          <el-form-item label="司机电话" prop="driverPhone">
            <el-input v-model="shipForm.driverPhone" placeholder="请输入司机电话" />
          </el-form-item>
        </template>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="shipForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="shipDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleShipSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'

const route = useRoute()
const router = useRouter()

// 订单信息
const orderInfo = reactive({
  orderNo: 'ORD202403200001',
  status: 'pending',
  createTime: '2024-03-20 10:00:00',
  dealerName: '经销商1',
  customerName: '张三',
  customerPhone: '13800138000',
  shippingAddress: '广东省深圳市南山区科技园',
  totalAmount: 1000.00,
  freight: 20.00,
  actualAmount: 1020.00,
  remark: '',
  items: [
    {
      productCode: 'P001',
      productName: '商品1',
      specification: '规格1',
      unit: '件',
      quantity: 2,
      deductionRule: '1:1',
      deductionQuantity: 2,
      price: 500.00,
      amount: 1000.00
    }
  ],
  activities: [
    {
      type: 'create',
      time: '2024-03-20 10:00:00',
      content: '创建订单'
    }
  ]
})

// 审核对话框
const approveDialogVisible = ref(false)
const approveFormRef = ref<FormInstance>()
const approveForm = reactive({
  approved: true,
  comment: ''
})

// 审核表单验证规则
const approveRules = reactive<FormRules>({
  approved: [
    { required: true, message: '请选择审核结果', trigger: 'change' }
  ],
  comment: [
    { required: true, message: '请输入审核意见', trigger: 'blur' }
  ]
})

// 发货对话框
const shipDialogVisible = ref(false)
const shipFormRef = ref<FormInstance>()
const shipForm = reactive({
  shippingMethod: 'factory',
  logisticsCompany: '',
  trackingNo: '',
  plateNumber: '',
  driverPhone: '',
  remark: ''
})

// 发货表单验证规则
const shipRules = reactive<FormRules>({
  shippingMethod: [
    { required: true, message: '请选择发货方式', trigger: 'change' }
  ],
  logisticsCompany: [
    { required: true, message: '请输入物流公司', trigger: 'blur' }
  ],
  trackingNo: [
    { required: true, message: '请输入物流单号', trigger: 'blur' }
  ],
  plateNumber: [
    { required: true, message: '请输入车牌号', trigger: 'blur' }
  ],
  driverPhone: [
    { required: true, message: '请输入司机电话', trigger: 'blur' }
  ]
})

// 获取状态类型
const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending: 'info',
    approved: 'success',
    to_ship: 'warning',
    shipped: 'primary',
    completed: 'success',
    cancelled: 'danger'
  }
  return typeMap[status] || 'info'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    pending: '待审核',
    approved: '已审核',
    to_ship: '待发货',
    shipped: '已发货',
    completed: '已完成',
    cancelled: '已取消'
  }
  return textMap[status] || '未知'
}

// 获取操作记录类型
const getActivityType = (type: string) => {
  const typeMap: Record<string, string> = {
    create: 'primary',
    approve: 'success',
    ship: 'warning',
    complete: 'success',
    cancel: 'danger'
  }
  return typeMap[type] || 'info'
}

// 返回上一页
const goBack = () => {
  router.back()
}

// 审核订单
const handleApprove = () => {
  approveDialogVisible.value = true
  // 重置表单
  Object.assign(approveForm, {
    approved: true,
    comment: ''
  })
}

// 提交审核
const handleApproveSubmit = async () => {
  if (!approveFormRef.value) return
  await approveFormRef.value.validate((valid) => {
    if (valid) {
      // TODO: 实现审核逻辑
      ElMessage.success('审核成功')
      approveDialogVisible.value = false
    }
  })
}

// 发货
const handleShip = () => {
  shipDialogVisible.value = true
  // 重置表单
  Object.assign(shipForm, {
    shippingMethod: 'factory',
    logisticsCompany: '',
    trackingNo: '',
    plateNumber: '',
    driverPhone: '',
    remark: ''
  })
}

// 提交发货
const handleShipSubmit = async () => {
  if (!shipFormRef.value) return
  await shipFormRef.value.validate((valid) => {
    if (valid) {
      // TODO: 实现发货逻辑
      ElMessage.success('发货成功')
      shipDialogVisible.value = false
    }
  })
}

// 取消订单
const handleCancel = () => {
  ElMessageBox.confirm(
    '确定要取消该订单吗？',
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    // TODO: 实现取消逻辑
    ElMessage.success('取消成功')
  })
}

// 获取订单详情
const getOrderDetail = async () => {
  // TODO: 根据路由参数获取订单详情
  console.log('订单ID：', route.params.id)
}

onMounted(() => {
  getOrderDetail()
})
</script>

<style scoped>
.order-detail-container {
  padding: 20px;
}

.page-header {
  margin-bottom: 20px;
}

.detail-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.header-operations {
  display: flex;
  gap: 10px;
}
</style> 