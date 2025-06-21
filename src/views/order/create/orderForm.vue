<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ isEdit ? '编辑订单' : isView ? '查看订单' : '新增订单' }}</span>
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
        <el-col :span="12" v-if="isEdit">
          <el-form-item label="订单编号" prop="orderNo">
            <el-input v-model="form.orderNo" placeholder="系统自动生成" :disabled="true" />
          </el-form-item>
        </el-col>
        <el-col :span="isEdit ? 12 : 12">
          <el-form-item label="下单时间" prop="orderDate">
            <el-date-picker
              v-model="form.orderDate"
              type="datetime"
              placeholder="选择下单时间"
              style="width: 100%"
            />
          </el-form-item>
        </el-col>
        <el-col :span="isEdit ? 12 : 12">
          <el-form-item label="经销商" prop="dealerId">
            <el-select 
              v-model="form.dealerId" 
              placeholder="请选择经销商" 
              filterable 
              clearable
              style="width: 100%"
              @change="handleDealerChange"
            >
              <el-option
                v-for="dealer in dealerList"
                :key="dealer.id"
                :label="dealer.name"
                :value="dealer.id"
              />
            </el-select>
          </el-form-item>
        </el-col>        
      </el-row>

      <!-- 收货信息 -->
      <el-divider content-position="left">收货信息</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="收货人" prop="receiverName">
            <el-input v-model="form.receiverName" placeholder="请输入收货人姓名" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="联系电话" prop="receiverPhone">
            <el-input v-model="form.receiverPhone" placeholder="请输入联系电话" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="收货地址" prop="receiverAddress">
            <el-input v-model="form.receiverAddress" placeholder="请输入收货地址" />
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 产品信息 -->
      <el-divider content-position="left">产品信息</el-divider>
      
      <div class="product-section">
        <div class="product-header">
          <span>产品清单</span>
          <el-button type="primary" size="small" @click="addProduct" v-if="!isView">添加产品</el-button>
        </div>
        
        <el-table :data="form.orderItems" border style="width: 100%">
          <el-table-column type="index" label="序号" width="60" />
          <el-table-column label="产品名称" min-width="200">
            <template #default="{ row, $index }">
              <el-select 
                v-model="row.productId" 
                placeholder="请选择产品" 
                filterable 
                clearable
                style="width: 100%"
                @change="(value) => handleProductChange(value, $index)"
              >
                <el-option
                  v-for="product in productList"
                  :key="product.id"
                  :label="product.name"
                  :value="product.id"
                />
              </el-select>
            </template>
          </el-table-column>
          <el-table-column label="规格" width="150">
            <template #default="{ row }">
              <span>{{ row.specification || '-' }}</span>
            </template>
          </el-table-column>          
          <el-table-column label="数量" width="120">
            <template #default="{ row, $index }">
              <el-input-number
                v-model="row.quantity"
                :min="1"
                :precision="0"
                style="width: 100%"
                @change="() => calculateRowTotal($index)"
              />
            </template>
          </el-table-column>          
          <el-table-column label="操作" width="100" v-if="!isView">
            <template #default="{ $index }">
              <el-button type="danger" link @click="removeProduct($index)">删除</el-button>
            </template>
          </el-table-column>
        </el-table>
      </div>

      <!-- 订单汇总 -->
      <el-divider content-position="left">订单汇总</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="产品总数">
            <span class="summary-item">{{ totalQuantity }} 件</span>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="订单总量">
            <span class="summary-item total-amount">{{ totalAmount }}</span>
          </el-form-item>
        </el-col>  
        <el-col :span="8">
          <el-form-item label="运费类型" prop="paymentMethod">
            <el-select v-model="form.paymentMethod" placeholder="请选择付款方式" style="width: 100%">
              <el-option label="到付" value="cash" />
              <el-option label="现付" value="bank_transfer" />
              <el-option label="自提" value="check" />              
            </el-select>
          </el-form-item>
        </el-col>              
      </el-row>
      <!-- 备注信息 -->
      <el-divider content-position="left">备注信息</el-divider>
      
      <el-form-item label="订单备注" prop="remark">
        <el-input
          v-model="form.remark"
          type="textarea"
          :rows="4"
          placeholder="请输入订单备注信息"
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

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 表单数据
const form = reactive({
  id: '',
  orderNo: '',
  orderDate: '',
  dealerId: '',
  orderStatus: 'pending',
  contactPerson: '',
  contactPhone: '',
  contactEmail: '',
  receiverName: '',
  receiverPhone: '',
  receiverAddress: '',
  orderItems: [],
  discountAmount: 0,
  paymentMethod: '',
  expectedDelivery: '',
  remark: ''
})

// 表单验证规则
const rules: FormRules = {
  dealerId: [
    { required: true, message: '请选择经销商', trigger: 'change' }
  ],
  orderStatus: [
    { required: true, message: '请选择订单状态', trigger: 'change' }
  ],
  contactPerson: [
    { required: true, message: '请输入联系人', trigger: 'blur' }
  ],
  contactPhone: [
    { required: true, message: '请输入联系电话', trigger: 'blur' }
  ],
  receiverName: [
    { required: true, message: '请输入收货人姓名', trigger: 'blur' }
  ],
  receiverPhone: [
    { required: true, message: '请输入收货人联系电话', trigger: 'blur' }
  ],
  receiverAddress: [
    { required: true, message: '请输入收货地址', trigger: 'blur' }
  ],
  paymentMethod: [
    { required: true, message: '请选择付款方式', trigger: 'change' }
  ]
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)

// 经销商列表
const dealerList = ref<any[]>([])

// 产品列表
const productList = ref<any[]>([])

// 计算属性
const totalQuantity = computed(() => {
  return form.orderItems.reduce((sum, item) => sum + (item.quantity || 0), 0)
})

const totalAmount = computed(() => {
  return form.orderItems.reduce((sum, item) => sum + (item.subtotal || 0), 0)
})

// 初始化表单
const initForm = (data?: any, viewMode = false) => {
  isEdit.value = !!data
  isView.value = viewMode
  
  if (data) {
    // 编辑模式，填充数据
    Object.assign(form, data)
  } else {
    // 新增模式，重置表单
    resetForm()
    // 生成订单编号
    form.orderNo = generateOrderNo()
    form.orderDate = new Date().toISOString()
  }
  
  // 加载数据
  loadDealerList()
  loadProductList()
}

// 生成订单编号
const generateOrderNo = () => {
  const date = new Date()
  const year = date.getFullYear()
  const month = String(date.getMonth() + 1).padStart(2, '0')
  const day = String(date.getDate()).padStart(2, '0')
  const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0')
  return `ORD${year}${month}${day}${random}`
}

// 加载经销商列表
const loadDealerList = async () => {
  try {
    // TODO: 调用经销商列表API
    dealerList.value = [
      { id: '1', name: '北京经销商' },
      { id: '2', name: '上海经销商' },
      { id: '3', name: '广州经销商' }
    ]
  } catch (error) {
    ElMessage.error('加载经销商列表失败')
    console.error('加载经销商列表错误:', error)
  }
}

// 加载产品列表
const loadProductList = async () => {
  try {
    // TODO: 调用产品列表API
    productList.value = [
      { id: '1', name: '产品A', specification: '规格A', unitPrice: 100 },
      { id: '2', name: '产品B', specification: '规格B', unitPrice: 200 },
      { id: '3', name: '产品C', specification: '规格C', unitPrice: 150 }
    ]
  } catch (error) {
    ElMessage.error('加载产品列表失败')
    console.error('加载产品列表错误:', error)
  }
}

// 经销商选择变化
const handleDealerChange = (dealerId: string) => {
  const dealer = dealerList.value.find(d => d.id === dealerId)
  if (dealer) {
    // TODO: 根据经销商ID获取详细信息
    form.contactPerson = dealer.contactPerson || ''
    form.contactPhone = dealer.contactPhone || ''
    form.contactEmail = dealer.contactEmail || ''
  }
}

// 产品选择变化
const handleProductChange = (productId: string, index: number) => {
  const product = productList.value.find(p => p.id === productId)
  if (product) {
    form.orderItems[index].productName = product.name
    form.orderItems[index].specification = product.specification
    form.orderItems[index].unitPrice = product.unitPrice
    calculateRowTotal(index)
  }
}

// 计算行小计
const calculateRowTotal = (index: number) => {
  const item = form.orderItems[index]
  if (item.quantity && item.unitPrice) {
    item.subtotal = item.quantity * item.unitPrice
  }
}

// 添加产品
const addProduct = () => {
  form.orderItems.push({
    productId: '',
    productName: '',
    specification: '',
    unitPrice: 0,
    quantity: 1,
    subtotal: 0
  })
}

// 删除产品
const removeProduct = (index: number) => {
  form.orderItems.splice(index, 1)
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    // 验证产品列表
    if (form.orderItems.length === 0) {
      ElMessage.error('请至少添加一个产品')
      return
    }
    
    if (isEdit.value) {
      // 编辑模式
      // await reqUpdateOrder(submitData)
      ElMessage.success('更新成功')
    } else {
      // 新增模式
      // await reqAddOrder(submitData)
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
    orderNo: generateOrderNo(),
    orderDate: new Date().toISOString(),
    dealerId: '',
    orderStatus: 'pending',
    contactPerson: '',
    contactPhone: '',
    contactEmail: '',
    receiverName: '',
    receiverPhone: '',
    receiverAddress: '',
    orderItems: [],
    discountAmount: 0,
    paymentMethod: '',
    expectedDelivery: '',
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

.product-section {
  margin-bottom: 20px;
  
  .product-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 10px;
    
    span {
      font-weight: bold;
      color: #303133;
    }
  }
}

.summary-item {
  font-size: 16px;
  font-weight: bold;
  color: #303133;
  
  &.total-amount {
    color: #f56c6c;
  }
}

.subtotal {
  color: #409eff;
  font-weight: bold;
}
</style> 