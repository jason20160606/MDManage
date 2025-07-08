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
          <el-date-picker v-model="queryForm.DateRange" type="daterange" range-separator="至" start-placeholder="开始日期"
            end-placeholder="结束日期" style="width: 240px;" />
        </el-form-item>
        <el-form-item label="订单总额区间">
          <el-input v-model="queryForm.TotalAmountMin" placeholder="最小数量" style="width: 100px;" clearable />
          <span style="margin: 0 8px;">-</span>
          <el-input v-model="queryForm.TotalAmountMax" placeholder="最大数量" style="width: 100px;" clearable />
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

      <!-- 表格操作按钮 -->
      <div style="margin-bottom: 10px;">
        <el-button type="success" :disabled="multipleSelection.length <= 1" @click="batchAudit">批量审核</el-button>
      </div>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%" v-loading="loading" @selection-change="handleSelectionChange">
        <el-table-column type="selection" width="55" />
        <el-table-column type="index" label="序号" width="60" />
        <el-table-column label="订单信息" min-width="260">
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
        <el-table-column label="收货信息" min-width="180">
          <template #default="{ row }">
            <div class="receiver-info">
              <div class="receiver-name">姓名:{{ row.ReceiverName }}</div>
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
                <span class="total-amount">差价: {{ row.PriceDiff }}</span>
              </div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="订单总额" width="120" align="center">
          <template #default="{ row }">
            <div class="amount-info">
              <span class="amount">{{ row.TotalAmount }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="editOrder(row)">编辑</el-button>
            <el-button type="info" link @click="viewOrder(row)">查看</el-button>
            <el-button type="success" link @click="confirmOrder(row)" v-if="row.Status === 1">审核</el-button>            
            <el-button type="danger" link @click="deleteOrder(row)">删除</el-button>
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

        <el-form-item v-if="importResult" label="导入结果">
          <div class="import-result">
            <div class="result-item">
              <span class="label">成功：</span>
              <span class="success">{{ importResult.success }} 条</span>
            </div>
            <div class="result-item">
              <span class="label">失败：</span>
              <span class="error">{{ importResult.failed }} 条</span>
            </div>
            <div v-if="importResult.errors && importResult.errors.length > 0" class="error-list">
              <div v-for="(error, index) in importResult.errors" :key="index" class="error-item">
                {{ error }}
              </div>
            </div>
          </div>
        </el-form-item>
      </el-form>

      <template #footer>
        <div class="dialog-footer">
          <el-button @click="importDialogVisible = false">取消</el-button>
          <el-button type="primary" @click="submitImport" :loading="importing">开始导入</el-button>
        </div>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Download } from '@element-plus/icons-vue'
import OrderForm from './orderForm.vue'
import OrderView from './orderView.vue'
import { reqOrderlist,  reqDeleteOrder, reqImportOrders, reqAuditOrder, reqBatchAuditOrder, reqUpdateOrder } from '@/api/order'
import { reqOrderImportTemplate } from '@/api/order'

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

// 获取子组件实例
const orderFormRef = ref()
const orderViewRef = ref()
const uploadRef = ref()

// 多选相关
const multipleSelection = ref<any[]>([])
const handleSelectionChange = (val: any[]) => {
  multipleSelection.value = val
}

// 审核结果弹窗相关
const auditResultDialogVisible = ref(false)
const auditResultData = ref<any>(null)

// 一键复制审核结果
const copyAuditResult = () => {
  if (!auditResultData.value) return
  const text = `
审核状态：${auditResultData.value.auditState === 1 ? '成功' : '失败'}
审核信息：${auditResultData.value.auditMsg}
经销商：${auditResultData.value.dealerName}
审核前额度：${auditResultData.value.beforeDealerQuota}
审核后额度：${auditResultData.value.afterDealerQuota}
订单号：${auditResultData.value.orderinfoDtos?.orderNO}
订单金额：${auditResultData.value.orderinfoDtos?.totalAmount}
  `.trim()
  navigator.clipboard.writeText(text)
  ElMessage.success('已复制到剪贴板')
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
    // 判断多种成功标志
    if (result.success || result.status === 200) {
      // 适配data为数组或对象      
      orderList.value = result.data
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
      ElMessage.error(result.message || '获取订单列表失败')
    }
  } catch (error) {
    ElMessage.error('获取订单列表失败')
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
    ElMessage.error('模板下载失败');
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
    const result = await reqImportOrders(formData)
    if (result.code === 200) {
      importResult.value = result.data
      ElMessage.success('导入完成')
    } else {
      ElMessage.error(result.message || '导入失败')
    }
  } catch (error) {
    ElMessage.error('导入失败')
    console.error('导入错误:', error)
  } finally {
    importing.value = false
  }
}

// 确认订单（审核）
const confirmOrder = async (row: any) => {
  try {
    const { value: remark } = await ElMessageBox.prompt(
      `请输入审核备注（可选）`,
      `审核订单：${row.OrderNo}`,
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputPlaceholder: '请输入审核备注',
        inputType: 'textarea',
        inputValue: '',
        draggable: true
      }
    )
    // 订单id通过data对象传递
    const auditDto = { OrderId: row.Id, remark }
    const result = await reqAuditOrder(auditDto)
    if (result.Success) {
      auditResultData.value = {
        AuditState: 1,
        AuditMsg: result.Message,
        DealerName: result.DealerName,
        BeforeDealerQuota: result.BeforeDealerQuota,
        AfterDealerQuota: result.AfterDealerQuota,
        orderinfoDtos: result.orderinfoDtos || []
      }
      auditResultDialogVisible.value = true
      // 弹窗弹出后再刷新列表，避免弹窗被刷新关闭
      setTimeout(() => {
        handleQuery()
      }, 500)
    } else {
      ElMessage.error(result.Message || '订单审核失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('订单审核失败')
    }
  }
}

// 删除订单
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

    const result = await reqDeleteOrder(row.Id)
    if (result.status === 200) {
      ElMessage.success('删除成功')
      handleQuery()
    } else {
      ElMessage.error(result.message || '删除失败')
    }
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
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
    2: 'success',   // 已审核
    3: 'warning',   // 已发货
    4: 'success',   // 已完成
    5: 'danger'     // 已取消
  }
  return statusMap[status] || 'info'
}

// 获取订单状态文本
const getOrderStatusText = (status: number) => {
  const statusMap: Record<number, string> = {
    1: '待审核',
    2: '已审核',
    3: '已发货',
    4: '已完成',
    5: '已取消'
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

// 批量审核
const batchAudit = async () => {
  if (multipleSelection.value.length <= 1) return
  // 判断是否为同一经销商
  const dealerIdSet = new Set(multipleSelection.value.map(row => row.DealerId))
  if (dealerIdSet.size > 1) {
    ElMessage.warning('只能批量审核同一经销商的订单')
    return
  }
  try {
    const { value: remark } = await ElMessageBox.prompt(
      '请输入批量审核备注（可选）',
      '批量审核',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        inputPlaceholder: '请输入审核备注',
        inputType: 'textarea',
        inputValue: '',
        draggable: true
      }
    )
    // 调用批量审核API
    const orderIds = multipleSelection.value.map(row => row.Id)
    // 显示进度条对话框
    batchAuditProgress.value = 0
    batchAuditDialogVisible.value = true
    // 模拟进度条递增（实际可用后端分步返回进度）
    const total = orderIds.length
    let finished = 0
    const timer = setInterval(() => {
      finished++
      batchAuditProgress.value = Math.round((finished / total) * 100)
      if (finished >= total) {
        clearInterval(timer)
      }
    }, 300)
    // 实际调用API
    const result = await reqBatchAuditOrder(orderIds, remark)
    batchAuditDialogVisible.value = false
    if (result && result.Success) {
      auditResultData.value = {
        AuditState: 1,
        AuditMsg: result.Message,
        DealerName: result.DealerName,
        BeforeDealerQuota: result.BeforeDealerQuota,
        AfterDealerQuota: result.AfterDealerQuota,
        orderinfoDtos: result.orderinfoDtos || []
      }
      auditResultDialogVisible.value = true
      setTimeout(() => {
        handleQuery()
      }, 500)
    } else {
      ElMessage.error(result.Message || '批量审核失败')
    }
  } catch (error) {
    batchAuditDialogVisible.value = false
    if (error !== 'cancel') {
      ElMessage.error('批量审核失败')
    }
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

.header-actions {
  display: flex;
  gap: 10px;
}

.import-result {
  .result-item {
    margin-bottom: 8px;

    .label {
      font-weight: bold;
      margin-right: 8px;
    }

    .success {
      color: #67c23a;
      font-weight: bold;
    }

    .error {
      color: #f56c6c;
      font-weight: bold;
    }
  }

  .error-list {
    margin-top: 10px;
    padding: 10px;
    background-color: #fef0f0;
    border-radius: 4px;

    .error-item {
      color: #f56c6c;
      font-size: 12px;
      margin-bottom: 4px;

      &:last-child {
        margin-bottom: 0;
      }
    }
  }
}
</style>
