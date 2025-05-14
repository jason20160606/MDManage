<template>
    <el-icon style="margin-right: 10px;" @click="changeIcon">
        <component :is="layUseSettingStore.fold ? 'Fold' : 'Expand'" />
    </el-icon>
    <!--左侧面包屑-->
    <el-breadcrumb separator-icon="ArrowRight">        
        <el-breadcrumb-item v-for="(item, index) in $route.matched" :key="index" v-show="item.meta.title" :to="item.path">
            <el-icon>
                <component :is="item.meta.icon" />
            </el-icon>
            <!--面包屑路由-->
            <span>{{ item.meta.title }}</span>
        </el-breadcrumb-item>   
    </el-breadcrumb>
</template>

<script setup lang='ts'>
import { useRoute } from 'vue-router';
//引入setting仓库
import useSettingStore from '@/store/modules/setting';
let layUseSettingStore = useSettingStore();
//获取当前路由
let $route = useRoute();
//点击折叠按钮
let changeIcon = () => {
    //图标切换
    layUseSettingStore.fold = !layUseSettingStore.fold;
}
</script>
<script lang="ts">
export default {
    name: 'Breadcrumb'
}
</script>

<style></style>