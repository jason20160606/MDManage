<template>
  <div class="app-container">
    <!-- 库存列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>工厂库存管理</span>
          <el-button type="primary" @click="addInventory">
            新增库存
          </el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">        
        <el-form-item label="工厂名称">
          <el-select v-model="queryForm.warehouseLocation" placeholder="请选择仓库" clearable style="width: 150px;">
            <el-option label="全部仓库" value="" />
            <el-option
              v-for="warehouse in warehouseList"
              :key="warehouse.id"
              :label="warehouse.name"
              :value="warehouse.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="产品名称">
          <el-input v-model="queryForm.warehouseLocation" placeholder="请输入产品名称" clearable style="width: 200px;" />          
        </el-form-item>
        <el-form-item label="库存状态">
          <el-select v-model="queryForm.stockStatus" placeholder="请选择状态" clearable style="width: 120px;">
            <el-option label="充足" :value="'sufficient'" />
            <el-option label="不足" :value="'insufficient'" />
            <el-option label="缺货" :value="'out_of_stock'" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 库存列表 -->
      <el-table :data="inventoryList" border style="width: 100%" v-loading="loading">
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column label="产品信息" min-width="200">
          <template #default="{ row }">
            <div class="material-info">
              <div class="material-name">{{ row.materialName }}</div>
              <div class="material-code">编码: {{ row.materialCode }}</div>
              <div class="material-spec">规格: {{ row.specification }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="warehouseName" label="工厂名称" width="120" show-overflow-tooltip />
        <el-table-column label="库存数量" width="120" align="center">
          <template #default="{ row }">
            <div class="stock-info">
              <span class="stock-quantity">{{ row.quantity }}</span>
              <span class="stock-unit">{{ row.unit }}</span>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="库存状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStockStatusType(row.quantity, row.warningQuantity)">
              {{ getStockStatusText(row.quantity, row.warningQuantity) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="预警数量" width="100" align="center">
          <template #default="{ row }">
            <span class="warning-quantity">{{ row.warningQuantity || 0 }}</span>
          </template>
        </el-table-column>        
        <el-table-column label="最后更新" width="150" align="center">
          <template #default="{ row }">
            <div class="update-info">
              <div>{{ formatDateTime(row.lastUpdateTime) }}</div>
              <div class="update-user">{{ row.updateUser || '系统' }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="editInventory(row)">库存调整</el-button>
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

    <!-- 库存编辑对话框 -->
    <inventoryForm ref="inventory" v-show="scene === 1" @change-scene="changeScene"></inventoryForm>

    <!-- 库存记录对话框 -->
    <inventoryRecord ref="record" v-show="scene === 2" @change-scene="changeScene"></inventoryRecord>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import inventoryForm from './inventoryForm.vue'
import inventoryRecord from './inventoryRecord.vue'

// 场景值：0-数据展示，1-库存编辑，2-库存记录
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  materialName: '',
  warehouseLocation: '',
  stockStatus: ''
})

// 库存列表
const inventoryList = ref<any[]>([])
const loading = ref(false)

// 仓库列表
const warehouseList = ref<any[]>([])

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)
const background = ref(true)

// 获取子组件实例
const inventory = ref()
const record = ref()

// 查询库存列表
const handleQuery = async () => {
  loading.value = true
  try {
    // TODO: 调用库存列表API
    // const result = await reqInventoryList(queryForm)
    
    // 模拟数据
    setTimeout(() => {
      inventoryList.value = [
        {
          id: '1',
          materialName: '钢板',
          materialCode: 'F001',
          specification: 'Q235',
          warehouseName: 'A仓库',
          quantity: 500,
          unit: '吨',
          warningQuantity: 100,
          inboundDate: '2024-01-10',
          lastUpdateTime: '2024-01-15 14:30:00',
          updateUser: '张三'
        },
        {
          id: '2',
          materialName: '塑料颗粒',
          materialCode: 'F002',
          specification: 'HDPE',
          warehouseName: 'B仓库',
          quantity: 50,
          unit: '公斤',
          warningQuantity: 100,
          inboundDate: '2024-01-08',
          lastUpdateTime: '2024-01-14 16:20:00',
          updateUser: '李四'
        }
      ]
      total.value = inventoryList.value.length
      loading.value = false
    }, 500)
  } catch (error) {
    ElMessage.error('获取库存列表失败')
    console.error('库存查询错误:', error)
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.materialName = ''
  queryForm.warehouseLocation = ''
  queryForm.stockStatus = ''
  currentPageNo.value = 1
  handleQuery()
}

// 新增库存 - 切换到编辑场景，隐藏列表
const addInventory = () => {
  scene.value = 1
  nextTick(() => {
    inventory.value?.initForm()
  })
}

// 编辑库存 - 切换到编辑场景，隐藏列表
const editInventory = (row: any) => {
  scene.value = 1
  nextTick(() => {
    inventory.value?.initForm(row)
  })
}

// 查看库存记录 - 切换到记录场景，隐藏列表
const viewInventoryRecord = (row: any) => {
  scene.value = 2
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
      inputValue: row.warningQuantity || 0,
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
    
    // TODO: 调用设置预警API
    ElMessage.success('预警设置成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('设置预警失败')
    }
  }
}

// 删除库存 - 保持在列表场景，显示确认对话框
const deleteInventory = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除库存记录"${row.materialName}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    // TODO: 调用删除API
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
    }
  }
}

// 子组件自定义事件 - 切换场景
const changeScene = (num: number) => {
  scene.value = num
  if (num === 0) {
    handleQuery()
  }
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

// 获取库存状态类型
const getStockStatusType = (quantity: number, warningQuantity: number) => {
  if (quantity === 0) return 'danger'
  if (quantity <= warningQuantity) return 'warning'
  return 'success'
}

// 获取库存状态文本
const getStockStatusText = (quantity: number, warningQuantity: number) => {
  if (quantity === 0) return '缺货'
  if (quantity <= warningQuantity) return '不足'
  return '充足'
}

// 格式化日期
const formatDate = (dateStr: string) => {
  if (!dateStr) return ''
  return new Date(dateStr).toLocaleDateString('zh-CN')
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

// 初始化
onMounted(() => {
  // 加载仓库列表
  warehouseList.value = [
    { id: '1', name: 'A仓库' },
    { id: '2', name: 'B仓库' },
    { id: '3', name: 'C仓库' }
  ]
  
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

.pagination-wrapper {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.material-info {
  .material-name {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  
  .material-code {
    font-size: 12px;
    color: #909399;
    margin-bottom: 2px;
  }
  
  .material-spec {
    font-size: 12px;
    color: #606266;
  }
}

.stock-info {
  .stock-quantity {
    font-size: 16px;
    font-weight: bold;
    color: #409eff;
  }
  
  .stock-unit {
    font-size: 12px;
    color: #909399;
    margin-left: 4px;
  }
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
</style>
