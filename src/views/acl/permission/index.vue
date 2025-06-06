<template>
        <el-table :data="roleList" style="width: 100%; margin-bottom: 20px" row-key="id" border>
            <el-table-column prop="date" label="名称" />
            <el-table-column prop="name" label="权限值" />
            <el-table-column prop="address" label="修改时间" />
            <el-table-column prop="address" label="操作">
                <template #="{ row }">
                    <el-button type="primary" size="small" icon="Plus" title="新增" @click="addSKU(row)"></el-button>
                    <el-button type="success" size="small" icon="Edit" @click="update(row)" title="修改"></el-button>
                    <el-button type="info" size="small" icon="View" title="查看"></el-button>
                    <el-button type="danger" size="small" icon="Delete" title="删除"></el-button>
                </template>
            </el-table-column>
        </el-table>
    <el-dialog v-model="roleDrawer" width="50%" title="添加菜单">
        <el-form>
            <el-form-item label="菜单名称">
                <el-input placeholder="请输入菜单名称"></el-input>
            </el-form-item>
            <el-form-item label="权限名称">
                <el-input placeholder="请输入权限名称"></el-input>
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="roleDrawer = false">取消</el-button>
            <el-button type="primary">确定</el-button>
        </template>
    </el-dialog>
</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
//引入API
//定义表格数据
let roleList = ref([
    {
        id: 1,
        date: '超级管理员',
        name: 'admin',
       
        children:  [
            {
                id: 1,
                date: '超级管理员',
        name: 'admin',
            },
            {
                id: 2,
                date: '超级管理员',
        name: 'admin',
            }
            
        ]
    },
    {
        id: 2,
        date: '普通用户',
        name: 'user',
        children: [
            {
                id: 1,
                date: '超级管理员',
                name: 'admin',
            },
            {
                id: 2,
                date: '超级管理员',
                name: 'admin',
            }
            
        ]
    },
    {
        id: 3,
        date: '测试用户',
        name: 'test',
        children: [
            {
                id: 1,
                date: '超级管理员',
                name: 'admin',
            },
            {
                id: 2,
                date: '超级管理员',
        name: 'admin',
            }
            
        ]
    }
]);
let roleDrawer = ref(true); //控制角色分配抽屉显示隐藏
onMounted(() => {
    getRoleList();
});
const getRoleList = async () => {

};
</script>

<style></style>