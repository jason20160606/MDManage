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
              <el-date-picker v-model="queryForm.DateRange" type="daterange" range-separator="至" start-placeholder="开始日期"
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

      <!-- 表格操作按钮 -->
      <div style="margin-bottom: 10px; display: flex; align-items: center; gap: 10px;">
        <el-tooltip
          :disabled="selectedDealerCount <= 1"
          content="一次只能审核同一个经销商的订单，请按经销商分开勾选提交"
          placement="top"
        >
          <span>
            <el-button type="success" :disabled="batchAuditDisabled" @click="batchAudit">批量审核</el-button>
          </span>
        </el-tooltip>
        <span v-if="selectedDealerCount > 1" class="audit-hint">
          已勾选 {{ selectedDealerCount }} 个经销商的订单，批量审核不支持跨经销商，请分开提交
        </span>
        <span v-else-if="multipleSelection.length > 1" class="audit-hint muted">
          已选 {{ multipleSelection.length }} 单（同一经销商）
        </span>
      </div>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" v-loading="loading" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="45" />
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column label="订单信息" min-width="215">
          <template #default="{ row }">
            <div class="order-info">
              <div class="order-no">订单编号:{{ row.OrderNo }}</div>
              <div class="order-date">订单日期: {{ formatDateTime(row.OrderDate) }}</div>
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
        <el-table-column label="经销商信息" min-width="120">
          <template #default="{ row }">
            <div class="dealer-info">
              <div class="dealer-name">姓名:{{ row.DealerName }}</div>
              <div class="dealer-sendname">发件人: {{ row.SenderName }}</div>             
            </div>
          </template>
        </el-table-column>
        <el-table-column label="收货信息" min-width="165">
          <template #default="{ row }">
            <div class="receiver-info">
              <div class="receiver-name">姓名:{{ row.ReceiverName }}</div>
              <div class="receiver-phone">电话: {{ row.ReceiverPhone }}</div>
              <div class="receiver-address">地址: {{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="产品信息" min-width="180">
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
        <el-table-column label="合计箱数" width="110" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ fmtQty(orderBoxTotal(row)) }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="editOrder(row)">编辑</el-button>
            <el-button type="info" link @click="viewOrder(row)">查看</el-button>
            <el-button type="success" link @click="confirmOrder(row)" v-if="row.Status === 1">审核</el-button>            
            <el-button type="danger" link @click="deleteOrder(row)" v-if="row.Status === 1">删除</el-button>
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

    <!-- 订单编辑对话框 -->
    <OrderForm ref="orderFormRef" v-show="scene === 1" @change-scene="changeScene"></OrderForm>

    <!-- 订单查看对话框 -->
    <OrderView ref="orderViewRef" v-show="scene === 2" @change-scene="changeScene"></OrderView>

    <!-- 导入订单对话框 -->
    <el-dialog v-model="importDialogVisible" title="导入订单" width="500px">
      <el-form :model="importForm" label-width="100px">
        <el-form-item label="选择文件" required>
          <el-upload ref="uploadRef" :auto-upload="false" :on-change="handleFileChange"
            :before-upload="beforeFileUpload" accept=".xlsx,.xls,.csv" :limit="1" :file-list="fileList">
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
            <el-icon>
              <Download />
            </el-icon>
            下载导入模板
          </el-button>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="importDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitImport" :loading="importing">开始导入</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 导入结果对话框：成功多少单、哪些行被跳过、为什么 -->
    <el-dialog v-model="importResultVisible" title="导入结果" width="720px">
      <div v-if="importResult" class="import-summary">
        <div class="summary-item">
          <span class="label">读取数据行</span>
          <span class="value">{{ importResult.total }} 行</span>
        </div>
        <div class="summary-item">
          <span class="label">成功导入</span>
          <span class="value success">{{ importResult.imported }} 单</span>
        </div>
        <div class="summary-item">
          <span class="label">跳过</span>
          <span class="value" :class="{ error: importResult.skipped > 0 }">{{ importResult.skipped }} 行</span>
        </div>
      </div>

      <el-alert
        v-if="importResult && importResult.unknown.length"
        type="warning"
        :closable="false"
        show-icon
        style="margin-bottom: 12px;"
        :title="`表头里有 ${importResult.unknown.length} 个商品列名没对上系统 SKU：${importResult.unknown.join('、')}`"
      />

      <template v-if="importResult && importResult.rows.length">
        <div class="skip-title">以下行未导入，请按行号回表格修改后重新上传：</div>
        <el-table :data="importResult.rows" border size="small" max-height="340">
          <el-table-column prop="Row" label="行号" width="70" align="center" />
          <el-table-column prop="DealerName" label="经销商" width="120" show-overflow-tooltip>
            <template #default="{ row }">{{ row.DealerName || '-' }}</template>
          </el-table-column>
          <el-table-column prop="ReceiverName" label="收货人" width="110" show-overflow-tooltip>
            <template #default="{ row }">{{ row.ReceiverName || '-' }}</template>
          </el-table-column>
          <el-table-column prop="Reason" label="跳过原因" min-width="260" />
        </el-table>
      </template>
      <el-empty
        v-else-if="importResult && importResult.skipped === 0"
        description="全部行都已成功导入"
        :image-size="70"
      />

      <template #footer>
        <el-button type="primary" @click="importResultVisible = false">知道了</el-button>
      </template>
    </el-dialog>

    <!-- 审核结果弹窗 -->
    <el-dialog v-model="auditResultDialogVisible" title="订单审核结果" width="400px" :close-on-click-modal="false">
      <div v-if="auditResultData">
        <div style="margin-bottom: 8px;">
          <b>审核状态：</b>
          <el-tag :type="auditResultData.AuditState === 1 ? 'success' : 'danger'">
            {{ auditResultData.AuditState === 1 ? '成功' : '失败' }}
          </el-tag>
        </div>
        <div style="margin-bottom: 8px;"><b>审核信息：</b>{{ auditResultData.AuditMsg }}</div>
        <div style="margin-bottom: 8px;"><b>经销商：</b>{{ auditResultData.DealerName }}</div>
        <div style="margin-bottom: 8px;"><b>审核前额度：</b>{{ auditResultData.BeforeDealerQuota }}</div>
        <div style="margin-bottom: 8px;"><b>审核后额度：</b>{{ auditResultData.AfterDealerQuota }}</div>
        <div v-if="Array.isArray(auditResultData.orderinfoDtos)">
          <div v-for="(item, idx) in auditResultData.orderinfoDtos" :key="idx" style="margin-bottom: 8px;">
            <b>订单号：</b>{{ item.OrderNO }}　<b>订单总量：</b>{{ item.TotalAmount }}
          </div>
        </div>
      </div>
      <template #footer>
        <el-button @click="copyAuditResult">一键复制</el-button>
        <el-button type="primary" @click="auditResultDialogVisible = false">关闭</el-button>
      </template>
    </el-dialog>

    <!-- 批量审核进度条弹窗 -->
    <el-dialog v-model="batchAuditDialogVisible" title="批量审核进度" width="400px" :close-on-click-modal="false" :show-close="false">
      <div style="padding: 24px 0;">
        <el-progress :percentage="batchAuditProgress" status="success" :text-inside="true" :stroke-width="22" />
        <div style="text-align:center;margin-top:12px;">请耐心等待，正在批量审核...</div>
      </div>
    </el-dialog>

    <!-- 审核弹窗：审核时先选好发货仓（默认 洗衣液→洗衣仓，其余→默认仓） -->
    <el-dialog v-model="auditDialogVisible" :title="auditMode === 'batch' ? `批量审核（${auditRows.length} 单）` : `审核订单：${auditRows[0]?.OrderNo || ''}`" width="500px" :close-on-click-modal="false">
      <el-form label-width="90px">
        <el-form-item label="发货仓" required>
          <el-select v-model="auditForm.WarehouseId" placeholder="请选择发货仓" style="width: 100%">
            <el-option v-for="w in warehouseOptions" :key="w.Id" :label="w.Name" :value="w.Id" />
          </el-select>
          <div class="audit-warehouse-tip">默认规则：洗衣液订单发广州-洗衣仓，其余发广州-默认仓；审核后锁定该仓库存</div>
        </el-form-item>
        <el-form-item label="商品明细" v-if="auditMode === 'single' && auditRows[0]?.OrderItems?.length">
          <div class="audit-product-preview">
            <div v-for="(item, idx) in auditRows[0].OrderItems" :key="idx" class="audit-product-line">
              {{ item.ProductName || '未知产品' }} ×{{ fmtQty(boxQty(item)) }} 箱
            </div>
          </div>
        </el-form-item>
        <el-form-item label="审核备注">
          <el-input v-model="auditForm.Remark" type="textarea" :rows="3" placeholder="请输入审核备注（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="auditDialogVisible = false">取消</el-button>
        <el-button type="primary" :loading="auditSubmitting" @click="auditMode === 'batch' ? submitBatchAudit() : submitAudit()">
          确认审核
        </el-button>
      </template>
    </el-dialog>

    <!-- 库存不足拆单弹窗：默认发有货数量，可逐行手工调整（含调为 0） -->
    <el-dialog v-model="splitDialogVisible" title="库存不足，按数量拆单审核" width="780px" :close-on-click-modal="false">
      <div class="split-tip">
        发货仓：<b>{{ splitForm.WarehouseName || '自动判定' }}</b>。整单无法全部发出，请逐行确认<b>本次发货数量</b>；
        未发的部分会拆成新订单留在「待审核」，到货后单独审核。
      </div>
      <el-table :data="splitRows" border size="small" max-height="340">
        <el-table-column label="商品" min-width="200">
          <template #default="{ row }">
            <div>{{ row.ProductName }}</div>
            <div v-if="row.Specs" class="split-specs">{{ row.Specs }}</div>
          </template>
        </el-table-column>
        <el-table-column label="待发(箱)" width="90" align="right">
          <template #default="{ row }">{{ fmtQty(row.NeedQty) }}</template>
        </el-table-column>
        <el-table-column label="可用(箱)" width="90" align="right">
          <template #default="{ row }">
            <span :class="{ 'split-zero': row.AvailableQty <= 0 }">{{ fmtQty(row.AvailableQty) }}</span>
          </template>
        </el-table-column>
        <el-table-column label="本次发货(箱)" width="150" align="center">
          <template #default="{ row }">
            <el-input-number
              v-model="row.ShipQty"
              :min="0"
              :max="row.MaxShipQty"
              :step="1"
              :precision="2"
              :disabled="row.MaxShipQty <= 0"
              size="small"
              controls-position="right"
              style="width: 120px"
            />
          </template>
        </el-table-column>
        <el-table-column label="转入子单(箱)" width="110" align="right">
          <template #default="{ row }">{{ fmtQty(Math.max(0, Number(row.NeedQty) - Number(row.ShipQty || 0))) }}</template>
        </el-table-column>
      </el-table>
      <div class="split-summary">
        本次发货 <b>{{ fmtQty(splitShipTotal) }}</b> 箱，转入子单 <b>{{ fmtQty(splitChildTotal) }}</b> 箱
        <el-button link type="primary" size="small" style="margin-left: 12px" @click="resetSplitRows">恢复默认数量</el-button>
      </div>
      <el-form label-width="90px" style="margin-top: 8px">
        <el-form-item label="审核备注">
          <el-input v-model="splitForm.Remark" type="textarea" :rows="2" placeholder="请输入审核备注（可选）" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="splitDialogVisible = false">取消</el-button>
        <el-button
          type="primary"
          :loading="splitSubmitting"
          :disabled="splitShipTotal <= 0"
          @click="confirmSplitAndAudit"
        >
          拆单并审核
        </el-button>
      </template>
    </el-dialog>

    <!-- 库存不足的两种「不能拆」场景：单笔全仓无货 / 批量审核含缺货单
         这里必须给出可点的下一步，否则只剩一条提示，操作员不知道该怎么办 -->
    <el-dialog
      v-model="shortageDialogVisible"
      :title="shortageTitle"
      width="760px"
    >
      <div v-if="shortageReason === 'quota'" class="quota-block">
        <div class="quota-head">
          <span class="quota-badge">额度不足</span>
          <span>
            经销商<b>{{ shortageDealer }}</b>的可用额度不够这一{{ shortageMode === 'batch' ? '批' : '单' }}，
            系统<b>先校验额度、再校验库存</b>，额度不够就不会进入库存判断，也就没有拆单。
          </span>
        </div>
        <el-table :data="quotaRows" border size="small" class="quota-table">
          <el-table-column label="额度账户" prop="AccountName" min-width="130" />
          <el-table-column label="需要(箱)" width="110" align="right">
            <template #default="{ row }">{{ fmtQty(row.NeedQty) }}</template>
          </el-table-column>
          <el-table-column label="可用(箱)" width="110" align="right">
            <template #default="{ row }">{{ fmtQty(row.AvailableQty) }}</template>
          </el-table-column>
          <el-table-column label="还差(箱)" width="110" align="right">
            <template #default="{ row }"><span class="quota-short">{{ fmtQty(row.ShortfallQty) }}</span></template>
          </el-table-column>
        </el-table>
        <div class="split-quota">
          拆单只能解决库存，解决不了额度。请先在「经销商管理」里补充额度（或让经销商减少下单后再审）。
        </div>
      </div>
      <div v-else class="split-tip">
        <template v-if="shortageMode === 'batch'">
          批量审核是<b>整批通过或整批不通过</b>，不支持自动拆单。下面这些订单库存不足，请<b>逐单</b>审核：审核时系统会弹出拆单，可按数量只发有货部分。
        </template>
        <template v-else>
          所选发货仓下这些商品<b>可用库存都是 0</b>，没有可以发的部分，因此无法拆单。
          请先<b>补货</b>，或者在「审核」弹窗里<b>换一个发货仓</b>再提交。
        </template>
      </div>
      <el-table v-if="shortageReason !== 'quota' && shortageRows.length" :data="shortageRows" border size="small" max-height="320">
        <el-table-column v-if="shortageMode === 'batch'" label="订单号" prop="OrderNo" min-width="185" show-overflow-tooltip />
        <el-table-column label="商品" prop="ProductName" min-width="120" show-overflow-tooltip />
        <el-table-column label="需发(箱)" width="85" align="right">
          <template #default="{ row }">{{ fmtQty(row.NeedQty) }}</template>
        </el-table-column>
        <el-table-column label="可用(箱)" width="85" align="right">
          <template #default="{ row }"><span class="split-zero">{{ fmtQty(row.AvailableQty) }}</span></template>
        </el-table-column>
        <el-table-column label="缺口(箱)" width="85" align="right">
          <template #default="{ row }">{{ fmtQty(row.ShortageQty) }}</template>
        </el-table-column>
      </el-table>
      <template #footer>
        <el-button @click="shortageDialogVisible = false">知道了</el-button>
        <el-button v-if="shortageReason === 'quota'" type="primary" @click="goDealerQuota">去经销商管理补额度</el-button>
        <el-button v-else-if="shortageMode === 'batch'" type="primary" @click="handleShortageOneByOne">逐单审核</el-button>
        <el-button v-else type="primary" @click="retryWithOtherWarehouse">换个发货仓</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { showError, getList, getTotal } from '@/utils/request'
import { ref, reactive, computed, onMounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download } from '@element-plus/icons-vue'
import OrderForm from './orderForm.vue'
import OrderView from './orderView.vue'
import { reqOrderlist,  reqDeleteOrder, reqImportOrders, reqAuditOrder, reqBatchAuditOrder, reqSplitAndAuditOrder, reqSplitPreviewOrder } from '@/api/order'
import { reqOrderImportTemplate } from '@/api/order'
import { reqGetFactoryList } from '@/api/organization/factory'
import { orderBoxTotal, fmtQty, boxQty, itemDiff, orderDiffTotal, fmtMoney } from '@/utils/orderQty'

const router = useRouter()

// 场景值：0-数据展示，1-订单编辑，2-订单查看
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
const orderList = ref<any>([])
const loading = ref(false)

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 导入相关
const importDialogVisible = ref(false)
const importForm = reactive({})
const fileList = ref<any[]>([])
const importing = ref(false)
const importResult = ref<any>(null)
const importResultVisible = ref(false)

// 获取子组件实例
const orderFormRef = ref()
const orderViewRef = ref()
const uploadRef = ref()

// 多选相关
const multipleSelection = ref<any[]>([])
const handleSelectionChange = (val: any[]) => {
  multipleSelection.value = val
}

// 批量审核只支持同一经销商：跨经销商时直接禁用按钮，不让人点了才被拒
const selectedDealerCount = computed(() => {
  const keys = multipleSelection.value.map((row: any) => row.DealerId ?? row.DealerName)
  return new Set(keys).size
})
const batchAuditDisabled = computed(() => multipleSelection.value.length <= 1 || selectedDealerCount.value > 1)

// 审核结果弹窗相关
const auditResultDialogVisible = ref(false)
const auditResultData = ref<any>(null)

// 审核弹窗相关：审核时先选好发货仓
// 仓库列表（factories 里 parent_id 非空的记录）
const warehouseOptions = ref<any[]>([])
const auditDialogVisible = ref(false)
const auditSubmitting = ref(false)
// single=单笔审核（row），batch=批量审核（multipleSelection）
const auditMode = ref<'single' | 'batch'>('single')
const auditRows = ref<any[]>([])
const auditForm = reactive<{ WarehouseId: number | undefined; Remark: string }>({
  WarehouseId: undefined,
  Remark: ''
})

const loadWarehouses = async () => {
  try {
    const res = await reqGetFactoryList({ onlyWarehouse: true })
    const data = getList(res)
    warehouseOptions.value = Array.isArray(data) ? data : []
  } catch (e) {
    console.error('获取仓库列表失败', e)
    warehouseOptions.value = []
  }
}

// 默认发货仓规则：所有商品都是洗衣液 → 洗衣仓；否则 → 默认仓（优先广州）
const defaultWarehouseFor = (rows: any[]): number | undefined => {
  const items = (rows || []).flatMap(r => r?.OrderItems || [])
  const allLaundry = items.length > 0 && items.every(i => (i.ProductName || '').includes('洗衣液'))
  const laundryWh = warehouseOptions.value.find(w => (w.Name || '').includes('洗衣仓'))
  const defaultWh = warehouseOptions.value.find(w => (w.Name || '').includes('广州') && (w.Name || '').includes('默认仓'))
    || warehouseOptions.value.find(w => (w.Name || '').includes('默认仓'))
  return allLaundry && laundryWh ? laundryWh.Id : defaultWh?.Id
}

// 一键复制审核结果
const copyAuditResult = async () => {
  const r: any = auditResultData.value
  if (!r) return
  // auditResultData 的键是 AuditState/AuditMsg/... （首字母大写），
  // 旧实现读的是 auditState/auditMsg，复制出来全是 undefined，这里修正；
  // orderinfoDtos 是数组（批量审核会有多单），逐行输出。
  const orders: any[] = Array.isArray(r.orderinfoDtos) ? r.orderinfoDtos : []
  const text = [
    `审核状态：${r.AuditState === 1 ? '成功' : '失败'}`,
    `审核信息：${r.AuditMsg || ''}`,
    `经销商：${r.DealerName || ''}`,
    `审核前额度：${r.BeforeDealerQuota ?? ''}`,
    `审核后额度：${r.AfterDealerQuota ?? ''}`,
    ...orders.map((o: any) => `订单号：${o.OrderNO || ''}　订单总量：${o.TotalAmount ?? ''}`)
  ].join('\n')
  try {
    await navigator.clipboard.writeText(text)
    ElMessage.success('已复制到剪贴板')
  } catch (e) {
    const ta = document.createElement('textarea')
    ta.value = text
    ta.style.position = 'fixed'
    ta.style.opacity = '0'
    document.body.appendChild(ta)
    ta.select()
    document.execCommand('copy')
    document.body.removeChild(ta)
    ElMessage.success('已复制到剪贴板')
  }
}

// 查询订单列表
const handleQuery = async () => {
  loading.value = true
  try {
    const params = {
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
    orderList.value = getList(result)
    total.value = getTotal(result, orderList.value.length)
  } catch (error) {
    showError(error, '获取订单列表失败')
    console.error('订单查询错误:', error)
    orderList.value = []
    total.value = 0
  } finally {
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
    orderViewRef.value?.initView(row.Id)
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
const downloadTemplate = async () => {
  try {
    const res = await reqOrderImportTemplate();
    // 创建Blob对象
    const blob = new Blob([res.data], { type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' });
    // 创建下载链接
    const url = window.URL.createObjectURL(blob);
    const link = document.createElement('a');
    link.href = url;
    link.download = '订单导入模板.xlsx'; // 下载文件名
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
    window.URL.revokeObjectURL(url);
    ElMessage.success('模板下载成功');
  } catch (error) {
    showError(error, '模板下载失败');
    console.error('模板下载错误:', error);
  }
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
    const res = await reqImportOrders(formData)

    // 拦截器已把 ApiResponse.Data 拆包；失败会直接 reject 到 catch
    const payload: any = res ?? {}
    const dto: any = payload.ImportedCount !== undefined ? payload : (payload ?? payload)

    importResult.value = {
      total: dto.TotalRows ?? 0,
      imported: dto.ImportedCount ?? 0,
      skipped: dto.SkippedCount ?? 0,
      rows: dto.Skipped ?? dto.skipped ?? [],
      unknown: dto.UnknownColumns ?? dto.unknownColumns ?? []
    }
    importResultVisible.value = true
    importDialogVisible.value = false
    uploadRef.value?.clearFiles?.()
    fileList.value = []
    // 导入成功后列表要刷出来
    handleQuery()
  } catch (e: any) {
    ElMessage.error(e?.Message || e?.message || '导入失败')
    console.error('导入错误:', e)
  } finally {
    importing.value = false
  }
}

// 确认订单（审核）：打开弹窗，先选发货仓再提交
const confirmOrder = (row: any) => {
  auditMode.value = 'single'
  auditRows.value = [row]
  auditForm.WarehouseId = defaultWarehouseFor([row])
  auditForm.Remark = ''
  auditDialogVisible.value = true
}

// 审核结果弹窗
const showAuditResult = (result: any) => {
  auditResultData.value = {
    AuditState: 1,
    AuditMsg: result?.Message || '审核成功',
    DealerName: result?.DealerName,
    BeforeDealerQuota: result?.BeforeDealerQuota,
    AfterDealerQuota: result?.AfterDealerQuota,
    orderinfoDtos: result?.orderinfoDtos || []
  }
  auditResultDialogVisible.value = true
}

// 库存不足拆单弹窗的状态
const splitDialogVisible = ref(false)
const splitSubmitting = ref(false)
const splitRows = ref<any[]>([])
const splitForm = reactive({ OrderId: 0, WarehouseId: 0 as number | undefined, WarehouseName: '', Remark: '' })

// 「不能拆」时的缺口明细弹窗：single=单笔；batch=批量里有缺货单
// shortageReason：quota=额度不足（额度先于库存校验，拆了也过不了） / outofstock=所选仓全部无货
const shortageDialogVisible = ref(false)
const shortageMode = ref<'single' | 'batch'>('single')
const shortageReason = ref<'' | 'quota' | 'outofstock'>('')
const shortageMessage = ref('')
const shortageRows = ref<any[]>([])
const shortageOrderRow = ref<any>(null)
// 额度不足明细：逐个额度账户的 需要/可用/还差，比一句 toast 更容易看清差多少
const quotaRows = ref<any[]>([])
const shortageDealer = ref('')

const shortageTitle = computed(() => {
  const quota = shortageReason.value === 'quota'
  if (shortageMode.value === 'batch') return quota ? '批量审核未通过：经销商额度不足' : '批量审核未通过：有订单库存不足'
  return quota ? '无法审核：经销商额度不足' : '无法拆单：所选发货仓商品全部无货'
})

// 额度不足 → 直接把人送到经销商管理页补额度
const goDealerQuota = () => {
  shortageDialogVisible.value = false
  router.push('/organization/dealer')
}

// 单笔全无货：换个发货仓重试（回到审核弹窗，保留这单）
const retryWithOtherWarehouse = () => {
  const row = shortageOrderRow.value
  shortageDialogVisible.value = false
  if (!row) return
  confirmOrder(row)
}

// 批量含缺货单：切到逐单模式，自动打开第一张缺货单的审核弹窗（沿用刚才选定的发货仓）
const handleShortageOneByOne = () => {
  shortageDialogVisible.value = false
  const first = shortageRows.value[0]
  const keepWarehouse = auditForm.WarehouseId
  const keepRemark = auditForm.Remark
  const target = orderList.value.find((r: any) => String(r.Id) === String(first?.OrderId))
  if (!target) {
    ElMessage.warning('请取消勾选后，在列表里对缺货订单逐单点「审核」')
    return
  }
  confirmOrder(target)
  if (keepWarehouse) auditForm.WarehouseId = keepWarehouse
  auditForm.Remark = keepRemark
}

const splitShipTotal = computed(() =>
  splitRows.value.reduce((sum, r) => sum + Math.max(0, Number(r.ShipQty || 0)), 0)
)
const splitChildTotal = computed(() =>
  splitRows.value.reduce((sum, r) => sum + Math.max(0, Number(r.NeedQty || 0) - Number(r.ShipQty || 0)), 0)
)

// 一键恢复后端算出的默认发货量
const resetSplitRows = () => {
  splitRows.value.forEach(r => {
    r.ShipQty = Number(r.DefaultShipQty || 0)
  })
}

const handleSplitAndAudit = async (row: any) => {
  try {
    const preview: any = await reqSplitPreviewOrder(row.Id, auditForm.WarehouseId || undefined)
    const items = Array.isArray(preview?.Items) ? preview.Items : []
    if (!items.length) {
      ElMessage.warning(preview?.Message || '没有可拆分的明细')
      return
    }
    splitForm.OrderId = row.Id
    splitForm.WarehouseId = preview.WarehouseId || auditForm.WarehouseId || undefined
    splitForm.WarehouseName = preview.WarehouseName || ''
    splitForm.Remark = auditForm.Remark
    // 默认只发有货数量，操作员可逐行调整
    splitRows.value = items.map((it: any) => ({ ...it, ShipQty: Number(it.DefaultShipQty || 0) }))
    splitDialogVisible.value = true
  } catch (error) {
    showError(error, '获取拆单信息失败')
  }
}

// 提交拆单并审核：按操作员填写的逐行发货量拆分
const confirmSplitAndAudit = async () => {
  if (splitShipTotal.value <= 0) {
    ElMessage.warning('请至少为一件有货商品填写本次发货数量')
    return
  }
  if (splitChildTotal.value <= 0) {
    ElMessage.warning('所选数量已覆盖整单需求，无需拆单，直接点「确认审核」即可')
    return
  }
  splitSubmitting.value = true
  try {
    const res: any = await reqSplitAndAuditOrder(splitForm.OrderId, {
      WarehouseId: splitForm.WarehouseId,
      Remark: splitForm.Remark,
      Items: splitRows.value.map(r => ({ OrderItemId: r.OrderItemId, ShipQty: Number(r.ShipQty || 0) }))
    })
    ElMessage.success(
      `已拆单并审核：本次发货 ${fmtQty(res?.ParentQty)} 箱，${fmtQty(res?.ChildQty)} 箱转入 ${res?.ChildOrderNo}（待审核）`
    )
    splitDialogVisible.value = false
    auditDialogVisible.value = false
    handleQuery()
  } catch (error) {
    showError(error, '拆单审核失败')
  } finally {
    splitSubmitting.value = false
  }
}

// 提交审核（单笔）：带发货仓，后端审核时锁该仓库存
const submitAudit = async () => {
  if (!auditForm.WarehouseId) {
    ElMessage.warning('请选择发货仓')
    return
  }
  const row = auditRows.value[0]
  auditSubmitting.value = true
  try {
    const auditDto = { OrderId: row.Id, remark: auditForm.Remark, WarehouseId: auditForm.WarehouseId }
    const result: any = await reqAuditOrder(auditDto)
    auditDialogVisible.value = false
    showAuditResult(result)
    // 弹窗弹出后再刷新列表，避免弹窗被刷新关闭
    setTimeout(() => {
      handleQuery()
    }, 500)
  } catch (error: any) {
    // 库存不足：后端返回 400 + Data.Shortages（逐行缺口）；额度不足时 Data.CannotSplitReason='quota'
    const data = error?.Data
    const shortages = Array.isArray(data?.Shortages) ? data.Shortages : []
    const reason = data?.CannotSplitReason || ''
    if (shortages.length && data?.CanSplit) {
      // 还有有货部分且额度够 → 弹「按数量拆单审核」，操作员逐行确认发货量
      auditDialogVisible.value = false
      await handleSplitAndAudit(row)
    } else if (shortages.length || reason) {
      // 拆不了（全仓无货 / 额度不足）→ 明确告知原因，并给可点的下一步
      shortageMode.value = 'single'
      shortageReason.value = reason
      shortageRows.value = shortages
      shortageMessage.value = data?.Message || ''
      quotaRows.value = Array.isArray(data?.QuotaShortages) ? data.QuotaShortages : []
      shortageDealer.value = data?.DealerName || row?.DealerName || ''
      shortageOrderRow.value = row
      auditDialogVisible.value = false
      shortageDialogVisible.value = true
    }
    // 其它失败原因（订单状态不对等）已由响应拦截器统一提示，这里不重复弹
  } finally {
    auditSubmitting.value = false
  }
}

// 删除订单（仅待审核订单可删）
const deleteOrder = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除订单"${row.OrderNo}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
  } catch {
    return // 用户点了取消/关闭
  }

  try {
    // 响应拦截器约定：Success=false 会直接 reject；Success=true 且 Data=null 时返回
    // {Success,Message,Data} 信封，信封上没有 status 字段。旧代码按 result.status === 200
    // 判断，导致后端已删除成功却提示「删除失败」，也不刷新列表。
    const result: any = await reqDeleteOrder(row.Id)
    ElMessage.success(result?.Message || '删除成功')
    handleQuery()
  } catch (error: any) {
    // 业务失败（如「只允许删除待审核订单」）带后端 Message，由本页统一提示；
    // HTTP 4xx/5xx 已由响应拦截器提示，这里不重复弹窗。
    if (error?.Message) {
      ElMessage.error(error.Message)
    } else if (!error?.response) {
      showError(error, '删除失败')
    }
  }
}

// 保留监听OrderForm的change-scene事件
const changeScene = (num: number) => {
  scene.value = num
  if (num === 0) {
    handleQuery()
  }
}

// 分页相关方法
const handleCurrentChange = (page) => {
  currentPage.value = page
  handleQuery()
}

const handleSizeChange = (size) => {
  pageSize.value = size
  currentPage.value = 1
  handleQuery()
}

// 获取订单状态类型
const getOrderStatusType = (status: number) => {
  const statusMap: Record<number, string> = {
    1: 'info',      // 待审核
    2: 'success',   // 已审核（待发货）
    3: 'warning',   // 部分发货
    4: 'success',   // 全部发货
    5: 'success',   // 已签收
    6: 'danger'     // 已取消
  }
  return statusMap[status] || 'info'
}

// 获取订单状态文本
const getOrderStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    1: '待审核',
    2: '已审核',
    3: '部分发货',
    4: '已发货',
    5: '已签收',
    6: '已取消',
    7: '已驳回',
    8: '已退货'
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
    day: '2-digit'    
  })
}

// 批量审核进度条相关
const batchAuditProgress = ref(0)
const batchAuditDialogVisible = ref(false)

// 批量审核：也先选发货仓。混装单（含洗衣液+普通商品）默认走默认仓
const batchAudit = () => {
  if (multipleSelection.value.length <= 1) return
  // 判断是否为同一经销商（按钮已禁用，这里再兜一层，防止快捷键/程序调用绕过）
  const dealerIdSet = new Set(multipleSelection.value.map(row => row.DealerId))
  if (dealerIdSet.size > 1) {
    ElMessage.warning('只能批量审核同一经销商的订单，请按经销商分开提交')
    return
  }
  auditMode.value = 'batch'
  auditRows.value = [...multipleSelection.value]
  auditForm.WarehouseId = defaultWarehouseFor(auditRows.value)
  auditForm.Remark = ''
  auditDialogVisible.value = true
}

// 提交批量审核：统一用所选发货仓
const submitBatchAudit = async () => {
  if (!auditForm.WarehouseId) {
    ElMessage.warning('请选择发货仓')
    return
  }
  const orderIds = auditRows.value.map(row => row.Id)
  auditSubmitting.value = true
  // 显示进度条对话框
  batchAuditProgress.value = 0
  batchAuditDialogVisible.value = true
  const total = orderIds.length
  let finished = 0
  const timer = setInterval(() => {
    finished++
    batchAuditProgress.value = Math.round((finished / total) * 100)
    if (finished >= total) {
      clearInterval(timer)
    }
  }, 300)
  try {
    const result: any = await reqBatchAuditOrder(orderIds, auditForm.Remark, auditForm.WarehouseId)
    batchAuditDialogVisible.value = false
    auditDialogVisible.value = false
    showAuditResult(result)
    setTimeout(() => {
      handleQuery()
    }, 500)
  } catch (error: any) {
    batchAuditDialogVisible.value = false
    // 批量不支持拆单：把缺货明细列出来并引导逐单审核；额度不足则直接说清原因
    const data = error?.Data
    const shortages = Array.isArray(data?.Shortages) ? data.Shortages : []
    const reason = data?.CannotSplitReason || ''
    if (shortages.length || reason === 'quota') {
      shortageMode.value = 'batch'
      shortageReason.value = reason
      shortageRows.value = shortages
      shortageMessage.value = data?.Message || ''
      quotaRows.value = Array.isArray(data?.QuotaShortages) ? data.QuotaShortages : []
      shortageDealer.value = data?.DealerName || auditRows.value[0]?.DealerName || ''
      auditDialogVisible.value = false
      shortageDialogVisible.value = true
    } else {
      showError(error, '批量审核失败')
    }
  } finally {
    auditSubmitting.value = false
    clearInterval(timer)
  }
}

// 初始化
onMounted(() => {
  handleQuery()
  loadWarehouses()
})
</script>

<style lang="scss" scoped>
.app-container {
  padding: 20px;
}

.audit-warehouse-tip {
  font-size: 12px;
  color: #909399;
  line-height: 1.6;
  margin-top: 4px;
}

// 拆单弹窗
.split-tip {
  background: #fdf6ec;
  border: 1px solid #faecd8;
  border-radius: 4px;
  padding: 8px 12px;
  margin-bottom: 12px;
  font-size: 13px;
  line-height: 1.7;
  color: #606266;
}

.split-specs {
  font-size: 12px;
  color: #909399;
}

.split-quota {
  margin-top: 6px;
  color: #e6a23c;
  font-weight: 600;
}

.split-summary {
  margin-top: 12px;
  font-size: 13px;
  color: #606266;
  text-align: right;
}

.split-zero {
  color: #f56c6c;
  font-weight: 600;
}

// 额度不足：整块做成醒目提示，额度表放在最上面，一眼看到「还差多少箱」
.quota-block {
  border: 1px solid #fbc4c4;
  background: #fef0f0;
  border-radius: 4px;
  padding: 10px 12px;
  margin-bottom: 4px;
}

.quota-head {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  font-size: 13px;
  line-height: 1.7;
  color: #606266;
}

.quota-badge {
  flex: none;
  background: #f56c6c;
  color: #fff;
  font-size: 12px;
  line-height: 20px;
  padding: 0 8px;
  border-radius: 3px;
}

.quota-table {
  margin-top: 10px;
  background: #fff;
}

.quota-short {
  color: #f56c6c;
  font-weight: 700;
}

.audit-product-preview {
  max-height: 180px;
  overflow-y: auto;
  border: 1px solid #ebeef5;
  border-radius: 4px;
  padding: 8px 12px;
  width: 100%;
  line-height: 1.8;
  font-size: 13px;
  color: #606266;
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

.header-actions {
  display: flex;
  gap: 10px;
}

/* 导入结果：三个数字横排 + 跳过明细表 */
.import-summary {
  display: flex;
  gap: 32px;
  padding: 12px 16px;
  margin-bottom: 14px;
  background: #f5f7fa;
  border-radius: 6px;

  .summary-item {
    display: flex;
    flex-direction: column;
    gap: 4px;

    .label {
      font-size: 12px;
      color: #909399;
    }

    .value {
      font-size: 20px;
      font-weight: 600;
      color: #303133;

      &.success {
        color: #67c23a;
      }

      &.error {
        color: #f56c6c;
      }
    }
  }
}

.skip-title {
  margin-bottom: 8px;
  font-size: 13px;
  color: #606266;
}

.audit-hint {
  font-size: 12px;
  color: #e6a23c;

  &.muted {
    color: #909399;
  }
}
</style>
