<template>
    <div class="role-page-root">
    <el-card>
        <el-form :inline="true" class="form" label-width="80px">
            <el-form-item label="角色名称">
                <el-input v-model="searchName" placeholder="请输入角色名称"></el-input>
            </el-form-item>
            <el-form-item>
                <el-button type="primary" @click="handleSearch">查询</el-button>
                <el-button type="success" @click="handleReset">重置</el-button>
            </el-form-item>
        </el-form>
    </el-card>
    <el-card style="margin: 10px 0px;">
        <el-button type="primary" @click="openAddRole">添加角色</el-button>
        <el-table border style="margin: 10px 0px;" :data="roleList">
            <el-table-column label="ID" prop="Id" width="80"></el-table-column>
            <el-table-column label="角色名称" prop="Name" width="120"></el-table-column>
            <el-table-column label="描述" prop="Description" ></el-table-column>
            <el-table-column label="权限" prop="Permissions">
                <template #default="{ row }">
                    <!-- 用el-tag美观展示每个权限名称 -->
                    <span>
                        <el-tag v-for="item in (Array.isArray(row.Permissions) ? row.Permissions : [])" :key="item.Id" style="margin-right: 4px;" type="info">
                            {{ item.Name }}
                        </el-tag>
                    </span>
                </template>
            </el-table-column>
            <el-table-column label="操作" width="160px">
                <template #default="{ row }">
                    <!-- 仅显示图标按钮，添加title提示 -->
                    <el-button type="primary" size="small" icon="User" circle @click="openAssignPermission(row)" title="分配权限"></el-button>
                    <el-button type="success" size="small" icon="Edit" circle @click="openEditRole(row)" title="编辑"></el-button>
                    <el-button type="info" size="small" icon="Delete" circle @click="handleDeleteRole(row)" title="删除"></el-button>
                </template>
            </el-table-column>
        </el-table>
    </el-card>
    <!-- 分页组件 -->
    <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]" :background="background"
            layout="total, sizes, prev, pager, next, jumper" :total="total" @current-change="handleCurrentChange"
            @size-change="handleSizeChange" />
    
    <!-- 添加/编辑角色弹窗 -->
    <el-dialog v-model="roleDialogVisible" :title="roleDialogType === 'add' ? '添加角色' : '编辑角色'" width="500px">
        <el-form :model="roleForm" ref="roleFormRef" label-width="80px">
            <el-form-item label="角色名称" prop="Name" :rules="[{ required: true, message: '请输入角色名称', trigger: 'blur' }]">
                <el-input v-model="roleForm.Name" placeholder="请输入角色名称"></el-input>
            </el-form-item>
            <el-form-item label="描述" prop="Description">
                <el-input v-model="roleForm.Description" placeholder="请输入描述"></el-input>
            </el-form-item>
        </el-form>
        <template #footer>
            <el-button @click="roleDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleSaveRole">确定</el-button>
        </template>
    </el-dialog>

    <!-- 分配权限弹窗 -->
    <el-dialog v-model="assignDialogVisible" title="分配权限" width="600px">
        <el-tree
            ref="permissionTreeRef"
            :data="permissionTree"
            show-checkbox
            node-key="Id"
            :props="{ label: 'Name', children: 'Children' }"
            style="max-height: 400px; overflow: auto;"
        />
        <template #footer>
            <el-button @click="assignDialogVisible = false">取消</el-button>
            <el-button type="primary" @click="handleAssignPermission">确定</el-button>
        </template>
    </el-dialog>
</div>
</template>

<script setup lang='ts'>
import { ref, onMounted, reactive, nextTick } from 'vue';
import { ElMessage, ElMessageBox } from 'element-plus';
// 导入角色相关API
import { reqGetRoleList, reqAddRole, reqUpdateRole, reqDeleteRole, reqGetRolePermissions, reqAssignPermission } from '@/api/acl/role';
import { reqMenuInfo } from '@/api/acl/menu'; // 新增：导入菜单（权限）API

// 响应式数据
let roleList = ref<any[]>([]); // 角色列表数据
let total = ref(0); // 总数据量
let currentPage = ref(1); // 当前页码
let pageSize = ref(10); // 每页显示数量
let background = ref(true); // 分页器背景色
let drawer = ref(false);

// 添加/编辑角色弹窗相关
const roleDialogVisible = ref(false);
const roleDialogType = ref<'add' | 'edit'>('add');
const roleForm = reactive({
    Id: undefined,
    Name: '',
    Description: ''
});
const roleFormRef = ref();

// 分配权限弹窗相关
const assignDialogVisible = ref(false);
const permissionTree = ref<any[]>([]); // 权限树数据
const checkedPermissionIds = ref<number[]>([]); // 已选权限ID
const currentRoleId = ref<number | null>(null);
const permissionTreeRef = ref();

// 角色名称搜索关键字
const searchName = ref('');

// 获取角色列表函数，支持角色名称搜索
const getRoleList = async () => {
    const params: any = { PageNumber: currentPage.value, PageSize: pageSize.value };
    if (searchName.value) params.Name = searchName.value;
    const res = await reqGetRoleList(params);
    // 假设接口返回格式：{ records: [], total: 0 }
    roleList.value = res.data;
    // 从响应头中获取分页信息
    const pagination = JSON.parse(res.headers['x-pagination']);    
    currentPage.value = pagination.PageIndex;
    pageSize.value = pagination.PageSize;
    total.value = pagination.TotalCount;
};

// 查询按钮
const handleSearch = () => {
    currentPage.value = 1;
    getRoleList();
};
// 重置按钮
const handleReset = () => {
    searchName.value = '';
    currentPage.value = 1;
    getRoleList();
};

// 打开添加角色弹窗
const openAddRole = () => {
    roleDialogType.value = 'add';
    roleDialogVisible.value = true;
    roleForm.Id = undefined;
    roleForm.Name = '';
    roleForm.Description = '';
};

// 打开编辑角色弹窗
const openEditRole = (row: any) => {
    roleDialogType.value = 'edit';
    roleDialogVisible.value = true;
    roleForm.Id = row.Id;
    roleForm.Name = row.Name;
    roleForm.Description = row.Description;
};

// 保存角色（新增/编辑）
const handleSaveRole = async () => {
    await roleFormRef.value?.validate();
    if (roleDialogType.value === 'add') {
        // 添加角色
        await reqAddRole({
            Name: roleForm.Name,
            Description: roleForm.Description
        });
        ElMessage.success('添加成功');
    } else {
        // 编辑角色
        await reqUpdateRole({
            Id: roleForm.Id,
            Name: roleForm.Name,
            Description: roleForm.Description
        });
        ElMessage.success('编辑成功');
    }
    roleDialogVisible.value = false;
    getRoleList();
};

// 删除角色
const handleDeleteRole = async (row: any) => {
    try {
        await ElMessageBox.confirm(`确定要删除角色“${row.Name}”吗？`, '确认删除', {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning',
        });
        await reqDeleteRole(row.Id);
        ElMessage.success('删除成功');
        getRoleList();
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error('删除失败');
        }
    }
};

// 打开分配权限弹窗
const openAssignPermission = async (row: any) => {
    currentRoleId.value = row.Id;
    // 只请求当前角色已分配权限
    const res = await reqGetRolePermissions(row.Id);
    // 将权限对象数组转为ID数组
    checkedPermissionIds.value = Array.isArray(res.Permissions)
      ? res.Permissions.map((item: any) => item.Id)
      : [];
    assignDialogVisible.value = true;
    await nextTick();
    console.log('当前角色已分配权限ID:', checkedPermissionIds.value);
    console.log('权限树数据:', permissionTree.value);
    permissionTreeRef.value?.setCheckedKeys(checkedPermissionIds.value);
};

// 分配权限提交
const handleAssignPermission = async () => {
    const checked = permissionTreeRef.value.getCheckedKeys();
    await reqAssignPermission(currentRoleId.value, checked);
    ElMessage.success('分配权限成功');
    assignDialogVisible.value = false;
    getRoleList();
};

// 初始化加载数据
onMounted(async () => {
    getRoleList();
    // 页面加载时只请求一次权限树
    const res = await reqMenuInfo();
    permissionTree.value = res.data;    
});

// 分页切换时重新获取数据
const handleCurrentChange = (page: number) => {
    currentPage.value = page;
    getRoleList();
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