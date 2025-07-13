<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>产品分类管理</span>
          <el-button type="primary" @click="addCategory">新增一级分类</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <!-- 分类列表 -->
      <el-table :data="categoryList" border style="width: 100%" row-key="Id" :tree-props="{ children: 'Children' }">        
        <el-table-column prop="Name" label="分类名称" min-width="200" show-overflow-tooltip />
        <el-table-column prop="Level" label="级别" width="100">
          <template #default="{ row }">
            <el-tag :type="row.Level === 1 ? 'primary' : row.Level === 2 ? 'success' : 'warning'">
              {{ row.Level === 1 ? '一级' : row.Level === 2 ? '二级' : '三级' }}
            </el-tag>
          </template>
        </el-table-column>              
        <el-table-column label="操作" width="280" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="addSubCategory(row)" v-if="row.Level < 3">
              添加子分类
            </el-button>
            <el-button type="primary" link @click="updateCategory(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDeleteClick(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 分类编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增分类' : '编辑分类'"
      width="600px"
    >
      <el-form :model="categoryForm" ref="categoryFormRef" :rules="categoryRules" label-width="100px">       
        <el-form-item label="上级分类" prop="parentId" v-if="dialogType === 'add' && categoryForm.level > 1">
          <el-input :value="parentCategoryName" disabled />
        </el-form-item>
        <el-form-item label="分类名称" prop="name">
          <el-input v-model="categoryForm.name" placeholder="请输入分类名称" />
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

// 查询表单
const queryForm = reactive({
  name: '',
  level: undefined as number | undefined
})

// 分类列表
const categoryList = ref<Category[]>([])

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
  icon: '',
  description: ''
})

// 表单验证规则
const categoryRules = {
  name: [
    { required: true, message: '请输入分类名称', trigger: 'blur' },
    { min: 2, max: 50, message: '分类名称长度在 2 到 50 个字符', trigger: 'blur' }
  ]
}

// 计算属性：只读显示父分类名称
const parentCategoryName = computed(() => {
  if (categoryForm.level > 1 && categoryForm.parentId) {
    function findName(list: any[], id: number | string): string | undefined {
      for (const item of list) {
        if (item.Id === id || item.id === id) return item.Name || item.name
        if (item.Children && item.Children.length) {
          const found = findName(item.Children, id)
          if (found) return found
        }
      }
      return undefined
    }
    return findName(categoryList.value, categoryForm.parentId) || ''
  }
  return ''
})

// 查询分类列表
const handleQuery = async () => {
  try {
    // 构建查询参数
    const params: CategoryQueryParams = {
      name: queryForm.name || undefined,
      level: queryForm.level
      // 不传pageNumber、pageSize
    }
    
    const result = await reqGetCategoryList(params)
    console.log(result);
    // 确保数据是数组
    if (result && result.data) {
      categoryList.value = Array.isArray(result.data) ? result.data : []
    } else {
      categoryList.value = []
    }
    
    // 不再处理分页信息
  } catch (error) {
    ElMessage.error('获取分类列表失败，请重试')
    console.error('分类列表查询错误:', error)
    categoryList.value = []
  }
}


// 新增分类
const addCategory = () => {
  dialogType.value = 'add'
  dialogVisible.value = true
  // 只能新增一级分类
  Object.assign(categoryForm, {
    id: undefined,
    name: '',
    parentId: null,
    level: 1,
  })
}

// 添加子分类
const addSubCategory = (row: any) => {
  dialogType.value = 'add'
  dialogVisible.value = true
  // 兼容Id/Level字段
  const parentId = row['Id'] ?? row['id']
  const parentLevel = row['Level'] ?? row['level']
  Object.assign(categoryForm, {
    id: undefined,
    name: '',
    parentId: parentId,
    level: parentLevel ? parentLevel + 1 : 2,
  })
}

// 编辑分类
const updateCategory = (row: any) => {
  dialogType.value = 'edit'
  dialogVisible.value = true
  Object.assign(categoryForm, {
    id: row.Id ?? row.id,
    name: row.Name ?? row.name,
    parentId: row.ParentId ?? row.parentId,
    level: row.Level ?? row.level,
    icon: row.Icon ?? row.icon,
    description: row.Description ?? row.description
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

// 新增删除按钮点击处理方法
const handleDeleteClick = (row: any) => {
  if (row.Children && row.Children.length > 0) {
    ElMessage.warning('该分类下存在子分类，无法删除')
    return
  }
  deleteCategory(row)
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