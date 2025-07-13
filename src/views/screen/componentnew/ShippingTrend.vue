<script setup lang="ts">
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'

const trendRef = ref<HTMLElement | null>(null)

// 生成最近30天日期
function getLast30Days() {
  const days = []
  const now = new Date()
  for (let i = 29; i >= 0; i--) {
    const d = new Date(now)
    d.setDate(now.getDate() - i)
    days.push(`${d.getMonth() + 1}/${d.getDate()}`)
  }
  return days
}

const xData = getLast30Days()
// 示例发货量数据
const yData = Array.from({ length: 30 }, () => Math.floor(Math.random() * 100 + 100))

onMounted(() => {
  if (trendRef.value) {
    const chart = echarts.init(trendRef.value)
    const option = {
      tooltip: {
        trigger: 'axis',
        backgroundColor: 'rgba(20,40,80,0.95)',
        borderColor: '#00eaff',
        borderWidth: 1,
        textStyle: { color: '#fff' }
      },
      grid: {
        left: 30,
        right: 30,
        top: 10,
        bottom: 0,
        containLabel: true
      },
      xAxis: {
        type: 'category',
        data: xData,
        boundaryGap: false,
        axisLine: { lineStyle: { color: '#00eaff' } },
        axisLabel: { color: '#b3e5fc', fontSize: 12 }
      },
      yAxis: {
        type: 'value',
        axisLine: { show: false },
        splitLine: { lineStyle: { color: '#183661' } },
        axisLabel: { color: '#b3e5fc', fontSize: 12 }
      },
      legend: {
        show: true,
        data: ['发货量'],
        left: 'center',
        top: 0,
        itemWidth: 18,
        itemHeight: 12,
        textStyle: { color: '#00eaff', fontSize: 14 }
      },
      series: [
        {
          name: '发货量',
          type: 'line',
          data: yData,
          smooth: true,
          symbol: 'circle',
          symbolSize: 6,
          lineStyle: {
            color: '#00eaff', // 主色
            width: 3,
            shadowColor: '#00eaff99',
            shadowBlur: 8
          },
          itemStyle: {
            color: '#00eaff',
            borderColor: '#fff',
            borderWidth: 2
          },
          areaStyle: {
            color: 'rgba(0,234,255,0.15)'
          },
          // 折线绘制动画
          animation: true,
          animationDuration: 1200, // 动画时长（毫秒）
          animationEasing: 'cubicOut',
          // 数据点出现动画
          animationDelay: function (idx) {
            return idx * 30;
          },
          // 鼠标悬停高亮动画
          emphasis: {
            focus: 'series',
            itemStyle: {
              color: '#ffd700',
              borderColor: '#fff',
              borderWidth: 3,
              shadowBlur: 12,
              shadowColor: '#ffd70099'
            },
            lineStyle: {
              width: 4,
              color: '#ffd700'
            }
          }
        }
      ]
    }
    chart.setOption(option)
  }
})
</script>

<template>
  <div class="main-card">
    <span class="card-corner tl"></span>
    <span class="card-corner tr"></span>
    <span class="card-corner bl"></span>
    <span class="card-corner br"></span>
    <div class="card-title"><span class="card-title-bar"></span>发货趋势（近30天）</div>
    <!-- 集成ECharts折线图，容器必须有宽高 -->
    <div ref="trendRef" class="trend-area"></div>
    <div class="trend-legend-row">
      <span class="legend-title">图例：</span>
      <span class="legend-dot dot1"></span>发货量
      <span class="legend-dot dot2"></span>同比
    </div>
  </div>
</template>
<style scoped>
.main-card {
  font-family: var(--default-font-family, ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji");
  background: linear-gradient(135deg, #1b2b4a 0%, #183661 100%);
  border-radius: 16px;
  border: 2px solid #00eaff55;
  box-shadow: 0 0 24px #00eaff33, 0 2px 8px rgba(0,0,0,0.4);
  color: #fff;
  min-width: 0;
  position: relative;
  padding: 22px 16px 18px 16px;
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  overflow: visible;
}
.card-corner {
  position: absolute;
  width: 18px; height: 18px;
  border: 2px solid #00eaff;
  z-index: 2;
}
.card-corner.tl { top: -2px; left: -2px; border-bottom: none; border-right: none; }
.card-corner.tr { top: -2px; right: -2px; border-bottom: none; border-left: none; }
.card-corner.bl { bottom: -2px; left: -2px; border-top: none; border-right: none; }
.card-corner.br { bottom: -2px; right: -2px; border-top: none; border-left: none; }
.card-title {
  color: #b3e5fc;
  font-size: 18px;
  margin-bottom: 18px;
  letter-spacing: 1px;
  text-align: left;
  width: 100%;
}
.card-title-bar {
  display: inline-block;
  width: 3px;
  height: 14px;
  background: linear-gradient(180deg, #00eaff 0%, #0056ff 100%);
  border-radius: 2px;
  margin-right: 6px;
  box-shadow: 0 0 6px #00eaff;
}
.trend-area {
  width: 100%;
  height: 120px;
  background: rgba(0,238,255,0.05);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #00eaff;
  font-size: 16px;
  margin-bottom: 10px;
}
.trend-legend-row {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 13px;
  color: #b3e5fc;
  margin-top: 4px;
}
.legend-title {
  color: #b3e5fc;
  font-size: 13px;
}
.legend-dot {
  display: inline-block;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 2px;
}
.dot1 { background: #00eaff; }
.dot2 { background: #ffd700; }
</style>