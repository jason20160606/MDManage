<template>
  <div class="app-container">
    <el-card>
      <!-- 搜索与按钮区域 -->
      <template #header>
        <div class="header-container">
          <!-- 搜索表单 -->
          <el-form :inline="true" class="search-form">
            <el-form-item label="经销商名称">
              <el-input v-model="searchForm.dealerName" placeholder="请输入经销商名称" clearable />
            </el-form-item>
            <el-form-item label="收货人姓名">
              <el-input v-model="searchForm.receiverName" placeholder="请输入收货人姓名" clearable />
            </el-form-item>
            <el-form-item>
              <el-button type="primary" @click="handleSearch">搜索</el-button>
              <el-button @click="resetSearch">重置</el-button>
            </el-form-item>
          </el-form>

          <!-- 操作按钮 -->
          <div class="button-group">
            <el-button type="primary" @click="handleAddOrder">新增订单</el-button>
            <el-button type="success" @click="handleImportOrder">导入订单</el-button>
          </div>
        </div>
      </template>
    </el-card>
    <!-- 订单列表 -->
    <OrderTable :table-data="tableData" :object-span-method="objectSpanMethod" />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { reqOrderlist } from '@/api/order'
import OrderTable from '../components/OrderTable.vue'

// 搜索表单
const searchForm = reactive({ 
  dealerName: '', 
  receiverName: '' 
})

// 订单列表
const orderList = ref([])

// 处理后的表格数据
const tableData = computed(() => {
  const result: any[] = []
  if (!orderList.value) return result
  
  orderList.value.forEach((order: any) => {
    const items = order?.OrderItems || []
    let localIndex = 1; // 为每个订单重置产品序号
    items.forEach((item: any, index: number) => {
      result.push({
        ...order,
        orderNo: order.OrderNo, // 确保有 orderNo 字段
        orderDate: order.OrderDate || '2024-01-01', // 添加订单日期
        customerName: order.CustomerName || '未知客户', // 添加客户名称
        productName: item?.productName || '',
        quantity: item?.quantity || 0,
        _orderId: order.Id, // 确保有 _orderId 字段
        localIndex: localIndex++, // 添加产品序号
        _rowspan: index === 0 ? items.length : 0 // 用于合并单元格
      })
    })
  })
  return result
})

// 获取订单列表数据
const getOrderList = async () => {
  try {
    const res = await reqOrderlist()
    console.log('API返回数据:', res) // 添加日志
    if (res.status === 200 && Array.isArray(res.data)) {
      orderList.value = res.data
      ElMessage.success('获取订单列表成功')
    } else {
      orderList.value = []
      ElMessage.error(res.message || '获取订单列表失败')
    }
  } catch (error) {
    console.error('获取订单列表出错：', error)
    orderList.value = []
    ElMessage.error('获取订单列表失败')
  }
}

// 页面加载时获取数据
onMounted(() => {
  getOrderList()
})

// 搜索操作
const handleSearch = async () => {
  try {
    const res = await reqOrderlist()
    if (res.code === 200) {
      // 根据搜索条件过滤数据
      const filteredData = res.data.filter(order => {
        const matchDealer = !searchForm.dealerName || 
          order.dealerName.toLowerCase().includes(searchForm.dealerName.toLowerCase())
        const matchReceiver = !searchForm.receiverName || 
          order.receiverName.toLowerCase().includes(searchForm.receiverName.toLowerCase())
        return matchDealer && matchReceiver
      })
      orderList.value = filteredData
      ElMessage.success('搜索成功')
    } else {
      ElMessage.error(res.message || '搜索失败')
    }
  } catch (error) {
    console.error('搜索出错：', error)
    ElMessage.error('搜索失败')
  }
}

// 重置搜索
const resetSearch = () => {
  searchForm.dealerName = ''
  searchForm.receiverName = ''
}

// 新增订单
const handleAddOrder = () => {
  // TODO: 跳转新增页面或打开对话框
  ElMessage.info('新增订单功能待实现')
}

// 导入订单
const handleImportOrder = () => {
  // TODO: 打开文件上传对话框
  ElMessage.info('订单导入功能待实现')
}

// 合并单元格方法
const objectSpanMethod = ({ row, column, rowIndex, columnIndex }: { row: any, column: any, rowIndex: number, columnIndex: number }) => {
  // 需要合并的列：订单编号 (columnIndex 0), 订单日期 (columnIndex 1), 客户名称 (columnIndex 2), 操作 (columnIndex 6)
  if (columnIndex === 0 || columnIndex === 1 || columnIndex === 2 || columnIndex === 6) {
    if (row._rowspan) {
      return {
        rowspan: row._rowspan,
        colspan: 1
      }
    } else {
      return {
        rowspan: 0,
        colspan: 0
      }
    }
  }
  return { rowspan: 1, colspan: 1 };
}

const getStatusType = (status: string) => {
  const statusMap = {
    '0': 'info',    // 待处理
    '1': 'success', // 已完成
    '2': 'warning', // 处理中
    '3': 'danger'   // 已取消
  }
  return statusMap[status] || 'info'
}
</script>

<style lang="scss" scoped>
.header-container {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.search-form {
  flex: 1;
  max-width: 800px;
}

.button-group {
  margin-left: 20px;
  white-space: nowrap;
}

/* 调整表格样式 */
:deep(.el-table) {
  .el-table__header {
    th {
      background-color: #f5f7fa;
      color: #606266;
      font-weight: 500;
    }
  }
  
  /* 合并单元格样式 */
  .el-table__row {
    td {
      padding: 8px 0;
    }
  }
}
</style>

<style lang="scss" scoped>
/* 调整嵌套表格的边距，避免与父表格间距过大 */
.el-table .el-table {
  margin: 0;
}

/* 调整展开行的样式 */
:deep(.el-table__expand-column) {
  .el-table__expand-icon {
    color: #409eff;
  }
}


:deep(.el-table__expanded-cell .el-table) {
  margin: 0;
  background-color: #fff;
}
</style>
