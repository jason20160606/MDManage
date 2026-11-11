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
            <!-- 三级联动选择：一级 → 二级 → 三级，支持按名称搜索，最终只保存三级分类ID -->
            <el-cascader
              v-model="spuForm.CategoryId"
              :options="categoryTree"
              :props="cascaderProps"
              placeholder="请选择三级分类（可直接搜索）"
              clearable
              filterable
              style="width: 100%"
            />
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
import { reqAddSPU, reqUpdateSPU, reqCategoryTree } from '@/api/product/spu'
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
  ]
}

// 状态标识
const isEdit = ref(false)

// 分类树（一级/二级/三级），用于三级联动
const categoryTree = ref<any[]>([])

// 级联选择配置：字段名对齐后端 PascalCase，emitPath=false 表示只取最后一级的ID
const cascaderProps = {
  value: 'Id',
  label: 'Name',
  children: 'Children',
  emitPath: false,
  checkStrictly: false
}

onMounted(() => {
  fetchBrandOptions()
  fetchCategoryTree()
})

// 拉取分类树：接口返回的是裸数组，字段为 Id / Name / Children
const fetchCategoryTree = async () => {
  try {
    const res = await reqCategoryTree()
    const tree = Array.isArray(res) ? res : res?.data
    categoryTree.value = Array.isArray(tree) ? tree : []
  } catch (e) {
    categoryTree.value = []
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
        ElMessage.error('更新失败')
      }
    } else {
      let res = await reqAddSPU(spuForm)
      if (res.Success) {
        emit('change-scene', 0) // 返回列表
        ElMessage.success('新增成功')
      } else {
        ElMessage.error('新增失败')
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

// 图片上传相关逻辑已移除：后台暂不展示主图，SPUMainImages 仅保留在表单里原样回传
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