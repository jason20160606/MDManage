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
          <!-- 订单日期选择，只允许选择日期，不含时间 -->
          <el-form-item label="订单日期" prop="OrderDate">
            <el-date-picker
              v-model="form.OrderDate"
              type="date"                          
              placeholder="选择订单日期"
              style="width: 100%"
              :disabled="isView"              
            />
          </el-form-item>
        </el-col>
        <el-col :span="isEdit ? 12 : 12">
          <el-form-item label="经销商" prop="DealerId">
            <!-- 新增时为下拉选择，编辑/查看时为只读文本框 -->
            <template v-if="!isEdit && !isView">
              <el-select
                v-model="form.DealerId"
                placeholder="请选择经销商"
                filterable
                style="width: 100%"
                @change="handleDealerChange"
              >
                <el-option
                  v-for="dealer in dealerList"
                  :key="dealer.Id"
                  :label="dealer.Name"
                  :value="dealer.Id"
                />
              </el-select>
            </template>
            <template v-else>
              <el-input v-model="form.DealerName" :disabled="true" placeholder="经销商" />
            </template>
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
        
        <el-table :data="form.OrderItemDetails" border style="width: 100%" :header-cell-style="{ fontWeight: 'normal' }">
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
                  v-for="product in productList.filter(p => !form.OrderItemDetails.some((item, idx) => item.ProductId === p.Id && idx !== $index))"
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
            <span class="summary-item">{{ form.OrderItemDetails.length }} 种</span>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="订单总量">
            <span class="summary-item total-amount">{{ totalQuantity }} 件</span>
          </el-form-item>
        </el-col>  
        <el-col :span="8">
          <el-form-item label="运费类型" prop="DeliveryType">
            <el-select v-model="form.DeliveryType" placeholder="请选择运费类型" style="width: 100%">
              <el-option label="自提" :value="1" />
              <el-option label="到付" :value="2" />
              <el-option label="现付" :value="3" />
            </el-select>
          </el-form-item>
        </el-col>              
      </el-row>
      <!-- 司机信息，仅自提时显示 -->
      <el-row v-if="Number(form.DeliveryType) === 1" :gutter="20">
        <el-col :span="8">
          <el-form-item label="司机姓名" prop="DriverName">
            <el-input v-model="form.DriverName" placeholder="请输入司机姓名" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="车牌号" prop="CarPlateNumber">
            <el-input v-model="form.CarPlateNumber" placeholder="请输入车牌号" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="联系电话" prop="DriverPhone">
            <el-input v-model="form.DriverPhone" placeholder="请输入司机联系电话" />
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
import { reqCheckOrder, reqAddOrder, reqUpdateOrder } from '@/api/order'
import { reqDealerNameList } from '@/api/organization/dealer'
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
  ReceiverName: '',
  ReceiverPhone: '',
  ReceiverAddress: '',
  OrderItemDetails: [],  
  DeliveryType: '',
  Remark: '',
  MatchId: '',
  DriverName: '',
  CarPlateNumber: '',
  DriverPhone: ''
})

// 表单验证规则
const rules: FormRules = {
  // 仅新增时校验经销商，编辑/查看时不校验
  DealerId: [
    {
      required: true,
      message: '请选择经销商',
      trigger: 'change',
      // 自定义校验函数，只有新增时才校验
      validator: (_rule: any, value: any, callback: any) => {
        if (!isEdit.value && !isView.value && !value) {
          callback(new Error('请选择经销商'));
        } else {
          callback();
        }
      }
    }
  ],
  OrderDate: [
    { required: true, message: '请选择订单日期', trigger: 'change' }
  ],
  SenderName: [
    { required: true, message: '请输入发件人姓名', trigger: 'blur' }
  ],
  MatchId: [
    { required: true, message: '请输入MatchId', trigger: 'blur' }
  ],
  DeliveryType: [
    { required: true, message: '请选择运费类型', trigger: 'change' }
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


// 计算属性
const totalQuantity = computed(() => {
  return form.OrderItemDetails.reduce((sum, item) => sum + (item.Quantity || 0), 0)
})

// 初始化表单
const initForm = async (data?: any, viewMode = false) => {
  isEdit.value = !!data
  isView.value = viewMode
  if (data && data.Id) {
    // 编辑模式，查详情
    const res = await reqCheckOrder(data.Id)
    const detail = res.data || res.Data || res
    Object.assign(form, detail)
    // 适配后端OrderItemDetails为null的情况，始终保证为数组
    form.OrderItemDetails = Array.isArray(form.OrderItemDetails) ? form.OrderItemDetails : []
    // 适配订单日期格式，保证el-date-picker正常显示
    if (form.OrderDate) {
      form.OrderDate = form.OrderDate.slice(0, 10)
    }
    // 编辑模式下不请求经销商列表
  } else {
    // 新增模式，重置表单
    resetForm()    
    // 只保留日期部分，格式为yyyy-MM-dd
    const today = new Date()
    const yyyy = today.getFullYear()
    const mm = String(today.getMonth() + 1).padStart(2, '0')
    const dd = String(today.getDate()).padStart(2, '0')  
    form.OrderDate = `${yyyy}-${mm}-${dd}`
    // 仅新增时请求经销商列表
    loadDealerList()
  }
  loadProductList()
}

// 加载经销商列表
const loadDealerList = async () => {
  try {
    // 调用后端API获取经销商名称列表
    const res = await reqDealerNameList()
    // 兼容不同返回结构
    dealerList.value = res.data || res.Data || res || []
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

// 产品选择变化，属性统一为Id、Name
const handleProductChange = (productId: string, index: number) => {
  const product = productList.value.find(p => p.Id === productId)
  if (product) {
    form.OrderItemDetails[index].ProductName = product.Name
    form.OrderItemDetails[index].Specification = product.Specification
    form.OrderItemDetails[index].UnitPrice = product.UnitPrice
    calculateRowTotal(index)
  }
}

// 计算行小计
const calculateRowTotal = (index: number) => {
  const item = form.OrderItemDetails[index]
  if (item.Quantity && item.UnitPrice) {
    item.Subtotal = item.Quantity * item.UnitPrice
  }
}

// 添加产品，属性统一为大写开头
const addProduct = () => {
  form.OrderItemDetails.push({
    ProductId: '',
    ProductName: '',
    Specification: '',
    UnitPrice: 0,
    Quantity: 1,
    Subtotal: 0
  })
}

// 删除产品
const removeProduct = (index: number) => {
  form.OrderItemDetails.splice(index, 1)
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return
  try {
    await formRef.value.validate()
    // 验证产品列表
    if (form.OrderItemDetails.length === 0) {
      ElMessage.error('请至少添加一个产品')
      return
    }
    // 校验每个产品的ProductId和Quantity
    for (const [idx, item] of form.OrderItemDetails.entries()) {
      if (!item.ProductId) {
        ElMessage.error(`第${idx + 1}行产品未选择，请选择产品`)
        return
      }
      if (!item.Quantity || item.Quantity <= 0) {
        ElMessage.error(`第${idx + 1}行产品数量不能为空且必须大于0`)
        return
      }
    }
    // 组装提交数据，移除Area
    const submitData = { ...form }
    if (isEdit.value) {
      // 编辑模式
      await reqUpdateOrder(submitData)
      ElMessage.success('更新成功')
    } else {
      // 新增模式
      await reqAddOrder(submitData)
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
  if (isEdit.value) {
    // 编辑模式下，重置时不重置经销商
    Object.assign(form, {
      // Id、DealerId、DealerName 保持不变      
      OrderDate: '',
      SenderName: '',
      ContactPerson: '',
      ContactPhone: '',      
      ReceiverName: '',
      ReceiverPhone: '',
      ReceiverAddress: '',
      OrderItemDetails: [],      
      DeliveryType: '',      
      Remark: '',
      MatchId: '',
      DriverName: '',
      CarPlateNumber: '',
      DriverPhone: ''
    })
  } else {
    // 新增模式全部重置
    Object.assign(form, { 
      OrderDate: '',
      DealerId: '',
      DealerName: '',
      SenderName: '',
      ContactPerson: '',
      ContactPhone: '',      
      ReceiverName: '',
      ReceiverPhone: '',
      ReceiverAddress: '',
      OrderItemDetails: [],      
      DeliveryType: '',      
      Remark: '',
      MatchId: '',
      DriverName: '',
      CarPlateNumber: '',
      DriverPhone: ''
    })
  }
}

// 返回列表
const goBack = () => {
  emit('change-scene', 0)
}

// 处理经销商选择变化
const handleDealerChange = (dealerId: string) => {
  // 根据选择的Id查找对应的经销商名称
  const dealer = dealerList.value.find(d => d.Id === dealerId)
  if (dealer) {
    form.DealerName = dealer.Name
  } else {
    form.DealerName = ''
  }
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