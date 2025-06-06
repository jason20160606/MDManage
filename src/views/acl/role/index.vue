<template>
    <el-card>
        <el-form :inline="true" class="form" label-width="80px">
            <el-form-item label="角色名称">
                <el-input placeholder="请输入角色名称"></el-input>
            </el-form-item>
            <el-form-item>
                <el-button type="primary">查询</el-button>
                <el-button type="success">重置</el-button>
            </el-form-item>
        </el-form>
    </el-card>
    <el-card style="margin: 10px 0px;">
        <el-button  type="primary" @click="addrole">添加角色</el-button>
        <el-table border style="margin: 10px 0px;">
            <el-table-column type="index" label="#" width="80px">
            </el-table-column>
            <el-table-column label="ID">
            </el-table-column>
            <el-table-column label="角色名称">
            </el-table-column>            
            <el-table-column label="创建时间">
            </el-table-column>
            <el-table-column label="更新时间">
            </el-table-column>
            <el-table-column label="操作" width="260px">
            </el-table-column>
        </el-table>
    </el-card>
    <el-pagination v-model:current-page="currentPageNo" v-model:page-size="pageSizeNo"
            :page-sizes="[100, 200, 300, 400]" :size="size" :disabled="disabled" :background="background"
            layout="prev, pager, next, jumper,->, sizes,total" :total="400" @current-change="getSPU" />
<!--添加角色-->
<el-dialog title="添加角色" v-model="drawer" width="30%">
    <el-form>
        <el-form-item label="角色名称">
            <el-input placeholder="请输入角色名称"></el-input>
        </el-form-item>
        
    </el-form>
    <template #footer>  
            <div>
                <el-button @click="drawer=false">取消</el-button>
                <el-button type="primary">确定</el-button>    
            </div>  
        </template>
</el-dialog>
</template>

<script setup lang='ts'>
import { ref } from 'vue';
let currentPageNo = ref(1); //当前页码
let pageSizeNo = ref(100); //每页显示多少条数据
let size = ref('medium'); //分页器尺寸
let disabled = ref(false); //分页器是否禁用
let background = ref(true); //分页器是否有背景色
let drawer = ref(true); //控制添加角色的抽屉显示隐藏
//添加角色
const addrole = () => {
    drawer.value = true;
}
</script>

<style>
.form {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
</style>