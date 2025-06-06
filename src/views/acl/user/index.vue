<template>
    <el-card>
        <el-form :inline="true" class="form">
            <el-form-item label="用户名">
                <el-input placeholder="请输入用户名"></el-input>
            </el-form-item>
            <el-form-item>
                <el-button type="primary">搜索</el-button>
                <el-button type="primary">重置</el-button>
            </el-form-item>
        </el-form>
    </el-card>
    <el-card style="margin: 10px 0px;">
        <el-button type="primary" icon="Plus" @click="addUser">新增用户</el-button>
        <el-button type="danger" icon="Delete">批量删除</el-button>
        <el-table border style="margin: 10px 0px;" :data="recordsattr">
            <el-table-column type="selection" width="80px">
            </el-table-column>
            <el-table-column label="ID" prop="userId" align="center">
            </el-table-column>
            <el-table-column label="用户名" prop="username" align="center">
            </el-table-column>
            <el-table-column label="昵称" prop="realName" align="center">
            </el-table-column>
            <el-table-column label="头像" prop="avatar" align="center">
                <template #default="{ row }">
                    <img :src="row.avatar" alt="头像" style="width: 50px; height: 50px; border-radius: 50%;">
                </template>
            </el-table-column>
            <el-table-column label="角色" prop="employeeCode" align="center">
            </el-table-column>
            <el-table-column label="手机号码" prop="phone" align="center">
            </el-table-column>
            <el-table-column label="状态" prop="status" align="center">
                <template #="{ row }">
                    <el-tag :type="row.status ? 'success' : 'danger'">{{ row.status ? '启用' : '禁用' }}</el-tag>
                </template>
            </el-table-column>
            <el-table-column label="操作" width="300px" align="center" fixed="right">
                <template #="{ row }">
                    <el-button type="primary" size="small" icon="User" @click="roles">分配角色</el-button>
                    <el-button type="success" size="small" icon="Edit" @click="reqUpdateUser(row)">编辑</el-button>
                    <el-button type="info" size="small" icon="Delete">删除</el-button>
                </template>
            </el-table-column>
        </el-table>
        <el-pagination v-model:current-page="currentPageNo" v-model:page-size="pageSizeNo"
            :page-sizes="[100, 200, 300, 400]" :size="size" :disabled="disabled" :background="background"
            layout="prev, pager, next, jumper,->, sizes,total" :total="400" @current-change="getUserInfo"
            @size-change="handleSizeChange" />
    </el-card>
    <!--抽屉效果新增修改-->
    <el-drawer v-model="drawer">
        <template #title>
            <h4>新增用户</h4>
        </template>
        <template #default>
            <el-form>
                <el-form-item label="用户">
                    <el-input placeholder="请输入用户名"></el-input>
                </el-form-item>
                <el-form-item label="昵称">
                    <el-input placeholder="请输入昵称"></el-input>
                </el-form-item>
                <el-form-item label="密码">
                    <el-input placeholder="请输入昵称"></el-input>
                </el-form-item>
            </el-form>
        </template>
        <template #footer>
            <el-form-item>
                <el-button type>取消</el-button>
                <el-button type="primary">确定</el-button>
            </el-form-item>
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
                            {{ role }}
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
import { reqUserList } from '@/api/acl/user';
//默认页码
let currentPageNo = ref(1); //当前页码
let pageSizeNo = ref(100); //每页显示多少条数据
let size = ref('medium'); //分页器尺寸
let disabled = ref(false); //分页item器是否禁用
let background = ref(true); //分页器是否有背景色
//用户总个数
let total = ref(0);
//用户数据
let recordsattr = ref([]);
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
//组件挂载完毕
onMounted(() => {
    getUserInfo();
});
//获取用户信息
const getUserInfo = async (pager = 1) => {
    currentPageNo.value = pager; //更新当前页码
    let response = await reqUserList(currentPageNo.value, pageSizeNo.value);
    if (response.code == 200) {
        recordsattr.value = response.data.dataList; //更新用户数据
        total.value = response.data.recordCount; //更新用户总个数
    } else {
        console.error('获取用户信息失败:', response.message);
    }
};
//下拉菜单变化发起请求
const handleSizeChange = () => {
    //pageSizeNo.value = val; //更新每页显示的条数
    getUserInfo(); //重新获取用户信息
}
//新增用户
const addUser = () => {
    drawer.value = true; //显示抽屉
}
//编辑用户
const reqUpdateUser = (row) => {
    drawer.value = true; //显示抽屉
    console.log('编辑用户:', row);
    // 这里可以添加编辑用户的逻辑
};
//分配角色
const roles = () => {
    roleDrawer.value = true; //显示抽屉
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
}
</style>