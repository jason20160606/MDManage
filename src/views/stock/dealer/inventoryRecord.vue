<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>库存记录 - {{ currentDealer?.Name }}</span>
        <el-button @click="goBack">返回列表</el-button>
      </div>
    </template>

    <!-- 产品信息概览 -->
    <el-descriptions v-if="currentDealer" :column="4" border class="product-overview">      
      <el-descriptions-item label="经销商">{{ currentDealer.Name }}</el-descriptions-item>
      <el-descriptions-item label="当前库存">
        <span class="current-stock">{{ currentDealer.Quota }}</span>
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
      <el-table-column label="操作时间" width="160" align="center">
        <template #default="{ row }">
          {{ formatDateTime(row.CreatedAt) }}
        </template>
      </el-table-column>
      <el-table-column label="操作类型" width="100" align="center">
        <template #default="{ row }">
          <el-tag :type="getOperationTypeTag(row.OperationType)">
            {{ getOperationTypeText(row.OperationType) }}
          </el-tag>
        </template>
      </el-table-column>
      <el-table-column label="变动前额度" width="120" align="center">
        <template #default="{ row }">
          <span>{{ row.BeforeAmount }}</span>
        </template>
      </el-table-column>
      <el-table-column label="变动额度" width="120" align="center">
        <template #default="{ row }">
          <span :class="getQuantityClass(row.Quantity)">
            {{ row.OperationType === 1 ? '-' : '+' }}{{ row.Quantity }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="变动后额度" width="120" align="center">
        <template #default="{ row }">
          <span>{{ row.AfterAmount }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作人" width="100" align="center">
        <template #default="{ row }">
          {{ row.Operator }}
        </template>
      </el-table-column>
      <el-table-column label="来源/单号"  align="left">
        <template #default="{ row }">
          {{ row.Source }}
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
            <div class="stat-label">总增加数量</div>
            <div class="stat-value in-quantity">{{ statistics.totalIn }}</div>
          </div>
        </el-col>
        <el-col :span="6">
          <div class="stat-item">
            <div class="stat-label">总扣减数量</div>
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
import { getDealerQuotaLog, getDealerDetail } from '@/api/stock/dealer/index'

// 定义事件
const emit = defineEmits(['change-scene', 'close'])

// 查询表单
const queryForm = reactive({
  adjustType: '',
  adjustReason: '',
  dateRange: []
})

// 当前经销商信息
const currentDealer = ref<any>(null)
// 当前经销商id
const currentDealerId = ref<number|string>('')
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
  // 1为扣减（负数），其它为增加（正数）
  const totalOut = recordList.value
    .filter(record => record.OperationType === 1)
    .reduce((sum, record) => sum + Math.abs(record.Quantity || 0), 0)
  const totalIn = recordList.value
    .filter(record => record.OperationType !== 1)
    .reduce((sum, record) => sum + (record.Quantity || 0), 0)
  const adjustCount = recordList.value.length
  const netChange = totalIn - totalOut
  return {
    totalIn,
    totalOut,
    adjustCount,
    netChange
  }
})

// 初始化记录，接收经销商对象或id
const initRecord = async (dealerRow: any) => {
  if (!dealerRow) return
  loading.value = true
  try {
    // 1. 获取经销商id
    const dealerId = dealerRow.Id || dealerRow.id
    currentDealerId.value = dealerId
    // 2. 获取经销商详情（通过 getDealerDetail 方法）
    const dealerRes = await getDealerDetail(dealerId)

    console.log(dealerRes)
    currentDealer.value = dealerRes.data.Data || null
    // 3. 获取库存记录
    await fetchQuotaLog()
  } catch (error) {
    ElMessage.error('获取经销商信息或库存记录失败')
    currentDealer.value = null
    recordList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 获取库存记录列表
const fetchQuotaLog = async () => {
  if (!currentDealerId.value) return
  loading.value = true
  try {
    const params = {
      dealerId: currentDealerId.value,
      adjustType: queryForm.adjustType,
      adjustReason: queryForm.adjustReason,
      dateRange: queryForm.dateRange,
      pageNumber: currentPageNo.value,
      pageSize: pageSizeNo.value
    }
    const res = await getDealerQuotaLog(params)
    recordList.value = res.data.recordList || res.data || []
    total.value = res.data.total || recordList.value.length
  } catch (error) {
    ElMessage.error('获取库存记录失败')
    recordList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 查询记录列表（只查库存记录）
const handleQuery = () => {
  currentPageNo.value = 1
  fetchQuotaLog()
}

// 重置查询
const resetQuery = () => {
  queryForm.adjustType = ''
  queryForm.adjustReason = ''
  queryForm.dateRange = []
  currentPageNo.value = 1
  fetchQuotaLog()
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
  currentPageNo.value = page
  fetchQuotaLog()
}
const handleSizeChange = (size: number) => {
  pageSizeNo.value = size
  currentPageNo.value = 1
  fetchQuotaLog()
}

// 获取操作类型标签
const getOperationTypeTag = (type: number|string) => {
  switch (type) {
    case 1: return 'success'; // 审核
    case 2: return 'info';    // 分配
    case 3: return 'danger';  // 扣减
    case 4: return 'warning'; // 返还
    default: return 'info';
  }
}

// 获取操作类型文本
const getOperationTypeText = (type: number|string) => {
  switch (type) {
    case 1: return '审核';
    case 2: return '分配';
    case 3: return '扣减';
    case 4: return '返还';
    default: return '其它';
  }
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

// 返回列表，关闭弹窗
function goBack() {
  emit('close')
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