<template>
  <div class="app-container">
    <!-- 库存列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>仓库库存</span>
          <el-button type="primary" @click="openAddDialog">新增库存</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="仓库">
          <el-select
            v-model="queryForm.factoryId"
            placeholder="请选择仓库"
            clearable
            filterable
            style="width: 220px"
            @change="handleFactoryChange"
            @clear="handleFactoryClear"
          >
            <el-option
              v-for="w in warehouseList"
              :key="w.Id"
              :label="w.ParentName ? `${w.ParentName} / ${w.Name}` : w.Name"
              :value="w.Id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="品牌">
          <el-select
            v-model="queryForm.brandId"
            placeholder="全部品牌"
            clearable
            filterable
            style="width: 160px"
            @change="handleBrandChange"
            @clear="handleBrandChange"
          >
            <el-option v-for="b in brandOptions" :key="b.Id" :label="b.Name" :value="b.Id" />
          </el-select>
        </el-form-item>
        <el-form-item label="产品名称">
          <el-input v-model="queryForm.productName" placeholder="请输入产品名称" clearable style="width: 200px" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 库存列表 -->
      <el-table :data="inventoryList" border style="width: 100%" v-loading="loading">
        <el-table-column type="index" label="序号" width="70" align="center" />
        <el-table-column prop="ProductName" label="产品名称" min-width="190" show-overflow-tooltip />
        <el-table-column prop="BrandName" label="品牌" width="120" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.BrandName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="ParentFactoryName" label="所属工厂" width="110" show-overflow-tooltip>
          <template #default="{ row }">
            {{ row.ParentFactoryName || '-' }}
          </template>
        </el-table-column>
        <el-table-column prop="FactoryName" label="仓库" width="140" show-overflow-tooltip />
        <el-table-column label="库存数量" width="110" align="center">
          <template #default="{ row }">
            <span class="stock-quantity">{{ row.Quantity }}</span>
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
            {{ formatDateTime(row.UpdatedAt) }}
          </template>
        </el-table-column>
        <el-table-column label="操作" width="340" fixed="right" align="center">
          <template #default="{ row }">
            <el-button type="primary" link @click="editInventory(row)">库存调整</el-button>
            <el-button type="info" link @click="viewInventoryRecord(row)">库存记录</el-button>
            <el-button type="warning" link @click="setWarning(row)">设置预警</el-button>
            <el-button type="danger" link @click="removeStock(row)">删除</el-button>
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

    <!-- 库存编辑 -->
    <inventoryForm
      ref="inventory"
      v-show="scene === 1"
      :factory-list="warehouseList"
      @change-scene="changeScene"
    ></inventoryForm>

    <!-- 库存记录 -->
    <inventoryRecord ref="record" v-show="scene === 2" @change-scene="changeScene"></inventoryRecord>

    <!-- 新增库存 -->
    <el-dialog v-model="addDialogVisible" title="新增库存" width="520px" :close-on-click-modal="false">
      <el-form :model="addForm" label-width="100px">
        <el-form-item label="仓库" required>
          <el-select v-model="addForm.factoryId" style="width: 100%" @change="loadSkuOptions">
            <el-option
              v-for="w in warehouseList"
              :key="w.Id"
              :label="w.ParentName ? `${w.ParentName} / ${w.Name}` : w.Name"
              :value="w.Id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="商品" required>
          <el-select
            v-model="addForm.productId"
            filterable
            clearable
            :loading="skuLoading"
            placeholder="只列出该工厂下还没有库存的商品"
            style="width: 100%"
          >
            <el-option
              v-for="s in skuOptions"
              :key="s.Id"
              :label="s.BrandName ? `${s.BrandName} · ${s.Name}` : s.Name"
              :value="s.Id"
            />
          </el-select>
          <div v-if="!skuLoading && !skuOptions.length" class="form-tip">
            该工厂下没有可添加的商品：要么商品都已建过库存行，要么商品还没分配到这个工厂
          </div>
        </el-form-item>
        <el-form-item label="初始数量">
          <el-input-number v-model="addForm.quantity" :min="0" :precision="0" style="width: 100%" />
          <div class="form-tip">大于 0 时会同时写入一条“生产入库”流水</div>
        </el-form-item>
        <el-form-item label="预警数量">
          <el-input-number v-model="addForm.warningThreshold" :min="0" :precision="0" style="width: 100%" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="addForm.remark" type="textarea" :rows="2" placeholder="可留空" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="addDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="saving" @click="saveAdd">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import inventoryForm from './inventoryForm.vue'
import inventoryRecord from './inventoryRecord.vue'
import {
  getFactorySockList,
  getFactoryList,
  updateFactoryStockWarning,
  deleteFactoryStock,
  createFactoryStock,
  getAvailableSkus
} from '@/api/stock/factory/index'
import { reqGetBrandList } from '@/api/organization/company'

// 场景值：0-数据展示，1-库存编辑，2-库存记录
const scene = ref<number>(0)

const queryForm = reactive({
  factoryId: '' as any,
  brandId: undefined as number | undefined,
  productName: ''
})

// 仓库列表（含所属工厂 ParentName）
const warehouseList = ref<any[]>([])
// 品牌列表（SKU → SPU → 品牌）
const brandOptions = ref<any[]>([])
const inventoryList = ref<any[]>([])
const loading = ref(false)
const saving = ref(false)

const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

const inventory = ref()
const record = ref()
const queryFormRef = ref()

// 加载仓库列表：只保留 parent_id 有值的行
const loadFactoryList = async () => {
  try {
    const res = await getFactoryList()
    const arr = Array.isArray(res) ? res : res?.data || []
    warehouseList.value = arr.filter((r: any) => !!r.ParentId)
    if (warehouseList.value.length > 0) {
      const keep = warehouseList.value.some((w: any) => w.Id === queryForm.factoryId)
      if (!keep) queryForm.factoryId = warehouseList.value[0].Id
      handleQuery()
    }
  } catch (error) {
    warehouseList.value = []
  }
}

// 加载品牌列表，用于筛选
const loadBrandList = async () => {
  try {
    const res = await reqGetBrandList()
    brandOptions.value = Array.isArray(res) ? res : res?.data || []
  } catch (error) {
    brandOptions.value = []
  }
}

const handleQuery = async () => {
  if (!queryForm.factoryId) return
  loading.value = true
  try {
    const params: any = {
      FactoryId: queryForm.factoryId,
      ProductName: queryForm.productName,
      PageNumber: currentPage.value,
      PageSize: pageSize.value
    }
    if (queryForm.brandId) params.BrandId = queryForm.brandId
    const result = await getFactorySockList(params)
    inventoryList.value = result.data || []
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

const handleFactoryChange = () => {
  if (!queryForm.factoryId) return
  currentPage.value = 1
  handleQuery()
}

const handleBrandChange = () => {
  currentPage.value = 1
  handleQuery()
}

const resetQuery = () => {
  queryForm.productName = ''
  queryForm.brandId = undefined
  currentPage.value = 1
  handleQuery()
}

const handleFactoryClear = () => {
  queryForm.factoryId = ''
  inventoryList.value = []
  total.value = 0
}

const editInventory = async (row: any) => {
  scene.value = 1
  await nextTick()
  await inventory.value?.initForm(row)
}

const viewInventoryRecord = (row: any) => {
  scene.value = 2
  nextTick(() => {
    record.value?.initRecord(row)
  })
}

// 设置预警：必须带 FactoryId，否则多仓同一 SKU 会改错仓
const setWarning = async (row: any) => {
  try {
    const { value } = await ElMessageBox.prompt('请输入预警数量', '设置预警', {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      inputValue: row.WarningThreshold || 0,
      inputValidator: (value) => {
        if (value === '') return '预警数量不能为空'
        if (isNaN(Number(value)) || Number(value) < 0) return '请输入有效的数字'
        return true
      }
    })
    await updateFactoryStockWarning({
      FactoryId: row.FactoryId,
      ProductId: row.ProductId,
      WarningThreshold: Number(value)
    })
    ElMessage.success('预警设置成功')
    handleQuery()
  } catch (error) {
    // 取消或拦截器已提示
  }
}

/* ---------------- 新增库存 ---------------- */
const addDialogVisible = ref(false)
const skuLoading = ref(false)
const skuOptions = ref<any[]>([])
const addForm = reactive({
  factoryId: '' as any,
  productId: undefined as number | undefined,
  quantity: 0,
  warningThreshold: 0,
  remark: ''
})

const openAddDialog = async () => {
  if (!queryForm.factoryId) {
    ElMessage.warning('请先选择一个仓库')
    return
  }
  Object.assign(addForm, {
    factoryId: queryForm.factoryId,
    productId: undefined,
    quantity: 0,
    warningThreshold: 0,
    remark: ''
  })
  addDialogVisible.value = true
  await loadSkuOptions()
}

const loadSkuOptions = async () => {
  if (!addForm.factoryId) {
    skuOptions.value = []
    return
  }
  skuLoading.value = true
  try {
    const res = await getAvailableSkus(addForm.factoryId)
    skuOptions.value = Array.isArray(res) ? res : res?.data || []
    addForm.productId = undefined
  } catch (e) {
    skuOptions.value = []
  } finally {
    skuLoading.value = false
  }
}

const saveAdd = async () => {
  if (!addForm.productId) {
    ElMessage.warning('请选择商品')
    return
  }
  saving.value = true
  try {
    await createFactoryStock({
      FactoryId: addForm.factoryId,
      ProductId: addForm.productId,
      Quantity: addForm.quantity,
      WarningThreshold: addForm.warningThreshold,
      Remark: addForm.remark
    })
    ElMessage.success('已新增库存记录')
    addDialogVisible.value = false
    queryForm.factoryId = addForm.factoryId
    await handleQuery()
  } catch (e) {
    // 拦截器已提示
  } finally {
    saving.value = false
  }
}

const removeStock = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定删除「${row.FactoryName}」下「${row.ProductName}」的库存记录吗？只有库存和锁定量都为 0 才能删除。`,
      '删除确认',
      { type: 'warning' }
    )
  } catch {
    return
  }
  try {
    await deleteFactoryStock(row.Id)
    ElMessage.success('已删除')
    await handleQuery()
  } catch (e) {
    // 拦截器已提示
  }
}

const changeScene = (num: number) => {
  scene.value = num
  if (num === 0) handleQuery()
}

const handleCurrentChange = (page: number) => {
  currentPage.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1
  handleQuery()
}

const getStockStatusType = (quantity: number, warningQuantity: number) => {
  if (quantity === 0) return 'danger'
  if (warningQuantity > 0 && quantity <= warningQuantity) return 'warning'
  return 'success'
}

const getStockStatusText = (quantity: number, warningQuantity: number) => {
  if (quantity === 0) return '缺货'
  if (warningQuantity > 0 && quantity <= warningQuantity) return '不足'
  return '充足'
}

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

onMounted(() => {
  loadBrandList()
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

.stock-quantity {
  font-size: 15px;
  font-weight: bold;
  color: #409eff;
}

.warning-quantity {
  color: #e6a23c;
  font-weight: bold;
}

.locked-quantity {
  color: #f56c6c;
  font-weight: bold;
}

.form-tip {
  margin-top: 4px;
  font-size: 12px;
  color: #909399;
  line-height: 1.4;
}
</style>
