<template>
    <div class="rankbox">
        <div class="title">
            <p>排行榜</p>
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
        //标题组件
        title: {
            text: '排行总榜',//标题文本
            left: 'left',//标题水平位置
            top: 'top',//标题垂直位置
            textStyle: {
                color: '#fff',//标题文字颜色
                fontSize: 18,//标题文字大小
            }
        },
        //X|Y轴
        xAxis: {
            type: 'category',//类目轴
            data: ['军事', '新闻', '娱乐', '游戏', '财经'],//类目数据
        },
        yAxis: {
            type: 'value',//数值轴
        },
        //系列 显示什么样的图形图表
        series: [
            {
                type: 'bar',//柱状图
                data: [10, 90, 80, 70, 60],//数据
                barWidth: '30%',//柱状图宽度
                lable: {
                    show: true,//是否显示标签
                    position: 'insideTop',//标签位置
                    color: 'yellow',//标签文字颜色
                    fontSize: 20,//标签文字大小
                },
                //背景颜色
                showBackground: true,
                backgroundStyle: {
                    color: 'rgba(255, 255, 255, 0.1)',//背景颜色                    
                },
                itemStyle: {
                    borderRadius: [10, 10, 0, 0]//圆角
                }

            }
        ],
        //布局组件
        grid:{
            left:20,
            right:0,
            top:30,
            bottom:20,
        }
    })
})



</script>

<style scoped lang="scss">
.rankbox {
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