<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ isEdit ? '编辑库存' : isView ? '查看库存' : '新增库存' }}</span>
        <el-button @click="goBack">返回列表</el-button>
      </div>
    </template>

    <el-form
      ref="formRef"
      :model="form"
      :rules="rules"
      label-width="120px"
      :disabled="isView"
      v-loading="loading"
    >
      <!-- 基本信息 -->
      <el-divider content-position="left">基本信息</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="经销商名称" prop="dealerName">
            <el-input v-model="form.dealerName" placeholder="经销商名称" :disabled="true" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="经销商编码" prop="dealerCode">
            <el-input v-model="form.dealerCode" placeholder="经销商编码" :disabled="true" />
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 库存信息 -->
      <el-divider content-position="left">库存信息</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="调整类型" prop="adjustType">
            <el-select v-model="form.adjustType" placeholder="请选择调整类型" style="width: 100%">
              <el-option label="业绩调整" value="1" />
              <el-option label="库存盘点" value="6" />              
            </el-select>
          </el-form-item>
        </el-col>  
        <el-col :span="8">
          <el-form-item label="当前配额" prop="currentQuota">
            <el-input-number
              v-model="form.currentQuota"
              :min="0"
              :precision="0"
              style="width: 100%"
              placeholder="当前配额"
              :disabled="true"
            />
          </el-form-item>
        </el-col>         
      </el-row>

      <el-row :gutter="20">
        
        <el-col :span="8">
          <el-form-item label="调整数量" prop="adjustQuantity">
            <el-input-number
              v-model="form.adjustQuantity"
              :precision="0"
              style="width: 100%"
              placeholder="正数为增加，负数为减少"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="调整后配额" prop="newQuota">
            <el-input-number
              v-model="form.newQuota"
              :min="0"
              :precision="0"
              style="width: 100%"
              placeholder="调整后配额"
              :disabled="true"
            />
          </el-form-item>
        </el-col>
      </el-row>
      <!-- 备注信息 -->
      <el-divider content-position="left">备注信息</el-divider>
      
      <el-form-item label="备注" prop="remark">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="4"
          placeholder="请输入备注信息"
        />
      </el-form-item>

      <!-- 操作按钮 -->
      <el-form-item v-if="!isView">
        <el-button type="primary" @click="submitForm">保存</el-button>
        <el-button @click="resetForm">重置</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, watch, computed } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { reqGetDealerDetail } from '@/api/organization/dealer/index'
import { updateDealerQuota } from '@/api/stock/dealer/index'

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 表单数据
const form = reactive({
  id: '',
  dealerName: '',
  dealerCode: '',
  currentQuota: 0,
  adjustQuantity: 0,
  newQuota: 0,
  adjustType: '',
  adjustReason: '',
  adjustPeriod: '',
  effectiveDate: '',
  expiryDate: '',
  remark: ''
})

// 表单验证规则
const rules: FormRules = {
  dealerName: [
    { required: true, message: '经销商名称不能为空', trigger: 'blur' }
  ],
  adjustQuantity: [
    { required: true, message: '请输入调整数量', trigger: 'blur' }
  ],
  adjustType: [
    { required: true, message: '请选择调整类型', trigger: 'change' }
  ],
  adjustReason: [
    { required: true, message: '请选择调整原因', trigger: 'change' }
  ]
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)
const loading = ref(false)

// 计算调整后的配额
const newQuota = computed(() => {
  return form.currentQuota + form.adjustQuantity
})

// 监听调整数量变化，自动计算新配额
watch(() => form.adjustQuantity, () => {
  form.newQuota = newQuota.value
})

// 查询经销商详情
const loadDealerDetail = async (dealerId: number) => {
  loading.value = true
  try {
    const res = await reqGetDealerDetail(dealerId)
    if (res.status === 200 && res.data) {
      const dealerData = res.data
      // 更新表单数据
      form.dealerName = dealerData.Name || dealerData.name || ''
      form.dealerCode = dealerData.MatchId || dealerData.MatchId || ''
      form.currentQuota = dealerData.Quota || dealerData.quota || 0
      form.newQuota = dealerData.Quota || dealerData.quota || 0
    } else {
      ElMessage.error('获取经销商详情失败')
    }
  } catch (error) {
    console.error('获取经销商详情出错:', error)
    ElMessage.error('获取经销商详情失败')
  } finally {
    loading.value = false
  }
}

// 初始化表单
const initForm = async (data?: any, viewMode = false) => {
  isEdit.value = !!data
  isView.value = viewMode
  
  if (data) {
    // 编辑模式，先重置表单
    resetForm()
    
    // 设置基本信息
    form.id = data.Id || data.id
    
    // 如果有经销商ID，查询经销商详情
    if (form.id) {
      await loadDealerDetail(Number(form.id))
    } else {
      // 如果没有ID，使用传入的数据
      form.dealerName = data.Name || data.dealerName || ''
      form.dealerCode = data.Code || data.dealerCode || ''
      form.currentQuota = data.Quota || data.currentQuota || 0
      form.newQuota = data.Quota || data.currentQuota || 0
    }
    
    // 重置调整相关字段
    form.adjustQuantity = 0
    form.adjustType = ''
    form.adjustReason = ''
    form.adjustPeriod = ''
    form.effectiveDate = ''
    form.expiryDate = ''
    form.remark = ''
  } else {
    // 新增模式，重置表单
    resetForm()
  }
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()

    // 验证调整后配额不能为负数
    if (form.newQuota < 0) {
      ElMessage.error('调整后配额不能为负数')
      return
    }

    const submitData = {
      Id: form.id,
      Quota: form.adjustQuantity,
      OperationType: form.adjustType,
      Remark: form.remark
    }

    await updateDealerQuota(submitData)
    ElMessage.success('配额调整成功')
    goBack()
  } catch (error) {
    ElMessage.error('配额调整失败')
    console.error('提交表单错误:', error)
  }
}

// 重置表单
const resetForm = () => {
  // 只重置可编辑字段
  form.adjustQuantity = 0
  form.remark = ''
  // 如有其它可编辑字段，可在此补充
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

// 暴露方法给父组件
defineExpose({
  initForm
})
</script>

<style lang="scss" scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.el-form {
  .el-form-item {
    margin-bottom: 18px;
  }
}
</style> 