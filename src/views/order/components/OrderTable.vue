<template>
  <el-card class="order-table">
    <el-table :data="props.tableData" border style="width: 100%" :span-method="props.objectSpanMethod">
      <!-- 一级表头：订单基础信息 -->
      <el-table-column label="订单基础信息" align="center" width="540">
        <el-table-column prop="orderNo" label="订单编号" width="180" align="center" />
        <el-table-column prop="orderDate" label="订单日期" width="180" align="center" />
        <el-table-column prop="customerName" label="客户名称" width="180" align="center" />
      </el-table-column>

      <!-- 一级表头：产品详情 -->
      <el-table-column label="产品详情" align="center">
        <!-- 修改：使用localIndex字段代替自动序号 -->
        <el-table-column prop="localIndex" label="序号" width="80" align="center" />
        <el-table-column prop="productName" label="产品名称" width="180" align="center" />
        <el-table-column prop="quantity" label="产品数量" width="120" align="center" />
      </el-table-column>

      <el-table-column label="操作" align="center" width="120">
        <template #default="{ row }">
          <el-button type="text" size="small" @click="handleEdit(row._orderId)">编辑</el-button>
        </template>
      </el-table-column>
    </el-table>
  </el-card>
</template>

<script setup lang="ts">
import { ElMessage } from 'element-plus';

// 定义接收的props类型
interface FlattenedItem {
  orderNo: string;
  orderDate: string;
  customerName: string;
  productName: string;
  quantity: number;
  _orderId: number;
  localIndex: number;
}

interface Props {
  tableData: FlattenedItem[];
  objectSpanMethod: ({ row, column, rowIndex, columnIndex }: { row: any, column: any, rowIndex: number, columnIndex: number }) => any;
}

const props = defineProps<Props>();

const handleEdit = (orderId: number) => {
  ElMessage.info(`编辑订单ID : ${orderId}`);
};
</script>

<style scoped>
.order-table {
  margin:10px 0px;
}
</style>