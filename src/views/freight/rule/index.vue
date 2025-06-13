<template>
  <div class="freight-container">
    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="商品名称">
          <el-input v-model="searchForm.productName" placeholder="请输入商品名称" clearable />
        </el-form-item>
        <el-form-item label="商品代码">
          <el-input v-model="searchForm.productCode" placeholder="请输入商品代码" clearable />
        </el-form-item>
        <el-form-item label="状态">
          <el-select v-model="searchForm.status" placeholder="请选择状态" clearable>
            <el-option label="启用" value="enabled" />
            <el-option label="禁用" value="disabled" />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleSearch">搜索</el-button>
          <el-button @click="handleReset">重置</el-button>
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

      <el-table :data="tableData" border style="width: 100%">
        <el-table-column prop="productCode" label="商品代码" width="120" />
        <el-table-column prop="productName" label="商品名称" width="200" />
        <el-table-column prop="freight" label="运费" width="120">
          <template #default="{ row }">
            <span>¥{{ row.freight.toFixed(2) }}</span>
          </template>
        </el-table-column>
        <el-table-column prop="minQuantity" label="最小数量" width="120" />
        <el-table-column prop="maxQuantity" label="最大数量" width="120" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'enabled' ? 'success' : 'danger'">
              {{ row.status === 'enabled' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="createTime" label="创建时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button
              :type="row.status === 'enabled' ? 'danger' : 'success'"
              link
              @click="handleToggleStatus(row)"
            >
              {{ row.status === 'enabled' ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
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

    <!-- 新增/编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增规则' : '编辑规则'"
      width="500px"
    >
      <el-form
        ref="formRef"
        :model="form"
        :rules="rules"
        label-width="100px"
      >
        <el-form-item label="商品" prop="productId">
          <el-select v-model="form.productId" placeholder="请选择商品">
            <el-option
              v-for="item in productOptions"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="运费" prop="freight">
          <el-input-number
            v-model="form.freight"
            :min="0"
            :precision="2"
            :step="10"
          />
        </el-form-item>
        <el-form-item label="数量范围">
          <el-col :span="11">
            <el-form-item prop="minQuantity">
              <el-input-number
                v-model="form.minQuantity"
                :min="1"
                :precision="0"
                placeholder="最小数量"
              />
            </el-form-item>
          </el-col>
          <el-col :span="2" class="text-center">
            <span class="text-gray-500">-</span>
          </el-col>
          <el-col :span="11">
            <el-form-item prop="maxQuantity">
              <el-input-number
                v-model="form.maxQuantity"
                :min="1"
                :precision="0"
                placeholder="最大数量"
              />
            </el-form-item>
          </el-col>
        </el-form-item>
        <el-form-item label="状态" prop="status">
          <el-radio-group v-model="form.status">
            <el-radio label="enabled">启用</el-radio>
            <el-radio label="disabled">禁用</el-radio>
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

    <!-- 查看对话框 -->
    <el-dialog
      v-model="viewDialogVisible"
      title="查看规则"
      width="500px"
    >
      <el-descriptions :column="1" border>
        <el-descriptions-item label="商品代码">{{ viewData.productCode }}</el-descriptions-item>
        <el-descriptions-item label="商品名称">{{ viewData.productName }}</el-descriptions-item>
        <el-descriptions-item label="运费">¥{{ viewData.freight?.toFixed(2) }}</el-descriptions-item>
        <el-descriptions-item label="数量范围">
          {{ viewData.minQuantity }} - {{ viewData.maxQuantity }}
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="viewData.status === 'enabled' ? 'success' : 'danger'">
            {{ viewData.status === 'enabled' ? '启用' : '禁用' }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="创建时间">{{ viewData.createTime }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ viewData.remark }}</el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'

// 搜索表单
const searchForm = reactive({
  productName: '',
  productCode: '',
  status: ''
})

// 表格数据
const tableData = ref([])
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 商品选项
const productOptions = ref([])

// 新增/编辑对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const formRef = ref<FormInstance>()
const form = reactive({
  productId: '',
  freight: 0,
  minQuantity: 1,
  maxQuantity: 9999,
  status: 'enabled',
  remark: ''
})

// 查看对话框
const viewDialogVisible = ref(false)
const viewData = ref<any>({})

// 表单验证规则
const rules: FormRules = {
  productId: [
    { required: true, message: '请选择商品', trigger: 'change' }
  ],
  freight: [
    { required: true, message: '请输入运费', trigger: 'blur' }
  ],
  minQuantity: [
    { required: true, message: '请输入最小数量', trigger: 'blur' }
  ],
  maxQuantity: [
    { required: true, message: '请输入最大数量', trigger: 'blur' }
  ],
  status: [
    { required: true, message: '请选择状态', trigger: 'change' }
  ]
}

// 获取商品列表
const getProductList = async () => {
  // TODO: 实现获取商品列表的逻辑
  productOptions.value = [
    { id: 1, name: '示例商品1' },
    { id: 2, name: '示例商品2' }
  ]
}

// 搜索
const handleSearch = () => {
  // TODO: 实现搜索逻辑
  console.log('搜索条件：', searchForm)
}

// 重置
const handleReset = () => {
  searchForm.productName = ''
  searchForm.productCode = ''
  searchForm.status = ''
  handleSearch()
}

// 新增
const handleAdd = () => {
  dialogType.value = 'add'
  dialogVisible.value = true
  form.productId = ''
  form.freight = 0
  form.minQuantity = 1
  form.maxQuantity = 9999
  form.status = 'enabled'
  form.remark = ''
}

// 编辑
const handleEdit = (row: any) => {
  dialogType.value = 'edit'
  dialogVisible.value = true
  form.productId = row.productId
  form.freight = row.freight
  form.minQuantity = row.minQuantity
  form.maxQuantity = row.maxQuantity
  form.status = row.status
  form.remark = row.remark
}

// 查看
const handleView = (row: any) => {
  viewData.value = row
  viewDialogVisible.value = true
}

// 切换状态
const handleToggleStatus = (row: any) => {
  const action = row.status === 'enabled' ? '禁用' : '启用'
  ElMessageBox.confirm(`确定要${action}该规则吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // TODO: 实现状态切换逻辑
    ElMessage.success(`${action}成功`)
    handleSearch()
  })
}

// 提交表单
const handleSubmit = async () => {
  if (!formRef.value) return
  await formRef.value.validate((valid) => {
    if (valid) {
      // TODO: 实现保存逻辑
      ElMessage.success(dialogType.value === 'add' ? '新增成功' : '编辑成功')
      dialogVisible.value = false
      handleSearch()
    }
  })
}

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val
  handleSearch()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  handleSearch()
}

// 初始化
onMounted(() => {
  getProductList()
  handleSearch()
})
</script>

<style scoped>
.freight-container {
  padding: 20px;
}

.search-card {
  margin-bottom: 20px;
}

.table-card {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.pagination {
  margin-top: 20px;
  display: flex;
  justify-content: flex-end;
}

.text-center {
  text-align: center;
  line-height: 32px;
}

.text-gray-500 {
  color: #909399;
}
</style> 