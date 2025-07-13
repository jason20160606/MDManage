<script setup lang="ts">
import { ref, onMounted, onUnmounted, computed } from 'vue'

const PAGE_SIZE = 3

// 订单数据示例（精简字段）
const orders = ref([
  { id: 1, no: 'SHP-2025-001', dealer: '深圳经销商', status: 'shipped', statusText: '已发货', statusClass: 'tag-shipped' },
  { id: 2, no: 'SHP-2025-002', dealer: '上海经销商', status: 'audited', statusText: '已审核', statusClass: 'tag-audited' },
  { id: 3, no: 'SHP-2025-003', dealer: '北京经销商', status: 'cancelled', statusText: '已取消', statusClass: 'tag-cancelled' },
  { id: 4, no: 'SHP-2025-004', dealer: '广州经销商', status: 'shipped', statusText: '已发货', statusClass: 'tag-shipped' },
  { id: 5, no: 'SHP-2025-005', dealer: '成都经销商', status: 'audited', statusText: '已审核', statusClass: 'tag-audited' },
  { id: 6, no: 'SHP-2025-006', dealer: '杭州经销商', status: 'shipped', statusText: '已发货', statusClass: 'tag-shipped' }
])

const pageCount = computed(() => Math.ceil(orders.value.length / PAGE_SIZE))
const currentIndex = ref(0)
let timer: any = null

onMounted(() => {
  timer = setInterval(() => {
    // 到最后一页后无缝回到第一页
    currentIndex.value = (currentIndex.value + 1) % pageCount.value
  }, 3000)
})
onUnmounted(() => {
  clearInterval(timer)
})
</script>

<template>
  <div class="main-card">
    <span class="card-corner tl"></span>
    <span class="card-corner tr"></span>
    <span class="card-corner bl"></span>
    <span class="card-corner br"></span>
    <div class="card-title">当日订单</div>
    <div class="order-list-wrapper">
      <ul
        class="order-list"
        :style="{ transform: `translateY(-${currentIndex * 180}px)` }"
      >
        <li v-for="order in orders" :key="order.id" class="order-item">
          <div class="order-header">
            <span class="order-no">{{ order.no }}</span>
            <span class="order-dealer">{{ order.dealer }}</span>
            <span :class="['order-status-tag', order.statusClass]">{{ order.statusText }}</span>
          </div>
        </li>
      </ul>
    </div>
    <div class="order-pagination">
      <span v-for="i in pageCount" :key="i" :class="['dot', { active: i-1 === currentIndex }]" />
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
.order-list-wrapper {
  width: 100%;
  height: 180px;
  margin-bottom: 10px;
  overflow: hidden;
  position: relative;
}
.order-list {
  list-style: none;
  margin: 0;
  padding: 0;
  transition: transform 0.5s cubic-bezier(.4,0,.2,1);
}
.order-item {
  background: rgba(20,40,80,0.95);
  border-radius: 10px;
  box-shadow: 0 2px 8px #00eaff11;
  margin-bottom: 12px;
  padding: 12px 14px 10px 14px;
  color: #fff;
  position: relative;
  border: 1px solid #183661;
  transition: box-shadow 0.3s;
  height: 50px;
  display: flex;
  align-items: center;
}
.order-item:last-child { margin-bottom: 0; }
.order-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0;
  width: 100%;
}
.order-no {
  color: #b3e5fc;
  font-size: 13px;
}
.order-dealer {
  color: #fff;
  font-size: 13px;
  margin-left: 16px;
  flex: 1;
}
.order-status-tag {
  font-size: 13px;
  padding: 2px 12px;
  border-radius: 8px;
  margin-left: 8px;
  margin-right: 0;
  color: #fff;
  box-shadow: 0 0 6px #00eaff33;
}
.tag-shipped {
  background: linear-gradient(90deg, #00eaff 60%, #0056ff 100%);
}
.tag-audited {
  background: linear-gradient(90deg, #ffb300 60%, #ff4d4f 100%);
}
.tag-cancelled {
  background: linear-gradient(90deg, #00c48f 60%, #43e97b 100%);
}
.order-pagination {
  display: flex;
  justify-content: center;
  align-items: center;
  margin-top: 4px;
  width: 100%;
}
.dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: #233a5c;
  margin: 0 3px;
  transition: background 0.3s;
}
.dot.active {
  background: #00eaff;
  box-shadow: 0 0 6px #00eaff;
}
</style>