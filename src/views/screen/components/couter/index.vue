<template>
    <div class="couterbox">
        <div class="title">
            <p>渠道对比</p>
            <img src="../../images/dataScreen-title.png" alt="">
        </div>
        <div class="charts" ref="chartRef"></div>
    </div>

</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
let chartRef = ref();
onMounted(() => {
    let myChart = echarts.init(chartRef.value);
    myChart.setOption({
        title: {
            text: 'BChart'
        },
        legend: {
            data: ['Allocated Budget', 'Actual Spending']
        },
        radar: {
            // shape: 'circle',
            indicator: [
                { name: 'Sales', max: 6500 },
                { name: 'Administration', max: 16000 },
                { name: 'Information Technology', max: 30000 },
                { name: 'Customer Support', max: 38000 },
                { name: 'Development', max: 52000 },
                { name: 'Marketing', max: 25000 }
            ]
        },
        series: [
            {
                name: 'Budget vs spending',
                type: 'radar',
                data: [
                    {
                        value: [4200, 3000, 20000, 35000, 50000, 18000],
                        name: 'Allocated Budget'
                    },
                    {
                        value: [5000, 14000, 28000, 26000, 42000, 21000],
                        name: 'Actual Spending'
                    }
                ]
            }
        ]
    })
})
</script>

<style scoped lang="scss">
.couterbox {
    width: 100%;
    height: 100%;
    background: url('../../images/dataScreen-main-cb.png') no-repeat;
    background-size: 100% 100%;

    .title {
        margin-left: 10px;

        p {
            font-size: 18px;
            color: #fff;
        }
    }

    .charts {
        width: 100%;
        height: calc(100% - 30px);
        margin-top: 10px;
    }
}
</style>