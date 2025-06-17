<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>产品分类管理</span>
          <el-button type="primary" @click="addCategory">新增分类</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="分类名称">
          <el-input v-model="queryForm.name" placeholder="请输入分类名称" clearable />
        </el-form-item>
        <el-form-item label="分类级别">
          <el-select v-model="queryForm.level" placeholder="请选择分类级别" clearable style="width: 150px;">
            <el-option label="一级分类" :value="1" />
            <el-option label="二级分类" :value="2" />
            <el-option label="三级分类" :value="3" />
          </el-select>
        </el-form-item>        
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 分类列表 -->
      <el-table :data="categoryList" border style="width: 100%" row-key="id" :tree-props="{ children: 'children' }">
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column prop="name" label="分类名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="level" label="级别" width="100">
          <template #default="{ row }">
            <el-tag :type="row.level === 1 ? 'primary' : row.level === 2 ? 'success' : 'warning'">
              {{ row.level === 1 ? '一级' : row.level === 2 ? '二级' : '三级' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="sort" label="排序" width="100" />       
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="addSubCategory(row)" v-if="row.level < 3">
              添加子分类
            </el-button>
            <el-button type="primary" link @click="updateCategory(row)">编辑</el-button>
            <el-button type="danger" link @click="deleteCategory(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          :current-page="currentPageNo"
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

    <!-- 分类编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增分类' : '编辑分类'"
      width="600px"
    >
      <el-form :model="categoryForm" ref="categoryFormRef" :rules="categoryRules" label-width="100px">
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="categoryForm.name" placeholder="请输入分类名称" />
        </el-form-item>
        <el-form-item label="上级分类" prop="parentId" v-if="categoryForm.level > 1">
          <el-cascader
            v-model="categoryForm.parentId"
            :options="parentCategoryOptions"
            :props="{
              checkStrictly: true,
              label: 'name',
              value: 'id',
              children: 'children',
              emitPath: false
            }"
            placeholder="请选择上级分类"
            clearable
            style="width: 100%"
          />
        </el-form-item>
        <el-form-item label="分类级别" prop="level">
          <el-select v-model="categoryForm.level" placeholder="请选择分类级别" :disabled="dialogType === 'edit'">
            <el-option label="一级分类" :value="1" />
            <el-option label="二级分类" :value="2" />
            <el-option label="三级分类" :value="3" />
          </el-select>
        </el-form-item>
        <el-form-item label="排序" prop="sort">
          <el-input-number v-model="categoryForm.sort" :min="0" placeholder="请输入排序值" />
        </el-form-item>
        <el-form-item label="分类图标" prop="icon">
          <el-input v-model="categoryForm.icon" placeholder="请输入图标类名或URL" />
        </el-form-item>
        <el-form-item label="描述" prop="description">
          <el-input
            v-model="categoryForm.description"
            type="textarea"
            :rows="3"
            placeholder="请输入分类描述"
          />
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
import { ref, reactive, onMounted, computed } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqGetCategoryList, reqAddCategory, reqUpdateCategory, reqDeleteCategory } from '@/api/product/category/index'
import type { Category, CategoryQueryParams } from '@/api/product/category/type'
import { ChatLineRound } from '@element-plus/icons-vue'
import { changeGlobalNodesTarget } from 'element-plus/es/utils/index.mjs'

// 查询表单
const queryForm = reactive({
  name: '',
  level: undefined as number | undefined
})

// 分类列表
const categoryList = ref<Category[]>([])

// 分页相关
const currentPageNo = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 对话框相关
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const categoryFormRef = ref()

// 分类表单
const categoryForm = reactive<Category>({
  id: undefined,
  name: '',
  parentId: null,
  level: 1,
  sort: 0,
  icon: '',
  description: ''
})

// 表单验证规则
const categoryRules = {
  name: [
    { required: true, message: '请输入分类名称', trigger: 'blur' },
    { min: 2, max: 50, message: '分类名称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  level: [
    { required: true, message: '请选择分类级别', trigger: 'change' }
  ],
  sort: [
    { required: true, message: '请输入排序值', trigger: 'blur' },
    { type: 'number', min: 0, message: '排序值不能小于0', trigger: 'blur' }
  ]
}

// 上级分类选项（用于级联选择器）
const parentCategoryOptions = computed(() => {
  const options: Category[] = []
  
  // 添加一级分类作为选项
  categoryList.value.forEach(category => {
    if (category.level === 1 && category.id) {
      const option: Category = {
        id: category.id,
        name: category.name,
        level: category.level,
        sort: category.sort
      }
      
      // 添加二级子分类
      if (category.children && category.children.length > 0) {
        option.children = category.children
          .filter(child => child.level === 2 && child.id)
          .map(child => ({
            id: child.id,
            name: child.name,
            level: child.level,
            sort: child.sort
          }))
      }
      
      options.push(option)
    }
  })
  
  return options
})

// 查询分类列表
const handleQuery = async () => {
  try {
    // 构建查询参数
    const params: CategoryQueryParams = {
      name: queryForm.name || undefined,
      level: queryForm.level,
      pageNumber: currentPageNo.value,
      pageSize: pageSize.value
    }
    
    const result = await reqGetCategoryList(params)
    console.log(result);
    // 确保数据是数组
    if (result && result.data) {
      categoryList.value = Array.isArray(result.data) ? result.data : []
    } else {
      categoryList.value = []
    }
    
    // 如果后端返回了分页信息
    if (result.headers && result.headers['x-pagination']) {
      try {
        const pagination = JSON.parse(result.headers['x-pagination'])
        total.value = pagination.TotalCount || 0
        pageSize.value = pagination.PageSize || 10
      } catch (e) {
        console.warn('解析分页信息失败:', e)
        total.value = categoryList.value.length
      }
    } else {
      total.value = categoryList.value.length
    }
  } catch (error) {
    ElMessage.error('获取分类列表失败，请重试')
    console.error('分类列表查询错误:', error)
    categoryList.value = []
    total.value = 0
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.name = ''
  queryForm.level = undefined
  currentPageNo.value = 1
  handleQuery()
}

// 新增分类
const addCategory = () => {
  dialogType.value = 'add'
  dialogVisible.value = true
  // 重置表单
  Object.assign(categoryForm, {
    id: undefined,
    name: '',
    parentId: null,
    level: 1,
    sort: 0,
    icon: '',
    description: ''
  })
}

// 添加子分类
const addSubCategory = (row: Category) => {
  dialogType.value = 'add'
  dialogVisible.value = true
  // 设置父级分类和级别
  Object.assign(categoryForm, {
    id: undefined,
    name: '',
    parentId: row.id,
    level: row.level + 1,
    sort: 0,
    icon: '',
    description: ''
  })
}

// 编辑分类
const updateCategory = (row: Category) => {
  dialogType.value = 'edit'
  dialogVisible.value = true
  // 填充表单数据
  Object.assign(categoryForm, {
    id: row.id,
    name: row.name,
    parentId: row.parentId,
    level: row.level,
    sort: row.sort,
    icon: row.icon,
    description: row.description
  })
}

// 删除分类
const deleteCategory = async (row: Category) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除分类"${row.name}"吗？${row.children && row.children.length > 0 ? '删除后将同时删除其下所有子分类！' : ''}`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    await reqDeleteCategory(row.id!)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
      console.error('删除分类错误:', error)
    }
  }
}

// 保存分类信息
const handleSave = async () => {
  if (!categoryFormRef.value) return
  
  try {
    await categoryFormRef.value.validate()
    
    // 处理级联选择器的值 - 添加安全检查
    if (categoryForm.parentId && Array.isArray(categoryForm.parentId)) {
      categoryForm.parentId = categoryForm.parentId[categoryForm.parentId.length - 1]
    }
    
    if (dialogType.value === 'add') {
      await reqAddCategory(categoryForm)
    } else {
      await reqUpdateCategory(categoryForm.id!, categoryForm)
    }
    
    ElMessage.success(dialogType.value === 'add' ? '新增成功' : '更新成功')
    dialogVisible.value = false
    handleQuery()
  } catch (error) {
    ElMessage.error(dialogType.value === 'add' ? '新增失败' : '更新失败')
    console.error('保存分类信息错误:', error)
  }
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
  currentPageNo.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPageNo.value = 1
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