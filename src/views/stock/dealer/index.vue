<template>
  <div class="app-container">
    <!-- 库存列表页面，仅在未打开库存记录时显示 -->
    <el-card v-if="!showRecord">
      <template #header>
        <div class="card-header">
          <span>经销商库存管理</span>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="经销商名称">
          <el-input v-model="queryForm.dealerName" placeholder="请输入经销商名称" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 库存列表 -->
      <el-table :data="mainDealerList" border style="width: 100%" v-loading="loading">
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column prop="Name" label="经销商" width="150" show-overflow-tooltip />
        <el-table-column label="库存" width="100" prop="Quota" align="center"></el-table-column>
        <el-table-column label="库存状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStockStatusType(row.Quota)">
              {{ getStockStatusText(row.Quota)}}
            </el-tag>
          </template>
        </el-table-column>        
        <el-table-column label="预警数量" width="100" align="center">

          <template #default="{ row }">
            <span class="warning-quantity">{{ row.warningQuantity || 10000 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="邮费" width="100" prop="Freight" align="center"></el-table-column>
        <el-table-column label="差价" width="100" prop="PriceDiff" align="center"></el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="info" link @click="viewInventoryRecord(row)">库存记录</el-button>
            <el-button type="warning" link @click="setWarning(row)">设置预警</el-button>
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

    <!-- 库存记录对话框 -->
    <inventoryRecord
      ref="record"
      v-if="showRecord"
      @change-scene="changeScene"
      @close="showRecord = false"
    ></inventoryRecord>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import inventoryRecord from './inventoryRecord.vue'
import { getDealerList } from '@/api/stock/dealer/index'

// 查询表单
const queryForm = reactive({
  dealerName: ''
})

// 主库存管理页面用
const mainDealerList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)
const background = ref(true)

// 获取子组件实例
const record = ref()

// 控制库存记录对话框显示
const showRecord = ref(false)
const currentRecordRow = ref<any>(null)

// 查询库存列表
const handleQuery = async () => {
  loading.value = true
  try {
    // 传递分页参数
    const params: any = {
      DealerName: queryForm.dealerName,
      PageNumber: currentPageNo.value,
      PageSize: pageSizeNo.value
    }
    const res = await getDealerList(params)
    mainDealerList.value = res.data || []
    // 处理分页信息
    if (res.headers && res.headers['x-pagination']) {
      const pagination = JSON.parse(res.headers['x-pagination'])
      currentPageNo.value = pagination.PageIndex || 1
      pageSizeNo.value = pagination.PageSize || 10
      total.value = pagination.TotalCount || 0
    } else {
      total.value = mainDealerList.value.length
    }
  } catch (error) {
    ElMessage.error('获取经销商列表失败')
    mainDealerList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.dealerName = ''
  currentPageNo.value = 1
  handleQuery()
}

// 分页事件处理
const handleCurrentChange = (page: number) => {
  currentPageNo.value = page
  handleQuery()
}
const handleSizeChange = (size: number) => {
  pageSizeNo.value = size
  currentPageNo.value = 1
  handleQuery()
}

// 查看库存记录
const viewInventoryRecord = (row: any) => {
  currentRecordRow.value = row
  showRecord.value = true
  nextTick(() => {
    record.value?.initRecord(row)
  })
}

// 设置预警
const setWarning = async (row: any) => {
  try {
    await ElMessageBox.prompt('请输入预警数量', '设置预警', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputValue: row.warningQuantity || 10000,
      inputValidator: (value) => {
        if (value === '') {
          return '预警数量不能为空'
        }
        if (isNaN(Number(value)) || Number(value) < 0) {
          return '请输入有效的数字'
        }
        return true
      }
    })
    ElMessage.success('预警设置成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('设置预警失败')
    }
  }
}

// 切换场景（如有需要可保留）
const changeScene = () => {
  handleQuery()
}

// 库存状态
const getStockStatusType = (quantity: number) => {
  if (quantity === 0) return 'danger'
  if (quantity <= 10000) return 'warning'
  return 'success'
}
const getStockStatusText = (quantity: number) => {
  if (quantity === 0) return '缺货'
  if (quantity <= 10000) return '不足'
  return '充足'
}

// 初始化
onMounted(() => {
  handleQuery()
})
</script>

<style lang="scss" scoped>
.app-container {
  padding: 20px;
}
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.search-form {
  margin-bottom: 20px;
}
.warning-quantity {
  color: #e6a23c;
  font-weight: bold;
}
.update-info {
  .update-user {
    font-size: 12px;
    color: #909399;
    margin-top: 2px;
  }
}
.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}
</style>
