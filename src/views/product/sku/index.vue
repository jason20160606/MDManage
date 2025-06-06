<template>
    <div>
        <Category :scene="scene"></Category>
    </div>
    <el-card>
        <el-table border style="margin: 10px;">
            <el-table-column prop="id" type="index" label="ID" width="100px" align="center"></el-table-column>
            <el-table-column prop="name" label="名称" show-overflow-tooltip width="150px"></el-table-column>
            <el-table-column prop="price" label="价格" show-overflow-tooltip width="150px"></el-table-column>
            <el-table-column prop="description" label="图片" width="200px"></el-table-column>
            <el-table-column prop="createTime" label="重量" width="200px"></el-table-column>
            <el-table-column prop="updateTime" label="价格" width="200px"></el-table-column>
            <el-table-column prop="updateTime" label="操作" width="150px" fixed="right"></el-table-column>
        </el-table>
        <el-pagination v-model:current-page="currentPageNo" v-model:page-size="pageSizeNo"
            :page-sizes="[100, 200, 300, 400]" :size="size" :disabled="disabled" :background="background"
            layout="prev, pager, next, jumper,->, sizes,total" :total="400" @current-change="getSPU" />
        <!--抽屉组件-->
        <el-drawer v-model="drawer" title="查看商品详情">
            <template #header>
                <h4>商品详情</h4>
            </template>
            <template #default>
                <el-row>
                    <el-col :span="8">1</el-col>
                    <el-col :span="16">2</el-col>
                </el-row>
                <el-row>
                    <el-col :span="8">1</el-col>
                    <el-col :span="16">2</el-col>
                </el-row>
                <el-row>
                    <el-col :span="8">1</el-col>
                    <el-col :span="16">
                        <el-carousel :interval="4000" type="card" height="150px">
                            <el-carousel-item v-for="item in 4" :key="item">
                                <h3  justify="center" text="2xl">{{ item }}</h3>
                            </el-carousel-item>
                        </el-carousel>
                    </el-col>
                </el-row>
            </template>

        </el-drawer>
    </el-card>
</template>

<script setup lang='ts'>
import { ref } from 'vue';
let scene = ref<number>(0); //接受父组件传过来的值
let currentPageNo = ref(1); //当前页码
let pageSizeNo = ref(100); //每页显示多少条数据
let size = ref('medium'); //分页器尺寸
let disabled = ref(false); //分页器是否禁用
let background = ref(true); //分页器是否有背景色
//控制显示隐藏抽屉
let drawer = ref(true);
const getSPU = () => {
    // 这里可以调用API获取SPU数据
    console.log('获取SPU数据', currentPageNo.value, pageSizeNo.value);
};
</script>

<style scoped>
.demonstration {
    color: var(--el-text-color-secondary);
}

.el-carousel__item h3 {
    color: #475669;
    opacity: 0.75;
    line-height: 150px;
    margin: 0;
    text-align: center;
}

.el-carousel__item:nth-child(2n) {
    background-color: #99a9bf;
}

.el-carousel__item:nth-child(2n + 1) {
    background-color: #d3dce6;
}
</style>