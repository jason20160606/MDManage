<template>
  <div class="app-container">
    <!-- 统计卡片 -->
    <el-row :gutter="20" class="statistics-wrapper">
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>今日发货</span>
              <el-tag type="success">实时</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.todayCount }}</div>
            <div class="label">单</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>本月发货</span>
              <el-tag type="warning">月度</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.monthCount }}</div>
            <div class="label">单</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>待发货</span>
              <el-tag type="danger">待处理</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.pendingCount }}</div>
            <div class="label">单</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>已发货</span>
              <el-tag type="info">累计</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.totalCount }}</div>
            <div class="label">单</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 图表区域 -->
    <el-row :gutter="20" class="chart-wrapper">
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>发货趋势</span>
              <el-radio-group v-model="trendTimeRange" size="small">
                <el-radio-button label="week">近7天</el-radio-button>
                <el-radio-button label="month">近30天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div class="chart" ref="trendChartRef"></div>
        </el-card>
      </el-col>
      <el-col :span="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>物流公司分布</span>
            </div>
          </template>
          <div class="chart" ref="companyChartRef"></div>
        </el-card>
      </el-col>
    </el-row>

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
            <el-option label="已发货" value="shipped" />
            <el-option label="已签收" value="received" />
            <el-option label="运输中" value="shipping" />
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
        <el-table-column type="selection" width="55" />
        <el-table-column label="订单号/发货时间" width="280">
          <template #default="{ row }">
            <div>
              <div style="font-weight: bold; margin-bottom: 4px;">{{ row.OrderNo }}</div>
              <div style="color: #909399; font-size: 12px;">{{ formatDateTime(row.CreatedAt) }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="物流公司/车牌号" width="150">
          <template #default="{ row }">
            <div v-if="row.DeliveryType === 1">
              <div style="color: #409EFF; font-weight: bold;">车牌号</div>
              <div>{{ row.CarPlateNumber || '未设置' }}</div>
            </div>
            <div v-else>
              {{ row.LogisticsCompany || '未知物流公司' }}
            </div>
          </template>
        </el-table-column>
        <el-table-column label="物流单号/司机电话" width="180">
          <template #default="{ row }">
            <div v-if="row.DeliveryType === 1">
              <div style="color: #409EFF; font-weight: bold;">司机电话</div>
              <div>{{ row.DriverPhone || '未设置' }}</div>
            </div>
            <div v-else>
              {{ row.TrackingNo || '未设置' }}
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="ReceiverName" label="收货人" width="100" />
        <el-table-column prop="ReceiverPhone" label="联系电话" width="120" />
        <el-table-column prop="ReceiverAddress" label="收货地址" show-overflow-tooltip />
        <el-table-column prop="Status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
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

    <!-- 记录详情对话框 -->
    <el-dialog v-model="dialogVisible" title="发货记录详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单号">{{ currentRecord?.OrderNo }}</el-descriptions-item>
        <el-descriptions-item :label="currentRecord?.DeliveryType === 1 ? '车牌号' : '物流公司'">
          {{ currentRecord?.DeliveryType === 1 ? (currentRecord?.CarPlateNumber || '未设置') : (currentRecord?.LogisticsCompany || '未知物流公司') }}
        </el-descriptions-item>
        <el-descriptions-item :label="currentRecord?.DeliveryType === 1 ? '司机电话' : '物流单号'">
          {{ currentRecord?.DeliveryType === 1 ? (currentRecord?.DriverPhone || '未设置') : (currentRecord?.TrackingNo || '未设置') }}
        </el-descriptions-item>
        <el-descriptions-item label="发货时间">{{ formatDateTime(currentRecord?.CreatedAt) }}</el-descriptions-item>
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
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'
import { getShipmentList, getShipmentDetail, getLogisticsCompanyNames } from '@/api/shipping'

// 统计数据
const statistics = reactive({
  todayCount: 128,
  monthCount: 3280,
  pendingCount: 56,
  totalCount: 15680
})

// 图表相关
const trendChartRef = ref(null)
const companyChartRef = ref(null)
const trendTimeRange = ref('week')

// 物流公司列表
const logisticsCompanies = ref<{ Id: string, Code: string, Name: string }[]>([])

// 查询表单
const queryForm = reactive({
  orderNo: '',
  logisticsCompany: '',
  status: '',
  shipTime: []
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

// 获取状态类型
const getStatusType = (status: string) => {
  const map = {
    3: 'primary',   
    5: 'success'
  }
  return map[status] || 'info'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const map = {    
    3: '运输中',
    5: '已签收'
  }
  return map[status] || status
}

// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 初始化发货趋势图表
const initTrendChart = () => {
  const chart = echarts.init(trendChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis'
    },
    xAxis: {
      type: 'category',
      data: ['1月14日', '1月15日', '1月16日', '1月17日', '1月18日', '1月19日', '1月20日']
    },
    yAxis: {
      type: 'value'
    },
    series: [
      {
        name: '发货数量',
        type: 'line',
        smooth: true,
        data: [120, 132, 101, 134, 90, 230, 210]
      }
    ]
  }
  chart.setOption(option)
}

// 初始化物流公司分布图表
const initCompanyChart = () => {
  const chart = echarts.init(companyChartRef.value)
  const option = {
    tooltip: {
      trigger: 'item'
    },
    legend: {
      orient: 'vertical',
      left: 'left'
    },
    series: [
      {
        name: '物流公司分布',
        type: 'pie',
        radius: '50%',
        data: [
          { value: 1048, name: '顺丰速运' },
          { value: 735, name: '中通快递' },
          { value: 580, name: '圆通速递' },
          { value: 484, name: '韵达快递' },
          { value: 300, name: '申通快递' }
        ],
        emphasis: {
          itemStyle: {
            shadowBlur: 10,
            shadowOffsetX: 0,
            shadowColor: 'rgba(0, 0, 0, 0.5)'
          }
        }
      }
    ]
  }
  chart.setOption(option)
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
    
    if (queryForm.shipTime && queryForm.shipTime.length > 0) {
      params.StartDate = queryForm.shipTime[0]
    }
    
    if (queryForm.shipTime && queryForm.shipTime.length > 1) {
      params.EndDate = queryForm.shipTime[1]
    }
    
    const result = await getShipmentList(params)
    recordList.value = result.data || []
    
    // 处理分页信息
    if (result.headers && result.headers['x-pagination']) {
      const pagination = JSON.parse(result.headers['x-pagination'])
      currentPage.value = pagination.PageIndex || 1
      pageSize.value = pagination.PageSize || 10
      total.value = pagination.TotalCount || 0
    } else {
      total.value = recordList.value.length
    }
  } catch (error) {
    console.error('获取发货记录失败:', error)
    ElMessage.error('获取发货记录失败')
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
  
  // TODO: 调用批量打印接口
  ElMessage.success(`已选择 ${selectedRecords.value.length} 条记录进行打印`)
  console.log('批量打印记录:', selectedRecords.value)
}

// 查看记录
const handleViewRecord = async (row: any) => {
  try {
    // 检查OrderId是否存在
    if (!row.OrderId) {
      ElMessage.error('订单号不能为空')
      return
    }
    const result = await getShipmentDetail(row.OrderId)
    if (result && result.data) {
      currentRecord.value = result.data
      dialogVisible.value = true
    } else {
      ElMessage.error('获取发货记录详情失败')
    }
  } catch (error) {
    console.error('获取发货记录详情失败:', error)
    ElMessage.error('获取发货记录详情失败')
  }
}

// 打印记录
const handlePrint = (row: any) => {
  // TODO: 调用打印接口
  ElMessage.success('打印成功')
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

// 监听时间范围变化
watch(trendTimeRange, () => {
  // TODO: 根据时间范围重新获取数据
  initTrendChart()
})

// 获取物流公司列表
const getLogisticsCompanyList = async () => {
  try {
    const result = await getLogisticsCompanyNames()
    if (result && result.data) {
      logisticsCompanies.value = result.data
    }
  } catch (error) {
    console.error('获取物流公司列表失败:', error)
    ElMessage.error('获取物流公司列表失败')
  }
}

onMounted(() => {
  getLogisticsCompanyList()
  handleQuery()
  initTrendChart()
  initCompanyChart()
})
</script>

<style lang="scss" scoped>
.statistics-wrapper {
  margin-bottom: 20px;
}

.chart-wrapper {
  margin-bottom: 20px;
}

.record-wrapper {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.statistics-content {
  display: flex;
  align-items: baseline;
  .number {
    font-size: 24px;
    font-weight: bold;
    color: #303133;
  }
  .label {
    margin-left: 8px;
    color: #909399;
  }
}

.chart {
  height: 300px;
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
</style>
