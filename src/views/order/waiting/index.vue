<template>
  <div class="app-container">
    <!-- 待发货订单列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>待发货订单管理</span>
          <div class="header-actions">
            <el-button type="success" :disabled="selectedOrders.length < 2" @click="handleBatchShip">批量发货</el-button>
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="订单编号">
          <el-input v-model="queryForm.OrderNo" placeholder="请输入订单编号" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="经销商名称">
          <el-input v-model="queryForm.DealerName" placeholder="请输入经销商名称" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="收货人姓名">
          <el-input v-model="queryForm.ReceiverName" placeholder="请输入收货人姓名" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="收货人电话">
          <el-input v-model="queryForm.ReceiverPhone" placeholder="请输入收货人电话" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="订单日期">
          <el-date-picker v-model="queryForm.DateRange" type="daterange" range-separator="至" start-placeholder="开始日期" end-placeholder="结束日期" style="width: 240px;" />
        </el-form-item>
        <el-form-item label="订单总额区间">
          <el-input v-model="queryForm.TotalAmountMin" placeholder="最小金额" style="width: 100px;" clearable />
          <span style="margin: 0 8px;">-</span>
          <el-input v-model="queryForm.TotalAmountMax" placeholder="最大金额" style="width: 100px;" clearable />
        </el-form-item>
        <el-form-item label="快递类型">
          <el-select v-model="queryForm.DeliveryType" placeholder="请选择快递类型" clearable style="width: 120px;">
            <el-option label="自提" :value="1" />
            <el-option label="到付" :value="2" />
            <el-option label="现付" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" v-loading="loading" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column label="订单信息" min-width="240">
          <template #default="{ row }">
            <div class="order-info">
              <div class="order-no">{{ row.OrderNo }}</div>
              <div class="order-date">
                订单日期:
                {{ row.OrderDate && row.OrderDate !== '0001-01-01T00:00:00' ? formatDate(row.OrderDate) : '--' }}
              </div>
              <div class="order-status">
                <el-tag type="warning">待发货</el-tag>
                <el-tag style="margin-left: 8px;" :type="'info'">{{ getDeliveryTypeText(row.DeliveryType) }}</el-tag>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="经销商信息" min-width="180">
          <template #default="{ row }">
            <div class="dealer-info">
              <div class="dealer-name">{{ row.DealerName }}</div>
              <div class="dealer-sendname">发件人: {{ row.SenderName }}</div>              
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="180">
          <template #default="{ row }">
            <div class="receiver-info">
              <div class="receiver-name">{{ row.ReceiverName }}</div>
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
                  <span class="product-name">{{ item.ProductName || '未知产品' }}</span>
                  <span class="product-quantity">×{{ item.Quantity || 0 }}</span>
                </div>
                <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                <span class="total-count">共 {{ row.OrderItems?.length || 0 }} 种产品</span>
                <span class="total-amount">合计: {{ formatPrice(row.TotalAmount) }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="订单差价" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ row.TotalAmount }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="260" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleShip(row)">发货</el-button>
            <el-button type="info" link @click="viewOrder(row)">查看</el-button>
            <el-button type="warning" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleCancel(row)">取消</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :background="background"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        />
      </div>
    </el-card>

    <!-- 发货表单 -->
    <shipForm ref="shipFormRef" v-show="scene === 1" @change-scene="changeScene"></shipForm>

    <!-- 订单查看对话框 -->
    <orderView ref="orderViewRef" v-show="scene === 2" @change-scene="changeScene"></orderView>

    <!-- 编辑收货信息弹窗 -->
    <el-dialog v-model="editDialogVisible" title="编辑收货信息" width="500px" :close-on-click-modal="false">
      <el-form :model="editForm" ref="editFormRef" label-width="100px" style="padding: 10px 0;">
        <el-form-item label="收货人姓名">
          <el-input v-model="editForm.ReceiverName" placeholder="请输入收货人姓名" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="收货人电话">
          <el-input v-model="editForm.ReceiverPhone" placeholder="请输入收货人电话" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="收货地址">
          <el-input v-model="editForm.ReceiverAddress" placeholder="请输入收货地址" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="司机姓名" v-if="editForm.DeliveryType == 1">
          <el-input v-model="editForm.DriverName" placeholder="请输入司机姓名" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="车牌号" v-if="editForm.DeliveryType == 1">
          <el-input v-model="editForm.CarPlateNumber" placeholder="请输入车牌号" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="司机电话" v-if="editForm.DeliveryType == 1">
          <el-input v-model="editForm.DriverPhone" placeholder="请输入司机电话" style="width: 100%;" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveEdit">保存</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import shipForm from './shipForm.vue'
import orderView from './orderView.vue'
import { reqOrderlist, reqUpdateOrderAddress } from '@/api/order'

// 场景值：0-数据展示，1-发货编辑，2-订单查看
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  OrderNo: '',
  DealerName: '',
  ReceiverName: '',
  ReceiverPhone: '',
  DeliveryType: '',
  DateRange: [],
  TotalAmountMin: '',
  TotalAmountMax: ''
})

// 订单列表
const orderList = ref<any[]>([])
const loading = ref(false)

// 选中的订单
const selectedOrders = ref<any[]>([])

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 获取子组件实例
const shipFormRef = ref()
const orderViewRef = ref()

// 编辑收货信息弹窗相关
const editDialogVisible = ref(false)
const editForm = reactive({
  Id: '', // 订单ID
  ReceiverName: '',
  ReceiverPhone: '',
  ReceiverAddress: '',
  DriverName: '', // 司机姓名
  CarPlateNumber: '', // 车牌号
  DriverPhone: '', // 司机电话
  DeliveryType: 0, // 订单类型，用于判断是否自提，number类型
  Remark: ''
})
const editFormRef = ref()
// 新增：保存原始数据
const editFormOrigin = reactive({
  ReceiverName: '',
  ReceiverPhone: '',
  ReceiverAddress: '',
  DriverName: '',
  CarPlateNumber: '',
  DriverPhone: '',
  DeliveryType: 0, // number类型
  Remark: ''
})

// 发货表单相关
const shipOrderInfo = ref<any>(null) // 当前发货订单详情

// 获取快递类型文本
const getDeliveryTypeText = (type: number) => {
  const typeMap: Record<number, string> = {
    1: '自提',
    2: '到付',
    3: '现付'
  }
  return typeMap[type] || '未知'
}

// 查询订单列表
const handleQuery = async () => {
  loading.value = true
  try {
    const params = {
      OrderStatus: 2,
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNo: queryForm.OrderNo || undefined,
      DealerName: queryForm.DealerName || undefined,
      ReceiverName: queryForm.ReceiverName || undefined,
      ReceiverPhone: queryForm.ReceiverPhone || undefined,
      DeliveryType: queryForm.DeliveryType || undefined,
      StartDate: queryForm.DateRange && queryForm.DateRange.length > 0 ? queryForm.DateRange[0] : undefined,
      EndDate: queryForm.DateRange && queryForm.DateRange.length > 1 ? queryForm.DateRange[1] : undefined,
      AmountMin: queryForm.TotalAmountMin || undefined,
      AmountMax: queryForm.TotalAmountMax || undefined
    }
    const result = await reqOrderlist(params)
    if (result && (result.success || result.status === 200)) {
      orderList.value = result.data || []
      if (result.headers && result.headers['x-pagination']) {
        const pagination = JSON.parse(result.headers['x-pagination'])
        currentPage.value = pagination.PageIndex || 1
        pageSize.value = pagination.PageSize || 10
        total.value = pagination.TotalCount || 0
      } else {
        total.value = orderList.value.length
      }
    } else {
      orderList.value = []
      total.value = 0
      ElMessage.error(result.message || '获取待发货订单列表失败')
    }
    loading.value = false
  } catch (error) {
    ElMessage.error('获取待发货订单列表失败')
    console.error('订单查询错误:', error)
    orderList.value = []
    total.value = 0
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.OrderNo = ''
  queryForm.DealerName = ''
  queryForm.ReceiverName = ''
  queryForm.ReceiverPhone = ''
  queryForm.DeliveryType = ''
  queryForm.DateRange = []
  queryForm.TotalAmountMin = ''
  queryForm.TotalAmountMax = ''
  currentPage.value = 1
  handleQuery()
}

// 处理选择变化
const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}

// 单个发货
const handleShip = (row: any) => {
  // 直接传页面已有数据
  shipOrderInfo.value = row
  scene.value = 1
  nextTick(() => {
    shipFormRef.value?.initForm([shipOrderInfo.value])
  })
}

// 批量发货
const handleBatchShip = () => {
  if (selectedOrders.value.length === 0) {
    ElMessage.warning('请选择要发货的订单')
    return
  }
  // 直接传页面选中数据
  scene.value = 1
  nextTick(() => {
    shipFormRef.value?.initForm(selectedOrders.value)
  })
}

// 查看订单
const viewOrder = (row: any) => {
  scene.value = 2
  nextTick(() => {
    orderViewRef.value?.initView(row)
  })
}

// 取消订单
const handleCancel = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要取消订单"${row.OrderNo}"吗？`,
      '取消订单',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    // TODO: 调用取消订单API
    ElMessage.success('订单取消成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('订单取消失败')
    }
  }
}

// 导出订单
const handleExport = () => {
  if (selectedOrders.value.length === 0) {
    ElMessage.warning('请选择要导出的订单')
    return
  }
  
  // TODO: 调用导出API
  ElMessage.success('导出成功')
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
  currentPage.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1
  handleQuery()
}
const formatDate = (dateStr: string) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',    
  })
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

// 格式化价格
const formatPrice = (price: number) => {
  if (!price) return '0.00'
  return price.toFixed(2)
}

// 打开编辑弹窗，只允许编辑收货信息
const handleEdit = (row: any) => {
  editForm.Id = row.Id
  editForm.ReceiverName = row.ReceiverName
  editForm.ReceiverPhone = row.ReceiverPhone
  editForm.ReceiverAddress = row.ReceiverAddress
  editForm.DriverName = row.DriverName
  editForm.CarPlateNumber = row.CarPlateNumber
  editForm.DriverPhone = row.DriverPhone
  editForm.DeliveryType = Number(row.DeliveryType)
  editForm.Remark = row.Remark
  // 记录原始数据
  editFormOrigin.ReceiverName = row.ReceiverName
  editFormOrigin.ReceiverPhone = row.ReceiverPhone
  editFormOrigin.ReceiverAddress = row.ReceiverAddress
  editFormOrigin.DriverName = row.DriverName
  editFormOrigin.CarPlateNumber = row.CarPlateNumber
  editFormOrigin.DriverPhone = row.DriverPhone
  editFormOrigin.DeliveryType = Number(row.DeliveryType)
  editFormOrigin.Remark = row.Remark
  editDialogVisible.value = true
}

// 保存收货信息
const saveEdit = async () => {
  // 判断是否有变动（自提订单需对比司机信息）
  const isNoChange =
    editForm.ReceiverName === editFormOrigin.ReceiverName &&
    editForm.ReceiverPhone === editFormOrigin.ReceiverPhone &&
    editForm.ReceiverAddress === editFormOrigin.ReceiverAddress &&
    (editForm.DeliveryType != 1 || (
      editForm.DriverName === editFormOrigin.DriverName &&
      editForm.CarPlateNumber === editFormOrigin.CarPlateNumber &&
      editForm.DriverPhone === editFormOrigin.DriverPhone
    ))
  if (isNoChange) {
    ElMessage.info('未做任何修改')
    editDialogVisible.value = false
    return
  }
  try {
    // 调用专用修改地址API
    await reqUpdateOrderAddress(editForm.Id, {
      ReceiverName: editForm.ReceiverName,
      ReceiverPhone: editForm.ReceiverPhone,
      ReceiverAddress: editForm.ReceiverAddress,
      Remark: editForm.Remark,
      ...(editForm.DeliveryType == 1 ? {
        DriverName: editForm.DriverName,
        CarPlateNumber: editForm.CarPlateNumber,
        DriverPhone: editForm.DriverPhone
      } : {})
    })
    ElMessage.success('收货信息修改成功')
    editDialogVisible.value = false
    handleQuery()
  } catch (e) {
    ElMessage.error('收货信息修改失败')
  }
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

.header-actions {
  display: flex;
  gap: 10px;
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
  
  .dealer-sendname {
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
</style> 