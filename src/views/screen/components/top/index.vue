<template>
    <div class="top">
        <div class="left">
            <span class="lbtn" @click="goHome">首页</span>
        </div>

        <div class="center">
            <div class="title">
                <span>可视化数据大屏</span>
            </div>
        </div>
        <div class="right">
            <span class="rbtn">统计报告</span>
            <span class="time">{{ getTime }}</span>
        </div>
    </div>
</template>

<script setup lang='ts'>
import { useRouter } from 'vue-router';
import { onMounted,onBeforeUnmount, ref } from 'vue';
import moment from 'moment';
let $router = useRouter();
//存储当前时间
let getTime = ref(moment().format('YYYY-MM-DD HH:mm:ss'));
let timer = ref(0);
//返回首页
let goHome = () => {
    $router.push({ path: '/home' });
}
onMounted(() => {
    setInterval(() => {
        getTime.value = moment().format('YYYY-MM-DD HH:mm:ss');
    }, 1000);
})
onBeforeUnmount(() => {
    clearInterval(timer.value);
})

</script>

<style scoped lang="scss">
.top {
    width: 100%;
    height: 40px;
    display: flex;

    .left {
        flex: 1.5;
        background: url('../../images/dataScreen-header-left-bg.png') no-repeat center;
        background-size: cover;

        .lbtn {
            width: 150px;
            height: 40px;
            float: right;
            background: url('../../images/dataScreen-header-btn-bg-l.png') no-repeat center;
            background-size: 100% 100%;
            text-align: center;
            line-height: 40px;
            color: #29fcff;
            font-size: 20px;
        }
    }

    .center {
        flex: 2;

        .title {
            width: 100%;
            height: 74px;
            background: url('../../images/dataScreen-header-center-bg.png') no-repeat center;
            background-size: 100% 100%;
            text-align: center;
            line-height: 74px;
            color: #29fcff;
            font-size: 30px;
        }
    }

    .right {
        flex: 1.5;
        background: url('../../images/dataScreen-header-left-bg.png') no-repeat center;
        background-size: cover;
        display: flex;
        justify-content: space-between;
        align-items: center;

        .rbtn {
            width: 150px;
            height: 40px;
            background: url('../../images/dataScreen-header-btn-bg-r.png') no-repeat center;
            background-size: 100% 100%;
            float: left;
            text-align: center;
            line-height: 40px;
            color: #29fcff;
            font-size: 20px;
        }

        .time {
            
            height: 40px;
            text-align: center;
            line-height: 40px;
            color: #29fcff;
            font-size: 20px;
        }
    }
}
</style>