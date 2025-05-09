<template>
<div class="login">
    <el-row>
        <el-col :span="12" :xs="0">       
        </el-col>
        <el-col :span="12" :xs="24">
            <el-form>
                <h1>Hello</h1>
                <h2>欢迎来到后台订单系统</h2>
                <el-form-item label="用户名">
                    <el-input placeholder="请输入用户名"></el-input>
                </el-form-item>
                <el-form-item label="用户名">
                    <el-input placeholder="请输入用户名"></el-input>
                </el-form-item>
            </el-form>
        </el-col>
    </el-row>    
</div> 
</template>
    
<script setup lang='ts'>
    
</script>
    
<style scoped lang='scss'>
.login {
    width: 100%;
    height: 100vh;
    background: url('@/assets/images/login.jpg') no-repeat center center fixed;
    background-size: cover;   
}
    
</style>