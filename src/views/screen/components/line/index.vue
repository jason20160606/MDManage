<template>
    <div class="lineBox">
        <div class="title">
            <p>趋势图</p>
            <img src="../../images/dataScreen-title.png" alt="">
        </div>
        <div class="charts" ref=chartRef></div>
    </div>

</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
//获取DOM元素
let chartRef = ref();
//初始化
onMounted(() => {
    //创建图表
    let myChart = echarts.init(chartRef.value);
    //设置配置项
    myChart.setOption({
        title: { //标题
            text: '趋势图', //标题文本
            left: 'left', //标题位置
            textStyle: { //标题样式
                color: 'red', //标题颜色
                fontSize: 18, //标题字体大小
            }
        },
        //XY轴
        xAxis: { //X轴
            type: 'category', //X轴类型
            data: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'], //X轴数据
            splitLine: { //X轴分割线
                show: false, //不显示
            }
        },
        yAxis: { //Y轴
            type: 'value', //Y轴类型
            splitLine: { //X轴分割线
                show: false, //不显示
            }
        },
        grid: { //网格
            top: 20, //距离顶部
            left: 50, //距离左边
            right: 0, //距离右边
            bottom: 20, //距离底部
        },
        //系列 显示什么样的图形图表
        series: [
            {
                data: [150, 10, 224, 18, 135, 14, 260], //数据
                type: 'line', //折线图
                smooth: true, //平滑
                areaStyle: { //区域填充
                    color: 'rgba(255, 0, 0, 0.3)', //填充颜色
                }
            }
        ]
    })
})

</script>

<style scoped lang="scss">
.lineBox {
    //width: 100%;
    height: 100%;
    background: url('../../images/dataScreen-main-cb.png') no-repeat center;
    background-size: 100% 100%;
    margin: 20px;
    .title {
        margin-left: 20xp;
        p{
            font-size: 20px;
            color: #fff;
        };
    }
    .charts {
        width: 100%;
        height: calc(100% - 40px);
        //background-color: aqua;
    }
}
</style>