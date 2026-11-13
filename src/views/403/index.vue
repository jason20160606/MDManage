<template>
  <div class="forbidden">
    <div class="forbidden-content">
      <h1>403</h1>
      <p>没有访问该页面的权限</p>
      <span class="tip">如确需访问，请联系管理员在「系统管理 - 角色管理」中为该角色分配对应页面权限</span>
      <div class="actions">
        <el-button type="primary" @click="goHome">返回首页</el-button>
        <el-button @click="goBack">返回上一页</el-button>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from 'vue-router'

const router = useRouter()

const goHome = () => {
  router.push('/home')
}

const goBack = () => {
  if (window.history.length > 1) {
    router.back()
  } else {
    router.push('/home')
  }
}
</script>

<style scoped>
.forbidden {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  background-color: #f5f5f5;
}

.forbidden-content {
  text-align: center;
}

.forbidden-content h1 {
  font-size: 72px;
  color: #e6a23c;
  margin-bottom: 20px;
}

.forbidden-content p {
  font-size: 18px;
  color: #666;
  margin-bottom: 12px;
}

.tip {
  display: block;
  font-size: 13px;
  color: #999;
  margin-bottom: 30px;
}

.actions {
  display: flex;
  justify-content: center;
  gap: 12px;
}
</style>
