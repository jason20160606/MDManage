<template>
  <div class="app-container">
    <!-- 自提点（= 仓库） -->
    <el-card class="pickup-point-wrapper">
      <template #header>
        <div class="card-header">
          <span>自提点（仓库）</span>
          <span class="header-tip">自提点就是仓库，统一在「组织管理 - 工厂/仓库」维护</span>
        </div>
      </template>

      <el-alert
        type="info"
        :closable="false"
        show-icon
        title="自提点直接取仓库数据，不再单独维护。要新增或修改自提点，请到「组织管理 → 工厂/仓库」里操作。"
        style="margin-bottom: 16px;"
      />

      <el-table :data="warehouses" border style="width: 100%" v-loading="warehouseLoading">
        <el-table-column prop="Name" label="仓库（自提点）" min-width="150" show-overflow-tooltip />
        <el-table-column prop="ParentName" label="所属工厂" width="110" show-overflow-tooltip />
        <el-table-column prop="ContactPerson" label="联系人" width="100">
          <template #default="{ row }">{{ row.ContactPerson || '-' }}</template>
        </el-table-column>
        <el-table-column prop="ContactPhone" label="联系电话" width="130">
          <template #default="{ row }">{{ row.ContactPhone || '-' }}</template>
        </el-table-column>
        <el-table-column prop="Address" label="仓库地址" min-width="260" show-overflow-tooltip />
        <el-table-column label="状态" width="90">
          <template #default>
            <el-tag type="success">可自提</el-tag>
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
        <el-form-item label="订单状态">
          <el-select v-model="queryForm.status" placeholder="请选择状态" clearable style="width: 120px">
            <el-option label="待自提" :value="2" />
            <el-option label="已自提" :value="4" />
            <el-option label="已签收" :value="5" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" v-loading="listLoading" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="45" />
        <el-table-column label="订单信息" width="195">
          <template #default="{ row }">
            <div>
              <div style="font-weight:bold;">{{ row.OrderNo }}</div>
              <div style="font-size:12px;color:#888;">下单时间：{{ formatDateTime(row.OrderDate) }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="自提信息" width="200">
          <template #default="{ row }">
            <div>
              <div>经销商：{{ row.DealerName || '-' }}</div>
              <div>自提点：{{ row.WarehouseName || '-' }}</div>
              <div>司机：{{ row.DriverName || '-' }} {{ row.DriverPhone ? '（' + row.DriverPhone + '）' : '' }}</div>
              <div>车牌：{{ row.CarPlateNumber || '-' }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="160">
          <template #default="{ row }">
            <div>
              <div>{{ row.ReceiverName }}（{{ row.ReceiverPhone }}）</div>
              <div style="color: #888;">{{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品信息" min-width="150">
          <template #default="{ row }">
            <div>
              <span v-if="row.OrderItems && row.OrderItems.length">
                <span v-for="(item, idx) in row.OrderItems" :key="idx">
                  {{ item.ProductName }} ×{{ fmtQty(boxQty(item)) }}<span v-if="idx < row.OrderItems.length - 1">，</span>
                </span>
              </span>
              <span v-else>无</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="合计箱数" width="80" align="right">
          <template #default="{ row }">
            <div>{{ fmtQty(row.TotalShipQty) }}</div>
            <div style="font-size:12px;color:#909399;">已提 {{ fmtQty(row.ShippedQty) }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="Status" label="订单状态" width="85">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="Remark" label="备注" width="80" show-overflow-tooltip />
        <el-table-column label="操作" width="140">
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

    <!-- 确认自提对话框（补齐司机/车牌，自提单多数是导入来的，原单没有这些信息） -->
    <el-dialog v-model="pickupDialogVisible" title="确认自提" width="480px">
      <el-form :model="pickupForm" label-width="90px">
        <el-form-item label="经销商">{{ pickupRow?.DealerName || '-' }}</el-form-item>
        <el-form-item label="自提点">{{ pickupRow?.WarehouseName || '-' }}</el-form-item>
        <el-form-item label="收货人">
          {{ pickupRow?.ReceiverName || '-' }}
          {{ pickupRow?.ReceiverPhone ? '（' + pickupRow.ReceiverPhone + '）' : '' }}
        </el-form-item>
        <el-form-item label="合计箱数">{{ fmtQty(pickupRow?.TotalShipQty) }} 箱</el-form-item>
        <el-form-item label="司机姓名">
          <el-input v-model="pickupForm.DriverName" placeholder="请输入司机姓名" />
        </el-form-item>
        <el-form-item label="司机电话">
          <el-input v-model="pickupForm.DriverPhone" placeholder="请输入司机电话" />
        </el-form-item>
        <el-form-item label="车牌号">
          <el-input v-model="pickupForm.CarPlateNumber" placeholder="请输入车牌号，如 粤A12345" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="pickupDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="pickupSubmitting" @click="submitPickup">确认自提</el-button>
      </template>
    </el-dialog>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="orderDialogVisible" title="自提订单详情" width="900px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单号">{{ currentOrder?.OrderNo }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ formatDateTime(currentOrder?.OrderDate) }}</el-descriptions-item>
        <el-descriptions-item label="发件人">{{ currentOrder?.SenderName }}</el-descriptions-item>
        <el-descriptions-item label="经销商">{{ currentOrder?.DealerName }}</el-descriptions-item>
        <el-descriptions-item label="自提点">{{ currentOrder?.WarehouseName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">{{ getStatusText(currentOrder?.Status) }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ currentOrder?.ReceiverName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentOrder?.ReceiverPhone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="2">
          <div class="address-content">{{ currentOrder?.ReceiverAddress }}</div>
        </el-descriptions-item>
        <el-descriptions-item label="车牌号">{{ currentOrder?.CarPlateNumber || '-' }}</el-descriptions-item>
        <el-descriptions-item label="司机电话">{{ currentOrder?.DriverPhone || '-' }}</el-descriptions-item>
        <el-descriptions-item label="合计箱数">{{ fmtQty(currentOrder?.TotalShipQty) }}</el-descriptions-item>
        <el-descriptions-item label="已提箱数">{{ fmtQty(currentOrder?.ShippedQty) }}</el-descriptions-item>
        <el-descriptions-item label="备注" :span="2">
          <div class="remark-content">{{ currentOrder?.Remark || '无' }}</div>
        </el-descriptions-item>
      </el-descriptions>
      <div class="order-items">
        <h3>商品信息</h3>
        <el-table :data="currentOrder?.OrderItems || []" border>
          <el-table-column prop="ProductName" label="商品名称" />
          <el-table-column label="数量（箱）" width="120">
            <template #default="{ row }">{{ fmtQty(boxQty(row)) }}</template>
          </el-table-column>
          <el-table-column label="已提（箱）" width="120">
            <template #default="{ row }">{{ fmtQty(row.ShippedQty) }}</template>
          </el-table-column>
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { reqCheckOrder, reqShipOrder } from '@/api/order/index'
import { getSelfOrderList } from '@/api/shipping'
import { reqGetFactoryList } from '@/api/organization/factory'
import { fmtQty, boxQty } from '@/utils/orderQty'

// 自提点 = 仓库：直接取仓库数据（parent_id 非空的工厂记录）
const warehouses = ref<any[]>([])
const warehouseLoading = ref(false)

// 查询表单
const queryForm = reactive({
  orderNo: '',
  status: undefined as number | undefined
})

// 订单列表
const orderList = ref<any[]>([])
const listLoading = ref(false)

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 订单详情对话框
const orderDialogVisible = ref(false)
const currentOrder = ref<any>(null)

// 订单状态映射（自提订单走正常订单状态：2 待发货=待自提，4 已发货=已自提，5 已签收）
const getStatusText = (status?: number) => {
  const map: Record<number, string> = {
    2: '待自提',
    3: '部分自提',
    4: '已自提',
    5: '已签收',
    6: '已取消'
  }
  return status != null ? (map[status] || `状态${status}`) : '-'
}
const getStatusType = (status?: number) => {
  if (status === 2) return 'warning'
  if (status === 4) return 'primary'
  if (status === 5) return 'success'
  return 'info'
}

const formatDateTime = (dateStr?: string) => {
  if (!dateStr) return ''
  return dateStr.slice(0, 19).replace('T', ' ')
}

// 选中的订单
const selectedOrders = ref<any[]>([])
const handleSelectionChange = (selection: any[]) => {
  selectedOrders.value = selection
}

// 打印单个订单
const handlePrint = (row: any) => {
  printHtml(generatePrintContent([row]))
}
// 批量打印
const handleBatchPrint = () => {
  if (!selectedOrders.value.length) {
    ElMessage.warning('请先选择要打印的订单')
    return
  }
  printHtml(generatePrintContent(selectedOrders.value))
}
// 生成打印内容
const generatePrintContent = (orders: any[]) => {
  let html = '<div style="font-family:Arial;max-width:800px;margin:0 auto;">'
  orders.forEach(order => {
    html += `<div style='border:1px solid #ccc;padding:16px;margin-bottom:24px;'>`
    html += `<h2>订单号：${order.OrderNo}</h2>`
    html += `<div>下单时间：${formatDateTime(order.OrderDate)}</div>`
    html += `<div>经销商：${order.DealerName || '-'}</div>`
    html += `<div>自提点：${order.WarehouseName || '-'}</div>`
    html += `<div>收货人：${order.ReceiverName}（${order.ReceiverPhone}）</div>`
    html += `<div>收货地址：${order.ReceiverAddress}</div>`
    html += `<div>司机：${order.DriverName || '-'} ${order.DriverPhone ? '（' + order.DriverPhone + '）' : ''}</div>`
    html += `<div>车牌号：${order.CarPlateNumber || '-'}</div>`
    html += `<div>订单状态：${getStatusText(order.Status)}</div>`
    html += `<div>合计箱数：${fmtQty(order.TotalShipQty)}</div>`
    html += `<div>备注：${order.Remark || ''}</div>`
    html += `<h4 style='margin-top:12px;'>商品明细</h4>`
    html += `<table border='1' cellspacing='0' cellpadding='4' style='width:100%;border-collapse:collapse;'>`
    html += `<tr><th>商品名称</th><th>数量（箱）</th></tr>`
    if (order.OrderItems && order.OrderItems.length) {
      order.OrderItems.forEach((item: any) => {
        html += `<tr><td>${item.ProductName}</td><td>${fmtQty(boxQty(item))}</td></tr>`
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
  if (!win) return
  win.document.write(`<html><head><title>订单打印</title></head><body>${html}</body></html>`)
  win.document.close()
  win.print()
}

// 查询订单
const handleQuery = () => {
  currentPage.value = 1
  getPickupOrderList()
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.status = undefined
  handleQuery()
}

// 导出订单
const handleExport = () => {
  ElMessage.success('导出成功')
}

// 查看订单
const handleViewOrder = async (row: any) => {
  const res = await reqCheckOrder(row.Id || row.id)
  if (res.status === 200) {
    currentOrder.value = res.data?.Data ?? res.data
    orderDialogVisible.value = true
  } else {
    ElMessage.error('获取订单详情失败')
  }
}

// 确认自提：走发货接口，DeliveryType=1 自提
const pickupDialogVisible = ref(false)
const pickupSubmitting = ref(false)
const pickupRow = ref<any>(null)
const pickupForm = reactive({
  DriverName: '',
  DriverPhone: '',
  CarPlateNumber: ''
})

const handleConfirmPickup = (row: any) => {
  pickupRow.value = row
  pickupForm.DriverName = row.DriverName || ''
  pickupForm.DriverPhone = row.DriverPhone || ''
  pickupForm.CarPlateNumber = row.CarPlateNumber || ''
  pickupDialogVisible.value = true
}

const submitPickup = async () => {
  const row = pickupRow.value
  if (!row) return
  if (!pickupForm.CarPlateNumber.trim()) {
    ElMessage.warning('请填写车牌号，自提凭证需要它')
    return
  }
  pickupSubmitting.value = true
  try {
    const res = await reqShipOrder({
      OrderId: row.Id,
      DeliveryType: 1,
      Carrier: '自提',
      LogisticsCompany: '自提',
      TrackingNo: '',
      Remark: '客户自提确认',
      DriverName: pickupForm.DriverName.trim(),
      CarPlateNumber: pickupForm.CarPlateNumber.trim(),
      DriverPhone: pickupForm.DriverPhone.trim()
    })
    if (res && (res.Success || res.status === 200)) {
      ElMessage.success(res.Message || '确认自提成功')
      pickupDialogVisible.value = false
      getPickupOrderList()
    } else {
      ElMessage.error(res?.Message || '确认自提失败')
    }
  } catch (error) {
    console.error('确认自提失败:', error)
    ElMessage.error('确认自提失败，请重试')
  } finally {
    pickupSubmitting.value = false
  }
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
  listLoading.value = true
  try {
    const params: any = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value
    }
    if (queryForm.orderNo) params.OrderNumber = queryForm.orderNo
    if (queryForm.status) params.OrderStatus = queryForm.status

    const res = await getSelfOrderList(params)
    if (res.status === 200) {
      orderList.value = Array.isArray(res.data) ? res.data : (res.data?.records || [])
      if (res.headers && res.headers['x-pagination']) {
        const pagination = JSON.parse(res.headers['x-pagination'])
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
  } finally {
    listLoading.value = false
  }
}

// 自提点（仓库）列表
const fetchWarehouses = async () => {
  warehouseLoading.value = true
  try {
    const res = await reqGetFactoryList({ onlyWarehouse: true })
    const data = res?.data?.Data ?? res?.data ?? []
    warehouses.value = Array.isArray(data) ? data : []
  } catch (e) {
    console.error('获取仓库列表失败', e)
    warehouses.value = []
  } finally {
    warehouseLoading.value = false
  }
}

onMounted(() => {
  fetchWarehouses()
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

.header-tip {
  font-size: 12px;
  color: #909399;
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

  .el-message-box__message strong {
    font-weight: bold;
    color: #409eff;
  }
}
</style>
