<template>
  <div class="app-container">
    <el-card class="calc-card" shadow="never">
      <template #header>
        <div class="card-header">
          <div class="card-title">
            <span class="title-text">后台库存计算</span>
            <el-tag size="small" type="info" effect="plain" round>本机浏览器存储</el-tag>
          </div>
          <span class="card-desc">填数量 → 计算 → 复制结果，库存余量自动更新</span>
        </div>
      </template>

      <!-- 顶部操作条 -->
      <div class="toolbar">
        <div class="toolbar-field">
          <span class="field-label">经销商</span>
          <el-select
            v-model="stockCalcForm.dealerId"
            placeholder="请选择经销商"
            clearable
            style="width: 220px;"
          >
            <el-option label="全部经销商" value="" />
            <el-option
              v-for="dealer in dealerList"
              :key="dealer.id"
              :label="dealer.name"
              :value="dealer.id"
            />
          </el-select>
          <el-button :disabled="!stockCalcForm.dealerId" @click="openStockManageDialog">
            管理库存
          </el-button>
        </div>
        <div class="toolbar-actions">
          <el-button
            link
            :disabled="totalQty === 0 && stockCalcResult.length === 0"
            @click="resetInputs"
          >
            清空
          </el-button>
          <el-button type="primary" :disabled="!stockCalcForm.dealerId" @click="calcStock">
            计算
          </el-button>
        </div>
      </div>

      <!-- 工作区：左商品明细 / 右当前余量 -->
      <div class="workspace">
        <section class="block">
          <div class="block-head">
            <span class="block-title">商品明细</span>
            <span class="block-desc">仅「洗衣液（整箱）」需填写邮费</span>
          </div>
          <el-table
            :data="productList"
            size="small"
            border
            class="calc-table"
            show-summary
            :summary-method="getTableSummary"
          >
            <el-table-column prop="SkuId" label="商品" min-width="180">
              <template #default="{ row }">
                <span class="sku-name">{{ row.Name }}</span>
              </template>
            </el-table-column>
            <el-table-column label="数量" width="140" align="center">
              <template #default="{ $index }">
                <el-input
                  v-model="productInputQuantities[$index]"
                  class="cell-input"
                  size="small"
                  type="number"
                  min="0"
                  placeholder="0"
                />
              </template>
            </el-table-column>
            <el-table-column label="邮费" width="140" align="center">
              <template #default="{ $index }">
                <el-input
                  v-if="productList[$index].SkuId == 5"
                  v-model="productInputPostages[$index]"
                  class="cell-input"
                  size="small"
                  type="number"
                  min="0"
                  step="0.01"
                  placeholder="请输入邮费"
                />
                <span v-else class="cell-empty">—</span>
              </template>
            </el-table-column>
          </el-table>
        </section>

        <aside class="stock-panel">
          <div class="block-head">
            <span class="block-title">当前库存余量</span>
            <span class="block-desc">计算后自动更新</span>
          </div>
          <div class="stock-box">
            <div class="stock-box-head">
              <span>商品</span>
              <span>余量</span>
            </div>
            <ul v-if="stockCalcForm.dealerId" class="stock-list">
              <li
                v-for="item in productStockList"
                :key="item.SkuId"
                class="stock-row"
                :class="{ 'is-zero': isZeroStock(item.Stock) }"
              >
                <span class="stock-name" :title="item.Name">{{ item.Name }}</span>
                <span class="stock-num">{{ item.Stock }}</span>
              </li>
            </ul>
            <div v-else class="panel-empty">选择经销商后显示余量</div>
            <div v-if="stockCalcForm.dealerId" class="panel-foot">可在「管理库存」里手动调整</div>
          </div>
        </aside>
      </div>

      <!-- 计算结果 -->
      <section v-if="stockCalcResult.length > 0" class="result-panel">
        <div class="result-head">
          <div class="result-title">
            <i class="result-dot"></i>
            计算结果
          </div>
          <el-button size="small" type="primary" plain @click="copyStockCalcResult">
            一键复制
          </el-button>
        </div>
        <div class="result-body">
          <p v-for="(line, idx) in stockCalcResult" :key="idx" class="result-line">{{ line }}</p>
        </div>
      </section>
      <div v-else-if="stockCalcForm.dealerId" class="calc-empty">
        填写左侧数量后点击「计算」，结果会显示在这里
      </div>
    </el-card>

    <!-- 库存管理弹窗 -->
    <el-dialog
      v-model="showStockManageDialog"
      title="库存管理"
      width="520px"
      :before-close="closeStockManageDialog"
    >
      <el-alert
        title="库存余量保存在本机浏览器，更换电脑或清除浏览器数据会丢失，建议定期导出备份。"
        type="warning"
        :closable="false"
        show-icon
        class="backup-tip"
      />
      <el-table :data="productStockList" size="small" border class="manage-table">
        <el-table-column label="商品" min-width="180">
          <template #default="{ row }">
            <span class="sku-name">{{ row.Name }}</span>
          </template>
        </el-table-column>
        <el-table-column label="库存" width="150" align="center">
          <template #default="{ row }">
            <el-input
              v-model="stockManageEditValues[row.SkuId]"
              class="cell-input"
              size="small"
              type="number"
              min="0"
              step="0.01"
              placeholder="请输入库存"
            />
          </template>
        </el-table-column>
      </el-table>
      <template #footer>
        <div class="dialog-footer">
          <div class="dialog-footer-left">
            <el-button link type="primary" @click="exportBackup">导出备份</el-button>
            <el-button link type="primary" @click="triggerImport">导入备份</el-button>
            <input
              ref="importInputRef"
              type="file"
              accept=".json,application/json"
              style="display: none;"
              @change="handleImportFile"
            />
          </div>
          <div>
            <el-button @click="closeStockManageDialog">取消</el-button>
            <el-button type="primary" @click="saveAllStockManageEdit">保存</el-button>
          </div>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { showError } from '@/utils/request'
import { ref, reactive, computed, watch } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Dec } from '@/utils/decimal'
import { BACKSTAGE_SKUS, calcBackstageStock, type CalcItem } from './calc'

// 经销商列表（保持与原页面一致的固定 7 个）
const dealerList = ref<any[]>([
  { id: '1', name: '段真真' },
  { id: '2', name: '宇佳佳' },
  { id: '3', name: '廖莎' },
  { id: '4', name: '熊华' },
  { id: '5', name: '王青' },
  { id: '6', name: '吴官秀' },
  { id: '7', name: '郭志超' }
])

/** 商品行直接来自算法配置表，避免两处维护 */
const productList = BACKSTAGE_SKUS.map(s => ({ SkuId: s.skuId, Name: s.name }))

const stockCalcForm = reactive({
  dealerId: ''
})

// 余量存本机浏览器：dealerId => { skuId => 字面量 }，字面量保留小数位（0.80 不能变成 0.8）
const STORAGE_KEY = 'backstage_stock_v1'
type StockBook = Record<string, Record<string, string>>

const readBook = (): StockBook => {
  try {
    const raw = localStorage.getItem(STORAGE_KEY)
    return raw ? JSON.parse(raw) : {}
  } catch {
    return {}
  }
}

const readStock = (dealerId: string): Record<string, string> => {
  const saved = readBook()[dealerId] || {}
  const out: Record<string, string> = {}
  BACKSTAGE_SKUS.forEach(s => {
    out[String(s.skuId)] = saved[String(s.skuId)] ?? '0'
  })
  return out
}

const writeStock = (dealerId: string, stock: Record<string, string>) => {
  const book = readBook()
  book[dealerId] = stock
  localStorage.setItem(STORAGE_KEY, JSON.stringify(book))
}

const toStockList = (stock: Record<string, string>) =>
  BACKSTAGE_SKUS.map(s => ({
    SkuId: s.skuId,
    Name: s.name,
    Stock: stock[String(s.skuId)] ?? '0'
  }))

const productInputQuantities = ref<number[]>(productList.map(() => 0))
const productInputPostages = ref<(string | number)[]>(productList.map(() => ''))
const productStockList = ref<{ SkuId: number; Name: string; Stock: string }[]>([])
const showStockManageDialog = ref(false)
const stockManageEditValues = ref<{ [SkuId: string]: string }>({})
const stockCalcResult = ref<string[]>([])
const stockCalcResultCopyText = ref('')
const importInputRef = ref<HTMLInputElement | null>(null)

/** 已填写数量合计，用于「清空」按钮可用性与合计行 */
const totalQty = computed(() =>
  productInputQuantities.value.reduce((sum, val) => sum + Number(val || 0), 0)
)

/** 余量为 0（或空）时弱化显示 */
const isZeroStock = (stock: string) => Number(stock || 0) === 0

// 切换经销商时重置输入并读取该经销商的余量
watch(() => stockCalcForm.dealerId, val => {
  productInputQuantities.value = productList.map(() => 0)
  productInputPostages.value = productList.map(() => '')
  productStockList.value = val ? toStockList(readStock(String(val))) : []
  stockCalcResult.value = []
  stockCalcResultCopyText.value = ''
})

const calcStock = () => {
  if (!stockCalcForm.dealerId) {
    ElMessage.warning('请选择经销商')
    return
  }
  const dealerId = String(stockCalcForm.dealerId)
  const items: CalcItem[] = productList.map((p, idx) => {
    const item: CalcItem = {
      skuId: p.SkuId,
      quantity: Number(productInputQuantities.value[idx] ?? 0)
    }
    if (p.SkuId === 5 && productInputPostages.value[idx]) {
      item.userInputPostage = Number(productInputPostages.value[idx])
    }
    return item
  })

  const result = calcBackstageStock(items, readStock(dealerId))
  writeStock(dealerId, result.stock)
  productStockList.value = toStockList(result.stock)
  stockCalcResult.value = result.details
  stockCalcResultCopyText.value = result.details.join('\n')
  ElMessage.success('计算成功')
}

/** 清空输入与结果，方便下一轮录入 */
const resetInputs = () => {
  productInputQuantities.value = productList.map(() => 0)
  productInputPostages.value = productList.map(() => '')
  stockCalcResult.value = []
  stockCalcResultCopyText.value = ''
}

const copyStockCalcResult = async () => {
  try {
    await navigator.clipboard.writeText(stockCalcResultCopyText.value)
    ElMessage.success('已复制到剪贴板')
  } catch (e) {
    showError(e, '复制失败')
  }
}

const openStockManageDialog = () => {
  if (!stockCalcForm.dealerId) {
    ElMessage.warning('请选择经销商')
    return
  }
  const list = toStockList(readStock(String(stockCalcForm.dealerId)))
  productStockList.value = list
  list.forEach(p => {
    stockManageEditValues.value[p.SkuId] = p.Stock
  })
  showStockManageDialog.value = true
}

const closeStockManageDialog = () => {
  showStockManageDialog.value = false
}

const saveAllStockManageEdit = () => {
  if (!stockCalcForm.dealerId) return
  const dealerId = String(stockCalcForm.dealerId)
  const stock: Record<string, string> = {}
  BACKSTAGE_SKUS.forEach(s => {
    // 走一遍 Decimal，保证存进去的是规范字面量（如 12.50 保留两位）
    stock[String(s.skuId)] = Dec.parse(stockManageEditValues.value[s.skuId] ?? '0').toString()
  })
  writeStock(dealerId, stock)
  productStockList.value = toStockList(stock)
  productStockList.value.forEach(p => {
    stockManageEditValues.value[p.SkuId] = p.Stock
  })
  ElMessage.success('保存成功')
  showStockManageDialog.value = false
}

const exportBackup = () => {
  try {
    const blob = new Blob([JSON.stringify(readBook(), null, 2)], { type: 'application/json' })
    const url = URL.createObjectURL(blob)
    const link = document.createElement('a')
    link.href = url
    link.download = `后台库存备份_${new Date().toISOString().slice(0, 10)}.json`
    link.click()
    URL.revokeObjectURL(url)
    ElMessage.success('已导出备份文件')
  } catch (e) {
    showError(e, '导出失败')
  }
}

const triggerImport = () => {
  importInputRef.value?.click()
}

const handleImportFile = async (event: Event) => {
  const input = event.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  try {
    const data = JSON.parse(await file.text())
    if (!data || typeof data !== 'object' || Array.isArray(data)) {
      throw new Error('备份文件格式不正确')
    }
    await ElMessageBox.confirm('导入会覆盖本机现有的库存余量，确定继续？', '导入备份', {
      type: 'warning',
      confirmButtonText: '确定导入',
      cancelButtonText: '取消'
    })
    localStorage.setItem(STORAGE_KEY, JSON.stringify(data))
    if (stockCalcForm.dealerId) {
      const list = toStockList(readStock(String(stockCalcForm.dealerId)))
      productStockList.value = list
      list.forEach(p => {
        stockManageEditValues.value[p.SkuId] = p.Stock
      })
    }
    ElMessage.success('导入成功')
  } catch (e: any) {
    // 取消确认框时 ElMessageBox reject 'cancel'，不算错误
    if (e === 'cancel' || e === 'close') return
    showError(e, '导入失败')
  } finally {
    input.value = ''
  }
}

// 合计行方法，Element Plus官方用法
function getTableSummary(param: any) {
  // param.columns: 所有列配置，param.data: 表格数据
  const sums: (string | number)[] = []
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

.calc-card {
  width: 100%;
  border-radius: 10px;
}

/* ---------- 卡片头 ---------- */
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.card-title {
  display: flex;
  align-items: center;
  gap: 10px;

  .title-text {
    font-size: 16px;
    font-weight: 600;
    color: var(--el-text-color-primary);
  }
}

.card-desc {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

/* ---------- 顶部操作条 ---------- */
.toolbar {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  flex-wrap: wrap;
  padding: 12px 14px;
  border-radius: 10px;
  background: var(--el-fill-color-lighter);
}

.toolbar-field {
  display: flex;
  align-items: center;
  gap: 10px;
}

.toolbar-actions {
  display: flex;
  align-items: center;
  gap: 6px;
}

.field-label {
  font-size: 13px;
  color: var(--el-text-color-regular);
}

/* ---------- 工作区 ---------- */
.workspace {
  display: grid;
  grid-template-columns: minmax(0, 1fr) 300px;
  gap: 20px;
  align-items: stretch;
  margin-top: 20px;
}

.block-head {
  display: flex;
  align-items: baseline;
  gap: 10px;
  margin-bottom: 12px;
}

.block-title {
  position: relative;
  padding-left: 10px;
  font-size: 14px;
  font-weight: 600;
  color: var(--el-text-color-primary);

  &::before {
    content: '';
    position: absolute;
    left: 0;
    top: 50%;
    transform: translateY(-50%);
    width: 3px;
    height: 14px;
    border-radius: 2px;
    background: var(--el-color-primary);
  }
}

.block-desc {
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

/* ---------- 表格 ---------- */
.calc-table {
  border-radius: 8px;
  overflow: hidden;

  :deep(.el-table__cell) {
    padding: 5px 0;
  }

  :deep(.el-table__footer .cell) {
    font-weight: 600;
  }
}

.sku-name {
  font-size: 13px;
  color: var(--el-text-color-primary);
}

.cell-empty {
  color: var(--el-text-color-placeholder);
}

/* 表格内数字输入：居中、隐藏原生上下箭头 */
.cell-input {
  width: 104px;

  :deep(.el-input__inner) {
    text-align: center;
    -moz-appearance: textfield;
    font-variant-numeric: tabular-nums;
  }

  :deep(.el-input__inner)::-webkit-outer-spin-button,
  :deep(.el-input__inner)::-webkit-inner-spin-button {
    -webkit-appearance: none;
    margin: 0;
  }
}

/* ---------- 库存余量侧栏 ---------- */
.stock-panel {
  display: flex;
  flex-direction: column;
  min-width: 0;
}

.stock-box {
  flex: 1;
  display: flex;
  flex-direction: column;
  border: 1px solid var(--el-border-color-lighter);
  border-radius: 10px;
  overflow: hidden;
  background: var(--el-bg-color);
}

.stock-box-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 34px;
  padding: 0 14px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
  background: var(--el-fill-color-lighter);
  border-bottom: 1px solid var(--el-border-color-lighter);
}

.stock-list {
  flex: 1;
  display: flex;
  flex-direction: column;
  margin: 0;
  padding: 0;
  list-style: none;
}

.stock-row {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 10px;
  padding: 0 14px;
  border-bottom: 1px dashed var(--el-border-color-lighter);

  &:last-child {
    border-bottom: none;
  }

  &.is-zero .stock-num {
    color: var(--el-text-color-placeholder);
    font-weight: 500;
  }
}

.stock-name {
  font-size: 13px;
  color: var(--el-text-color-regular);
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.stock-num {
  flex: none;
  font-size: 15px;
  font-weight: 600;
  color: var(--el-color-primary);
  font-variant-numeric: tabular-nums;
}

.panel-empty {
  padding: 40px 14px;
  text-align: center;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}

.panel-foot {
  padding: 9px 14px;
  font-size: 11px;
  color: var(--el-text-color-secondary);
  border-top: 1px solid var(--el-border-color-lighter);
  background: var(--el-fill-color-lighter);
}

/* ---------- 计算结果 ---------- */
.result-panel {
  margin-top: 22px;
  border: 1px solid var(--el-color-success-light-7);
  border-radius: 10px;
  overflow: hidden;
}

.result-head {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 12px;
  padding: 10px 16px;
  background: var(--el-color-success-light-9);
  border-bottom: 1px solid var(--el-color-success-light-7);
}

.result-title {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 14px;
  font-weight: 600;
  color: var(--el-text-color-primary);
}

.result-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  background: var(--el-color-success);
}

.result-body {
  padding: 14px 16px;
  background: var(--el-bg-color);
}

.result-line {
  margin: 0 0 6px;
  font-size: 13px;
  line-height: 1.8;
  color: var(--el-text-color-primary);
  word-break: break-all;
  font-variant-numeric: tabular-nums;

  &:last-child {
    margin-bottom: 0;
  }
}

.calc-empty {
  margin-top: 22px;
  padding: 22px 16px;
  text-align: center;
  font-size: 13px;
  color: var(--el-text-color-secondary);
  border: 1px dashed var(--el-border-color);
  border-radius: 10px;
}

/* ---------- 弹窗 ---------- */
.backup-tip {
  margin-bottom: 12px;
}

.manage-table {
  border-radius: 8px;
  overflow: hidden;
}

.dialog-footer {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.dialog-footer-left {
  display: flex;
  gap: 8px;
}

/* ---------- 响应式 ---------- */
@media (max-width: 1180px) {
  .workspace {
    grid-template-columns: minmax(0, 1fr);
  }

  .toolbar-actions {
    margin-left: auto;
  }

  /* 侧栏改为卡片网格，隐掉表头带 */
  .stock-box-head {
    display: none;
  }

  .stock-list {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(132px, 1fr));
    gap: 8px;
    padding: 12px;
  }

  .stock-row {
    flex: none;
    flex-direction: column;
    align-items: flex-start;
    gap: 2px;
    padding: 8px 10px;
    border: 1px solid var(--el-border-color-lighter);
    border-radius: 8px;
  }

  .stock-num {
    font-size: 16px;
  }
}

@media (max-width: 768px) {
  .app-container {
    padding: 12px;
  }

  .toolbar {
    align-items: flex-start;
  }

  .toolbar-actions {
    margin-left: auto;
  }
}
</style>
