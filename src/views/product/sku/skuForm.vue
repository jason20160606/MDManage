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
            <el-input v-model="form.spuName" placeholder="" style="width: 100%" disabled />
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
          <el-form-item label="差价" prop="stock">
            <el-input-number v-model="form.specialPrice" :min="0" :precision="0" style="width: 100%" placeholder="请输入库存数量"  />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="扣减比例" prop="warningStock">
            <el-input-number v-model="form.quotaDeductRatio" :precision="2" :step="0.1" :min="0" style="width: 100%"
              placeholder="请输入比例（倍数）" />

          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="单位">
            <!-- 将单位字段改为下拉选择，选项来自unitMap，v-model绑定form.unit -->
            <el-select v-model="form.unit" placeholder="请选择单位" style="width: 100%">
              <el-option
                v-for="(label, value) in unitMap"
                :key="value"
                :label="label"
                :value="value"
              />
            </el-select>
          </el-form-item>
        </el-col>        
      </el-row>
      <el-divider content-position="left">状态</el-divider>
      <el-row :gutter="20">

        <el-col :span="12">
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :label="1">上架</el-radio>
              <el-radio :label="0">下架</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
      </el-row>
      <!-- 规格信息 -->

      <!-- 图片信息 -->
      <el-divider content-position="left">图片信息</el-divider>

      <el-form-item label="主图" prop="mainImage">
        <el-upload class="avatar-uploader" action="/api/Upload" :data="{ type: 'skuMain' }" name="file"
         :show-file-list="false" :on-success="handleMainImageSuccess" :before-upload="beforeImageUpload">
          <img v-if="form.mainImage" :src="form.mainImage" class="avatar" />
          <el-icon v-else class="avatar-uploader-icon">
            <Plus />
          </el-icon>
        </el-upload>
      </el-form-item>

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
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import type { FormInstance, FormRules, UploadProps } from 'element-plus'
import { reqUpdateSku, type SkuData } from '@/api/product/sku'


// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 表单数据
const form = reactive({
  id: '',
  name: '',
  skuCode: '',
  spuId: '',
  spuName: '',
  status: 1,
  price: 0,
  costPrice: 0,
  stock: 0,
  warningStock: 0,
  weight: 0,
  volume: 0,
  mainImage: '',
  images: [] as string[],
  description: '',
  specifications: [],
  brandId: '',
  brandName: '',
  factoryId: '',
  factoryName: '',
  unit: '',
  quotaDeductRatio: 0,
  specialPrice: 0,
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
  spuId: [
    { required: true, message: '请选择所属SPU', trigger: 'change' }
  ],
  price: [
    { required: true, message: '请输入销售价格', trigger: 'blur' },
    { type: 'number', min: 0, message: '价格不能小于0', trigger: 'blur' }
  ],
  stock: [
    { required: true, message: '请输入库存数量', trigger: 'blur' },
    { type: 'number', min: 0, message: '库存不能小于0', trigger: 'blur' }
  ]
}

// 图片列表
const imageList = ref<any[]>([])

// 计算属性
const computedSpecs = computed(() => {
  return form.specifications.map(spec => ({
    specId: spec.specId,
    specName: '', // 不再加载SPU和规格列表
    specValue: spec.specValue
  }))
})

// 单位映射，key统一为字符串类型
const unitMap: Record<string, string> = {
  '1': '箱',
  '2': '件',
  '3': '套',
  '4': '支',
  '5': '盒',
  '6': '瓶',
  '7': '个',
  '8': '公斤'
}

// 初始化表单
const initForm = (data: any) => {
  // 只支持编辑，填充数据
  form.id = data.Id
  form.name = data.Name
  form.skuCode = data.Code
  form.spuId = data.SPUId
  form.spuName = data.SPUName
  form.status = data.Status
  form.price = data.Price
  form.costPrice = data.CostPrice
  form.mainImage = data.MainImage
  form.description = data.Description
  form.specifications = data.Specifications || []
  form.brandId = data.BrandId
  form.brandName = data.BrandName
  form.factoryId = data.FactoryId
  form.factoryName = data.FactoryName
  // 单位字段处理，确保类型与unitMap的key一致（字符串），并校验
  const unitKey = String(data.Unit)
  form.unit = unitMap[unitKey] ? unitKey : ''
  form.quotaDeductRatio = data.QuotaDeductRatio
  form.specialPrice = data.SpecialPrice
  // 处理图片列表
  if (data.Images && Array.isArray(data.Images)) {
    imageList.value = data.Images.map((url: string, index: number) => ({
      name: `image_${index}`,
      url: url
    }))
  } else {
    imageList.value = []
  }
  // 不再加载SPU和规格列表
}

// 主图上传成功
const handleMainImageSuccess: UploadProps['onSuccess'] = (response) => {
  // 参照SPU，后端返回图片相对路径，前端拼接完整URL
  const baseUrl = import.meta.env.VITE_APP_SERVE || 'http://localhost:5161';
  form.mainImage = response.data ? `${baseUrl}/${response.data}` : response.url;
  ElMessage.success('主图上传成功');
}


// 上传前验证
const beforeImageUpload: UploadProps['beforeUpload'] = (file) => {
  // 参照SPU，只允许图片类型，且小于2MB
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
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
      SpecialPrice: Number(form.specialPrice),
      Price: Number(form.price),
      CostPrice: Number(form.costPrice),
      QuotaDeductRatio: Number(form.quotaDeductRatio),
      Unit: Number(form.unit),
      MainImage: form.mainImage,
      Status: Number(form.status)
    }

    // 断言为any，避免类型检查报错
    await reqUpdateSku(submitData as any)
    ElMessage.success('更新成功')
    goBack()
  } catch (error) {
    ElMessage.error('操作失败')
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
    spuId: '',
    spuName: '',
    status: 1,
    price: 0,
    costPrice: 0,
    stock: 0,
    warningStock: 0,
    weight: 0,
    volume: 0,
    mainImage: '',
    images: [],
    description: '',
    specifications: [],
    brandId: '',
    brandName: '',
    factoryId: '',
    factoryName: '',
    unit: '',
    quotaDeductRatio: 0,
    specialPrice: 0,
  })
  imageList.value = []
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

.avatar-uploader {
  :deep(.el-upload) {
    border: 1px dashed #d9d9d9;
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    transition: var(--el-transition-duration-fast);

    &:hover {
      border-color: var(--el-color-primary);
    }
  }
}

.avatar-uploader-icon {
  font-size: 28px;
  color: #8c939d;
  width: 178px;
  height: 178px;
  text-align: center;
  line-height: 178px;
}

.avatar {
  width: 178px;
  height: 178px;
  display: block;
}
</style>