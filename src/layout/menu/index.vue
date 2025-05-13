<template>
    <template v-for="(item) in menuList" :key="item.path">
        <!--没有子路由-->
        <template v-if="!item.children">
            <el-menu-item v-if="!item.meta.hidden" :index="item.path" @click="goRoute">
                <el-icon>
                        <component :is="item.meta.icon" />
                    </el-icon>
                <template #title>                    
                    <span>{{ item.meta.title }}</span>
                </template>
            </el-menu-item>
        </template>
        <!--有子路由只有一个-->
        <template v-if="item.children && item.children.length == 1">
            <el-menu-item v-if="!item.meta.hidden" :index="item.path" @click="goRoute">
                <el-icon>
                        <component :is="item.children[0].meta.icon" />
                    </el-icon>
                <template #title>                    
                    <span>{{ item.children[0].meta.title }}</span>
                </template>
            </el-menu-item>
        </template>
        <!--有子路由-->
        <template v-if="item.children && item.children.length > 1">
            <el-sub-menu v-if="!item.meta.hidden" :index="item.path">
                <template #title>
                    <el-icon>
                        <component :is="item.meta.icon" />
                    </el-icon>
                    <span>{{ item.meta.title }}</span>
                </template>
                <Menu :menuList="item.children" />
            </el-sub-menu>
        </template>
    </template>
</template>

<script setup lang='ts'>
import { useRouter } from 'vue-router';
//获取路由对象
let $router = useRouter();
//点击菜单跳转到指定路由
const goRoute = (vc:any) => {
    //路由跳转
    $router.push(vc.index);
};
//获取父组件传递的全部路由数组
defineProps(['menuList'])
</script>
<script lang="ts">
export default {
    name: 'Menu'
}
</script>

<style></style>