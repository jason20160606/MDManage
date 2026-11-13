<template>
  <div class="app-container">
    <!-- 待发货订单列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>待发货订单管理</span>
          <div class="header-actions">
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <div style="display: flex; flex-wrap: wrap;">
          <!-- 第一行 -->
          <div style="display: flex; flex: 1 1 100%; flex-wrap: wrap;">
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
          </div>
          <!-- 第二行 -->
          <div style="display: flex; flex: 1 1 100%; flex-wrap: wrap; align-items: center;">
            <el-form-item label="订单日期">
              <el-date-picker v-model="queryForm.DateRange" type="daterange" value-format="YYYY-MM-DD" range-separator="至" start-placeholder="开始日期"
                end-placeholder="结束日期" style="width: 240px;" />
            </el-form-item>
            <el-form-item label="合计箱数区间">
              <el-input v-model="queryForm.TotalAmountMin" placeholder="最小箱数" style="width: 100px;" clearable />
              <span style="margin: 0 8px;">-</span>
              <el-input v-model="queryForm.TotalAmountMax" placeholder="最大箱数" style="width: 100px;" clearable />
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
          </div>
        </div>
      </el-form>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" v-loading="loading" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="45" />
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column label="订单信息" min-width="215">
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
        <el-table-column label="经销商信息" min-width="120">
          <template #default="{ row }">
            <div class="dealer-info">
              <div class="dealer-name">{{ row.DealerName }}</div>
              <div class="dealer-sendname">发件人: {{ row.SenderName }}</div>              
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="170">
          <template #default="{ row }">
            <div class="receiver-info">
              <div class="receiver-name">{{ row.ReceiverName }}</div>
              <div class="receiver-phone">电话: {{ row.ReceiverPhone }}</div>
              <div class="receiver-address">地址: {{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="产品信息" min-width="188">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-list">
                <div v-for="(item, index) in row.OrderItems || []" :key="index" class="product-item">
                  <span class="product-name">{{ item.ProductName || '未知产品' }}</span>
                  <span class="product-quantity">×{{ fmtQty(boxQty(item)) }}</span>
                  <span v-if="itemDiff(item) !== 0" class="product-diff">差价 {{ fmtMoney(itemDiff(item)) }}</span>
                </div>
                <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                <span class="total-count">共 {{ row.OrderItems?.length || 0 }} 种产品</span>
                <span class="total-amount">合计 {{ fmtQty(orderBoxTotal(row)) }} 箱</span>
                <span class="total-diff">差价 {{ fmtMoney(orderDiffTotal(row)) }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="合计箱数" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ fmtQty(orderBoxTotal(row)) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">            
            <el-button type="info" link @click="viewOrder(row)">查看</el-button>           
            <el-button type="warning" link @click="handleEdit(row)">编辑</el-button>
            <el-button v-if="row.DeliveryType === 1" type="info" link @click="handleEditCar(row)">车牌</el-button>
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

    <!-- 发货表单已移除 -->

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
      </el-form>
      <template #footer>
        <el-button @click="editDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveEdit">保存</el-button>
      </template>
    </el-dialog>

    <!-- 车辆信息编辑弹窗 -->
    <el-dialog v-model="editCarDialogVisible" title="编辑车辆信息" width="500px" :close-on-click-modal="false">
      <el-form :model="editCarForm" label-width="100px" style="padding: 10px 0;">
        <el-form-item label="司机姓名">
          <el-input v-model="editCarForm.DriverName" placeholder="请输入司机姓名" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="车牌号">
          <el-input v-model="editCarForm.CarPlateNumber" placeholder="请输入车牌号" style="width: 100%;" />
        </el-form-item>
        <el-form-item label="司机电话">
          <el-input v-model="editCarForm.DriverPhone" placeholder="请输入司机电话" style="width: 100%;" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="editCarDialogVisible = false">取消</el-button>
        <el-button type="primary" @click="saveEditCar">保存</el-button>
      </template>
    </el-dialog>

    <!-- 取消订单结果弹窗：与审核结果一样展示经销商额度变化，并支持一键复制 -->
    <el-dialog v-model="resultDialogVisible" title="订单取消结果" width="520px" :close-on-click-modal="false">
      <div v-if="cancelResult">
        <div class="cancel-result-row">
          <b>取消状态：</b>
          <el-tag :type="cancelResult.Success ? 'success' : 'danger'" size="small">
            {{ cancelResult.Success ? '成功' : '失败' }}
          </el-tag>
        </div>
        <div class="cancel-result-row"><b>订单号：</b>{{ cancelResult.OrderNo || '—' }}　<b>订单总箱数：</b>{{ fmtNum(cancelResult.TotalAmount) }}</div>
        <div class="cancel-result-row"><b>经销商：</b>{{ cancelResult.DealerName || '—' }}</div>
        <div class="cancel-result-row"><b>取消前额度：</b>{{ fmtNum(cancelResult.BeforeDealerQuota) }}</div>
        <div class="cancel-result-row"><b>取消后额度：</b>{{ fmtNum(cancelResult.AfterDealerQuota) }}</div>
        <div v-if="!cancelResult.QuotaRestored" class="cancel-result-row" style="color:#909399;font-size:12px;">
          该订单尚未审核，未产生经销商额度变化
        </div>

        <template v-if="cancelResult.QuotaChanges && cancelResult.QuotaChanges.length">
          <el-divider content-position="left">额度返还明细</el-divider>
          <el-table :data="cancelResult.QuotaChanges" size="small" border>
            <el-table-column prop="QuotaName" label="额度账户" min-width="120" />
            <el-table-column prop="BeforeAmount" label="取消前" width="88" align="right" />
            <el-table-column label="返还" width="88" align="right">
              <template #default="{ row }"><span style="color:#c45656">+{{ fmtNum(row.ChangeQuantity) }}</span></template>
            </el-table-column>
            <el-table-column prop="AfterAmount" label="取消后" width="88" align="right" />
          </el-table>
        </template>

        <div v-if="cancelResult.PriceDiffReversed" class="cancel-result-row" style="margin-top:8px;">
          <b>差价冲回：</b>-{{ fmtNum(cancelResult.BeforePriceDiff - cancelResult.AfterPriceDiff) }}
          （{{ fmtNum(cancelResult.BeforePriceDiff) }} → {{ fmtNum(cancelResult.AfterPriceDiff) }}）
        </div>

        <template v-if="cancelResult.StockChanges && cancelResult.StockChanges.length">
          <el-divider content-position="left">仓库库存回退</el-divider>
          <el-table :data="cancelResult.StockChanges" size="small" border max-height="180">
            <el-table-column prop="ProductName" label="商品" min-width="140" show-overflow-tooltip />
            <el-table-column prop="Action" label="动作" width="70" align="center" />
            <el-table-column prop="Quantity" label="箱数" width="80" align="right" />
            <el-table-column prop="WarehouseName" label="仓库" min-width="120" show-overflow-tooltip />
          </el-table>
        </template>

        <div class="cancel-result-row" style="margin-top:10px;">
          <b>取消信息：</b>
          <div class="cancel-result-msg">{{ resultDialogMessage }}</div>
        </div>
      </div>
      <div v-else style="font-size: 16px; color: #333; white-space: pre-line;">{{ resultDialogMessage }}</div>
      <template #footer>
        <el-button @click="copyCancelResult">一键复制</el-button>
        <el-button type="primary" @click="resultDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import orderView from './orderView.vue'
import { reqOrderlist, reqUpdateOrderAddress, reqUpdateOrderCarInfo, reqExportOrders, reqCancelOrder, reqCheckOrder } from '@/api/order'
import { orderBoxTotal, fmtQty, boxQty, itemDiff, orderDiffTotal, fmtMoney } from '@/utils/orderQty'

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

const resultDialogVisible = ref(false)
const resultDialogMessage = ref('')
// 取消订单结构化结果（经销商额度 / 仓库库存变化），来自后端 ApiResponse.Data
const cancelResult = ref<any>(null)

const fmtNum = (v: any) => {
  const n = Number(v)
  if (!Number.isFinite(n)) return '—'
  return n.toFixed(2).replace(/\.?0+$/, '') || '0'
}

// 复制到剪贴板：clipboard API 不可用时降级到 execCommand
const copyText = async (text: string) => {
  try {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text)
    } else {
      const ta = document.createElement('textarea')
      ta.value = text
      ta.style.position = 'fixed'
      ta.style.opacity = '0'
      document.body.appendChild(ta)
      ta.select()
      document.execCommand('copy')
      document.body.removeChild(ta)
    }
    ElMessage.success('已复制到剪贴板')
  } catch (e) {
    console.error('复制失败', e)
    ElMessage.error('复制失败，请手动选择文本复制')
  }
}

const copyCancelResult = () => {
  const r: any = cancelResult.value
  const lines: string[] = []
  if (r) {
    lines.push(`取消状态：${r.Success ? '成功' : '失败'}`)
    lines.push(`订单号：${r.OrderNo || ''}`)
    lines.push(`经销商：${r.DealerName || ''}`)
    lines.push(`订单总箱数：${fmtNum(r.TotalAmount)}`)
    lines.push(`取消前额度：${fmtNum(r.BeforeDealerQuota)}`)
    lines.push(`取消后额度：${fmtNum(r.AfterDealerQuota)}`)
    if (!r.QuotaRestored) lines.push('额度变化：该订单尚未审核，未产生额度变化')
    const quotaChanges: any[] = r.QuotaChanges || []
    quotaChanges.forEach((q: any) => {
      lines.push(`${q.QuotaName}：${fmtNum(q.BeforeAmount)} → ${fmtNum(q.AfterAmount)}（返还 ${fmtNum(q.ChangeQuantity)} 箱）`)
    })
    if (r.PriceDiffReversed) {
      lines.push(`差价冲回：${fmtNum(r.BeforePriceDiff)} → ${fmtNum(r.AfterPriceDiff)}`)
    }
    const stockChanges: any[] = r.StockChanges || []
    stockChanges.forEach((s: any) => {
      lines.push(`${s.ProductName} ${s.Action} ${fmtNum(s.Quantity)} 箱${s.WarehouseName ? `（${s.WarehouseName}）` : ''}`)
    })
    const msgLines: string[] = (r.Message || '').split('@').map((s: string) => s.trim().replace(/[,，；;]$/, '')).filter(Boolean)
    lines.push(`取消信息：${msgLines.join('；')}`)
  } else {
    lines.push(resultDialogMessage.value || '订单取消成功')
  }
  copyText(lines.join('\n'))
}

// 获取子组件实例
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

// 新增车辆信息编辑弹窗相关变量
const editCarDialogVisible = ref(false)
const editCarForm = reactive({
  Id: '',
  DriverName: '',
  CarPlateNumber: '',
  DriverPhone: ''
})
const editCarFormOrigin = reactive({
  DriverName: '',
  CarPlateNumber: '',
  DriverPhone: ''
})

// 发货表单相关

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
      OrderStatus: 2, // 状态为2表示待发货
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNumber: queryForm.OrderNo || undefined,
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
    orderList.value = result.data || []
    if (result.headers && result.headers['x-pagination']) {
      const pagination = JSON.parse(result.headers['x-pagination'])
      currentPage.value = pagination.PageIndex || 1
      pageSize.value = pagination.PageSize || 10
      total.value = pagination.TotalCount || 0
    } else {
      total.value = orderList.value.length
    }
    loading.value = false
  } catch (error) {
    ElMessage.error('获取待发货订单列表失败')
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
    // 成功时 Data 里带结构化结果（额度/库存变化），响应拦截器已自动解包
    const res: any = await reqCancelOrder(row.Id)
    cancelResult.value = res && res.OrderNo ? res : null
    resultDialogMessage.value = (res?.Message || '订单取消成功').split('@').join('\n')
    resultDialogVisible.value = true
    setTimeout(() => handleQuery(), 300)
  } catch (error: any) {
    if (error !== 'cancel') {
      cancelResult.value = null
      resultDialogMessage.value = error?.Message || '订单取消失败'
      resultDialogVisible.value = true
    }
  }
}

// 导出订单
const handleExport = async () => {
  if (selectedOrders.value.length === 0) {
    ElMessage.warning('请选择要导出的订单')
    return
  }
  try {
    // 获取选中订单ID数组
    const orderIds = selectedOrders.value.map(item => item.Id)
    // 调用导出API（API已自动组装参数格式）
    const res = await reqExportOrders(orderIds)
    // 处理文件下载，res.data才是Blob内容
    const blob = new Blob([res.data], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' })
    const url = window.URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `订单导出_${new Date().toLocaleDateString()}.xlsx`
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
    window.URL.revokeObjectURL(url)
    ElMessage.success('导出成功')
  } catch (error) {
    ElMessage.error('导出失败')
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
  } catch (e: any) {
    ElMessage.error(e?.Message || e?.message || '收货信息修改失败')
  }
}

// 新增车辆信息编辑弹窗方法
const handleEditCar = async (row: any) => {
  try {
    // 先取订单详情，列表数据可能没带全司机/车牌
    const res = await reqCheckOrder(row.Id)
    const orderDetail = res?.data ?? res
    const source = orderDetail && (orderDetail.Id || orderDetail.id) ? orderDetail : row
    editCarForm.Id = row.Id
    editCarForm.DriverName = source.DriverName || ''
    editCarForm.CarPlateNumber = source.CarPlateNumber || ''
    editCarForm.DriverPhone = source.DriverPhone || ''
    editCarFormOrigin.DriverName = editCarForm.DriverName
    editCarFormOrigin.CarPlateNumber = editCarForm.CarPlateNumber
    editCarFormOrigin.DriverPhone = editCarForm.DriverPhone
  } catch (error) {
    console.error('获取订单详情失败，改用列表数据:', error)
    editCarForm.Id = row.Id
    editCarForm.DriverName = row.DriverName || ''
    editCarForm.CarPlateNumber = row.CarPlateNumber || ''
    editCarForm.DriverPhone = row.DriverPhone || ''
    editCarFormOrigin.DriverName = editCarForm.DriverName
    editCarFormOrigin.CarPlateNumber = editCarForm.CarPlateNumber
    editCarFormOrigin.DriverPhone = editCarForm.DriverPhone
  }
  editCarDialogVisible.value = true
}

// 保存车辆信息
const saveEditCar = async () => {
  const isNoChange =
    editCarForm.DriverName === editCarFormOrigin.DriverName &&
    editCarForm.CarPlateNumber === editCarFormOrigin.CarPlateNumber &&
    editCarForm.DriverPhone === editCarFormOrigin.DriverPhone
  if (isNoChange) {
    ElMessage.info('未做任何修改')
    editCarDialogVisible.value = false
    return
  }
  try {
    // 走车辆信息专用接口：以前这里错调了改地址接口，导致车牌永远存不进去
    await reqUpdateOrderCarInfo(editCarForm.Id, {
      DriverName: editCarForm.DriverName,
      CarPlateNumber: editCarForm.CarPlateNumber,
      DriverPhone: editCarForm.DriverPhone
    })
    ElMessage.success('车辆信息修改成功')
    editCarDialogVisible.value = false
    handleQuery()
  } catch (e: any) {
    // 后端的真实原因（如状态不允许）要透出来，不能一律盖成"修改失败"
    ElMessage.error(e?.Message || e?.message || '车辆信息修改失败')
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

  .product-diff {
    font-size: 12px;
    color: #e6a23c;
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
    display: flex;
    flex-wrap: wrap;
    gap: 2px 8px;
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

  .total-diff {
    font-size: 11px;
    color: #e6a23c;
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

.cancel-result-row {
  margin-bottom: 8px;
  font-size: 14px;
  line-height: 1.6;
}
.cancel-result-msg {
  margin-top: 4px;
  padding: 8px 10px;
  background: #f7f8fa;
  border-radius: 4px;
  white-space: pre-line;
  font-size: 13px;
  line-height: 1.7;
}
</style> 