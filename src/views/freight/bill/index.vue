<template>
  <div class="app-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="statistics-cards">
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>本月运费总额</span>
              <el-tag type="success">实时</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">¥{{ statistics.monthTotal }}</span>
            <div class="trend">
              <span :class="statistics.monthTrend >= 0 ? 'up' : 'down'">
                {{ statistics.monthTrend >= 0 ? '+' : '' }}{{ statistics.monthTrend }}%
              </span>
              较上月
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>待结算运费</span>
              <el-tag type="warning">待处理</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">¥{{ statistics.pendingTotal }}</span>
            <div class="trend">
              <span>{{ statistics.pendingCount }}笔</span>
              待结算
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>已结算运费</span>
              <el-tag type="success">已处理</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">¥{{ statistics.settledTotal }}</span>
            <div class="trend">
              <span>{{ statistics.settledCount }}笔</span>
              已结算
            </div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>运费订单数</span>
              <el-tag type="info">总计</el-tag>
            </div>
          </template>
          <div class="card-content">
            <span class="amount">{{ statistics.totalOrders }}</span>
            <div class="trend">
              <span>{{ statistics.todayOrders }}笔</span>
              今日新增
            </div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 搜索表单 -->
    <el-card class="search-card">
      <el-form :model="queryForm" :inline="true" class="search-form">
        <el-form-item label="账单编号">
          <el-input v-model="queryForm.billNo" placeholder="请输入账单编号" clearable />
        </el-form-item>
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item label="结算状态">
          <el-select v-model="queryForm.status" placeholder="请选择结算状态" clearable>
            <el-option label="待结算" value="pending" />
            <el-option label="已结算" value="settled" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item label="结算时间">
          <el-date-picker
            v-model="queryForm.settleTime"
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

    <!-- 账单列表 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>运费账单列表</span>
          <div class="header-buttons">
            <el-button type="primary" @click="handleExport">导出账单</el-button>
            <el-button type="success" @click="handleBatchSettle">批量结算</el-button>
          </div>
        </div>
      </template>

      <el-table
        v-loading="loading"
        :data="billList"
        border
        style="width: 100%"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column type="index" width="50" />
        <el-table-column prop="billNo" label="账单编号" min-width="180" />
        <el-table-column prop="orderNo" label="订单编号" min-width="180" />
        <el-table-column prop="amount" label="运费金额" width="120">
          <template #default="{ row }">
            ¥{{ row.amount }}
          </template>
        </el-table-column>
        <el-table-column prop="shippingMethod" label="配送方式" width="100" />
        <el-table-column prop="createTime" label="创建时间" width="160" />
        <el-table-column prop="settleTime" label="结算时间" width="160" />
        <el-table-column prop="status" label="结算状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button
              v-if="row.status === 'pending'"
              type="success"
              link
              @click="handleSettle(row)"
            >
              结算
            </el-button>
            <el-button
              v-if="row.status === 'pending'"
              type="danger"
              link
              @click="handleCancel(row)"
            >
              取消
            </el-button>
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

    <!-- 账单详情对话框 -->
    <el-dialog v-model="detailDialogVisible" title="账单详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="账单编号">{{ currentBill.billNo }}</el-descriptions-item>
        <el-descriptions-item label="订单编号">{{ currentBill.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="运费金额">¥{{ currentBill.amount }}</el-descriptions-item>
        <el-descriptions-item label="配送方式">{{ currentBill.shippingMethod }}</el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ currentBill.createTime }}</el-descriptions-item>
        <el-descriptions-item label="结算时间">{{ currentBill.settleTime }}</el-descriptions-item>
        <el-descriptions-item label="结算状态">
          <el-tag :type="getStatusType(currentBill.status)">
            {{ getStatusText(currentBill.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentBill.remark || '无' }}</el-descriptions-item>
      </el-descriptions>

      <div class="shipping-info">
        <h3>配送信息</h3>
        <el-descriptions :column="2" border>
          <el-descriptions-item label="收货人">{{ currentBill.receiver }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentBill.phone }}</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ currentBill.address }}</el-descriptions-item>
          <el-descriptions-item label="物流公司">{{ currentBill.logisticsCompany }}</el-descriptions-item>
          <el-descriptions-item label="物流单号">{{ currentBill.trackingNo }}</el-descriptions-item>
        </el-descriptions>
      </div>
    </el-dialog>

    <!-- 结算对话框 -->
    <el-dialog v-model="settleDialogVisible" title="运费结算" width="500px">
      <el-form :model="settleForm" label-width="100px">
        <el-form-item label="结算金额">
          <span class="settle-amount">¥{{ currentBill.amount }}</span>
        </el-form-item>
        <el-form-item label="结算方式" required>
          <el-select v-model="settleForm.method" placeholder="请选择结算方式">
            <el-option label="银行转账" value="bank" />
            <el-option label="支付宝" value="alipay" />
            <el-option label="微信支付" value="wechat" />
          </el-select>
        </el-form-item>
        <el-form-item label="结算账号" required>
          <el-input v-model="settleForm.account" placeholder="请输入结算账号" />
        </el-form-item>
        <el-form-item label="结算备注">
          <el-input
            v-model="settleForm.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入结算备注"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="settleDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSettleSubmit">确认结算</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'

// 统计数据
const statistics = reactive({
  monthTotal: 12580.00,
  monthTrend: 12.5,
  pendingTotal: 3580.00,
  pendingCount: 15,
  settledTotal: 9000.00,
  settledCount: 45,
  totalOrders: 60,
  todayOrders: 5
})

// 查询表单
const queryForm = reactive({
  billNo: '',
  orderNo: '',
  status: '',
  settleTime: []
})

// 账单列表
const loading = ref(false)
const billList = ref([
  {
    billNo: 'FY202403150001',
    orderNo: 'DD202403150001',
    amount: 100.00,
    shippingMethod: '快递配送',
    createTime: '2024-03-15 10:00:00',
    settleTime: '',
    status: 'pending',
    remark: '',
    receiver: '张三',
    phone: '13800138000',
    address: '北京市朝阳区xxx街道',
    logisticsCompany: '顺丰速运',
    trackingNo: 'SF1234567890'
  }
])

// 分页
const page = ref(1)
const pageSize = ref(10)
const total = ref(100)

// 账单详情对话框
const detailDialogVisible = ref(false)
const currentBill = ref<any>({})

// 结算对话框
const settleDialogVisible = ref(false)
const settleForm = reactive({
  method: '',
  account: '',
  remark: ''
})

// 选中的账单
const selectedBills = ref<any[]>([])

// 获取状态类型
const getStatusType = (status: string) => {
  const typeMap: Record<string, string> = {
    pending: 'warning',
    settled: 'success',
    cancelled: 'info'
  }
  return typeMap[status] || 'info'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const textMap: Record<string, string> = {
    pending: '待结算',
    settled: '已结算',
    cancelled: '已取消'
  }
  return textMap[status] || '未知'
}

// 查询
const handleQuery = () => {
  // TODO: 调用查询接口
  console.log('查询条件：', queryForm)
}

// 重置
const handleReset = () => {
  queryForm.billNo = ''
  queryForm.orderNo = ''
  queryForm.status = ''
  queryForm.settleTime = []
}

// 导出
const handleExport = () => {
  // TODO: 调用导出接口
  ElMessage.success('导出成功')
}

// 查看账单
const handleView = (row: any) => {
  currentBill.value = row
  detailDialogVisible.value = true
}

// 结算
const handleSettle = (row: any) => {
  currentBill.value = row
  settleForm.method = ''
  settleForm.account = ''
  settleForm.remark = ''
  settleDialogVisible.value = true
}

// 提交结算
const handleSettleSubmit = () => {
  if (!settleForm.method) {
    ElMessage.warning('请选择结算方式')
    return
  }
  if (!settleForm.account) {
    ElMessage.warning('请输入结算账号')
    return
  }

  // TODO: 调用结算接口
  ElMessage.success('结算成功')
  settleDialogVisible.value = false
  handleQuery()
}

// 取消账单
const handleCancel = (row: any) => {
  ElMessageBox.confirm(
    '确定要取消该运费账单吗？',
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    // TODO: 调用取消接口
    ElMessage.success('取消成功')
    handleQuery()
  })
}

// 批量结算
const handleBatchSettle = () => {
  if (selectedBills.value.length === 0) {
    ElMessage.warning('请选择要结算的账单')
    return
  }

  // TODO: 调用批量结算接口
  ElMessage.success('批量结算成功')
  handleQuery()
}

// 选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedBills.value = selection
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
.statistics-cards {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.card-content {
  text-align: center;

  .amount {
    font-size: 24px;
    font-weight: bold;
    color: #303133;
  }

  .trend {
    margin-top: 10px;
    font-size: 14px;
    color: #909399;

    .up {
      color: #67c23a;
    }

    .down {
      color: #f56c6c;
    }
  }
}

.search-card {
  margin-bottom: 20px;
}

.search-form {
  display: flex;
  flex-wrap: wrap;
  gap: 10px;
}

.table-card {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.shipping-info {
  margin-top: 20px;

  h3 {
    margin-bottom: 15px;
  }
}

.settle-amount {
  font-size: 20px;
  font-weight: bold;
  color: #f56c6c;
}

:deep(.el-descriptions) {
  margin-bottom: 20px;
}
</style> 