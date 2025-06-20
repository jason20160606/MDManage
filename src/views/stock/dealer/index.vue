<template>
  <div class="app-container">
    <!-- 库存列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>经销商库存管理</span>
          <el-button type="primary" @click="addInventory">
            新增库存
          </el-button>
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
        </el-form-item>
        <el-form-item label="商品">
          <div style="display: flex; flex-wrap: nowrap; gap: 12px; align-items: center;">
            <el-select v-model="selectedProduct" placeholder="请选择商品" filterable style="width: 220px;">
              <el-option
                v-for="p in productList"
                :key="p.skuId"
                :label="p.name"
                :value="p.skuId"
              />
            </el-select>
            <el-input v-model="selectedQuantity" type="number" min="1" style="width: 120px;" placeholder="请输入数量" />
            <el-button type="primary" @click="addStockCalcItem">添加商品</el-button>
          </div>
        </el-form-item>
        <el-form-item label="商品明细" style="width: 100%; display: block;">
          <el-table :data="stockCalcForm.items" border style="width: 100%;">
            <el-table-column prop="skuId" label="商品">
              <template #default="{ row }">
                <span>{{ getProductName(row.skuId) }}</span>
              </template>
            </el-table-column>
            <el-table-column prop="quantity" label="数量" width="120" />
            <el-table-column label="操作" width="80">
              <template #default="{ row, index }">
                <el-button type="danger" link @click="removeStockCalcItem(index)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>
        </el-form-item>
        <!-- 计算/返回按钮单独一行 -->
        <el-form-item>
          <el-button type="primary" @click="calcStock">计算</el-button>
          <el-button @click="backToList">返回</el-button>
        </el-form-item>
        <!-- 经销商商品库存表格 -->
        <el-form-item label="经销商商品库存" v-if="stockCalcForm.dealerId" style="width: 100%; display: block;">
          <el-button type="primary" @click="fetchDealerStockList" :loading="dealerStockLoading" size="small">查询库存</el-button>
        </el-form-item>
        <el-form-item v-if="dealerStockList.length > 0" style="width: 100%; display: block;">
          <el-table :data="dealerStockList" border style="width: 100%;">
            <el-table-column prop="skuId" label="SKU ID" width="100" />
            <el-table-column prop="name" label="商品名称" width="400"/>
            <el-table-column label="当前库存" width="180">
              <template #default="{ row, $index }">
                <div v-if="dealerStockEditRow === $index">
                  <el-input v-model="dealerStockEditValue" size="small" style="width: 100px;" />
                  <el-button type="primary" size="small" @click="saveEditStock(row, $index)">保存</el-button>
                  <el-button size="small" @click="cancelEditStock">取消</el-button>
                </div>
                <div v-else>
                  <span>{{ row.stock }}</span>
                  <el-button type="text" size="small" @click="startEditStock(row, $index)">编辑</el-button>
                </div>
              </template>
            </el-table-column>
          </el-table>
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
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import inventoryForm from './inventoryForm.vue'
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
const inventory = ref()
const record = ref()

// 后台库存计算表单
const stockCalcForm = reactive({
  dealerId: '',
  items: [] as { skuId: string | number, quantity: string | number }[]
})

// 计算结果
const stockCalcLoading = ref(false)
const stockCalcResult = ref<string[]>([])
const stockCalcResultText = ref('')
const stockCalcResultCopyText = ref('')

// 商品列表mock数据
const productList = ref([
  { skuId: 1, name: '燕窝面膜10盒/1箱' },
  { skuId: 2, name: '冰膜10盒/1箱' },
  { skuId: 3, name: '烟酰胺面膜' },
  { skuId: 4, name: 'AI智颜面膜/3盒/箱' },
  { skuId: 5, name: '洗脸巾/30包/箱' },
  { skuId: 6, name: '24K金/水/6盒/箱' },
  { skuId: 7, name: '24K金/乳/6盒/箱' },
  { skuId: 8, name: '24K金/精华/6盒/箱' },
  { skuId: 9, name: '24K金/保湿霜/6盒/箱' },
  { skuId: 10, name: '氨基酸泡泡慕斯/7盒/箱' },
  { skuId: 11, name: '玻色因面霜/2盒/箱' },
  { skuId: 12, name: '抗皱面膜' },
  { skuId: 13, name: '抗皱眼霜9盒/箱' },
  { skuId: 14, name: '凝时抗皱焕肤套盒' },
  { skuId: 15, name: '抗皱水/4瓶装' },
  { skuId: 16, name: '抗皱精华/4瓶装' },
  { skuId: 17, name: '抗皱乳/4瓶装' },
  { skuId: 18, name: '抗皱霜/4瓶装' },
  { skuId: 19, name: '保湿抗皱喷雾9支/箱' },
  { skuId: 20, name: '抗皱眼贴/6盒/箱' },
  { skuId: 21, name: '蜜都舒缓修护柔肤套' },
  { skuId: 22, name: '贵妇膏2盒/箱' },
  { skuId: 23, name: '隔离' },
  { skuId: 24, name: '防晒霜/5瓶' },
  { skuId: 25, name: '防晒喷雾/5瓶' },
  { skuId: 26, name: '小安瓶30支装' },
  { skuId: 27, name: '气垫BB/5盒/箱' },
  { skuId: 28, name: '新款控油洗发' },
  { skuId: 29, name: '去屑洗发水' },
  { skuId: 30, name: '生姜洗发水' },
  { skuId: 31, name: '香氛洗发水' },
  { skuId: 32, name: '柔顺护发膜' },
  { skuId: 33, name: '沐浴露' },
  { skuId: 34, name: '邂逅时光嫩肤身体乳/12瓶/箱' },
  { skuId: 35, name: '牙膏/10盒/箱' },
  { skuId: 36, name: '洗衣液/10瓶/箱' },
  { skuId: 37, name: '内衣洗衣液' },
  { skuId: 38, name: '日用245mm卫生巾' },
  { skuId: 39, name: '夜用300mm卫生巾' },
  { skuId: 40, name: '特长夜用415mm卫生巾' },
  { skuId: 41, name: '蜜都安睡裤' },
  { skuId: 42, name: '护垫' },
  { skuId: 43, name: '玻尿酸' },
  { skuId: 44, name: '补水喷雾' },
  { skuId: 45, name: '油污净' },
  { skuId: 46, name: '洗洁精' },
  { skuId: 47, name: '脱毛膏' },
])

// 选择器绑定
const selectedProduct = ref('')
const selectedQuantity = ref('')

// 新增：经销商商品库存列表
const dealerStockList = ref<any[]>([])
const dealerStockLoading = ref(false)
const dealerStockEditRow = ref<number | null>(null)
const dealerStockEditValue = ref('')

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
      `确定要删除库存记录"${row.productName}"吗？`,
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
  return new Date(dateStr).toLocaleString('zh-CN', {
    year: 'numeric',
    month: '2-digit',
    day: '2-digit',
    hour: '2-digit',
    minute: '2-digit'
  })
}

// 添加商品到明细
const addStockCalcItem = () => {
  if (!selectedProduct.value || !selectedQuantity.value) {
    ElMessage.warning('请选择商品并填写数量')
    return
  }
  // 检查是否已添加
  if (stockCalcForm.items.some(i => i.skuId === selectedProduct.value)) {
    ElMessage.warning('该商品已添加')
    return
  }
  stockCalcForm.items.push({
    skuId: selectedProduct.value,
    quantity: selectedQuantity.value
  })
  selectedProduct.value = ''
  selectedQuantity.value = ''
}

// 删除商品明细
const removeStockCalcItem = (index: number) => {
  stockCalcForm.items.splice(index, 1)
}

// 计算库存
const calcStock = async () => {
  if (!stockCalcForm.dealerId || !stockCalcForm.items.length) {
    ElMessage.warning('请选择经销商并添加商品')
    return
  }
  stockCalcLoading.value = true
  try {
    const res = await HTStock({
      dealerId: stockCalcForm.dealerId,
      items: stockCalcForm.items.map(i => ({
        skuId: Number(i.skuId),
        quantity: Number(i.quantity)
      }))
    })
    stockCalcResult.value = res.data.data.details || []
    stockCalcResultText.value = stockCalcResult.value.join('<br />')
    stockCalcResultCopyText.value = stockCalcResult.value.join('\n')
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
  selectedProduct.value = ''
  selectedQuantity.value = ''
}

// 返回库存列表
const backToList = () => {
  scene.value = 0
}

// 获取商品名方法
const getProductName = (skuId: string | number) => {
  const p = productList.value.find(p => p.skuId == skuId)
  return p ? p.name : skuId
}

// 查询经销商商品库存
const fetchDealerStockList = async () => {
  if (!stockCalcForm.dealerId) {
    ElMessage.warning('请先选择经销商')
    return
  }
  dealerStockLoading.value = true
  try {
    const res = await HTStockList(stockCalcForm.dealerId)
    dealerStockList.value = (res.data.data || []).filter((item: any) => Number(item.stock) > 0)
  } catch (e) {
    ElMessage.error('获取库存失败')
  } finally {
    dealerStockLoading.value = false
  }
}

// 开始编辑库存
const startEditStock = (row: any, index: number) => {
  dealerStockEditRow.value = index
  dealerStockEditValue.value = row.stock
}

// 取消编辑
const cancelEditStock = () => {
  dealerStockEditRow.value = null
  dealerStockEditValue.value = ''
}

// 保存库存
const saveEditStock = async (row: any, index: number) => {
  try {
    await HTStockUpdate(stockCalcForm.dealerId, {
      skuId: row.skuId,
      name: row.name,
      stock: Number(dealerStockEditValue.value)
    })
    ElMessage.success('保存成功')
    dealerStockEditRow.value = null
    dealerStockEditValue.value = ''
    fetchDealerStockList()
  } catch {
    ElMessage.error('保存失败')
  }
}

// 监听经销商切换，清空库存表格
watch(() => stockCalcForm.dealerId, (val) => {
  dealerStockList.value = []
  dealerStockEditRow.value = null
  dealerStockEditValue.value = ''
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
</style>
