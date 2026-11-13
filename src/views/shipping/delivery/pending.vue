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
        <!-- 新增：收货人电话搜索条件 -->
        <el-form-item label="收货人电话">
          <el-input v-model="queryParams.receiverPhone" placeholder="请输入收货人电话" clearable />
        </el-form-item>
        <!-- 移除发货状态搜索条件 -->
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
            <el-button type="primary" @click="handleBatchPrint">批量打印</el-button>
            <el-button type="primary" @click="openBatchShip">批量发货</el-button>
            <el-button type="success" @click="handleExport">导出订单</el-button>
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
        <el-table-column type="selection" width="45" />
        <el-table-column prop="OrderDate" label="订单日期" width="95">
          <template #default="{ row }">
            {{ formatDate(row.OrderDate) }}
          </template>
        </el-table-column>
        <el-table-column prop="OrderNo" label="订单编号" min-width="200" class-name="order-no-col">
          <template #default="{ row }">
            <div>{{ row.OrderNo }}</div>
            <!-- 拆单子单：让操作员知道这单是缺货拆出来的，不是凭空多出来的 -->
            <el-tooltip v-if="row.SplitFromNo" :content="`由订单 ${row.SplitFromNo} 拆出的缺货子单`" placement="top">
              <el-tag type="warning" effect="plain" size="small" style="margin-top: 2px;">拆单子单</el-tag>
            </el-tooltip>
          </template>
        </el-table-column>
        <el-table-column prop="SenderName" label="发件人" width="90" />
        <el-table-column label="收件人信息" min-width="170">
          <template #default="{ row }">
            <div class="receiver-info">
              <div>收货人：{{ row.ReceiverName }}</div>
              <div>电话：{{ row.ReceiverPhone }}</div>
              <div>地址：{{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="商品信息" min-width="170">
          <template #default="{ row }">
            <div class="product-list">
              <div v-for="(item, idx) in row.OrderItems || []" :key="idx" class="product-item">
                {{ item.ProductName }} × {{ fmtQty(boxQty(item)) }}
              </div>
              <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">暂无产品信息</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="合计箱数" width="90" align="center">
          <template #default="{ row }">
            {{ fmtQty(orderBoxTotal(row)) }}
          </template>
        </el-table-column>
        
        <el-table-column label="配送方式" width="90" align="center">
          <template #default="{ row }">
            <el-tag :type="row.DeliveryType === 1 ? 'warning' : 'info'" effect="plain">
              {{ row.DeliveryType === 1 ? '自提' : row.DeliveryType === 2 ? '到付' : '现付' }}
            </el-tag>
          </template>
        </el-table-column>

        <el-table-column label="状态" width="90">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="190" fixed="right">
          <template #default="{ row }">
            <!-- 单个订单发货按钮 -->
            <el-button type="primary" link @click="handleShip(row)">发货</el-button>
            <el-button type="primary" link @click="handleDetail(row)">详情</el-button>
            <!-- 单个订单打印按钮 -->
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

    <!-- 勾选批量发货：汇总所选订单后一次发完 -->
    <el-dialog v-model="batchShipDialogVisible" title="批量发货" width="760px" :close-on-click-modal="false">
      <el-alert
        type="info"
        :closable="false"
        show-icon
        style="margin-bottom: 12px;"
        :title="`已勾选 ${batchShipRows.length} 单，按每单剩余待发量一次性发完；合计 ${fmtQty(batchShipRemainTotal)} 箱`"
      />
      <el-table :data="batchShipRows" border size="small" max-height="280" row-key="Id">
        <el-table-column prop="OrderNo" label="订单编号" min-width="200" />
        <el-table-column label="收件人" width="110">
          <template #default="{ row }">{{ row.ReceiverName }}</template>
        </el-table-column>
        <el-table-column label="商品明细（箱）" min-width="240">
          <template #default="{ row }">
            <div v-for="(item, idx) in row.OrderItems || []" :key="idx" class="ship-item-line">
              {{ item.ProductName }} × {{ fmtQty(remainQty(item)) }}
            </div>
            <div v-if="!row.OrderItems || row.OrderItems.length === 0" class="no-products">暂无产品信息</div>
          </template>
        </el-table-column>
        <el-table-column label="待发箱数" width="110" align="center">
          <template #default="{ row }">{{ fmtQty(orderRemainTotal(row)) }}</template>
        </el-table-column>
      </el-table>

      <div class="ship-summary">
        <span class="label">各商品待发合计：</span>
        <span v-for="(qty, name) in batchRemainMap" :key="name" class="summary-tag">{{ name }} × {{ fmtQty(qty) }}</span>
        <span v-if="!Object.keys(batchRemainMap).length" class="empty">—</span>
      </div>

      <el-form :model="batchShipForm" label-width="90px" style="margin-top: 12px;">
        <el-form-item label="物流公司">
          <el-select v-model="batchShipForm.Carrier" placeholder="可不填，发货后再补" clearable style="width: 260px;">
            <el-option
              v-for="item in logisticsCompanyList"
              :key="item.Id"
              :label="item.Name"
              :value="item.Code"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="每单运费">
          <el-input-number v-model="batchShipForm.Freight" :min="0" :step="0.01" :precision="2" />
          <span class="ship-mode-tip">仅现付订单计入，到付/自提不收运费</span>
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="batchShipForm.Remark" placeholder="默认：勾选批量发货" />
        </el-form-item>
      </el-form>

      <template #footer>
        <el-button @click="batchShipDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="batchShipping" @click="submitBatchShip">
          确认发货（{{ batchShipRows.length }} 单）
        </el-button>
      </template>
    </el-dialog>

    <!-- 批量打印预览弹窗 -->
    <el-dialog v-model="batchPrintDialogVisible" title="批量打印预览" width="800px" :close-on-click-modal="false">
      <div id="printArea">
        <div v-for="order in selectedRows" :key="order.Id" class="print-order-item" style="margin-bottom: 24px; border-bottom: 1px dashed #ccc; padding-bottom: 12px;">
          <div><strong>订单编号：</strong>{{ order.OrderNo }}</div>
          <div><strong>经销商：</strong>{{ order.DealerName }}</div>
          <div><strong>发件人：</strong>{{ order.SenderName }}</div>          
          <div><strong>订单日期：</strong>{{ formatDate(order.OrderDate) }}</div>
          <div><strong>收货人：</strong>{{ order.ReceiverName }}（{{ order.ReceiverPhone }}）</div>
          <div><strong>收货地址：</strong>{{ order.ReceiverAddress }}</div>
          <div><strong>商品明细：</strong></div>
          <ul style="margin-left: 24px;">
            <li v-for="(item, idx) in order.OrderItems || []" :key="idx" style="display: flex; align-items: center;">
              <span style="display: inline-block; min-width: 180px;">{{ item.ProductName }} × {{ fmtQty(boxQty(item)) }}</span>
              <span style="font-size:18px; margin-left: 16px;">□</span>
            </li>
          </ul>
          <div><strong>合计箱数：</strong>{{ fmtQty(orderBoxTotal(order)) }}</div>
        </div>
      </div>
      <!-- 批量打印合计区域 -->
      <div v-if="selectedRows.length" style="margin-top: 32px; border-top: 2px solid #333; padding-top: 16px;">
        <div style="font-weight: bold; margin-bottom: 8px;">合计：</div>
        <div>所有订单合计箱数：
          <span style="color: #f56c6c; font-weight: bold;">
            {{ fmtQty(batchBoxTotal) }} 箱
          </span>
        </div>
        <div style="margin-top: 8px;">各商品总数量：</div>
        <ul style="margin-left: 24px;">
          <li v-for="(qty, name) in batchProductTotalMap" :key="name">
            {{ name }} × {{ qty }}
          </li>
        </ul>
      </div>
      <template #footer>
        <el-button @click="batchPrintDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="printBatchOrders">打印</el-button>
      </template>
    </el-dialog>

    <!-- 单个订单发货对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="shipForm.DeliveryType === 1 ? '确认客户自提' : '物流发货'"
      width="600px"
      destroy-on-close
    >
      <el-form :model="shipForm" label-width="100px">
        <!-- 配送方式由订单本身决定，不能在这里改，只做展示 -->
        <el-row :gutter="20">
          <el-col :span="18">
            <el-form-item label="配送方式">
              <el-tag :type="shipForm.DeliveryType === 1 ? 'warning' : 'primary'" effect="plain">
                {{ shipForm.DeliveryType === 1 ? '客户自提' : shipForm.DeliveryType === 2 ? '物流到付' : '物流现付' }}
              </el-tag>
              <span class="ship-mode-tip">下单时已确定，不可修改</span>
            </el-form-item>
          </el-col>
        </el-row>

        <!-- 客户自提：司机与车牌是提货凭证，必须填 -->
        <template v-if="shipForm.DeliveryType === 1">
          <el-row :gutter="20">
            <el-col :span="18">
              <el-form-item label="司机姓名" required>
                <el-input v-model="shipForm.DriverName" placeholder="请输入司机姓名" maxlength="20" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="18">
              <el-form-item label="司机电话">
                <el-input v-model="shipForm.DriverPhone" placeholder="选填" maxlength="20" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="18">
              <el-form-item label="车牌号" required>
                <el-input v-model="shipForm.CarPlateNumber" placeholder="如 粤A12345" maxlength="20" />
              </el-form-item>
            </el-col>
          </el-row>
        </template>

        <!-- 物流配送：物流公司 + 单号为必填 -->
        <template v-else>
          <el-row :gutter="20">
            <el-col :span="18">
              <el-form-item label="物流公司" required>
                <el-select v-model="shipForm.Carrier" placeholder="请选择物流公司" style="width: 100%">
                  <el-option
                    v-for="item in logisticsCompanyList"
                    :key="item.Id"
                    :label="item.Name"
                    :value="item.Code"
                  />
                </el-select>
              </el-form-item>
            </el-col>
          </el-row>
          <el-row :gutter="20">
            <el-col :span="18">
              <el-form-item label="物流单号" required>
                <el-input v-model="shipForm.TrackingNo" placeholder="请输入物流单号" />
              </el-form-item>
            </el-col>
          </el-row>
          <el-row v-if="shipForm.DeliveryType === 3" :gutter="20">
            <el-col :span="18">
              <el-form-item label="运费" required>
                <!-- 只有现付订单由发货方付运费；到付由收件人付，自提没有运费 -->
                <el-input-number v-model="shipForm.Freight" :min="0" :step="0.01" :precision="2" style="width: 100%;" placeholder="请输入运费" />
              </el-form-item>
            </el-col>
          </el-row>
        </template>

        <el-form-item label="发货备注">
          <el-input
            v-model="shipForm.Remark"
            type="textarea"
            :rows="3"
            placeholder="请输入发货备注"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" :loading="shipping" @click="submitShip">确定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 单个订单打印预览弹窗 -->
    <el-dialog v-model="singlePrintDialogVisible" title="订单打印预览" width="600px" :close-on-click-modal="false">
      <div id="singlePrintArea">
        <div v-if="printOrder">
          <div><strong>经销商：</strong>{{ printOrder.DealerName }}</div>
          <div><strong>发件人：</strong>{{ printOrder.SenderName }}</div>
          <div><strong>订单编号：</strong>{{ printOrder.OrderNo }}</div>
          <div><strong>订单日期：</strong>{{ formatDate(printOrder.OrderDate) }}</div>
          <div><strong>收货人：</strong>{{ printOrder.ReceiverName }}（{{ printOrder.ReceiverPhone }}）</div>
          <div><strong>收货地址：</strong>{{ printOrder.ReceiverAddress }}</div>
          <div><strong>商品明细：</strong></div>
          <ul style="margin-left: 24px;">
            <li v-for="(item, idx) in printOrder.OrderItems || []" :key="idx" style="display: flex; align-items: center;">
              <span style="display: inline-block; min-width: 180px;">{{ item.ProductName }} × {{ fmtQty(boxQty(item)) }}</span>
              <span style="font-size:18px; margin-left: 16px;">□</span>
            </li>
          </ul>
          <div><strong>合计箱数：</strong>{{ fmtQty(orderBoxTotal(printOrder)) }}</div>
        </div>
      </div>
      <template #footer>
        <el-button @click="singlePrintDialogVisible = false">关闭</el-button>
        <el-button type="primary" @click="printSingleOrder">打印</el-button>
      </template>
    </el-dialog>

    <!-- 新增订单详情弹窗 -->
    <el-dialog v-model="detailDialogVisible" title="订单详情" width="600px" :close-on-click-modal="false">
      <div v-if="detailOrder">
        <div><b>订单编号：</b>{{ detailOrder.OrderNo }}</div>
        <div><b>订单日期：</b>{{ detailOrder.OrderDate }}</div>
        <div><b>经销商：</b>{{ detailOrder.DealerName }}</div>
        <div><b>发件人：</b>{{ detailOrder.SenderName }}</div>
        <div><b>收货人：</b>{{ detailOrder.ReceiverName }}（{{ detailOrder.ReceiverPhone }}）</div>
        <div><b>收货地址：</b>{{ detailOrder.ReceiverAddress }}</div>
        <div><b>合计箱数：</b>{{ fmtQty(orderBoxTotal(detailOrder)) }}</div>
        <div><b>状态：</b>{{ getStatusText(detailOrder.Status) }}</div>
        <div><b>商品明细：</b></div>
        <ul>
          <li v-for="(item, idx) in detailOrder.OrderItemDetails || []" :key="idx">
            {{ item.ProductName }} × {{ fmtQty(boxQty(item)) }}
          </li>
        </ul>
        <div><b>备注：</b>{{ detailOrder.Remark }}</div>
      </div>
      <template #footer>
        <el-button @click="detailDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { showError, getList, getTotal } from '@/utils/request'
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqPendingOrderList, reqShipOrder, reqExportOrders, reqBatchShipSelected, reqCheckOrder } from '@/api/order'
import { getLogisticsCompanyNames } from '@/api/shipping'
import { boxQty, remainQty, orderBoxTotal, orderRemainTotal, fmtQty } from '@/utils/orderQty'

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNo: '',
  receiver: '',
  // status: '', // 移除发货状态参数
  receiverPhone: '' // 新增收货人电话参数
})

// 表格数据
const loading = ref(false)
const tableData = ref<any[]>([])
// 分页相关变量
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const selectedRows = ref([])

// 批量打印预览弹窗显示状态
const batchPrintDialogVisible = ref(false)

// ===== 勾选批量发货 =====
const batchShipDialogVisible = ref(false)
const batchShipping = ref(false)
const batchShipForm = reactive({
  Carrier: '',
  Freight: 0,
  Remark: ''
})

// 箱数计算统一走 @/utils/orderQty（boxQty / remainQty / orderBoxTotal / orderRemainTotal）

// 所选订单的待发箱数合计
const batchShipRemainTotal = computed(() =>
  (selectedRows.value || []).reduce((sum: number, order: any) => sum + orderRemainTotal(order), 0).toFixed(2)
)

// 所选订单按商品汇总的待发箱数
const batchRemainMap = computed(() => {
  const map: Record<string, number> = {}
  if (!selectedRows.value || !selectedRows.value.length) return map
  selectedRows.value.forEach((order: any) => {
    (order.OrderItems || []).forEach((item: any) => {
      const qty = remainQty(item)
      if (!item.ProductName || qty <= 0) return
      map[item.ProductName] = (map[item.ProductName] || 0) + qty
    })
  })
  return map
})

// 本次要发货的订单：勾选里过滤掉已经发完的（列表数据可能已过期，勾了也发不出去）
// 批量发货只发物流单：自提单要核对司机和车牌，必须逐单在发货弹层里确认
const batchShipRows = computed(() =>
  (selectedRows.value || []).filter(
    (o: any) => orderRemainTotal(o) > 0 && Number(o.DeliveryType) !== 1
  )
)

// 打开批量发货汇总弹窗
const openBatchShip = () => {
  if (!selectedRows.value || selectedRows.value.length === 0) {
    ElMessage.warning('请先勾选要发货的订单')
    return
  }
  if (batchShipRows.value.length === 0) {
    ElMessage.warning('所选订单都没有待发数量，请刷新列表后重试')
    return
  }
  const skipped = selectedRows.value.length - batchShipRows.value.length
  if (skipped > 0) {
    const selfPickupCount = (selectedRows.value || []).filter(
      (o: any) => Number(o.DeliveryType) === 1
    ).length
    if (selfPickupCount > 0) {
      ElMessage.warning(`已跳过 ${selfPickupCount} 张自提单（自提需逐单核对司机与车牌），其余 ${skipped - selfPickupCount} 单无待发数量`)
    } else {
      ElMessage.warning(`已自动跳过 ${skipped} 单没有待发数量的订单`)
    }
  }
  batchShipForm.Carrier = ''
  batchShipForm.Freight = 0
  batchShipForm.Remark = ''
  batchShipDialogVisible.value = true
}

// 提交批量发货
const submitBatchShip = async () => {
  if (batchShipping.value) return
  const orderIds = batchShipRows.value.map((row: any) => Number(row.Id))
  if (!orderIds.length) {
    ElMessage.warning('所选订单都没有待发数量，请刷新列表后重试')
    return
  }
  batchShipping.value = true
  try {
    await reqBatchShipSelected({
      OrderIds: orderIds,
      Carrier: batchShipForm.Carrier || undefined,
      Freight: Number(batchShipForm.Freight) || 0,
      Remark: batchShipForm.Remark || undefined
    })
    ElMessage.success('批量发货成功')
    batchShipDialogVisible.value = false
  } catch (e: any) {
    // 部分/全部失败时后端把逐单原因拼在 Message 里，直接展示原文
    if (e?.Message) {
      ElMessageBox.alert(e.Message, '批量发货结果', { confirmButtonText: '知道了', type: 'warning' })
      batchShipDialogVisible.value = false
    } else {
      showError(e, '批量发货失败：接口无响应，请检查后端服务是否正常')
    }
  }
  batchShipping.value = false
  getOrderList()
}

// 批量打印方法
const handleBatchPrint = () => {
  if (!selectedRows.value || selectedRows.value.length === 0) {
    ElMessage.warning('请先选择要打印的订单');
    return;
  }
  batchPrintDialogVisible.value = true;
}

// 执行打印
const printBatchOrders = () => {
  // 只打印弹窗内容
  const printContent = document.getElementById('printArea')?.innerHTML;
  if (!printContent) return;
  const win = window.open('', '', 'width=900,height=600');
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
  `);
  win!.document.close();
  win!.focus();
  win!.print();
  win!.close();
}

// 单个订单发货弹窗显示状态
const dialogVisible = ref(false)
// 发货提交中（防重复点击，否则第二次会因订单已发货被拒，看起来像发货失败）
const shipping = ref(false)
// 单个订单发货表单
const shipForm = reactive({
  OrderId: '',         // 订单ID
  DeliveryType: 2,     // 1=客户自提 2=物流配送
  Carrier: '',         // 物流公司编码
  TrackingNo: '',      // 物流单号
  Freight: '' as number | '',  // 运费
  Remark: '',          // 备注
  DriverName: '',      // 司机姓名（自提必填）
  DriverPhone: '',     // 司机电话
  CarPlateNumber: ''   // 车牌号（自提必填）
})

// 单个订单打印预览弹窗显示状态
const singlePrintDialogVisible = ref(false)
// 当前要打印的订单对象
const printOrder = ref<any>(null)

// 新增订单详情弹窗相关变量
const detailDialogVisible = ref(false);
const detailOrder = ref<any>(null);

// 计算所有订单合计箱数
const batchBoxTotal = computed(() => {
  if (!selectedRows.value || !selectedRows.value.length) return 0;
  return selectedRows.value.reduce((sum, order) => sum + orderBoxTotal(order), 0);
});

// 计算每个商品的总箱数合计
const batchProductTotalMap = computed(() => {
  const map: Record<string, number> = {};
  if (!selectedRows.value || !selectedRows.value.length) return map;
  selectedRows.value.forEach(order => {
    (order.OrderItems || []).forEach((item: any) => {
      if (!item.ProductName) return;
      if (!map[item.ProductName]) map[item.ProductName] = 0;
      map[item.ProductName] += boxQty(item);
    });
  });
  return map;
});

// 物流公司名称列表（类型为any[]，兼容后端返回字段Id、Name、Code、IsEnabled）
const logisticsCompanyList = ref<any[]>([]);

// 获取订单列表数据
const getOrderList = async () => {
  loading.value = true
  try {
    const params = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value,
      OrderNumber: queryParams.orderNo || undefined, // 订单编号
      ReceiverName: queryParams.receiver || undefined, // 收货人
      ReceiverPhone: queryParams.receiverPhone || undefined // 收货电话
    }
    const result = await reqPendingOrderList(params)
    tableData.value = getList(result) // 订单数据
    // 分页信息从headers['x-pagination']获取
    total.value = getTotal(result)
    ElMessage.success('获取待发货订单列表成功');
  } catch (error) {
    tableData.value = []
    total.value = 0
    showError(error, '获取订单列表失败');
  } finally {
    loading.value = false
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
  queryParams.receiver = '';
  // queryParams.status = ''; // 移除发货状态参数
  queryParams.receiverPhone = '';
  queryParams.pageNum = 1; // 重置时也重置页码
  getOrderList();
}

// 表格选择
const handleSelectionChange = (selection: any[]) => {
  selectedRows.value = selection
}

// 导出
const handleExport = async () => {
  if (!selectedRows.value || selectedRows.value.length === 0) {
    ElMessage.warning('请先选择要导出的订单');
    return;
  }
  // 获取选中的订单ID数组
  const orderIds = selectedRows.value.map((row: any) => row.Id);
  try {
    // 调用后端导出API，返回AxiosResponse，文件流在res.data中
    const res = await reqExportOrders(orderIds);
    // 创建Blob对象，指定Excel类型
    const blob = new Blob([res.data], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    // 创建下载链接
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = '订单导出.xlsx'; // 可自定义文件名
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
    ElMessage.success('导出成功');
  } catch (error) {
    showError(error, '导出失败，请稍后重试');
  }
}

// 格式化日期为YYYY-MM-DD，只显示年月日
const formatDate = (dateStr: string) => {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  const year = d.getFullYear();
  const month = String(d.getMonth() + 1).padStart(2, '0');
  const day = String(d.getDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}
// 状态文字映射
const getStatusText = (status: number | string) => {
  switch (Number(status)) {
    case 2: return '未发货';
    case 3: return '部分发货';
    case 4: return '已发货';
    default: return '未知';
  }
}
// 状态标签颜色映射
const getStatusTagType = (status: number | string) => {
  switch (Number(status)) {
    case 2: return 'warning'; // 黄色
    case 3: return 'success'; // 绿色
    case 4: return 'info';    // 蓝色
    default: return 'default';
  }
}
// 打开发货弹窗，填充当前订单信息
const handleShip = (row: any) => {
  shipForm.OrderId = row.Id;
  // 配送方式由订单决定：1=自提 2=到付 3=现付（后端会用这个值回写订单，不能归一成 2）
  shipForm.DeliveryType = Number(row.DeliveryType) || 2;
  shipForm.Carrier = '';
  shipForm.TrackingNo = '';
  shipForm.Freight = '';
  shipForm.Remark = '';
  shipForm.DriverName = row.DriverName || '';
  shipForm.DriverPhone = row.DriverPhone || '';
  shipForm.CarPlateNumber = row.CarPlateNumber || '';
  dialogVisible.value = true;
}

// 完善 handleDetail 方法
const handleDetail = async (row: any) => {
  try {
    const res = await reqCheckOrder(row.Id);
    detailOrder.value = res;
    detailDialogVisible.value = true;
  } catch (e) {
    showError(e, '获取订单详情失败');
  }
}

// 打印
const handlePrint = (row: any) => {
  printOrder.value = row;
  singlePrintDialogVisible.value = true;
}

// 执行单个订单打印
const printSingleOrder = () => {
  const printContent = document.getElementById('singlePrintArea')?.innerHTML;
  if (!printContent) return;
  const win = window.open('', '', 'width=700,height=500');
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
  `);
  win!.document.close();
  win!.focus();
  win!.print();
  win!.close();
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

// 提交发货
const submitShip = async () => {
  // 防重复提交：连点两次时第二次会因订单已发货被拒，用户会误以为发货失败
  if (shipping.value) return
  const isSelfPickup = shipForm.DeliveryType === 1
  // 运费只在现付（3）时需要填：到付由收件人付、自提没有运费
  const isCashPay = shipForm.DeliveryType === 3
  if (isSelfPickup) {
    // 自提凭证：司机姓名 + 车牌号
    if (!shipForm.DriverName.trim()) {
      ElMessage.warning('请填写司机姓名，自提凭证需要它')
      return
    }
    if (!shipForm.CarPlateNumber.trim()) {
      ElMessage.warning('请填写车牌号，自提凭证需要它')
      return
    }
  } else {
    if (!shipForm.Carrier || !shipForm.TrackingNo) {
      ElMessage.warning('请填写完整物流信息');
      return;
    }
    if (isCashPay && (shipForm.Freight === '' || isNaN(Number(shipForm.Freight)) || Number(shipForm.Freight) <= 0)) {
      ElMessage.warning('现付订单请填写运费');
      return;
    }
  }
  shipping.value = true;
  try {
    // 调用发货API，等待后端返回
    await reqShipOrder({
      OrderId: shipForm.OrderId,
      DeliveryType: shipForm.DeliveryType,
      Carrier: isSelfPickup ? '自提' : shipForm.Carrier,
      TrackingNo: isSelfPickup ? '' : shipForm.TrackingNo,
      Freight: isCashPay ? Number(shipForm.Freight) : 0,
      Remark: shipForm.Remark,
      DriverName: shipForm.DriverName.trim(),
      DriverPhone: shipForm.DriverPhone.trim(),
      CarPlateNumber: shipForm.CarPlateNumber.trim()
    });
    // 统一信封：成功时拿到的是 Data（发货接口 Data 为 null，所以这里不依赖返回值）
    ElMessage.success('发货成功')
    dialogVisible.value = false;
    getOrderList(); // 刷新列表
  } catch (e: any) {
    // 业务失败已由拦截器提示真实原因（如库存不足）；这里只兜底网络异常
    if (!e?.Message) {
      showError(e, '发货失败：接口无响应，请检查后端服务是否正常');
    }
    console.error('发货异常：', e);
  } finally {
    shipping.value = false;
  }
}

// 初始化
onMounted(async () => {
  getOrderList()
  // 获取物流公司名称列表
  const res = await getLogisticsCompanyNames()
  if (Array.isArray(res)) {
    logisticsCompanyList.value = getList(res)
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

  /* 21 位订单号折行太难认，缩一点字号保持单行 */
  :deep(.order-no-col .cell) {
    white-space: nowrap;
    font-size: 13px;
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

.import-result {
  margin-top: 16px;
}

.ship-item-line {
  line-height: 1.7;
}

.ship-summary {
  margin-top: 12px;
  padding: 10px 12px;
  background: #f5f7fa;
  border-radius: 4px;
  font-size: 13px;
  line-height: 2;

  .label {
    color: #606266;
    margin-right: 8px;
  }

  .summary-tag {
    display: inline-block;
    margin-right: 10px;
    padding: 0 8px;
    background: #fff;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    color: #303133;
  }

  .empty {
    color: #c0c4cc;
  }
}

.ship-mode-tip {
  margin-left: 10px;
  font-size: 12px;
  color: #909399;
}
</style>
