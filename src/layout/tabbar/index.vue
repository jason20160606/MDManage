<template>
    <div class="tabbar">
        <div class="tabbar-left">
            <Breadcrumb></Breadcrumb>

        </div>
        <div class="tabbar-right">
            <Setting></Setting>            
        </div>
    </div>
</template>

<script setup lang='ts'>
import Breadcrumb from "@/layout/tabbar/breadcrumb/index.vue";
import Setting from "@/layout/tabbar/setting/index.vue";
</script>
<script lang="ts">
export default {
    name: 'Tabbar'
}
</script>
<style scoped lang="scss">
.tabbar {
    width: 100%;
    height: 100%;
    display: flex;
    justify-content: space-between;
    background-image: linear-gradient(to right, rgb(204, 183, 183), rgb(216, 149, 149), white);

    .tabbar-left {
        font-size: 14px;
        margin-left: 20px;
        height: 100%;
        display: flex;
        align-items: center;
    }

    .tabbar-right {
        margin-right: 20px;
        height: 100%;
        display: flex;
        align-items: center;
    }

}
</style>