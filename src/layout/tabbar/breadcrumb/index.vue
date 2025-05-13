<template>
    <el-icon style="margin-right: 10px;" @click="changeIcon">
        <component :is="layUseSettingStore.fold ? 'Fold' : 'Expand' " />        
    </el-icon>
    <!--左侧面包屑-->
    <el-breadcrumb separator-icon="ArrowRight" >
        <el-breadcrumb-item>权限管理</el-breadcrumb-item>
        <el-breadcrumb-item>用户管理</el-breadcrumb-item>
    </el-breadcrumb>
</template>

<script setup lang='ts'>
//引入setting仓库
import useSettingStore from '@/store/modules/setting';
let layUseSettingStore = useSettingStore();
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