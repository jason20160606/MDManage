<template>
  <div class="app-container">
    <!-- 自提点管理 -->
    <el-card class="pickup-point-wrapper">
      <template #header>
        <div class="card-header">
          <span>自提点管理</span>
          <el-button type="primary" @click="handleAddPickupPoint">新增自提点</el-button>
        </div>
      </template>

      <el-table :data="pickupPoints" border style="width: 100%">
        <el-table-column prop="name" label="自提点名称" />
        <el-table-column prop="address" label="地址" show-overflow-tooltip />
        <el-table-column prop="contact" label="联系人" />
        <el-table-column prop="phone" label="联系电话" />
        <el-table-column prop="businessHours" label="营业时间" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'">
              {{ row.status === 'active' ? '营业中' : '已关闭' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEditPickupPoint(row)">编辑</el-button>
            <el-button type="primary" link @click="handleToggleStatus(row)">
              {{ row.status === 'active' ? '关闭' : '开启' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 自提订单管理 -->
    <el-card class="order-wrapper">
      <template #header>
        <div class="card-header">
          <span>自提订单管理</span>
          <div class="header-operations">
            <el-button type="primary" @click="handleExport">导出订单</el-button>
          </div>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="订单号">
          <el-input v-model="queryForm.orderNo" placeholder="请输入订单号" clearable />
        </el-form-item>
        <el-form-item label="自提点">
          <el-select v-model="queryForm.pickupPoint" placeholder="请选择自提点" clearable>
            <el-option
              v-for="item in pickupPoints"
              :key="item.id"
              :label="item.name"
              :value="item.id"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select v-model="queryForm.status" placeholder="请选择状态" clearable>
            <el-option label="待自提" value="pending" />
            <el-option label="已自提" value="completed" />
            <el-option label="已取消" value="cancelled" />
          </el-select>
        </el-form-item>
        <el-form-item label="下单时间">
          <el-date-picker
            v-model="queryForm.orderTime"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 订单列表 -->
      <el-table :data="orderList" border style="width: 100%">
        <el-table-column prop="orderNo" label="订单号" width="180" />
        <el-table-column prop="pickupPoint" label="自提点" />
        <el-table-column prop="receiver" label="收货人" />
        <el-table-column prop="phone" label="联系电话" />
        <el-table-column prop="orderTime" label="下单时间" width="180" />
        <el-table-column prop="pickupTime" label="自提时间" width="180" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.status)">
              {{ getStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleViewOrder(row)">查看</el-button>
            <el-button
              v-if="row.status === 'pending'"
              type="primary"
              link
              @click="handleConfirmPickup(row)"
            >
              确认自提
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

    <!-- 自提点编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增自提点' : '编辑自提点'"
      width="500px"
    >
      <el-form :model="pickupPointForm" label-width="100px">
        <el-form-item label="自提点名称" required>
          <el-input v-model="pickupPointForm.name" placeholder="请输入自提点名称" />
        </el-form-item>
        <el-form-item label="地址" required>
          <el-input v-model="pickupPointForm.address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="联系人" required>
          <el-input v-model="pickupPointForm.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="pickupPointForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="营业时间" required>
          <el-input v-model="pickupPointForm.businessHours" placeholder="请输入营业时间" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="pickupPointForm.status"
            :active-value="'active'"
            :inactive-value="'inactive'"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="handleSavePickupPoint">确 定</el-button>
        </div>
      </template>
    </el-dialog>

    <!-- 订单详情对话框 -->
    <el-dialog v-model="orderDialogVisible" title="订单详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="订单号">{{ currentOrder?.orderNo }}</el-descriptions-item>
        <el-descriptions-item label="自提点">{{ currentOrder?.pickupPoint }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ currentOrder?.receiver }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentOrder?.phone }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ currentOrder?.orderTime }}</el-descriptions-item>
        <el-descriptions-item label="自提时间">{{ currentOrder?.pickupTime }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">
          <el-tag :type="getStatusType(currentOrder?.status)">
            {{ getStatusText(currentOrder?.status) }}
          </el-tag>
        </el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentOrder?.remark }}</el-descriptions-item>
      </el-descriptions>

      <div class="order-items">
        <h3>商品信息</h3>
        <el-table :data="currentOrder?.items" border>
          <el-table-column prop="name" label="商品名称" />
          <el-table-column prop="sku" label="SKU" />
          <el-table-column prop="price" label="单价" />
          <el-table-column prop="quantity" label="数量" />
          <el-table-column prop="total" label="小计" />
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqOrderlist } from '@/api/order/index'

// 自提点列表
const pickupPoints = ref([
  {
    id: 1,
    name: '北京朝阳区自提点',
    address: '北京市朝阳区望京街道xxx号',
    contact: '张三',
    phone: '13800138000',
    businessHours: '09:00-21:00',
    status: 'active'
  },
  {
    id: 2,
    name: '北京海淀区自提点',
    address: '北京市海淀区中关村xxx号',
    contact: '李四',
    phone: '13800138001',
    businessHours: '09:00-21:00',
    status: 'active'
  }
])

// 查询表单
const queryForm = reactive({
  orderNo: '',
  pickupPoint: '',
  status: '',
  orderTime: []
})

// 订单列表
const orderList = ref<any[]>([])

// 分页
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(100)

// 对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const pickupPointForm = reactive({
  name: '',
  address: '',
  contact: '',
  phone: '',
  businessHours: '',
  status: 'active'
})

// 订单详情对话框
const orderDialogVisible = ref(false)
const currentOrder = ref(null)

// 获取状态类型
const getStatusType = (status: string) => {
  const map = {
    pending: 'warning',
    completed: 'success',
    cancelled: 'info'
  }
  return map[status] || 'info'
}

// 获取状态文本
const getStatusText = (status: string) => {
  const map = {
    pending: '待自提',
    completed: '已自提',
    cancelled: '已取消'
  }
  return map[status] || status
}

// 查询订单
const handleQuery = () => {
  getPickupOrderList()
}

// 重置查询
const resetQuery = () => {
  queryForm.orderNo = ''
  queryForm.pickupPoint = ''
  queryForm.status = ''
  queryForm.orderTime = []
}

// 导出订单
const handleExport = () => {
  // TODO: 调用导出接口
  ElMessage.success('导出成功')
}

// 新增自提点
const handleAddPickupPoint = () => {
  dialogType.value = 'add'
  Object.assign(pickupPointForm, {
    name: '',
    address: '',
    contact: '',
    phone: '',
    businessHours: '',
    status: 'active'
  })
  dialogVisible.value = true
}

// 编辑自提点
const handleEditPickupPoint = (row: any) => {
  dialogType.value = 'edit'
  Object.assign(pickupPointForm, row)
  dialogVisible.value = true
}

// 切换自提点状态
const handleToggleStatus = (row: any) => {
  const action = row.status === 'active' ? '关闭' : '开启'
  ElMessageBox.confirm(`确认${action}该自提点吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    row.status = row.status === 'active' ? 'inactive' : 'active'
    ElMessage.success(`${action}成功`)
  })
}

// 保存自提点
const handleSavePickupPoint = () => {
  if (!pickupPointForm.name || !pickupPointForm.address || !pickupPointForm.contact || !pickupPointForm.phone || !pickupPointForm.businessHours) {
    ElMessage.warning('请填写必填项')
    return
  }
  // TODO: 调用保存接口
  ElMessage.success(dialogType.value === 'add' ? '新增成功' : '修改成功')
  dialogVisible.value = false
}

// 查看订单
const handleViewOrder = (row: any) => {
  currentOrder.value = row
  orderDialogVisible.value = true
}

// 确认自提
const handleConfirmPickup = (row: any) => {
  ElMessageBox.confirm('确认该订单已完成自提吗？', '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    // TODO: 调用确认自提接口
    row.status = 'completed'
    row.pickupTime = new Date().toLocaleString()
    ElMessage.success('确认自提成功')
  })
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

const getPickupOrderList = async () => {
  try {
    const res = await reqOrderlist({})    
    console.log('API返回数据:', res)
    // 假设API返回的数据结构是 { code: 200, data: { records: [...], total: ... } }
    if (res.status === 200) {
      orderList.value = res.data
      total.value = res.data.total
    } else {
      ElMessage.error('获取自提订单列表失败')
    }
  } catch (error) {
    console.error('请求自提订单列表出错:', error)
    ElMessage.error('请求自提订单列表出错')
  }
}

onMounted(() => {
  getPickupOrderList()
})
</script>

<style lang="scss" scoped>
.pickup-point-wrapper,
.order-wrapper {
  margin-bottom: 20px;
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

.order-items {
  margin-top: 20px;
  h3 {
    margin-bottom: 20px;
    font-weight: normal;
    color: #666;
  }
}
</style>
