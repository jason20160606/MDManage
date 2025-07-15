<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ isEdit ? '编辑SPU' : '新增SPU' }}</span>
        <el-button @click="handleCancel">返回</el-button>
      </div>
    </template>

    <el-form ref="spuFormRef" :model="spuForm" :rules="spuRules" label-width="120px">
      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="SPU名称" prop="Name">
            <el-input v-model="spuForm.Name" placeholder="请输入SPU名称" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="所属分类" prop="CategoryId">
            <el-select v-model="spuForm.CategoryId" placeholder="请选择分类" clearable style="width: 100%">
              <el-option v-for="cat in categoryOptions" :key="cat.Id" :label="cat.Name" :value="cat.Id" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <el-row :gutter="20">
        <el-col :span="12">
          <el-form-item label="品牌" prop="BrandId">
            <el-select v-model="spuForm.BrandId" placeholder="请选择品牌" clearable style="width: 100%">
              <el-option v-for="brand in brandOptions" :key="brand.Id" :label="brand.Name" :value="brand.Id" />
            </el-select>
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="状态" prop="Status">
            <el-switch v-model="spuForm.Status" inline-prompt :active-value="1" :inactive-value="0" active-text="上架"
              inactive-text="下架" />
          </el-form-item>
        </el-col>
      </el-row>

      <el-form-item label="商品描述" prop="Description">
        <el-input v-model="spuForm.Description" type="textarea" :rows="4" placeholder="请输入商品描述" />
      </el-form-item>

      <el-form-item label="主图" prop="SPUMainImages">
        <!-- 主图上传控件，上传到后端 /Upload，type=spuMain，上传成功后回显图片 -->
        <el-upload class="avatar-uploader" action="/api/Upload" :data="{ type: 'spuMain' }" name="file"
          :show-file-list="false" :on-success="handleMainImageSuccess" :before-upload="beforeImageUpload">
          <!-- 如果已上传主图则显示图片，否则显示上传图标 -->
          <img v-if="spuForm.SPUMainImages" :src="spuForm.SPUMainImages" class="avatar" />
          <el-icon v-else class="avatar-uploader-icon">
            <Plus />
          </el-icon>
        </el-upload>
      </el-form-item>
      <el-form-item>
        <el-button type="primary" @click="handleSave">保存</el-button>
        <el-button @click="handleCancel">取消</el-button>
      </el-form-item>
    </el-form>
  </el-card>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { Plus } from '@element-plus/icons-vue'
import { reqAddSPU, reqUpdateSPU, reqLevel3Categories } from '@/api/product/spu'
import { reqGetBrandList } from '@/api/organization/company'

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const spuFormRef = ref()

// 表单数据
const spuForm = reactive({
  Id: undefined as number | undefined,
  Name: '',
  CategoryId: undefined as number | undefined,
  BrandId: undefined as number | undefined,
  Description: '',
  SPUMainImages: '',
  Status: 1,
})

// 表单验证规则
const spuRules = {
  Name: [
    { required: true, message: '请输入SPU名称', trigger: 'blur' },
    { min: 1, max: 50, message: 'SPU名称长度在 1 到 50 个字符', trigger: 'blur' }
  ],
  CategoryId: [
    { required: true, message: '请选择所属分类', trigger: 'change' }
  ],
  BrandId: [
    { required: true, message: '请选择品牌', trigger: 'change' }
  ],
  Description: [
    // { required: true, message: '请输入商品描述', trigger: 'blur' }, // 移除必填校验
    { max: 100, message: '商品描述不能超过100个字符', trigger: 'blur' }
  ],
  SPUMainImages: [
    { required: true, message: '请上传主图', trigger: 'change' }
  ]
}

// 状态标识
const isEdit = ref(false)

// 分类选项（这里需要从store或API获取）
const categoryOptions = ref([])

onMounted(() => {
  fetchBrandOptions()
  fetchCategoryOptions()
})

const fetchCategoryOptions = async () => {
  try {
    const res = await reqLevel3Categories()
    categoryOptions.value = res.data
  } catch (e) {
    ElMessage.error('获取分类数据失败')
  }
}

// 品牌选项（这里需要从API获取）
const brandOptions = ref([])

const fetchBrandOptions = async () => {
  try {
    const res = await reqGetBrandList()
    // 假设返回res.data为品牌数组，字段为Id和Name
    brandOptions.value = Array.isArray(res.data) ? res.data : []
  } catch (e) {
    ElMessage.error('获取品牌数据失败')
  }
}

// 初始化表单
const initForm = (data?: any) => {
  isEdit.value = !!data
  if (data) {
    // 编辑模式，填充数据
    Object.assign(spuForm, {
      Id: data.Id,
      Name: data.Name,
      CategoryId: data.CategoryId,
      BrandId: data.BrandId,
      Description: data.Description,
      SPUMainImages: data.MainImage,      
      Status: data.Status,
    })

  } else {
    // 新增模式，重置表单
    Object.assign(spuForm, {
      Id: undefined,
      Name: '',
      CategoryId: undefined,
      BrandId: undefined,
      Description: '',
      SPUMainImages: '',      
      Status: 1,
    })
  }
}

// 保存SPU
const handleSave = async () => {
  if (!spuFormRef.value) return

  try {
    await spuFormRef.value.validate()

    // 处理级联选择器的值
    if (Array.isArray(spuForm.CategoryId)) {
      spuForm.CategoryId = spuForm.CategoryId[spuForm.CategoryId.length - 1]
    }

    if (isEdit.value) {
      let res = await reqUpdateSPU(spuForm)
      if (res.Success) {
        emit('change-scene', 0) // 返回列表
        ElMessage.success('更新成功')
      } else {
        ElMessage.success('更新失败')

      }
    } else {
      let res = await reqAddSPU(spuForm)
      if (res.Success) {
        emit('change-scene', 0) // 返回列表
        ElMessage.success('新增成功')
      } else {
        ElMessage.success('新增失败')

      }
    }

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
  const baseUrl = import.meta.env.VITE_APP_SERVE || 'http://localhost:5161';
  // 后端返回图片相对路径，前端拼接完整URL
  spuForm.SPUMainImages = response.data ? `${baseUrl}/${response.data}` : response.url;
  ElMessage.success('主图上传成功');
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