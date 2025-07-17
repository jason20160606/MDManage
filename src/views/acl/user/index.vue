<template>
    <div>
        <el-card>
            <el-form :inline="true" class="form">
                <el-form-item label="用户名：">
                    <el-input v-model="account" placeholder="请输入用户名"></el-input>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="search">搜索</el-button>
                    <el-button type="primary" @click="handleReset">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>
        <el-card style="margin: 10px 0px;">
            <el-button type="primary" icon="Plus" @click="addUser">新增用户</el-button>
            <el-table v-loading="loading" border style="margin: 10px 0px;" :data="recordsattr">
                <el-table-column label="序号" type="index" width="80px" align="center">
                </el-table-column>
                <el-table-column label="用户名" prop="Username" align="center" width="120px">
                </el-table-column>
                <el-table-column label="昵称" prop="Nickname" align="center" width="120px">
                </el-table-column>
                <el-table-column label="状态" prop="status" align="center" width="100px">
                    <template #default="{ row }">
                        <el-tag :type="row.Status === 1 ? 'success' : 'danger'">
                            {{ row.Status === 1 ? '启用' : '禁用' }}
                        </el-tag>
                    </template>
                </el-table-column>
                <!-- 新增：角色列 -->
                <el-table-column label="角色" align="left">
                    <template #default="{ row }">
                        <div class="role-cell">
                            <template v-if="row.Roles && row.Roles.length">
                                <el-tag v-for="role in row.Roles" :key="role.Id || role.id || role"
                                    style="margin-right: 4px;">
                                    {{ role.Name || role.name || role }}
                                </el-tag>
                            </template>
                            <template v-else>
                                <el-tag type="info">无</el-tag>
                            </template>
                        </div>
                    </template>
                </el-table-column>

                <el-table-column label="最后登录时间" prop="LastLoginTime" align="center">
                    <template #default="{ row }">
                        <span>{{ formatDateTime(row.LastLoginTime) }}</span>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="220px" align="center" fixed="right">
                    <template #default="{ row }">
                        <!-- 状态控制按钮：仅图标，带悬浮提示 -->
                        <el-tooltip content="状态切换" placement="top">
                            <el-button :type="row.Status === 1 ? 'warning' : 'success'" size="small" icon="Switch"
                                circle @click="handleStatusBtn(row)" :title="row.Status === 1 ? '禁用' : '启用'" />
                        </el-tooltip>
                        <!-- 分配角色按钮：仅图标，带悬浮提示 -->
                        <el-tooltip content="分配角色" placement="top">
                            <el-button type="primary" size="small" icon="User" circle @click="roles(row)"
                                title="分配角色" />
                        </el-tooltip>
                        <!-- 重置密码按钮：仅图标，带悬浮提示 -->
                        <el-tooltip content="重置密码" placement="top">
                            <el-button type="success" size="small" icon="Key" circle @click="handleResetPassword(row)"
                                title="重置密码" />
                        </el-tooltip>
                        <!-- 删除按钮：仅图标，带悬浮提示 -->
                        <el-tooltip content="删除" placement="top">
                            <el-button type="danger" size="small" icon="Delete" circle @click="handleDelete(row)"
                                title="删除" />
                        </el-tooltip>
                    </template>
                </el-table-column>
            </el-table>
            <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize"
                :page-sizes="[10, 20, 50, 100]" :background="background"
                layout="total, sizes, prev, pager, next, jumper" :total="total" @current-change="handleCurrentChange"
                @size-change="handleSizeChange" />
        </el-card>
        <!--抽屉效果新增修改-->
        <el-drawer v-model="drawer" :title="drawerTitle" size="500px">
            <template #default>
                <el-form :model="userForm" :rules="rules" ref="userFormRef" label-width="80px">
                    <el-form-item label="用户名" prop="username">
                        <el-input v-model="userForm.username" placeholder="请输入用户名"
                            :disabled="drawerTitle === '编辑用户'"></el-input>
                    </el-form-item>
                    <el-form-item label="昵称" prop="nickname">
                        <el-input v-model="userForm.nickname" placeholder="请输入昵称"></el-input>
                    </el-form-item>
                    <el-form-item label="密码" prop="password">
                        <el-input v-model="userForm.password" type="password" placeholder="请输入密码"></el-input>
                    </el-form-item>
                </el-form>
            </template>
            <template #footer>
                <div style="flex: auto">
                    <el-button @click="drawer = false">取消</el-button>
                    <el-button type="primary" @click="handleSubmit">确定</el-button>
                </div>
            </template>
        </el-drawer>
        <!--角色分配弹窗-->
        <el-dialog v-model="roleDialogVisible" title="角色分配" width="500px">
            <el-form>
                <el-form-item label="用户名称">
                    <!-- 绑定当前分配角色的用户名，并禁用输入 -->
                    <el-input v-model="currentRoleUserName" :disabled="true"></el-input>
                </el-form-item>
                <el-form-item label="职位列表">
                    <el-checkbox v-model="checkAll" :indeterminate="isIndeterminate" @change="handleCheckAllChange">
                        全部
                    </el-checkbox>
                    <el-checkbox-group v-model="userRoles" @change="handleCheckedCitiesChange">
                        <el-row gutter="10">
                            <el-col :span="8" v-for="role in rolesList" :key="role.Id">
                                <el-checkbox :label="String(role.Id)">{{ role.Name }}</el-checkbox>
                            </el-col>
                        </el-row>
                    </el-checkbox-group>
                </el-form-item>
            </el-form>
            <template #footer>
                <span class="dialog-footer">
                    <el-button @click="roleDialogVisible = false">取消</el-button>
                    <el-button type="primary" @click="handleAssignRoles">确定</el-button>
                </span>
            </template>
        </el-dialog>
    </div>
</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
import { reqUserList, reqAddUser, reqDeleteUser, reqGetUserRoles, reqResetPassword, reqEnableUser, reqAssignRoles } from '@/api/acl/user';
import { reqGetRoleName } from '@/api/acl/role';
import { ElMessage, ElMessageBox } from 'element-plus';

// 加载状态
const loading = ref(false);

//分页器
let currentPage = ref(1); //当前页码
let pageSize = ref(10); //每页显示多少条数据
let background = ref(true); //分页器是否有背景色
let total = ref(0);//总数量
//用户数据类型定义，补充 status 字段
interface UserRecord {
    Id: number | string;
    Username: string;
    Nickname: string;
    status: string; // '1' 启用，'0' 禁用
    LastLoginTime?: string;
    Roles?: any[]; // 新增：角色集合
    // 其他字段可按需补充
}
//用户数据
let recordsattr = ref<UserRecord[]>([]);
let account = ref<string>('');

//控制抽屉显示隐藏
let drawer = ref(false);
// 控制角色分配弹窗显示隐藏
let roleDialogVisible = ref(false);
//全选
let checkAll = ref(false);
//设置不确定的复选框
let isIndeterminate = ref(true);
// 角色分配相关变量
let rolesList = ref<any[]>([]); // 角色对象数组
let userRoles = ref<string[]>([]); // 选中的角色Id数组，改为string[]
// 当前分配角色的用户名
let currentRoleUserName = ref(''); // 用于弹窗显示

//抽屉标题
const drawerTitle = ref('新增用户');
//表单ref
const userFormRef = ref();
//用户表单数据
interface UserForm {
    id: string | number;
    username: string;
    nickname: string;
    password: string;
}

const userForm = ref<UserForm>({
    id: '',
    username: '',
    nickname: '',
    password: ''
});

//表单校验规则
const rules = ref({
    username: [
        { required: true, message: '请输入用户名', trigger: 'blur' },
        { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
    ],
    nickname: [
        { required: true, message: '请输入昵称', trigger: 'blur' }
    ],
    password: [
        { required: true, message: '请输入密码', trigger: 'blur' },
        { min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
    ]
});


//组件挂载完毕
onMounted(async () => {
    getUserInfo();
    // 只在页面挂载时请求一次所有角色
    let roleRes = await reqGetRoleName();
    if (roleRes.status == 200) {
        rolesList.value = roleRes.data;
    }
});
//搜索用户
const search = () => {
    getUserInfo();
    account.value = ''
}

//获取用户信息
const getUserInfo = async () => {
    const params = {
        PageNumber: currentPage.value,
        PageSize: pageSize.value,
        Account: account.value  // 添加用户名搜索参数
    }
    try {
        let resault = await reqUserList(params);
        if (resault.status == 200) {
            // 兼容后端返回的每个用户含有Roles字段
            recordsattr.value = resault.data.map((user: any) => ({
                ...user,
                Roles: user.Roles || []
            }));
            // 从响应头中获取分页信息
            const pagination = JSON.parse(resault.headers['x-pagination']);
            currentPage.value = pagination.PageIndex;
            pageSize.value = pagination.PageSize;
            total.value = pagination.TotalCount;
        }
        else {
            console.error('获取用户信息失败：响应数据格式不正确');
        }
    } catch (error) {
        console.error('获取用户信息失败：', error);
    }
};

//页码改变处理
const handleCurrentChange = (page: number) => {
    currentPage.value = page
    getUserInfo() // 重新获取用户信息
}

//下拉菜单变化发起请求
const handleSizeChange = (val: number) => {
    pageSize.value = val; //更新每页显示的条数
    currentPage.value = 1 // 重置到第一页
    getUserInfo(); //重新获取用户信息
}

//新增用户
const addUser = () => {
    drawerTitle.value = '新增用户';
    userForm.value = {
        id: '',
        username: '',
        nickname: '',
        password: ''
    };
    drawer.value = true;
};


//删除用户
const handleDelete = (row: any) => {
    ElMessageBox.confirm(
        '确定要删除该用户吗？',
        '警告',
        {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning',
        }
    ).then(async () => {
        try {
            const res: any = await reqDeleteUser(row.Id);
            if (res.Success) {
                ElMessage.success('删除成功');
                getUserInfo();
            } else {
                ElMessage.error('删除失败');
            }
        } catch (error) {
            ElMessage.error('删除失败');
        }
    }).catch(() => {
        ElMessage.info('已取消删除');
    });
};

//提交表单
const handleSubmit = async () => {
    if (!userFormRef.value) return;

    await userFormRef.value.validate(async (valid: boolean) => {
        if (valid) {
            try {
                let res;

                //新增用户 - 提交所有字段
                res = await reqAddUser(userForm.value);
                if (res && res.status === 201) {
                    ElMessage.success('添加成功');
                    drawer.value = false;
                    getUserInfo();
                }

            } catch (error) {
                console.error('操作失败：', error);
                ElMessage.error('操作失败');
            }
        }
    });
};

//重置
const handleReset = () => {
    account.value = '';
    getUserInfo();
};

//分配角色
const roles = async (user) => {
    roleDialogVisible.value = true; // 显示弹窗
    currentRoleUserName.value = user?.Username || ''; // 记录用户名
    // 不再重复请求所有角色，直接用rolesList
    // 通过接口获取用户已分配角色Id数组
    if (user && user.Id) {
        let userRoleRes = await reqGetUserRoles(user.Id);
        console.log(userRoleRes)
        if (userRoleRes.status == 200 && Array.isArray(userRoleRes.data.Roles)) {
            userRoles.value = userRoleRes.data.Roles.map(r => String(r.Id));
        } else {
            userRoles.value = [];
        }
    } else {
        userRoles.value = [];
    }
}

//全选
const handleCheckAllChange = (val: boolean) => {
    userRoles.value = val ? (rolesList.value as any[]).map(r => String(r.Id)) : []
    isIndeterminate.value = false
}

//监听复选框变化
const handleCheckedCitiesChange = (value: string[]) => {
    checkAll.value = value.length === rolesList.value.length; //更新全选状态
    isIndeterminate.value = value.length > 0 && value.length < rolesList.value.length; //更新不确定状态
}

// 操作栏状态控制按钮逻辑（切换启用/禁用状态）
const handleStatusBtn = (row: any) => {
    // 弹出确认框
    ElMessageBox.confirm(
        `确定要${row.Status === 1 ? '禁用' : '启用'}该用户吗？`,
        '提示',
        {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning',
        }
    ).then(async () => {
        try {
            // 调用切换状态接口，IsEnabled为true表示启用，false表示禁用
            const res = await reqEnableUser({ Id: row.Id, IsEnabled: row.Status === 0 });
            if (res.Success) {
                ElMessage.success(`${row.Status === 1 ? '禁用' : '启用'}成功`);
                // 前端同步状态，1为启用，0为禁用
                row.Status = row.Status === 1 ? 0 : 1;
            } else {
                ElMessage.error('操作失败');
            }
        } catch (error) {
            ElMessage.error('操作失败');
        }
    }).catch(() => {
        ElMessage.info('已取消操作');
    });
};

// 点击重置密码按钮，弹出确认框，确认后直接调用接口并消息提示新密码
const handleResetPassword = async (row: any) => {
    ElMessageBox.confirm(
        '确定要重置该用户的密码吗？',
        '提示',
        {
            confirmButtonText: '确定',
            cancelButtonText: '取消',
            type: 'warning',
        }
    ).then(async () => {
        try {
            const res = await reqResetPassword(row.Id);
            // 假设返回新密码在res.newPassword或res.password
            if (res.Success) {
                ElMessage.success(res.Message);
            } else {
                ElMessage.error('重置密码失败');
            }

        } catch (error) {
            ElMessage.error('重置密码失败');
        }
    }).catch(() => {
        ElMessage.info('已取消重置');
    });
};

// 分配角色弹窗“确定”按钮事件
const handleAssignRoles = async () => {
    if (!currentRoleUserName.value) {
        ElMessage.error('未选择用户');
        return;
    }
    // 找到当前用户ID
    const user = recordsattr.value.find(u => u.Username === currentRoleUserName.value);
    if (!user) {
        ElMessage.error('用户信息异常');
        return;
    }
    try {
        // userRoles.value 是字符串数组，需转为数字数组
        const roleIds = userRoles.value.map(id => Number(id));
        const res = await reqAssignRoles(user.Id, roleIds);
        if (res && res.Success) {
            ElMessage.success('分配角色成功');
            roleDialogVisible.value = false;
            getUserInfo(); // 新增：分配角色成功后刷新用户列表
        } else {
            ElMessage.error(res.Message || '分配角色失败');
        }
    } catch (error) {
        ElMessage.error('分配角色失败');
    }
};

// 格式化日期时间，去掉T，显示为 yyyy-MM-dd HH:mm:ss
function formatDateTime(dateStr: string) {
    if (!dateStr) return '';
    // 兼容 ISO 字符串和普通字符串
    let d = dateStr.replace('T', ' ');
    // 如果有毫秒和Z，去掉
    d = d.replace(/\.\d{3}Z?$/, '');
    return d;
}
</script>

<style>
.form {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 10px 0;
    /* 添加上下内边距 */
}

/* 确保表单项垂直居中 */
.form .el-form-item {
    margin-bottom: 0;
    /* 移除底部间距 */
    display: flex;
    align-items: center;
}

/* 调整输入框高度 */
.form .el-input {
    line-height: 32px;
}

/* 添加表格内容居中样式 */
.el-table .cell {
    display: flex;
    justify-content: center;
    align-items: center;
}

/* 确保表格内容垂直居中 */
.el-table td {
    padding: 8px 0;
}

/* 职位列表复选框一行三个 */
.el-checkbox-group .el-row {
    width: 100%;
}

.el-checkbox-group .el-col {
    margin-bottom: 8px;
}

/* 角色列内容靠左显示 */
.role-cell {
    display: flex;
    justify-content: flex-start !important;
    align-items: center;
    width: 100%;
}

.role-cell .el-tag {
    margin-right: 4px;
}

.el-table .el-table__body td .role-cell {
    justify-content: flex-start !important;
}
</style>