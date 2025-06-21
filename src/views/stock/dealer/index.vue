<template>
  <div class="app-container">
    <!-- 库存列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>经销商库存管理</span>
          <!-- <el-button type="primary" @click="addInventory">新增库存</el-button> -->
          <el-button type="success" @click="toStockCalcView">
            后台库存计算
          </el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="经销商名称">
          <el-select v-model="queryForm.dealerId" placeholder="请选择经销商" clearable style="width: 200px;">
            <el-option label="全部经销商" value="" />
            <el-option
              v-for="dealer in dealerList"
              :key="dealer.id"
              :label="dealer.name"
              :value="dealer.id"
            />
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
        <el-table-column prop="dealerName" label="经销商" width="150" show-overflow-tooltip />
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
        <el-table-column label="最后更新"  align="center">
          <template #default="{ row }">
            <div class="update-info">
              <div>{{ formatDate(row.lastUpdateTime) }}</div>
              <div class="update-user">{{ row.updateUser || '系统' }}</div>
            </div>
          </template>
        </el-table-column>
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
    <inventoryRecord ref="record" v-show="scene === 2" @change-scene="changeScene"></inventoryRecord>

    <!-- 后台库存计算视图 -->
    <el-card v-show="scene === 3" class="stock-calc-card" style="width: 100%;">
      <template #header>
        <div class="card-header">
          <span>后台库存计算</span>
          <el-button @click="backToList">返回</el-button>
        </div>
      </template>
      <el-form :model="stockCalcForm" ref="stockCalcFormRef" :inline="true" class="search-form">
        <el-form-item label="经销商">
          <el-select v-model="stockCalcForm.dealerId" placeholder="请选择经销商" clearable style="width: 200px;">
            <el-option label="全部经销商" value="" />
            <el-option
              v-for="dealer in dealerList"
              :key="dealer.id"
              :label="dealer.name"
              :value="dealer.id"
            />
          </el-select>
          <el-button v-if="stockCalcForm.dealerId" type="primary" style="margin-left: 16px;" @click="openStockManageDialog">管理库存</el-button>
        </el-form-item>
        <el-form-item v-if="stockCalcForm.dealerId">
          <div class="stock-horizontal-list">
            <div class="stock-item" v-for="item in productStockList" :key="item.skuId">
              <div class="stock-title">{{ item.name }}</div>
              <div class="stock-value">{{ item.stock }}</div>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="商品明细" style="width: 100%; display: block;">
          <el-table :data="productList" border style="width: 100%;">
            <el-table-column prop="skuId" label="商品">
              <template #default="{ row }">
                <span>{{ row.name }}</span>
              </template>
            </el-table-column>
            <el-table-column label="数量" width="120">
              <template #default="{ $index }">
                <el-input v-model="productInputQuantities[$index]" type="number" min="0" style="width: 100px;" placeholder="请输入数量" />
              </template>
            </el-table-column>
            <el-table-column label="邮费" width="120">
              <template #default="{ $index }">
                <el-input v-if="productList[$index].skuId == 5" v-model="productInputPostages[$index]" type="number" min="0" step="0.01" style="width: 100px;" placeholder="请输入邮费" />
                <span v-else>-</span>
              </template>
            </el-table-column>
          </el-table>
        </el-form-item>
        <!-- 计算/返回按钮单独一行 -->
        <el-form-item>
          <el-button type="primary" @click="calcStock">计算</el-button>
          <el-button @click="backToList">返回</el-button>
        </el-form-item>
      </el-form>
      <div v-if="stockCalcLoading" class="loading-wrapper">
        <el-alert
          title="计算中..."
          type="info"
          show-icon
          :closable="false"
        >
        </el-alert>
      </div>
      <div v-if="stockCalcResult.length > 0" class="result-wrapper">
        <el-alert
          title="计算结果"
          type="success"
          show-icon
          :closable="false"
        >
          <div v-html="stockCalcResultText"></div>
        </el-alert>
        <div class="copy-btn-wrapper">
          <el-button type="primary" @click="copyStockCalcResult">一键复制</el-button>
        </div>
      </div>
    </el-card>

    <!-- 库存管理弹窗 -->
    <el-dialog v-model="showStockManageDialog" title="库存管理" width="50%" :before-close="closeStockManageDialog">
      <el-table :data="productStockList" border style="width: 100%;">
        <el-table-column prop="skuId" label="商品">
          <template #default="{ row }">
            <span>{{ row.name }}</span>
          </template>
        </el-table-column>
        <el-table-column label="库存" width="120">
          <template #default="{ row }">
            <el-input v-model="stockManageEditValues[row.skuId]" type="number" min="0" style="width: 100px;" placeholder="请输入库存" />
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="closeStockManageDialog">取消</el-button>
          <el-button type="primary" @click="saveAllStockManageEdit">保存</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import inventoryRecord from './inventoryRecord.vue'
import { HTStock, HTStockList, HTStockUpdate } from '@/api/stock/dealer/index'

// 场景值：0-数据展示，1-库存编辑，2-库存记录，3-后台库存计算
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  dealerId: '',
  productName: '',
  stockStatus: ''
})

// 库存列表
const inventoryList = ref<any[]>([])
const loading = ref(false)

// 经销商列表
const dealerList = ref<any[]>([])

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)
const background = ref(true)

// 获取子组件实例
const record = ref()

// 后台库存计算表单
const stockCalcForm = reactive({
  dealerId: '',
  items: [] as { skuId: string | number, quantity: string | number, userInputPostage?: number }[]
})

// 计算结果
const stockCalcLoading = ref(false)
const stockCalcResult = ref<string[]>([])
const stockCalcResultText = ref('')
const stockCalcResultCopyText = ref('')

// 商品列表mock数据
const productList = ref([
  { skuId: 1, name: '家庭套' },
  { skuId: 2, name: '家庭套（新疆西藏）' },
  { skuId: 3, name: '特惠9件套' },
  { skuId: 4, name: '洗衣液' },
  { skuId: 5, name: '洗衣液（整箱）' },
  { skuId: 6, name: '洗脸巾' },
  { skuId: 7, name: '3瓶装洗护' },
  { skuId: 8, name: '4瓶装洗护' }  
])

// 商品输入数量数组
const productInputQuantities = ref<number[]>([])
// 商品邮费输入数组
const productInputPostages = ref<(string|number)[]>([])

// 新增：库存管理弹窗相关变量
const showStockManageDialog = ref(false)
const stockManageEditRows = ref<{ [skuId: string]: boolean }>({})
const stockManageEditValues = ref<{ [skuId: string]: string }>({})

// 商品库存数组（skuId: 库存）
const productStocks = ref<{ [skuId: string]: number }>({})
// 新增：商品库存列表（后端回传的所有商品及库存）
const productStockList = ref<{ skuId: number|string, name: string, stock: number }[]>([])

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
          productName: 'iPhone 15 Pro',
          productCode: 'IP15P001',
          specification: '256GB 深空黑色',
          dealerName: '羊羊羊经销商',
          quantity: 50,
          unit: '台',
          warningQuantity: 10,
          lastUpdateTime: '2024-01-15 14:30:00',
          updateUser: '张三'
        },
        {
          id: '2',
          productName: 'MacBook Pro 14',
          productCode: 'MBP14001',
          specification: 'M3 Pro 1TB',
          dealerName: '牛牛牛经销商',
          quantity: 5,
          unit: '台',
          warningQuantity: 10,
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
  queryForm.dealerId = ''
  queryForm.productName = ''
  queryForm.stockStatus = ''
  currentPageNo.value = 1
  handleQuery()
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
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 计算库存
const calcStock = async () => {
  if (!stockCalcForm.dealerId) {
    ElMessage.warning('请选择经销商')
    return
  }
  // 组装请求参数，所有商品都提交，包括数量为0
  const items = productList.value.map((p, idx) => {
    const quantity = Number(productInputQuantities.value[idx])
    const item: any = {
      skuId: p.skuId,
      quantity
    }
    // 洗衣液（整箱）邮费
    if (p.skuId === 5 && productInputPostages.value[idx]) {
      item.userInputPostage = Number(productInputPostages.value[idx])
    }
    return item
  })
  // 不再过滤数量为0的商品
  // if (items.length === 0) {
  //   ElMessage.warning('请至少填写一个商品数量')
  //   return
  // }
  stockCalcLoading.value = true
  try {
    const res = await HTStock({
      dealerId: stockCalcForm.dealerId,
      items
    })
    stockCalcResult.value = res.data.data.details || []
    stockCalcResultText.value = stockCalcResult.value.join('<br />')
    stockCalcResultCopyText.value = stockCalcResult.value.join('\n')
    // 新增：更新库存列表
    if (res.data.data.productStocks) {
      productStockList.value = res.data.data.productStocks
      const stockMap: { [skuId: string]: number } = {}
      res.data.data.productStocks.forEach((item: any) => {
        stockMap[item.skuId] = item.stock
      })
      productStocks.value = stockMap
    }
    ElMessage.success('计算成功')
  } catch (e) {
    ElMessage.error('计算失败')
  } finally {
    stockCalcLoading.value = false
  }
}

// 一键复制
const copyStockCalcResult = async () => {
  try {
    await navigator.clipboard.writeText(stockCalcResultCopyText.value)
    ElMessage.success('已复制到剪贴板')
  } catch {
    ElMessage.error('复制失败')
  }
}

// 切换到库存计算视图
const toStockCalcView = () => {
  scene.value = 3
  stockCalcForm.dealerId = ''
  stockCalcForm.items = []
  stockCalcResult.value = []
  stockCalcResultText.value = ''
  stockCalcResultCopyText.value = ''
}

// 返回库存列表
const backToList = () => {
  scene.value = 0
}

// 打开库存管理弹窗
const openStockManageDialog = () => {
  showStockManageDialog.value = true
  stockManageEditRows.value = {}
  stockManageEditValues.value = {}
  productStockList.value.forEach(p => {
    stockManageEditValues.value[p.skuId] = String(p.stock ?? '')
  })
}

// 关闭弹窗
const closeStockManageDialog = () => {
  showStockManageDialog.value = false
}

// 保存所有库存
const saveAllStockManageEdit = async () => {
  try {
    const updateList = productStockList.value.map(row => ({
      skuId: row.skuId,
      name: row.name,
      stock: Number(stockManageEditValues.value[row.skuId])
    }))
    // 逐条调用接口（如有批量接口可优化）
    for (const item of updateList) {
      await HTStockUpdate(stockCalcForm.dealerId, item)
    }
    ElMessage.success('保存成功')
    showStockManageDialog.value = false
    // 刷新库存
    if (stockCalcForm.dealerId) {
      const res = await HTStockList(stockCalcForm.dealerId)
      const stockMap: { [skuId: string]: number } = {}
      productStockList.value = res.data.data || []
      ;(res.data.data || []).forEach((item: any) => {
        stockMap[item.skuId] = item.stock
      })
      productStocks.value = stockMap
      productStockList.value.forEach(p => {
        stockManageEditValues.value[p.skuId] = String(productStocks.value[p.skuId] ?? '')
      })
    }
  } catch {
    ElMessage.error('保存失败')
  }
}

// 切换经销商时自动查询所有商品库存
watch(() => stockCalcForm.dealerId, async (val) => {
  // 初始化输入数组
  productInputQuantities.value = productList.value.map(() => 0)
  productInputPostages.value = productList.value.map(() => '')
  // 查询库存
  if (val) {
    try {
      const res = await HTStockList(val)
      const stockMap: { [skuId: string]: number } = {}
      // 新增：赋值商品库存列表
      productStockList.value = res.data.data || []
      ;(res.data.data || []).forEach((item: any) => {
        stockMap[item.skuId] = item.stock
      })
      productStocks.value = stockMap
    } catch {
      productStocks.value = {}
      productStockList.value = []
    }
  } else {
    productStocks.value = {}
    productStockList.value = []
  }
})

// 初始化
onMounted(() => {
  // 加载经销商列表
  dealerList.value = [
    { id: '1', name: '段真真' },
    { id: '2', name: '宇佳佳' },
    { id: '3', name: '廖莎' },
    { id: '4', name: '熊华' },
    { id: '5', name: '王青' },
    { id: '6', name: '吴官秀' },    
    { id: '7', name: '郭志超' },
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

.product-info {
  .product-name {
    font-weight: bold;
    color: #303133;
    margin-bottom: 4px;
  }
  
  .product-code {
    font-size: 12px;
    color: #909399;
    margin-bottom: 2px;
  }
  
  .product-spec {
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

.loading-wrapper {
  margin-top: 20px;
  text-align: center;
}

.result-wrapper {
  margin-top: 20px;
  text-align: left;
}

.copy-btn-wrapper {
  display: flex;
  justify-content: center;
  margin-top: 12px;
}

.stock-calc-card {
  max-width: none;
  margin: 40px auto;
}

.stock-horizontal-list {
  display: flex;
  gap: 32px;
  margin-bottom: 12px;
}
.stock-item {
  text-align: center;
  min-width: 80px;
}
.stock-title {
  font-size: 14px;
  color: #666;
  margin-bottom: 4px;
}
.stock-value {
  font-size: 18px;
  font-weight: bold;
  color: #409eff;
}
</style>
