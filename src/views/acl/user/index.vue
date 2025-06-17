<template>
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
            <el-table-column label="用户名" prop="Username" align="center">
            </el-table-column>
            <el-table-column label="昵称" prop="Nickname" align="center">
            </el-table-column>
            <el-table-column label="状态" prop="status" align="center">
                <template #default="{ row }">
                    <el-tag :type="row.status === '1' ? 'success' : 'danger'">
                        {{ row.status === '1' ? '启用' : '禁用' }}
                    </el-tag>
                </template>
            </el-table-column>
            <el-table-column label="最后登录时间" prop="LastLoginTime" align="center">
            </el-table-column>
            <el-table-column label="操作" width="300px" align="center" fixed="right">
                <template #default="{ row }">
                    <el-button type="primary" size="small" icon="User" @click="roles">分配角色</el-button>
                    <el-button type="success" size="small" icon="Edit" @click="handleEdit(row)">编辑</el-button>
                    <el-button type="danger" size="small" icon="Delete" @click="handleDelete(row)">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
        <el-pagination v-model:current-page="currentPageNo" v-model:page-size="pageSize" :page-sizes="[10, 20, 50, 100]"
            :background="background" layout="total, sizes, prev, pager, next, jumper" :total="total"
            @current-change="getUserInfo" @size-change="handleSizeChange" />
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
    <!--角色分配-->
    <el-drawer v-model="roleDrawer">
        <template #title>
            <h4>角色分配</h4>
        </template>
        <template #default>
            <el-form>
                <el-form-item label="用户名称">
                    <el-input :disabled="true"></el-input>
                </el-form-item>
                <el-form-item label="职位列表">
                    <el-checkbox v-model="checkAll" :indeterminate="isIndeterminate" @change="handleCheckAllChange">
                        全部
                    </el-checkbox>
                    <el-checkbox-group v-model="userRoles" @change="handleCheckedCitiesChange">
                        <el-checkbox v-for="(role, index) in rolesList" :key="index" :label="role">
                            {{ role.Name }}
                        </el-checkbox>
                    </el-checkbox-group>
                </el-form-item>
            </el-form>
        </template>
        <template #footer>
            <div style="flex:auto">
                <el-button type>取消</el-button>
                <el-button type="primary">确定</el-button>
            </div>
        </template>
    </el-drawer>
</template>

<script setup lang='ts'>
import { ref, onMounted } from 'vue';
import { reqUserList, reqAddUser, reqUpdateUser, reqDeleteUser } from '@/api/acl/user';
import { reqGetRoleList } from '@/api/acl/role';
import { ElMessage, ElMessageBox } from 'element-plus';

// 加载状态
const loading = ref(false);

//分页器
let currentPageNo = ref(1); //当前页码
let pageSize = ref(10); //每页显示多少条数据
let background = ref(true); //分页器是否有背景色
let total = ref(0);//总数量
//用户数据
let recordsattr = ref([]);
let account = ref<string>('');

//控制抽屉显示隐藏
let drawer = ref(false);
//控制角色分配抽屉显示隐藏
let roleDrawer = ref(false);
//全选
let checkAll = ref(false);
//设置不确定的复选框
let isIndeterminate = ref(true);
//设置职位
let rolesList = ref(["销售", "前台", "后台"]); //角色列表
let userRoles = ref(["销售"]); //用户角色

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
onMounted(() => {
    getUserInfo();
});
//搜索用户
const search = () => {
    getUserInfo();
    account.value = ''
}

//获取用户信息
const getUserInfo = async (pager = 1) => {
    currentPageNo.value = pager; //更新当前页码
    const params = {
        PageNumber: currentPageNo.value,
        PageSize: pageSize.value,
        Account: account.value  // 添加用户名搜索参数
    }
    try {
        let resault = await reqUserList(params);
        if (resault.status == 200) {
            recordsattr.value = resault.data;
            // 从响应头中获取分页信息
            const pagination = JSON.parse(resault.headers['x-pagination']);
            currentPageNo.value = pagination.PageIndex;
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

//下拉菜单变化发起请求
const handleSizeChange = (val: number) => {
    pageSize.value = val; //更新每页显示的条数
    getUserInfo(1); //重新获取用户信息，重置到第一页
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

//编辑用户
const handleEdit = (row: any) => {
    console.log(row)
    drawerTitle.value = '编辑用户';
    userForm.value = {
        id: row.Id.toString(),  // 转换为字符串
        username: row.Username,
        nickname: row.Nickname,
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
            const res = await reqDeleteUser(row.id);
            if (res.status === 200) {
                ElMessage.success('删除成功');
                getUserInfo();
            }
        } catch (error) {
            console.error('删除用户失败：', error);
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
                if (userForm.value.id) {
                    //编辑用户 - 只提交昵称
                    const updateData = {
                        nickname: userForm.value.nickname,
                        password: userForm.value.password || ''
                    };
                    res = await reqUpdateUser(Number(userForm.value.id), updateData);
                    if (res.status === 200) {
                        ElMessage.success('修改成功');
                        drawer.value = false;
                        getUserInfo();
                    }
                } else {
                    //新增用户 - 提交所有字段
                    res = await reqAddUser(userForm.value);
                    if (res.status === 201) {
                        ElMessage.success('添加成功');
                        drawer.value = false;
                        getUserInfo();
                    }
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
const roles = async () => {
    roleDrawer.value = true; //显示抽屉
    const params = {
        PageNumber: 1,
        PageSize: 100
    }
    let role = await reqGetRoleList(params);
    if (role.status == 200) {
        rolesList = role.data;

    }

}

//全选
const handleCheckAllChange = (val: boolean) => {
    userRoles.value = val ? rolesList.value : []
    isIndeterminate.value = false
}

//监听复选框变化
const handleCheckedCitiesChange = (value: string[]) => {
    checkAll.value = value.length === rolesList.value.length; //更新全选状态
    isIndeterminate.value = value.length > 0 && value.length < rolesList.value.length; //更新不确定状态
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
</style>