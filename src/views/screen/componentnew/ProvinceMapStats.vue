<template>
  <div class="main-card">

    <div class="card-title">全国发货分布热力地图</div>
    <!-- 集成ECharts中国地图，容器必须有宽高 -->
    <div ref="mapRef" class="map-area"></div>
    <div class="map-legend-row">
      <span class="legend-title">发货量：</span>
      <span class="legend-dot dot1"></span>300+单
      <span class="legend-dot dot2"></span>200-299单
      <span class="legend-dot dot3"></span>100-199单
      <span class="legend-dot dot4"></span>&lt;100单
    </div>
  </div>
</template>
<script setup lang="ts">
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'
// 引入中国地图GeoJSON
import chinaJSON from './china.json'

const mapRef = ref()

const mapData = [
  { name: '广东', value: 320 },
  { name: '江苏', value: 280 },
  { name: '山东', value: 210 },
  { name: '新疆', value: 210 },
  { name: '浙江', value: 180 },
  { name: '河南', value: 105 },
  { name: '四川', value: 95 },
  { name: '河北', value: 80 },
  { name: '上海', value: 60 }
]

const geoCoordMap = {
  北京: [116.405285, 39.904989],
  天津: [117.190182, 39.125596],
  上海: [121.472644, 31.231706],
  重庆: [106.504962, 29.533155],
  河北: [114.502461, 38.045474],
  山西: [112.549248, 37.857014],
  辽宁: [123.429096, 41.796767],
  吉林: [125.3245, 43.886841],
  黑龙江: [126.642464, 45.756967],
  江苏: [118.767413, 32.041544],
  浙江: [120.153576, 30.287459],
  安徽: [117.283042, 31.86119],
  福建: [119.306239, 26.075302],
  江西: [115.892151, 28.676493],
  山东: [117.000923, 36.675807],
  河南: [113.665412, 34.757975],
  湖北: [114.298572, 30.584355],
  湖南: [112.982279, 28.19409],
  广东: [113.280637, 23.125178],
  海南: [110.33119, 20.031971],
  四川: [104.065735, 30.659462],
  贵州: [106.713478, 26.578343],
  云南: [102.712251, 25.040609],
  陕西: [108.948024, 34.263161],
  甘肃: [103.823557, 36.058039],
  青海: [101.778916, 36.623178],
  台湾: [121.509062, 25.044332],
  内蒙古: [111.670801, 40.818311],
  广西: [108.320004, 22.82402],
  西藏: [91.132212, 29.660361],
  宁夏: [106.278179, 38.46637],
  新疆: [87.617733, 43.792818],
  香港: [114.173355, 22.320048],
  澳门: [113.54909, 22.198951]
}

const linesData = mapData.map(item => ({
  fromName: '广东',
  toName: item.name,
  coords: [geoCoordMap['广东'], geoCoordMap[item.name]],
  value: item.value
}))

echarts.registerMap('china', chinaJSON as any)

onMounted(() => {
  let mychart = echarts.init(mapRef.value)
  mychart.setOption({
    geo: {
      map: 'china',
      roam: true,
      zoom:1.5,
      top:150,
      label: { show: false, color: '#b3e5fc', fontSize: 12 },
      itemStyle: { areaColor: '#12235c', borderColor: '#00eaff', borderWidth: 1, shadowColor: '#00eaff55', shadowBlur: 10 },
      emphasis: { label: { show: true, color: '#ffd700', fontWeight: 'bold' }, itemStyle: { areaColor: '#00eaff', shadowBlur: 20, shadowColor: '#00eaff99' } },
      z: 1
    },
    series: [
      {
        name: '发货航线',
        type: 'lines',
        coordinateSystem: 'geo',
        zlevel: 2,
        effect: { show: true, period: 4, trailLength: 0.2, color: '#FFE269', symbol: 'arrow', symbolSize: 5 },
        lineStyle: { color: '#FFE269', width: 2, opacity: 0.7, curveness: 0.25 },
        data: linesData
      },
      {
        name: '发货量',
        type: 'effectScatter',
        coordinateSystem: 'geo',
        zlevel: 3,
        rippleEffect: { brushType: 'stroke', scale: 4 },
        label: { show: true, position: 'right', formatter: '{b}', color: '#fff', fontSize: 13 },
        symbolSize: function (val: any) { return Math.max(10, val[2] / 20) },
        itemStyle: { color: '#ffd700', shadowBlur: 10, shadowColor: '#ffd70099' },
        data: mapData.map(item => ({ name: item.name, value: [...geoCoordMap[item.name], item.value] }))
      }
    ],
    tooltip: {
      trigger: 'item',
      formatter: function (params: any) {
        if (params.seriesType === 'effectScatter') {
          return params.name + '<br/>发货量：' + params.value[2] + '单';
        } else if (params.seriesType === 'lines') {
          return params.data.fromName + ' → ' + params.data.toName + '<br/>发货量：' + params.data.value + '单';
        } else {
          return params.name;
        }
      }
    },
    grid: { left: 0, top: 0, right: 0, bottom: 0 }
  })
})
</script>
<style scoped>
.main-card {
  font-family: var(--default-font-family, ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji");
  background: linear-gradient(135deg, #1b2b4a 0%, #183661 100%);
  border-radius: 16px;
  border: 2px solid #00eaff55;
  box-shadow: 0 0 24px #00eaff33, 0 2px 8px rgba(0, 0, 0, 0.4);
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
  width: 18px;
  height: 18px;
  border: 2px solid #00eaff;
  z-index: 2;
}

.card-corner.tl {
  top: -2px;
  left: -2px;
  border-bottom: none;
  border-right: none;
}

.card-corner.tr {
  top: -2px;
  right: -2px;
  border-bottom: none;
  border-left: none;
}

.card-corner.bl {
  bottom: -2px;
  left: -2px;
  border-top: none;
  border-right: none;
}

.card-corner.br {
  bottom: -2px;
  right: -2px;
  border-top: none;
  border-left: none;
}

.card-title {
  color: #b3e5fc;
  font-size: 18px;
  margin-bottom: 18px;
  letter-spacing: 1px;
  text-align: center;
  width: 100%;
}

.map-area {
  width: 100%;
  height: 580px;
  background: rgba(0, 238, 255, 0.05);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #00eaff;
  font-size: 16px;
  margin-bottom: 10px;
}

.map-legend-row {
  display: flex;
  align-items: center;
  gap: 12px;
  font-size: 14px;
  color: #b3e5fc;
  margin-top: 4px;
}

.legend-title {
  color: #b3e5fc;
  font-size: 14px;
}

.legend-dot {
  display: inline-block;
  width: 12px;
  height: 12px;
  border-radius: 50%;
  margin-right: 2px;
}

.dot1 {
  background: #00eaff;
}

.dot2 {
  background: #1e90ff;
}

.dot3 {
  background: #ffd700;
}

.dot4 {
  background: #ff4d4f;
}
</style>