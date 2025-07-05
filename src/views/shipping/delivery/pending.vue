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
            <el-option label="待发货" value="0" />
            <el-option label="部分发货" value="2" />
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
        row-key="Id"
      >
        <el-table-column type="selection" width="55" />
        <el-table-column prop="OrderNo" label="订单编号" min-width="180" />
        <el-table-column prop="SenderName" label="发件人" width="120" />
        <el-table-column label="收件人信息" min-width="220">
          <template #default="{ row }">
            <div class="receiver-info">
              <div>收货人：{{ row.ReceiverName }}</div>
              <div>电话：{{ row.ReceiverPhone }}</div>
              <div>地址：{{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品信息" min-width="200">
          <template #default="{ row }">
            <div class="product-list">
              <div v-for="(item, idx) in row.OrderItems || []" :key="idx" class="product-item">
                {{ item.ProductName }} × {{ item.Quantity }}
              </div>
              <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">暂无产品信息</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="TotalAmount" label="订单总额" width="120">
          <template #default="{ row }">
            {{ row.TotalAmount }}
          </template>
        </el-table-column>
        <el-table-column prop="OrderDate" label="下单时间" width="160" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === '0' ? 'warning' : 'info'">
              {{ row.status === '0' ? '待发货' : '部分发货' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleShip">发货</el-button>
            <el-button type="primary" link @click="handleDetail(row)">详情</el-button>
            <el-button type="primary" link @click="handlePrint(row)">打印</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="queryParams.pageNum"
          v-model:page-size="queryParams.pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 发货对话框 -->
    <el-dialog
      v-model="dialogVisible"
      title="订单发货"
      width="600px"
      destroy-on-close
    >
      <!-- 分组标题：物流信息 -->
      <el-divider content-position="left">物流信息</el-divider>
      <el-form :model="shipForm" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="12">
            <el-form-item label="物流公司">
              <el-select v-model="shipForm.logisticsCompany" placeholder="请选择物流公司" style="width: 100%">
                <el-option label="顺丰速运" value="SF" />
                <el-option label="中通快递" value="ZTO" />
                <el-option label="圆通速递" value="YTO" />
                <el-option label="韵达快递" value="YD" />
              </el-select>
            </el-form-item>
          </el-col>
          <el-col :span="12">
            <el-form-item label="物流单号">
              <el-input v-model="shipForm.trackingNo" placeholder="请输入物流单号" />
            </el-form-item>
          </el-col>
        </el-row>
        <!-- 分组标题：备注信息 -->
        <el-divider content-position="left">备注信息</el-divider>
        <el-form-item label="发货备注">
          <el-input
            v-model="shipForm.remark"
            type="textarea"
            :rows="3"
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { reqOrderlist } from '@/api/order'

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
const tableData = ref<any[]>([])
const total = ref(0)
const selectedRows = ref([])

// 发货表单
const dialogVisible = ref(false)
const shipForm = reactive({
  logisticsCompany: '',
  trackingNo: '',
  remark: ''
})

// 获取订单列表数据
const getOrderList = async () => {
  loading.value = true
  try {
    // 只查状态为0（待发货）的订单，直接传递Status参数
    const res = await reqOrderlist({ OrderStatus: 2 })
    console.log('API返回数据:', res)
    if (res.status === 200 && Array.isArray(res.data)) {
      // 直接使用后端返回的已过滤数据
      let filteredData = res.data;

      // 其他本地筛选
      if (queryParams.orderNo) {
        filteredData = filteredData.filter((order: any) => 
          order.OrderNo.toLowerCase().includes(queryParams.orderNo.toLowerCase())
        );
      }
      if (queryParams.receiver) {
        filteredData = filteredData.filter((order: any) => 
          order.receiverName.toLowerCase().includes(queryParams.receiver.toLowerCase())
        );
      }
      // 状态筛选已由后端完成，无需本地再筛选
      // 分页处理
      const startIndex = (queryParams.pageNum - 1) * queryParams.pageSize;
      const endIndex = startIndex + queryParams.pageSize;
      tableData.value = filteredData.slice(startIndex, endIndex);
      total.value = filteredData.length; // 更新总数
      ElMessage.success('获取待发货订单列表成功');
    } else {
      tableData.value = [];
      total.value = 0;
      ElMessage.error(res.message || '获取订单列表失败');
    }
  } catch (error) {
    console.error('获取订单列表出错：', error);
    tableData.value = [];
    total.value = 0;
    ElMessage.error('获取订单列表失败');
  } finally {
    loading.value = false;
  }
}

// 查询列表
const handleQuery = () => {
  queryParams.pageNum = 1; // 查询时重置页码到第一页
  getOrderList();
}

// 重置查询
const resetQuery = () => {
  queryParams.orderNo = '';
  queryParams.receiver = '';
  queryParams.status = '';
  queryParams.pageNum = 1; // 重置时也重置页码
  getOrderList();
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
const handleShip = () => {
  dialogVisible.value = true
}

// 查看详情
const handleDetail = (row: any) => {
  // TODO: 跳转到详情页
  ElMessage.info(`查看订单详情：${row.OrderNo}`);
}

// 打印
const handlePrint = (row: any) => {
  // TODO: 调用打印功能
  ElMessage.info(`打印订单：${row.OrderNo}`);
}

// 导出
const handleExport = () => {
  // TODO: 调用导出功能
  ElMessage.success('导出成功')
}

// 提交发货
const submitShip = () => {
  // TODO: 调用发货接口
  ElMessage.success('发货成功')
  dialogVisible.value = false
  handleQuery() // 发货成功后刷新列表
}

// 分页
const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  getOrderList()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  getOrderList()
}

// 初始化
onMounted(() => {
  getOrderList()
})
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

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.el-dialog {
  .el-form {
    margin-top: 10px;
    .el-form-item {
      margin-bottom: 18px;
    }
  }
}

.dialog-footer {
  text-align: right;
  padding: 10px 0 0 0;
}
</style>
