<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <el-card class="search-wrapper">
      <el-form :model="queryParams" ref="queryForm" :inline="true">
        <el-form-item label="订单编号">
          <el-input v-model="queryParams.orderNo" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item label="物流单号">
          <el-input v-model="queryParams.trackingNo" placeholder="请输入物流单号" clearable />
        </el-form-item>
        <el-form-item label="物流公司">
          <el-select v-model="queryParams.logisticsCompany" placeholder="请选择物流公司" clearable style="width: 150px;">
            <el-option
              v-for="item in logisticsCompanyList"
              :key="item.Id"
              :label="item.Name"
              :value="item.Code"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="发货时间">
          <el-date-picker
            v-model="queryParams.shipTime"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
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
          <span>已发货列表</span>
          <div class="right">
            <el-button type="success" @click="handleExport">导出</el-button>
            <el-button type="primary" @click="handleBatchPrint">批量打印</el-button>
          </div>
        </div>
      </template>

      <!-- 表格区域 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        border
        row-key="Id"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="45" />
        <el-table-column prop="OrderNo" label="订单编号" min-width="195">
          <template #default="{ row }">
            <div>
              <div><b>{{ row.OrderNo }}</b></div>
              <!-- 这行应显示真正发货时间；列表里的 OrderDate 是下单日期 -->
              <div style="font-size: 12px; color: #909399;">
                发货时间：{{ row.ShipmentInfos?.[0]?.CreatedAt ? formatDateTime(row.ShipmentInfos[0].CreatedAt) : '-' }}
              </div>
            </div>
          </template>
        </el-table-column>
       
        <el-table-column label="收货信息" min-width="185">
          <template #default="{ row }">
            <div class="receiver-info">
              <div>收货人：{{ row.ReceiverName }}</div>
              <div>电话：{{ row.ReceiverPhone }}</div>
              <div>地址：{{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        
        <el-table-column label="产品信息" min-width="175">
          <template #default="{ row }">
            <div class="product-info">
              <div class="product-list">
                <div v-for="(item, index) in row.OrderItems || []" :key="index" class="product-item">
                  <span class="product-name">{{ item.ProductName || '未知产品' }}</span>
                  <!-- 明细与合计都按实物箱数展示，和其它发货页面口径一致 -->
                  <span class="product-quantity">×{{ fmtQty(boxQty(item)) }}</span>
                </div>
                <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">
                  暂无产品信息
                </div>
              </div>
              <div class="product-summary">
                共 {{ row.OrderItems?.length || 0 }} 种 · 合计
                <b>{{ fmtQty(orderBoxTotal(row)) }}</b> 箱
              </div>
            </div>
          </template>
        </el-table-column> 
        <el-table-column label="物流公司" width="110">
          <template #default="{ row }">
            <!-- 展示第一个发货记录的物流公司，如无则显示'-' -->
            {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].LogisticsCompany : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="物流单号" min-width="145">
          <template #default="{ row }">
            <!-- 展示第一个发货记录的物流单号，如无则显示'-' -->
            {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].TrackingNo : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="Status" label="物流状态" width="95">
          <template #default="{ row }">
            <el-tag :type="getLogisticsStatusType(row.Status)">
              {{ getLogisticsStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>       
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleTrack(row)">{{ Number(row.DeliveryType) === 1 ? '自提信息' : '物流跟踪' }}</el-button>
            <el-button type="primary" link @click="handleDetail(row)">详情</el-button>
            <el-button type="primary" link @click="handlePrint(row)">打印</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 物流跟踪对话框 -->
    <el-dialog
      v-model="trackDialogVisible"
      :title="trackIsSelfPickup ? '自提信息' : '物流跟踪'"
      width="620px"
      destroy-on-close
    >
      <template v-if="trackIsSelfPickup">
        <el-descriptions :column="1" border>
          <el-descriptions-item label="订单号">{{ trackSelfInfo.OrderNo || '-' }}</el-descriptions-item>
          <el-descriptions-item label="司机姓名">{{ trackSelfInfo.DriverName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="司机电话">{{ trackSelfInfo.DriverPhone || '-' }}</el-descriptions-item>
          <el-descriptions-item label="车牌号">{{ trackSelfInfo.CarPlateNumber || '-' }}</el-descriptions-item>
        </el-descriptions>
        <el-alert type="info" :closable="false" show-icon title="自提订单不经过快递，无需物流跟踪" style="margin-top: 12px;" />
      </template>
      <template v-else>

      <div class="track-head">
        <span class="track-title">{{ trackTitle || '暂无物流信息' }}</span>
        <el-button size="small" :loading="trackLoading" @click="refreshTrack">刷新</el-button>
      </div>
      <el-alert
        v-if="trackMocked"
        type="warning"
        :closable="false"
        show-icon
        :title="trackMessage || '当前为模拟轨迹，配置物流查询账号后自动切换为真实轨迹'"
        style="margin-bottom: 14px;"
      />
      <div v-else-if="trackMessage" class="track-msg">{{ trackMessage }}</div>
      <el-timeline v-loading="trackLoading" class="track-timeline">
        <el-timeline-item
          v-for="(activity, index) in logisticsTrack"
          :key="index"
          :type="activity.type"
          :timestamp="activity.timestamp"
        >
          <div>{{ activity.content }}</div>
          <div v-if="activity.location" class="track-loc">{{ activity.location }}</div>
        </el-timeline-item>
      </el-timeline>
      <el-empty
        v-if="!trackLoading && logisticsTrack.length === 0"
        description="暂无物流轨迹"
        :image-size="70"
      />
    
      </template>
    </el-dialog>

    <!-- 单个订单打印预览弹窗 -->
    <el-dialog v-model="singlePrintDialogVisible" title="订单打印预览" width="600px" :close-on-click-modal="false">
      <div id="singlePrintArea">
        <div v-if="printOrder">
          <div><strong>订单编号：</strong>{{ printOrder.OrderNo }}</div>
          <div><strong>发货时间：</strong>{{ printOrder.OrderDate }}</div>
          <div><strong>收货人：</strong>{{ printOrder.ReceiverName }}（{{ printOrder.ReceiverPhone }}）</div>
          <div><strong>收货地址：</strong>{{ printOrder.ReceiverAddress }}</div>
          <div><strong>物流公司：</strong>{{ printOrder.ShipmentInfos && printOrder.ShipmentInfos.length > 0 ? printOrder.ShipmentInfos[0].LogisticsCompany : '-' }}</div>
          <div><strong>物流单号：</strong>{{ printOrder.ShipmentInfos && printOrder.ShipmentInfos.length > 0 ? printOrder.ShipmentInfos[0].TrackingNo : '-' }}</div>
          <div><strong>商品明细：</strong></div>
          <ul style="margin-left: 24px;">
            <li v-for="(item, idx) in printOrder.OrderItems || []" :key="idx" style="display: flex; align-items: center;">
              <span style="display: inline-block; min-width: 180px;">{{ item.ProductName }} × {{ item.Quantity }}</span>
            </li>
          </ul>
          <div><strong>订单总额：</strong>{{ printOrder.TotalAmount }}</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="singlePrintDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="printSingleOrder">打印</el-button>
      </template>
    </el-dialog>

    <!-- 批量打印预览弹窗 -->
    <el-dialog v-model="batchPrintDialogVisible" title="批量打印预览" width="800px" :close-on-click-modal="false">
      <div id="batchPrintArea">
        <div v-for="order in selectedRows" :key="order.Id" class="print-order-item" style="margin-bottom: 24px; border-bottom: 1px dashed #ccc; padding-bottom: 12px;">
          <div><strong>订单编号：</strong>{{ order.OrderNo }}</div>
          <div><strong>发货时间：</strong>{{ order.OrderDate }}</div>
          <div><strong>收货人：</strong>{{ order.ReceiverName }}（{{ order.ReceiverPhone }}）</div>
          <div><strong>收货地址：</strong>{{ order.ReceiverAddress }}</div>
          <div><strong>物流公司：</strong>{{ order.ShipmentInfos && order.ShipmentInfos.length > 0 ? order.ShipmentInfos[0].LogisticsCompany : '-' }}</div>
          <div><strong>物流单号：</strong>{{ order.ShipmentInfos && order.ShipmentInfos.length > 0 ? order.ShipmentInfos[0].TrackingNo : '-' }}</div>
          <div><strong>商品明细：</strong></div>
          <ul style="margin-left: 24px;">
            <li v-for="(item, idx) in order.OrderItems || []" :key="idx" style="display: flex; align-items: center;">
              <span style="display: inline-block; min-width: 180px;">{{ item.ProductName }} × {{ item.Quantity }}</span>
            </li>
          </ul>
          <div><strong>订单总额：</strong>{{ order.TotalAmount }}</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="batchPrintDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="printBatchOrders">打印</el-button>
      </template>
    </el-dialog>

    <!-- 详情弹窗 -->
    <el-dialog v-model="detailDialogVisible" title="订单详情" width="780px" :close-on-click-modal="false" class="order-detail-dialog">
      <div v-if="detailOrder" class="detail-body" v-loading="detailLoading">
        <el-descriptions :column="2" border size="default" class="detail-block">
          <el-descriptions-item label="订单编号">{{ detailOrder.OrderNo }}</el-descriptions-item>
          <el-descriptions-item label="订单日期">{{ formatDate(detailOrder.OrderDate) }}</el-descriptions-item>
          <el-descriptions-item label="经销商">{{ detailOrder.DealerName || '-' }}</el-descriptions-item>
          <el-descriptions-item label="订单状态">
            <el-tag size="small" :type="getLogisticsStatusType(detailOrder.Status)">
              {{ getLogisticsStatusText(detailOrder.Status) }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="配送方式">
            <el-tag size="small" :type="detailOrder.DeliveryType === 1 ? 'warning' : 'info'" effect="plain">
              {{ detailOrder.DeliveryType === 1 ? '客户自提' : detailOrder.DeliveryType === 2 ? '物流到付' : '物流现付' }}
            </el-tag>
          </el-descriptions-item>
          <el-descriptions-item label="发货进度">
            {{ fmtQty(detailOrder.ShippedQty) }} / {{ fmtQty(detailOrder.TotalShipQty) }} 箱
          </el-descriptions-item>
          <el-descriptions-item label="收货人">
            {{ detailOrder.ReceiverName || '-' }}
            <span v-if="detailOrder.ReceiverPhone">（{{ detailOrder.ReceiverPhone }}）</span>
          </el-descriptions-item>
          <el-descriptions-item label="订单总箱数">{{ fmtQty(orderBoxTotal(detailOrder)) }} 箱</el-descriptions-item>
          <el-descriptions-item label="收货地址" :span="2">{{ detailOrder.ReceiverAddress || '-' }}</el-descriptions-item>
          <!-- 自提单看司机车牌，物流单看承运商运单号；每项用独立 v-if，避免 v-else 链丢项 -->
          <el-descriptions-item v-if="detailOrder.DeliveryType === 1" label="司机姓名">
            {{ detailOrder.DriverName || '-' }}
            <span v-if="detailOrder.DriverPhone">（{{ detailOrder.DriverPhone }}）</span>
          </el-descriptions-item>
          <el-descriptions-item v-if="detailOrder.DeliveryType === 1" label="车牌号">
            {{ detailOrder.CarPlateNumber || '-' }}
          </el-descriptions-item>
          <el-descriptions-item v-if="detailOrder.DeliveryType !== 1" label="承运商">
            {{ detailOrder.ShipmentInfos?.[0]?.LogisticsCompany || '-' }}
          </el-descriptions-item>
          <el-descriptions-item v-if="detailOrder.DeliveryType !== 1" label="运单号">
            {{ detailOrder.ShipmentInfos?.[0]?.TrackingNo || '-' }}
          </el-descriptions-item>
          <el-descriptions-item label="备注" :span="2">{{ detailOrder.Remark || '-' }}</el-descriptions-item>
        </el-descriptions>

        <!-- 商品明细：详情接口返回的是 OrderItemDetails -->
        <div class="detail-section">
          <div class="section-title">
            商品明细
            <span class="section-sub">共 {{ detailItems.length }} 种</span>
          </div>
          <el-table :data="detailItems" border size="small" empty-text="暂无商品明细">
            <el-table-column type="index" label="#" width="48" align="center" />
            <el-table-column prop="ProductName" label="产品名称" min-width="150" show-overflow-tooltip />
            <el-table-column prop="BrandName" label="品牌" width="90" />
            <el-table-column prop="FactoryName" label="厂家" width="90" />
            <el-table-column label="订货箱数" width="90" align="right">
              <template #default="{ row }">{{ fmtQty(boxQty(row)) }}</template>
            </el-table-column>
            <el-table-column label="已发箱数" width="90" align="right">
              <template #default="{ row }">{{ fmtQty(row.ShippedQty) }}</template>
            </el-table-column>
          </el-table>
        </div>

        <!-- 发货记录：一单可能分多批发 -->
        <div v-if="detailOrder.ShipmentInfos && detailOrder.ShipmentInfos.length" class="detail-section">
          <div class="section-title">
            发货记录
            <span class="section-sub">共 {{ detailOrder.ShipmentInfos.length }} 批</span>
          </div>
          <el-table :data="detailOrder.ShipmentInfos" border size="small">
            <el-table-column prop="ShipmentNo" label="发货单号" min-width="170" show-overflow-tooltip />
            <el-table-column label="承运商" width="110">
              <template #default="{ row }">{{ row.LogisticsCompany || (detailOrder.DeliveryType === 1 ? '自提' : '-') }}</template>
            </el-table-column>
            <el-table-column prop="TrackingNo" label="物流单号" min-width="140" show-overflow-tooltip>
              <template #default="{ row }">{{ row.TrackingNo || '-' }}</template>
            </el-table-column>
            <el-table-column label="发货箱数" width="90" align="right">
              <template #default="{ row }">{{ fmtQty(row.TotalQuantity) }}</template>
            </el-table-column>
            <el-table-column label="发货时间" width="150">
              <template #default="{ row }">{{ formatDateTime(row.CreatedAt) }}</template>
            </el-table-column>
          </el-table>
        </div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { reqShippedOrderList, reqCheckOrder } from '@/api/order' // 导入新的已发货订单接口和详情接口
import { getLogisticsCompanyNames, getShipmentTrack } from '@/api/shipping'
import { fmtQty, boxQty, orderBoxTotal } from '@/utils/orderQty'

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNo: '',
  trackingNo: '',
  logisticsCompany: '',
  shipTime: []
})

// 表格数据
const loading = ref(false)
const tableData = ref<any[]>([])
// 分页相关变量
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 物流跟踪对话框
const trackDialogVisible = ref(false)
const trackIsSelfPickup = ref(false)
const trackSelfInfo = ref<any>({})
const trackLoading = ref(false)
const trackMocked = ref(false)
const trackMessage = ref('')
const trackTitle = ref('')
const logisticsTrack = ref<any[]>([])

// 物流公司名称列表
const logisticsCompanyList = ref<{ Id: string, Code: string, Name: string }[]>([])

// 获取物流状态类型
const getLogisticsStatusType = (status: string) => {
  const map: Record<string, string> = {
    '1': 'primary', // 已发货/运输中
    '0': 'info', // 待处理
    '2': 'success', // 已完成/已签收
    '3': 'danger'   // 已取消/异常
  }
  return map[status] || 'info'
}

// 获取物流状态文本
const getLogisticsStatusText = (status: string) => {
  const map: Record<string, string> = {
    '1': '待审核',
    '2': '待发货',
    '3': '运输中',
    '4': '运输中',
    '5': '已签收',
    '6': '已取消'
  }
  return map[status] || status
}

// 获取订单列表数据
const getOrderList = async () => {
  loading.value = true
  try {
    const params = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNumber: queryParams.orderNo || undefined,
      TrackingNo: queryParams.trackingNo || undefined,
      LogisticsCompany: queryParams.logisticsCompany || undefined,
      StartDate: queryParams.shipTime?.[0] || undefined,
      EndDate: queryParams.shipTime?.[1] || undefined
    }
    const result = await reqShippedOrderList(params)
    tableData.value = result.data // 订单数据
    // 分页信息从headers['x-pagination']获取
    if (result.headers && result.headers['x-pagination']) {
      const pagination = JSON.parse(result.headers['x-pagination'])
      currentPage.value = pagination.PageIndex || 1
      pageSize.value = pagination.PageSize || 10
      total.value = pagination.TotalCount || 0
    } else {
      total.value = tableData.value.length
    }
    ElMessage.success('获取已发货订单列表成功');
  } catch (error) {
    tableData.value = [];
    total.value = 0;
    ElMessage.error('获取订单列表失败');
  } finally {
    loading.value = false;
  }
}

// 查询列表
const handleQuery = () => {
  currentPage.value = 1; // 查询时重置页码到第一页
  getOrderList();
}

// 重置查询
const resetQuery = () => {
  queryParams.orderNo = '';
  queryParams.trackingNo = '';
  queryParams.logisticsCompany = '';
  queryParams.shipTime = [];
  currentPage.value = 1; // 重置时也重置页码
  getOrderList();
}

// 物流跟踪
const trackShipmentId = ref(0)

const formatTrackTime = (value: any) => {
  if (!value) return ''
  const d = new Date(value)
  if (isNaN(d.getTime()) || d.getFullYear() < 1900) return ''
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

const loadTrack = async (shipmentId: number, refresh = false) => {
  trackLoading.value = true
  try {
    const res: any = await getShipmentTrack(shipmentId, refresh)
    // 响应拦截器已拆包；Data 为 null 时会回整个信封，这里两种结构都兼容
    const data = res?.Tracks ? res : (res?.data ?? res ?? {})
    const list = data.Tracks || data.tracks || []
    trackMocked.value = !!data.Mocked
    trackMessage.value = data.Message || ''
    // 自提单没有承运商/运单号，接口返回为空，不要用空值覆盖掉外面填好的「自提」标题
    const apiTitle = [data.Carrier, data.TrackingNo].filter(Boolean).join(' ')
    if (apiTitle) trackTitle.value = apiTitle
    logisticsTrack.value = list.map((t: any) => ({
      content: t.Remark || t.remark || '',
      location: t.Location || t.location || '',
      timestamp: formatTrackTime(t.Time || t.time),
      type:
        (t.Status || t.status) === '已签收' || (t.Status || t.status) === '已自提'
          ? 'success'
          : (t.Status || t.status) === '异常'
            ? 'danger'
            : 'primary'
    }))
  } catch (e) {
    console.error('获取物流轨迹失败', e)
    logisticsTrack.value = []
  } finally {
    trackLoading.value = false
  }
}

const handleTrack = (row: any) => {

  // 自提订单不经过快递：不调用物流查询接口，只展示车牌与司机信息
  if (Number(row.DeliveryType) === 1) {
    trackIsSelfPickup.value = true
    trackSelfInfo.value = { ...row }
    trackTitle.value = '自提信息'
    logisticsTrack.value = []
    trackMessage.value = ''
    trackMocked.value = false
    trackDialogVisible.value = true
    return
  }
  trackIsSelfPickup.value = false
  const shipment = (row?.ShipmentInfos || [])[0]
  if (!shipment?.Id) {
    ElMessage.warning('该订单还没有发货记录，无法跟踪')
    return
  }
  trackShipmentId.value = shipment.Id
  trackTitle.value =
    row.DeliveryType === 1
      ? ['自提', row.CarPlateNumber].filter(Boolean).join(' · ')
      : [shipment.LogisticsCompany, shipment.TrackingNo].filter(Boolean).join(' · ') || '物流跟踪'
  trackMessage.value = ''
  trackMocked.value = false
  logisticsTrack.value = []
  trackDialogVisible.value = true
  loadTrack(shipment.Id)
}

const refreshTrack = () => {
  if (!trackShipmentId.value) return
  loadTrack(trackShipmentId.value, true)
}

// 详情弹窗相关变量
const detailDialogVisible = ref(false)
const detailLoading = ref(false)
const detailOrder = ref<any>(null)
// 详情接口返回的明细字段是 OrderItemDetails（OrderItems 只在列表接口里用，这里恒为 null）
const detailItems = computed<any[]>(() => detailOrder.value?.OrderItemDetails || [])

// 查看详情方法，调用reqCheckOrder获取详情
const handleDetail = async (row: any) => {
  detailOrder.value = null
  detailDialogVisible.value = true
  detailLoading.value = true
  try {
    const res = await reqCheckOrder(row.Id)
    // 详情接口直接返回 DTO；兼容可能被包在 Data 里的情况
    const data = res?.OrderNo ? res : (res?.data ?? res)
    if (!data || !data.OrderNo) {
      ElMessage.error('获取订单详情失败')
      detailDialogVisible.value = false
      return
    }
    detailOrder.value = data
  } catch (e: any) {
    ElMessage.error(e?.Message || e?.message || '获取订单详情失败')
    detailDialogVisible.value = false
  } finally {
    detailLoading.value = false
  }
}

// 单个订单打印预览弹窗显示状态
const singlePrintDialogVisible = ref(false)
// 当前要打印的订单对象
const printOrder = ref<any>(null)

// 批量打印预览弹窗显示状态
const batchPrintDialogVisible = ref(false)
// 批量打印选中的订单
const selectedRows = ref<any[]>([])

// 打开单个订单打印预览弹窗
const handlePrint = (row: any) => {
  printOrder.value = row
  singlePrintDialogVisible.value = true
}

// 执行单个订单打印
const printSingleOrder = () => {
  const printContent = document.getElementById('singlePrintArea')?.innerHTML
  if (!printContent) return
  const win = window.open('', '', 'width=700,height=500')
  win!.document.write(`
    <html>
      <head>
        <title>订单打印</title>
        <style>
          body { font-family: 'Microsoft YaHei', Arial, sans-serif; font-size: 14px; }
        </style>
      </head>
      <body>
        ${printContent}
      </body>
    </html>
  `)
  win!.document.close()
  win!.focus()
  win!.print()
  win!.close()
}

// 打开批量打印预览弹窗
const handleBatchPrint = () => {
  if (!selectedRows.value || selectedRows.value.length === 0) {
    ElMessage.warning('请先选择要打印的订单')
    return
  }
  batchPrintDialogVisible.value = true
}

// 执行批量打印
const printBatchOrders = () => {
  const printContent = document.getElementById('batchPrintArea')?.innerHTML
  if (!printContent) return
  const win = window.open('', '', 'width=900,height=600')
  win!.document.write(`
    <html>
      <head>
        <title>批量订单打印</title>
        <style>
          body { font-family: 'Microsoft YaHei', Arial, sans-serif; font-size: 14px; }
          .print-order-item { margin-bottom: 24px; border-bottom: 1px dashed #ccc; padding-bottom: 12px; }
        </style>
      </head>
      <body>
        ${printContent}
      </body>
    </html>
  `)
  win!.document.close()
  win!.focus()
  win!.print()
  win!.close()
}

// 表格选择事件，记录选中行
const handleSelectionChange = (selection: any[]) => {
  selectedRows.value = selection
}

// 导出
const handleExport = () => {
  // TODO: 调用导出功能
  ElMessage.success('导出成功')
}

// 分页事件
const handleSizeChange = (val: number) => {
  pageSize.value = val
  currentPage.value = 1
  getOrderList()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  getOrderList()
}

// 日期时间格式化：2026-11-12 17:30
const formatDateTime = (value: any) => {
  if (!value) return '-'
  const d = new Date(value)
  if (isNaN(d.getTime())) return String(value)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

// 日期格式化：去掉接口带出来的 T00:00:00 尾巴
const formatDate = (value: any) => {
  if (!value) return '-'
  const d = new Date(value)
  if (isNaN(d.getTime())) return String(value)
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`
}

// 初始化
onMounted(async () => {
  getOrderList()
  // 获取物流公司名称列表
  const res = await getLogisticsCompanyNames()
  if (res && Array.isArray(res.data)) {
    logisticsCompanyList.value = res.data
  }
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

/* 产品信息列：明细一行一个产品，末尾一行是种类与合计箱数 */
.product-info {
  line-height: 1.6;

  .product-item {
    display: flex;
    gap: 6px;
  }

  .product-name {
    overflow: hidden;
    white-space: nowrap;
    text-overflow: ellipsis;
  }

  .product-quantity {
    flex: none;
    color: #606266;
  }

  .product-summary {
    margin-top: 4px;
    padding-top: 4px;
    border-top: 1px dashed #ebeef5;
    font-size: 12px;
    color: #909399;

    b {
      color: #303133;
      font-weight: 600;
    }
  }

  .no-products {
    color: #c0c4cc;
  }
}

:deep(.el-timeline-item__content) {
  color: #666;
  line-height: 1.6;
}

.track-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 12px;

  .track-title {
    font-weight: bold;
    color: #303133;
  }
}

.track-msg {
  margin-bottom: 12px;
  color: #e6a23c;
  font-size: 13px;
}

.track-timeline {
  max-height: 420px;
  overflow-y: auto;
  padding: 4px 8px 0 2px;

  :deep(.el-timeline-item__content) {
    line-height: 1.6;
  }

  :deep(.el-timeline-item) {
    padding-bottom: 16px;
  }
}

.track-loc {
  margin-top: 2px;
  font-size: 12px;
  color: #909399;
}

/* 订单详情弹窗：原来字段是一串裸 div 挤在一起，这里统一间距 */
.detail-body {
  display: flex;
  flex-direction: column;
  gap: 20px;

  .detail-block {
    :deep(.el-descriptions__label) {
      width: 104px;
      color: #606266;
      background: #fafafa;
    }

    :deep(.el-descriptions__content) {
      line-height: 1.7;
      color: #303133;
    }
  }

  .detail-section {
    .section-title {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 10px;
      font-size: 14px;
      font-weight: 600;
      color: #303133;

      &::before {
        content: '';
        width: 3px;
        height: 14px;
        border-radius: 2px;
        background: var(--el-color-primary);
      }
    }

    .section-sub {
      font-size: 12px;
      font-weight: 400;
      color: #909399;
    }
  }
}
</style>
