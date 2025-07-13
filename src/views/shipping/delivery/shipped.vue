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
        <el-table-column type="selection" width="55" />
        <el-table-column prop="OrderNo" label="订单编号" min-width="200">
          <template #default="{ row }">
            <div>
              <div><b>{{ row.OrderNo }}</b></div>
              <div style="font-size: 12px; color: #909399;">发货时间：{{ row.OrderDate }}</div>
            </div>
          </template>
        </el-table-column>
       
        <el-table-column label="收货信息" min-width="220">
          <template #default="{ row }">
            <div class="receiver-info">
              <div>收货人：{{ row.ReceiverName }}</div>
              <div>电话：{{ row.ReceiverPhone }}</div>
              <div>地址：{{ row.ReceiverAddress }}</div>
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
        <el-table-column label="物流公司" width="120">
          <template #default="{ row }">
            <!-- 展示第一个发货记录的物流公司，如无则显示'-' -->
            {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].LogisticsCompany : '-' }}
          </template>
        </el-table-column>
        <el-table-column label="物流单号" min-width="180">
          <template #default="{ row }">
            <!-- 展示第一个发货记录的物流单号，如无则显示'-' -->
            {{ row.ShipmentInfos && row.ShipmentInfos.length > 0 ? row.ShipmentInfos[0].TrackingNo : '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="Status" label="物流状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getLogisticsStatusType(row.Status)">
              {{ getLogisticsStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>       
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleTrack(row)">物流跟踪</el-button>
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
      title="物流跟踪"
      width="800px"
      destroy-on-close
    >
      <el-timeline>
        <el-timeline-item
          v-for="(activity, index) in logisticsTrack"
          :key="index"
          :timestamp="activity.time"
          :type="index === 0 ? 'primary' : ''"
        >
          {{ activity.content }}
        </el-timeline-item>
      </el-timeline>
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
    <el-dialog v-model="detailDialogVisible" title="订单详情" width="600px" :close-on-click-modal="false">
      <div v-if="detailOrder">
        <div><b>订单编号：</b>{{ detailOrder.OrderNo }}</div>
        <div><b>订单日期：</b>{{ detailOrder.OrderDate }}</div>
        <div><b>经销商：</b>{{ detailOrder.DealerName }}</div>
        <div><b>发件人：</b>{{ detailOrder.SenderName }}</div>
        <div><b>收货人：</b>{{ detailOrder.ReceiverName }}（{{ detailOrder.ReceiverPhone }}）</div>
        <div><b>收货地址：</b>{{ detailOrder.ReceiverAddress }}</div>
        <div><b>订单总额：</b>{{ detailOrder.TotalAmount }}</div>
        <div><b>状态：</b>{{ getLogisticsStatusText(detailOrder.Status) }}</div>
        <div><b>商品明细：</b></div>
        <ul>
          <li v-for="(item, idx) in detailOrder.OrderItems || []" :key="idx">
            {{ item.ProductName }} × {{ item.Quantity }}
          </li>
        </ul>
        <div><b>备注：</b>{{ detailOrder.Remark }}</div>
        <div><b>物流公司：</b>{{ detailOrder.ShipmentInfos && detailOrder.ShipmentInfos.length > 0 ? detailOrder.ShipmentInfos[0].LogisticsCompany : '-' }}</div>
        <div><b>物流单号：</b>{{ detailOrder.ShipmentInfos && detailOrder.ShipmentInfos.length > 0 ? detailOrder.ShipmentInfos[0].TrackingNo : '-' }}</div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { reqShippedOrderList, reqCheckOrder } from '@/api/order' // 导入新的已发货订单接口和详情接口
import { getLogisticsCompanyNames } from '@/api/shipping'

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
const logisticsTrack = ref([ // 模拟数据，待接入物流接口后替换
  {
    time: '2024-01-20 10:00:00',
    content: '快件已签收，签收人：张先生'
  },
  {
    time: '2024-01-20 09:30:00',
    content: '快件已到达【北京朝阳区望京营业点】'
  },
  {
    time: '2024-01-19 20:00:00',
    content: '快件已从【北京转运中心】发出'
  },
  {
    time: '2024-01-19 18:00:00',
    content: '快件已到达【北京转运中心】'
  }
])

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
      OrderNo: queryParams.orderNo || undefined,
      TrackingNo: queryParams.trackingNo || undefined,
      LogisticsCompany: queryParams.logisticsCompany || undefined,
      ShipTime: queryParams.shipTime || undefined
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
const handleTrack = (row: any) => {
  // TODO: 调用物流跟踪接口，此处模拟数据需要替换
  trackDialogVisible.value = true
  ElMessage.info(`物流跟踪订单：${row.OrderNo}`);
}

// 详情弹窗相关变量
const detailDialogVisible = ref(false)
const detailOrder = ref<any>(null)

// 查看详情方法，调用reqCheckOrder获取详情
const handleDetail = async (row: any) => {
  try {
    const res = await reqCheckOrder(row.Id)
    if (res && (res.Success || res.status === 200)) {
      detailOrder.value = res.data || res // 兼容不同返回结构
      detailDialogVisible.value = true
    } else {
      ElMessage.error(res.Message || res.message || '获取订单详情失败')
    }
  } catch (e) {
    ElMessage.error('获取订单详情失败')
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

// 格式化价格
const formatPrice = (price: number) => {
  if (!price) return '0.00'
  return Number(price).toFixed(2)
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

:deep(.el-timeline-item__content) {
  color: #666;
}
</style>
