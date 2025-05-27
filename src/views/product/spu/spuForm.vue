<template>
    <el-form label-width="100">
        <el-form-item label="SPU名称">
            <el-input placeholder="请输出SPU名称"></el-input>
        </el-form-item>
        <el-form-item label="SPU品牌">
            <el-select placeholder="请选择品牌" style="width: 120px;" >
                <el-option label="1" value="华为"></el-option>
                <el-option label="2" value="阿里"></el-option>
                <el-option label="3" value="腾讯"></el-option>
            </el-select>
        </el-form-item>
        <el-form-item label="SPU描述">
            <el-input placeholder="请输入描述" type="textarea"></el-input>
        </el-form-item>
        <el-form-item label="SPU图片">
            <el-upload
    action="https://run.mocky.io/v3/9d059bf9-4660-45f2-925d-ce80ad6c4d15"
    list-type="picture-card">
                <el-icon>
                    <Plus />
                </el-icon>
            </el-upload>
            <el-dialog>
                <img w-full alt="Preview Image" />
            </el-dialog>
        </el-form-item>
        <el-form-item label="SPU销售属性">
            <el-select style="width: 120px;" >
                <el-option label="1" value="1"></el-option>
                <el-option label="2" value="2"></el-option>
                <el-option label="3" value="3"></el-option>
            </el-select>
            <el-button style="margin-left: 10px;" type="primary" size="default" icon="Plus">添加属性值</el-button>
            <el-table border style="margin: 10px 0px;">
                <el-table-column label="序号"></el-table-column>
                <el-table-column label="销售属性名字"></el-table-column>
                <el-table-column label="销售属性值"></el-table-column>
                <el-table-column label="操作"></el-table-column>
            </el-table>
        </el-form-item>
        <el-form-item>
            <el-button type="primary" size="default">保存</el-button>
            <el-button type="primary" size="default" @click="cnecel">取消</el-button>
        </el-form-item>
    </el-form>
</template>

<script setup lang='ts'>
let $emit = defineEmits(['change-scene']);
//点击取消按钮通知父组件切换场景
const cnecel = () => {
    $emit('change-scene',0);
}
</script>

<style></style>