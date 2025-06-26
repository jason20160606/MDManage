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
        <el-table-column prop="Code" label="自提点编码"/>
        <el-table-column prop="Name" label="自提点名称"/>
        <el-table-column prop="ContactPerson" label="联系人"/>
        <el-table-column prop="ContactPhone" label="联系电话"/>
        <el-table-column prop="Address" label="地址" show-overflow-tooltip width="320" />
        <el-table-column prop="Remark" label="备注"/>
        <el-table-column prop="IsEnabled" label="状态">
          <template #default="{ row }">
            <el-tag :type="row.IsEnabled ? 'success' : 'info'">
              {{ row.IsEnabled ? '营业中' : '已关闭' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEditPickupPoint(row)">编辑</el-button>
            <el-button type="primary" link @click="handleToggleStatus(row)">
              {{ row.IsEnabled ? '关闭' : '开启' }}
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
          <el-select v-model="queryForm.pickupPoint" placeholder="请选择自提点" clearable style="width: 120px">
            <el-option
              v-for="item in pickupPoints"
              :key="item.Code"
              :label="item.Name"
              :value="item.Code"
            />
          </el-select>
        </el-form-item>
        <el-form-item label="订单状态">
          <el-select v-model="queryForm.status" placeholder="请选择状态" clearable style="width: 120px">
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
        <el-table-column prop="OrderNo" label="订单号" width="180" />
        <el-table-column label="收货信息" width="320">
          <template #default="{ row }">
            <div>
              <div>{{ row.ReceiverName }}（{{ row.ReceiverPhone }}）</div>
              <div style="color: #888;">{{ row.ReceiverAddress }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column label="自提信息" width="260">
          <template #default="{ row }">
            <div>
              <div>经销商：{{ row.DealerName || '-' }}</div>
              <div>司机信息：{{ row.ContactPerson || '-' }} {{ row.ContactPhone ? '（' + row.ContactPhone + '）' : '' }}</div>
            </div>
          </template>
        </el-table-column>
        <el-table-column prop="OrderDate" label="下单时间" width="160">
          <template #default="{ row }">
            {{ row.OrderDate ? row.OrderDate.slice(0, 19).replace('T', ' ') : '' }}
          </template>
        </el-table-column>
        <el-table-column prop="Status" label="订单状态" width="100">
          <template #default="{ row }">
            <el-tag :type="getStatusType(row.Status)">
              {{ getStatusText(row.Status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column prop="TotalAmount" label="订单总额" width="100" />
        <el-table-column prop="Remark" label="备注" width="120" />
        <el-table-column label="操作" width="180">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleViewOrder(row)">查看</el-button>
            <el-button
              v-if="row.Status === 1"
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
      <el-pagination
        v-model:current-page="currentPageNo"
        v-model:page-size="pageSizeNo"
        :page-sizes="[10, 20, 50, 100]"
        layout="total, sizes, prev, pager, next, jumper"
        :total="total"
        @current-change="handleCurrentChange"
        @size-change="handleSizeChange"
        style="margin-top: 10px; text-align: right;"
    />
    </el-card>

    <!-- 自提点编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增自提点' : '编辑自提点'"
      width="500px"
    >
      <el-form :model="pickupPointForm" label-width="100px">
        <el-form-item label="自提点名称" required>
          <el-input v-model="pickupPointForm.Name" placeholder="请输入自提点名称" />
        </el-form-item>
        <el-form-item label="地址" required>
          <el-input v-model="pickupPointForm.Address" placeholder="请输入地址" />
        </el-form-item>
        <el-form-item label="联系人" required>
          <el-input v-model="pickupPointForm.ContactPerson" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="pickupPointForm.ContactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="营业时间" required>
          <el-input v-model="pickupPointForm.businessHours" placeholder="请输入营业时间" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="pickupPointForm.IsEnabled"
            :active-value="true"
            :inactive-value="false"
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
        <el-descriptions-item label="订单号">{{ currentOrder?.OrderNo }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ currentOrder?.ReceiverName }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentOrder?.ReceiverPhone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址">{{ currentOrder?.ReceiverAddress }}</el-descriptions-item>
        <el-descriptions-item label="自提车牌号">{{ currentOrder?.ContactPerson }}</el-descriptions-item>
        <el-descriptions-item label="自提联系电话">{{ currentOrder?.ContactPhone }}</el-descriptions-item>
        <el-descriptions-item label="下单时间">{{ currentOrder?.OrderDate ? currentOrder.OrderDate.slice(0, 19).replace('T', ' ') : '' }}</el-descriptions-item>
        <el-descriptions-item label="订单状态">{{ getStatusText(currentOrder?.Status) }}</el-descriptions-item>
        <el-descriptions-item label="订单总额">{{ currentOrder?.TotalAmount }}</el-descriptions-item>
        <el-descriptions-item label="备注">{{ currentOrder?.Remark }}</el-descriptions-item>
      </el-descriptions>
      <div class="order-items">
        <h3>商品信息</h3>
        <el-table :data="currentOrder?.OrderItems || []" border>
          <el-table-column prop="ProductName" label="商品名称" />          
          <el-table-column prop="Quantity" label="数量" />          
        </el-table>
      </div>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqOrderlist, reqCheckOrder } from '@/api/order/index'
import { getPickupPoints, addPickupPoint, updatePickupPoint } from '@/api/shipping'

// 自提点列表
const pickupPoints = ref<any[]>([])

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
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
const total = ref(0)

// 对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const pickupPointForm = reactive({
  Code: '',
  Name: '',
  Address: '',
  ContactPerson: '',
  ContactPhone: '',
  Remark: '',
  IsEnabled: true
})

// 订单详情对话框
const orderDialogVisible = ref(false)
const currentOrder = ref(null)

// 订单状态映射
const statusMap = {
  1: '待自提',
  2: '已自提',
  3: '已取消'
}
const getStatusText = (status: number) => statusMap[status] || status
const getStatusType = (status: number) => {
  if (status === 1) return 'warning'
  if (status === 2) return 'success'
  if (status === 3) return 'info'
  return 'info'
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
    Code: '',
    Name: '',
    Address: '',
    ContactPerson: '',
    ContactPhone: '',
    Remark: '',
    IsEnabled: true
  })
  dialogVisible.value = true
}

// 编辑自提点
const handleEditPickupPoint = (row: any) => {
  dialogType.value = 'edit'
  Object.assign(pickupPointForm, {
    Code: row.Code,
    Name: row.Name,
    Address: row.Address,
    ContactPerson: row.ContactPerson,
    ContactPhone: row.ContactPhone,
    Remark: row.Remark,
    IsEnabled: row.IsEnabled
  })
  dialogVisible.value = true
}

// 切换自提点状态
const handleToggleStatus = (row: any) => {
  const action = row.IsEnabled ? '关闭' : '开启'
  ElMessageBox.confirm(`确认${action}该自提点吗？`, '提示', {
    confirmButtonText: '确定',
    cancelButtonText: '取消',
    type: 'warning'
  }).then(() => {
    row.IsEnabled = !row.IsEnabled
    ElMessage.success(`${action}成功`)
  })
}

// 保存自提点
const handleSavePickupPoint = async () => {
  if (!pickupPointForm.Name || !pickupPointForm.Address || !pickupPointForm.ContactPerson || !pickupPointForm.ContactPhone) {
    ElMessage.warning('请填写必填项')
    return
  }
  let res
  if (dialogType.value === 'add') {
    res = await addPickupPoint(pickupPointForm)
  } else {
    res = await updatePickupPoint(pickupPointForm.Code, pickupPointForm)
  }
  if (res.status === 200 || res.status === 201) {
    ElMessage.success(dialogType.value === 'add' ? '新增成功' : '修改成功')
    dialogVisible.value = false
    fetchPickupPoints()
  } else {
    ElMessage.error('操作失败')
  }
}

// 查看订单
const handleViewOrder = async (row: any) => {
  // 根据id查询订单详情
  const res = await reqCheckOrder(row.Id || row.id)
  if (res.status === 200) {
    currentOrder.value = res.data
    orderDialogVisible.value = true
  } else {
    ElMessage.error('获取订单详情失败')
  }
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
  pageSizeNo.value = val
  getPickupOrderList()
}

const handleCurrentChange = (val: number) => {
  currentPageNo.value = val
  getPickupOrderList()
}

const getPickupOrderList = async () => {
  try {
    const params = {
      PageNumber: currentPageNo.value,
      PageSize: pageSizeNo.value,
      // 可根据实际接口补充其它查询参数
    }
    const res = await reqOrderlist(params)
    // 假设API返回的数据结构是 { code: 200, data: { records: [...], total: ... } }
    if (res.status === 200) {
      orderList.value = res.data.records || res.data
      if (res.headers && res.headers['x-pagination']) {
        const pagination = JSON.parse(res.headers['x-pagination'])
        currentPageNo.value = pagination.PageIndex || 1
        pageSizeNo.value = pagination.PageSize || 10
        total.value = pagination.TotalCount || 0
      } else {
        total.value = orderList.value.length
      }
    } else {
      ElMessage.error('获取自提订单列表失败')
    }
  } catch (error) {
    console.error('请求自提订单列表出错:', error)
    ElMessage.error('请求自提订单列表出错')
  }
}

// 页面加载时获取自提点列表
const fetchPickupPoints = async () => {
  const res = await getPickupPoints()
  if (res.status === 200) {
    pickupPoints.value = res.data
  }
}

onMounted(() => {
  fetchPickupPoints()
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
