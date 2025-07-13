<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>经销商管理</span>
          <el-button type="primary" @click="handleAdd">新增经销商</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="经销商名称">
          <el-input v-model="queryForm.name" placeholder="请输入经销商名称" clearable />
        </el-form-item>
        <el-form-item label="经销商代码">
          <el-input v-model="queryForm.code" placeholder="请输入经销商代码" clearable />
        </el-form-item>

        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 经销商列表 -->
      <el-table :data="dealerList" border style="width: 100%">
        <el-table-column type="index" label="序号" width="80" />
        <el-table-column prop="MatchId" label="经销商代码" width="150" show-overflow-tooltip />
        <el-table-column prop="Name" label="经销商名称" min-width="200" show-overflow-tooltip />        
        <el-table-column prop="Quota" label="库存额度" width="120" />
        <el-table-column prop="Freight" label="邮费欠款" width="120" />
        <el-table-column prop="PriceDiff" label="差价欠款" width="120" />
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="danger" link @click="handleDelete(row)">删除</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize" :page-sizes="[10, 20, 50, 100]"
          :background="background" layout="total, sizes, prev, pager, next, jumper" :total="total"
          @current-change="handleCurrentChange" @size-change="handleSizeChange" />          
      </div>
    </el-card>

    <!-- 经销商编辑对话框 -->
    <el-dialog v-model="dialogVisible" :title="dialogType === 'add' ? '新增经销商' : '编辑经销商'" width="600px">
      <el-form :model="dealerForm" ref="dealerFormRef" :rules="dealerRules" label-width="100px">
        <el-form-item label="经销商名称" prop="name">
          <el-input v-model="dealerForm.name" placeholder="请输入经销商名称" />
        </el-form-item>
        <el-form-item label="经销商代码" prop="MatchId">
          <el-input v-model="dealerForm.matchId" placeholder="请输入经销商代码" />
        </el-form-item>
        <el-form-item label="联系人" prop="contact">
          <el-input v-model="dealerForm.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" prop="phone">
          <el-input v-model="dealerForm.phone" placeholder="请输入联系电话" />
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
import { reqGetDealerList, reqAddDealer, reqUpdateDealer, reqDeleteDealer } from '@/api/organization/dealer/index'
import type { DealerQueryParams } from '@/api/organization/dealer/index'

// 查询表单
const queryForm = reactive({
  name: '',
  code: ''
})

// 经销商列表
const dealerList = ref<any[]>([])

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 对话框相关
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const dealerFormRef = ref()

// 经销商表单
const dealerForm = reactive({
  id: '',
  name: '',
  matchId: '',
  contact: '',
  phone: ''
})

// 表单验证规则
const dealerRules = {
  name: [
    { required: true, message: '请输入经销商名称', trigger: 'blur' },
    { min: 2, max: 50, message: '经销商名称长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  matchId: [
    { required: true, message: '请输入经销商代码', trigger: 'blur' },
    { max: 20, message: '经销商代码长度不能超过 20 个字符', trigger: 'blur' }
  ],
  // 联系人不做必填校验
  // 联系电话只做格式校验，且仅在有值时校验
  phone: [
    { validator: (_, value, callback) => {
        if (value && !/^1[3-9]\d{9}$/.test(value)) {
          callback(new Error('请输入有效的手机号'))
        } else {
          callback()
        }
      }, trigger: 'blur' }
  ]
}

// 查询经销商列表
const handleQuery = async () => {
  try {
    // 构建查询参数
    const params: DealerQueryParams = {
      name: queryForm.name || undefined,
      code: queryForm.code || undefined,
      PageNumber: currentPage.value,
      pageSize: pageSize.value
    }

    const result = await reqGetDealerList(params)
    console.log(result);
    dealerList.value = result.data || []

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
    ElMessage.error('获取经销商列表失败，请重试')
    console.error('经销商列表查询错误:', error)
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.name = ''
  queryForm.code = ''
  currentPage.value = 1
  handleQuery()
}

// 新增经销商
const handleAdd = () => {
  dialogType.value = 'add'
  dialogVisible.value = true
  // 重置表单
  Object.assign(dealerForm, {
    matchId: '',
    name: '',
    contact: '',
    phone: ''
  })
}

// 编辑经销商
const handleEdit = (row: any) => {
  dialogType.value = 'edit'
  dialogVisible.value = true
  // 填充表单数据
  Object.assign(dealerForm, {
    id: row.Id,
    matchId: row.MatchId,
    name: row.Name,
    contact: row.Contact || '',
    phone: row.Phone || ''
  })
  console.log('表单数据:', dealerForm)
}

// 删除经销商
const handleDelete = async (row: any) => {
  try {
    await ElMessageBox.confirm(
      `确定要删除经销商"${row.Name}"吗？`,
      '确认删除',
      {
        confirmButtonText: '确定',
        cancelButtonText: '取消',
        type: 'warning',
      }
    )

    await reqDeleteDealer(row.Id || row.id)
    ElMessage.success('删除成功')
    handleQuery()
  } catch (error) {
    if (error !== 'cancel') {
      ElMessage.error('删除失败')
      console.error('删除经销商错误:', error)
    }
  }
}

// 保存经销商信息
const handleSave = async () => {
  if (!dealerFormRef.value) return

  try {
    await dealerFormRef.value.validate()

    if (dialogType.value === 'add') {
      await reqAddDealer(dealerForm)
    } else {
      console.log('更新时的ID值:', dealerForm.id, '类型:', typeof dealerForm.id)
      await reqUpdateDealer(Number(dealerForm.id), dealerForm)
    }

    ElMessage.success(dialogType.value === 'add' ? '新增成功' : '更新成功')
    dialogVisible.value = false
    handleQuery()
  } catch (error) {
    ElMessage.error(dialogType.value === 'add' ? '新增失败' : '更新失败')
    console.error('保存经销商信息错误:', error)
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
