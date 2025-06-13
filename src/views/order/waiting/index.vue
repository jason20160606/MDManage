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
        <el-form-item label="订单时间">
          <el-date-picker
            v-model="queryForm.orderTime"
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
          <span>待发货订单列表</span>
          <div class="header-buttons">
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <el-table :data="orderList" border style="width: 100%">
        <el-table-column type="index" width="50" />
        <el-table-column prop="orderNo" label="订单编号" min-width="180" />
        <el-table-column prop="customerName" label="客户名称" min-width="120" />
        <el-table-column prop="orderTime" label="下单时间" width="160" />
        <el-table-column prop="totalAmount" label="订单金额" width="120">
          <template #default="{ row }">
            {{ row.totalAmount }} 元
          </template>
        </el-table-column>
        <el-table-column prop="goodsCount" label="商品数量" width="100" />
        <el-table-column prop="shippingMethod" label="配送方式" width="100" />
        <el-table-column prop="status" label="订单状态" width="100">
          <template #default="{ row }">
            <el-tag type="warning">待发货</el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button type="success" link @click="handleShip(row)">发货</el-button>
            <el-button type="danger" link @click="handleCancel(row)">取消</el-button>
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

    <!-- 发货对话框 -->
    <el-dialog v-model="shipDialogVisible" title="订单发货" width="600px">
      <el-form :model="shipForm" label-width="100px">
        <el-form-item label="物流公司" required>
          <el-select v-model="shipForm.logisticsCompany" placeholder="请选择物流公司">
            <el-option
              v-for="item in logisticsCompanies"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="物流单号" required>
          <el-input v-model="shipForm.trackingNo" placeholder="请输入物流单号" />
        </el-form-item>
        <el-form-item label="发货备注">
          <el-input
            v-model="shipForm.remark"
            type="textarea"
            placeholder="请输入发货备注信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="shipDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleShipSubmit">确认发货</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="订单详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单编号">{{ currentOrder.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="客户名称">{{ currentOrder.customerName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentOrder.phone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址">{{ currentOrder.address }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ currentOrder.orderTime }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">
          <el-tag type="warning">待发货</el-tag>
        </el-descriptions-item>
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
  orderTime: []
})

// 订单列表
const orderList = ref([
  {
    orderNo: 'DD202403150001',
    customerName: '张三',
    orderTime: '2024-03-15 10:00:00',
    totalAmount: 1000,
    goodsCount: 2,
    shippingMethod: '快递配送',
    status: '待发货',
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

// 发货对话框
const shipDialogVisible = ref(false)
const shipForm = reactive({
  logisticsCompany: '',
  trackingNo: '',
  remark: ''
})

// 物流公司列表
const logisticsCompanies = ref([
  { id: 1, name: '顺丰快递' },
  { id: 2, name: '中通快递' },
  { id: 3, name: '圆通快递' }
])

// 订单详情对话框
const detailDialogVisible = ref(false)
const currentOrder = ref<any>({})

// 查询
const handleQuery = () => {
  // TODO: 调用查询接口
  console.log('查询条件：', queryForm)
}

// 重置
const handleReset = () => {
  queryForm.orderNo = ''
  queryForm.customerName = ''
  queryForm.orderTime = []
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

// 发货
const handleShip = (row: any) => {
  currentOrder.value = row
  shipDialogVisible.value = true
}

// 提交发货
const handleShipSubmit = () => {
  if (!shipForm.logisticsCompany || !shipForm.trackingNo) {
    ElMessage.warning('请填写必填项')
    return
  }

  // TODO: 调用发货接口
  ElMessage.success('发货成功')
  shipDialogVisible.value = false
}

// 取消订单
const handleCancel = (row: any) => {
  ElMessageBox.confirm('确认取消该订单吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // TODO: 调用取消接口
    ElMessage.success('取消成功')
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