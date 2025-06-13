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
        <el-form-item label="物流单号">
          <el-input v-model="queryForm.trackingNo" placeholder="请输入物流单号" clearable />
        </el-form-item>
        <el-form-item label="发货时间">
          <el-date-picker
            v-model="queryForm.shipTime"
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
          <span>已发货订单列表</span>
          <div class="header-buttons">
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <el-table :data="orderList" border style="width: 100%">
        <el-table-column type="index" width="50" />
        <el-table-column prop="orderNo" label="订单编号" min-width="180" />
        <el-table-column prop="customerName" label="客户名称" min-width="120" />
        <el-table-column prop="shipTime" label="发货时间" width="160" />
        <el-table-column prop="logisticsCompany" label="物流公司" width="120" />
        <el-table-column prop="trackingNo" label="物流单号" min-width="180" />
        <el-table-column prop="status" label="物流状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getLogisticsStatusType(row.logisticsStatus)">
              {{ row.logisticsStatus }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button type="success" link @click="handleTrack(row)">物流跟踪</el-button>
            <el-button type="warning" link @click="handleComplete(row)">确认收货</el-button>
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
        <el-descriptions-item label="发货时间">{{ currentOrder.shipTime }}</el-descriptions-item>
        <el-descriptions-item label="物流状态">
          <el-tag :type="getLogisticsStatusType(currentOrder.logisticsStatus)">
            {{ currentOrder.logisticsStatus }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="物流公司">{{ currentOrder.logisticsCompany }}</el-descriptions-item>
        <el-descriptions-item label="物流单号">{{ currentOrder.trackingNo }}</el-descriptions-item>
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
    </el-dialog>

    <!-- 物流跟踪对话框 -->
    <el-dialog v-model="trackDialogVisible" title="物流跟踪" width="600px">
      <el-timeline>
        <el-timeline-item
          v-for="(activity, index) in logisticsTrack"
          :key="index"
          :type="activity.type"
          :timestamp="activity.timestamp"
        >
          {{ activity.content }}
        </el-timeline-item>
      </el-timeline>
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
  trackingNo: '',
  shipTime: []
})

// 订单列表
const orderList = ref([
  {
    orderNo: 'DD202403150001',
    customerName: '张三',
    shipTime: '2024-03-15 10:00:00',
    logisticsCompany: '顺丰快递',
    trackingNo: 'SF1234567890',
    logisticsStatus: '运输中',
    phone: '13800138000',
    address: '北京市朝阳区xxx街道',
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

// 物流跟踪对话框
const trackDialogVisible = ref(false)
const logisticsTrack = ref([
  {
    content: '快件已签收，签收人：张三',
    timestamp: '2024-03-16 15:30:00',
    type: 'success'
  },
  {
    content: '快件已到达【北京朝阳区xxx营业点】',
    timestamp: '2024-03-16 10:20:00',
    type: 'primary'
  },
  {
    content: '快件已到达【北京转运中心】',
    timestamp: '2024-03-15 20:15:00',
    type: 'primary'
  },
  {
    content: '快件已从【上海转运中心】发出',
    timestamp: '2024-03-15 15:30:00',
    type: 'primary'
  },
  {
    content: '快件已揽收',
    timestamp: '2024-03-15 10:00:00',
    type: 'primary'
  }
])

// 获取物流状态标签类型
const getLogisticsStatusType = (status: string) => {
  const statusMap: Record<string, string> = {
    '已揽收': 'info',
    '运输中': 'primary',
    '已签收': 'success',
    '异常': 'danger'
  }
  return statusMap[status] || 'info'
}

// 查询
const handleQuery = () => {
  // TODO: 调用查询接口
  console.log('查询条件：', queryForm)
}

// 重置
const handleReset = () => {
  queryForm.orderNo = ''
  queryForm.customerName = ''
  queryForm.trackingNo = ''
  queryForm.shipTime = []
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

// 物流跟踪
const handleTrack = (row: any) => {
  currentOrder.value = row
  // TODO: 调用物流跟踪接口
  trackDialogVisible.value = true
}

// 确认收货
const handleComplete = (row: any) => {
  ElMessageBox.confirm('确认该订单已收货吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // TODO: 调用确认收货接口
    ElMessage.success('确认收货成功')
  })
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

:deep(.el-descriptions) {
  margin-bottom: 20px;
}
</style> 