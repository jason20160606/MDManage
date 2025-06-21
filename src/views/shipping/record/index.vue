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
            <el-button type="primary" @click="handleExport">导出记录</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单号" clearable />
        </el-form-item>
        <el-form-item label="物流公司">
          <el-select v-model="queryForm.logisticsCompany" placeholder="请选择物流公司" clearable>
            <el-option
              v-for="item in logisticsCompanies"
              :key="item.code"
              :label="item.name"
              :value="item.code"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="发货状态">
          <el-select v-model="queryForm.status" placeholder="请选择状态" clearable>
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
      <el-table :data="recordList" border style="width: 100%">
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="logisticsCompany" label="物流公司" />
        <el-table-column prop="trackingNo" label="物流单号" width="180" />
        <el-table-column prop="receiver" label="收货人" />
        <el-table-column prop="phone" label="联系电话" />
        <el-table-column prop="address" label="收货地址" show-overflow-tooltip />
        <el-table-column prop="shipTime" label="发货时间" width="180" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleViewRecord(row)">查看</el-button>
            <el-button type="primary" link @click="handlePrint()">打印</el-button>
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
        <el-descriptions-item label="订单号">{{ currentRecord?.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="物流公司">{{ currentRecord?.logisticsCompany }}</el-descriptions-item>
        <el-descriptions-item label="物流单号">{{ currentRecord?.trackingNo }}</el-descriptions-item>
        <el-descriptions-item label="发货时间">{{ currentRecord?.shipTime }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ currentRecord?.receiver }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentRecord?.phone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="2">{{ currentRecord?.address }}</el-descriptions-item>
        <el-descriptions-item label="物流状态">
          <el-tag :type="getStatusType(currentRecord?.status)">
            {{ getStatusText(currentRecord?.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentRecord?.remark }}</el-descriptions-item>
      </el-descriptions>

      <div class="tracking-info">
        <h3>物流轨迹</h3>
        <el-timeline>
          <el-timeline-item
            v-for="(activity, index) in currentRecord?.tracking"
            :key="index"
            :timestamp="activity.time"
            :type="index === 0 ? 'primary' : ''"
          >
            {{ activity.content }}
          </el-timeline-item>
        </el-timeline>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch } from 'vue'
import { ElMessage } from 'element-plus'
import * as echarts from 'echarts'

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
const logisticsCompanies = ref([
  { name: '顺丰速运', code: 'SF' },
  { name: '中通快递', code: 'ZTO' },
  { name: '圆通速递', code: 'YTO' },
  { name: '韵达快递', code: 'YD' },
  { name: '申通快递', code: 'STO' }
])

// 查询表单
const queryForm = reactive({
  orderNo: '',
  logisticsCompany: '',
  status: '',
  shipTime: []
})

// 记录列表
const recordList = ref([
  {
    orderNo: 'SH202401200001',
    logisticsCompany: '顺丰速运',
    trackingNo: 'SF1234567890',
    receiver: '张先生',
    phone: '138****8888',
    address: '北京市朝阳区望京街道xxx小区',
    shipTime: '2024-01-20 10:00:00',
    status: 'received',
    remark: '无',
    tracking: [
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
      }
    ]
  },
  {
    orderNo: 'SH202401200002',
    logisticsCompany: '中通快递',
    trackingNo: 'ZTO1234567890',
    receiver: '李先生',
    phone: '138****8889',
    address: '北京市海淀区中关村xxx号',
    shipTime: '2024-01-20 11:00:00',
    status: 'shipping',
    remark: '无',
    tracking: [
      {
        time: '2024-01-20 11:00:00',
        content: '快件已发出'
      },
      {
        time: '2024-01-20 10:30:00',
        content: '快件已揽收'
      }
    ]
  }
])

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(100)

// 对话框
const dialogVisible = ref(false)
const currentRecord = ref(null)

// 获取状态类型
const getStatusType = (status: string) => {
  const map = {
    shipped: 'primary',
    shipping: 'warning',
    received: 'success'
  }
  return map[status] || 'info'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const map = {
    shipped: '已发货',
    shipping: '运输中',
    received: '已签收'
  }
  return map[status] || status
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
const handleQuery = () => {
  // TODO: 调用查询接口
  console.log('查询条件：', queryForm)
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.logisticsCompany = ''
  queryForm.status = ''
  queryForm.shipTime = []
}

// 导出记录
const handleExport = () => {
  // TODO: 调用导出接口
  ElMessage.success('导出成功')
}

// 查看记录
const handleViewRecord = (row: any) => {
  currentRecord.value = row
  dialogVisible.value = true
}

// 打印记录
const handlePrint = () => {
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

onMounted(() => {
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
