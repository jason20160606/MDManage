<template>
    <svg>
        <use :xlink:href="prefix + name" :fill="color"></use>
    </svg>
</template>

<script setup lang='ts'>

//接收父组件传过来的参数
defineProps({
    prefix: {
        type: String,
        default: '#icon-'
    },
    name: {
        type: String,
        default: ''
    },
    color: {
        type: String,
        default: '#000000'
    },
    size: {
        type: [String, Number],
        default: 24
    }
})
</script>

<style></style>