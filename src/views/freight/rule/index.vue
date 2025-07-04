<template>
  <div class="freight-container">
    <!-- 搜索区域 -->
    <el-card class="search-card">
      <el-form :model="searchForm" inline>
        <el-form-item label="商品名称">
          <el-input v-model="searchForm.ProductName" placeholder="请输入商品名称" clearable />
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
        <el-table-column prop="Name" label="商品名称"/>
        
        <el-table-column prop="BaseFreight" label="运费">
          <template #default="{ row }">
            <span>¥{{ row.BaseFreight.toFixed(2) }}</span>
          </template>
        </el-table-column>       
        <el-table-column prop="SpecialFreight" label="新疆运费">
          <template #default="{ row }">
            <span>¥{{ row.SpecialFreight.toFixed(2) }}</span>
          </template>
        </el-table-column> 
        
        <el-table-column prop="UpdatedAt" label="更新时间" width="180" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>  
          </template>
        </el-table-column>
      </el-table>

      <div class="pagination">
        <el-pagination v-model:current-page="currentPageNo" v-model:page-size="pageSizeNo"
            :page-sizes="[10, 20, 50, 100]"
            layout="total, sizes, prev, pager, next, jumper" :total="total" @current-change="handleCurrentChange"
            @size-change="handleSizeChange" />
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
          <!-- 编辑模式下商品选择器只读，禁止修改商品，只允许新增时选择 -->
          <el-select
            v-model="form.productId"
            placeholder="请选择商品"
            :disabled="dialogType === 'edit'"  
          >
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
        <el-form-item label="新疆运费" prop="specialfreight">
          <el-input-number
            v-model="form.specialfreight"
            :min="0"
            :precision="2"
            :step="10"
          />
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
import { ref, reactive, onMounted } from 'vue'
import type { FormInstance, FormRules } from 'element-plus'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqFreightRuleList } from '@/api/freight'
import { reqFreightRuleDetail } from '@/api/freight'
import { reqSkuNameList } from '@/api/product/sku/index'

// 搜索表单
const searchForm = reactive({
  ProductName: ''
})

// 表格数据
const tableData = ref([])
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
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
  specialfreight:0,
  minQuantity: 1,
  maxQuantity: 9999,
  status: 'enabled',
  remark: ''
})


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


// 获取运费规则列表
const fetchFreightRuleList = async () => {
  const params = {
    PageNumber: currentPageNo.value,
    PageSize: pageSizeNo.value,
    ...searchForm
  }
  const res = await reqFreightRuleList(params)
  if (res.status === 200) {
    tableData.value = res.data.records || res.data
    const pagination = JSON.parse(res.headers['x-pagination']);    
    currentPageNo.value = pagination.PageIndex;
    pageSizeNo.value = pagination.pageSize;
    total.value = pagination.TotalCount;
  } else {
    tableData.value = []
    total.value = 0
  }
}

// 搜索
const handleSearch = () => {
  currentPageNo.value = 1
  fetchFreightRuleList()
}

// 重置
const handleReset = () => {
  searchForm.ProductName = ''
  handleSearch()
}

// 新增
const handleAdd = async () => {
  dialogType.value = 'add'
  dialogVisible.value = true
  form.productId = ''
  form.freight = 0
  form.specialfreight = 0
  form.minQuantity = 1
  form.maxQuantity = 9999
  form.status = 'enabled'
  form.remark = ''
  // 新增时获取产品下拉选项
  try {
    const res = await reqSkuNameList()
    if (res && res.data) {
      productOptions.value = res.data.map((sku: any) => ({
        id: sku.Id,
        name: sku.Name
      }))
    }
  } catch (e) {
    productOptions.value = []
  }
}

// 编辑
const handleEdit = async (row: any) => {
  dialogType.value = 'edit'
  dialogVisible.value = true
  try {
    // 兼容Id/id字段
    const ruleId = row.Id || row.id
    const res = await reqFreightRuleDetail(ruleId)
    if (res && res.data) {
      // 正确映射接口返回字段到表单
      form.productId = res.data.Id // 商品ID
      form.freight = res.data.BaseFreight // 运费
      form.specialfreight = res.data.SpecialFreight // 新疆运费
      form.remark = res.data.remark || '' // 备注（如有）
      // 其它字段如有需要可补充
      // 保证商品下拉有当前商品
      const exist = productOptions.value.find(item => item.id === res.data.Id)
      if (!exist && res.data.Id) {
        productOptions.value.push({
          id: res.data.Id,
          name: res.data.Name || '未知商品'
        })
      }
    }
  } catch (e) {
    ElMessage.error('获取运费规则详情失败')
  }
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
  pageSizeNo.value = val
  fetchFreightRuleList()
}

const handleCurrentChange = (val: number) => {
  currentPageNo.value = val
  fetchFreightRuleList()
}

// 初始化
onMounted(() => {
  fetchFreightRuleList()
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