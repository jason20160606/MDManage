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
        <el-button type="primary" @click="addrole">添加角色</el-button>
        <el-table border style="margin: 10px 0px;" :data="roleList">
            <el-table-column label="ID" prop="Id" width="80"></el-table-column>
            <el-table-column label="角色名称" prop="Name" width="120"></el-table-column>
            <el-table-column label="描述" prop="Description" ></el-table-column>
            <el-table-column label="权限" prop="Permissions"></el-table-column>
            <el-table-column label="操作" width="300px">
                <template #default="{ }">
                    <el-button type="primary" size="small" icon="User">分配权限</el-button>
                    <el-button type="success" size="small" icon="Edit">编辑</el-button>
                    <el-button type="info" size="small" icon="Delete">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
    </el-card>
    <!-- 分页组件 -->
    <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]" :background="background"
            layout="total, sizes, prev, pager, next, jumper" :total="total" @current-change="handleCurrentChange"
            @size-change="handleSizeChange" />
    <!-- 添加角色抽屉保持原有 -->
</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
// 导入角色列表接口
import { reqGetRoleList } from '@/api/acl/role';

// 响应式数据
let roleList = ref<any[]>([]); // 角色列表数据
let total = ref(0); // 总数据量
let currentPage = ref(1); // 当前页码
let pageSize = ref(10); // 每页显示数量
let background = ref(true); // 分页器背景色
let drawer = ref(false);

// 获取角色列表函数
const getRoleList = async () => {
    const res = await reqGetRoleList({ PageNumber: currentPage.value, PageSize: pageSize.value });
    // 假设接口返回格式：{ records: [], total: 0 }
    roleList.value = res.data;
    // 从响应头中获取分页信息
    const pagination = JSON.parse(res.headers['x-pagination']);    
    currentPage.value = pagination.PageIndex;
    pageSize.value = pagination.PageSize;
    total.value = pagination.TotalCount;
};

// 初始化加载数据
onMounted(() => {
    getRoleList();
});

// 分页切换时重新获取数据
const handleCurrentChange = (page: number) => {
    currentPage.value = page;
    getRoleList();
};

// 添加角色逻辑（保持原有）
const addrole = () => {
    drawer.value = true;
};

const handleSizeChange = (size: number) => {
    pageSize.value = size;
    currentPage.value = 1; // 重置到第一页
    getRoleList();
}
</script>

<style>
.form {
    display: flex;
    justify-content: space-between;
    align-items: center;
}
</style>