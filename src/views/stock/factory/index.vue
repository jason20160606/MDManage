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
          <el-select v-model="queryForm.factoryId" placeholder="请选择工厂" clearable style="width: 150px;" @change="handleFactoryChange" @clear="handleFactoryClear">           
            <el-option
              v-for="factory in factoryList"
              :key="factory.Id"
              :label="factory.Name"
              :value="factory.Id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="产品名称">
          <el-input v-model="queryForm.productName" placeholder="请输入产品名称" clearable style="width: 200px;" />
        </el-form-item>        
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 库存列表 -->
      <el-table :data="inventoryList" border style="width: 100%" v-loading="loading">
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column prop="ProductName" label="产品名称" min-width="200"></el-table-column>
        <el-table-column prop="FactoryName" label="工厂名称" width="120" show-overflow-tooltip />
        <el-table-column label="库存数量" width="120" align="center">
          <template #default="{ row }">
            <div class="stock-info">
              <span class="stock-quantity">{{ row.Quantity }}</span>              
            </div>
          </template>
        </el-table-column>
        <el-table-column label="库存状态" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getStockStatusType(row.Quantity, row.WarningThreshold)">
              {{ getStockStatusText(row.Quantity, row.WarningThreshold) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="预警数量" width="100" align="center">
          <template #default="{ row }">
            <span class="warning-quantity">{{ row.WarningThreshold || 0 }}</span>
          </template>
        </el-table-column>
        <el-table-column label="锁定数量" width="100" align="center">
          <template #default="{ row }">
            <span class="locked-quantity">{{ row.LockedQuantity || 0 }}</span>
          </template>
        </el-table-column>        
        <el-table-column label="最后更新时间" width="150" align="center">
          <template #default="{ row }">
            <div class="update-info">
              <div>{{ formatDateTime(row.UpdatedAt) }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="250" fixed="right">
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

    <!-- 库存编辑对话框 -->
    <inventoryForm ref="inventory" v-show="scene === 1" :factory-list="factoryList" @change-scene="changeScene"></inventoryForm>

    <!-- 库存记录对话框 -->
    <inventoryRecord ref="record" v-show="scene === 2" @change-scene="changeScene"></inventoryRecord>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import inventoryForm from './inventoryForm.vue'
import inventoryRecord from './inventoryRecord.vue'
import { getFactorySockList } from '@/api/stock/factory/index'
import { getFactoryList } from '@/api/stock/factory/index' // 假设有此接口

// 场景值：0-数据展示，1-库存编辑，2-库存记录
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  factoryId: '',
  productName: '',
  stockStatus: ''
})

// 工厂列表
const factoryList = ref<any[]>([])
// 库存列表
const inventoryList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 获取子组件实例
const inventory = ref()
const record = ref()

// 查询工厂列表
const loadFactoryList = async () => {
  // 防止重复请求
  if (factoryList.value.length > 0) {
    return
  }
  
  try {
    const res = await getFactoryList()
    factoryList.value = res.data || []
    // 新增：如果有工厂，默认选中第一个并请求库存
    if (factoryList.value.length > 0) {
      queryForm.factoryId = factoryList.value[0].Id
      handleQuery()
    }
  } catch (error) {
    console.error('获取工厂列表失败:', error)
    factoryList.value = []
  }
}

// 查询库存列表
const handleQuery = async () => {
  loading.value = true
  try {
    const params: any = {
      FactoryId: queryForm.factoryId,
      ProductName: queryForm.productName,
      PageNumber: currentPage.value,
      PageSize: pageSize.value
    }
    // 可根据需要添加库存状态等参数
    const result = await getFactorySockList(params)
    console.log(result.data)
    inventoryList.value = result.data || []
    console.log(inventoryList)
    if (result.headers && result.headers['x-pagination']) {
                const pagination = JSON.parse(result.headers['x-pagination'])
                currentPage.value = pagination.PageIndex || 1
                pageSize.value = pagination.PageSize || 10
                total.value = pagination.TotalCount || 0
            } else {
                total.value = inventoryList.value.length
            }
  } catch (error) {
    ElMessage.error('获取库存列表失败')
    inventoryList.value = []
    total.value = 0
  } finally {
    loading.value = false
  }
}

// 工厂选择变化处理
const handleFactoryChange = () => {
  // 如果工厂ID被清空，直接返回，不请求
  if (!queryForm.factoryId) {
    return
  }
  // 重置到第一页
  currentPage.value = 1
  // 自动查询该工厂的库存数据
  handleQuery()
}

// 重置查询
const resetQuery = () => {
  queryForm.factoryId = ''
  queryForm.productName = ''
  queryForm.stockStatus = ''
  currentPage.value = 1
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
const editInventory = async (row: any) => {
  scene.value = 1
  await nextTick()
  await inventory.value?.initForm(row)
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

// 子组件自定义事件 - 切换场景
const changeScene = (num: number) => {
  scene.value = num
  if (num === 0) {
    handleQuery()
  }
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

// 工厂下拉框清空处理
const handleFactoryClear = () => {
  queryForm.factoryId = ''
  inventoryList.value = []
  total.value = 0
}

// 初始化
onMounted(() => {
  loadFactoryList()
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

.locked-quantity {
  color: #f56c6c;
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
