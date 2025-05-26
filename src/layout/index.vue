<template>
    <div class="layout">
        <!--左侧菜单 -->
        <div class="layout-aside" >
            <Logo />

            <!--滚动组件-->
            <el-scrollbar class="scrollbar">
                <!-- 菜单组件 -->
                <el-menu :collapse="useStore.fold" :default-active="$route.path" background-color="#001529" text-color="white">
                    <!--动态菜单 -->
                    <Menu :menuList="userStore.menuRoutes" />
                </el-menu>

            </el-scrollbar>
        </div>
        <!--顶部菜单 -->
        <div class="layout-header" :class="{ fold: useStore.fold }">
            <!--顶部tabbar组件-->
            <Tabbar></Tabbar>
        </div>
        <!--内容展示 -->
        <div class="layout-content" :class="{ fold: useStore.fold }">
            <Main />
        </div>
    </div>
</template>

<script setup lang='ts'>
//获取路由对象
import { useRoute } from 'vue-router';
//引入左侧子组件
import Logo from '@/layout/logo/index.vue';
//引入菜单组件
import Menu from '@/layout/menu/index.vue';
//引入内容组件
import Main from '@/layout/main/index.vue';
//获取小仓库数据
import useUserStore from '@/store/modules/user';
//引入顶部tabbar组件
import Tabbar from '@/layout/tabbar/index.vue';
//引入用户组件设定仓库
import useSettingStore from '@/store/modules/setting';
let useStore = useSettingStore();
let userStore = useUserStore();
let $route = useRoute();

</script>
<script lang="ts">
export default {
    name: 'Layout'
}
</script>
<style scoped lang='scss'>
.layout {
    background: white;
    width: 100%;
    height: 100vh;


    .layout-aside {
        background: $menu-background;
        width: $menu-left-width;
        height: 100vh;
        color: white;
        transition: all 0.3s;

        .scrollbar {
            width: 100%;
            height: calc(100vh - $menu-logo-height);

            .el-menu {
                border-right: none;
            }
        }
    }

    .layout-header {
        position: fixed;
        width: calc(100% - $menu-left-width);
        height: $menu-top-height;
        top: 0px;
        left: $menu-left-width;
        transition: all 0.3s;
        &.fold {
            width:calc(100vw - $menu-left-min-width);
            left: $menu-left-min-width;
        }
    }

    .layout-content {
        position: absolute;        
        width: calc(100% - $menu-left-width);
        height: calc(100vh - $menu-top-height);
        left: $menu-left-width;
        top: $menu-top-height;
        padding: 20px;
        overflow: auto;
        transition: all 0.3s;
        &.fold {
            width:calc(100vw - $menu-left-min-width);
            left: $menu-left-min-width;
        }
    }
}
</style>