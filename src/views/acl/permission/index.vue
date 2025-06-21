<template>
        <el-table :data="roleList" style="width: 100%; margin-bottom: 20px" row-key="id" border>            
            <el-table-column prop="Id" label="ID" />
            <el-table-column prop="Name" label="名称" />
            <el-table-column prop="Code" label="权限值" />            
            <el-table-column label="操作" width="260px">
                <template #="{ }">
                    <!-- <el-button type="primary" size="small" icon="Plus" title="新增" @click="addSKU(row)"></el-button> -->
                    <!-- <el-button type="success" size="small" icon="Edit" @click="update(row)" title="修改"></el-button> -->
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
// 导入菜单查询接口
import { reqMenuInfo } from '@/api/acl/menu';

// 定义响应式数据（替换原有硬编码）
let roleList = ref<any[]>([]); // 菜单列表数据
let roleDrawer = ref(false); // 控制添加菜单抽屉显示隐藏

// 获取菜单列表函数
const getRoleList = async () => {
    try {
        const res = await reqMenuInfo(); // 调用接口获取数据 
        // 假设接口返回格式：{ code: 200, data: [...] }（需根据实际接口调整）
        roleList.value = res.data; // 将接口数据赋值给表格 
           
    } catch (error) {
        console.error('获取菜单失败:', error);
    }
};

// 初始化加载数据
onMounted(() => {
    getRoleList();
});
</script>

<style></style>