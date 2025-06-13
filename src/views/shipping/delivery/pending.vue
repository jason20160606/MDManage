<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <el-card class="search-wrapper">
      <el-form :model="queryParams" ref="queryForm" :inline="true">
        <el-form-item label="订单编号">
          <el-input v-model="queryParams.orderNo" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item label="收货人">
          <el-input v-model="queryParams.receiver" placeholder="请输入收货人" clearable />
        </el-form-item>
        <el-form-item label="发货状态">
          <el-select v-model="queryParams.status" placeholder="请选择状态" clearable>
            <el-option label="待发货" value="pending" />
            <el-option label="部分发货" value="partial" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作按钮区域 -->
    <el-card class="table-wrapper">
      <template #header>
        <div class="card-header">
          <span>待发货列表</span>
          <div class="right">
            <el-button type="primary" @click="handleBatchShip">批量发货</el-button>
            <el-button type="success" @click="handleExport">导出</el-button>
          </div>
        </div>
      </template>

      <!-- 表格区域 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        border
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="orderNo" label="订单编号" min-width="180" />
        <el-table-column prop="receiver" label="收货人" width="120" />
        <el-table-column prop="phone" label="联系电话" width="120" />
        <el-table-column prop="address" label="收货地址" min-width="200" show-overflow-tooltip />
        <el-table-column prop="goodsCount" label="商品数量" width="100" />
        <el-table-column prop="totalAmount" label="订单金额" width="120">
          <template #default="{ row }">
            ¥{{ row.totalAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="下单时间" width="160" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'pending' ? 'warning' : 'info'">
              {{ row.status === 'pending' ? '待发货' : '部分发货' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleShip(row)">发货</el-button>
            <el-button type="primary" link @click="handleDetail(row)">详情</el-button>
            <el-button type="primary" link @click="handlePrint(row)">打印</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </el-card>

    <!-- 发货对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="订单发货"
      width="800px"
      destroy-on-close
    >
      <el-form :model="shipForm" label-width="100px">
        <el-form-item label="物流公司">
          <el-select v-model="shipForm.logisticsCompany" placeholder="请选择物流公司">
            <el-option label="顺丰速运" value="SF" />
            <el-option label="中通快递" value="ZTO" />
            <el-option label="圆通速递" value="YTO" />
            <el-option label="韵达快递" value="YD" />
          </el-select>
        </el-form-item>
        <el-form-item label="物流单号">
          <el-input v-model="shipForm.trackingNo" placeholder="请输入物流单号" />
        </el-form-item>
        <el-form-item label="发货备注">
          <el-input
            v-model="shipForm.remark"
            type="textarea"
            placeholder="请输入发货备注"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="submitShip">确 定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNo: '',
  receiver: '',
  status: ''
})

// 表格数据
const loading = ref(false)
const tableData = ref([])
const total = ref(0)
const selectedRows = ref([])

// 发货表单
const dialogVisible = ref(false)
const shipForm = reactive({
  logisticsCompany: '',
  trackingNo: '',
  remark: ''
})

// 查询列表
const handleQuery = () => {
  loading.value = true
  // TODO: 调用接口获取数据
  setTimeout(() => {
    loading.value = false
  }, 1000)
}

// 重置查询
const resetQuery = () => {
  queryParams.orderNo = ''
  queryParams.receiver = ''
  queryParams.status = ''
  handleQuery()
}

// 表格选择
const handleSelectionChange = (selection: any[]) => {
  selectedRows.value = selection
}

// 批量发货
const handleBatchShip = () => {
  if (selectedRows.value.length === 0) {
    ElMessage.warning('请选择要发货的订单')
    return
  }
  dialogVisible.value = true
}

// 单个发货
const handleShip = (row: any) => {
  dialogVisible.value = true
}

// 查看详情
const handleDetail = (row: any) => {
  // TODO: 跳转到详情页
}

// 打印
const handlePrint = (row: any) => {
  // TODO: 调用打印功能
}

// 导出
const handleExport = () => {
  // TODO: 调用导出功能
}

// 提交发货
const submitShip = () => {
  // TODO: 调用发货接口
  ElMessage.success('发货成功')
  dialogVisible.value = false
  handleQuery()
}

// 分页
const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  handleQuery()
}

// 初始化
handleQuery()
</script>

<style lang="scss" scoped>
.search-wrapper {
  margin-bottom: 20px;
}

.table-wrapper {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

.dialog-footer {
  text-align: right;
}
</style>
