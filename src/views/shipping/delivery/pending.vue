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
            <el-button type="primary" @click="batchImportDialogVisible = true">批量发货</el-button>
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
        <el-table-column type="selection" width="50" />
        <el-table-column prop="OrderDate" label="订单日期" width="100">
          <template #default="{ row }">
            {{ formatDate(row.OrderDate) }}
          </template>
        </el-table-column>
        <el-table-column prop="OrderNo" label="订单编号" min-width="200" />
        <el-table-column prop="SenderName" label="发件人" width="100" />
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
        <el-table-column prop="TotalAmount" label="订单总额" width="100">
          <template #default="{ row }">
            {{ row.TotalAmount }}
          </template>
        </el-table-column>
        
        <el-table-column label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusTagType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
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

    <!-- 批量发货导入弹窗 -->
    <el-dialog v-model="batchImportDialogVisible" title="批量发货导入" width="400px" :close-on-click-modal="false">
      <el-upload
        ref="uploadRef"
        :auto-upload="false"
        :on-change="handleFileChange"
        :before-upload="beforeBatchShipUpload"
        accept=".xlsx,.xls,.csv"
        :limit="1"
        :file-list="fileList"
      >
        <el-button type="primary">选择文件</el-button>
        <template #tip>
          <div class="el-upload__tip">仅支持Excel或CSV文件，大小不超过10MB</div>
        </template>
      </el-upload>
      <el-progress v-if="importing || importProgress > 0" :percentage="importProgress" status="success" style="margin: 16px 0;" />
      <div v-if="importResult" class="import-result">
        <el-alert
          :title="importResult.Message"
          :type="importResult.Success ? 'success' : 'error'"
          show-icon
          :closable="false"
          style="margin-bottom: 8px;"
        />
      </div>
      <template #footer>
        <el-button @click="batchImportDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="importing" @click="submitImport">开始导入</el-button>
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
              <span style="display: inline-block; min-width: 180px;">{{ item.ProductName }} × {{ item.Quantity }}</span>
              <span style="font-size:18px; margin-left: 16px;">□</span>
            </li>
          </ul>
          <div><strong>订单总额：</strong>{{ order.TotalAmount }}</div>
        </div>
      </div>
      <!-- 批量打印合计区域 -->
      <div v-if="selectedRows.length" style="margin-top: 32px; border-top: 2px solid #333; padding-top: 16px;">
        <div style="font-weight: bold; margin-bottom: 8px;">合计：</div>
        <div>所有订单总额合计：
          <span style="color: #f56c6c; font-weight: bold;">
            {{ batchTotalAmount }}
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
      title="订单发货"
      width="600px"
      destroy-on-close
    >
      <el-form :model="shipForm" label-width="100px">
        <el-row :gutter="20">
          <el-col :span="16">
            <el-form-item label="物流公司">
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
          <el-col :span="16">
            <el-form-item label="物流单号">
              <el-input v-model="shipForm.TrackingNo" placeholder="请输入物流单号"/> <!-- 物流单号输入框加宽 -->
            </el-form-item>
          </el-col>
        </el-row>
        <el-row :gutter="20">
          <el-col :span="16">
            <el-form-item label="运费">
              <!-- 运费改为数字文本框，宽度100%，步长0.01，最小0 -->
              <el-input-number v-model="shipForm.Freight" :min="0" :step="0.01" :precision="2" style="width: 100%;" placeholder="请输入运费" />
            </el-form-item>
          </el-col>
        </el-row>
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
          <el-button type="primary" @click="submitShip">确定</el-button>
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
              <span style="display: inline-block; min-width: 180px;">{{ item.ProductName }} × {{ item.Quantity }}</span>
              <span style="font-size:18px; margin-left: 16px;">□</span>
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

    <!-- 新增订单详情弹窗 -->
    <el-dialog v-model="detailDialogVisible" title="订单详情" width="600px" :close-on-click-modal="false">
      <div v-if="detailOrder">
        <div><b>订单编号：</b>{{ detailOrder.OrderNo }}</div>
        <div><b>订单日期：</b>{{ detailOrder.OrderDate }}</div>
        <div><b>经销商：</b>{{ detailOrder.DealerName }}</div>
        <div><b>发件人：</b>{{ detailOrder.SenderName }}</div>
        <div><b>收货人：</b>{{ detailOrder.ReceiverName }}（{{ detailOrder.ReceiverPhone }}）</div>
        <div><b>收货地址：</b>{{ detailOrder.ReceiverAddress }}</div>
        <div><b>订单总额：</b>{{ detailOrder.TotalAmount }}</div>
        <div><b>状态：</b>{{ getStatusText(detailOrder.Status) }}</div>
        <div><b>商品明细：</b></div>
        <ul>
          <li v-for="(item, idx) in detailOrder.OrderItemDetails || []" :key="idx">
            {{ item.ProductName }} × {{ item.Quantity }}
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
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { reqPendingOrderList, reqShipOrder, reqExportOrders, reqBatchShipOrder, reqCheckOrder } from '@/api/order'
import { getLogisticsCompanyNames } from '@/api/shipping'

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

// 批量发货导入弹窗显示状态
const batchImportDialogVisible = ref(false)

// 批量打印预览弹窗显示状态
const batchPrintDialogVisible = ref(false)

// 新增批量发货导入相关变量和方法
const fileList = ref<any[]>([]);
const importing = ref(false);
const importResult = ref<any>(null);
const importProgress = ref(0);

const handleFileChange = (file: any) => {
  fileList.value = [file];
};

const beforeBatchShipUpload = (file: File) => {
  const isExcel = file.type === 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'
    || file.type === 'application/vnd.ms-excel'
    || file.name.endsWith('.csv');
  const isLt10M = file.size / 1024 / 1024 < 10;
  if (!isExcel) {
    ElMessage.error('只能上传Excel或CSV文件！');
    return false;
  }
  if (!isLt10M) {
    ElMessage.error('文件大小不能超过10MB！');
    return false;
  }
  return true;
};

const submitImport = async () => {
  if (fileList.value.length === 0) {
    ElMessage.warning('请选择要导入的文件');
    return;
  }
  importing.value = true;
  importProgress.value = 0;
  importResult.value = null;

  // 模拟进度条递增
  const timer = setInterval(() => {
    if (importProgress.value < 90) {
      importProgress.value += 10;
    }
  }, 200);

  try {
    const formData = new FormData();
    formData.append('file', fileList.value[0].raw);
    const res = await reqBatchShipOrder(formData);
    clearInterval(timer);
    importProgress.value = 100;
    if (res && res.Success) {
      importResult.value = res;
      ElMessage.success(res.Message || '批量发货导入成功');
      batchImportDialogVisible.value = false;
      getOrderList();
    } else {
      importResult.value = res;
      ElMessage.error(res.Message || '批量发货失败');
    }
  } catch (err) {
    clearInterval(timer);
    importProgress.value = 0;
    ElMessage.error('批量发货导入失败，请检查网络或服务器');
  } finally {
    importing.value = false;
  }
};

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
// 单个订单发货表单
const shipForm = reactive({
  OrderId: '',         // 订单ID
  Carrier: '',         // 物流公司编码
  TrackingNo: '',      // 物流单号
  Freight: '',         // 运费
  Remark: ''           // 备注
})

// 单个订单打印预览弹窗显示状态
const singlePrintDialogVisible = ref(false)
// 当前要打印的订单对象
const printOrder = ref<any>(null)

// 新增订单详情弹窗相关变量
const detailDialogVisible = ref(false);
const detailOrder = ref<any>(null);

// 计算所有订单总额合计
const batchTotalAmount = computed(() => {
  if (!selectedRows.value || !selectedRows.value.length) return 0;
  return selectedRows.value.reduce((sum, order) => sum + (Number(order.TotalAmount) || 0), 0).toFixed(2);
});

// 计算每个商品的总数量合计
const batchProductTotalMap = computed(() => {
  const map: Record<string, number> = {};
  if (!selectedRows.value || !selectedRows.value.length) return map;
  selectedRows.value.forEach(order => {
    (order.OrderItems || []).forEach((item: any) => {
      if (!item.ProductName) return;
      if (!map[item.ProductName]) map[item.ProductName] = 0;
      map[item.ProductName] += Number(item.Quantity) || 0;
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
      OrderNo: queryParams.orderNo || undefined, // 订单编号
      ReceiverName: queryParams.receiver || undefined, // 收货人
      ReceiverPhone: queryParams.receiverPhone || undefined // 收货电话
    }
    const result = await reqPendingOrderList(params)
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
    ElMessage.success('获取待发货订单列表成功');
  } catch (error) {
    tableData.value = []
    total.value = 0
    ElMessage.error('获取订单列表失败');
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
    ElMessage.error('导出失败，请稍后重试');
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
    case 3: return '全部发货';
    case 4: return '部分发货';
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
  shipForm.Carrier = '';
  shipForm.TrackingNo = '';
  shipForm.Freight = '';
  shipForm.Remark = '';
  dialogVisible.value = true;
}

// 完善 handleDetail 方法
const handleDetail = async (row: any) => {
  try {
    const res = await reqCheckOrder(row.Id);
    if (res && (res.Success || res.status === 200)) {
      detailOrder.value = res.data || res; // 兼容不同返回结构
      detailDialogVisible.value = true;
    } else {
      ElMessage.error(res.Message || res.message || '获取订单详情失败');
    }
  } catch (e) {
    ElMessage.error('获取订单详情失败');
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
  if (!shipForm.Carrier || !shipForm.TrackingNo) {
    ElMessage.warning('请填写完整物流信息');
    return;
  }
  if (shipForm.Freight === '' || isNaN(Number(shipForm.Freight)) || Number(shipForm.Freight) < 0) {
    ElMessage.warning('请填写有效的运费');
    return;
  }
  try {
    // 调用发货API，等待后端返回
    const res = await reqShipOrder({
      OrderId: shipForm.OrderId,
      Carrier: shipForm.Carrier,
      TrackingNo: shipForm.TrackingNo,
      Freight: Number(shipForm.Freight),
      Remark: shipForm.Remark
    });
    // 根据后端返回的Success字段判断
    if (res && res.Success) {
      ElMessage.success(res.Message || '发货成功');
      dialogVisible.value = false;
      getOrderList(); // 刷新列表
    } else {
      ElMessage.error(res.Message || '发货失败');
    }
  } catch (e) {
    ElMessage.error('发货失败，请稍后重试');
    console.error('发货异常：', e);
  }
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
</style>
