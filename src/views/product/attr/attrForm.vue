<template>
  <el-card>
    <template #header>
      <div class="card-header">
        <span>{{ isEdit ? '编辑属性' : isView ? '查看属性' : '新增属性' }}</span>
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
          <el-form-item label="属性名称" prop="attrName">
            <el-input v-model="form.attrName" placeholder="请输入属性名称" />
          </el-form-item>
        </el-col>
        <el-col :span="12">
          <el-form-item label="分类级别" prop="categoryLevel">
            <el-select v-model="form.categoryLevel" placeholder="请选择分类级别" style="width: 100%">
              <el-option label="一级分类" :value="1" />
              <el-option label="二级分类" :value="2" />
              <el-option label="三级分类" :value="3" />
            </el-select>
          </el-form-item>
        </el-col>
      </el-row>

      <!-- 属性值管理 -->
      <el-divider content-position="left">属性值管理</el-divider>
      
      <el-form-item label="属性值列表">
        <div class="attr-value-container">
          <div class="attr-value-header">
            <el-button 
              type="primary" 
              link 
              @click="addAttrValue"
              :disabled="isView || !form.attrName"
            >
              + 添加属性值
            </el-button>
            <span class="tip-text">请先输入属性名称，然后添加属性值</span>
          </div>
          
          <div v-for="(value, index) in form.attrValueList" :key="index" class="attr-value-item">
            <el-row :gutter="10" align="middle">
              <el-col :span="16">
                <el-input
                  v-model="value.valueName"
                  placeholder="请输入属性值名称"
                  @blur="validateAttrValue(value, index)"
                  @keyup.enter="validateAttrValue(value, index)"
                />
              </el-col>
              <el-col :span="6">
                <el-button 
                  type="danger" 
                  link 
                  @click="removeAttrValue(index)"
                  :disabled="isView"
                >
                  删除
                </el-button>
              </el-col>
            </el-row>
          </div>
          
          <div v-if="form.attrValueList.length === 0" class="empty-tip">
            <el-empty description="暂无属性值，请添加" :image-size="60" />
          </div>
        </div>
      </el-form-item>

      <!-- 属性值预览 -->
      <el-form-item v-if="form.attrValueList.length > 0" label="属性值预览">
        <div class="preview-container">
          <el-tag 
            v-for="value in form.attrValueList" 
            :key="value.valueName"
            size="large" 
            style="margin: 4px 8px;"
            :type="getTagType(value.valueName)"
          >
            {{ value.valueName }}
          </el-tag>
        </div>
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
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'
import type { FormInstance, FormRules } from 'element-plus'
import { reqSaveOrUpdateAttr } from '@/api/product/attr'
import type { Attr, AttrValue } from '@/api/product/attr/type'
import useCategoryStore from '@/store/modules/category'

// 定义事件
const emit = defineEmits(['change-scene'])

// 表单引用
const formRef = ref<FormInstance>()

// 获取分类仓库
const categoryStore = useCategoryStore()

// 表单数据
const form = reactive<Attr>({
  id: undefined,
  attrName: '',
  categoryId: 0,
  categoryLevel: 3,
  attrValueList: []
})

// 表单验证规则
const rules: FormRules = {
  attrName: [
    { required: true, message: '请输入属性名称', trigger: 'blur' },
    { min: 2, max: 50, message: '长度在 2 到 50 个字符', trigger: 'blur' }
  ],
  categoryLevel: [
    { required: true, message: '请选择分类级别', trigger: 'change' }
  ]
}

// 状态标识
const isEdit = ref(false)
const isView = ref(false)

// 初始化表单
const initForm = (data?: Attr, viewMode = false) => {
  isEdit.value = !!data
  isView.value = viewMode
  
  if (data) {
    // 编辑模式，填充数据
    Object.assign(form, {
      ...data,
      attrValueList: data.attrValueList.map(value => ({
        ...value,
        flag: false // 重置编辑状态
      }))
    })
  } else {
    // 新增模式，重置表单
    resetForm()
  }
}

// 添加属性值
const addAttrValue = () => {
  if (!form.attrName.trim()) {
    ElMessage.warning('请先输入属性名称')
    return
  }
  
  form.attrValueList.push({
    valueName: '',
    flag: true
  })
}

// 删除属性值
const removeAttrValue = (index: number) => {
  form.attrValueList.splice(index, 1)
}

// 验证属性值
const validateAttrValue = (value: AttrValue, index: number) => {
  const trimmedValue = value.valueName.trim()
  
  // 检查是否为空
  if (trimmedValue === '') {
    form.attrValueList.splice(index, 1)
    ElMessage.warning('属性值名称不能为空')
    return false
  }
  
  // 检查是否重复
  const duplicateIndex = form.attrValueList.findIndex((item, idx) => 
    idx !== index && item.valueName.trim() === trimmedValue
  )
  
  if (duplicateIndex !== -1) {
    form.attrValueList.splice(index, 1)
    ElMessage.warning('属性值名称不能重复')
    return false
  }
  
  // 更新值
  value.valueName = trimmedValue
  value.flag = false
  return true
}

// 获取标签类型
const getTagType = (valueName: string) => {
  const colors = ['', 'success', 'warning', 'danger', 'info']
  const index = valueName.length % colors.length
  return colors[index]
}

// 提交表单
const submitForm = async () => {
  if (!formRef.value) return
  
  try {
    await formRef.value.validate()
    
    // 验证属性值
    if (form.attrValueList.length === 0) {
      ElMessage.warning('请至少添加一个属性值')
      return
    }
    
    // 过滤有效的属性值
    const validAttrValues = form.attrValueList.filter(value => 
      value.valueName.trim() !== ''
    )
    
    if (validAttrValues.length === 0) {
      ElMessage.warning('请至少添加一个有效的属性值')
      return
    }
    
    // 构建提交数据
    const submitData: Attr = {
      ...form,
      categoryId: categoryStore.c3Id || 0,
      attrValueList: validAttrValues
    }
    
    // 调用API
    const result = await reqSaveOrUpdateAttr(submitData)
    if (result.ok) {
      ElMessage.success(isEdit.value ? '更新成功' : '添加成功')
      goBack()
    } else {
      ElMessage.error('操作失败')
    }
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
    id: undefined,
    attrName: '',
    categoryId: categoryStore.c3Id || 0,
    categoryLevel: 3,
    attrValueList: []
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

.attr-value-container {
  .attr-value-header {
    display: flex;
    align-items: center;
    margin-bottom: 16px;
    
    .tip-text {
      margin-left: 12px;
      color: #909399;
      font-size: 12px;
    }
  }
  
  .attr-value-item {
    margin-bottom: 12px;
    padding: 12px;
    border: 1px solid #dcdfe6;
    border-radius: 4px;
    background-color: #fafafa;
    
    &:hover {
      border-color: #c0c4cc;
      background-color: #f5f7fa;
    }
  }
  
  .empty-tip {
    padding: 20px;
    text-align: center;
  }
}

.preview-container {
  padding: 12px;
  border: 1px solid #dcdfe6;
  border-radius: 4px;
  background-color: #fafafa;
  min-height: 60px;
}

.text-gray {
  color: #909399;
  font-size: 12px;
}
</style> 