<template>
  <ReceivableBill :bill-type="2" title="差价" />
</template>

<script setup lang="ts">
// 差价账单（订单级应收行 / 勾选结算）
import ReceivableBill from './components/ReceivableBill.vue'
</script>
