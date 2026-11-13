<template>
  <ReceivableBill :bill-type="1" title="运费" />
</template>

<script setup lang="ts">
// 运费账单（订单级应收行 / 勾选结算）
import ReceivableBill from './components/ReceivableBill.vue'
</script>
