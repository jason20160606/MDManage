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
        <el-table-column prop="Id" label="经销商代码" width="120" />
        <el-table-column prop="Name" label="经销商名称" />        
        <el-table-column prop="Quota" label="库存额度" width="120" />                 
        <el-table-column label="操作" width="280">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
            <el-button type="primary" link @click="handleQuota(row)">额度</el-button>
            <el-button type="primary" link @click="handleQuotaLog(row)">额度记录</el-button>
            <el-button
              type="primary"
              link
              @click="handleToggleStatus(row)"
            >
              {{ row.status === 'active' ? '停用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <div class="pagination-wrapper">
        <el-pagination
          v-model:current-page="currentPage"
          v-model:page-size="pageSize"
          :page-sizes="[10, 20, 50, 100]"
          :total="total"
          layout="total, sizes, prev, pager, next, jumper"
          @size-change="handleSizeChange"
          @current-change="handleCurrentChange"
        />
      </div>
    </el-card>

    <!-- 经销商编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增经销商' : '编辑经销商'"
      width="600px"
    >
      <el-form :model="dealerForm" label-width="100px">
        <el-form-item label="经销商代码" required>
          <el-input v-model="dealerForm.code" placeholder="请输入经销商代码" />
        </el-form-item>
        <el-form-item label="经销商名称" required>
          <el-input v-model="dealerForm.name" placeholder="请输入经销商名称" />
        </el-form-item>
        <el-form-item label="负责人" required>
          <el-input v-model="dealerForm.manager" placeholder="请输入负责人" />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="dealerForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="地址" required>
          <el-input v-model="dealerForm.address" type="textarea" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="库存额度" required>
          <el-input-number v-model="dealerForm.quota" :min="0" />
        </el-form-item>
        <el-form-item label="营业执照">
          <el-upload
            class="upload-demo"
            action="/api/upload"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
          >
            <el-button type="primary">上传营业执照</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="dealerForm.status"
            :active-value="'active'"
            :inactive-value="'inactive'"
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

    <!-- 经销商详情对话框 -->
    <el-dialog v-model="detailVisible" title="经销商详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="经销商代码">{{ currentDealer?.code }}</el-descriptions-item>
        <el-descriptions-item label="经销商名称">{{ currentDealer?.name }}</el-descriptions-item>
        <el-descriptions-item label="负责人">{{ currentDealer?.manager }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentDealer?.phone }}</el-descriptions-item>
        <el-descriptions-item label="地址" :span="2">{{ currentDealer?.address }}</el-descriptions-item>
        <el-descriptions-item label="库存额度">{{ currentDealer?.quota }} 件</el-descriptions-item>
        <el-descriptions-item label="已用额度">{{ currentDealer?.usedQuota }} 件</el-descriptions-item>
        <el-descriptions-item label="营业执照">
          <el-image
            style="width: 200px"
            :src="currentDealer?.license"
            :preview-src-list="[currentDealer?.license]"
          />
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="currentDealer?.status === 'active' ? 'success' : 'info'">
            {{ currentDealer?.status === 'active' ? '正常' : '停用' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>

    <!-- 额度调整对话框 -->
    <el-dialog v-model="quotaVisible" title="额度调整" width="500px">
      <el-form :model="quotaForm" label-width="100px">
        <el-form-item label="经销商名称">
          <span>{{ currentDealer?.name }}</span>
        </el-form-item>
        <el-form-item label="当前额度">
          <span>{{ currentDealer?.quota }} 件</span>
        </el-form-item>
        <el-form-item label="已用额度">
          <span>{{ currentDealer?.usedQuota }} 件</span>
        </el-form-item>
        <el-form-item label="调整额度" required>
          <el-input-number v-model="quotaForm.quota" :min="currentDealer?.usedQuota" />
        </el-form-item>
        <el-form-item label="调整原因" required>
          <el-input v-model="quotaForm.reason" type="textarea" placeholder="请输入调整原因" />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="quotaVisible = false">取 消</el-button>
          <el-button type="primary" @click="handleQuotaSave">确 定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 额度记录对话框 -->
    <el-dialog v-model="quotaLogVisible" title="额度记录" width="800px">
      <el-table :data="quotaLogList" border style="width: 100%">
        <el-table-column prop="time" label="操作时间" width="180" />
        <el-table-column prop="type" label="操作类型" width="100">
          <template #default="{ row }">
            <el-tag :type="row.type === 'increase' ? 'success' : 'danger'">
              {{ row.type === 'increase' ? '增加' : '减少' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="quantity" label="调整数量" width="100">
          <template #default="{ row }">
            {{ row.type === 'increase' ? '+' : '-' }}{{ row.quantity }} 件
          </template>
        </el-table-column>
        <el-table-column prop="before" label="调整前" width="100">
          <template #default="{ row }">
            {{ row.before }} 件
          </template>
        </el-table-column>
        <el-table-column prop="after" label="调整后" width="100">
          <template #default="{ row }">
            {{ row.after }} 件
          </template>
        </el-table-column>
        <el-table-column prop="operator" label="操作人" width="120" />
        <el-table-column prop="reason" label="原因" show-overflow-tooltip />
      </el-table>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive,onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqGetDealerList } from '@/api/organization/dealer/index'

// 查询表单
const queryForm = reactive({
  name: '',
  code: '',
  status: ''
})

// 经销商列表（移除测试数据，初始化为空数组）
const dealerList = ref<any[]>([])

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const dealerForm = reactive({
  code: '',
  name: '',
  manager: '',
  phone: '',
  address: '',
  quota: 0,
  license: '',
  status: 'active'
})

// 详情对话框
const detailVisible = ref(false)
const currentDealer = ref(null)

// 额度调整
const quotaVisible = ref(false)
const quotaForm = reactive({
  quota: 0,
  reason: ''
})

// 额度记录
const quotaLogVisible = ref(false)
const quotaLogList = ref([
  {
    time: '2024-01-01 12:00:00',
    type: 'increase',
    quantity: 1000,
    before: 0,
    after: 1000,
    operator: '张三',
    reason: '初始设置'
  },
  {
    time: '2024-01-02 12:00:00',
    type: 'decrease',
    quantity: 500,
    before: 1000,
    after: 500,
    operator: '李四',
    reason: '额度调整'
  }
])
onMounted(() => {
  handleQuery() // 页面加载时查询
})
// 查询经销商
const handleQuery = async () => {
  try {    
    // 调用API获取数据
    const result = await reqGetDealerList()
    // 绑定数据到列表和总数
    dealerList.value = result.data
    console.log('经销商列表数据:', dealerList.value) // 添加日志输出
    total.value = result.total
  } catch (error) {
    ElMessage.error('查询经销商失败，请重试')
    console.error('经销商查询错误:', error)
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.name = ''
  queryForm.code = ''
  queryForm.status = ''
}

// 新增经销商
const handleAdd = () => {
  dialogType.value = 'add'
  Object.assign(dealerForm, {
    code: '',
    name: '',
    manager: '',
    phone: '',
    address: '',
    quota: 0,
    license: '',
    status: 'active'
  })
  dialogVisible.value = true
}

// 编辑经销商
const handleEdit = (row: any) => {
  dialogType.value = 'edit'
  Object.assign(dealerForm, row)
  dialogVisible.value = true
}

// 查看经销商
const handleView = (row: any) => {
  currentDealer.value = row
  detailVisible.value = true
}

// 调整额度
const handleQuota = (row: any) => {
  currentDealer.value = row
  quotaForm.quota = row.quota
  quotaForm.reason = ''
  quotaVisible.value = true
}

// 查看额度记录
const handleQuotaLog = (row: any) => {
  currentDealer.value = row
  // TODO: 调用额度记录查询接口
  quotaLogVisible.value = true
}

// 切换经销商状态
const handleToggleStatus = (row: any) => {
  const action = row.status === 'active' ? '停用' : '启用'
  ElMessageBox.confirm(`确认${action}该经销商吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    row.status = row.status === 'active' ? 'inactive' : 'active'
    ElMessage.success(`${action}成功`)
  })
}

// 保存经销商
const handleSave = () => {
  if (!dealerForm.code || !dealerForm.name || !dealerForm.manager || !dealerForm.phone || !dealerForm.address || !dealerForm.quota) {
    ElMessage.warning('请填写必填项')
    return
  }
  // TODO: 调用保存接口
  ElMessage.success(dialogType.value === 'add' ? '新增成功' : '修改成功')
  dialogVisible.value = false
}

// 上传成功
const handleUploadSuccess = (response: any) => {
  dealerForm.license = response.url
  ElMessage.success('上传成功')
}

// 上传失败
const handleUploadError = () => {
  ElMessage.error('上传失败')
}

// 分页
const handleSizeChange = (val: number) => {
  pageSize.value = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  currentPage.value = val
  handleQuery()
}

// 保存额度调整
const handleQuotaSave = () => {
  if (!quotaForm.reason) {
    ElMessage.warning('请填写调整原因')
    return
  }
  if (quotaForm.quota < currentDealer.value?.usedQuota) {
    ElMessage.warning('调整后的额度不能小于已用额度')
    return
  }
}
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
</style>
