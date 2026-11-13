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

      <!-- 额度总览：通用 + 4 个特殊池 -->
      <el-row :gutter="20">
        <el-col :span="6">
          <el-form-item label="通用额度">
            <el-input :model-value="form.quota" disabled>
              <template #append>箱</template>
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="特殊额度1">
            <el-input :model-value="form.specialQuota1" disabled>
              <template #append>箱</template>
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="特殊额度2">
            <el-input :model-value="form.specialQuota2" disabled>
              <template #append>箱</template>
            </el-input>
          </el-form-item>
        </el-col>
        <el-col :span="6">
          <el-form-item label="特殊额度3">
            <el-input :model-value="form.specialQuota3" disabled>
              <template #append>箱</template>
            </el-input>
          </el-form-item>
        </el-col>
      </el-row>
      <el-row :gutter="20">
        <el-col :span="6">
          <el-form-item label="特殊额度4">
            <el-input :model-value="form.specialQuota4" disabled>
              <template #append>箱</template>
            </el-input>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="额度类型" prop="quotaSlot">
            <el-select v-model="form.quotaSlot" placeholder="请选择要调整的额度" style="width: 100%">
              <el-option label="通用额度" :value="0" />
              <el-option label="特殊额度1" :value="1" />
              <el-option label="特殊额度2" :value="2" />
              <el-option label="特殊额度3" :value="3" />
              <el-option label="特殊额度4" :value="4" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="调整类型" prop="adjustType">
            <el-select v-model="form.adjustType" placeholder="请选择调整类型" style="width: 100%">
              <el-option label="业绩调整" value="1" />
              <el-option label="库存盘点" value="6" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="当前额度">
            <el-input-number
              :model-value="currentQuota"
              :precision="0"
              style="width: 100%"
              :disabled="true"
            />
          </el-form-item>
        </el-col>
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
          <el-form-item label="调整后额度">
            <el-input-number
              :model-value="newQuota"
              :precision="0"
              style="width: 100%"
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
import { ref, reactive, computed } from 'vue'
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
  // 各额度池当前余额（箱）
  quota: 0,
  specialQuota1: 0,
  specialQuota2: 0,
  specialQuota3: 0,
  specialQuota4: 0,
  // 本次调整
  quotaSlot: 0,
  adjustQuantity: 0,
  adjustType: '',
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
  quotaSlot: [
    { required: true, message: '请选择额度类型', trigger: 'change' }
  ]
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)
const loading = ref(false)

// 当前选中池的余额
const currentQuota = computed(() => {
  switch (form.quotaSlot) {
    case 1: return form.specialQuota1
    case 2: return form.specialQuota2
    case 3: return form.specialQuota3
    case 4: return form.specialQuota4
    default: return form.quota
  }
})

// 调整后的余额
const newQuota = computed(() => currentQuota.value + (form.adjustQuantity || 0))

// 当前额度池名称
const slotName = computed(() => {
  return form.quotaSlot === 0 ? '通用额度' : `特殊额度${form.quotaSlot}`
})

// 查询经销商详情
const loadDealerDetail = async (dealerId: number) => {
  loading.value = true
  try {
    const res = await reqGetDealerDetail(dealerId)
    const dealerData = res
    if (dealerData) {
      form.dealerName = dealerData.Name || ''
      form.dealerCode = dealerData.MatchId || ''
      form.quota = Number(dealerData.Quota || 0)
      form.specialQuota1 = Number(dealerData.SpecialQuota1 || 0)
      form.specialQuota2 = Number(dealerData.SpecialQuota2 || 0)
      form.specialQuota3 = Number(dealerData.SpecialQuota3 || 0)
      form.specialQuota4 = Number(dealerData.SpecialQuota4 || 0)
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
    resetForm()
    form.id = data.Id || data.id
    
    if (form.id) {
      await loadDealerDetail(Number(form.id))
    } else {
      form.dealerName = data.Name || ''
      form.dealerCode = data.MatchId || ''
      form.quota = Number(data.Quota || 0)
      form.specialQuota1 = Number(data.SpecialQuota1 || 0)
      form.specialQuota2 = Number(data.SpecialQuota2 || 0)
      form.specialQuota3 = Number(data.SpecialQuota3 || 0)
      form.specialQuota4 = Number(data.SpecialQuota4 || 0)
    }
    
    form.quotaSlot = 0
    form.adjustQuantity = 0
    form.adjustType = ''
    form.remark = ''
  } else {
    resetForm()
  }
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()

    if (newQuota.value < 0) {
      ElMessage.error(`${slotName.value}调整后为 ${newQuota.value}，额度不能为负数`)
      return
    }
    if (!form.adjustQuantity) {
      ElMessage.warning('请输入调整数量')
      return
    }

    const submitData = {
      Id: form.id,
      Quota: form.adjustQuantity,
      QuotaSlot: form.quotaSlot,
      OperationType: form.adjustType,
      Remark: form.remark
    }

    await updateDealerQuota(submitData)
    ElMessage.success(`${slotName.value}调整成功`)
    goBack()
  } catch (error) {
    console.error('提交表单错误:', error)
  }
}

// 重置表单
const resetForm = () => {
  form.adjustQuantity = 0
  form.remark = ''
  form.adjustType = ''
  form.quotaSlot = 0
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
