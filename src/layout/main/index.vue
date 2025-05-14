<template>
    <!--路由组件出口位置-->
    <router-view v-slot="{ Component }">
        <transition name="fade">
            <!--渲染layout以及路由组件的子路由-->
            <component :is="Component" v-if="flag" />
        </transition>
    </router-view>
</template>

<script setup lang='ts'>
import { watch, ref, nextTick } from 'vue';
//获取设定仓库
import useSettingStore from '@/store/modules/setting';
let flag = ref(true);
let layUseSettingStore = useSettingStore();
//监听仓库内部数据是否发生变化
watch(() => layUseSettingStore.refresh, () => {
    //点击刷新：路由组件重新渲染
    flag.value = false;
    nextTick(() => {
        flag.value = true;
    })

})
</script>
<script lang="ts">
export default {
    name: 'Main'
}
</script>

<style scoped>
.fade-enter-from {
    opacity: 0;
    transform: scale(0);
}

.fade-enter-active {
    transition: all 0.5s;
}

.fade-enter-to {
    opacity: 1;
    transform: scale(1);
}
</style>