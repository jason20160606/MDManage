<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ isEdit ? '编辑SPU' : isView ? '查看SPU' : '新增SPU' }}</span>
        <el-button @click="handleCancel">返回</el-button>
      </div>
    </template>

    <el-form
      ref="spuFormRef"
      :model="spuForm"
      :rules="spuRules"
      label-width="120px"
      :disabled="isView"
    >
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="SPU名称" prop="name">
            <el-input v-model="spuForm.name" placeholder="请输入SPU名称" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="所属分类" prop="categoryId">
            <el-cascader
              v-model="spuForm.categoryId"
              :options="categoryOptions"
              :props="{
                checkStrictly: true,
                label: 'name',
                value: 'id',
                children: 'children',
                emitPath: false
              }"
              placeholder="请选择分类"
              clearable
              style="width: 100%"
            />
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="品牌" prop="brandId">
            <el-select v-model="spuForm.brandId" placeholder="请选择品牌" clearable style="width: 100%">
              <el-option
                v-for="brand in brandOptions"
                :key="brand.id"
                :label="brand.name"
                :value="brand.id"
              />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          
        </el-col>
      </el-row>

      <el-form-item label="商品描述" prop="description">
        <el-input
          v-model="spuForm.description"
          type="textarea"
          :rows="4"
          placeholder="请输入商品描述"
        />
      </el-form-item>

      <el-form-item label="主图" prop="mainImage">
        <el-upload
          class="avatar-uploader"
          action="/api/upload"
          :show-file-list="false"
          :on-success="handleMainImageSuccess"
          :before-upload="beforeImageUpload"
          :disabled="isView"
        >
          <img v-if="spuForm.mainImage" :src="spuForm.mainImage" class="avatar" />
          <el-icon v-else class="avatar-uploader-icon"><Plus /></el-icon>
        </el-upload>
      </el-form-item>

      <el-form-item label="商品图片" prop="images">
        <el-upload
          action="/api/upload"
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

      <el-form-item label="详情图片" prop="detailImages">
        <el-upload
          action="/api/upload"
          list-type="picture-card"
          :file-list="detailImageList"
          :on-success="handleDetailImageSuccess"
          :on-remove="handleDetailImageRemove"
          :before-upload="beforeImageUpload"
          :disabled="isView"
        >
          <el-icon><Plus /></el-icon>
        </el-upload>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSave" v-if="!isView">保存</el-button>
        <el-button @click="handleCancel">取消</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, computed } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { reqAddSPU, reqUpdateSPU } from '@/api/product/spu'

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const spuFormRef = ref()

// 表单数据
const spuForm = reactive({
  id: undefined as number | undefined,
  name: '',
  categoryId: undefined as number | undefined,
  brandId: undefined as number | undefined,
  description: '',
  mainImage: '',
  images: [] as string[],
  detailImages: [] as string[],
  sort: 0,
  status: 1,
  isRecommend: false,
  isHot: false,
  isNew: false
})

// 表单验证规则
const spuRules = {
  name: [
    { required: true, message: '请输入SPU名称', trigger: 'blur' },
    { min: 2, max: 100, message: 'SPU名称长度在 2 到 100 个字符', trigger: 'blur' }
  ],
  categoryId: [
    { required: true, message: '请选择所属分类', trigger: 'change' }
  ],
  brandId: [
    { required: true, message: '请选择品牌', trigger: 'change' }
  ],
  description: [
    { required: true, message: '请输入商品描述', trigger: 'blur' },
    { max: 500, message: '商品描述不能超过500个字符', trigger: 'blur' }
  ],
  mainImage: [
    { required: true, message: '请上传主图', trigger: 'change' }
  ]
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)

// 分类选项（这里需要从store或API获取）
const categoryOptions = ref([])

// 品牌选项（这里需要从API获取）
const brandOptions = ref([
  { id: 1, name: '苹果' },
  { id: 2, name: '华为' },
  { id: 3, name: '小米' },
  { id: 4, name: '三星' }
])

// 图片列表
const imageList = ref([])
const detailImageList = ref([])

// 计算属性
const computedImageList = computed(() => {
  return spuForm.images.map((url, index) => ({
    name: `image-${index}`,
    url
  }))
})

const computedDetailImageList = computed(() => {
  return spuForm.detailImages.map((url, index) => ({
    name: `detail-image-${index}`,
    url
  }))
})

// 初始化表单
const initForm = (data?: any, readonly = false) => {
  isEdit.value = !!data
  isView.value = readonly
  
  if (data) {
    // 编辑模式，填充数据
    Object.assign(spuForm, {
      id: data.id,
      name: data.name,
      categoryId: data.categoryId,
      brandId: data.brandId,
      description: data.description,
      mainImage: data.mainImage,
      images: data.images || [],
      detailImages: data.detailImages || [],
      sort: data.sort || 0,
      status: data.status,
      isRecommend: data.isRecommend || false,
      isHot: data.isHot || false,
      isNew: data.isNew || false
    })
    
    // 更新图片列表
    imageList.value = computedImageList.value
    detailImageList.value = computedDetailImageList.value
  } else {
    // 新增模式，重置表单
    Object.assign(spuForm, {
      id: undefined,
      name: '',
      categoryId: undefined,
      brandId: undefined,
      description: '',
      mainImage: '',
      images: [],
      detailImages: [],
      sort: 0,
      status: 1,
      isRecommend: false,
      isHot: false,
      isNew: false
    })
    
    imageList.value = []
    detailImageList.value = []
  }
}

// 保存SPU
const handleSave = async () => {
  if (!spuFormRef.value) return
  
  try {
    await spuFormRef.value.validate()
    
    // 处理级联选择器的值
    if (Array.isArray(spuForm.categoryId)) {
      spuForm.categoryId = spuForm.categoryId[spuForm.categoryId.length - 1]
    }
    
    if (isEdit.value) {
      await reqUpdateSPU(spuForm.id!, spuForm)
      ElMessage.success('更新成功')
    } else {
      await reqAddSPU(spuForm)
      ElMessage.success('新增成功')
    }
    
    emit('change-scene', 0) // 返回列表
  } catch (error) {
    ElMessage.error(isEdit.value ? '更新失败' : '新增失败')
    console.error('保存SPU错误:', error)
  }
}

// 取消操作
const handleCancel = () => {
  emit('change-scene', 0)
}

// 主图上传成功
const handleMainImageSuccess = (response: any) => {
  spuForm.mainImage = response.data || response.url
  ElMessage.success('主图上传成功')
}

// 商品图片上传成功
const handleImageSuccess = (response: any) => {
  const url = response.data || response.url
  spuForm.images.push(url)
  ElMessage.success('图片上传成功')
}

// 商品图片移除
const handleImageRemove = (file: any) => {
  const index = spuForm.images.indexOf(file.url)
  if (index > -1) {
    spuForm.images.splice(index, 1)
  }
}

// 详情图片上传成功
const handleDetailImageSuccess = (response: any) => {
  const url = response.data || response.url
  spuForm.detailImages.push(url)
  ElMessage.success('详情图片上传成功')
}

// 详情图片移除
const handleDetailImageRemove = (file: any) => {
  const index = spuForm.detailImages.indexOf(file.url)
  if (index > -1) {
    spuForm.detailImages.splice(index, 1)
  }
}

// 图片上传前验证
const beforeImageUpload = (file: File) => {
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

.avatar-uploader {
  :deep(.el-upload) {
    border: 1px dashed var(--el-border-color);
    border-radius: 6px;
    cursor: pointer;
    position: relative;
    overflow: hidden;
    transition: var(--el-transition-duration-fast);
  }

  :deep(.el-upload:hover) {
    border-color: var(--el-color-primary);
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