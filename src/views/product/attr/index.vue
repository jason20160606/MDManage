<template>
  <div class="app-container">
    <!-- 分类筛选组件 -->
    <Category :scene="scene" />
    
    <!-- 属性列表页面 -->
    <el-card v-show="scene === 0">
      <template #header>
        <div class="card-header">
          <span>属性管理</span>
          <el-button type="primary" @click="addAttr" :disabled="!categoryStore.c3Id">
            新增属性
          </el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="属性名称">
          <el-input v-model="queryForm.attrName" placeholder="请输入属性名称" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item label="属性值">
          <el-input v-model="queryForm.valueName" placeholder="请输入属性值" clearable style="width: 200px;" />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 属性列表 -->
      <el-table :data="attrList" border style="width: 100%" v-loading="loading">
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column prop="attrName" label="属性名称" min-width="150" show-overflow-tooltip />
        <el-table-column label="属性值" min-width="300" show-overflow-tooltip>
          <template #default="{ row }">
            <el-tag 
              v-for="item in row.attrValueList" 
              :key="item.id || item.valueName"
              size="small" 
              style="margin: 2px 4px;"
              :type="getTagType(item.valueName)"
            >
              {{ item.valueName }}
            </el-tag>
            <span v-if="!row.attrValueList || row.attrValueList.length === 0" class="text-gray">
              暂无属性值
            </span>
          </template>
        </el-table-column>
        <el-table-column prop="categoryLevel" label="分类级别" width="100" align="center">
          <template #default="{ row }">
            <el-tag :type="getLevelTagType(row.categoryLevel)">
              {{ getLevelText(row.categoryLevel) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="属性值数量" width="120" align="center">
          <template #default="{ row }">
            <el-badge :value="row.attrValueList?.length || 0" :max="99" type="info" />
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="updateAttr(row)">编辑</el-button>
            <el-button type="info" link @click="viewAttr(row)">查看</el-button>
            <el-button type="danger" link @click="deleteAttr(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPageNo"
          v-model:page-size="pageSizeNo"
          :page-sizes="[10, 20, 50, 100]"
          :background="background"
          layout="total, sizes, prev, pager, next, jumper"
          :total="total"
          @current-change="handleCurrentChange"
          @size-change="handleSizeChange"
        />
      </div>
    </el-card>

    <!-- 属性编辑对话框 -->
    <attrForm ref="attr" v-show="scene === 1" @change-scene="changeScene"></attrForm>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import useCategoryStore from '@/store/modules/category'
import { reqAttr, reqDeleteAttr } from '@/api/product/attr'
import type { Attr } from '@/api/product/attr/type'
import attrForm from './attrForm.vue'

// 场景值：0-数据展示，1-属性编辑
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
  attrName: '',
  valueName: ''
})

// 属性列表
const attrList = ref<Attr[]>([])
const loading = ref(false)

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)
const background = ref(true)

// 获取三级分类的仓库
const categoryStore = useCategoryStore()

// 获取子组件实例
const attr = ref()

// 监听三级分类的变化
watch(() => categoryStore.c3Id, () => {
  if (!categoryStore.c3Id) {
    attrList.value = []
    total.value = 0
    return
  }
  handleQuery()
})

// 查询属性列表
const handleQuery = async () => {
  if (!categoryStore.c3Id) {
    ElMessage.warning('请先选择分类')
    return
  }

  loading.value = true
  try {
    const result: any = await reqAttr()
    if (result.ok) {
      // 过滤数据
      let filteredData = result.data || []
      
      // 按属性名称过滤
      if (queryForm.attrName) {
        filteredData = filteredData.filter((item: Attr) => 
          item.attrName.toLowerCase().includes(queryForm.attrName.toLowerCase())
        )
      }
      
      // 按属性值过滤
      if (queryForm.valueName) {
        filteredData = filteredData.filter((item: Attr) => 
          item.attrValueList.some(val => 
            val.valueName.toLowerCase().includes(queryForm.valueName.toLowerCase())
          )
        )
      }
      
      attrList.value = filteredData
      total.value = filteredData.length
    }
  } catch (error) {
    ElMessage.error('获取属性列表失败')
    console.error('属性查询错误:', error)
  } finally {
    loading.value = false
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.attrName = ''
  queryForm.valueName = ''
  currentPageNo.value = 1
  handleQuery()
}

// 新增属性 - 切换到编辑场景，隐藏列表
const addAttr = () => {
  scene.value = 1 // 切换到属性编辑场景，隐藏列表
  nextTick(() => {
    attr.value?.initForm() // 初始化新增表单
  })
}

// 编辑属性 - 切换到编辑场景，隐藏列表
const updateAttr = (row: Attr) => {
  scene.value = 1 // 切换到属性编辑场景，隐藏列表
  nextTick(() => {
    attr.value?.initForm(row) // 初始化编辑表单
  })
}

// 查看属性 - 切换到编辑场景，隐藏列表
const viewAttr = (row: Attr) => {
  scene.value = 1 // 切换到属性编辑场景，隐藏列表
  nextTick(() => {
    attr.value?.initForm(row, true) // 初始化只读表单
  })
}

// 删除属性 - 保持在列表场景，显示确认对话框
const deleteAttr = async (row: Attr) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除属性"${row.attrName}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )
    
    // 调用删除API
    await reqDeleteAttr(row.id!)
    ElMessage.success('删除成功')
    handleQuery() // 刷新列表
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
      console.error('删除属性错误:', error)
    }
  }
}

// 子组件自定义事件 - 切换场景
const changeScene = (num: number) => {
  scene.value = num
  if (num === 0) {
    handleQuery() // 返回列表时刷新数据
  }
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
  currentPageNo.value = page
  handleQuery()
}

const handleSizeChange = (size: number) => {
  pageSizeNo.value = size
  currentPageNo.value = 1
  handleQuery()
}

// 获取标签类型
const getTagType = (valueName: string) => {
  const colors = ['', 'success', 'warning', 'danger', 'info']
  const index = valueName.length % colors.length
  return colors[index]
}

// 获取分类级别标签类型
const getLevelTagType = (level: number) => {
  switch (level) {
    case 1: return 'primary'
    case 2: return 'success'
    case 3: return 'warning'
    default: return 'info'
  }
}

// 获取分类级别文本
const getLevelText = (level: number) => {
  switch (level) {
    case 1: return '一级'
    case 2: return '二级'
    case 3: return '三级'
    default: return '未知'
  }
}

// 初始化
onMounted(() => {
  // 页面加载时不自动查询，等待用户选择分类
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

.text-gray {
  color: #909399;
  font-size: 12px;
}
</style>