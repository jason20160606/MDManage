<template>
    <div class="logo" v-if="setting.logoHidden">
        <img :src="setting.logo" alt="MIDO">
        <p>{{ setting.title }}</p>
    </div>
</template>

<script setup lang='ts'>
//引入设置标题与logop配置文件
import setting from '@/setting';
</script>
<script lang="ts">
export default {
    name: 'Logo'
}
</script>
<style scoped lang="scss">
.logo {
    width: 100%;
    height: $menu-logo-height;
    color: white;
    align-items: center;
    display: flex;
    padding: 20px;

    img {
        padding: 5px;
        width: 30px;
        height: 30px;
    }

    p {
        margin: 10px;
        font-size: $menu-logo-font-size;
    }

}
</style>