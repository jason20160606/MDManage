<template>
    <div class="app-container">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>工厂管理</span>
            <el-button type="primary" @click="handleAdd">新增工厂</el-button>
          </div>
        </template>
  
        <!-- 搜索区域 -->
        <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
          <el-form-item label="工厂名称">
            <el-input v-model="queryForm.name" placeholder="请输入工厂名称" clearable />
          </el-form-item>         
          <el-form-item>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
  
        <!-- 工厂列表 -->
        <el-table :data="factoryList" border style="width: 100%">
          <el-table-column type="index" label="序号" width="120" />
          <el-table-column prop="Name" label="工厂名称" />
          <el-table-column prop="ContactPerson" label="负责人" />
          <el-table-column prop="ContactPhone" label="联系电话" />
          <el-table-column prop="Address" label="工厂地址" show-overflow-tooltip width="400"/>          
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
  
      <!-- 工厂编辑对话框 -->
      <el-dialog
        v-model="dialogVisible"
        :title="dialogType === 'add' ? '新增工厂' : '编辑工厂'"
        width="600px"
      >
        <el-form :model="factoryForm" ref="factoryFormRef" :rules="factoryRules" label-width="100px">
          <el-form-item label="工厂名称" prop="name">
            <el-input v-model="factoryForm.name" placeholder="请输入工厂名称" />
          </el-form-item>
          <el-form-item label="负责人" prop="contactPerson">
            <el-input v-model="factoryForm.contactPerson" placeholder="请输入负责人" />
          </el-form-item>
          <el-form-item label="联系电话" prop="contactPhone">
            <el-input v-model="factoryForm.contactPhone" placeholder="请输入联系电话" />
          </el-form-item>
          <el-form-item label="工厂地址" prop="address">
            <el-input v-model="factoryForm.address" type="textarea" placeholder="请输入工厂地址" />
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
  import { reqGetFactoryList, reqAddFactory, reqUpdateFactory, reqDeleteFactory } from '@/api/organization/factory'
  import type { FactoryQueryParams } from '@/api/organization/factory'
  
  // 查询表单
  const queryForm = reactive({ 
    name: '' // 工厂名称
  })
  
  // 工厂列表
  const factoryList = ref<any[]>([])
  
  // 分页相关
  const currentPage = ref(1)
  const pageSize = ref(10)
  const total = ref(0)
  const background = ref(true)
  
  // 对话框相关
  const dialogVisible = ref(false)
  const dialogType = ref<'add' | 'edit'>('add')
  const factoryFormRef = ref()
  
  // 工厂表单
  const factoryForm = reactive({
    id: '',
    name: '',
    contactPerson: '',
    contactPhone: '',
    address: ''
  })
  
  // 表单验证规则
  const factoryRules = {
    name: [
      { required: true, message: '请输入工厂名称', trigger: 'blur' },
      { min: 2, max: 50, message: '工厂名称长度在 2 到 50 个字符', trigger: 'blur' }
    ],
    contactPerson: [
      { required: true, message: '请输入负责人', trigger: 'blur' },
      { max: 20, message: '负责人长度不能超过 20 个字符', trigger: 'blur' }
    ],
    contactPhone: [
      { required: true, message: '请输入联系电话', trigger: 'blur' },
      { pattern: /^1[3-9]\d{9}$/, message: '请输入正确的手机号码', trigger: 'blur' }
    ],
    address: [
      { required: true, message: '请输入工厂地址', trigger: 'blur' },
      { max: 200, message: '工厂地址长度不能超过 200 个字符', trigger: 'blur' }
    ]
  }
  
  // 查询工厂列表
  const handleQuery = async () => {
    try {
      // 构建查询参数
      const params: FactoryQueryParams = {
        name: queryForm.name || undefined,
        PageNumber: currentPage.value,
        pageSize: pageSize.value
      }
      
      const result = await reqGetFactoryList(params)
      factoryList.value = result.data || []
      
      // 如果后端返回了分页信息，只更新总数和页大小，不覆盖当前页码
      if (result.headers && result.headers['x-pagination']) {
        const pagination = JSON.parse(result.headers['x-pagination'])
        total.value = pagination.TotalCount || 0
        pageSize.value = pagination.PageSize || 10
      } else {
        // 如果没有分页信息，使用前端计算的总数
        total.value = result.data?.length || 0
      }
    } catch (error) {
      ElMessage.error('获取工厂列表失败，请重试')
      console.error('工厂列表查询错误:', error)
    }
  }
  
  // 重置查询
  const resetQuery = () => {
    queryForm.name = ''
    currentPage.value = 1
    handleQuery()
  }
  
  // 新增工厂
  const handleAdd = () => {
    dialogType.value = 'add'
    dialogVisible.value = true
    // 重置表单
    Object.assign(factoryForm, {
      id: '',
      name: '',
      contactPerson: '',
      contactPhone: '',
      address: ''
    })
  }
  
  // 编辑工厂
  const handleEdit = (row: any) => {
    dialogType.value = 'edit'
    dialogVisible.value = true
    // 填充表单数据
    Object.assign(factoryForm, {
      id: row.Id,
      name: row.Name,
      contactPerson: row.ContactPerson,
      contactPhone: row.ContactPhone,
      address: row.Address
    })
  }
  
  // 删除工厂
  const handleDelete = async (row: any) => {
    try {
      await ElMessageBox.confirm(
        `确定要删除工厂"${row.Name}"吗？`,
        '确认删除',
        {
          confirmButtonText: '确定',
          cancelButtonText: '取消',
          type: 'warning',
        }
      )
      
      await reqDeleteFactory(row.Id)
      ElMessage.success('删除成功')
      handleQuery()
    } catch (error) {
      if (error !== 'cancel') {
        ElMessage.error('删除失败')
        console.error('删除工厂错误:', error)
      }
    }
  }
  
  // 保存工厂信息
  const handleSave = async () => {
    if (!factoryFormRef.value) return
    
    try {
      await factoryFormRef.value.validate()
      
      if (dialogType.value === 'add') {
        await reqAddFactory(factoryForm)
      } else {
        await reqUpdateFactory(Number(factoryForm.id), factoryForm)
      }
      
      ElMessage.success(dialogType.value === 'add' ? '新增成功' : '更新成功')
      dialogVisible.value = false
      handleQuery()
    } catch (error) {
      ElMessage.error(dialogType.value === 'add' ? '新增失败' : '更新失败')
      console.error('保存工厂信息错误:', error)
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