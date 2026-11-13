<template>
    <div class="home-container">
        <el-card class="welcome-card">
            <div class="box">
                <img :src="getAvatarUrl(useStore.avatar)" @error="onAvatarError" alt="用户头像" class="avatar">

                <div>
                    <h3 class="title">{{ getTime() }}好{{ useStore.nickname }}</h3>
                </div>
            </div>
        </el-card>

        <!-- 发货统计卡片 + 发货趋势 + 物流公司分布（由发货记录页迁入） -->
        <h3 class="section-title"><span class="section-title-bar"></span>发货数据概览</h3>
        <ShippingStatistics />

        <div class="welcome-illustration">
            <SvgIcon name="wel" width="600px" height="300px"></SvgIcon>
        </div>
    </div>
</template>

<script setup lang='ts'>
//引入仓库对象
import useUserStore from '@/store/modules/user';
import { getTime } from '@/utils/time';
import { getAvatarUrl, onAvatarError } from '@/utils/image';
import ShippingStatistics from './components/ShippingStatistics.vue';
let useStore = useUserStore();

</script>

<style lang="scss" scoped>
.home-container {
    padding: 20px;
}

.welcome-card {
    margin-bottom: 20px;
}

.section-title {
    display: flex;
    align-items: center;
    margin: 0 0 16px;
    font-size: 16px;
    font-weight: 600;
    color: #303133;
}

.section-title-bar {
    display: inline-block;
    width: 4px;
    height: 16px;
    margin-right: 8px;
    border-radius: 2px;
    background-color: #409eff;
}

.box {
    display: flex;
    z-index: 1;
    /* 保证首页内容层级较低，不会遮挡弹窗 */
    .avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background-color: #e8edf4;

    }

    .title {
        margin-left: 20px;
        line-height: 100px;
        font-size: 20px;
        color: #333;
    }
}

.welcome-illustration {
    display: flex;
    justify-content: center;
    margin-top: 10px;
    overflow: hidden;
}
</style>
