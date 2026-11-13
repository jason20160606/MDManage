<template>
  <div class="app-container">
    <!-- 统计卡片、发货趋势、物流公司分布已统一移到首页展示，本页只保留发货记录表格 -->
    <!-- 发货记录列表 -->
    <el-card class="record-wrapper">
      <template #header>
        <div class="card-header">
          <span>发货记录</span>
          <div class="header-operations">
            <el-button type="primary" @click="handleBatchPrint" :disabled="selectedRecords.length === 0">
              批量打印 ({{ selectedRecords.length }})
            </el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单号" clearable />
        </el-form-item>
        <el-form-item label="物流公司">
          <el-select v-model="queryForm.logisticsCompany" placeholder="请选择物流公司" clearable style="width: 180px">
            <el-option
              v-for="item in logisticsCompanies"
              :key="item.Code"
              :label="item.Name"
              :value="item.Code"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="发货状态">
          <el-select v-model="queryForm.status" placeholder="请选择状态" clearable style="width: 140px">
            <el-option label="部分发货" :value="3" />
            <el-option label="已发货" :value="4" />
            <el-option label="已签收" :value="5" />
          </el-select>
        </el-form-item>
        <el-form-item label="发货时间">
          <el-date-picker
            v-model="queryForm.shipTime"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 记录列表 -->
      <el-table 
        :data="recordList" 
        border 
        style="width: 100%" 
        v-loading="loading"
        @selection-change="handleSelectionChange"
      >
        <el-table-column type="selection" width="45" />
        <el-table-column label="发货单号/发货时间" width="200">
          <template #default="{ row }">
            <div>
              <div class="cell-code" :title="row.ShipmentNo">{{ row.ShipmentNo || '-' }}</div>
              <div style="color: #909399; font-size: 12px;">{{ formatDateTime(row.CreatedAt) }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="订单号" width="175">
          <template #default="{ row }">
            <div class="cell-code" :title="row.OrderNo">{{ row.OrderNo || '-' }}</div>
          </template>
        </el-table-column>
        <el-table-column label="经销商" width="85" show-overflow-tooltip>
          <template #default="{ row }">{{ row.DealerName || '-' }}</template>
        </el-table-column>
        <el-table-column label="物流公司/单号" width="145">
          <template #default="{ row }">
            <div v-if="row.DeliveryType === 1">
              <div style="color: #409EFF; font-weight: bold;">自提</div>
              <div>{{ row.CarPlateNumber || '未填车牌' }}</div>
            </div>
            <div v-else>
              <div>{{ row.LogisticsCompany || '未知物流公司' }}</div>
              <div style="color: #909399; font-size: 12px;">{{ row.TrackingNo || '未填单号' }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="本次箱数" width="80" align="right">
          <template #default="{ row }">{{ fmtQty(row.TotalQuantity) }}</template>
        </el-table-column>
        <el-table-column label="收货人/地址" min-width="178">
          <template #default="{ row }">
            <div>{{ row.ReceiverName }} {{ row.ReceiverPhone ? '（' + row.ReceiverPhone + '）' : '' }}</div>
            <div style="color: #909399; font-size: 12px;">{{ row.ReceiverAddress }}</div>
          </template>
        </el-table-column>
        <el-table-column prop="Status" label="状态" width="85">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="165">
          <template #default="{ row }">
            <el-button type="success" link @click="handleTrack(row)">{{ Number(row.DeliveryType) === 1 ? '自提信息' : '跟踪' }}</el-button>
            <el-button type="primary" link @click="handleViewRecord(row)">查看</el-button>
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
    <el-dialog v-model="trackDialogVisible" :title="trackIsSelfPickup ? '自提信息' : '物流跟踪'" width="620px">
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
      <el-empty v-if="!trackLoading && logisticsTrack.length === 0" description="暂无物流轨迹" :image-size="70" />
    
      </template>
    </el-dialog>

    <!-- 记录详情对话框 -->
    <el-dialog v-model="dialogVisible" title="发货记录详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="发货单号">{{ currentRecord?.ShipmentNo || '-' }}</el-descriptions-item>
        <el-descriptions-item label="订单号">{{ currentRecord?.OrderNo }}</el-descriptions-item>
        <el-descriptions-item label="经销商">{{ currentRecord?.DealerName || '-' }}</el-descriptions-item>
        <el-descriptions-item label="发件人">{{ currentRecord?.SenderName || '-' }}</el-descriptions-item>
        <el-descriptions-item :label="currentRecord?.DeliveryType === 1 ? '车牌号' : '物流公司'">
          {{ currentRecord?.DeliveryType === 1 ? (currentRecord?.CarPlateNumber || '未设置') : (currentRecord?.LogisticsCompany || '未知物流公司') }}
        </el-descriptions-item>
        <el-descriptions-item :label="currentRecord?.DeliveryType === 1 ? '司机电话' : '物流单号'">
          {{ currentRecord?.DeliveryType === 1 ? (currentRecord?.DriverPhone || '未设置') : (currentRecord?.TrackingNo || '未设置') }}
        </el-descriptions-item>
        <el-descriptions-item label="发货时间">{{ formatDateTime(currentRecord?.CreatedAt) }}</el-descriptions-item>
        <el-descriptions-item label="签收时间">{{ formatDateTime(currentRecord?.ReceiveTime) || '-' }}</el-descriptions-item>
        <el-descriptions-item label="本次发货箱数">{{ fmtQty(currentRecord?.TotalQuantity) }}</el-descriptions-item>
        <el-descriptions-item label="发货类型">
          {{ currentRecord?.ShipmentType === 2 ? '部分发货' : '全部发货' }}
        </el-descriptions-item>
        <el-descriptions-item label="收货人">{{ currentRecord?.ReceiverName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentRecord?.ReceiverPhone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="2">{{ currentRecord?.ReceiverAddress }}</el-descriptions-item>
        <el-descriptions-item label="物流状态">
          <el-tag :type="getStatusType(currentRecord?.Status)">
            {{ getStatusText(currentRecord?.Status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentRecord?.Remark || '无' }}</el-descriptions-item>
      </el-descriptions>

      <div class="tracking-info" v-if="currentRecord?.ShipmentItems && currentRecord.ShipmentItems.length > 0">
        <h3>发货明细</h3>
        <el-table :data="currentRecord.ShipmentItems" border>
          <el-table-column prop="ProductName" label="商品名称" />
          <el-table-column prop="Quantity" label="数量" width="100" />
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { showError, getList, getTotal } from '@/utils/request'
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getShipmentList, getShipmentDetailById, getLogisticsCompanyNames, getShipmentTrack } from '@/api/shipping'
import { fmtQty } from '@/utils/orderQty'

// 物流公司列表
const logisticsCompanies = ref<{ Id: string, Code: string, Name: string }[]>([])

// 查询表单
const queryForm = reactive({
  orderNo: '',
  logisticsCompany: '',
  status: '' as string | number,
  shipTime: [] as string[]
})

// 记录列表
const recordList = ref<any[]>([])
const loading = ref(false)

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 对话框
const dialogVisible = ref(false)
const currentRecord = ref(null)

// 选中的记录
const selectedRecords = ref<any[]>([])

// 获取状态类型（Status 是订单状态：3-部分发货 4-已发货 5-已签收）
const getStatusType = (status: string | number) => {
  const map: Record<string, string> = {
    2: 'warning',
    3: 'warning',
    4: 'primary',
    5: 'success'
  }
  return map[String(status)] || 'info'
}

// 获取状态文本
const getStatusText = (status: string | number) => {
  const map: Record<string, string> = {
    2: '待发货',
    3: '部分发货',
    4: '已发货',
    5: '已签收',
    6: '已取消'
  }
  return map[String(status)] || `状态${status}`
}

// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr) return ''
  if (String(dateStr).startsWith('0001')) return ''
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 查询记录
const handleQuery = async () => {
  loading.value = true
  try {
    // 构建查询参数，过滤掉undefined和空值
    const params: any = {
      PageNumber: currentPage.value,
      PageSize: pageSize.value
    }
    
    // 只有当值不为空时才添加到参数中
    if (queryForm.orderNo && queryForm.orderNo.trim()) {
      params.OrderNumber = queryForm.orderNo.trim()
    }
    
    if (queryForm.logisticsCompany && queryForm.logisticsCompany.trim()) {
      params.LogisticsCode = queryForm.logisticsCompany.trim()
    }

    // 发货状态取的是订单状态（3部分发货/4已发货/5已签收）
    if (queryForm.status !== '' && queryForm.status !== null && queryForm.status !== undefined) {
      params.OrderStatus = Number(queryForm.status)
    }
    
    if (queryForm.shipTime && queryForm.shipTime.length > 0) {
      params.StartDate = queryForm.shipTime[0]
    }
    
    if (queryForm.shipTime && queryForm.shipTime.length > 1) {
      params.EndDate = queryForm.shipTime[1]
    }
    
    const result = await getShipmentList(params)
    recordList.value = getList(result)
    
    // 处理分页信息
    total.value = getTotal(result)
  } catch (error) {
    console.error('获取发货记录失败:', error)
    showError(error, '获取发货记录失败')
    recordList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.logisticsCompany = ''
  queryForm.status = ''
  queryForm.shipTime = []
  handleQuery()
}

// 选择变化处理
const handleSelectionChange = (selection: any[]) => {
  selectedRecords.value = selection
}

// 批量打印
const handleBatchPrint = () => {
  if (selectedRecords.value.length === 0) {
    ElMessage.warning('请选择要打印的记录')
    return
  }
  
  // 后端尚无批量打印接口：不要弹「打印成功」误导用户
  ElMessage.warning('批量打印功能暂未开放')
}

// 查看记录（按发货单ID取，一单分多批发货时不会串行）
const handleViewRecord = async (row: any) => {
  try {
    if (!row.Id) {
      ElMessage.error('发货记录ID不能为空')
      return
    }
    const result = await getShipmentDetailById(row.Id)
    const detail = result && (result?.Data ?? result)
    if (detail && detail.Id) {
      currentRecord.value = detail
      dialogVisible.value = true
    } else {
      ElMessage.error('获取发货记录详情失败')
    }
  } catch (error) {
    console.error('获取发货记录详情失败:', error)
    showError(error, '获取发货记录详情失败')
  }
}

// 打印记录
const handlePrint = (_row?: any) => {
  // TODO: 接入打印模板后替换
  ElMessage.warning('打印功能暂未开放')
}

// 物流跟踪对话框
const trackDialogVisible = ref(false)
const trackIsSelfPickup = ref(false)
const trackSelfInfo = ref<any>({})
const trackLoading = ref(false)
const trackMocked = ref(false)
const trackMessage = ref('')
const trackTitle = ref('')
const logisticsTrack = ref<any[]>([])
const currentTrackRow = ref<any>(null)

const formatTrackTime = (value: string) => {
  if (!value) return ''
  if (String(value).startsWith('0001')) return ''
  const d = new Date(value)
  if (isNaN(d.getTime())) return value
  const pad = (n: number) => String(n).padStart(2, '0')
  return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())} ${pad(d.getHours())}:${pad(d.getMinutes())}`
}

// 把接口返回/被 reject 的轨迹数据统一渲染成时间线
const renderTrack = (data: any) => {
  const list = data?.Tracks || data?.tracks || []
  trackMocked.value = !!data?.Mocked
  trackMessage.value = data?.Message || ''
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
}

// 按发货单拉取轨迹：优先真实快递查询，未配置账号时后端返回系统推导的模拟轨迹
const loadTrack = async (shipmentId: number, refresh = false) => {
  trackLoading.value = true
  try {
    const res: any = await getShipmentTrack(shipmentId, refresh)
    // 响应拦截器已把 {Success,Data} 拆包成 Data 本身；个别情况会保留原结构，这里两种都兼容
    const data = res?.Tracks ? res : (res ?? {})
    renderTrack(data)
  } catch (e: any) {
    // 「查不到轨迹」这类业务结果会被拦截器 reject，但它带着 Message/空轨迹，照常渲染
    if (e && (e.Tracks || e.Message)) {
      renderTrack(e)
    } else {
      console.error('获取物流轨迹失败', e)
      showError(e, '获取物流轨迹失败')
      logisticsTrack.value = []
    }
  } finally {
    trackLoading.value = false
  }
}

// 发货记录行本身就是一条发货单，直接用 row.Id 查询
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
  if (!row?.Id) {
    ElMessage.warning('该记录缺少发货单号，无法查看物流轨迹')
    return
  }
  currentTrackRow.value = row
  // 自提分支已在上面提前 return，这里只可能是快递单
  trackTitle.value =
    [row.LogisticsCompany, row.TrackingNo].filter(Boolean).join(' · ') || '物流跟踪'
  logisticsTrack.value = []
  trackMessage.value = ''
  trackMocked.value = false
  trackDialogVisible.value = true
  loadTrack(row.Id)
}

const refreshTrack = () => {
  const id = currentTrackRow.value?.Id
  if (id) loadTrack(id, true)
  else ElMessage.warning('暂无可刷新的发货单')
}

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  handleQuery()
}

// 获取物流公司列表
const getLogisticsCompanyList = async () => {
  try {
    const result = await getLogisticsCompanyNames()
    if (result) {
      logisticsCompanies.value = getList(result)
    }
  } catch (error) {
    console.error('获取物流公司列表失败:', error)
    showError(error, '获取物流公司列表失败')
  }
}

onMounted(() => {
  getLogisticsCompanyList()
  handleQuery()
})
</script>

<style lang="scss" scoped>
.record-wrapper {
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

.tracking-info {
  margin-top: 20px;
  h3 {
    margin-bottom: 20px;
    font-weight: normal;
    color: #666;
  }
}

:deep(.el-timeline-item__content) {
  color: #666;
}

.track-head {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 14px;
}

.track-title {
  font-weight: 500;
  color: #303133;
}

.track-msg {
  margin-bottom: 12px;
  font-size: 13px;
  color: #909399;
}

.track-timeline {
  max-height: 420px;
  overflow-y: auto;
  padding: 4px 8px 0 2px;
}

/* 行高默认被压到 14px，中文字形会超出容器顶部被裁掉半行，这里放开 */
.track-timeline :deep(.el-timeline-item__content) {
  line-height: 1.6;
}

.track-timeline :deep(.el-timeline-item__timestamp) {
  line-height: 1.5;
  padding-top: 4px;
}

.track-loc {
  margin-top: 2px;
  font-size: 12px;
  color: #909399;
}

/* 单号类字段：单行显示，超长省略，鼠标悬停看完整（避免数字被硬折成两行） */
.cell-code {
  font-size: 12.5px;
  font-weight: 500;
  line-height: 18px;
  color: #303133;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}
</style>

