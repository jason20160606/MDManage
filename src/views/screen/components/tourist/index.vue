<template>
        <div class="box">
            <div class="top">
                <p class="title">时时游客统计</p>
                <p class="bg"> </p>                    
                    <p class="rightp">可预约总量<span>99999999</span>人</p>                
            </div>
            <div class="number">
                <span v-for="(item,index) in people" :key="index" >{{ item }}</span>
            </div>
             <!--放置图表-->
             <div class="charts" ref="chartsRef">12222222222</div>
        </div>
       
</template>
    
<script setup lang='ts'>
    import { ref ,onMounted} from 'vue';
    import * as echarts from 'echarts';
    let people = ref('521545人');
    //获取节点
    let chartsRef = ref();
    onMounted(() => {
        //创建图表
        let myChart = echarts.init(chartsRef.value);
        //设置图表数据
        myChart.setOption(
            {
                title: {
                    text: '水球图'
                },
                //X轴Y轴
                xAxis: {},
                yAxis: {},                 
                //系列 显示什么样的图形图表
                series: [
                    {
                        type: 'line',//水球图
                        data: [0.6, 0.6, 0.0, 0.0],//数据
                        //shape: 'circle',//图形
                    }
                ],
                //布局组件
                grid:{
                    left:0,
                    right:0,
                    top:0,
                    bottom:0,   
                }
            }
        );
    })
</script>
    
<style scoped lang="scss">
.box {
    background:url(../../images/dataScreen-main-lb.png) no-repeat center;
    background-size: 100% 100%;
    margin-top: 10px;
    .top {
        margin-left: 20px;
        .title {
           font-size: 18px;
           color: #fff;
           
       }
       .bg {
           width: 68px;
           height: 7px;
           background: url(../../images/dataScreen-title.png) no-repeat center;
           background-size: 100% 100%;
           margin-top: 10px;
       }
       .rightp {
           float: right;
           color: white;
           font-size: 20px;
           span{
               color: #ffd800;

           }
       }
    }
    .number {
        margin-top: 30px;
        display: flex;
        padding: 10px 10px;
        span{
            flex: 1;
            color: #29fcff;
            height: 40px;
            text-align: center;
            line-height: 40px;
            background: url(../../images/total.png) no-repeat center;
            background-size: 100% 100%;
        }
    }
    .charts {
       width: 100%;
       height: 250px;
       background-color: #6b1f1f;       
   }
}
    
</style>