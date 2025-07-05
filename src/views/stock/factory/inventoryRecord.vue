<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>库存记录 - {{ currentMaterial?.ProductName }}</span>
        <el-button @click="goBack">返回列表</el-button>
      </div>
    </template>

    <!-- 库存概览 -->
    <el-row :gutter="20" class="overview-section">
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">当前库存</div>
            <div class="overview-value">{{ currentMaterial?.Quantity || 0 }}</div>           
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">预警数量</div>
            <div class="overview-value warning">{{ currentMaterial?.WarningThreshold || 0 }}</div>           
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">本月入库</div>
            <div class="overview-value success">{{ monthlyStats.inbound || 0 }}</div>
            <div class="overview-unit">{{ currentMaterial?.unit || '' }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">本月出库</div>
            <div class="overview-value danger">{{ monthlyStats.outbound || 0 }}</div>
            <div class="overview-unit">{{ currentMaterial?.unit || '' }}</div>
          </div>
        </el-card>
      </el-col>
    </el-row>

    <!-- 搜索条件 -->
    <el-form :model="queryForm" :inline="true" class="search-form">
      <el-form-item label="调整类型">
        <el-select v-model="queryForm.adjustType" placeholder="请选择类型" clearable style="width: 120px;">
          <el-option label="生产入库" value="1" />
          <el-option label="发货出库" value="2" />
          <el-option label="退货" value="3" />
          <el-option label="损耗" value="4" />
        </el-select>
      </el-form-item>      
      <el-form-item label="时间范围">
        <el-date-picker
          v-model="queryForm.dateRange"
          type="daterange"
          range-separator="至"
          start-placeholder="开始日期"
          end-placeholder="结束日期"
          style="width: 240px;"
        />
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleQuery">查询</el-button>
        <el-button @click="resetQuery">重置</el-button>
      </el-form-item>
    </el-form>

    <!-- 记录列表 -->
    <el-table :data="recordList" border style="width: 100%" v-loading="loading">
      <el-table-column type="index" label="序号" width="80" />
      <el-table-column label="调整时间" width="150" align="center">
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
      <el-table-column label="调整前数量" width="120" align="center">
        <template #default="{ row }">
          <span class="quantity-before">{{ row.QuantityBefore }}</span>
        </template>
      </el-table-column>
      <el-table-column label="调整数量" width="120" align="center">
        <template #default="{ row }">
          <span :class="getQuantityClass(row.AdjustQuantity)">
            {{ row.AdjustQuantity > 0 ? '+' : '' }}{{ row.AdjustQuantity }}
          </span>
        </template>
      </el-table-column>
      <el-table-column label="调整后数量" width="120" align="center">
        <template #default="{ row }">
          <span class="quantity-after">{{ row.QuantityAfter }}</span>
        </template>
      </el-table-column>
      <el-table-column label="操作人" width="100" align="center">
        <template #default="{ row }">
          {{ row.operator || '系统' }}
        </template>
      </el-table-column>
      <el-table-column label="备注" min-width="200" show-overflow-tooltip>
        <template #default="{ row }">
          {{ row.remark || '-' }}
        </template>
      </el-table-column>
    </el-table>

    <!-- 分页 -->
    <div class="pagination-wrapper">
      <el-pagination
        v-model:current-page="currentPage"
        v-model:page-size="pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :background="background"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
      />
    </div>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import { getFactoryStockDetail, getFactoryStockLog } from '@/api/stock/factory/index'

// 定义事件
const emit = defineEmits(['change-scene'])

// 当前材料信息
const currentMaterial = ref<any>(null)

// 查询表单
const queryForm = reactive({
  adjustType: '',
  adjustReason: '',
  dateRange: []
})

// 记录列表
const recordList = ref<any[]>([])
const loading = ref(false)

// 月度统计
const monthlyStats = reactive({
  inbound: 0,
  outbound: 0
})

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 初始化记录
const initRecord = async (material: any) => {
  if (!material || !material.Id) return
  const res = await getFactoryStockDetail(material.Id)
  if (res && res.data) {
    currentMaterial.value = res.data
  } else {
    currentMaterial.value = material
  }
  handleQuery()
  loadMonthlyStats()
}

// 查询记录列表
const handleQuery = async () => {
  if (!currentMaterial.value || !currentMaterial.value.Id) return

  loading.value = true
  try {
    // 组装请求参数，符合后端新接口要求
    const params: any = {
      PageNumber: currentPage.value, // 当前页码
      PageSize: pageSize.value,      // 每页数量  
      FactoryId: currentMaterial.value.FactoryId || null, // 工厂ID
      ProductId: currentMaterial.value.ProductId || null, // 产品ID
      OperationType: queryForm.adjustReason ? Number(queryForm.adjustReason) : null, // 操作类型（筛选项）
      CreatedAtMin: '', // 开始时间
      CreatedAtMax: ''  // 结束时间
    }
    // 处理时间范围
    if (queryForm.dateRange && queryForm.dateRange.length === 2) {
      params.CreatedAtMin = queryForm.dateRange[0]
      params.CreatedAtMax = queryForm.dateRange[1]
    }
    // 调用API获取数据
    const res = await getFactoryStockLog(params)
    recordList.value = res.data?.items || res.data || []
    total.value = res.data?.total || recordList.value.length
  } catch (error) {
    ElMessage.error('获取库存记录失败')
    recordList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 加载月度统计
const loadMonthlyStats = async () => {
  try {
    // TODO: 调用月度统计API
    monthlyStats.inbound = 100
    monthlyStats.outbound = 30
  } catch (error) {
    console.error('加载月度统计错误:', error)
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.adjustType = ''
  queryForm.adjustReason = ''
  queryForm.dateRange = []
  currentPage.value = 1
  handleQuery()
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
  currentPage.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1
  handleQuery()
}

// 获取调整类型标签样式
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

.overview-section {
  margin-bottom: 20px;
}

.overview-card {
  .overview-item {
    text-align: center;
    
    .overview-label {
      font-size: 14px;
      color: #909399;
      margin-bottom: 8px;
    }
    
    .overview-value {
      font-size: 24px;
      font-weight: bold;
      color: #409eff;
      margin-bottom: 4px;
      
      &.warning {
        color: #e6a23c;
      }
      
      &.success {
        color: #67c23a;
      }
      
      &.danger {
        color: #f56c6c;
      }
    }
    
    .overview-unit {
      font-size: 12px;
      color: #909399;
    }
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
</style> 