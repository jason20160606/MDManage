<template>
        <div class="box_age">
                <div class="title">
                        <p>年龄比例</p>
                        <img src="../../images/dataScreen-title.png" alt="">
                </div>
                <div class="charts" ref="chartsRef"></div>
        </div>
</template>

<script setup lang='ts'>
import * as echarts from 'echarts';
import { ref, onMounted } from 'vue';

let chartsRef = ref();
onMounted(() => {
        let myChart = echarts.init(chartsRef.value);
        let option = {
                tooltip: {
                        trigger: 'item'
                },
                legend: {
                        top: 40,
                        right: 20,
                        orient: 'vertical',       //组件方向
                        textStyle: {            //图例文字样式
                                color: 'white',
                                fontSize: 14,
                        }
                },
                series: [
                        {
                                name: 'Access From',
                                type: 'pie',
                                radius: ['40%', '70%'],
                                avoidLabelOverlap: false,
                                itemStyle: {
                                        borderRadius: 10,
                                        borderColor: '#fff',
                                        borderWidth: 2
                                },
                                label: {
                                        show: true,
                                        position: 'inside',
                                        color: 'white'
                                },
                                emphasis: {
                                        label: {
                                                show: true,
                                                //fontSize: 40,
                                                fontWeight: 'bold'
                                        }
                                },
                                labelLine: {
                                        show: false
                                },
                                data: [
                                        { value: 1048, name: '军事' },
                                        { value: 735, name: '新闻' },
                                        { value: 580, name: '娱乐' },
                                        { value: 484, name: '游戏' },
                                        { value: 300, name: '财经' }
                                ]
                        }
                ]
        };
        myChart.setOption(option);
})
</script>

<style scoped lang="scss">
.box_age {
        width: 100%;
        height: 100%;
        background: url('../../images/dataScreen-main-cb.png') no-repeat;
        background-size: 100% 100%;

        .title {
                margin-left: 20px;

                p {
                        font-size: 20px;
                        color: white;
                }
        }

        .charts {                
                height: 260px;               
        }
}
</style>