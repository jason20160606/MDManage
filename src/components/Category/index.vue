<template>
    <el-card class="box-card">
        <el-form :inline="true">
            <el-form-item label="一级分类" prop="name">
                <el-select :disabled="scene==1" v-model="categoryStore.c1Id" style="width: 100px;" @change="handler">  
                    <el-option v-for="c1 in categoryStore.c1Arr" :key="c1.id" :label="c1.name" :value="c1.id"></el-option>                 
                </el-select>
            </el-form-item>
            <el-form-item label="二级分类" prop="name">
                <el-select :disabled="scene==1" v-model="categoryStore.c2Id" placeholder="请选择" style="width: 120px"  @change="handler1">
                    <el-option v-for="c2 in categoryStore.c2Arr" :key="c2.id" :label="c2.name" :value="c2.id"></el-option>     
                </el-select>
            </el-form-item>
            <el-form-item label="三级分类" prop="name">
                <el-select :disabled="scene==1" v-model="categoryStore.c3Id" placeholder="请选择" style="width: 120px">
                <el-option v-for="c3 in categoryStore.c3Arr" :key="c3.id" :label="c3.name" :value="c3.id"></el-option>
                </el-select>
            </el-form-item>
        </el-form>
    </el-card>
</template>

<script setup lang='ts'>
//引入组件挂载完毕的方法
import { onMounted } from 'vue'
//引入三级分类仓库
import useCategoryStore from '@/store/modules/category'
//获取三级分类仓库
let categoryStore = useCategoryStore();
//组件挂载完毕获取一级分类数据
onMounted(() => {
    categoryStore.getC1Arr();
})
//一级分类选择事件
const handler = () => { 
    categoryStore.c2Id = '';
    categoryStore.c3Id = '';
    categoryStore.c2Arr = [];
    categoryStore.c3Arr = [];
    categoryStore.getC2Arr();
}
//二级分类选择事件
const handler1 = () => {
    categoryStore.c3Id = '';
    categoryStore.c3Arr = [];
    categoryStore.getC3Arr();
}
//接受父组件传过来的值
defineProps([`scene`])

</script>

<style></style>