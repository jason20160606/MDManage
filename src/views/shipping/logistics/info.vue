<template>
  <div class="app-container">
    <!-- 物流公司管理 -->
    <el-card class="company-wrapper">
      <template #header>
        <div class="card-header">
          <span>物流公司管理</span>
          <el-button type="primary" @click="handleAddCompany">新增物流公司</el-button>
        </div>
      </template>

      <el-table :data="logisticsCompanies" border style="width: 100%">
        <el-table-column prop="Name" label="公司名称" />
        <el-table-column prop="Code" label="公司代码" />
        <el-table-column prop="ContactName" label="联系人" />
        <el-table-column prop="ContactPhone" label="联系电话" />
        <el-table-column prop="Remark" label="备注" />
        <el-table-column prop="IsEnabled" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.IsEnabled ? 'success' : 'info'">
              {{ row.IsEnabled ? '启用' : '禁用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="240">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEditCompany(row)">编辑</el-button>
            <el-button type="primary" link @click="handleDeleteCompany(row)">删除</el-button>
            <el-button type="primary" link @click="handleToggleStatus(row)">
              {{ row.isEnabled ? '禁用' : '启用' }}
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
          <el-input v-model="companyForm.contactName" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话">
          <el-input v-model="companyForm.contactPhone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="备注">
          <el-input v-model="companyForm.remark" placeholder="请输入备注" />
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="companyForm.isEnabled"
            :active-value="true"
            :inactive-value="false"
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { getLogisticsCompanies, addLogisticsCompany, updateLogisticsCompany, deleteLogisticsCompany } from '@/api/shipping'

// 物流公司列表
const logisticsCompanies = ref<any[]>([])

// 对话框
const dialogVisible = ref(false)
const dialogType = ref<'add' | 'edit'>('add')
const companyForm = reactive({
  id: undefined,
  name: '',
  code: '',
  contactName: '',
  contactPhone: '',
  remark: '',
  isEnabled: true
})


// 页面加载时获取物流公司列表
const fetchLogisticsCompanies = async () => {
  const res = await getLogisticsCompanies()
  if (res.status === 200) {
    logisticsCompanies.value = res.data
  }
}

onMounted(() => {
  fetchLogisticsCompanies()
})


// 新增物流公司
const handleAddCompany = () => {
  dialogType.value = 'add'
  Object.assign(companyForm, {
    id: undefined,
    name: '',
    code: '',
    contactName: '',
    contactPhone: '',
    remark: '',
    isEnabled: true
  })
  dialogVisible.value = true
}

// 编辑物流公司
const handleEditCompany = (row: any) => {
  dialogType.value = 'edit'
  Object.assign(companyForm, {
    id: row.id,
    name: row.name,
    code: row.code,
    contactName: row.contactName,
    contactPhone: row.contactPhone,
    remark: row.remark,
    isEnabled: row.isEnabled
  })
  dialogVisible.value = true
}

// 切换物流公司状态
const handleToggleStatus = (row: any) => {
  row.isEnabled = !row.isEnabled
  ElMessage.success(`${row.isEnabled ? '启用' : '禁用'}成功`)
}

// 保存物流公司
const handleSaveCompany = async () => {
  if (!companyForm.name || !companyForm.code) {
    ElMessage.warning('请填写必填项')
    return
  }
  let res
  if (dialogType.value === 'add') {
    res = await addLogisticsCompany(companyForm)
  } else {
    const idOrCode = companyForm.id ?? companyForm.code
    res = await updateLogisticsCompany(idOrCode, companyForm)
  }
  if (res.status === 200 || res.status === 201) {
    ElMessage.success(dialogType.value === 'add' ? '新增成功' : '修改成功')
    dialogVisible.value = false
    fetchLogisticsCompanies()
  } else {
    ElMessage.error('操作失败')
  }
}

// 删除物流公司
const handleDeleteCompany = async (row: any) => {
  const res = await deleteLogisticsCompany(row.id ?? row.code)
  if (res.status === 200) {
    ElMessage.success('删除成功')
    fetchLogisticsCompanies()
  } else {
    ElMessage.error('删除失败')
  }
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
