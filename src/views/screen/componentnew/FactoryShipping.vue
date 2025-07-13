<template>
  <div class="main-card ranking-card">
    <!-- 顶部发光横线装饰 -->
    <div class="card-top-glow"></div>
    <span class="card-corner tl"></span>
    <span class="card-corner tr"></span>
    <span class="card-corner bl"></span>
    <span class="card-corner br"></span>
    <div class="card-title"><span class="card-title-bar"></span>工厂发货排行TOP10</div>
    <ul class="rank-list">
      <li v-for="(item, idx) in list" :key="item.name" class="rank-item" :class="'rank-item-' + (idx+1)">
        <span class="rank-index" :class="'rank-index-' + (idx+1)">
          <span v-if="idx < 3" class="rank-index-glow">{{ idx+1 }}</span>
          <span v-else>{{ idx+1 }}</span>
        </span>
        <span class="rank-name">{{ item.name }}</span>
        <span class="rank-value">{{ item.value }} 箱</span>
      </li>
    </ul>
    <!-- 卡片底部发光阴影 -->
    <div class="card-bottom-glow"></div>
  </div>
</template>
<script setup lang="ts">
// 支持外部传入工厂发货排行数据，优先用props，否则用mock
import { defineProps, computed } from 'vue'
// 声明props，类型可根据实际数据结构调整
const props = defineProps<{ data?: { name: string, value: number }[] }>()
// mock数据
const mockList = [
  { name: '基础流通', value: 8520 },
  { name: '冰箱', value: 6800 },
  { name: '家电流通', value: 5600 },
  { name: 'AI定制流通', value: 4850 },
  { name: '流动加', value: 4200 },
  { name: '24K金/水', value: 3950 },
  { name: '24K金/乳', value: 2800 },
  { name: '24K金/纯度箱', value: 2450 },
  { name: '24K金/纯度箱', value: 2100 },
  { name: '24K金/纯度箱', value: 1800 }
]
// 计算属性，优先展示父组件传入的数据
const list = computed(() => props.data && props.data.length ? props.data : mockList)
</script>
<style scoped>
.main-card.ranking-card {
  font-family: var(--default-font-family, ui-sans-serif, system-ui, sans-serif, "Apple Color Emoji", "Segoe UI Emoji", "Segoe UI Symbol", "Noto Color Emoji");
  background: linear-gradient(135deg, #1b2b4a 0%, #183661 100%);
  border-radius: 16px;
  border: 2px solid #00eaff55;
  box-shadow: 0 0 24px #00eaff33, 0 2px 8px rgba(0,0,0,0.4);
  color: #fff;
  min-width: 0;
  position: relative;
  padding: 14px 10px 10px 10px; /* 缩小内边距 */
  display: flex;
  flex-direction: column;
  align-items: flex-start;
  overflow: visible;
  .card-bottom-glow {
    position: absolute;
    left: 10px; right: 10px; bottom: 4px;
    height: 8px;
    border-radius: 50%;
    background: radial-gradient(ellipse at center, #00eaff55 0%, transparent 80%);
    opacity: 0.5;
    z-index: 1;
    pointer-events: none;
  }
}
.card-top-glow {
  position: absolute;
  left: 0; right: 0; top: 0;
  height: 4px;
  background: linear-gradient(90deg, #00eaff 0%, #0056ff 100%);
  border-radius: 2px;
  opacity: 0.5;
  z-index: 2;
  pointer-events: none;
}
.card-corner {
  position: absolute;
  width: 14px; height: 14px;
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
.rank-list {
  width: 100%;
  margin: 0;
  padding: 0;
  list-style: none;
  z-index: 2;
}
.rank-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 7px 0 7px 0;
  border-bottom: 1px solid #223a5a;
  font-size: 13px;
  color: #fff;
  transition: background 0.2s;
}
.rank-item:last-child {
  border-bottom: none;
}
.rank-item:hover {
  background: rgba(0,238,255,0.08);
}
.rank-index {
  width: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 13px;
  color: #ffd700;
  margin-right: 4px;
}
.rank-index-glow {
  display: inline-block;
  width: 18px;
  height: 18px;
  line-height: 18px;
  text-align: center;
  font-size: 13px;
  font-weight: bold;
  color: #fff;
  border-radius: 50%;
  background: linear-gradient(135deg, #ffd700 0%, #00eaff 100%);
  box-shadow: 0 0 8px #ffd700, 0 0 10px #00eaff;
  filter: brightness(1.1);
}
.rank-index-1 .rank-index-glow {
  background: linear-gradient(135deg, #ffd700 0%, #fffbe6 100%);
  color: #222;
  box-shadow: 0 0 10px #ffd700, 0 0 14px #fffbe6;
}
.rank-index-2 .rank-index-glow {
  background: linear-gradient(135deg, #b3e5fc 0%, #00eaff 100%);
  color: #183661;
  box-shadow: 0 0 8px #00eaff, 0 0 10px #b3e5fc;
}
.rank-index-3 .rank-index-glow {
  background: linear-gradient(135deg, #ff8c00 0%, #ffd700 100%);
  color: #fff;
  box-shadow: 0 0 8px #ff8c00, 0 0 10px #ffd700;
}
.rank-name {
  flex: 1;
  text-align: left;
  color: #b3e5fc;
  font-size: 13px;
}
.rank-value {
  color: #00eaff;
  font-size: 13px;
  text-shadow: 0 0 6px #00eaff;
}
</style>