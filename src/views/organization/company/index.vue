<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>公司管理</span>
          <el-button type="primary" @click="handleAdd">新增公司</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="公司名称">
          <el-input v-model="queryForm.name" placeholder="请输入公司名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 公司列表 -->
      <el-table :data="companyList" border style="width: 100%">
        <el-table-column type="index" label="序号" width="120" />
        <el-table-column prop="Name" label="公司名称" />
        <el-table-column prop="Description" label="公司描述" />        
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>            
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination 
          v-model:current-page="currentPage" 
          :page-size="pageSize" 
          :page-sizes="[10, 20, 50, 100]"
          :background="background" 
          layout="total, sizes, prev, pager, next, jumper" 
          :total="total"
          @current-change="handleCurrentChange" 
          @size-change="handleSizeChange" 
        />
      </div>
    </el-card>

    <!-- 公司编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增公司' : '编辑公司'"
      width="600px"
    >
      <el-form :model="companyForm" ref="companyFormRef" :rules="companyRules" label-width="100px">
        <el-form-item label="公司名称" prop="name">
          <el-input v-model="companyForm.name" placeholder="请输入公司名称" />
        </el-form-item>
        <el-form-item label="公司描述" prop="description">
          <el-input v-model="companyForm.description" type="textarea" placeholder="请输入公司描述" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="handleSave">确 定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqGetBrandList, reqAddBrand, reqUpdateBrand, reqDeleteBrand } from '@/api/organization/company'
import type { BrandQueryParams } from '@/api/organization/company'

// 查询表单
const queryForm = reactive({ 
    name: '', // 公司名称
})

// 公司列表
const companyList = ref<any[]>([])

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 对话框相关
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const companyFormRef = ref()

// 公司表单
const companyForm = reactive({
    id: '',
    name: '',
    description: ''
})

// 表单验证规则
const companyRules = {
    name: [
        { required: true, message: '请输入公司名称', trigger: 'blur' },
        { min: 2, max: 50, message: '公司名称长度在 2 到 50 个字符', trigger: 'blur' }
    ],
    description: [
        { max: 200, message: '公司描述不能超过 200 个字符', trigger: 'blur' }
    ]
}

// 查询公司列表
const handleQuery = async () => {
    try {
        // 构建查询参数
        const params: BrandQueryParams = {
            name: queryForm.name || undefined,
            PageNumber: currentPage.value,
            pageSize: pageSize.value
        }
        
        const result = await reqGetBrandList(params)
        companyList.value = result.data || []
        
        // 如果后端返回了分页信息，只更新总数和页大小，不覆盖当前页码
        if (result.headers && result.headers['x-pagination']) {
            const pagination = JSON.parse(result.headers['x-pagination'])
            total.value = pagination.TotalCount || 0
            // 不覆盖用户选择的页码：currentPage.value = pagination.PageIndex || 1
            pageSize.value = pagination.PageSize || 10
        } else {
            // 如果没有分页信息，使用前端计算的总数
            total.value = result.data?.length || 0
        }
    } catch (error) {
        ElMessage.error('获取公司列表失败，请重试')
        console.error('公司列表查询错误:', error)
    }
}

// 重置查询
const resetQuery = () => {
    queryForm.name = ''
    currentPage.value = 1
    handleQuery()
}

// 新增公司
const handleAdd = () => {
    dialogType.value = 'add'
    dialogVisible.value = true
    // 重置表单
    Object.assign(companyForm, {
        id: '',
        name: '',
        description: ''
    })
}

// 编辑公司
const handleEdit = (row: any) => {
    dialogType.value = 'edit'
    dialogVisible.value = true
    // 填充表单数据
    Object.assign(companyForm, {
        id: row.Id,
        name: row.Name,
        description: row.Description
    })
}

// 删除公司
const handleDelete = async (row: any) => {
    try {
        await ElMessageBox.confirm(
            `确定要删除公司"${row.Name}"吗？`,
            '确认删除',
            {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning',
            }
        )
        
        await reqDeleteBrand(row.Id)
        ElMessage.success('删除成功')
        handleQuery()
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error('删除失败')
            console.error('删除公司错误:', error)
        }
    }
}

// 保存公司信息
const handleSave = async () => {
    if (!companyFormRef.value) return
    
    try {
        await companyFormRef.value.validate()
        
        if (dialogType.value === 'add') {
            await reqAddBrand(companyForm)
        } else {
            await reqUpdateBrand(Number(companyForm.id), companyForm)
        }
        
        ElMessage.success(dialogType.value === 'add' ? '新增成功' : '更新成功')
        dialogVisible.value = false
        handleQuery()
    } catch (error) {
        ElMessage.error(dialogType.value === 'add' ? '新增失败' : '更新失败')
        console.error('保存公司信息错误:', error)
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

// 初始化加载数据
onMounted(() => {
    handleQuery()
})
</script>

<style lang="scss" scoped>
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

.dialog-footer {
  text-align: right;
}
</style>
