<template>
    <el-form label-width="100px">
        <el-form-item label="SKU名称">
            <el-input v-model="aaa" placeholder="SKU名称"></el-input>
        </el-form-item>
        <el-form-item label="价格">
            <el-input v-model="bbb" placeholder="价格(元)" type="number"></el-input>
        </el-form-item>
        <el-form-item label="重量(g)">
            <el-input placeholder="重量(g)" type="number"></el-input>
        </el-form-item>
        <el-form-item label="SKU描述">
            <el-input placeholder="" type="textarea"></el-input>
        </el-form-item>
        <el-form-item label="平台属性">
            <el-form :inline="true">
                <el-form-item label="内存">
                    <el-select  placeholder="请选择">
                        <el-option label="1111" value="1111"></el-option>
                        <el-option label="2111" value="2111"></el-option>
                        <el-option label="2111" value="3111"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="颜色">
                    <el-select>
                        <el-option label="1111" value="1111"></el-option>
                        <el-option label="2111" value="2111"></el-option>
                        <el-option label="2111" value="3111"></el-option>
                    </el-select>
                </el-form-item>
                <el-form-item label="规格">
                    <el-select>
                        <el-option label="1111" value="1111"></el-option>
                        <el-option label="2111" value="2111"></el-option>
                        <el-option label="2111" value="3111"></el-option>
                    </el-select>
                </el-form-item>
            </el-form>

        </el-form-item>
        <el-form-item label="销售属性">
            <el-select>
                <el-option label="销售属性" value="1"></el-option>
                <el-option label="销售属性" value="2"></el-option>
                <el-option label="销售属性" value="3"></el-option>
            </el-select>
        </el-form-item>
        <el-form-item label="图片列表">
            <el-table border>
                <el-table-column type="selection" width="80px">
                </el-table-column>
                <el-table-column label="图片">
                </el-table-column>
                <el-table-column label="名称">
                </el-table-column>
                <el-table-column label="操作" @click="cancel"></el-table-column>
            </el-table>
        </el-form-item>
        <el-form-item>
            <el-button type="primary">保存</el-button>
            <el-button type="primary">取消</el-button>
        </el-form-item>

    </el-form>

</template>

<script setup lang='ts'>
let $emit = defineEmits(['change-scene']);
import { ref } from 'vue';
//引入请求API
let aaa = ref('');
let bbb = ref(0);
//取消
const cancel = () => {
    $emit('change-scene', 0);
    console.log('取消');
}   

//暴漏当前子组件方法
const initSkuData = () => {
    console.log(`output->`,'初始化SKU数据')
};
defineExpose({
    initSkuData
    
})
</script>

<style></style>