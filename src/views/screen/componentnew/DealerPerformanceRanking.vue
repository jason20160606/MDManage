<template>
  <div class="main-card ranking-card">
    <!-- 顶部发光横线装饰 -->
    <div class="card-top-glow"></div>
    <span class="card-corner tl"></span>
    <span class="card-corner tr"></span>
    <span class="card-corner bl"></span>
    <span class="card-corner br"></span>
    <div class="card-title"><span class="card-title-bar"></span>经销商业绩排行Top10</div>
    <ul class="rank-list">
      <li v-for="(item, idx) in list" :key="item.name" class="rank-item" :class="'rank-item-' + (idx+1)">
        <span class="rank-index" :class="'rank-index-' + (idx+1)">
          <span v-if="idx === 0" class="rank-crown">
            <!-- 金色立体皇冠SVG-->
            <svg width="22" height="18" viewBox="0 0 22 18">
              <g>
                <ellipse cx="11" cy="15" rx="8" ry="2.5" fill="#ffe066" opacity="0.5"/>
                <path d="M3 13L6 5L11 12L16 5L19 13Z" fill="url(#gold)" stroke="#FFD700" stroke-width="1.5"/>
                <circle cx="6" cy="5" r="2" fill="#FFD700" stroke="#fffbe6" stroke-width="0.8"/>
                <circle cx="16" cy="5" r="2" fill="#FFD700" stroke="#fffbe6" stroke-width="0.8"/>
                <circle cx="11" cy="12" r="1.2" fill="#fffbe6" stroke="#FFD700" stroke-width="0.6"/>
                <defs>
                  <linearGradient id="gold" x1="3" y1="5" x2="19" y2="13" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#FFD700"/>
                    <stop offset="1" stop-color="#fffbe6"/>
                  </linearGradient>
                </defs>
              </g>
            </svg>
          </span>
          <span v-else-if="idx === 1" class="rank-crown">
            <!-- 银色立体皇冠SVG-->
            <svg width="22" height="18" viewBox="0 0 22 18">
              <g>
                <ellipse cx="11" cy="15" rx="8" ry="2.5" fill="#b3e5fc" opacity="0.5"/>
                <path d="M3 13L6 5L11 12L16 5L19 13Z" fill="url(#silver)" stroke="#B3E5FC" stroke-width="1.5"/>
                <circle cx="6" cy="5" r="2" fill="#B3E5FC" stroke="#fff" stroke-width="0.8"/>
                <circle cx="16" cy="5" r="2" fill="#B3E5FC" stroke="#fff" stroke-width="0.8"/>
                <circle cx="11" cy="12" r="1.2" fill="#fff" stroke="#B3E5FC" stroke-width="0.6"/>
                <defs>
                  <linearGradient id="silver" x1="3" y1="5" x2="19" y2="13" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#B3E5FC"/>
                    <stop offset="1" stop-color="#fff"/>
                  </linearGradient>
                </defs>
              </g>
            </svg>
          </span>
          <span v-else-if="idx === 2" class="rank-crown">
            <!-- 铜色立体皇冠SVG-->
            <svg width="22" height="18" viewBox="0 0 22 18">
              <g>
                <ellipse cx="11" cy="15" rx="8" ry="2.5" fill="#ffb366" opacity="0.5"/>
                <path d="M3 13L6 5L11 12L16 5L19 13Z" fill="url(#bronze)" stroke="#FF8C00" stroke-width="1.5"/>
                <circle cx="6" cy="5" r="2" fill="#FF8C00" stroke="#fffbe6" stroke-width="0.8"/>
                <circle cx="16" cy="5" r="2" fill="#FF8C00" stroke="#fffbe6" stroke-width="0.8"/>
                <circle cx="11" cy="12" r="1.2" fill="#fffbe6" stroke="#FF8C00" stroke-width="0.6"/>
                <defs>
                  <linearGradient id="bronze" x1="3" y1="5" x2="19" y2="13" gradientUnits="userSpaceOnUse">
                    <stop stop-color="#FF8C00"/>
                    <stop offset="1" stop-color="#ffb366"/>
                  </linearGradient>
                </defs>
              </g>
            </svg>
          </span>
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
// 声明 props，类型可根据实际数据结构调整
// 支持外部传入业绩排行数据，优先用props，否则用mock
import { defineProps, computed } from 'vue'
const props = defineProps<{ data?: { name: string, value: number }[] }>()
const mockList = [
  { name: '段真真', value: 225000 },
  { name: '宇佳佳', value: 205000 },
  { name: '廖莎', value: 185000 },
  { name: '熊华', value: 175000 },
  { name: '王青', value: 165000 },
  { name: '吴官秀', value: 155000 },
  { name: '郭志超', value: 145000 },
  { name: '测试', value: 135000 },
  { name: '测试', value: 125000 },
  { name: '测试', value: 115000 }
]

const list = computed(() => props.data && props.data.length ? props.data : mockList)
</script>
<style scoped>
.main-card.ranking-card {
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
.rank-crown {
  display: inline-block;
  vertical-align: middle;
  margin-right: 2px;
}
.rank-index {
  min-width: 22px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: bold;
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
  margin-left: 2px;
}
.rank-value {
  color: #00eaff;
  font-size: 13px;
  text-shadow: 0 0 6px #00eaff;
}
</style>
