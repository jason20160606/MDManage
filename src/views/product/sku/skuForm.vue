<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ isEdit ? '编辑SKU' : isView ? '查看SKU' : '新增SKU' }}</span>
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
          <el-form-item label="SKU名称" prop="name">
            <el-input v-model="form.name" placeholder="请输入SKU名称" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="SKU编码" prop="skuCode">
            <el-input v-model="form.skuCode" placeholder="请输入SKU编码" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="所属SPU" prop="spuId">
            <el-select 
              v-model="form.spuId" 
              placeholder="请选择SPU" 
              filterable 
              clearable
              style="width: 100%"
            >
              <el-option
                v-for="spu in spuList"
                :key="spu.id"
                :label="spu.name"
                :value="spu.id"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="状态" prop="status">
            <el-radio-group v-model="form.status">
              <el-radio :label="1">上架</el-radio>
              <el-radio :label="0">下架</el-radio>
            </el-radio-group>
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 价格库存 -->
      <el-divider content-position="left">价格库存</el-divider>
      
      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="销售价格" prop="price">
            <el-input-number
              v-model="form.price"
              :precision="2"
              :step="0.01"
              :min="0"
              style="width: 100%"
              placeholder="请输入销售价格"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="成本价格" prop="costPrice">
            <el-input-number
              v-model="form.costPrice"
              :precision="2"
              :step="0.01"
              :min="0"
              style="width: 100%"
              placeholder="请输入成本价格"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="库存数量" prop="stock">
            <el-input-number
              v-model="form.stock"
              :min="0"
              :precision="0"
              style="width: 100%"
              placeholder="请输入库存数量"
            />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="8">
          <el-form-item label="预警库存" prop="warningStock">
            <el-input-number
              v-model="form.warningStock"
              :min="0"
              :precision="0"
              style="width: 100%"
              placeholder="请输入预警库存"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="重量(kg)" prop="weight">
            <el-input-number
              v-model="form.weight"
              :precision="2"
              :step="0.01"
              :min="0"
              style="width: 100%"
              placeholder="请输入重量"
            />
          </el-form-item>
        </el-col>
        <el-col :span="8">
          <el-form-item label="体积(m³)" prop="volume">
            <el-input-number
              v-model="form.volume"
              :precision="3"
              :step="0.001"
              :min="0"
              style="width: 100%"
              placeholder="请输入体积"
            />
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 规格信息 -->
      <el-divider content-position="left">规格信息</el-divider>
      
      <el-form-item label="规格组合">
        <div class="spec-container">
          <div v-for="(spec, index) in form.specifications" :key="index" class="spec-item">
            <el-row :gutter="10">
              <el-col :span="8">
                <el-select 
                  v-model="spec.specId" 
                  placeholder="选择规格" 
                  style="width: 100%"
                  @change="handleSpecChange(index)"
                >
                  <el-option
                    v-for="specOption in availableSpecs"
                    :key="specOption.id"
                    :label="specOption.name"
                    :value="specOption.id"
                  />
                </el-select>
              </el-col>
              <el-col :span="8">
                <el-select 
                  v-model="spec.specValue" 
                  placeholder="选择规格值" 
                  style="width: 100%"
                >
                  <el-option
                    v-for="value in getSpecValues(spec.specId)"
                    :key="value"
                    :label="value"
                    :value="value"
                  />
                </el-select>
              </el-col>
              <el-col :span="6">
                <el-button 
                  type="danger" 
                  link 
                  @click="removeSpec(index)"
                  :disabled="isView"
                >
                  删除
                </el-button>
              </el-col>
            </el-row>
          </div>
          <el-button 
            type="primary" 
            link 
            @click="addSpec"
            :disabled="isView"
          >
            + 添加规格
          </el-button>
        </div>
      </el-form-item>

      <!-- 图片信息 -->
      <el-divider content-position="left">图片信息</el-divider>
      
      <el-form-item label="主图" prop="mainImage">
        <el-upload
          class="avatar-uploader"
          :action="uploadUrl"
          :show-file-list="false"
          :on-success="handleMainImageSuccess"
          :before-upload="beforeImageUpload"
          :disabled="isView"
        >
          <img v-if="form.mainImage" :src="form.mainImage" class="avatar" />
          <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
        </el-upload>
      </el-form-item>

      <el-form-item label="图片列表">
        <el-upload
          :action="uploadUrl"
          list-type="picture-card"
          :file-list="imageList"
          :on-success="handleImageSuccess"
          :on-remove="handleImageRemove"
          :before-upload="beforeImageUpload"
          :disabled="isView"
        >
          <el-icon><Plus /></el-icon>
        </el-upload>
      </el-form-item>

      <!-- 描述信息 -->
      <el-divider content-position="left">描述信息</el-divider>
      
      <el-form-item label="SKU描述" prop="description">
        <el-input
          v-model="form.description"
          type="textarea"
          :rows="4"
          placeholder="请输入SKU描述"
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
import { Plus } from '@element-plus/icons-vue'
import type { FormInstance, FormRules, UploadProps } from 'element-plus'
import { reqAddSku, reqUpdateSku, type SkuData } from '@/api/product/sku'
import { reqSPU } from '@/api/product/spu'
import { reqAttr } from '@/api/product/attr'

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
  specifications: [] as any[]
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

// 状态标识
const isEdit = ref(false)
const isView = ref(false)

// SPU列表
const spuList = ref<any[]>([])

// 可用规格列表
const availableSpecs = ref<any[]>([])

// 图片列表
const imageList = ref<any[]>([])

// 上传地址
const uploadUrl = '/api/upload' // 根据实际API调整

// 计算属性
const computedSpecs = computed(() => {
  return form.specifications.map(spec => ({
    specId: spec.specId,
    specName: availableSpecs.value.find(s => s.id === spec.specId)?.name || '',
    specValue: spec.specValue
  }))
})

// 初始化表单
const initForm = (data?: any, viewMode = false) => {
  isEdit.value = !!data
  isView.value = viewMode
  
  if (data) {
    // 编辑模式，填充数据
    Object.assign(form, data)
    // 处理图片列表
    if (data.images && Array.isArray(data.images)) {
      imageList.value = data.images.map((url: string, index: number) => ({
        name: `image_${index}`,
        url: url
      }))
    }
  } else {
    // 新增模式，重置表单
    resetForm()
  }
  
  // 加载SPU列表和规格列表
  loadSpuList()
  loadSpecList()
}

// 加载SPU列表
const loadSpuList = async () => {
  try {
    // 调用SPU列表API
    const result = await reqSPU()
    if (result.ok) {
      spuList.value = result.data || []
    }
  } catch (error) {
    ElMessage.error('加载SPU列表失败')
    console.error('加载SPU列表错误:', error)
  }
}

// 加载规格列表
const loadSpecList = async () => {
  try {
    // 调用属性列表API
    const result = await reqAttr()
    if (result.ok) {
      // 转换属性数据为规格格式
      availableSpecs.value = (result.data || []).map((attr: any) => ({
        id: attr.id,
        name: attr.attrName,
        values: attr.attrValueList?.map((val: any) => val.valueName) || []
      }))
    }
  } catch (error) {
    ElMessage.error('加载规格列表失败')
    console.error('加载规格列表错误:', error)
  }
}

// 获取规格值列表
const getSpecValues = (specId: string) => {
  const spec = availableSpecs.value.find(s => s.id === specId)
  return spec?.values || []
}

// 添加规格
const addSpec = () => {
  form.specifications.push({
    specId: '',
    specValue: ''
  })
}

// 删除规格
const removeSpec = (index: number) => {
  form.specifications.splice(index, 1)
}

// 规格变化处理
const handleSpecChange = (index: number) => {
  form.specifications[index].specValue = ''
}

// 主图上传成功
const handleMainImageSuccess: UploadProps['onSuccess'] = (response) => {
  form.mainImage = response.url
  ElMessage.success('主图上传成功')
}

// 图片上传成功
const handleImageSuccess: UploadProps['onSuccess'] = (response) => {
  form.images.push(response.url)
  ElMessage.success('图片上传成功')
}

// 图片删除
const handleImageRemove: UploadProps['onRemove'] = (file) => {
  const index = form.images.indexOf(file.url)
  if (index > -1) {
    form.images.splice(index, 1)
  }
}

// 上传前验证
const beforeImageUpload: UploadProps['beforeUpload'] = (file) => {
  const isJPG = file.type === 'image/jpeg' || file.type === 'image/png' || file.type === 'image/webp'
  const isLt2M = file.size / 1024 / 1024 < 2

  if (!isJPG) {
    ElMessage.error('上传图片只能是 JPG/PNG/WEBP 格式!')
  }
  if (!isLt2M) {
    ElMessage.error('上传图片大小不能超过 2MB!')
  }
  return isJPG && isLt2M
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    // 构建提交数据
    const submitData: SkuData = {
      ...form,
      specifications: computedSpecs.value
    }
    
    if (isEdit.value) {
      // 编辑模式
      await reqUpdateSku(submitData)
      ElMessage.success('更新成功')
    } else {
      // 新增模式
      await reqAddSku(submitData)
      ElMessage.success('添加成功')
    }
    
    // 返回列表
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
    specifications: []
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
  width: 100px;
  height: 100px;
  text-align: center;
  line-height: 100px;
}

.avatar {
  width: 100px;
  height: 100px;
  display: block;
}
</style>