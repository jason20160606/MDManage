<template>
  <div class="shipping-statistics">
    <!-- 发货统计卡片（原发货记录页顶部，现统一在首页展示） -->
    <el-row :gutter="20" class="statistics-wrapper">
      <el-col :xs="12" :sm="12" :md="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>今日发货</span>
              <el-tag type="success">实时</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.TodayShippedOrderCount ?? 0 }}</div>
            <div class="label">单</div>
            <div class="box-label">/ {{ statistics.TodayShippedQuantity ?? 0 }} 箱</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>本月发货</span>
              <el-tag type="warning">月度</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.MonthShippedOrderCount ?? 0 }}</div>
            <div class="label">单</div>
            <div class="box-label">/ {{ statistics.MonthShippedQuantity ?? 0 }} 箱</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>待发货</span>
              <el-tag type="danger">待处理</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.TotalUnshippedOrderCount ?? 0 }}</div>
            <div class="label">单</div>
            <div class="box-label">/ {{ statistics.TotalUnshippedQuantity ?? 0 }} 箱</div>
          </div>
        </el-card>
      </el-col>
      <el-col :xs="12" :sm="12" :md="6">
        <el-card shadow="hover">
          <template #header>
            <div class="card-header">
              <span>已发货</span>
              <el-tag type="info">累计</el-tag>
            </div>
          </template>
          <div class="statistics-content">
            <div class="number">{{ statistics.TotalShippedOrderCount ?? 0 }}</div>
            <div class="label">单</div>
            <div class="box-label">/ {{ statistics.TotalShippedQuantity ?? 0 }} 箱</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 发货趋势 / 物流公司分布 -->
    <el-row :gutter="20" class="chart-wrapper">
      <el-col :xs="24" :sm="24" :md="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>发货趋势</span>
              <el-radio-group v-model="trendTimeRange" size="small">
                <el-radio-button :value="'week'">近7天</el-radio-button>
                <el-radio-button :value="'month'">近30天</el-radio-button>
              </el-radio-group>
            </div>
          </template>
          <div class="chart" ref="trendChartRef"></div>
        </el-card>
      </el-col>
      <el-col :xs="24" :sm="24" :md="12">
        <el-card>
          <template #header>
            <div class="card-header">
              <span>物流公司分布</span>
              <span class="chart-subtitle">近 30 天发货箱数</span>
            </div>
          </template>
          <div class="chart" ref="companyChartRef"></div>
        </el-card>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, onActivated, onBeforeUnmount, watch, nextTick } from 'vue'
import * as echarts from 'echarts'
import {
  getShipmentStatistical,
  getShipmentTrend,
  getCarrierDistribution
} from '@/api/shipping'

// 统计数据，字段与接口返回一致
const statistics = reactive<Record<string, number>>({
  TodayShippedOrderCount: 0,
  TodayShippedQuantity: 0,
  MonthShippedOrderCount: 0,
  MonthShippedQuantity: 0,
  TotalUnshippedOrderCount: 0,
  TotalUnshippedQuantity: 0,
  TotalShippedOrderCount: 0,
  TotalShippedQuantity: 0,
  TotalBoxCount: 0
})

// 首页是公共页，统计接口失败时保持 0 值即可，不用红色报错打扰用户
const fetchStatistics = async () => {
  try {
    const res: any = await getShipmentStatistical()
    if (res && res.data) {
      Object.assign(statistics, res.data)
    }
  } catch (e) {
    console.warn('获取发货统计数据失败', e)
  }
}

// 图表容器与实例：组件会被 keep-alive 缓存，需要统一 resize / dispose
const trendChartRef = ref<HTMLElement | null>(null)
const companyChartRef = ref<HTMLElement | null>(null)
let trendChart: echarts.ECharts | null = null
let companyChart: echarts.ECharts | null = null

const ensureChart = (el: HTMLElement | null, current: echarts.ECharts | null) => {
  if (!el) return null
  if (current) return current
  // 侧边栏折叠 / 隐藏标签页时容器宽度可能为 0，echarts 会拿不到尺寸
  if (!el.clientWidth || !el.clientHeight) return null
  return echarts.init(el)
}

// 发货趋势
const trendTimeRange = ref('week')
const trendData = ref<{ date: string, orderCount: number, quantity: number }[]>([])

const renderTrendChart = async () => {
  await nextTick()
  trendChart = ensureChart(trendChartRef.value, trendChart)
  if (!trendChart) return
  trendChart.setOption({
    tooltip: { trigger: 'axis' },
    legend: { data: ['发货单数', '发货箱数'] },
    grid: { left: 40, right: 20, bottom: 30, top: 40 },
    xAxis: {
      type: 'category',
      data: trendData.value.map(item => item.date)
    },
    yAxis: { type: 'value' },
    series: [
      {
        name: '发货单数',
        type: 'line',
        smooth: true,
        data: trendData.value.map(item => item.orderCount)
      },
      {
        name: '发货箱数',
        type: 'line',
        smooth: true,
        data: trendData.value.map(item => item.quantity)
      }
    ]
  }, true)
}

const fetchTrendData = async () => {
  const days = trendTimeRange.value === 'week' ? 7 : 30
  try {
    const res: any = await getShipmentTrend(days)
    if (res && res.data) {
      trendData.value = res.data.map((item: any) => ({
        date: item.Date ? (typeof item.Date === 'string' ? item.Date.slice(0, 10) : new Date(item.Date).toLocaleDateString('zh-CN')) : '',
        orderCount: item.OrderCount,
        quantity: item.Quantity
      }))
    } else {
      trendData.value = []
    }
  } catch (e) {
    console.warn('获取发货趋势失败', e)
    trendData.value = []
  }
  renderTrendChart()
}

// 物流公司分布（真实数据：按物流公司统计最近 30 天发货箱数）
const renderCompanyChart = async (data: { name: string, value: number }[] = []) => {
  await nextTick()
  companyChart = ensureChart(companyChartRef.value, companyChart)
  if (!companyChart) return
  const option = data.length
    ? {
        tooltip: { trigger: 'item', formatter: '{b}：{c} 箱（{d}%）' },
        legend: { orient: 'vertical', left: 'left' },
        series: [
          {
            name: '物流公司分布',
            type: 'pie',
            radius: '50%',
            data,
            emphasis: {
              itemStyle: { shadowBlur: 10, shadowOffsetX: 0, shadowColor: 'rgba(0, 0, 0, 0.5)' }
            }
          }
        ]
      }
    : {
        title: {
          text: '最近 30 天暂无发货记录',
          left: 'center',
          top: 'middle',
          textStyle: { color: '#909399', fontSize: 14, fontWeight: 'normal' }
        },
        series: []
      }
  companyChart.setOption(option, true)
}

const fetchCarrierDistribution = async () => {
  try {
    const res: any = await getCarrierDistribution(30)
    const list = (res && res.data ? res.data : []).map((x: any) => ({
      name: x.Name || '未填物流',
      value: Number(x.Value) || 0
    }))
    renderCompanyChart(list)
  } catch (e) {
    console.warn('获取物流公司分布失败', e)
    renderCompanyChart([])
  }
}

const resizeCharts = () => {
  trendChart?.resize()
  companyChart?.resize()
}

// 首页从别的标签页切回来时，容器尺寸变化需要重绘；若此前因宽度为 0 没初始化，这里补上
const ensureChartsRendered = () => {
  if (!trendChart) fetchTrendData()
  else trendChart.resize()
  if (!companyChart) fetchCarrierDistribution()
  else companyChart.resize()
}

watch(trendTimeRange, fetchTrendData)

onMounted(() => {
  fetchStatistics()
  fetchTrendData()
  fetchCarrierDistribution()
  window.addEventListener('resize', resizeCharts)
})

// 首次 onActivated 与 onMounted 同时发生，跳过以免重复请求；之后每次回到首页刷新数据
let firstActivate = true
onActivated(() => {
  if (firstActivate) {
    firstActivate = false
    return
  }
  fetchStatistics()
  ensureChartsRendered()
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', resizeCharts)
  trendChart?.dispose()
  companyChart?.dispose()
  trendChart = null
  companyChart = null
})
</script>

<style lang="scss" scoped>
.statistics-wrapper {
  margin-bottom: 4px;
}

.chart-wrapper {
  margin-top: 16px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.chart-subtitle {
  font-size: 12px;
  color: #909399;
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

.box-label {
  margin-left: 8px;
  font-size: 14px;
  color: #909399;
  display: inline-block;
  vertical-align: middle;
}

.chart {
  height: 300px;
}
</style>
