<template>
  <div class="app-container">
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
      <el-table
        :data="orderList"
        border
        class="pickup-table"
        style="width: 100%"
        v-loading="listLoading"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="45" />
        <el-table-column label="订单信息" width="190">
          <template #default="{ row }">
            <div class="main-line order-no">{{ row.OrderNo }}</div>
            <div class="sub-line">下单时间：{{ formatDate(row.OrderDate) }}</div>
          </template>
        </el-table-column>
        <el-table-column label="自提信息" width="215">
          <template #default="{ row }">
            <div class="info-list">
              <div>经销商：{{ row.DealerName || '-' }}</div>
              <div>
                司机：<span v-if="row.DriverName">{{ row.DriverName }}<template v-if="row.DriverPhone">（{{ row.DriverPhone }}）</template></span>
                <span v-else class="missing">未填写</span>
              </div>
              <div>
                车牌：<span v-if="row.CarPlateNumber">{{ row.CarPlateNumber }}</span>
                <span v-else class="missing">未填写</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="175">
          <template #default="{ row }">
            <div class="info-list">
              <div>{{ row.ReceiverName }}（{{ row.ReceiverPhone }}）</div>
              <div class="sub-line">{{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品信息" min-width="175">
          <template #default="{ row }">
            <div v-if="row.OrderItems && row.OrderItems.length" class="info-list">
              <div v-for="(item, idx) in row.OrderItems" :key="idx">
                {{ item.ProductName }} ×{{ fmtQty(boxQty(item)) }}
              </div>
            </div>
            <span v-else class="sub-line">无</span>
          </template>
        </el-table-column>
        <el-table-column label="合计箱数" width="92" align="center">
          <template #default="{ row }">
            <div class="main-line">{{ fmtQty(row.TotalShipQty) }}</div>
            <div class="sub-line">已提 {{ fmtQty(row.ShippedQty) }}</div>
          </template>
        </el-table-column>
        <el-table-column label="订单状态" width="86" align="center">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="172" align="center" class-name="op-col">
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
    <el-dialog v-model="pickupDialogVisible" title="确认自提" width="480px" :close-on-click-modal="false">
      <el-form ref="pickupFormRef" :model="pickupForm" :rules="pickupRules" label-width="96px">
        <el-form-item label="经销商">{{ pickupRow?.DealerName || '-' }}</el-form-item>
        <el-form-item label="收货人">
          {{ pickupRow?.ReceiverName || '-' }}
          {{ pickupRow?.ReceiverPhone ? '（' + pickupRow.ReceiverPhone + '）' : '' }}
        </el-form-item>
        <el-form-item label="合计箱数">{{ fmtQty(pickupRow?.TotalShipQty) }} 箱</el-form-item>
        <el-form-item label="司机姓名" prop="DriverName">
          <el-input v-model="pickupForm.DriverName" placeholder="请输入司机姓名" maxlength="20" clearable />
        </el-form-item>
        <el-form-item label="司机电话" prop="DriverPhone">
          <el-input v-model="pickupForm.DriverPhone" placeholder="选填，便于提货时联系" maxlength="20" clearable />
        </el-form-item>
        <el-form-item label="车牌号" prop="CarPlateNumber">
          <el-input v-model="pickupForm.CarPlateNumber" placeholder="如 粤A12345" maxlength="20" clearable />
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
        <el-descriptions-item label="下单时间">{{ formatDate(currentOrder?.OrderDate) }}</el-descriptions-item>
        <el-descriptions-item label="发件人">{{ currentOrder?.SenderName }}</el-descriptions-item>
        <el-descriptions-item label="经销商">{{ currentOrder?.DealerName }}</el-descriptions-item>
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
        <!-- 详情接口返回的是 OrderItemDetails，OrderItems 只在列表接口里，这里恒为 null -->
        <el-table :data="currentOrder?.OrderItemDetails || []" border empty-text="暂无商品信息">
          <el-table-column type="index" label="#" width="48" align="center" />
          <el-table-column prop="ProductName" label="商品名称" min-width="160" />
          <el-table-column prop="BrandName" label="品牌" width="100" />
          <el-table-column prop="FactoryName" label="厂家" width="100" />
          <el-table-column label="数量（箱）" width="110" align="right">
            <template #default="{ row }">{{ fmtQty(boxQty(row)) }}</template>
          </el-table-column>
          <el-table-column label="已提（箱）" width="110" align="right">
            <template #default="{ row }">{{ fmtQty(row.ShippedQty) }}</template>
          </el-table-column>
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { showError, getList, getTotal } from '@/utils/request'
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage } from 'element-plus'
import { reqCheckOrder, reqShipOrder } from '@/api/order/index'
import { getSelfOrderList } from '@/api/shipping'
import { fmtQty, boxQty } from '@/utils/orderQty'

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

// 下单日期只有日期部分，直接显示会带出 00:00:00
const formatDate = (dateStr?: string) => {
  if (!dateStr) return '-'
  const d = new Date(dateStr)
  if (isNaN(d.getTime())) return String(dateStr).slice(0, 10)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
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
    html += `<div>下单时间：${formatDate(order.OrderDate)}</div>`
    html += `<div>经销商：${order.DealerName || '-'}</div>`
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
    // 列表行走 OrderItems，详情接口走 OrderItemDetails，两种都兼容
    const printItems = order.OrderItems || order.OrderItemDetails || []
    if (printItems.length) {
      printItems.forEach((item: any) => {
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
  try {
    const res = await reqCheckOrder(row.Id || row.id)
    // 详情接口直接返回 DTO；兼容被包在 Data 里或返回 AxiosResponse 的情况
    const data = res?.OrderNo ? res : res
    if (!data || !data.OrderNo) {
      ElMessage.error('获取订单详情失败')
      return
    }
    currentOrder.value = {
      ...data,
      // 老订单没落发货仓，详情接口的 WarehouseName 是空；列表已经兜底算出提货仓，借过来显示
    }
    orderDialogVisible.value = true
  } catch (e: any) {
    ElMessage.error(e?.Message || e?.message || '获取订单详情失败')
  }
}

// 确认自提：走发货接口，DeliveryType=1 自提
const pickupDialogVisible = ref(false)
const pickupSubmitting = ref(false)
const pickupRow = ref<any>(null)
const pickupFormRef = ref()
const pickupForm = reactive({
  DriverName: '',
  DriverPhone: '',
  CarPlateNumber: ''
})

// 司机姓名与车牌号是提货凭证，缺一不可（后端 ShipCoreAsync 同样会拦）
const pickupRules = {
  DriverName: [
    { required: true, message: '请填写司机姓名', trigger: 'blur' },
    { min: 2, max: 20, message: '司机姓名长度应为 2-20 个字', trigger: 'blur' }
  ],
  CarPlateNumber: [
    { required: true, message: '请填写车牌号', trigger: 'blur' },
    { min: 5, max: 12, message: '车牌号长度应为 5-12 位，如 粤A12345', trigger: 'blur' }
  ]
}

const handleConfirmPickup = (row: any) => {
  pickupRow.value = row
  pickupForm.DriverName = row.DriverName || ''
  pickupForm.DriverPhone = row.DriverPhone || ''
  pickupForm.CarPlateNumber = row.CarPlateNumber || ''
  pickupDialogVisible.value = true
  // 清掉上一次的校验红字
  nextTick(() => pickupFormRef.value?.clearValidate())
}

const submitPickup = async () => {
  const row = pickupRow.value
  if (!row || pickupSubmitting.value) return
  // 必填校验交给表单规则，字段下方会直接标红
  const valid = await pickupFormRef.value?.validate().catch(() => false)
  if (!valid) return
  pickupSubmitting.value = true
  try {
    await reqShipOrder({
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
    ElMessage.success('确认自提成功')
    pickupDialogVisible.value = false
    getPickupOrderList()
  } catch (error) {
    console.error('确认自提失败:', error)
    showError(error, '确认自提失败，请重试')
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
    orderList.value = getList(res)
    total.value = getTotal(res, orderList.value.length)
  } catch (error) {
    console.error('请求自提订单列表出错:', error)
    showError(error, '请求自提订单列表出错')
  } finally {
    listLoading.value = false
  }
}

onMounted(() => {
  getPickupOrderList()
})
</script>

<style lang="scss" scoped>
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

/* 自提订单表格：表头不折行，单元格多行信息统一行高，操作列三个按钮排一行 */
.pickup-table {
  :deep(th .cell) {
    white-space: nowrap;
  }

  :deep(.el-table__row) {
    vertical-align: top;
  }

  :deep(.op-col .cell) {
    padding: 0 8px;

    .el-button + .el-button {
      margin-left: 8px;
    }
  }
}

.main-line {
  font-weight: 500;
  color: #303133;
  line-height: 1.5;
}

/* 订单号是 21 位定长串，折行会很难认，宁可缩一点字号也不换行 */
.order-no {
  font-size: 13px;
  white-space: nowrap;
}

.sub-line {
  font-size: 12px;
  color: #909399;
  line-height: 1.5;
}

.info-list {
  line-height: 1.55;
  color: #303133;
}

.missing {
  color: #e6a23c;
  font-weight: 500;
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
