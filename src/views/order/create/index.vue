<template>
  <div class="app-container">
    <!-- 订单列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>订单管理</span>
          <div class="header-actions">
            <el-button type="success" @click="handleImport">导入订单</el-button>
            <el-button type="primary" @click="addOrder">
              新增订单
            </el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单编号" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="经销商名称">
          <el-input v-model="queryForm.dealerName" placeholder="请输入经销商名称" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="收货人姓名">
          <el-input v-model="queryForm.receiverName" placeholder="请输入收货人姓名" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="收货人电话">
          <el-input v-model="queryForm.receiverPhone" placeholder="请输入收货人电话" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="快递类型">
          <el-select v-model="queryForm.deliveryType" placeholder="请选择快递类型" clearable style="width: 120px;">
            <el-option label="自提" :value="1" />
            <el-option label="到付" :value="2" />
            <el-option label="现付" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker
            v-model="queryForm.dateRange"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            style="width: 240px;"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" v-loading="loading">
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column label="订单信息" min-width="200">
          <template #default="{ row }">
            <div class="order-info">
              <div class="order-no">订单编号:{{ row.OrderNo }}</div>
              <div class="order-date">下单时间: {{ formatDateTime(row.CreatedAt) }}</div>
              <div class="order-status">
                <el-tag :type="getOrderStatusType(row.Status)">
                  {{ getOrderStatusText(row.Status) }}
                </el-tag>
                <el-tag :type="getDeliveryTypeTag(row.DeliveryType)" style="margin-left: 8px;">
                  {{ getDeliveryTypeText(row.DeliveryType) }}
                </el-tag>
              </div>              
            </div>
          </template>
        </el-table-column>
        <el-table-column label="经销商信息" min-width="180">
          <template #default="{ row }">
            <div class="dealer-info">
              <div class="dealer-name">姓名:{{ row.DealerName }}</div>
              <div class="dealer-contact">联系人: {{ row.ContactPerson }}</div>
              <div class="dealer-phone">电话: {{ row.ContactPhone }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="180">
          <template #default="{ row }">
            <div class="receiver-info">
              <div class="receiver-name">姓名:{{ row.ReceiverName }}</div>    
              <div class="receiver-phone">电话: {{ row.ReceiverPhone }}</div>          
              <div class="receiver-address">地址: {{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="产品信息" min-width="200">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-list">
                <div v-for="(item, index) in row.OrderItems || []" :key="index" class="product-item">
                  <span class="product-name">{{ item.productName || '未知产品' }}</span>
                  <span class="product-quantity">×{{ item.quantity || 0 }}</span>
                </div>
                <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                <span class="total-count">共 {{ row.OrderItems.length || 0 }} 种产品</span>
                <span class="total-amount">合计: {{ row.TotalAmount }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="订单总额" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ row.TotalAmount }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="editOrder(row)">编辑</el-button>
            <el-button type="info" link @click="viewOrder(row)">查看</el-button>
            <el-button type="success" link @click="confirmOrder(row)" v-if="row.Status === 1">审核</el-button>
            <el-button type="warning" link @click="cancelOrder(row)" v-if="[1, 2].includes(row.Status)">取消</el-button>
            <el-button type="danger" link @click="deleteOrder(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPageNo"
          v-model:page-size="pageSizeNo"
          :page-sizes="[10, 20, 50, 100]"
          :background="background"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        />
      </div>
    </el-card>

    <!-- 订单编辑对话框 -->
    <OrderForm ref="orderFormRef" v-show="scene === 1" @change-scene="changeScene"></OrderForm>

    <!-- 订单查看对话框 -->
    <OrderView ref="orderViewRef" v-show="scene === 2" @change-scene="changeScene"></OrderView>

    <!-- 导入订单对话框 -->
    <el-dialog v-model="importDialogVisible" title="导入订单" width="500px">
      <el-form :model="importForm" label-width="100px">
        <el-form-item label="选择文件" required>
          <el-upload
            ref="uploadRef"
            :auto-upload="false"
            :on-change="handleFileChange"
            :before-upload="beforeFileUpload"
            accept=".xlsx,.xls,.csv"
            :limit="1"
            :file-list="fileList"
          >
            <el-button type="primary">选择文件</el-button>
            <template #tip>
              <div class="el-upload__tip">
                支持 .xlsx、.xls、.csv 格式，文件大小不超过 10MB
              </div>
            </template>
          </el-upload>
        </el-form-item>
        
        <el-form-item label="模板下载">
          <el-button type="info" link @click="downloadTemplate">
            <el-icon><Download /></el-icon>
            下载导入模板
          </el-button>
        </el-form-item>
        
        <el-form-item v-if="importResult" label="导入结果">
          <div class="import-result">
            <div class="result-item">
              <span class="label">成功：</span>
              <span class="success">{{ importResult.success }} 条</span>
            </div>
            <div class="result-item">
              <span class="label">失败：</span>
              <span class="error">{{ importResult.failed }} 条</span>
            </div>
            <div v-if="importResult.errors && importResult.errors.length > 0" class="error-list">
              <div v-for="(error, index) in importResult.errors" :key="index" class="error-item">
                {{ error }}
              </div>
            </div>
          </div>
        </el-form-item>
      </el-form>
      
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="importDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitImport" :loading="importing">开始导入</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download } from '@element-plus/icons-vue'
import OrderForm from './orderForm.vue'
import OrderView from './orderView.vue'
import { reqOrderlist, reqConfirmOrder, reqCancelOrder, reqDeleteOrder, reqImportOrders } from '@/api/order'

// 场景值：0-数据展示，1-订单编辑，2-订单查看
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  orderNo: '',
  dealerName: '',
  receiverName: '',
  receiverPhone: '',
  deliveryType: '',
  dateRange: []
})

// 订单列表
const orderList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)
const background = ref(true)

// 导入相关
const importDialogVisible = ref(false)
const importForm = reactive({})
const fileList = ref<any[]>([])
const importing = ref(false)
const importResult = ref<any>(null)

// 获取子组件实例
const orderFormRef = ref()
const orderViewRef = ref()
const uploadRef = ref()

// 查询订单列表
const handleQuery = async () => {
  loading.value = true
  try {
    // 构建查询参数
    const params = {
      page: currentPageNo.value,
      pageSize: pageSizeNo.value,
      orderNo: queryForm.orderNo || undefined,
      dealerName: queryForm.dealerName || undefined,
      receiverName: queryForm.receiverName || undefined,
      receiverPhone: queryForm.receiverPhone || undefined,
      deliveryType: queryForm.deliveryType || undefined,
      startDate: queryForm.dateRange && queryForm.dateRange.length > 0 ? queryForm.dateRange[0] : undefined,
      endDate: queryForm.dateRange && queryForm.dateRange.length > 1 ? queryForm.dateRange[1] : undefined
    }

    const result = await reqOrderlist(params)
    
    if (result.status === 200) {
      orderList.value = result.data || []
      console.log(result)
      total.value = result.data.total || 0
    } else {
      orderList.value = []
      total.value = 0
      ElMessage.error(result.message || '获取订单列表失败')
    }
  } catch (error) {
    ElMessage.error('获取订单列表失败')
    console.error('订单查询错误:', error)
    orderList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.dealerName = ''
  queryForm.receiverName = ''
  queryForm.receiverPhone = ''
  queryForm.deliveryType = ''
  queryForm.dateRange = []
  currentPageNo.value = 1
  handleQuery()
}

// 新增订单 - 切换到编辑场景，隐藏列表
const addOrder = () => {
  scene.value = 1
  nextTick(() => {
    orderFormRef.value?.initForm()
  })
}

// 编辑订单 - 切换到编辑场景，隐藏列表
const editOrder = (row: any) => {
  scene.value = 1
  nextTick(() => {
    orderFormRef.value?.initForm(row)
  })
}

// 查看订单 - 切换到查看场景，隐藏列表
const viewOrder = (row: any) => {
  scene.value = 2
  nextTick(() => {
    orderViewRef.value?.initView(row)
  })
}

// 导入订单
const handleImport = () => {
  importDialogVisible.value = true
  importResult.value = null
  fileList.value = []
}

// 文件选择变化
const handleFileChange = (file: any) => {
  fileList.value = [file]
}

// 文件上传前验证
const beforeFileUpload = (file: any) => {
  const isValidType = ['application/vnd.openxmlformats-officedocument.spreadsheetml.sheet', 'application/vnd.ms-excel', 'text/csv'].includes(file.type)
  const isLt10M = file.size / 1024 / 1024 < 10

  if (!isValidType) {
    ElMessage.error('只能上传 Excel 或 CSV 文件!')
    return false
  }
  if (!isLt10M) {
    ElMessage.error('文件大小不能超过 10MB!')
    return false
  }
  return true
}

// 下载模板
const downloadTemplate = () => {
  // TODO: 下载导入模板
  ElMessage.success('模板下载成功')
}

// 提交导入
const submitImport = async () => {
  if (fileList.value.length === 0) {
    ElMessage.warning('请选择要导入的文件')
    return
  }

  importing.value = true
  try {
    const formData = new FormData()
    formData.append('file', fileList.value[0].raw)
    const result = await reqImportOrders(formData)
    if (result.code === 200) {
      importResult.value = result.data
      ElMessage.success('导入完成')
    } else {
      ElMessage.error(result.message || '导入失败')
    }
  } catch (error) {
    ElMessage.error('导入失败')
    console.error('导入错误:', error)
  } finally {
    importing.value = false
  }
}

// 确认订单
const confirmOrder = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要确认订单"${row.orderNo}"吗？`,
      '确认订单',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    const result = await reqConfirmOrder(row.id)
    if (result.code === 200) {
      ElMessage.success('订单确认成功')
      handleQuery()
    } else {
      ElMessage.error(result.message || '订单确认失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('订单确认失败')
    }
  }
}

// 取消订单
const cancelOrder = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要取消订单"${row.orderNo}"吗？`,
      '取消订单',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    const result = await reqCancelOrder(row.id)
    if (result.code === 200) {
      ElMessage.success('订单取消成功')
      handleQuery()
    } else {
      ElMessage.error(result.message || '订单取消失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('订单取消失败')
    }
  }
}

// 删除订单
const deleteOrder = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除订单"${row.orderNo}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    const result = await reqDeleteOrder(row.id)
    if (result.code === 200) {
      ElMessage.success('删除成功')
      handleQuery()
    } else {
      ElMessage.error(result.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 子组件自定义事件 - 切换场景
const changeScene = (num: number) => {
  scene.value = num
  if (num === 0) {
    handleQuery()
  }
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
  currentPageNo.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSizeNo.value = size
  currentPageNo.value = 1
  handleQuery()
}

// 获取订单状态类型
const getOrderStatusType = (status: number) => {
  const statusMap: Record<number, string> = {
    1: 'info',      // 待审核
    2: 'success',   // 已审核
    3: 'warning',   // 已发货
    4: 'success',   // 已完成
    5: 'danger'     // 已取消
  }
  return statusMap[status] || 'info'
}

// 获取订单状态文本
const getOrderStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    1: '待审核',
    2: '已审核',
    3: '已发货',
    4: '已完成',
    5: '已取消'
  }
  return statusMap[status] || '未知'
}

// 获取快递类型标签
const getDeliveryTypeTag = (type: number) => {
  const typeMap: Record<number, string> = {
    1: 'success',   // 自提
    2: 'warning',   // 到付
    3: 'info'       // 现付
  }
  return typeMap[type] || 'info'
}

// 获取快递类型文本
const getDeliveryTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    1: '自提',
    2: '到付',
    3: '现付'
  }
  return typeMap[type] || '未知'
}

// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 初始化
onMounted(() => {
  handleQuery()
})
</script>

<style lang="scss" scoped>
.app-container {
  padding: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  margin-bottom: 20px;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.order-info {
  .order-no {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  
  .order-date {
    font-size: 12px;
    color: #909399;
    margin-bottom: 4px;
  }
  
  .order-status {
    margin-top: 4px;
  }
}

.dealer-info {
  .dealer-name {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  
  .dealer-contact,
  .dealer-phone {
    font-size: 12px;
    color: #606266;
    margin-bottom: 2px;
  }
}

.receiver-info {
  .receiver-name {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  
  .receiver-phone,
  .receiver-address {
    font-size: 12px;
    color: #606266;
    margin-bottom: 2px;
  }
}

.product-info {
  .product-list {
    margin-bottom: 6px;
  }
  
  .product-item {
    display: block;
    margin-bottom: 2px;
    line-height: 1.4;
  }
  
  .product-name {
    font-size: 12px;
    color: #303133;
    font-weight: 500;
  }
  
  .product-quantity {
    font-size: 12px;
    color: #409eff;
    font-weight: bold;
    margin-left: 4px;
  }
  
  .no-products {
    font-size: 12px;
    color: #909399;
    font-style: italic;
  }
  
  .product-summary {
    margin-top: 6px;
    padding-top: 4px;
    border-top: 1px solid #f0f0f0;
  }
  
  .total-count {
    font-size: 11px;
    color: #606266;
    margin-right: 8px;
  }
  
  .total-amount {
    font-size: 11px;
    color: #f56c6c;
    font-weight: bold;
  }
}

.amount-info {
  .amount {
    font-size: 16px;
    font-weight: bold;
    color: #f56c6c;
  }
}

.header-actions {
  display: flex;
  gap: 10px;
}

.import-result {
  .result-item {
    margin-bottom: 8px;
    
    .label {
      font-weight: bold;
      margin-right: 8px;
    }
    
    .success {
      color: #67c23a;
      font-weight: bold;
    }
    
    .error {
      color: #f56c6c;
      font-weight: bold;
    }
  }
  
  .error-list {
    margin-top: 10px;
    padding: 10px;
    background-color: #fef0f0;
    border-radius: 4px;
    
    .error-item {
      color: #f56c6c;
      font-size: 12px;
      margin-bottom: 4px;
      
      &:last-child {
        margin-bottom: 0;
      }
    }
  }
}
</style>
