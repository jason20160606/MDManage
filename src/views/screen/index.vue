<template>
    <div class="container">
        <!--数据大屏展示内容区域-->
        <div class="screen" ref="screenRef">
            <Top />
            <div class="bottom">
                <div class="left">
                    <Tourist class="tourist" />
                    <Sex class="sex" />
                    <Age class="age" />
                </div>
                <div class="center">
                    <Map class="cmap"></Map>
                    <Line class="cline"></Line>
                </div>
                <div class="right">
                    <Rank class="rank"></Rank>
                    <Year class="year"></Year>
                    <Couter class="couter"></Couter>
                </div>
            </div>
        </div>

    </div>
</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
import Top from './components/top/index.vue'; //引入顶部组件
//引入左侧三个组件
import Age from './components/age/index.vue'; //引入年龄组件
import Sex from './components/sex/index.vue'; //引入性别组件
import Tourist from './components/tourist/index.vue'; //引入统计组件
import Map from './components/map/index.vue'; //引入性别组件
import Line from './components/line/index.vue'; //引入统计组件
import Rank from './components/rank/index.vue'; //引入统计组件
import Year from './components/year/index.vue'; //引入性别组件
import Couter from './components/couter/index.vue'; //引入统计组件
//获取数据大屏的DOM元素
let screenRef = ref();
onMounted(() => {
    //获取数据大屏的DOM元素
    screenRef.value.style.transform = `scale(${getScale()}) translate(-50%,-50%)`;
})
//定义大屏缩放比例
function getScale(w = 1920, h = 1080) {
    //获取浏览器的宽高缩放比例
    let scaleX = window.innerWidth / w;
    let scaleY = window.innerHeight / h;
    //获取最小的缩放比例
    let scale = Math.min(scaleX, scaleY);
    return scale;
};
</script>

<style scoped lang="scss">
.container {
    width: 100vw;
    height: 100vh;
    background: url('./images/bg.png') no-repeat center;
    background-size: cover;

    .screen {
        width: 1920px;
        height: 1080px;
        left: 50%;
        top: 50%;
        position: fixed;
        transform-origin: left top;

        .top {
            width: 100%;
            height: 40px;
            //background-color: aqua;
        }

        .bottom {
            display: flex;
            // width: 100%;
            //height: calc(100% - 100px);

            //background-color: rgb(170, 119, 119);
            //font-size: 20px;

            .left {

                flex: 1;
                height: 1040px;
                display: flex;
                flex-direction: column;

                .tourist {
                    flex: 1.2;
                }

                .age {
                    flex: 1;
                    //background-color: royalblue;
                }

                .sex {
                    flex: 1;
                    //background-color: salmon;
                }
            }

            .center {
                flex: 2;
                display: flex;
                flex-direction: column;
                //background-color: aqua;

                .cmap {
                    flex: 4;
                    //background-color:red;
                }

                .cline {
                    flex: 1;
                    //background-color: rgb(170, 119, 119);
                }
            }

            .right {
                flex: 1;
                display: flex;
                flex-direction: column;

                .rank {
                    flex: 1.5;                   
                }

                .year {
                    flex: 1;                    
                }

                .couter {
                    flex: 1;                    
                }

            }
        }

    }
}
</style>