<template>
  <div class="app-container">
    <!-- 搜索表单 -->
    <el-card class="search-card">
      <el-form :model="queryForm" :inline="true" class="search-form">
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item label="客户名称">
          <el-input v-model="queryForm.customerName" placeholder="请输入客户名称" clearable />
        </el-form-item>
        <el-form-item label="完成时间">
          <el-date-picker
            v-model="queryForm.completeTime"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="handleReset">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 订单列表 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>已完成订单列表</span>
          <div class="header-buttons">
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <el-table :data="orderList" border style="width: 100%">
        <el-table-column type="index" width="50" />
        <el-table-column prop="orderNo" label="订单编号" min-width="180" />
        <el-table-column prop="customerName" label="客户名称" min-width="120" />
        <el-table-column prop="completeTime" label="完成时间" width="160" />
        <el-table-column prop="totalAmount" label="订单金额" width="120">
          <template #default="{ row }">
            {{ row.totalAmount }} 元
          </template>
        </el-table-column>
        <el-table-column prop="goodsCount" label="商品数量" width="100" />
        <el-table-column prop="shippingMethod" label="配送方式" width="100" />
        <el-table-column prop="evaluation" label="评价状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.evaluation ? 'success' : 'info'">
              {{ row.evaluation ? '已评价' : '未评价' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button type="success" link @click="handleEvaluation(row)">评价</el-button>
            <el-button type="warning" link @click="handleRefund(row)">退款</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="page"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="订单详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单编号">{{ currentOrder.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="客户名称">{{ currentOrder.customerName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentOrder.phone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址">{{ currentOrder.address }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ currentOrder.orderTime }}</el-descriptions-item>
        <el-descriptions-item label="完成时间">{{ currentOrder.completeTime }}</el-descriptions-item>
        <el-descriptions-item label="配送方式">{{ currentOrder.shippingMethod }}</el-descriptions-item>
        <el-descriptions-item label="订单金额">{{ currentOrder.totalAmount }} 元</el-descriptions-item>
      </el-descriptions>

      <div class="goods-list">
        <h3>商品信息</h3>
        <el-table :data="currentOrder.goods" border style="width: 100%">
          <el-table-column type="index" width="50" />
          <el-table-column prop="name" label="商品名称" min-width="200" />
          <el-table-column prop="spec" label="规格" width="120" />
          <el-table-column prop="unit" label="单位" width="80" />
          <el-table-column prop="quantity" label="数量" width="100" />
          <el-table-column prop="price" label="单价" width="120">
            <template #default="{ row }">
              {{ row.price }} 元
            </template>
          </el-table-column>
          <el-table-column prop="amount" label="金额" width="120">
            <template #default="{ row }">
              {{ row.amount }} 元
            </template>
          </el-table-column>
        </el-table>
      </div>

      <div v-if="currentOrder.evaluation" class="evaluation-info">
        <h3>评价信息</h3>
        <el-descriptions :column="1" border>
          <el-descriptions-item label="评分">
            <el-rate v-model="currentOrder.evaluation.rating" disabled />
          </el-descriptions-item>
          <el-descriptions-item label="评价内容">
            {{ currentOrder.evaluation.content }}
          </el-descriptions-item>
          <el-descriptions-item label="评价时间">
            {{ currentOrder.evaluation.time }}
          </el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>

    <!-- 评价对话框 -->
    <el-dialog v-model="evaluationDialogVisible" title="订单评价" width="500px">
      <el-form :model="evaluationForm" label-width="80px">
        <el-form-item label="评分" required>
          <el-rate v-model="evaluationForm.rating" />
        </el-form-item>
        <el-form-item label="评价内容" required>
          <el-input
            v-model="evaluationForm.content"
            type="textarea"
            :rows="4"
            placeholder="请输入评价内容"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="evaluationDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleEvaluationSubmit">提交评价</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 退款对话框 -->
    <el-dialog v-model="refundDialogVisible" title="申请退款" width="500px">
      <el-form :model="refundForm" label-width="100px">
        <el-form-item label="退款金额" required>
          <el-input-number
            v-model="refundForm.amount"
            :min="0"
            :max="currentOrder.totalAmount"
            :precision="2"
          />
        </el-form-item>
        <el-form-item label="退款原因" required>
          <el-select v-model="refundForm.reason" placeholder="请选择退款原因">
            <el-option label="商品质量问题" value="quality" />
            <el-option label="商品与描述不符" value="description" />
            <el-option label="商品损坏" value="damage" />
            <el-option label="其他原因" value="other" />
          </el-select>
        </el-form-item>
        <el-form-item label="退款说明">
          <el-input
            v-model="refundForm.description"
            type="textarea"
            :rows="4"
            placeholder="请输入退款说明"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="refundDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleRefundSubmit">提交申请</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// 查询表单
const queryForm = reactive({
  orderNo: '',
  customerName: '',
  completeTime: []
})

// 订单列表
const orderList = ref([
  {
    orderNo: 'DD202403150001',
    customerName: '张三',
    completeTime: '2024-03-15 10:00:00',
    totalAmount: 1000,
    goodsCount: 2,
    shippingMethod: '快递配送',
    evaluation: {
      rating: 5,
      content: '商品质量很好，物流速度快，服务态度好。',
      time: '2024-03-16 15:30:00'
    },
    phone: '13800138000',
    address: '北京市朝阳区xxx街道',
    orderTime: '2024-03-15 10:00:00',
    goods: [
      {
        name: '商品1',
        spec: '规格1',
        unit: '个',
        quantity: 1,
        price: 500,
        amount: 500
      },
      {
        name: '商品2',
        spec: '规格2',
        unit: '个',
        quantity: 1,
        price: 500,
        amount: 500
      }
    ]
  }
])

// 分页
const page = ref(1)
const pageSize = ref(10)
const total = ref(100)

// 订单详情对话框
const detailDialogVisible = ref(false)
const currentOrder = ref<any>({})

// 评价对话框
const evaluationDialogVisible = ref(false)
const evaluationForm = reactive({
  rating: 5,
  content: ''
})

// 退款对话框
const refundDialogVisible = ref(false)
const refundForm = reactive({
  amount: 0,
  reason: '',
  description: ''
})

// 查询
const handleQuery = () => {
  // TODO: 调用查询接口
  console.log('查询条件：', queryForm)
}

// 重置
const handleReset = () => {
  queryForm.orderNo = ''
  queryForm.customerName = ''
  queryForm.completeTime = []
}

// 导出
const handleExport = () => {
  // TODO: 调用导出接口
  ElMessage.success('导出成功')
}

// 查看订单
const handleView = (row: any) => {
  currentOrder.value = row
  detailDialogVisible.value = true
}

// 评价
const handleEvaluation = (row: any) => {
  if (row.evaluation) {
    ElMessage.warning('该订单已评价')
    return
  }
  currentOrder.value = row
  evaluationDialogVisible.value = true
}

// 提交评价
const handleEvaluationSubmit = () => {
  if (!evaluationForm.content) {
    ElMessage.warning('请输入评价内容')
    return
  }

  // TODO: 调用评价接口
  ElMessage.success('评价成功')
  evaluationDialogVisible.value = false
}

// 退款
const handleRefund = (row: any) => {
  currentOrder.value = row
  refundForm.amount = row.totalAmount
  refundDialogVisible.value = true
}

// 提交退款
const handleRefundSubmit = () => {
  if (!refundForm.reason) {
    ElMessage.warning('请选择退款原因')
    return
  }

  // TODO: 调用退款接口
  ElMessage.success('退款申请已提交')
  refundDialogVisible.value = false
}

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  page.value = val
  handleQuery()
}
</script>

<style lang="scss" scoped>
.search-card {
  margin-bottom: 20px;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.goods-list {
  margin-top: 20px;

  h3 {
    margin-bottom: 15px;
  }
}

.evaluation-info {
  margin-top: 20px;

  h3 {
    margin-bottom: 15px;
  }
}

:deep(.el-descriptions) {
  margin-bottom: 20px;
}
</style> 