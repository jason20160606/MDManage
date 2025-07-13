<template>
  <div class="main-card">
    <span class="card-corner tl"></span>
    <span class="card-corner tr"></span>
    <span class="card-corner bl"></span>
    <span class="card-corner br"></span>
    <div class="card-title"><span class="card-title-bar"></span>有效经销商地区</div>
    <div ref="pieRef" class="member-pie-echarts"></div>
    <div class="member-total">合计：<span class="main-value">{{ total }}</span>人</div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import * as echarts from 'echarts'

const pieRef = ref<HTMLElement | null>(null)
const total = 11950

const pieData = [
  { value: 3200, name: '华东区' },
  { value: 2800, name: '华南区' },
  { value: 2100, name: '华北区' },
  { value: 1800, name: '西南区' },
  { value: 1050, name: '西北区' }
]

onMounted(() => {
  if (pieRef.value) {

    let mychart = echarts.init(pieRef.value)
    let option = {
      tooltip: {
        trigger: 'item'
      },
      legend: {
        top: '20%',
        right: '1%',
        //图例组件方向
        orient: 'vertical',
        textStyle:{
          color:'white'

        }
      },
      series: [
        {          
          type: 'pie',
          center: ['40%', '50%'], // 居中显示
          radius: ['40%', '70%'],
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
              fontSize: 40,
              fontWeight: 'bold'
            }
          },
          labelLine: {
            show: false
          },
          data: pieData
        }
      ],
      //图形图标位置
      grid: {
        left: 0,
        right: 0,
        top: 0,
        bottom: 0
      }

    };
    mychart.setOption(option)
  }
});
</script>
<style scoped>
.main-card {
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

.member-pie {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 10px;
}

.member-pie-placeholder {
  width: 100%;
  height: 120px;
  background: rgba(0, 238, 255, 0.05);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: #00eaff;
  font-size: 14px;
  margin-bottom: 10px;
}

.member-total {
  color: #b3e5fc;
  font-size: 14px;
  margin-top: 10px;
}

.main-value {
  color: #ffd700;
  font-size: 28px;
  font-weight: bold;
  text-shadow: 0 0 12px #ffd700;
  letter-spacing: 1px;
}

.member-pie-echarts {
  width: 260px;
  height: 180px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: center;
}
</style>
