<template>
    <div class="map" ref="chartRef">
        我是地图组件
    </div>

</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
import * as echarts from 'echarts';
import chinaJson from './china.json'
//获取DOM元素
let chartRef = ref();
//注册地图
echarts.registerMap('china', chinaJson as any);
//初始化
onMounted(() => {
    //创建图表
    let myChart = echarts.init(chartRef.value);
    //设置配置项
    myChart.setOption({
        //地图组件
        geo: {
            map: 'china',
            roam: true, //鼠标缩放
            label: {
                show: true, //显示省份
                color: '#fff', //省份颜色
                fontSize: 12, //省份字体大小
            },
            itemStyle: { //省份
                color: '#0080ff', //省份颜色
                borderColor: '#fff', //边框颜色
                borderWidth: 0.5, //边框宽度
                opacity: 0.8, //透明度
            },
            //地图高亮效果
            emphasis: {
                itemStyle: {
                    color: '#ff0000', //省份颜色
                },
                label: {
                    fontSize: 30, //省份字体大小
                }
            }
        },
        grid: { //网格
            top: 0, //距离顶部
            left: 0, //距离左边
            right: 0, //距离右边
            bottom: 0, //距离底部
        },
        //航线
        series: [
            {
                type: 'lines', //航线
                zlevel: 1, //层级
                effect: { //特效
                    show: true, //显示
                    symbol: 'arrow', //箭头
                    period: 6, //周期
                    trailLength: 0.7, //尾迹长度
                    color: '#fff', //颜色
                    symbolSize: 10, //符号大小
                },
                data: [{
                    coords: [
                        [113.280637, 23.125178],
                        [87.617733, 43.792818]
                    ],
                    lineStyle: { //航线样式
                        normal: { //正常
                            color: '#fff', //颜色
                            width: 0, //宽度
                            curveness: 0.2, //曲度
                        }
                    }
                },{
                    coords: [
                        [113.280637, 23.125178],
                        [111.670801, 40.818311]
                    ],
                    lineStyle: { //航线样式
                        normal: { //正常
                            color: '#fff', //颜色
                            width: 0, //宽度
                            curveness: 0.2, //曲度
                        }
                    }
                }
                ]

            }
        ]
    })
})

</script>

<style></style>