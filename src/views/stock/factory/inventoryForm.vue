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
          <el-form-item label="产品名称" prop="materialName">
            <el-input v-model="form.materialName" placeholder="请输入材料名称" />
          </el-form-item>
        </el-col>        
      </el-row>

      <el-row :gutter="20">        
        <el-col :span="12">
          <el-form-item label="仓库位置" prop="warehouseId">
            <el-select 
              v-model="form.warehouseId" 
              placeholder="请选择仓库" 
              filterable 
              clearable
              style="width: 100%"
            >
              <el-option
                v-for="warehouse in warehouseList"
                :key="warehouse.Id"
                :label="warehouse.Name"
                :value="warehouse.Id"
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
              <el-option label="入库" value="in" />
              <el-option label="出库" value="out" />
              <el-option label="盘点调整" value="adjust" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="调整原因" prop="adjustReason">
            <el-select v-model="form.adjustReason" placeholder="请选择调整原因" style="width: 100%">
              <el-option label="正常入库" value="normal_in" />
              <el-option label="退货入库" value="return_in" />
              <el-option label="正常出库" value="normal_out" />
              <el-option label="损坏出库" value="damage_out" />
              <el-option label="盘点差异" value="inventory_diff" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="当前库存" prop="quantity">
            <el-input-number
              v-model="form.quantity"
              :min="0"
              :precision="0"
              style="width: 100%"
              placeholder="当前库存数量"
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
              placeholder="正数为入库，负数为出库"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="单位" prop="unit">
            <el-input v-model="form.unit" placeholder="请输入单位" />
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { getFactoryList } from '@/api/stock/factory/index'

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 表单数据
const form = reactive({
  id: '',
  materialName: '',
  materialCode: '',
  specification: '',
  warehouseId: '',
  quantity: 0,
  adjustQuantity: 0,
  unit: '',
  warningQuantity: 0,
  adjustType: '',
  adjustReason: '',
  inboundDate: '',
  remark: ''
})

// 表单验证规则
const rules: FormRules = {
  materialName: [
    { required: true, message: '请输入材料名称', trigger: 'blur' }
  ],
  materialCode: [
    { required: true, message: '请输入材料编码', trigger: 'blur' }
  ],
  specification: [
    { required: true, message: '请输入规格', trigger: 'blur' }
  ],
  warehouseId: [
    { required: true, message: '请选择仓库', trigger: 'change' }
  ],
  adjustQuantity: [
    { required: true, message: '请输入调整数量', trigger: 'blur' }
  ],
  adjustType: [
    { required: true, message: '请选择调整类型', trigger: 'change' }
  ],
  adjustReason: [
    { required: true, message: '请选择调整原因', trigger: 'change' }
  ],
  unit: [
    { required: true, message: '请输入单位', trigger: 'blur' }
  ]
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)

// 仓库列表（工厂列表）
const warehouseList = ref<any[]>([])

// 加载工厂列表
const loadWarehouseList = async () => {
  try {
    const res = await getFactoryList()
    warehouseList.value = res.data || []
  } catch {
    warehouseList.value = []
  }
}

// 初始化表单
const initForm = (data?: any, viewMode = false) => {
  isEdit.value = !!data
  isView.value = viewMode
  loadWarehouseList()
  if (data) {
    // 编辑模式，填充数据
    Object.assign(form, data)
  } else {
    // 新增模式，重置表单
    resetForm()
  }
}

// 页面挂载时也加载一次工厂列表
onMounted(() => {
  loadWarehouseList()
})

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    if (isEdit.value) {
      // 编辑模式
      // await reqUpdateInventory(submitData)
      ElMessage.success('更新成功')
    } else {
      // 新增模式
      // await reqAddInventory(submitData)
      ElMessage.success('添加成功')
    }
    
    // 返回列表
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
    materialName: '',
    materialCode: '',
    specification: '',
    warehouseId: '',
    quantity: 0,
    adjustQuantity: 0,
    unit: '',
    warningQuantity: 0,
    adjustType: '',
    adjustReason: '',
    inboundDate: '',
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
</script>

<style lang="scss" scoped>
.card-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
}
</style> 