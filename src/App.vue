<template>
  <div>
    <h1>
      <router-view />
    </h1>
  </div>
</template>

<script setup lang='ts'>
//引入请求拦截器
import service from './utils/request';
import { onMounted } from 'vue';
//组件挂载完毕发送请求
onMounted(() => {
  service({
    url: '/login',
    method: 'post',
    data: {
      username: 'admin',
      password: '123456'
    }
  }).then((res) => {
    console.log(res);
  }).catch((err) => {
    console.log(err);
  })
});

</script>

<style scoped lang='scss'>
</style>