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
    >
      <!-- 基本信息 -->
      <el-divider content-position="left">基本信息</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="产品名称" prop="productName">
            <el-input v-model="form.productName" placeholder="请输入产品名称" :disabled="true" />
          </el-form-item>
        </el-col>        
      </el-row>

      <el-row :gutter="20">        
        <el-col :span="12">
          <el-form-item label="仓库位置" prop="factoryId">
            <el-select 
              v-model="form.factoryId" 
              placeholder="请选择仓库" 
              filterable 
              clearable
              style="width: 100%"
              :disabled="true"
            >
              <el-option
                v-for="factory in factoryList"
                :key="factory.Id"
                :label="factory.Name"
                :value="factory.Id"
              />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 库存信息 -->
      <el-divider content-position="left">库存信息</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="调整类型" prop="adjustType">
            <el-select v-model="form.adjustType" placeholder="请选择调整类型" style="width: 100%">
              <el-option label="生产入库" value="1" />              
              <el-option label="退货" value="3" />
              <el-option label="损耗" value="4" />
            </el-select>
          </el-form-item>
        </el-col>       
        <el-col :span="8">
          <el-form-item label="当前库存" prop="quantity">
            <el-input
              v-model="form.quantity"
              :min="0"
              :precision="0"
              style="width: 100%"
              placeholder="当前库存数量"
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
              placeholder="正数为入库，负数为出库"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="调整后数量">
            <el-input
              :value="newQuantity"
              :disabled="true"
              style="width: 100%"
              placeholder="调整后数量"
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
import { getFactoryStockDetail, updateFactoryStock, createFactoryStock } from '@/api/stock/factory/index'

// 定义props
const props = defineProps<{
  factoryList?: any[]
}>()

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 表单数据
const form = reactive({
  id: '',
  productName: '',
  factoryId: '',
  factoryName: '',
  quantity: 0,
  lockedQuantity: 0,
  warningThreshold: 0,
  createdAt: '',
  updatedAt: '',
  adjustQuantity: 0,
  adjustType: '',
  remark: ''
})

// 表单验证规则
const rules: FormRules = {
  productName: [
    { required: true, message: '请输入材料名称', trigger: 'blur' }
  ],
  factoryId: [
    { required: true, message: '请选择仓库', trigger: 'change' }
  ],
  adjustQuantity: [
    { required: true, message: '请输入调整数量', trigger: 'blur' }
  ],
  adjustType: [
    { required: true, message: '请选择调整类型', trigger: 'change' }
  ]
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)

// 仓库列表（工厂列表）
const factoryList = ref<any[]>([])

// 监听props中的工厂列表变化
watch(() => props.factoryList, (newList) => {
  if (newList && newList.length > 0) {
    factoryList.value = newList
  }
}, { immediate: true })

// 初始化表单
const initForm = async (data?: any, viewMode = false) => {
  isEdit.value = !!data
  isView.value = viewMode
  if (data) {
    // 编辑模式，先重置表单
    resetForm()
    // 如果有id，查询库存详情
    if (data.Id) {
      const res = await getFactoryStockDetail(data.Id)
      if (res && res.data) {
        Object.assign(form, {
          id: res.data.Id,
          productName: res.data.ProductName,
          factoryId: res.data.FactoryId,
          factoryName: res.data.FactoryName,
          quantity: res.data.Quantity,
          lockedQuantity: res.data.LockedQuantity,
          warningThreshold: res.data.WarningThreshold,
          createdAt: res.data.CreatedAt,
          updatedAt: res.data.UpdatedAt,
          adjustQuantity: 0,
          adjustType: '',
          remark: ''
        })
      } else {
        Object.assign(form, data)
      }
    } else {
      Object.assign(form, data)
    }
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
    if (isEdit.value) {
      // 编辑模式，调用更新接口
      await updateFactoryStock(form.id, {
        adjustQuantity: form.adjustQuantity,
        adjustType: form.adjustType,
        remark: form.remark
        // 可补充其他字段
      })
      ElMessage.success('更新成功')
    } else {
      // 新增模式，调用新增接口
      await createFactoryStock({
        productName: form.productName,
        factoryId: form.factoryId,
        adjustQuantity: form.adjustQuantity,
        adjustType: form.adjustType,
        remark: form.remark
        // 可补充其他字段
      })
      ElMessage.success('添加成功')
    }
    goBack()
  } catch (error) {
    ElMessage.error('表单验证失败')
    console.error('提交表单错误:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (!formRef.value) return
  
  formRef.value.resetFields()
  Object.assign(form, {
    id: '',
    productName: '',
    factoryId: '',
    factoryName: '',
    quantity: 0,
    lockedQuantity: 0,
    warningThreshold: 0,
    createdAt: '',
    updatedAt: '',
    adjustQuantity: 0,
    adjustType: '',
    remark: ''
  })
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

// 暴露方法给父组件
defineExpose({
  initForm
})

const newQuantity = computed(() => Number(form.quantity) + Number(form.adjustQuantity || 0))
</script>

<style lang="scss" scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style> 