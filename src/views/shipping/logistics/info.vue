<template>
  <div class="app-container">
    <!-- 物流单号查询 -->
    <el-card class="search-wrapper">
      <el-form :model="queryForm" ref="queryFormRef" :inline="true">
        <el-form-item label="物流单号">
          <el-input v-model="queryForm.trackingNo" placeholder="请输入物流单号" clearable />
        </el-form-item>
        <el-form-item label="物流公司">
          <el-select v-model="queryForm.logisticsCompany" placeholder="请选择物流公司" clearable>
            <el-option
              v-for="item in logisticsCompanies"
              :key="item.code"
              :label="item.name"
              :value="item.code"
            />
          </el-select>
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 物流信息展示 -->
    <el-card v-if="logisticsInfo" class="info-wrapper">
      <template #header>
        <div class="card-header">
          <span>物流信息</span>
          <el-button type="primary" link @click="handleRefresh">刷新</el-button>
        </div>
      </template>
      <el-descriptions :column="2" border>
        <el-descriptions-item label="物流单号">{{ logisticsInfo.trackingNo }}</el-descriptions-item>
        <el-descriptions-item label="物流公司">{{ getLogisticsCompanyName(logisticsInfo.logisticsCompany) }}</el-descriptions-item>
        <el-descriptions-item label="发货时间">{{ logisticsInfo.shipTime }}</el-descriptions-item>
        <el-descriptions-item label="预计送达">{{ logisticsInfo.estimatedDeliveryTime }}</el-descriptions-item>
        <el-descriptions-item label="收货人">{{ logisticsInfo.receiver }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ logisticsInfo.phone }}</el-descriptions-item>
        <el-descriptions-item label="收货地址" :span="2">{{ logisticsInfo.address }}</el-descriptions-item>
      </el-descriptions>

      <div class="tracking-info">
        <h3>物流轨迹</h3>
        <el-timeline>
          <el-timeline-item
            v-for="(activity, index) in logisticsInfo.tracking"
            :key="index"
            :timestamp="activity.time"
            :type="index === 0 ? 'primary' : ''"
          >
            {{ activity.content }}
          </el-timeline-item>
        </el-timeline>
      </div>
    </el-card>

    <!-- 物流公司管理 -->
    <el-card class="company-wrapper">
      <template #header>
        <div class="card-header">
          <span>物流公司管理</span>
          <el-button type="primary" @click="handleAddCompany">新增物流公司</el-button>
        </div>
      </template>

      <el-table :data="logisticsCompanies" border style="width: 100%">
        <el-table-column prop="name" label="公司名称" />
        <el-table-column prop="code" label="公司代码" />
        <el-table-column prop="contact" label="联系人" />
        <el-table-column prop="phone" label="联系电话" />
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'">
              {{ row.status === 'active' ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEditCompany(row)">编辑</el-button>
            <el-button type="primary" link @click="handleToggleStatus(row)">
              {{ row.status === 'active' ? '禁用' : '启用' }}
            </el-button>
          </template>
        </el-table-column>
      </el-table>
    </el-card>

    <!-- 物流公司编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增物流公司' : '编辑物流公司'"
      width="500px"
    >
      <el-form :model="companyForm" label-width="100px">
        <el-form-item label="公司名称" required>
          <el-input v-model="companyForm.name" placeholder="请输入公司名称" />
        </el-form-item>
        <el-form-item label="公司代码" required>
          <el-input v-model="companyForm.code" placeholder="请输入公司代码" />
        </el-form-item>
        <el-form-item label="联系人">
          <el-input v-model="companyForm.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="companyForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="companyForm.status"
            :active-value="'active'"
            :inactive-value="'inactive'"
          />
        </el-form-item>
      </el-form>
      <template #footer>
        <div class="dialog-footer">
          <el-button @click="dialogVisible = false">取 消</el-button>
          <el-button type="primary" @click="handleSaveCompany">确 定</el-button>
        </div>
      </template>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

// 查询表单
const queryForm = reactive({
  trackingNo: '',
  logisticsCompany: ''
})

// 物流公司列表
const logisticsCompanies = ref([
  {
    name: '顺丰速运',
    code: 'SF',
    contact: '张三',
    phone: '13800138000',
    status: 'active'
  },
  {
    name: '中通快递',
    code: 'ZTO',
    contact: '李四',
    phone: '13800138001',
    status: 'active'
  },
  {
    name: '圆通速递',
    code: 'YTO',
    contact: '王五',
    phone: '13800138002',
    status: 'inactive'
  }
])

// 物流信息
const logisticsInfo = ref(null)

// 对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const companyForm = reactive({
  name: '',
  code: '',
  contact: '',
  phone: '',
  status: 'active'
})

// 获取物流公司名称
const getLogisticsCompanyName = (code: string) => {
  const company = logisticsCompanies.value.find(item => item.code === code)
  return company ? company.name : code
}

// 查询物流信息
const handleQuery = () => {
  if (!queryForm.trackingNo) {
    ElMessage.warning('请输入物流单号')
    return
  }
  // TODO: 调用物流查询接口
  logisticsInfo.value = {
    trackingNo: queryForm.trackingNo,
    logisticsCompany: queryForm.logisticsCompany,
    shipTime: '2024-01-20 10:00:00',
    estimatedDeliveryTime: '2024-01-21 18:00:00',
    receiver: '张先生',
    phone: '138****8888',
    address: '北京市朝阳区望京街道xxx小区',
    tracking: [
      {
        time: '2024-01-20 10:00:00',
        content: '快件已签收，签收人：张先生'
      },
      {
        time: '2024-01-20 09:30:00',
        content: '快件已到达【北京朝阳区望京营业点】'
      },
      {
        time: '2024-01-19 20:00:00',
        content: '快件已从【北京转运中心】发出'
      }
    ]
  }
}

// 重置查询
const resetQuery = () => {
  queryForm.trackingNo = ''
  queryForm.logisticsCompany = ''
  logisticsInfo.value = null
}

// 刷新物流信息
const handleRefresh = () => {
  handleQuery()
}

// 新增物流公司
const handleAddCompany = () => {
  dialogType.value = 'add'
  Object.assign(companyForm, {
    name: '',
    code: '',
    contact: '',
    phone: '',
    status: 'active'
  })
  dialogVisible.value = true
}

// 编辑物流公司
const handleEditCompany = (row: any) => {
  dialogType.value = 'edit'
  Object.assign(companyForm, row)
  dialogVisible.value = true
}

// 切换物流公司状态
const handleToggleStatus = (row: any) => {
  row.status = row.status === 'active' ? 'inactive' : 'active'
  ElMessage.success(`${row.status === 'active' ? '启用' : '禁用'}成功`)
}

// 保存物流公司
const handleSaveCompany = () => {
  if (!companyForm.name || !companyForm.code) {
    ElMessage.warning('请填写必填项')
    return
  }
  // TODO: 调用保存接口
  ElMessage.success(dialogType.value === 'add' ? '新增成功' : '修改成功')
  dialogVisible.value = false
}
</script>

<style lang="scss" scoped>
.search-wrapper,
.info-wrapper,
.company-wrapper {
  margin-bottom: 20px;
}

.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.tracking-info {
  margin-top: 20px;
  h3 {
    margin-bottom: 20px;
    font-weight: normal;
    color: #666;
  }
}

:deep(.el-timeline-item__content) {
  color: #666;
}
</style>
