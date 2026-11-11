<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>编辑SKU</span>
        <el-button @click="goBack">返回列表</el-button>
      </div>
    </template>

    <el-form ref="formRef" :model="form" :rules="rules" label-width="120px">
      <!-- 基本信息 -->
      <el-divider content-position="left">基本信息</el-divider>

      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="SKU名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入SKU名称" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="所属SPU">
            <el-input :model-value="form.spuName || '-'" disabled />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="所属品牌">
            <el-input :model-value="form.brandName || '-'" disabled />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="所属分类">
            <el-input :model-value="form.categoryPath || '-'" disabled />
          </el-form-item>
        </el-col>
      </el-row>



      <!-- 价格库存 -->
      <el-divider content-position="left">价格库存</el-divider>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="销售价格" prop="price">
            <el-input-number v-model="form.price" :precision="2" :step="0.01" :min="0" style="width: 100%"
              placeholder="请输入销售价格" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="成本价格" prop="costPrice">
            <el-input-number v-model="form.costPrice" :precision="2" :step="0.01" :min="0" style="width: 100%"
              placeholder="请输入成本价格" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="补差价(元/箱额度)">
            <el-input-number v-model="form.priceDiffUnit" :min="0" :precision="0" style="width: 100%"
              placeholder="扣1箱额度需补的钱，无则填0" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="扣库存比例">
            <el-input-number v-model="form.quotaConversion" :precision="2" :step="1" :min="0" style="width: 100%"
              placeholder="1箱额度扣几箱库存，1:1填1" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="特殊额度列">
            <el-select v-model="form.specialSlot" placeholder="请选择占用哪一列专属额度" style="width: 100%">
              <el-option label="不占用（扣通用额度）" :value="0" />
              <el-option label="专属额度 1" :value="1" />
              <el-option label="专属额度 2" :value="2" />
              <el-option label="专属额度 3" :value="3" />
              <el-option label="专属额度 4" :value="4" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="规格">
            <el-input v-model="form.unit" placeholder="如 10瓶/箱、6盒/箱" maxlength="50" clearable />
          </el-form-item>
        </el-col>        
      </el-row>

      <!-- 每箱重量 / 体积：发货与运费按“箱”计量，填的是 1 箱对应的重量与体积 -->
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="每箱重量(kg)">
            <el-input-number v-model="form.boxWeight" :precision="3" :step="0.1" :min="0" style="width: 100%"
              placeholder="1箱的毛重，单位kg" />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="每箱体积(m³)">
            <el-input-number v-model="form.boxVolume" :precision="4" :step="0.001" :min="0" style="width: 100%"
              placeholder="1箱的体积，单位m³" />
          </el-form-item>
        </el-col>
      </el-row>
      <el-divider content-position="left">状态</el-divider>
      <el-row :gutter="20">

        <el-col :span="12">
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :value="1">上架</el-radio>
              <el-radio :value="0">下架</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
      </el-row>
      <!-- 规格信息 -->

      <!-- 描述信息 -->
      <el-divider content-position="left">描述信息</el-divider>

      <el-form-item label="SKU描述" prop="description">
        <el-input v-model="form.description" type="textarea" :rows="4" placeholder="请输入SKU描述" />
      </el-form-item>

      <!-- 操作按钮 -->
      <el-form-item>
        <el-button type="primary" @click="submitForm">保存</el-button>
        <el-button @click="resetForm">重置</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { reqUpdateSku } from '@/api/product/sku'


// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 表单数据
const form = reactive({
  id: '',
  name: '',
  skuCode: '',
  spuId: 0 as number,
  spuName: '',
  status: 1,
  price: 100,
  costPrice: 100,
  stock: 0,
  warningStock: 0,
  weight: 0,
  volume: 0,
  mainImage: '',
  images: [] as string[],
  description: '',
  specifications: [],
  brandId: 0 as number,
  brandName: '',
  categoryPath: '',
  unit: '',
  quotaConversion: 1,
  specialSlot: 0,
  priceDiffUnit: 0,
  boxWeight: 0,
  boxVolume: 0,
})

// 表单验证规则
const rules: FormRules = {
  name: [
    { required: true, message: '请输入SKU名称', trigger: 'blur' },
    { min: 2, max: 100, message: '长度在 2 到 100 个字符', trigger: 'blur' }
  ],
  skuCode: [
    { required: true, message: '请输入SKU编码', trigger: 'blur' },
    { pattern: /^[A-Za-z0-9_-]+$/, message: 'SKU编码只能包含字母、数字、下划线和横线', trigger: 'blur' }
  ],
  spuId: [],
  price: [
    { required: true, message: '请输入销售价格', trigger: 'blur' },
    { type: 'number', min: 0, message: '价格不能小于0', trigger: 'blur' }
  ],
  stock: [
    { required: true, message: '请输入库存数量', trigger: 'blur' },
    { type: 'number', min: 0, message: '库存不能小于0', trigger: 'blur' }
  ]
}

// 所属SPU、品牌、三级分类：只读展示，由商品档案决定，SKU 页面不允许修改

// 初始化表单
const initForm = (data: any) => {
  // 只支持编辑，填充数据
  form.id = data.Id
  form.name = data.Name
  form.skuCode = data.Code
  form.spuId = data.SPUId != null ? Number(data.SPUId) : 0
  form.spuName = data.SPUName
  form.status = data.Status
  form.price = data.Price
  form.costPrice = data.CostPrice
  form.mainImage = data.MainImage
  form.description = data.Description
  form.specifications = data.Specifications || []
  form.brandId = data.BrandId
  form.brandName = data.BrandName
  form.categoryPath = data.CategoryPath || data.CategoryName || ''
  // 规格：自由文本
  form.unit = data.Unit || ''
  form.quotaConversion = data.QuotaConversion ?? 1
  form.specialSlot = data.SpecialSlot ?? 0
  form.priceDiffUnit = data.PriceDiffUnit
  form.boxWeight = Number(data.BoxWeight ?? 0)
  form.boxVolume = Number(data.BoxVolume ?? 0)
  // 后台暂不展示图片：MainImage 仅原样保留，编辑保存时回传，避免把库里已有值清空
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return

  try {
    await formRef.value.validate()

    // 只传递后端需要的字段，字段名和类型严格对应
    const submitData = {
      Id: Number(form.id),
      SPUId: Number(form.spuId),
      Name: form.name,
      PriceDiffUnit: Number(form.priceDiffUnit),
      Price: Number(form.price),
      CostPrice: Number(form.costPrice),
      QuotaConversion: Number(form.quotaConversion),
      SpecialSlot: Number(form.specialSlot),
      Unit: form.unit || '',
      MainImage: form.mainImage,
      BoxWeight: Number(form.boxWeight) || 0,
      BoxVolume: Number(form.boxVolume) || 0,
      Status: Number(form.status)
    }

    // 断言为any，避免类型检查报错
    await reqUpdateSku(submitData as any)
    ElMessage.success('更新成功')
    goBack()
  } catch (error) {
    // 表单校验未通过、或接口业务失败（拦截器已提示后端 Message），此处不再重复弹窗
    console.error('提交表单错误:', error)
  }
}

// 重置表单
const resetForm = () => {
  if (!formRef.value) return

  formRef.value.resetFields()
  Object.assign(form, {
    id: '',
    name: '',
    skuCode: '',
    spuId: 0,
    spuName: '',
    status: 1,
    price: 100,
    costPrice: 100,
    stock: 0,
    warningStock: 0,
    weight: 0,
    volume: 0,
    mainImage: '',
    images: [],
    description: '',
    specifications: [],
    brandId: 0,
    brandName: '',
    categoryPath: '',
    unit: '',
    quotaConversion: 1,
    specialSlot: 0,
    priceDiffUnit: 0,
    boxWeight: 0,
    boxVolume: 0,
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

.spec-container {
  .spec-item {
    margin-bottom: 10px;
    padding: 10px;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    background-color: #fafafa;
  }
}
</style>
