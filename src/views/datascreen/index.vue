<template>
  <div class="datascreen">
    <div class="header">
      <div class="title">订单管理系统数据大屏</div>
      <div class="time">{{ currentTime }}</div>
      <el-button type="primary" :icon="HomeFilled" @click="goHome">返回首页</el-button>
    </div>

    <div class="overview">
      <div class="overview-item">
        <h3>今日订单</h3>
        <div class="value">1,234</div>
      </div>
      <div class="overview-item">
        <h3>今日销售额</h3>
        <div class="value">¥89,432</div>
      </div>
      <div class="overview-item">
        <h3>待发货</h3>
        <div class="value">56</div>
      </div>
      <div class="overview-item">
        <h3>库存预警</h3>
        <div class="value">12</div>
      </div>
    </div>

    <div class="main-content">
      <!-- 左侧面板 -->
      <div class="left-panel">
        <div class="panel">
          <div class="panel-title">销售趋势</div>
          <div ref="salesTrendChartRef" class="sales-trend-chart"></div>
        </div>
        <div class="panel">
          <div class="panel-title">订单分布</div>
          <div ref="orderDistributionChartRef" class="order-distribution-chart"></div>
        </div>
      </div>

      <!-- 中间面板 -->
      <div class="center-panel">
        <div class="panel">
          <div class="panel-title">经销商发货分布</div>
          <div ref="dealerShipmentChartRef" class="dealer-shipment-chart"></div>
        </div>
        <div class="panel">
          <div class="panel-title">区域销售趋势</div>
          <div ref="regionSalesChartRef" class="region-sales-chart"></div>
        </div>
      </div>

      <!-- 右侧面板 -->
      <div class="right-panel">
        <div class="panel">
          <div class="panel-title">经销商排行</div>
          <div ref="dealerRankChartRef" class="dealer-rank-chart"></div>
        </div>
        <div class="panel">
          <div class="panel-title">产品排行</div>
          <div ref="productRankChartRef" class="product-rank-chart"></div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted, nextTick } from 'vue'
import { useRouter } from 'vue-router'
import * as echarts from 'echarts'
import { HomeFilled } from '@element-plus/icons-vue'
// 引入中国地图数据
import chinaJson from './map/china.json'

// 注册中国地图
echarts.registerMap('china', chinaJson as any)

const router = useRouter()
const currentTime = ref('')

// 图表实例
let salesTrendChart: echarts.ECharts | null = null
let orderDistributionChart: echarts.ECharts | null = null
let dealerShipmentChart: echarts.ECharts | null = null
let regionSalesChart: echarts.ECharts | null = null
let dealerRankChart: echarts.ECharts | null = null
let productRankChart: echarts.ECharts | null = null

// 图表容器引用
const salesTrendChartRef = ref<HTMLElement>()
const orderDistributionChartRef = ref<HTMLElement>()
const dealerShipmentChartRef = ref<HTMLElement>()
const regionSalesChartRef = ref<HTMLElement>()
const dealerRankChartRef = ref<HTMLElement>()
const productRankChartRef = ref<HTMLElement>()

// 返回首页
const goHome = () => {
  router.push('/')
}

// 更新时间
const updateTime = () => {
  const now = new Date()
  currentTime.value = now.toLocaleString()
}

// 初始化所有图表
const initCharts = async () => {
  await nextTick()
  setTimeout(() => {
    initSalesTrendChart()
    initOrderDistributionChart()
    initDealerShipmentChart()
    initRegionSalesChart()
    initDealerRankChart()
    initProductRankChart()
  }, 100)
}

// 初始化销售趋势图表
const initSalesTrendChart = () => {
  if (!salesTrendChartRef.value) return
  salesTrendChart = echarts.init(salesTrendChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['周一', '周二', '周三', '周四', '周五', '周六', '周日'],
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      }
    },
    yAxis: {
      type: 'value',
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(255,255,255,0.1)'
        }
      }
    },
    series: [{
      data: [820, 932, 901, 934, 1290, 1330, 1320],
      type: 'line',
      smooth: true,
      symbol: 'circle',
      symbolSize: 8,
      itemStyle: {
        color: '#30cfd0'
      },
      areaStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 0, 1, [{
          offset: 0,
          color: 'rgba(48,207,208,0.3)'
        }, {
          offset: 1,
          color: 'rgba(48,207,208,0.1)'
        }])
      }
    }]
  }
  salesTrendChart.setOption(option)
}

// 初始化订单分布图表
const initOrderDistributionChart = () => {
  if (!orderDistributionChartRef.value) return
  orderDistributionChart = echarts.init(orderDistributionChartRef.value)
  const option = {
    tooltip: {
      trigger: 'item',
      formatter: '{a} <br/>{b}: {c} ({d}%)'
    },
    legend: {
      orient: 'vertical',
      right: 10,
      top: 'center',
      textStyle: {
        color: '#fff'
      }
    },
    series: [{
      name: '订单分布',
      type: 'pie',
      radius: ['50%', '70%'],
      avoidLabelOverlap: false,
      itemStyle: {
        borderRadius: 10,
        borderColor: '#fff',
        borderWidth: 2
      },
      label: {
        show: false,
        position: 'center'
      },
      emphasis: {
        label: {
          show: true,
          fontSize: '20',
          fontWeight: 'bold',
          color: '#fff'
        }
      },
      labelLine: {
        show: false
      },
      data: [
        { value: 1048, name: '线上订单' },
        { value: 735, name: '线下订单' },
        { value: 580, name: '电话订单' },
        { value: 484, name: '其他' }
      ]
    }]
  }
  orderDistributionChart.setOption(option)
}

// 初始化经销商发货分布图表
const initDealerShipmentChart = () => {
  if (!dealerShipmentChartRef.value) return
  dealerShipmentChart = echarts.init(dealerShipmentChartRef.value)
  const option = {
    backgroundColor: 'transparent',
    tooltip: {
      trigger: 'item',
      formatter: '{b}: {c}'
    },
    geo: {
      map: 'china',
      roam: true,
      zoom: 2,
      center: [105, 36],
      itemStyle: {
        areaColor: '#0f1c3c',
        borderColor: 'rgba(255,255,255,0.3)',
        borderWidth: 1
      },
      emphasis: {
        itemStyle: {
          areaColor: '#30cfd0',
          shadowBlur: 10,
          shadowColor: 'rgba(48,207,208,0.5)'
        }
      },
      label: {
        show: false
      }
    },
    series: [
      {
        type: 'lines',
        coordinateSystem: 'geo',
        zlevel: 2,
        effect: {
          show: true,
          period: 4,
          trailLength: 0.4,
          symbol: 'arrow',
          symbolSize: 6,
          color: '#fff'
        },
        lineStyle: {
          color: '#30cfd0',
          width: 1,
          opacity: 0.6,
          curveness: 0.2
        },
        data: [
          {
            fromName: '上海',
            toName: '北京',
            coords: [[121.4737, 31.2304], [116.4074, 39.9042]]
          },
          {
            fromName: '广州',
            toName: '成都',
            coords: [[113.2644, 23.1291], [104.0668, 30.5728]]
          },
          {
            fromName: '深圳',
            toName: '武汉',
            coords: [[114.0579, 22.5431], [114.3055, 30.5928]]
          },
          {
            fromName: '杭州',
            toName: '西安',
            coords: [[120.1551, 30.2741], [108.9402, 34.3416]]
          },
          {
            fromName: '南京',
            toName: '重庆',
            coords: [[118.7969, 32.0603], [106.5516, 29.5630]]
          }
        ]
      },
      {
        type: 'scatter',
        coordinateSystem: 'geo',
        zlevel: 3,
        symbolSize: 8,
        label: {
          show: true,
          position: 'right',
          formatter: '{b}',
          color: '#fff',
          fontSize: 12,
          backgroundColor: 'rgba(0,0,0,0.5)',
          padding: [2, 4],
          borderRadius: 2
        },
        itemStyle: {
          color: '#30cfd0'
        },
        data: [
          { name: '北京', value: [116.4074, 39.9042] },
          { name: '天津', value: [117.2010, 39.0842] },
          { name: '石家庄', value: [114.5149, 38.0428] },
          { name: '太原', value: [112.5489, 37.8706] },
          { name: '呼和浩特', value: [111.7519, 40.8415] },
          { name: '沈阳', value: [123.4315, 41.8057] },
          { name: '长春', value: [125.3236, 43.8171] },
          { name: '哈尔滨', value: [126.5349, 45.8038] },
          { name: '上海', value: [121.4737, 31.2304] },
          { name: '南京', value: [118.7969, 32.0603] },
          { name: '杭州', value: [120.1551, 30.2741] },
          { name: '合肥', value: [117.2272, 31.8206] },
          { name: '福州', value: [119.2965, 26.0745] },
          { name: '南昌', value: [115.8581, 28.6820] },
          { name: '济南', value: [117.1205, 36.6510] },
          { name: '郑州', value: [113.6254, 34.7466] },
          { name: '武汉', value: [114.3055, 30.5928] },
          { name: '长沙', value: [112.9388, 28.2282] },
          { name: '广州', value: [113.2644, 23.1291] },
          { name: '南宁', value: [108.3663, 22.8170] },
          { name: '海口', value: [110.1999, 20.0442] },
          { name: '重庆', value: [106.5516, 29.5630] },
          { name: '成都', value: [104.0668, 30.5728] },
          { name: '贵阳', value: [106.6302, 26.6470] },
          { name: '昆明', value: [102.8329, 24.8801] },
          { name: '拉萨', value: [91.1145, 29.6500] },
          { name: '西安', value: [108.9402, 34.3416] },
          { name: '兰州', value: [103.8343, 36.0611] },
          { name: '西宁', value: [101.7782, 36.6173] },
          { name: '银川', value: [106.2309, 38.4872] },
          { name: '乌鲁木齐', value: [87.6168, 43.8256] }
        ]
      }
    ]
  }
  dealerShipmentChart.setOption(option)
}

// 初始化区域销售趋势图表
const initRegionSalesChart = () => {
  if (!regionSalesChartRef.value) return
  regionSalesChart = echarts.init(regionSalesChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    legend: {
      data: ['华东', '华南', '华北', '西南', '西北'],
      textStyle: {
        color: '#fff'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'category',
      data: ['1月', '2月', '3月', '4月', '5月', '6月'],
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      }
    },
    yAxis: {
      type: 'value',
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(255,255,255,0.1)'
        }
      }
    },
    series: [
      {
        name: '华东',
        type: 'line',
        smooth: true,
        data: [320, 332, 301, 334, 390, 330],
        itemStyle: { color: '#30cfd0' }
      },
      {
        name: '华南',
        type: 'line',
        smooth: true,
        data: [220, 182, 191, 234, 290, 330],
        itemStyle: { color: '#c43ad6' }
      },
      {
        name: '华北',
        type: 'line',
        smooth: true,
        data: [150, 232, 201, 154, 190, 330],
        itemStyle: { color: '#83bff6' }
      },
      {
        name: '西南',
        type: 'line',
        smooth: true,
        data: [98, 77, 101, 99, 40, 90],
        itemStyle: { color: '#188df0' }
      },
      {
        name: '西北',
        type: 'line',
        smooth: true,
        data: [50, 60, 70, 80, 90, 100],
        itemStyle: { color: '#9c27b0' }
      }
    ]
  }
  regionSalesChart.setOption(option)
}

// 初始化经销商排行图表
const initDealerRankChart = () => {
  if (!dealerRankChartRef.value) return
  dealerRankChart = echarts.init(dealerRankChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(255,255,255,0.1)'
        }
      }
    },
    yAxis: {
      type: 'category',
      data: ['经销商A', '经销商B', '经销商C', '经销商D', '经销商E'],
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      }
    },
    series: [{
      name: '销售额',
      type: 'bar',
      data: [320, 302, 301, 334, 390],
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [{
          offset: 0,
          color: '#83bff6'
        }, {
          offset: 0.5,
          color: '#188df0'
        }, {
          offset: 1,
          color: '#188df0'
        }])
      }
    }]
  }
  dealerRankChart.setOption(option)
}

// 初始化产品排行图表
const initProductRankChart = () => {
  if (!productRankChartRef.value) return
  productRankChart = echarts.init(productRankChartRef.value)
  const option = {
    tooltip: {
      trigger: 'axis',
      axisPointer: {
        type: 'shadow'
      }
    },
    grid: {
      left: '3%',
      right: '4%',
      bottom: '3%',
      containLabel: true
    },
    xAxis: {
      type: 'value',
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      },
      splitLine: {
        lineStyle: {
          color: 'rgba(255,255,255,0.1)'
        }
      }
    },
    yAxis: {
      type: 'category',
      data: ['产品A', '产品B', '产品C', '产品D', '产品E'],
      axisLine: {
        lineStyle: {
          color: '#fff'
        }
      }
    },
    series: [{
      name: '销量',
      type: 'bar',
      data: [320, 302, 301, 334, 390],
      itemStyle: {
        color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [{
          offset: 0,
          color: '#c43ad6'
        }, {
          offset: 0.5,
          color: '#9c27b0'
        }, {
          offset: 1,
          color: '#9c27b0'
        }])
      }
    }]
  }
  productRankChart.setOption(option)
}

// 处理窗口大小变化
const handleResize = () => {
  if (salesTrendChart) salesTrendChart.resize()
  if (orderDistributionChart) orderDistributionChart.resize()
  if (dealerShipmentChart) dealerShipmentChart.resize()
  if (regionSalesChart) regionSalesChart.resize()
  if (dealerRankChart) dealerRankChart.resize()
  if (productRankChart) productRankChart.resize()
}

// 定时器
let timer: number

onMounted(() => {
  updateTime()
  timer = setInterval(updateTime, 1000)

  // 初始化图表
  initCharts()

  // 监听窗口大小变化
  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  clearInterval(timer)
  window.removeEventListener('resize', handleResize)

  // 销毁图表实例
  salesTrendChart?.dispose()
  orderDistributionChart?.dispose()
  dealerShipmentChart?.dispose()
  regionSalesChart?.dispose()
  dealerRankChart?.dispose()
  productRankChart?.dispose()
})
</script>

<style scoped>
.datascreen {
  width: 100%;
  height: 100vh;
  background: #0f1c3c;
  color: #fff;
  overflow: hidden;
}

.header {
  height: 60px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0 20px;
  background: rgba(255, 255, 255, 0.1);
}

.title {
  font-size: 24px;
  font-weight: bold;
  background: linear-gradient(to right, #30cfd0, #c43ad6);
  -webkit-background-clip: text;
  color: transparent;
}

.time {
  font-size: 16px;
  color: #30cfd0;
}

.overview {
  display: flex;
  justify-content: space-between;
  padding: 20px;
  gap: 20px;
}

.overview-item {
  flex: 1;
  background: rgba(255, 255, 255, 0.1);
  padding: 20px;
  border-radius: 10px;
  text-align: center;
}

.overview-item h3 {
  font-size: 16px;
  margin-bottom: 10px;
  color: #30cfd0;
}

.overview-item .value {
  font-size: 24px;
  font-weight: bold;
  color: #fff;
}

.main-content {
  display: flex;
  padding: 0 20px 20px;
  gap: 20px;
  height: calc(100vh - 180px);
}

.left-panel,
.right-panel {
  width: 20%;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.center-panel {
  width: 60%;
  display: flex;
  flex-direction: column;
  gap: 20px;
}

.panel {
  flex: 1;
  background: rgba(255, 255, 255, 0.1);
  border-radius: 10px;
  padding: 20px;
  display: flex;
  flex-direction: column;
}

.panel-title {
  font-size: 18px;
  margin-bottom: 20px;
  color: #30cfd0;
}

.chart-container {
  flex: 1;
  width: 100%;
  height: 100%;
  min-height: 300px;
}

/* 图表容器样式 */
.sales-trend-chart,
.order-distribution-chart,
.dealer-shipment-chart,
.region-sales-chart,
.dealer-rank-chart,
.product-rank-chart {
  width: 100%;
  height: 100%;
  min-height: 300px;
}
</style> 