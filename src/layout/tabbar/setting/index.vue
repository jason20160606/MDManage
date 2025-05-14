<template>
    <el-button size="small" icon="Refresh" circle @click="updateRefsh"></el-button>
    <el-button size="small" icon="FullScreen" circle @click="fullScreen"></el-button>
    <el-button size="small" icon="Setting" circle="true"></el-button>
    <img :src="layUseUserStore.avatar" alt="" style="height: 24px;width: 24px;margin: 0 10px; border-radius: 10px;">
    <!--下拉菜单-->
    <el-dropdown>
        <span class="el-dropdown-link">
            {{ layUseUserStore.name }}
            <el-icon class="el-icon--right">
                <arrow-down />
            </el-icon>
        </span>
        <template #dropdown>
            <el-dropdown-menu>
                <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
        </template>
    </el-dropdown>
</template>

<script setup lang='ts'>
//获取仓库
import useSettingStore from '@/store/modules/setting';
//获取用户相关仓库
import useUserStore from '@/store/modules/user';
//引入路由器
import { useRouter, useRoute } from 'vue-router';
let $router = useRouter();
//获取当前路由
let $route = useRoute();
let layUseUserStore = useUserStore();
//退出登录
let logout = () => {
    //1.告诉服务器清除token，退出登录接口
    //2.清除本地token
    //3.跳转到登录页面
    layUseUserStore.userLogout();
    $router.push({ path: '/login', query: { redirect: $route.path } });
}
//获取设定相关仓库
let layUseSettingStore = useSettingStore();
//刷新
let updateRefsh = () => {
    layUseSettingStore.refresh = !layUseSettingStore.refresh;
}
//全屏
let fullScreen = () => {
    //判断是否全屏
    let full = document.fullscreenElement;
    //全屏模式切换
    if (!full) {
        document.documentElement.requestFullscreen();
    } else {
        document.exitFullscreen();
    }
}
</script>
<script lang="ts">
export default {
    name: 'Setting'
}
</script>

<style></style>