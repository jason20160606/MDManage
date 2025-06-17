<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>库存记录 - {{ currentMaterial?.materialName }}</span>
        <el-button @click="goBack">返回列表</el-button>
      </div>
    </template>

    <!-- 库存概览 -->
    <el-row :gutter="20" class="overview-section">
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">当前库存</div>
            <div class="overview-value">{{ currentMaterial?.quantity || 0 }}</div>
            <div class="overview-unit">{{ currentMaterial?.unit || '' }}</div>
          </div>
        </el-card>
      </el-col>
      <el-col :span="6">
        <el-card shadow="hover" class="overview-card">
          <div class="overview-item">
            <div class="overview-label">预警数量</div>
            <div class="overview-value warning">{{ currentMaterial?.warningQuantity || 0 }}</div>
            <div class="overview-unit">{{ currentMaterial?.unit || '' }}</div>
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
          <el-option label="入库" value="in" />
          <el-option label="出库" value="out" />
          <el-option label="盘点调整" value="adjust" />
        </el-select>
      </el-form-item>
      <el-form-item label="调整原因">
        <el-select v-model="queryForm.adjustReason" placeholder="请选择原因" clearable style="width: 150px;">
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
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'

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
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)
const background = ref(true)

// 初始化记录
const initRecord = (material: any) => {
  currentMaterial.value = material
  handleQuery()
  loadMonthlyStats()
}

// 查询记录列表
const handleQuery = async () => {
  if (!currentMaterial.value) return
  
  loading.value = true
  try {
    // TODO: 调用库存记录API
    // const result = await reqInventoryRecordList({
    //   materialId: currentMaterial.value.id,
    //   ...queryForm
    // })
    
    // 模拟数据
    setTimeout(() => {
      recordList.value = [
        {
          id: '1',
          adjustTime: '2024-01-15 14:30:00',
          adjustType: 'in',
          adjustReason: 'normal_in',
          quantityBefore: 450,
          adjustQuantity: 50,
          quantityAfter: 500,
          operator: '张三',
          remark: '正常入库'
        },
        {
          id: '2',
          adjustTime: '2024-01-14 16:20:00',
          adjustType: 'out',
          adjustReason: 'normal_out',
          quantityBefore: 500,
          adjustQuantity: -30,
          quantityAfter: 470,
          operator: '李四',
          remark: '生产领料'
        },
        {
          id: '3',
          adjustTime: '2024-01-10 09:15:00',
          adjustType: 'in',
          adjustReason: 'return_in',
          quantityBefore: 400,
          adjustQuantity: 50,
          quantityAfter: 450,
          operator: '王五',
          remark: '退货入库'
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