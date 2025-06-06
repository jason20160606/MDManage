<template>
    <div class="yearbox">
        <div class="title">
            <p>年度排行</p>
            <img src="../../images/dataScreen-title.png" alt="">
        </div>
        <div class="charts" ref="chartRef"></div>
    </div>

</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
let chartRef = ref(null);
onMounted(() => {
    let myChart = echarts.init(chartRef.value);
    myChart.setOption({
        title: {
            text: '散点图',
            textStyle: {
                color: '#fff',
                fontSize: 18,
            },
            left: 'center',
            top: '20px',
        },
        xAxis: {
            type: 'category',
            show: false, // 不显示x轴
            //data: ['2021', '2022', '2023', '2024'],
        },
        yAxis: {
            //type: 'value',
            show: false, // 不显示y轴
        },
        series: [
            {
                data: [100, 200, 300, 400,1232,122,444,667,333,7,442],
                type: 'scatter', // 散点图
                symbolSize: 10, // 散点大小
                lable: {
                    show: true, // 显示标签
                    color: '#fff', // 标签颜色
                }
            },
        ],
        
    })
})
</script>

<style scoped lang="scss">
    .yearbox {
        width: 100%;
        height: 100%;
        background: url('../../images/dataScreen-main-cb.png') no-repeat;
        background-size: 100% 100%;
        margin:20px 0px;

        .title {
            margin-left: 20px;
            p {
                font-size: 18px;
                color: #fff;
            }
        }
       .charts {
            width: 100%;
            height: 80%;
            margin-top: 10px;
       }
    }
</style>