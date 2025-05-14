<template>
    <div class="login">
        <el-row>
            <el-col :span="12" :xs="0">
            </el-col>
            <el-col :span="12" :xs="24">
                <el-form class="login-form" :model="LoginFrom" :rules="rules" ref="LoginForms">
                    <h1>Hello</h1>
                    <h2>欢迎来到后台订单系统</h2>
                    <el-form-item prop="username">
                        <el-input :prefix-icon="User" v-model="LoginFrom.username" placeholder="请输入用户名"></el-input>
                    </el-form-item>
                    <el-form-item prop="password">
                        <el-input type="password" :prefix-icon="Lock" v-model="LoginFrom.password" show-password
                            placeholder="请输入密码"></el-input>
                    </el-form-item>
                    <el-form-item>
                        <el-button :loading="loading" type="primary" size="defaule" class="login-btn"
                            @click="Login">登录</el-button>
                    </el-form-item>
                </el-form>
            </el-col>
        </el-row>
    </div>
</template>

<script setup lang='ts'>
import { User, Lock } from '@element-plus/icons-vue';
import { reactive, ref } from 'vue';
//引入用户相关仓库
import useUserStore from '@/store/modules/user';
//引入路由
import { useRouter,useRoute } from 'vue-router';
//引入element-plus
import { ElNotification } from 'element-plus';
//映入获取当前时间的函数
import { getTime } from '@/utils/time';
//获取路由
const $router = useRouter();
const $route = useRoute();
//控制loading
const loading = ref(false);

let userStore = useUserStore();
//收集账号信息
const LoginFrom = reactive({
    username: 'admin',
    password: '123456'
});
//登录
const Login = async () => {
    //获取表单实例
    await LoginForms.value.validate();
    loading.value = true;
    try {
        //登录
        await userStore.userLogin(LoginFrom);
        //跳转到首页
        if ($route.query.redirect) {
            $router.push($route.query.redirect as string);            
        }else{
            $router.push({ path: '/' });
        }
        
        ElNotification({
            title: `${getTime()}好`,
            message: `欢迎回来，${LoginFrom.username}`,
            type: 'success',
        });
        loading.value = false;
    } catch (error) {
        loading.value = false;
        ElNotification({
            message: error,
            type: 'error',
        });
    }
};
const validatorUsername = (rule, value, callback) => {
    rule.trigger = 'change';
    if (value === '') {
        callback(new Error('请输入用户名'));
    } else if (value.length < 3 || value.length > 10) {
        callback(new Error('长度在 3 到 10 个字符'));
    } else {
        callback();
    }
};
const validatorPassword = (rule, value, callback) => {
    rule.trigger = 'change';
    if (value === '') {
        callback(new Error('请输入密码'));
    } else if (value.length < 6 || value.length > 20) {
        callback(new Error('长度在 6 到 20 个字符'));
    } else {
        callback();
    }
};
//定义表单效验规则对象
const rules = {
    username: [
        //{ required: true, message: '请输入用户名', trigger: 'blur' },
        //{ min: 3, max: 10, message: '长度在 3 到 10 个字符', trigger: 'blur' }
        { validator: validatorUsername }

    ],
    password: [
        //{ required: true, message: '请输入密码', trigger: 'blur' },
        //{ min: 6, max: 20, message: '长度在 6 到 20 个字符', trigger: 'blur' }
        { validator: validatorPassword }
    ]
};
//获取el-form组件
const LoginForms = ref();
</script>

<style scoped lang='scss'>
.login {
    width: 100%;
    height: 100vh;
    background: url('@/assets/images/login.jpg') no-repeat center center fixed;
    background-size: cover;

    .login-form {
        position: relative;
        width: 80%;
        top: 30vh;
        background-color: rgba(163, 158, 238, 0.8);
        background-size: cover;
        padding: 40px;
        border-radius: 10px;

        h1 {
            font-size: 40px;
            color: white;
        }

        h2 {
            font-size: 20px;
            color: white;
            margin: 20px 0 20px 0;
        }

        .login-btn {
            width: 100%;
            height: 50px;
            font-size: 20px;
            background-color: #5c6bc0;
            border-radius: 5px;
            color: white;
        }
    }
}
</style>