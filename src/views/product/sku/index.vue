<template>
        <div><Category :scene="scene"></Category></div>
</template>
    
<script setup lang='ts'>
import { ref } from 'vue';

    let scene = ref<number>(0); //接受父组件传过来的值
</script>
    
<style>
    
</style>