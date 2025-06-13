<template>
  <div class="freight-container">
    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :inline="true" :model="searchForm" class="search-form">
        <el-form-item label="产品名称">
          <el-input v-model="searchForm.productName" placeholder="请输入产品名称" clearable />
        </el-form-item>
        <el-form-item label="产品编码">
          <el-input v-model="searchForm.productCode" placeholder="请输入产品编码" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="启用" value="1" />
            <el-option label="禁用" value="0" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="resetSearch">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 表格区域 -->
    <el-card class="table-card">
      <template #header>
        <div class="card-header">
          <span>运费规则列表</span>
          <el-button type="primary" @click="handleAdd">新增规则</el-button>
        </div>
      </template>

      <el-table
        :data="tableData"
        style="width: 100%"
        v-loading="loading"
      >
        <el-table-column prop="productCode" label="产品编码" width="120" />
        <el-table-column prop="productName" label="产品名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="specification" label="规格" width="120" />
        <el-table-column prop="unit" label="单位" width="80" />
        <el-table-column prop="freightRule" label="运费规则" width="200">
          <template #default="{ row }">
            <div v-if="row.freightRule === 'fixed'">
              固定运费：¥{{ row.freightAmount?.toFixed(2) }}
            </div>
            <div v-else-if="row.freightRule === 'weight'">
              按重量计费：¥{{ row.freightAmount?.toFixed(2) }}/kg
            </div>
            <div v-else-if="row.freightRule === 'quantity'">
              按数量计费：¥{{ row.freightAmount?.toFixed(2) }}/件
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="minFreight" label="最低运费" width="120">
          <template #default="{ row }">
            ¥{{ row.minFreight?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column prop="maxFreight" label="最高运费" width="120">
          <template #default="{ row }">
            ¥{{ row.maxFreight?.toFixed(2) }}
          </template>
        </el-table-column>
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === '1' ? 'success' : 'danger'">
              {{ row.status === '1' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" fixed="right" width="150">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button
              :type="row.status === '1' ? 'danger' : 'success'"
              link
              @click="handleToggleStatus(row)"
            >
              {{ row.status === '1' ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination-container">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :total="total"
          :page-sizes="[10, 20, 50, 100]"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 运费规则表单对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增运费规则' : '编辑运费规则'"
      width="600px"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="产品" prop="productId">
          <el-select
            v-model="form.productId"
            placeholder="请选择产品"
            :disabled="dialogType === 'edit'"
          >
            <el-option
              v-for="item in productOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            >
              <span>{{ item.name }}</span>
              <span class="product-info">
                ({{ item.code }} | {{ item.specification }})
              </span>
            </el-option>
          </el-select>
        </el-form-item>
        <el-form-item label="运费规则" prop="freightRule">
          <el-radio-group v-model="form.freightRule">
            <el-radio label="fixed">固定运费</el-radio>
            <el-radio label="weight">按重量计费</el-radio>
            <el-radio label="quantity">按数量计费</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="运费金额" prop="freightAmount">
          <el-input-number
            v-model="form.freightAmount"
            :min="0"
            :precision="2"
            :step="10"
            placeholder="请输入运费金额"
          />
          <span class="unit-text">
            {{ form.freightRule === 'fixed' ? '元' : form.freightRule === 'weight' ? '元/kg' : '元/件' }}
          </span>
        </el-form-item>
        <el-form-item label="最低运费" prop="minFreight">
          <el-input-number
            v-model="form.minFreight"
            :min="0"
            :precision="2"
            :step="10"
            placeholder="请输入最低运费"
          />
          <span class="unit-text">元</span>
        </el-form-item>
        <el-form-item label="最高运费" prop="maxFreight">
          <el-input-number
            v-model="form.maxFreight"
            :min="0"
            :precision="2"
            :step="10"
            placeholder="请输入最高运费"
          />
          <span class="unit-text">元</span>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="1">启用</el-radio>
            <el-radio label="0">禁用</el-radio>
          </el-radio-group>
        </el-form-item>
        <el-form-item label="备注" prop="remark">
          <el-input
            v-model="form.remark"
            type="textarea"
            :rows="3"
            placeholder="请输入备注信息"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <span class="dialog-footer">
          <el-button @click="dialogVisible = false">取消</el-button>
          <el-button type="primary" @click="handleSubmit">确定</el-button>
        </span>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'

// 搜索表单
const searchForm = reactive({
  productName: '',
  productCode: '',
  status: ''
})

// 表格数据
const loading = ref(false)
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(100)
const tableData = ref([
  {
    id: 1,
    productCode: 'P001',
    productName: '商品1',
    specification: '规格1',
    unit: '件',
    freightRule: 'fixed',
    freightAmount: 20.00,
    minFreight: 10.00,
    maxFreight: 100.00,
    status: '1',
    createTime: '2024-03-20 10:00:00'
  }
])

// 产品选项
const productOptions = ref([
  {
    id: 1,
    code: 'P001',
    name: '商品1',
    specification: '规格1'
  },
  {
    id: 2,
    code: 'P002',
    name: '商品2',
    specification: '规格2'
  }
])

// 对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const formRef = ref<FormInstance>()
const form = reactive({
  productId: '',
  freightRule: 'fixed',
  freightAmount: 0,
  minFreight: 0,
  maxFreight: 0,
  status: '1',
  remark: ''
})

// 表单验证规则
const rules = reactive<FormRules>({
  productId: [
    { required: true, message: '请选择产品', trigger: 'change' }
  ],
  freightRule: [
    { required: true, message: '请选择运费规则', trigger: 'change' }
  ],
  freightAmount: [
    { required: true, message: '请输入运费金额', trigger: 'blur' }
  ],
  minFreight: [
    { required: true, message: '请输入最低运费', trigger: 'blur' }
  ],
  maxFreight: [
    { required: true, message: '请输入最高运费', trigger: 'blur' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
})

// 搜索
const handleSearch = () => {
  // TODO: 实现搜索逻辑
  console.log('搜索条件：', searchForm)
}

// 重置搜索
const resetSearch = () => {
  searchForm.productName = ''
  searchForm.productCode = ''
  searchForm.status = ''
  handleSearch()
}

// 新增规则
const handleAdd = () => {
  dialogType.value = 'add'
  dialogVisible.value = true
  // 重置表单
  Object.assign(form, {
    productId: '',
    freightRule: 'fixed',
    freightAmount: 0,
    minFreight: 0,
    maxFreight: 0,
    status: '1',
    remark: ''
  })
}

// 编辑规则
const handleEdit = (row: any) => {
  dialogType.value = 'edit'
  dialogVisible.value = true
  // 填充表单
  Object.assign(form, {
    productId: row.productId,
    freightRule: row.freightRule,
    freightAmount: row.freightAmount,
    minFreight: row.minFreight,
    maxFreight: row.maxFreight,
    status: row.status,
    remark: row.remark
  })
}

// 切换状态
const handleToggleStatus = (row: any) => {
  const action = row.status === '1' ? '禁用' : '启用'
  ElMessageBox.confirm(
    `确定要${action}该运费规则吗？`,
    '提示',
    {
      confirmButtonText: '确定',
      cancelButtonText: '取消',
      type: 'warning'
    }
  ).then(() => {
    // TODO: 实现状态切换逻辑
    ElMessage.success(`${action}成功`)
  })
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (valid) {
      // TODO: 实现提交逻辑
      ElMessage.success(dialogType.value === 'add' ? '新增成功' : '编辑成功')
      dialogVisible.value = false
    }
  })
}

// 分页相关方法
const handleSizeChange = (val: number) => {
  pageSize.value = val
  // TODO: 重新加载数据
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  // TODO: 重新加载数据
}
</script>

<style scoped>
.freight-container {
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pagination-container {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.product-info {
  color: #909399;
  font-size: 12px;
  margin-left: 8px;
}

.unit-text {
  margin-left: 8px;
  color: #909399;
}

:deep(.el-form-item__content) {
  width: 100%;
}

:deep(.el-select) {
  width: 100%;
}
</style> 