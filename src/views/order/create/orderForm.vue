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
          <el-form-item label="订单编号" prop="OrderNo">
            <el-input v-model="form.OrderNo" placeholder="系统自动生成" :disabled="true" />
          </el-form-item>
        </el-col>
        <el-col :span="isEdit ? 12 : 12">
          <el-form-item label="下单时间" prop="OrderDate">
            <el-date-picker
              v-model="form.OrderDate"
              type="datetime"
              placeholder="选择下单时间"
              style="width: 100%"
              :disabled="true"
            />
          </el-form-item>
        </el-col>
        <el-col :span="isEdit ? 12 : 12">
          <el-form-item label="经销商" prop="DealerName">
            <el-input v-model="form.DealerName" :disabled="true" placeholder="经销商" />
          </el-form-item>
        </el-col>
        <el-col :span="isEdit ? 12 : 12">
          <el-form-item label="发件人" prop="SenderName">
            <el-input v-model="form.SenderName" placeholder="请输入发件人姓名" :disabled="isView" />
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 收货信息 -->
      <el-divider content-position="left">收货信息</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="收货人" prop="ReceiverName">
            <el-input v-model="form.ReceiverName" placeholder="请输入收货人姓名" :disabled="isView" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="联系电话" prop="ReceiverPhone">
            <el-input v-model="form.ReceiverPhone" placeholder="请输入联系电话" :disabled="isView" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="MatchId" prop="MatchId">
            <el-input v-model="form.MatchId" placeholder="请输入MatchId" :disabled="isView" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="收货地区" prop="Area">
            <el-cascader
              v-model="form.Area"
              :options="areaOptions"
              placeholder="请选择省/市/区"
              :props="{ value: 'value', label: 'label', children: 'children' }"
              clearable
              :disabled="isView"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="收货地址" prop="ReceiverAddress">
            <el-input v-model="form.ReceiverAddress" placeholder="请输入详细地址" :disabled="isView" />
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
        
        <el-table :data="form.OrderItems" border style="width: 100%" :header-cell-style="{ fontWeight: 'normal' }">
          <el-table-column type="index" label="序号" width="60" />
          <el-table-column label="产品名称" min-width="200">
            <template #default="{ row, $index }">
              <el-select 
                v-model="row.ProductId" 
                placeholder="请选择产品" 
                filterable 
                clearable
                style="width: 100%"
                @change="(value) => handleProductChange(value, $index)"
              >
                <el-option
                  v-for="product in productList.filter(p => !form.OrderItems.some((item, idx) => item.ProductId === p.Id && idx !== $index))"
                  :key="product.Id"
                  :label="product.Name"
                  :value="product.Id"
                />
              </el-select>
            </template>
          </el-table-column>                  
          <el-table-column label="数量" width="150">
            <template #default="{ row, $index }">
              <el-input-number
                v-model="row.Quantity"
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
          <el-form-item label="产品种类">
            <span class="summary-item">{{ form.OrderItems.length }} 种</span>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="订单总量">
            <span class="summary-item total-amount">{{ totalQuantity }} 件</span>
          </el-form-item>
        </el-col>  
        <el-col :span="8">
          <el-form-item label="运费类型" prop="PaymentMethod">
            <el-select v-model="form.PaymentMethod" placeholder="请选择付款方式" style="width: 100%">
              <el-option label="到付" value="cash" />
              <el-option label="现付" value="bank_transfer" />
              <el-option label="自提" value="check" />              
            </el-select>
          </el-form-item>
        </el-col>              
      </el-row>
      <!-- 备注信息 -->
      <el-divider content-position="left">备注信息</el-divider>
      
      <el-form-item label="订单备注" prop="Remark">
        <el-input
          v-model="form.Remark"
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
import { reqCheckOrder } from '@/api/order'
import { regionData } from 'element-china-area-data'
import { reqSkuNameList } from '@/api/product/sku'

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 表单数据
const form = reactive({
  Id: '',
  OrderNo: '',
  OrderDate: '',
  DealerId: '',
  DealerName: '',
  SenderName: '',
  ContactPerson: '',
  ContactPhone: '',
  ContactEmail: '',
  ReceiverName: '',
  ReceiverPhone: '',
  ReceiverAddress: '',
  OrderItems: [],
  DiscountAmount: 0,
  PaymentMethod: '',
  ExpectedDelivery: '',
  Remark: '',
  MatchId: '',
  Area: []
})

// 表单验证规则
const rules: FormRules = {
  DealerId: [
    { required: true, message: '请选择经销商', trigger: 'change' }
  ],
  PaymentMethod: [
    { required: true, message: '请选择付款方式', trigger: 'change' }
  ],
  ReceiverName: [
    { required: true, message: '请输入收货人姓名', trigger: 'blur' }
  ],
  ReceiverPhone: [
    { required: true, message: '请输入收货人联系电话', trigger: 'blur' }
  ],
  ReceiverAddress: [
    { required: true, message: '请输入收货地址', trigger: 'blur' }
  ],
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)

// 经销商列表
const dealerList = ref<any[]>([])

// 产品列表
const productList = ref<any[]>([])

// 区域选项
const areaOptions = regionData

// 计算属性
const totalQuantity = computed(() => {
  return form.OrderItems.reduce((sum, item) => sum + (item.Quantity || 0), 0)
})

// 初始化表单
const initForm = async (data?: any, viewMode = false) => {
  console.log(areaOptions)
  isEdit.value = !!data
  isView.value = viewMode
  if (data && data.Id) {
    // 编辑模式，查详情
    const res = await reqCheckOrder(data.Id)
    const detail = res.data || res.Data || res
    Object.assign(form, detail)
    // 收货地区格式转换，字符串转数组
    if (detail.Area && typeof detail.Area === 'string') {
      form.Area = detail.Area.split(',')
    } else if (Array.isArray(detail.Area)) {
      form.Area = detail.Area
    } else {
      form.Area = []
    }
  } else {
    // 新增模式，重置表单
    resetForm()
    form.OrderNo = generateOrderNo()
    form.OrderDate = new Date().toISOString()
  }
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
      { Id: '1', Name: '北京经销商' },
      { Id: '2', Name: '上海经销商' },
      { Id: '3', Name: '广州经销商' }
    ]
  } catch (error) {
    ElMessage.error('加载经销商列表失败')
    console.error('加载经销商列表错误:', error)
  }
}

// 加载产品列表
const loadProductList = async () => {
  try {
    // 调用SKU名称列表API获取商品名称及id
    const res = await reqSkuNameList()
    productList.value = res.data || res.Data || res || []
  } catch (error) {
    ElMessage.error('加载产品列表失败')
    console.error('加载产品列表错误:', error)
  }
}

// 产品选择变化
const handleProductChange = (productId: string, index: number) => {
  const product = productList.value.find(p => p.id === productId)
  if (product) {
    form.OrderItems[index].productName = product.name
    form.OrderItems[index].specification = product.specification
    form.OrderItems[index].unitPrice = product.unitPrice
    calculateRowTotal(index)
  }
}

// 计算行小计
const calculateRowTotal = (index: number) => {
  const item = form.OrderItems[index]
  if (item.quantity && item.unitPrice) {
    item.subtotal = item.quantity * item.unitPrice
  }
}

// 添加产品
const addProduct = () => {
  form.OrderItems.push({
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
  form.OrderItems.splice(index, 1)
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
    // 验证产品列表
    if (form.OrderItems.length === 0) {
      ElMessage.error('请至少添加一个产品')
      return
    }
    // 组装提交数据，Area转为字符串
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
    Id: '',
    OrderNo: generateOrderNo(),
    OrderDate: new Date().toISOString(),
    DealerId: '',
    DealerName: '',
    SenderName: '',
    ContactPerson: '',
    ContactPhone: '',
    ContactEmail: '',
    ReceiverName: '',
    ReceiverPhone: '',
    ReceiverAddress: '',
    OrderItems: [],
    DiscountAmount: 0,
    PaymentMethod: '',
    ExpectedDelivery: '',
    Remark: '',
    MatchId: '',
    Area: []
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