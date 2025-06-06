<template>
    <el-button size="small" icon="Refresh" circle @click="updateRefsh"></el-button>
    <el-button size="small" icon="FullScreen" circle @click="fullScreen"></el-button>
    <el-popover placement="bottom" title="主题设置" :width="200" trigger="hover">
        <el-form>
                <el-form-item label="主题颜色">
                    <el-color-picker size="small"  v-model="color" :teleported="false" show-alpha :predefine="predefineColors" @change="setColor" />
                </el-form-item>
                <el-form-item label="暗黑模式">
                    <el-switch size="small" @click="changeDark" v-model="dark" inline-prompt active-icon="MoonNight" inactive-icon="Sunny"/>
                </el-form-item>
            </el-form>
            
        <template #reference>
            <el-button size="small"  icon="Setting" circle></el-button>
        </template>
    </el-popover>

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
import { ref } from 'vue'
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
let dark = ref(false);
//获取设定相关仓库
let layUseSettingStore = useSettingStore();
//退出登录
let logout = () => {
    //1.告诉服务器清除token，退出登录接口
    //2.清除本地token
    //3.跳转到登录页面
    layUseUserStore.userLogout();
    $router.push({ path: '/login', query: { redirect: $route.path } });
}

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
const color = ref('rgba(255, 69, 0, 0.68)')
const predefineColors = ref([
  '#ff4500',
  '#ff8c00',
  '#ffd700',
  '#90ee90',
  '#00ced1',
  '#1e90ff',
  '#c71585',
  'rgba(255, 69, 0, 0.68)',
  'rgb(255, 120, 0)',
  'hsv(51, 100, 98)',
  'hsva(120, 40, 94, 0.5)',
  'hsl(181, 100%, 37%)',
  'hsla(209, 100%, 56%, 0.73)',
  '#c7158577',
])
//switch事件
const changeDark=()=>{
    let html=document.documentElement;
    if(dark.value){
        html.classList.add('dark');        
    }else{
        html.classList.remove('dark');
    }
}
//设置主题颜色
const setColor=(color:string)=>{
    let html=document.documentElement;
    html.style.setProperty('--el-color-primary',color);    
}
</script>
<script lang="ts">
export default {
    name: 'Setting'
}
</script>

<style></style>