<template>
  <div class="app-container">
    <!-- 自提点管理 -->
    <el-card class="pickup-point-wrapper">
      <template #header>
        <div class="card-header">
          <span>自提点管理</span>
          <el-button type="primary" @click="handleAddPickupPoint">新增自提点</el-button>
        </div>
      </template>

      <el-table :data="pickupPoints" border style="width: 100%">
        <el-table-column prop="Code" label="自提点编码"/>
        <el-table-column prop="Name" label="自提点名称"/>
        <el-table-column prop="ContactName" label="联系人"/>
        <el-table-column prop="ContactPhone" label="联系电话"/>
        <el-table-column prop="Address" label="地址" show-overflow-tooltip width="320" />
        <el-table-column prop="Remark" label="备注"/>
        <el-table-column prop="IsEnabled" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.IsEnabled ? 'success' : 'info'">
              {{ row.IsEnabled ? '营业中' : '已关闭' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEditPickupPoint(row)">编辑</el-button>
            <el-button type="primary" link @click="handleToggleStatus(row)">
              {{ row.IsEnabled ? '关闭' : '开启' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 自提订单管理 -->
    <el-card class="order-wrapper">
      <template #header>
        <div class="card-header">
          <span>自提订单管理</span>
          <div class="header-operations">
            <el-button type="primary" @click="handleExport">导出订单</el-button>
            <el-button type="success" @click="handleBatchPrint" style="margin-left: 10px;">批量打印</el-button>            
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单号" clearable />
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker
            v-model="queryForm.orderTime"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          />
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select v-model="queryForm.status" placeholder="请选择状态" clearable style="width: 120px">
            <el-option label="待自提" value="pending" />
            <el-option label="已自提" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column label="订单信息" width="280">
          <template #default="{ row }">
            <div>
              <div style="font-weight:bold;">{{ row.OrderNo }}</div>
              <div style="font-size:12px;color:#888;">下单时间：{{ row.OrderDate ? row.OrderDate.slice(0, 19).replace('T', ' ') : '' }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" width="320">
          <template #default="{ row }">
            <div>
              <div>{{ row.ReceiverName }}（{{ row.ReceiverPhone }}）</div>
              <div style="color: #888;">{{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="自提信息" width="260">
          <template #default="{ row }">
            <div>
              <div>经销商：{{ row.DealerName || '-' }}</div>             
              <div>司机信息：{{ row.DriverName || '-' }} {{ row.DriverPhone ? '（' + row.DriverPhone + '）' : '' }}</div>
              <div>车牌信息：{{ row.CarPlateNumber || '-' }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品信息" min-width="200">
          <template #default="{ row }">
            <div>
              <span v-if="row.OrderItems && row.OrderItems.length">
                <span v-for="(item, idx) in row.OrderItems" :key="idx">
                  {{ item.ProductName }} ×{{ item.Quantity }}<span v-if="idx < row.OrderItems.length - 1">，</span>
                </span>
              </span>
              <span v-else>无</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="Status" label="订单状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="TotalAmount" label="订单总额" width="100" />
        <el-table-column prop="Remark" label="备注" width="120" />
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleViewOrder(row)">查看</el-button>
            <el-button v-if="row.Status === 2" type="primary" link @click="handleConfirmPickup(row)">确认自提</el-button>
            <el-button type="success" link @click="handlePrint(row)">打印</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        />
      </div>
    </el-card>

    <!-- 自提点编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增自提点' : '编辑自提点'"
      width="500px"
    >
      <el-form :model="pickupPointForm" label-width="100px">
        <el-form-item label="自提点编码" required>
          <el-input v-model="pickupPointForm.Code" placeholder="请输入自提点编码" />
        </el-form-item>
        <el-form-item label="自提点名称" required>
          <el-input v-model="pickupPointForm.Name" placeholder="请输入自提点名称" />
        </el-form-item>
        <el-form-item label="地址" required>
          <el-input v-model="pickupPointForm.Address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="联系人" required>
          <el-input v-model="pickupPointForm.ContactName" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="pickupPointForm.ContactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="pickupPointForm.Remark" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="pickupPointForm.IsEnabled"
            :active-value="true"
            :inactive-value="false"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="handleSavePickupPoint">确 定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="orderDialogVisible" title="订单详情" width="900px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单号">{{ currentOrder?.OrderNo }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ currentOrder?.OrderDate ? currentOrder.OrderDate.slice(0, 19).replace('T', ' ') : '' }}</el-descriptions-item>
        <el-descriptions-item label="发件人">{{ currentOrder?.SenderName }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ currentOrder?.ReceiverName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentOrder?.ReceiverPhone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="2">
          <div class="address-content">{{ currentOrder?.ReceiverAddress }}</div>
        </el-descriptions-item>
        <el-descriptions-item label="车牌号">{{ currentOrder?.CarPlateNumber }}</el-descriptions-item>
        <el-descriptions-item label="司机电话">{{ currentOrder?.DriverPhone }}</el-descriptions-item>        
        <el-descriptions-item label="订单状态">{{ getStatusText(currentOrder?.Status) }}</el-descriptions-item>
        <el-descriptions-item label="订单总额">{{ currentOrder?.TotalAmount }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">
          <div class="remark-content">{{ currentOrder?.Remark || '无' }}</div>
        </el-descriptions-item>
      </el-descriptions>
      <div class="order-items">
        <h3>商品信息</h3>
        <el-table :data="currentOrder?.OrderItemDetails || []" border>
          <el-table-column prop="ProductName" label="商品名称" />          
          <el-table-column prop="Quantity" label="数量" />          
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqCheckOrder, reqShipOrder } from '@/api/order/index'
import { getPickupPoints, addPickupPoint, updatePickupPoint, updatePickupPointEnable, getSelfOrderList } from '@/api/shipping'

// 自提点列表
const pickupPoints = ref<any[]>([])

// 查询表单
const queryForm = reactive({
  orderNo: '',
  pickupPoint: '',
  status: '',
  orderTime: []
})

// 订单列表
const orderList = ref<any[]>([])

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const pickupPointForm = reactive({
  Id: undefined,
  Code: '',
  Name: '',
  Address: '',
  ContactName: '',
  ContactPhone: '',
  Remark: '',
  IsEnabled: true
})

// 订单详情对话框
const orderDialogVisible = ref(false)
const currentOrder = ref(null)

// 订单状态映射
const statusMap = {
  2: '待自提',
  3: '已自提',
  5: '已签收',
  6: '已取消'
}
const getStatusText = (status: number) => statusMap[status] || status
const getStatusType = (status: number) => {
  if (status === 1) return 'warning'
  if (status === 2) return 'success'
  if (status === 3) return 'info'
  return 'info'
}

// 选中的订单
const selectedOrders = ref<any[]>([])
const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}
// 打印单个订单
const handlePrint = (row: any) => {
  const printContent = generatePrintContent([row])
  printHtml(printContent)
}
// 批量打印
const handleBatchPrint = () => {
  if (!selectedOrders.value.length) {
    ElMessage.warning('请先选择要打印的订单')
    return
  }
  const printContent = generatePrintContent(selectedOrders.value)
  printHtml(printContent)
}
// 生成打印内容
const generatePrintContent = (orders: any[]) => {
  let html = '<div style="font-family:Arial;max-width:800px;margin:0 auto;">'
  orders.forEach(order => {
    html += `<div style='border:1px solid #ccc;padding:16px;margin-bottom:24px;'>`
    html += `<h2>订单号：${order.OrderNo}</h2>`
    html += `<div>下单时间：${order.OrderDate ? order.OrderDate.slice(0,19).replace('T',' ') : ''}</div>`
    html += `<div>收货人：${order.ReceiverName}（${order.ReceiverPhone}）</div>`
    html += `<div>收货地址：${order.ReceiverAddress}</div>`
    html += `<div>自提点：${order.Name}（${order.Code}）</div>`
    html += `<div>司机：${order.ContactName || '-'} ${order.ContactPhone ? '（' + order.ContactPhone + '）' : ''}</div>`
    html += `<div>订单状态：${getStatusText(order.Status)}</div>`
    html += `<div>订单总额：${order.TotalAmount}</div>`
    html += `<div>备注：${order.Remark || ''}</div>`
    html += `<h4 style='margin-top:12px;'>商品明细</h4>`
    html += `<table border='1' cellspacing='0' cellpadding='4' style='width:100%;border-collapse:collapse;'>`
    html += `<tr><th>商品名称</th><th>数量</th></tr>`
    if (order.OrderItems && order.OrderItems.length) {
      order.OrderItems.forEach(item => {
        html += `<tr><td>${item.ProductName}</td><td>${item.Quantity}</td></tr>`
      })
    } else {
      html += `<tr><td colspan='2'>无</td></tr>`
    }
    html += `</table>`
    html += `</div>`
  })
  html += '</div>'
  return html
}
// 打印HTML内容
const printHtml = (html: string) => {
  const win = window.open('', '_blank')
  win.document.write(`<html><head><title>订单打印</title></head><body>${html}</body></html>`)
  win.document.close()
  win.print()
}

// 查询订单
const handleQuery = () => {
  getPickupOrderList()
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.pickupPoint = ''
  queryForm.status = ''
  queryForm.orderTime = []
}

// 导出订单
const handleExport = () => {
  // TODO: 调用导出接口
  ElMessage.success('导出成功')
}

// 新增自提点
const handleAddPickupPoint = () => {
  dialogType.value = 'add'
  Object.assign(pickupPointForm, {
    Id: undefined,
    Code: '',
    Name: '',
    Address: '',
    ContactName: '',
    ContactPhone: '',
    Remark: '',
    IsEnabled: true
  })
  dialogVisible.value = true
}

// 编辑自提点
const handleEditPickupPoint = (row: any) => {
  dialogType.value = 'edit'
  Object.assign(pickupPointForm, {
    Id: row.Id,
    Code: row.Code,
    Name: row.Name,
    Address: row.Address,
    ContactName: row.ContactName,
    ContactPhone: row.ContactPhone,
    Remark: row.Remark,
    IsEnabled: row.IsEnabled
  })
  dialogVisible.value = true
}

// 切换自提点状态
const handleToggleStatus = async (row: any) => {
  const action = row.IsEnabled ? '关闭' : '开启'
  // 直接切换状态，无需确认弹窗
  const res = await updatePickupPointEnable(row.Id, !row.IsEnabled)
  if (res && res.Success) {
    ElMessage.success(res.Message || `${action}成功`)
    fetchPickupPoints()
  } else {
    ElMessage.error((res && res.Message) || `${action}失败`)
  }
}

// 保存自提点
const handleSavePickupPoint = async () => {
  if (!pickupPointForm.Name || !pickupPointForm.Address || !pickupPointForm.ContactName || !pickupPointForm.ContactPhone) {
    ElMessage.warning('请填写必填项')
    return
  }
  let res
  if (dialogType.value === 'add') {
    res = await addPickupPoint(pickupPointForm)
  } else {
    res = await updatePickupPoint(pickupPointForm)
  }
  if (res && (res.status === 200 || res.status === 201 || res.Success)) {
    ElMessage.success(dialogType.value === 'add' ? '新增成功' : '修改成功')
    dialogVisible.value = false
    fetchPickupPoints()
  } else {
    ElMessage.error((res && res.Message) || '操作失败')
  }
}

// 查看订单
const handleViewOrder = async (row: any) => {
  // 根据id查询订单详情
  const res = await reqCheckOrder(row.Id || row.id)
  if (res.status === 200) {
    currentOrder.value = res.data
    orderDialogVisible.value = true
  } else {
    ElMessage.error('获取订单详情失败')
  }
}

// 确认自提
const handleConfirmPickup = (row: any) => {
  // 构建确认信息，包含经销商、司机和车牌信息
  const confirmMessage = `
确认该订单已完成自提吗？<br><br>
经销商姓名：${row.DealerName || '--'}<br>
收件人姓名：${row.ReceiverName || '--'}<br>
发货总数：${row.TotalAmount || '--'}<br>
司机姓名：${row.DriverName || '--'}<br>
司机电话：${row.DriverPhone || '--'}<br>
司机车牌号：<strong>${row.CarPlateNumber || '--'}</strong><br><br>
请确认以上信息无误后点击确定。
  `.trim()

  ElMessageBox.confirm(confirmMessage, '确认自提', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning',
    dangerouslyUseHTMLString: true,
    customClass: 'confirm-pickup-dialog'
  }).then(async () => {
    try {
      // 调用发货接口进行自提确认
      const shipData = {
        OrderId: row.Id,
        DeliveryType: 1, // 自提类型
        LogisticsCompany: '自提', // 自提方式
        TrackingNo: '', // 自提单号
        Remark: '客户自提确认',
        // 自提相关信息
        DriverName: row.DriverName || '',
        CarPlateNumber: row.CarPlateNumber || '',
        DriverPhone: row.DriverPhone || ''
      }
      
      const res = await reqShipOrder(shipData)
      if (res && (res.Success || res.status === 200)) {
        ElMessage.success(res.Message || '确认自提成功')
        getPickupOrderList() // 刷新列表
      } else {
        ElMessage.error(res.Message || '确认自提失败')
      }
    } catch (error) {
      console.error('确认自提失败:', error)
      ElMessage.error('确认自提失败，请重试')
    }
  }).catch(() => {
    // 用户取消操作
  })
}

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val
  getPickupOrderList()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  getPickupOrderList()
}

const getPickupOrderList = async () => {
  try {
    const params = {
      ...queryForm,
      PageNumber: currentPage.value,
      PageSize: pageSize.value
    }
    const res = await getSelfOrderList(params)
    if (res.status === 200) {
      orderList.value = res.data.records || res.data
      if (res.headers && res.headers['x-pagination']) {
        const pagination = JSON.parse(res.headers['x-pagination'])
        currentPage.value = pagination.PageIndex || 1
        pageSize.value = pagination.PageSize || 10
        total.value = pagination.TotalCount || 0
      } else {
        total.value = orderList.value.length
      }
    } else {
      ElMessage.error('获取自提订单列表失败')
    }
  } catch (error) {
    console.error('请求自提订单列表出错:', error)
    ElMessage.error('请求自提订单列表出错')
  }
}

// 页面加载时获取自提点列表
const fetchPickupPoints = async () => {
  const res = await getPickupPoints()
  if (res.status === 200) {
    pickupPoints.value = res.data
  }
}

onMounted(() => {
  fetchPickupPoints()
  getPickupOrderList()
})
</script>

<style lang="scss" scoped>
.pickup-point-wrapper,
.order-wrapper {
  margin-bottom: 20px;
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

.order-items {
  margin-top: 20px;
  h3 {
    margin-bottom: 20px;
    font-weight: normal;
    color: #666;
  }
}

// 订单详情对话框样式
:deep(.address-content),
:deep(.remark-content) {
  word-break: break-all;
  word-wrap: break-word;
  white-space: pre-wrap;
  line-height: 1.5;
  max-height: 80px;
  overflow-y: auto;
  padding: 4px 0;
}

:deep(.address-content) {
  color: #333;
  font-weight: 500;
}

:deep(.remark-content) {
  color: #666;
  font-style: italic;
}

// 确认自提弹窗样式
:deep(.confirm-pickup-dialog) {
  .el-message-box__message {
    line-height: 1.8 !important;
    font-size: 14px;
    text-align: left;
    word-break: break-all;
  }
  
  .el-message-box__message p {
    margin: 8px 0;
  }
  
  // 车牌号加粗样式
  .el-message-box__message strong {
    font-weight: bold;
    color: #409eff;
  }
}
</style>
