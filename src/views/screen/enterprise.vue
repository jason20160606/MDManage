<template>
  <div class="container">
    <!-- 企业经营数据大屏内容，z-index:1 -->
    <div class="screen" ref="screenRef" style="position:relative;z-index:1;">
      <!-- 顶部：企业LOGO、标题、时间等 -->
      <div class="top">
        <div class="logo-title">
          <img src="/logo.jpg" alt="LOGO" class="logo" />
          <span class="title">企业经营数据大屏</span>
          <span class="datetime">{{ nowTime }}</span>
        </div>
      </div>
      <div class="bottom">
        <!-- 左侧：经销商/工厂统计 -->
        <div class="left">
          <div class="dealer-stat card">
            <div class="card-title">经销商统计</div>
            <CountUp :end-val="statistics.dealerCount" :duration="2" class="card-number" />
            <div class="card-desc">经销商总数</div>
          </div>
          <div class="factory-stat card">
            <div class="card-title">工厂统计</div>
            <CountUp :end-val="statistics.factoryCount" :duration="2" class="card-number" />
            <div class="card-desc">工厂总数</div>
          </div>
          <div class="stock-stat card">
            <div class="card-title">库存统计</div>
            <CountUp :end-val="statistics.stockTotal" :duration="2" class="card-number" :options="{ prefix: '¥' }" />
            <div class="card-desc">当前库存总值</div>
          </div>
        </div>
        <!-- 中间：地图+趋势 -->
        <div class="center">
          <div class="map card">
            <div class="card-title">全国分布地图</div>
            <VChart :option="mapOption" autoresize style="height:320px;width:95%;" />
          </div>
          <div class="trend card">
            <div class="card-title">订单/发货/差价/运费趋势</div>
            <VChart :option="trendOption" autoresize style="height:180px;width:90%;margin-bottom:8px;" />
            <div class="card-desc">本月订单量</div>
          </div>
        </div>
        <!-- 右侧：排行榜、年度统计、实时总览 -->
        <div class="right">
          <div class="rank card">
            <div class="card-title">发货量排行榜</div>
            <div class="card-desc">（占位）</div>
          </div>
          <div class="year-stat card">
            <div class="card-title">年度经营统计</div>
            <CountUp :end-val="statistics.yearTotal" :duration="2" class="card-number" :options="{ prefix: '¥' }" />
            <div class="card-desc">年度总营收</div>
          </div>
          <div class="realtime card">
            <div class="card-title">实时总览</div>
            <CountUp :end-val="statistics.realtime" :duration="2" class="card-number" />
            <div class="card-desc">当前在线用户</div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { CountUp } from 'vue3-countup'
import VChart from 'vue-echarts'
import { use } from 'echarts/core'
import { BarChart, LineChart, MapChart } from 'echarts/charts'
import { TitleComponent, TooltipComponent, GridComponent, VisualMapComponent, LegendComponent } from 'echarts/components'
import { CanvasRenderer } from 'echarts/renderers'
import * as echarts from 'echarts/core'

// 注册Echarts组件
use([BarChart, LineChart, MapChart, TitleComponent, TooltipComponent, GridComponent, VisualMapComponent, LegendComponent, CanvasRenderer])

// 当前时间
const nowTime = ref('')
let screenRef = ref()

// 统计数据，模拟动态变化
const statistics = ref({
  dealerCount: 18,
  factoryCount: 5,
  stockTotal: 120000,
  trendValue: 3200,
  yearTotal: 980000,
  realtime: 128
})

// Echarts折线图option
const trendOption = ref({
  title: { text: '订单趋势', left: 'center', textStyle: { color: '#fff' } },
  tooltip: {},
  xAxis: { data: ['1月','2月','3月','4月','5月','6月'], axisLabel: { color: '#fff' } },
  yAxis: { axisLabel: { color: '#fff' } },
  series: [{ type: 'line', data: [120, 200, 150, 80, 70, 110], smooth: true }]
})

// 地图option
const mapOption = ref({
  title: { text: '全国分布', left: 'center', textStyle: { color: '#fff' } },
  tooltip: {},
  visualMap: { min: 0, max: 1000, left: 'left', top: 'bottom', text: ['高','低'], inRange: { color: ['#e0ffff', '#006edd'] }, textStyle: { color: '#fff' } },
  series: [{
    type: 'map',
    map: 'china',
    roam: true,
    label: { show: false },
    data: [
      { name: '北京', value: 500 },
      { name: '上海', value: 800 },
      { name: '广东', value: 600 },
      { name: '浙江', value: 400 },
      { name: '四川', value: 300 },
      { name: '湖北', value: 200 }
    ]
  }]
})

// 加载中国地图json（用fetch，不用import）
onMounted(async () => {
  screenRef.value.style.transform = `scale(${getScale()}) translate(-50%,-50%)`
  updateTime()
  setInterval(updateTime, 1000)
  setInterval(randomChange, 5000)
  // 注册中国地图
  const res = await fetch('/china.json')
  const geoJson = await res.json()
  echarts.registerMap('china', geoJson)
})

// 定时动态变化（模拟数据刷新）
function randomChange() {
  statistics.value.dealerCount = 18 + Math.floor(Math.random() * 3)
  statistics.value.factoryCount = 5 + Math.floor(Math.random() * 2)
  statistics.value.stockTotal = 120000 + Math.floor(Math.random() * 5000)
  statistics.value.trendValue = 3200 + Math.floor(Math.random() * 200)
  statistics.value.yearTotal = 980000 + Math.floor(Math.random() * 10000)
  statistics.value.realtime = 120 + Math.floor(Math.random() * 20)

  // 动态生成折线图数据
  const months = ['1月','2月','3月','4月','5月','6月']
  const lineData = months.map(() => 100 + Math.floor(Math.random() * 400))
  trendOption.value = {
    ...trendOption.value,
    series: [{ type: 'line', data: lineData, smooth: true }]
  }

  // 动态生成地图数据
  const mapData = [
    { name: '北京', value: 300 + Math.floor(Math.random() * 700) },
    { name: '上海', value: 300 + Math.floor(Math.random() * 700) },
    { name: '广东', value: 300 + Math.floor(Math.random() * 700) },
    { name: '浙江', value: 300 + Math.floor(Math.random() * 700) },
    { name: '四川', value: 300 + Math.floor(Math.random() * 700) },
    { name: '湖北', value: 300 + Math.floor(Math.random() * 700) }
  ]
  mapOption.value = {
    ...mapOption.value,
    series: [{
      ...mapOption.value.series[0],
      data: mapData
    }]
  }
}

// 更新时间
function updateTime() {
  const now = new Date()
  const y = now.getFullYear()
  const m = String(now.getMonth() + 1).padStart(2, '0')
  const d = String(now.getDate()).padStart(2, '0')
  const h = String(now.getHours()).padStart(2, '0')
  const min = String(now.getMinutes()).padStart(2, '0')
  const s = String(now.getSeconds()).padStart(2, '0')
  nowTime.value = `${y}-${m}-${d} ${h}:${min}:${s}`
}

function getScale(w = 1920, h = 1080) {
  let scaleX = window.innerWidth / w
  let scaleY = window.innerHeight / h
  return Math.min(scaleX, scaleY)
}
</script>

<style scoped lang="scss">
.container {
  width: 100vw;
  height: 100vh;
  background: url('./images/bg.png') no-repeat center;
  background-size: cover;
  .screen {
    width: 1920px;
    height: 1080px;
    left: 50%;
    top: 50%;
    position: fixed;
    transform-origin: left top;
    .top {
      width: 100%;
      height: 60px;
      display: flex;
      align-items: center;
      .logo-title {
        display: flex;
        align-items: center;
        .logo {
          width: 48px;
          height: 48px;
          margin-right: 20px;
          border-radius: 50%;
          box-shadow: 0 0 12px #3a8ee6;
        }
        .title {
          font-size: 36px;
          font-weight: bold;
          background: linear-gradient(90deg, #3a8ee6, #67c23a 80%);
          -webkit-background-clip: text;
          -webkit-text-fill-color: transparent;
          margin-right: 32px;
          letter-spacing: 2px;
        }
        .datetime {
          font-size: 20px;
          color: #fff;
          text-shadow: 0 0 8px #3a8ee6;
          animation: blink 1.2s infinite alternate;
        }
        @keyframes blink {
          0% { opacity: 1; }
          100% { opacity: 0.7; }
        }
      }
    }
    .bottom {
      display: flex;
      .left, .right {
        flex: 1;
        height: 1020px;
        display: flex;
        flex-direction: column;
        .card {
          flex: 1;
          margin: 10px 0;
          background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
          box-shadow: 0 0 20px #2a5298, 0 2px 8px rgba(0,0,0,0.2);
          border: 1.5px solid #3a8ee6;
          border-radius: 12px;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          font-size: 22px;
          color: #fff;
          transition: transform 0.2s, box-shadow 0.2s;
          &:hover {
            transform: translateY(-6px) scale(1.03);
            box-shadow: 0 0 40px #3a8ee6, 0 4px 16px rgba(0,0,0,0.3);
          }
          .card-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 8px;
            letter-spacing: 1px;
          }
          .card-number {
            font-size: 38px;
            font-weight: bold;
            color: #ffd700;
            margin-bottom: 6px;
            text-shadow: 0 0 8px #fff, 0 0 16px #3a8ee6;
          }
          .card-desc {
            font-size: 16px;
            color: #b3e5fc;
          }
        }
      }
      .center {
        flex: 2;
        display: flex;
        flex-direction: column;
        .card {
          margin: 10px 0;
          background: linear-gradient(135deg, #1e3c72 0%, #2a5298 100%);
          box-shadow: 0 0 20px #2a5298, 0 2px 8px rgba(0,0,0,0.2);
          border: 1.5px solid #3a8ee6;
          border-radius: 12px;
          display: flex;
          flex-direction: column;
          align-items: center;
          justify-content: center;
          font-size: 22px;
          color: #fff;
          .card-title {
            font-size: 20px;
            font-weight: bold;
            margin-bottom: 8px;
            letter-spacing: 1px;
          }
          .card-number {
            font-size: 38px;
            font-weight: bold;
            color: #ffd700;
            margin-bottom: 6px;
            text-shadow: 0 0 8px #fff, 0 0 16px #3a8ee6;
          }
          .card-desc {
            font-size: 16px;
            color: #b3e5fc;
          }
        }
        .map {
          flex: 4;
        }
        .trend {
          flex: 1;
        }
      }
    }
  }
}
</style> 