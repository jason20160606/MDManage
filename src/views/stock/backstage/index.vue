<template>
  <div class="app-container">
    <!-- 后台库存计算视图 -->
    <el-card class="stock-calc-card" style="width: 100%;">
      <template #header>
        <div class="card-header">
          <span>后台库存计算</span>
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
            <div class="stock-item" v-for="item in productStockList" :key="item.SkuId">
              <div class="stock-title">{{ item.Name }}</div>
              <div class="stock-value">{{ item.Stock }}</div>
            </div>
          </div>
        </el-form-item>
        <el-form-item label="商品明细" style="width: 100%; display: block;">
          <el-table :data="productList"  border style="width: 100%;"
            show-summary
            :summary-method="getTableSummary"
          >
            <el-table-column prop="SkuId" label="商品">
              <template #default="{ row }">
                <span>{{ row.Name }}</span>
              </template>
            </el-table-column>
            <el-table-column label="数量" width="120">
              <template #default="{ $index }">
                <el-input v-model="productInputQuantities[$index]" type="number" min="0" style="width: 100px;" placeholder="请输入数量" />
              </template>
            </el-table-column>
            <el-table-column label="邮费" width="120">
              <template #default="{ $index }">
                <el-input v-if="productList[$index].SkuId == 5" v-model="productInputPostages[$index]" type="number" min="0" step="0.01" style="width: 100px;" placeholder="请输入邮费" />
                <span v-else>-</span>
              </template>
            </el-table-column>
          </el-table>
        </el-form-item>
        <!-- 计算/返回按钮单独一行 -->
        <el-form-item>
          <el-button type="primary" @click="calcStock">计算</el-button>
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
        <el-table-column label="商品">
          <template #default="{ row }">
            <span>{{ row.Name }}</span>
          </template>
        </el-table-column>
        <el-table-column label="库存" width="120">
          <template #default="{ row }">
            <el-input v-model="stockManageEditValues[row.SkuId]" type="number" min="0" style="width: 100px;" placeholder="请输入库存" />
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
import { ref, reactive, watch } from 'vue'
import { ElMessage } from 'element-plus'
import { HTStock, HTStockList, HTStockUpdate } from '@/api/stock/backstage/index'

// 经销商列表（本地写死或后续可改为接口）
const dealerList = ref<any[]>([
  { id: '1', name: '段真真' },
  { id: '2', name: '宇佳佳' },
  { id: '3', name: '廖莎' },
  { id: '4', name: '熊华' },
  { id: '5', name: '王青' },
  { id: '6', name: '吴官秀' },
  { id: '7', name: '郭志超' },
])

const stockCalcForm = reactive({
  dealerId: '',
  items: [] as { skuId: string | number, quantity: string | number, userInputPostage?: number }[]
})

const productList = ref([
  { SkuId: 1, Name: '家庭套' },
  { SkuId: 2, Name: '家庭套（新疆西藏）' },
  { SkuId: 3, Name: '特惠9件套' },  
  { SkuId: 4, Name: '洗衣液' },
  { SkuId: 5, Name: '洗衣液（整箱）' },
  { SkuId: 6, Name: '洗脸巾' },
  { SkuId: 9, Name: '洗脸巾（新疆西藏）' },
  { SkuId: 7, Name: '3瓶装洗护' },
  { SkuId: 8, Name: '4瓶装洗护' }
])
const productInputQuantities = ref<number[]>([])
const productInputPostages = ref<(string|number)[]>([])
const productStockList = ref<{ SkuId: number|string, Name: string, Stock: number }[]>([])
const showStockManageDialog = ref(false)
const stockManageEditValues = ref<{ [SkuId: string]: string }>({})
const stockCalcLoading = ref(false)
const stockCalcResult = ref<string[]>([])
const stockCalcResultText = ref('')
const stockCalcResultCopyText = ref('')

// 工具函数：统一获取库存数组（直接用后端字段名 SkuId、Name、Stock）
function extractProductStocks(res: any) {
  return res.data?.productStocks || res.data?.data || res.data?.Data || res.data || []
}

// 切换经销商时自动查询所有商品库存
watch(() => stockCalcForm.dealerId, async (val) => {
  productInputQuantities.value = productList.value.map(() => 0)
  productInputPostages.value = productList.value.map(() => '')
  if (val) {
    try {
      const res = await HTStockList(val)
      productStockList.value = extractProductStocks(res)
    } catch {
      productStockList.value = []
    }
  } else {
    productStockList.value = []
  }
})

const calcStock = async () => {
  if (!stockCalcForm.dealerId) {
    ElMessage.warning('请选择经销商')
    return
  }
  const items = productList.value.map((p, idx) => {
    const quantity = Number(productInputQuantities.value[idx])
    const item: any = {
      skuId: p.SkuId,
      quantity
    }
    if (p.SkuId === 5 && productInputPostages.value[idx]) {
      item.userInputPostage = Number(productInputPostages.value[idx])
    }
    return item
  })
  stockCalcLoading.value = true
  try {
    const res = await HTStock({
      dealerId: stockCalcForm.dealerId,
      items
    })
    if (res.data.Success) {
      stockCalcResult.value = res.data.Data.Details || []
      stockCalcResultText.value = stockCalcResult.value.join('<br />')
      stockCalcResultCopyText.value = stockCalcResult.value.join('\n')
      if (res.data.Data.ProductStocks) {
        productStockList.value = res.data.Data.ProductStocks
      }
      ElMessage.success(res.data.Message || '计算成功')
    } else {
      ElMessage.error(res.data.Message || '计算失败')
    }
  } catch (e) {
    ElMessage.error('计算失败')
  } finally {
    stockCalcLoading.value = false
  }
}

const copyStockCalcResult = async () => {
  try {
    await navigator.clipboard.writeText(stockCalcResultCopyText.value)
    ElMessage.success('已复制到剪贴板')
  } catch {
    ElMessage.error('复制失败')
  }
}

const openStockManageDialog = async () => {
  if (!stockCalcForm.dealerId) {
    ElMessage.warning('请选择经销商')
    return
  }
  try {
    const res = await HTStockList(stockCalcForm.dealerId)
    productStockList.value = extractProductStocks(res)
    productStockList.value.forEach(p => {
      stockManageEditValues.value[p.SkuId] = String(p.Stock ?? '')
    })
    showStockManageDialog.value = true
  } catch {
    ElMessage.error('获取库存失败')
  }
}

const closeStockManageDialog = () => {
  showStockManageDialog.value = false
}

const saveAllStockManageEdit = async () => {
  try {
    const updateList = productStockList.value.map(row => ({
      skuId: row.SkuId,
      name: row.Name,
      stock: Number(stockManageEditValues.value[row.SkuId])
    }))
    await HTStockUpdate(stockCalcForm.dealerId, updateList)
    ElMessage.success('保存成功')
    showStockManageDialog.value = false
    if (stockCalcForm.dealerId) {
      const res = await HTStockList(stockCalcForm.dealerId)
      productStockList.value = extractProductStocks(res)
      productStockList.value.forEach(p => {
        stockManageEditValues.value[p.SkuId] = String(p.Stock ?? '')
      })
    }
  } catch {
    ElMessage.error('保存失败')
  }
}


// 合计行方法，Element Plus官方用法
function getTableSummary(param: any) {
  // param.columns: 所有列配置，param.data: 表格数据
  const sums: (string|number)[] = []
  param.columns.forEach((column: any, index: number) => {
    if (index === 0) {
      sums[index] = '合计'
    } else if (column.label === '数量') {
      // 统计所有输入的数量
      const total = productInputQuantities.value.reduce((sum, val) => sum + Number(val || 0), 0)
      sums[index] = total
    } else {
      sums[index] = ''
    }
  })
  return sums
}
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
