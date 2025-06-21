<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>库存记录 - {{ currentProduct?.dealerName }}</span>
        <el-button @click="goBack">返回列表</el-button>
      </div>
    </template>

    <!-- 产品信息概览 -->
    <el-descriptions v-if="currentProduct" :column="4" border class="product-overview">      
      
      <el-descriptions-item label="经销商">{{ currentProduct.dealerName }}</el-descriptions-item>
      <el-descriptions-item label="当前库存">
        <span class="current-stock">{{ currentProduct.quantity }}</span>
        <span class="stock-unit">{{ currentProduct.unit }}</span>
      </el-descriptions-item>
    </el-descriptions>

    <!-- 搜索区域 -->
    <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
      <el-form-item label="调整类型">
        <el-select v-model="queryForm.adjustType" placeholder="请选择调整类型" clearable style="width: 150px;">
          <el-option label="入库" value="in" />
          <el-option label="出库" value="out" />
          <el-option label="盘点调整" value="adjust" />
        </el-select>
      </el-form-item>
      <el-form-item label="调整原因">
        <el-select v-model="queryForm.adjustReason" placeholder="请选择调整原因" clearable style="width: 150px;">
          <el-option label="正常入库" value="normal_in" />
          <el-option label="退货入库" value="return_in" />
          <el-option label="正常出库" value="normal_out" />
          <el-option label="损坏出库" value="damage_out" />
          <el-option label="盘点差异" value="inventory_diff" />
        </el-select>
      </el-form-item>
      <el-form-item label="时间范围">
        <el-date-picker
          v-model="queryForm.dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          style="width: 250px;"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 库存记录列表 -->
    <el-table :data="recordList" border style="width: 100%" v-loading="loading">
      <el-table-column type="index" label="序号" width="80" />
      <el-table-column label="调整时间" width="160" align="center">
        <template #default="{ row }">
          {{ formatDateTime(row.adjustTime) }}
        </template>
      </el-table-column>
      <el-table-column label="调整类型" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="getAdjustTypeTag(row.adjustType)">
            {{ getAdjustTypeText(row.adjustType) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="调整原因" width="120" align="center">
        <template #default="{ row }">
          {{ getAdjustReasonText(row.adjustReason) }}
        </template>
      </el-table-column>
      <el-table-column label="调整前数量" width="120" align="center">
        <template #default="{ row }">
          <span class="quantity-before">{{ row.quantityBefore }}</span>
        </template>
      </el-table-column>
      <el-table-column label="调整数量" width="120" align="center">
        <template #default="{ row }">
          <span :class="getQuantityClass(row.adjustQuantity)">
            {{ row.adjustQuantity > 0 ? '+' : '' }}{{ row.adjustQuantity }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="调整后数量" width="120" align="center">
        <template #default="{ row }">
          <span class="quantity-after">{{ row.quantityAfter }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作人" width="100" align="center">
        <template #default="{ row }">
          {{ row.operator }}
        </template>
      </el-table-column>
      <el-table-column label="备注" min-width="200" show-overflow-tooltip>
        <template #default="{ row }">
          <span class="remark">{{ row.remark || '-' }}</span>
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-wrapper">
      <el-pagination
        v-model:current-page="currentPageNo"
        v-model:page-size="pageSizeNo"
        :page-sizes="[10, 20, 50, 100]"
        :background="background"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
      />
    </div>

    <!-- 统计信息 -->
    <el-card class="statistics-card">
      <template #header>
        <span>统计信息</span>
      </template>
      <el-row :gutter="20">
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">总入库数量</div>
            <div class="stat-value in-quantity">{{ statistics.totalIn }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">总出库数量</div>
            <div class="stat-value out-quantity">{{ statistics.totalOut }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">调整次数</div>
            <div class="stat-value adjust-count">{{ statistics.adjustCount }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">净变化</div>
            <div class="stat-value" :class="statistics.netChange >= 0 ? 'positive' : 'negative'">
              {{ statistics.netChange >= 0 ? '+' : '' }}{{ statistics.netChange }}
            </div>
          </div>
        </el-col>
      </el-row>
    </el-card>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'

// 定义事件
const emit = defineEmits(['change-scene'])

// 查询表单
const queryForm = reactive({
  adjustType: '',
  adjustReason: '',
  dateRange: []
})

// 当前产品信息
const currentProduct = ref<any>(null)

// 记录列表
const recordList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)
const background = ref(true)

// 统计信息
const statistics = computed(() => {
  const totalIn = recordList.value
    .filter(record => record.adjustType === 'in')
    .reduce((sum, record) => sum + record.adjustQuantity, 0)
  
  const totalOut = recordList.value
    .filter(record => record.adjustType === 'out')
    .reduce((sum, record) => sum + Math.abs(record.adjustQuantity), 0)
  
  const adjustCount = recordList.value
    .filter(record => record.adjustType === 'adjust')
    .length
  
  const netChange = totalIn - totalOut
  
  return {
    totalIn,
    totalOut,
    adjustCount,
    netChange
  }
})

// 初始化记录
const initRecord = (product: any) => {
  currentProduct.value = product
  handleQuery()
}

// 查询记录列表
const handleQuery = async () => {
  if (!currentProduct.value) return
  
  loading.value = true
  try {
    // TODO: 调用库存记录API
    // const result = await reqInventoryRecord(currentProduct.value.id, queryForm)
    
    // 模拟数据
    setTimeout(() => {
      recordList.value = [
        {
          id: '1',
          adjustTime: '2024-01-15 14:30:00',
          adjustType: 'in',
          adjustReason: 'normal_in',
          quantityBefore: 40,
          adjustQuantity: 10,
          quantityAfter: 50,
          operator: '张三',
          remark: '正常入库'
        },
        {
          id: '2',
          adjustTime: '2024-01-14 16:20:00',
          adjustType: 'out',
          adjustReason: 'normal_out',
          quantityBefore: 45,
          adjustQuantity: -5,
          quantityAfter: 40,
          operator: '李四',
          remark: '正常出库'
        },
        {
          id: '3',
          adjustTime: '2024-01-13 10:15:00',
          adjustType: 'adjust',
          adjustReason: 'inventory_diff',
          quantityBefore: 50,
          adjustQuantity: -5,
          quantityAfter: 45,
          operator: '王五',
          remark: '盘点调整'
        }
      ]
      total.value = recordList.value.length
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取库存记录失败')
    console.error('库存记录查询错误:', error)
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.adjustType = ''
  queryForm.adjustReason = ''
  queryForm.dateRange = []
  currentPageNo.value = 1
  handleQuery()
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
  currentPageNo.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSizeNo.value = size
  currentPageNo.value = 1
  handleQuery()
}

// 获取调整类型标签
const getAdjustTypeTag = (type: string) => {
  switch (type) {
    case 'in': return 'success'
    case 'out': return 'danger'
    case 'adjust': return 'warning'
    default: return 'info'
  }
}

// 获取调整类型文本
const getAdjustTypeText = (type: string) => {
  switch (type) {
    case 'in': return '入库'
    case 'out': return '出库'
    case 'adjust': return '调整'
    default: return '未知'
  }
}

// 获取调整原因文本
const getAdjustReasonText = (reason: string) => {
  const reasonMap: Record<string, string> = {
    'normal_in': '正常入库',
    'return_in': '退货入库',
    'normal_out': '正常出库',
    'damage_out': '损坏出库',
    'inventory_diff': '盘点差异'
  }
  return reasonMap[reason] || reason
}

// 获取数量样式类
const getQuantityClass = (quantity: number) => {
  if (quantity > 0) return 'quantity-in'
  if (quantity < 0) return 'quantity-out'
  return 'quantity-zero'
}

// 格式化日期时间
const formatDateTime = (dateStr: string) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

// 暴露方法给父组件
defineExpose({
  initRecord
})
</script>

<style lang="scss" scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.product-overview {
  margin-bottom: 20px;
  
  .current-stock {
    font-size: 18px;
    font-weight: bold;
    color: #409eff;
  }
  
  .stock-unit {
    font-size: 12px;
    color: #909399;
    margin-left: 4px;
  }
}

.search-form {
  margin-bottom: 20px;
}

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.statistics-card {
  margin-top: 20px;
  
  .stat-item {
    text-align: center;
    
    .stat-label {
      font-size: 14px;
      color: #606266;
      margin-bottom: 8px;
    }
    
    .stat-value {
      font-size: 24px;
      font-weight: bold;
      
      &.in-quantity {
        color: #67c23a;
      }
      
      &.out-quantity {
        color: #f56c6c;
      }
      
      &.adjust-count {
        color: #e6a23c;
      }
      
      &.positive {
        color: #67c23a;
      }
      
      &.negative {
        color: #f56c6c;
      }
    }
  }
}

.quantity-before {
  color: #909399;
}

.quantity-after {
  color: #409eff;
  font-weight: bold;
}

.quantity-in {
  color: #67c23a;
  font-weight: bold;
}

.quantity-out {
  color: #f56c6c;
  font-weight: bold;
}

.quantity-zero {
  color: #909399;
}

.remark {
  color: #606266;
}
</style> 