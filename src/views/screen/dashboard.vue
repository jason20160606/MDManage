<template>
  <div class="dashboard-bg">
    <div class="dashboard-content">
      <!-- 顶部主标题区 -->
      <div class="dashboard-header">
        <div class="main-title">电商数据大屏监控系统</div>
        <div class="sub-title" @click="goHome">实时监控 | <span class="clickable">智能分析</span></div>
        <div class="now-time"> {{ nowTime }}</div>
      </div>
      <!-- 第一行：4个统计卡片横向等分 -->
      <div class="dashboard-row-stats">
        <div class="stat-card" v-for="(item, idx) in statList" :key="idx">
          <div class="stat-title">{{ item.title }}</div>
          <div class="stat-value">
            <span class="stat-main">{{ item.value }}</span>
            <span v-if="item.unit" class="stat-unit">{{ item.unit }}</span>
          </div>          
        </div>
      </div>
      <!-- 第二行：左中右三分区 -->
      <div class="dashboard-row-main">
        <div class="dashboard-col-left">
          <div class="ranking">
            <DealerPerformanceRanking  :data="dealerPerformanceRankingData"/>
          </div>
          <div class="member">
            <DealerMemberStats  :data="dealerValidMemberRankingData" />
          </div>
        </div>
        <div class="dashboard-col-center">
          <ProvinceMapStats  :data="dailyProvinceShipmentData" />
        </div>
        <div class="dashboard-col-right">
          <div class="factory">
            <FactoryShipping :data="factoryProductShipmentRankingData" />
          </div>
          <div class="today">
            <TodayShippingOrders  :data="todaySimpleOrdersData" />
          </div>
        </div>
      </div>
      <!-- 第三行：底部统计区 -->
      <div class="dashboard-row-bottom">
          <ShippingTrend />
      </div>
    </div>
    <!-- 底部版权区 -->
    <div class="dashboard-footer">
      <div class="dashboard-text-secondary">
        © 2025 电商数据大屏系统 - 实时监控 · 智能分析
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, computed } from 'vue'
import { useRouter } from 'vue-router'
import DealerPerformanceRanking from '@/views/screen/componentnew/DealerPerformanceRanking.vue'
import DealerMemberStats from '@/views/screen/componentnew/DealerMemberStats.vue'
import ProvinceMapStats from '@/views/screen/componentnew/ProvinceMapStats.vue'
import ShippingTrend from '@/views/screen/componentnew/ShippingTrend.vue'
import FactoryShipping from '@/views/screen/componentnew/FactoryShipping.vue'
import TodayShippingOrders from '@/views/screen/componentnew/TodayShippingOrders.vue'
// 统一引入大屏API（与shipping风格一致）
import {
  getShipmentTrend,
  getDealerPerformanceRanking,
  getDealerValidMemberRanking,
  getFactoryProductShipmentRanking,
  getDailyProvinceShipment,
  getTodaySimpleOrders,
  getTodayOrderSummary
} from '@/api/screen/index'

const router = useRouter()
function goHome() {
  router.push('/home')
}

const nowTime = ref('')
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

// ========== 以下为API请求，数据赋值，不绑定UI ===========
const shipmentTrendData = ref([])
const dealerPerformanceRankingData = ref([])
const dealerValidMemberRankingData = ref([])
const factoryProductShipmentRankingData = ref([])
const dailyProvinceShipmentData = ref([])
const todaySimpleOrdersData = ref([])
// 修复todayOrderSummaryData初始类型，避免computed访问属性时报错
const todayOrderSummaryData = ref({
  TodayOrderCount: 0,
  TodayShippedCount: 0,
  TotalShippedCount: 0,
  TotalAddressCount: 0
})

onMounted(() => {
  updateTime()
  setInterval(updateTime, 1000)
  const today = new Date()
  const dateStr = `${today.getFullYear()}-${String(today.getMonth()+1).padStart(2,'0')}-${String(today.getDate()).padStart(2,'0')}`
  // 1. 发货趋势
  getShipmentTrend({ days: 30 }).then(res => {
    shipmentTrendData.value = res.data
  })
  // 获取经销商业绩排行数据，并转换为子组件需要的格式
  getDealerPerformanceRanking({ year: today.getFullYear() }).then(res => {
    // 将接口返回的 DealerName/PerformanceTotal 转为 name/value
    dealerPerformanceRankingData.value = (res.data || []).map(item => ({
      name: item.DealerName,
      value: item.PerformanceTotal
    }))
  })
  // 3. 有效经销商地区
  getDealerValidMemberRanking().then(res => {
    dealerValidMemberRankingData.value = res.data
  })
  // 4. 工厂发货排行
  getFactoryProductShipmentRanking({ year: today.getFullYear() }).then(res => {
    // 将接口返回的 ProductName/ShipmentTotal 转为 name/value
    factoryProductShipmentRankingData.value = (res.data || []).map(item => ({
      name: item.ProductName,
      value: item.ShipmentTotal
    }))
  })
  // 5. 发货分布（省份）
  getDailyProvinceShipment({ date: dateStr }).then(res => {
  // 省份名称自动适配geoCoordMap
  function adaptProvinceName(name) {
    if (!name) return '未知';
    let simple = name.replace(/省|市|壮族自治区|回族自治区|维吾尔自治区|自治区|特别行政区/g, '');
    // geoCoordMap的key列表
    const geoKeys = [
      '北京','天津','上海','重庆','河北','山西','辽宁','吉林','黑龙江','江苏','浙江','安徽','福建','江西','山东','河南','湖北','湖南','广东','海南','四川','贵州','云南','陕西','甘肃','青海','台湾','内蒙古','广西','西藏','宁夏','新疆','香港','澳门'
    ];
    for (const key of geoKeys) {
      if (name.includes(key) || simple.includes(key)) {
        return key;
      }
    }
    return simple;
  }
  dailyProvinceShipmentData.value = (res.data || []).map(item => ({
    name: adaptProvinceName(item.Province),
    value: item.ShipmentQuantity
  }))
})
  // 6. 当日订单信息
  getTodaySimpleOrders({ date: dateStr }).then(res => {
    todaySimpleOrdersData.value = res.data
  })
  // 7. 头部卡片统计
  getTodayOrderSummary({ date: dateStr }).then(res => {
    todayOrderSummaryData.value = res.data
  })
})

// 统计卡片数据动态绑定API
const statList = computed(() => [
  { title: '今日订单量', value: todayOrderSummaryData.value.TodayOrderCount ?? '-', unit: '', trend: 0 },
  { title: '今日发货量', value: todayOrderSummaryData.value.TodayShippedCount ?? '-', unit: '', trend: 0 },
  { title: '总销售量', value: todayOrderSummaryData.value.TotalShippedCount ?? '-', unit: '万', trend: 0 },
  { title: '活跃经销商', value: todayOrderSummaryData.value.TotalAddressCount ?? '-', unit: '', trend: 0 }
])
</script>

<style scoped lang="scss">

//背景
.dashboard-bg {
  width: 100vw;
  min-height: 100vh;
  background: linear-gradient(135deg, #183661 0%, #0a1833 100%);
  position: relative;
  overflow: hidden;
  display: flex;
  flex-direction: column;
  align-items: center;
  //布局
  .dashboard-content {
    display: flex;
    flex-direction: column;
    gap: 24px;
    // 顶部主标题区
    .dashboard-header {
      width: 1920px;
      margin: 0 auto;
      display: flex;
      flex-direction: column;
      align-items: center;
      padding-top: 32px;
      .main-title {
        font-size: 44px;
        font-weight: bold;
        color: #fff;
        letter-spacing: 6px;
        text-shadow: 0 0 24px #00eaff, 0 0 48px #0056ff;
        margin-bottom: 8px;
      }
      .sub-title {
        font-size: 18px;
        color: #b3e5fc;
        margin-bottom: 8px;
        cursor: pointer;
        transition: color 0.2s;
        &:hover {
          color: #00eaff;
          text-shadow: 0 0 8px #00eaff;
        }
        .clickable {
          color: #00eaff;
          text-shadow: 0 0 8px #00eaff;
        }
      }
      .now-time {
        font-size: 14px;
        color: #b3e5fc;
        margin-bottom: 8px;
      }      
    }

    // 第一行：统计卡片区
    .dashboard-row-stats {
      height: 110px;  
      .stat-card {
        flex: 1;
        margin: 0 12px;
        background: linear-gradient(135deg, #1b2b4a 0%, #183661 100%);
        border-radius: 16px;
        border: 2px solid #00eaff55; // 发光边框
        box-shadow: 0 0 24px #00eaff33, 0 2px 8px rgba(0,0,0,0.4); // 阴影
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        color: #fff;
        position: relative;
        overflow: hidden;
        // 卡片发光动画可选
        transition: box-shadow 0.3s;
        &:hover {
          box-shadow: 0 0 32px #00eaff99, 0 2px 16px rgba(0,0,0,0.5);
        }
        .stat-title {
          font-size: 18px;
          color: #b3e5fc;
          margin-bottom: 6px;
          letter-spacing: 1px;
        }
        .stat-value {
          display: flex;
          align-items: flex-end;
          justify-content: center;
          margin-bottom: 4px;
          .stat-main {
            font-size: 38px;
            font-weight: bold;
            color: #00eaff;
            text-shadow: 0 0 12px #00eaff, 0 0 24px #0056ff;
            line-height: 1;
          }
          .stat-unit {
            font-size: 18px;
            color: #b3e5fc;
            margin-left: 4px;
            line-height: 1.2;
          }
        }
        .stat-trend {
          display: flex;
          align-items: center;
          font-size: 16px;
          font-weight: bold;
          margin-top: 2px;
          &.up {
            color: #00eaff;
          }
          &.down {
            color: #ff4d4f;
          }
          .trend-icon {
            margin-right: 4px;
            vertical-align: middle;
          }
        }
      }      
    }
    // 第二行：主区块三分区
    .dashboard-row-main {
      height: 680px;
      width: 1920px;
      margin: 0 auto;
      display: flex;
      align-items: stretch;      
      .dashboard-col-left, .dashboard-col-right {
        width: 340px;
        min-width: 340px;
        max-width: 340px;
        gap: 18px;        
      }      
      .dashboard-col-center {
        flex: 1;
        min-width: 500;
        margin: 0 18px;
        align-items: center;
        justify-content: center;
      }
      .ranking,.factory{
        height: 360px;
        margin-bottom: 20px;
      }
      .member,.today{
        height: 300px;
      }
    }
    .main-card {
      flex: 1;
      display: flex;
      flex-direction: column;
      height: 100%;
      min-height: 0;
    }
    // 第三行：底部统计区
    .dashboard-row-bottom {
      height: 220px;
      width: 1920px;
      margin: 0 auto;
      display: flex;
      align-items: stretch;  
    }
  }
}

.dashboard-footer {
  width: 1920px;
  margin: 0 auto;
  display: flex;
  justify-content: center;
  align-items: center;
  position: relative;
  bottom: 0;
  left: 50%;
  transform: translateX(-50%);
  z-index: 1;
  gap: 18px;
  color: #b3e5fc;
  font-size: 14px;
  margin-top: 12px;
  margin-bottom: 12px;
}

.dashboard-row-stats, .dashboard-row-main, .dashboard-row-bottom {
  width: 1920px;  
  display: flex;
}
</style> 