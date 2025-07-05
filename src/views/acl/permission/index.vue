<template>
    <!-- 表格展示，增加序号列 -->
    <el-table :data="roleList" style="width: 100%; margin-bottom: 20px" row-key="id" border>
        <!-- 序号列，动态计算当前页的序号 -->
        <el-table-column label="序号" width="80">
            <template #default="{ $index }">
                <!-- 中文注释：序号根据当前页和每页条数动态计算 -->
                {{ ($index + 1) + (currentPage - 1) * pageSize }}
            </template>
        </el-table-column>
        <!-- 名称列 -->
        <el-table-column prop="Name" label="名称" />
        <!-- 权限值列 -->
        <el-table-column prop="Code" label="权限值" />
        <!-- 操作列 -->
        <el-table-column label="操作" width="260px">
            <template #="{ }">
                <!-- <el-button type="primary" size="small" icon="Plus" title="新增" @click="addSKU(row)"></el-button> -->
                <!-- <el-button type="success" size="small" icon="Edit" @click="update(row)" title="修改"></el-button> -->
                <el-button type="info" size="small" icon="View" title="查看"></el-button>
                <el-button type="danger" size="small" icon="Delete" title="删除"></el-button>
            </template>
        </el-table-column>
    </el-table>
    <!-- 分页器，放在表格下方，完全参考role页面写法 -->
    <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
        style="margin-top: 10px; text-align: right;"
    />
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

// 响应式数据
let roleList = ref<any[]>([]); // 当前页数据
let total = ref(0); // 总数据量
const currentPage = ref(1); // 当前页码
const pageSize = ref(10); // 每页显示数量
let roleDrawer = ref(false); // 控制添加菜单抽屉显示隐藏

// 获取菜单列表函数（带分页参数，参考role页面）
const getRoleList = async () => {
    try {
        const res = await reqMenuInfo({ PageNumber: currentPage.value, PageSize: pageSize.value });
        // 假设接口返回格式：{ data: [], headers: { 'x-pagination': '{...}' } }
        roleList.value = res.data;
        // 从响应头中获取分页信息
        if (res.headers && res.headers['x-pagination']) {
            const pagination = JSON.parse(res.headers['x-pagination']);
            currentPage.value = pagination.PageIndex;
            pageSize.value = pagination.PageSize;
            total.value = pagination.TotalCount;
        } else {
            // 兼容无headers时的写法
            total.value = res.total || 0;
        }
    } catch (error) {
        console.error('获取菜单失败:', error);
    }
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

// 每页条数切换
const handleSizeChange = (size: number) => {
    pageSize.value = size;
    getRoleList();
};
</script>

<style></style>