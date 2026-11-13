<template>
  <div class="app-container">
    <el-row :gutter="12">
      <!-- 左侧：工厂 -->
      <el-col :span="7">
        <el-card class="panel" shadow="never">
          <template #header>
            <div class="card-header">
              <span>工厂</span>
              <el-button type="primary" size="small" @click="openFactoryDialog()">新增工厂</el-button>
            </div>
          </template>

          <div class="factory-list" v-loading="loading">
            <div
              v-for="f in factories"
              :key="f.Id"
              class="factory-item"
              :class="{ active: currentFactoryId === f.Id }"
              @click="selectFactory(f.Id)"
            >
              <div class="factory-info">
                <div class="factory-name">{{ f.Name }}</div>
                <div class="factory-sub">
                  {{ f.ContactPerson || '未填负责人' }} · {{ warehouseCount(f.Id) }} 个仓
                </div>
              </div>
              <div class="factory-ops" @click.stop>
                <el-button link type="primary" size="small" @click="openFactoryDialog(f)">编辑</el-button>
                <el-button link type="danger" size="small" @click="removeFactory(f)">删除</el-button>
              </div>
            </div>

            <el-empty v-if="!loading && !factories.length" description="还没有工厂，先新增一个" :image-size="60" />
          </div>
        </el-card>
      </el-col>

      <!-- 右侧：该工厂下的仓库 -->
      <el-col :span="17">
        <el-card class="panel" shadow="never">
          <template #header>
            <div class="card-header">
              <span>
                仓库
                <span v-if="currentFactory" class="header-sub">— {{ currentFactory.Name }}</span>
              </span>
              <el-button type="primary" size="small" :disabled="!currentFactory" @click="openWarehouseDialog()">
                新增仓库
              </el-button>
            </div>
          </template>

          <el-table :data="currentWarehouses" border style="width: 100%" v-loading="loading">
            <el-table-column type="index" label="序号" width="70" align="center" />
            <el-table-column prop="Name" label="仓库名称" min-width="160" show-overflow-tooltip />
            <el-table-column prop="ContactPerson" label="负责人" width="110" />
            <el-table-column prop="ContactPhone" label="联系电话" width="140" />
            <el-table-column prop="Address" label="仓库地址" min-width="240" show-overflow-tooltip />
            <el-table-column label="操作" width="140" fixed="right" align="center">
              <template #default="{ row }">
                <el-button type="primary" link @click="openWarehouseDialog(row)">编辑</el-button>
                <el-button type="danger" link @click="removeWarehouse(row)">删除</el-button>
              </template>
            </el-table-column>
          </el-table>

          <el-empty
            v-if="currentFactory && !currentWarehouses.length"
            description="该工厂下还没有仓库"
            :image-size="70"
          />
          <el-empty v-if="!currentFactory" description="请先在左侧选择一个工厂" :image-size="70" />
        </el-card>
      </el-col>
    </el-row>

    <!-- 工厂编辑对话框 -->
    <el-dialog
      v-model="factoryDialogVisible"
      :title="factoryDialogType === 'add' ? '新增工厂' : '编辑工厂'"
      width="560px"
      :close-on-click-modal="false"
    >
      <el-form :model="factoryForm" ref="factoryFormRef" :rules="factoryRules" label-width="90px">
        <el-form-item label="工厂名称" prop="name">
          <el-input v-model="factoryForm.name" placeholder="如：广州" />
        </el-form-item>
        <el-form-item label="负责人" prop="contactPerson">
          <el-input v-model="factoryForm.contactPerson" placeholder="请输入负责人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contactPhone">
          <el-input v-model="factoryForm.contactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="工厂地址" prop="address">
          <el-input v-model="factoryForm.address" type="textarea" :rows="2" placeholder="请输入工厂地址" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="factoryDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="saving" @click="saveFactory">确 定</el-button>
      </template>
    </el-dialog>

    <!-- 仓库编辑对话框 -->
    <el-dialog
      v-model="warehouseDialogVisible"
      :title="warehouseDialogType === 'add' ? '新增仓库' : '编辑仓库'"
      width="560px"
      :close-on-click-modal="false"
    >
      <el-form :model="warehouseForm" ref="warehouseFormRef" :rules="warehouseRules" label-width="90px">
        <el-form-item label="所属工厂" prop="parentId">
          <el-select v-model="warehouseForm.parentId" placeholder="请选择所属工厂" style="width: 100%">
            <el-option v-for="f in factories" :key="f.Id" :label="f.Name" :value="f.Id" />
          </el-select>
        </el-form-item>
        <el-form-item label="仓库名称" prop="name">
          <el-input v-model="warehouseForm.name" placeholder="如：广州-1号仓" />
        </el-form-item>
        <el-form-item label="负责人" prop="contactPerson">
          <el-input v-model="warehouseForm.contactPerson" placeholder="请输入负责人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="contactPhone">
          <el-input v-model="warehouseForm.contactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="仓库地址" prop="address">
          <el-input v-model="warehouseForm.address" type="textarea" :rows="2" placeholder="请输入仓库地址" />
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="warehouseDialogVisible = false">取 消</el-button>
        <el-button type="primary" :loading="saving" @click="saveWarehouse">确 定</el-button>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { getList } from '@/utils/request'
import { ref, reactive, computed, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqGetFactoryList, reqAddFactory, reqUpdateFactory, reqDeleteFactory } from '@/api/organization/factory'

defineOptions({ name: 'WarehouseManage' })

const loading = ref(false)
const saving = ref(false)
const allRows = ref<any[]>([])
const currentFactoryId = ref<number | null>(null)

// 工厂 = parent_id 为空的行；仓库 = parent_id 有值的行
const factories = computed(() => allRows.value.filter((r) => !r.ParentId))
const warehouses = computed(() => allRows.value.filter((r) => !!r.ParentId))
const currentFactory = computed(() => factories.value.find((f) => f.Id === currentFactoryId.value) || null)
const currentWarehouses = computed(() => warehouses.value.filter((w) => w.ParentId === currentFactoryId.value))

const warehouseCount = (factoryId: number) => warehouses.value.filter((w) => w.ParentId === factoryId).length

const loadAll = async () => {
  loading.value = true
  try {
    const res = await reqGetFactoryList({})
    const arr = getList(res)
    allRows.value = arr
    // 保持当前选中，选中失效则回落到第一个工厂
    const stillExists = arr.some((r: any) => !r.ParentId && r.Id === currentFactoryId.value)
    if (!stillExists) {
      currentFactoryId.value = factories.value[0]?.Id ?? null
    }
  } catch (e) {
    console.error('加载工厂/仓库失败', e)
  } finally {
    loading.value = false
  }
}

const selectFactory = (id: number) => {
  currentFactoryId.value = id
}

/* ---------------- 工厂 ---------------- */
const factoryDialogVisible = ref(false)
const factoryDialogType = ref<'add' | 'edit'>('add')
const factoryFormRef = ref()
const factoryForm = reactive({
  id: 0,
  name: '',
  contactPerson: '',
  contactPhone: '',
  address: ''
})
const factoryRules = {
  name: [
    { required: true, message: '请输入工厂名称', trigger: 'blur' },
    { min: 2, max: 50, message: '工厂名称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  contactPhone: [{ pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }]
}

const openFactoryDialog = (row?: any) => {
  factoryDialogType.value = row ? 'edit' : 'add'
  Object.assign(factoryForm, {
    id: row?.Id ?? 0,
    name: row?.Name ?? '',
    contactPerson: row?.ContactPerson ?? '',
    contactPhone: row?.ContactPhone ?? '',
    address: row?.Address ?? ''
  })
  factoryDialogVisible.value = true
  factoryFormRef.value?.clearValidate()
}

const saveFactory = async () => {
  await factoryFormRef.value?.validate(async (valid: boolean) => {
    if (!valid) return
    saving.value = true
    try {
      const payload = {
        Name: factoryForm.name,
        ContactPerson: factoryForm.contactPerson,
        ContactPhone: factoryForm.contactPhone,
        Address: factoryForm.address
      }
      if (factoryDialogType.value === 'add') {
        await reqAddFactory(payload)
        ElMessage.success('工厂已新增')
      } else {
        await reqUpdateFactory(factoryForm.id, { Id: factoryForm.id, ...payload })
        ElMessage.success('工厂已更新')
      }
      factoryDialogVisible.value = false
      await loadAll()
    } catch (e) {
      // 失败提示由请求拦截器统一弹出
    } finally {
      saving.value = false
    }
  })
}

const removeFactory = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定删除工厂「${row.Name}」吗？该工厂下若还有仓库或商品，将无法删除。`,
      '删除确认',
      { type: 'warning' }
    )
  } catch {
    return
  }
  try {
    await reqDeleteFactory(row.Id)
    ElMessage.success('工厂已删除')
    if (currentFactoryId.value === row.Id) currentFactoryId.value = null
    await loadAll()
  } catch (e) {
    // 拦截器已提示
  }
}

/* ---------------- 仓库 ---------------- */
const warehouseDialogVisible = ref(false)
const warehouseDialogType = ref<'add' | 'edit'>('add')
const warehouseFormRef = ref()
const warehouseForm = reactive({
  id: 0,
  name: '',
  parentId: undefined as number | undefined,
  contactPerson: '',
  contactPhone: '',
  address: ''
})
const warehouseRules = {
  parentId: [{ required: true, message: '请选择所属工厂', trigger: 'change' }],
  name: [
    { required: true, message: '请输入仓库名称', trigger: 'blur' },
    { min: 2, max: 50, message: '仓库名称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  contactPhone: [{ pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }]
}

const openWarehouseDialog = (row?: any) => {
  warehouseDialogType.value = row ? 'edit' : 'add'
  Object.assign(warehouseForm, {
    id: row?.Id ?? 0,
    name: row?.Name ?? '',
    parentId: row?.ParentId ?? currentFactoryId.value ?? undefined,
    contactPerson: row?.ContactPerson ?? '',
    contactPhone: row?.ContactPhone ?? '',
    address: row?.Address ?? ''
  })
  warehouseDialogVisible.value = true
  warehouseFormRef.value?.clearValidate()
}

const saveWarehouse = async () => {
  await warehouseFormRef.value?.validate(async (valid: boolean) => {
    if (!valid) return
    saving.value = true
    try {
      const payload = {
        Name: warehouseForm.name,
        ParentId: warehouseForm.parentId,
        ContactPerson: warehouseForm.contactPerson,
        ContactPhone: warehouseForm.contactPhone,
        Address: warehouseForm.address
      }
      if (warehouseDialogType.value === 'add') {
        await reqAddFactory(payload)
        ElMessage.success('仓库已新增')
      } else {
        await reqUpdateFactory(warehouseForm.id, { Id: warehouseForm.id, ...payload })
        ElMessage.success('仓库已更新')
      }
      warehouseDialogVisible.value = false
      currentFactoryId.value = warehouseForm.parentId ?? currentFactoryId.value
      await loadAll()
    } catch (e) {
      // 拦截器已提示
    } finally {
      saving.value = false
    }
  })
}

const removeWarehouse = async (row: any) => {
  try {
    await ElMessageBox.confirm(`确定删除仓库「${row.Name}」吗？`, '删除确认', { type: 'warning' })
  } catch {
    return
  }
  try {
    await reqDeleteFactory(row.Id)
    ElMessage.success('仓库已删除')
    await loadAll()
  } catch (e) {
    // 拦截器已提示
  }
}

onMounted(loadAll)
</script>

<style scoped>
.panel {
  border-radius: 6px;
}
.card-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  font-weight: 600;
}
.header-sub {
  font-weight: 400;
  color: var(--el-text-color-secondary);
  font-size: 13px;
}
.factory-list {
  min-height: 320px;
}
.factory-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 10px 12px;
  border-radius: 6px;
  cursor: pointer;
  border: 1px solid transparent;
  transition: all 0.15s;
}
.factory-item:hover {
  background: var(--el-fill-color-light);
}
.factory-item.active {
  background: var(--el-color-primary-light-9);
  border-color: var(--el-color-primary-light-5);
}
.factory-name {
  font-weight: 600;
  font-size: 14px;
}
.factory-sub {
  margin-top: 4px;
  font-size: 12px;
  color: var(--el-text-color-secondary);
}
.factory-ops {
  white-space: nowrap;
}
</style>
