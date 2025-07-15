<template>
        <div class="app-container">
                <!-- 分类筛选组件 -->
                <div class="category-wrapper">
                        <Category :scene="scene"></Category>
                </div>

                <!-- SPU列表页面 -->
                <el-card v-show="scene === 0">
                        <template #header>
                                <div class="card-header">
                                        <span>SPU管理</span>
                                        <el-button type="primary" @click="addSpu">
                                                新增SPU
                                        </el-button>
                                </div>
                        </template>

                        <!-- 搜索区域 -->
                        <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
                                <el-form-item label="SPU名称">
                                        <el-input v-model="queryForm.name" placeholder="请输入SPU名称" clearable
                                                style="width: 200px;" />
                                </el-form-item>
                                <el-form-item label="状态">
                                        <el-select v-model="queryForm.status" placeholder="请选择状态" clearable
                                                style="width: 120px;">
                                                <el-option label="上架" :value="true" />
                                                <el-option label="下架" :value="false" />
                                        </el-select>
                                </el-form-item>
                                <el-form-item>
                                        <el-button type="primary" @click="handleQuery">查询</el-button>
                                        <el-button @click="resetQuery">重置</el-button>
                                </el-form-item>
                        </el-form>

                        <!-- SPU列表 -->
                        <el-table :data="spuList" border style="width: 100%" v-loading="loading">
                                <el-table-column type="index" label="序号" width="80" />
                                <el-table-column label="商品图片" width="120">
                                        <template #default="{ row }">
                                                <!-- 点击图片时，调用 handleImageClick 方法 -->
                                                <el-image
                                                        style="width: 60px; height: 60px; cursor: pointer"
                                                        :src="row.MainImage"
                                                        fit="cover"
                                                        @click="handleImageClick(row.MainImage)"
                                                />
                                        </template>
                                </el-table-column>
                                <el-table-column prop="BrandName" label="SPU品牌" min-width="60" />
                                <el-table-column prop="Name" label="SPU名称" min-width="100" />
                                <el-table-column prop="Description" label="商品描述" min-width="200"
                                        show-overflow-tooltip />
                                <el-table-column label="SKU数量" width="100" align="center">
                                        <template #default="{ row }">
                                                <el-tag :type="row.SKUs.length > 0 ? 'success' : 'info'">
                                                        {{ row.SKUs.length || 0 }}
                                                </el-tag>
                                        </template>
                                </el-table-column>
                                <el-table-column label="状态" width="100" align="center">
                                        <template #default="{ row }">
                                                <el-tag :type="row.Status === 1 ? 'success' : 'info'">
                                                        {{ row.Status === 1 ? '上架' : '下架' }}
                                                </el-tag>
                                        </template>
                                </el-table-column>
                                <el-table-column label="操作" width="280" fixed="right">
                                        <template #default="{ row }">
                                                <el-button type="primary" link @click="addSKU(row)">
                                                        添加SKU
                                                </el-button>
                                                <el-button type="success" link @click="updateSpu(row)">编辑</el-button>
                                                <el-button type="info" link @click="viewSpu(row)">查看</el-button>
                                                <el-button type="warning" link @click="toggleStatus(row)">
                                                        {{ row.Status === 1 ? '下架' : '上架' }}
                                                </el-button>
                                                <el-button type="danger" link @click="deleteSpu(row)">删除</el-button>
                                        </template>
                                </el-table-column>
                        </el-table>

                        <!-- 分页 -->
                        <div class="pagination-wrapper">
                                <el-pagination v-model:current-page="currentPage" v-model:page-size="pageSize"
                                        :page-sizes="[10, 20, 50, 100]" :background="background"
                                        layout="total, sizes, prev, pager, next, jumper" :total="total"
                                        @current-change="handleCurrentChange" @size-change="handleSizeChange" />
                        </div>
                </el-card>

                <!-- SPU编辑对话框 -->
                <spuForm ref="spu" v-show="scene === 1" @change-scene="changeScene"></spuForm>

                <!-- SPU详情弹窗 -->
                <el-dialog v-model="showDetailDialog" title="SPU详情" width="800px" :close-on-click-modal="false">
                    <div v-if="detailData">
                        <!-- SPU基本信息 -->
                        <div class="spu-detail-info">
                            <el-row :gutter="20">
                                <el-col :span="6">
                                    <el-image :src="detailData.MainImage" style="width: 100px; height: 100px;" fit="cover" />
                                </el-col>
                                <el-col :span="18">
                                    <p><strong>SPU名称：</strong>{{ detailData.Name }}</p>
                                    <p><strong>品牌：</strong>{{ detailData.BrandName }}</p>
                                    <!-- 新增：所属分类展示，字段名如有不同请调整 -->
                                    <p><strong>所属分类：</strong>{{ detailData.CategoryName || '无' }}</p>
                                    <p><strong>状态：</strong>                                        
                                            {{ detailData.Status === 1 ? '上架' : '下架' }}                                       
                                    </p>
                                    <p><strong>描述：</strong>{{ detailData.Description }}</p>
                                </el-col>
                            </el-row>
                        </div>
                        <el-divider>SKU列表</el-divider>
                        <!-- SKU列表表格 -->
                        <el-table :data="detailData.SKUs || []" border style="width: 100%">
                            <el-table-column prop="Code" label="SKU编号" width="180" />
                            <el-table-column prop="Name" label="SKU名称" min-width="120" />
                            <el-table-column prop="Price" label="价格" width="100" align="center" />
                            <el-table-column prop="SpecialPrice" label="差价" width="100" align="center">
                                <template #default="{ row }">
                                    {{ row.SpecialPrice ?? '-' }}
                                </template>
                            </el-table-column>                            
                            <el-table-column prop="QuotaDeductRatio" label="扣减比例" width="100" align="center">
                                <template #default="{ row }">
                                    {{ row.QuotaDeductRatio ?? '-' }}
                                </template>
                            </el-table-column>
                            <el-table-column prop="Status" label="状态" width="100">
                                <template #default="{ row }">
                                    <el-tag :type="row.Status === 1 ? 'success' : 'info'">
                                        {{ row.Status === 1 ? '上架' : '下架' }}
                                    </el-tag>
                                </template>
                            </el-table-column>
                        </el-table>
                    </div>
                    <template #footer>
                        <el-button @click="showDetailDialog = false">关闭</el-button>
                    </template>
                </el-dialog>

                <!-- ========== 新增：添加SKU弹窗表单 ========== -->
                <el-dialog v-model="showAddSkuDialog" title="添加SKU" width="500px" :close-on-click-modal="false">
                    <!-- label-width统一调整为150px，便于标签对齐 -->
                    <el-form :model="addSkuForm" :rules="addSkuRules" ref="addSkuFormRef" label-width="150px">
                        <!-- SPU名称（只读） -->
                        <el-form-item label="SPU名称" prop="spuName">
                            <el-input v-model="addSkuForm.spuName" disabled />
                        </el-form-item>
                        <!-- SKU名称 -->
                        <el-form-item label="SKU名称" prop="name">
                            <el-input v-model="addSkuForm.name" placeholder="请输入SKU名称" />
                        </el-form-item>
                        <!-- 差价 -->
                        <el-form-item label="差价" prop="diffPrice">
                            <!-- 使用数字输入框 -->
                            <el-input-number v-model="addSkuForm.diffPrice" :min="0" :step="0.01" placeholder="请输入差价" style="width: 100%;" />
                        </el-form-item>
                        <!-- 销售价格 -->
                        <el-form-item label="销售价格" prop="salePrice">
                            <!-- 使用数字输入框 -->
                            <el-input-number v-model="addSkuForm.salePrice" :min="0" :step="0.01" placeholder="请输入销售价格" style="width: 100%;" />
                        </el-form-item>
                        <!-- 成本价格 -->
                        <el-form-item label="成本价格" prop="costPrice">
                            <!-- 使用数字输入框 -->
                            <el-input-number v-model="addSkuForm.costPrice" :min="0" :step="0.01" placeholder="请输入成本价格" style="width: 100%;" />
                        </el-form-item>
                        <!-- 扣库存比例 -->
                        <el-form-item label="扣库存比例（倍数）" prop="stockRatio">
                            <!-- 使用数字输入框，最大100 -->
                            <el-input-number v-model="addSkuForm.stockRatio" :min="0" :max="100" :step="0.1" placeholder="请输入扣库存比例" style="width: 100%;" />
                        </el-form-item>
                        <!-- 单位 -->
                        <el-form-item label="单位" prop="unit">
                            <el-select v-model="addSkuForm.unit" placeholder="请选择单位" style="width: 100%;">
                                <el-option label="箱" :value="1" />
                                <el-option label="件" :value="2" />
                                <el-option label="套" :value="3" />
                                <el-option label="支" :value="4" />
                                <el-option label="盒" :value="5" />
                                <el-option label="瓶" :value="6" />
                                <el-option label="个" :value="7" />
                                <el-option label="公斤" :value="8" />
                            </el-select>
                        </el-form-item>
                        <!-- 状态 -->
                        <el-form-item label="状态" prop="status">
                            <!-- 使用el-switch替代下拉框，开为上架（1），关为下架（0） -->
                            <el-switch
                                v-model="addSkuForm.status"
                                :active-value="1"
                                :inactive-value="0"
                                active-text="上架"
                                inactive-text="下架"
                            />
                        </el-form-item>
                        <!-- 商品图 -->
                        <el-form-item label="商品图" prop="mainImage">
                            <!-- 上传控件与SPU新增一致，上传到/api/Upload，type=spuMain，name=file，2MB限制，回显图片 -->
                            <el-upload
                                class="avatar-uploader"
                                action="/api/Upload"
                                :data="{ type: 'spuMain' }"
                                name="file"
                                :show-file-list="false"
                                :on-success="handleSkuImageSuccess"
                                :before-upload="beforeSkuImageUpload"
                            >
                                <!-- 已上传则显示图片，否则显示上传图标 -->
                                <img v-if="addSkuForm.mainImage" :src="addSkuForm.mainImage" class="avatar" />
                                <el-icon v-else class="avatar-uploader-icon">
                                    <Plus />
                                </el-icon>
                            </el-upload>
                        </el-form-item>
                    </el-form>
                    <template #footer>
                        <el-button @click="showAddSkuDialog = false">取消</el-button>
                        <el-button type="primary" @click="submitAddSku">确定</el-button>
                    </template>
                </el-dialog>

                <!-- 商品图片大图弹窗 -->
                <!-- 设置弹窗宽度为320px，防止弹窗过大 -->
                <el-dialog
                        v-model="showImageDialog"                       
                        :close-on-click-modal="true"
                        title="商品图片"
                        center
                        width="500px"
                >
                        <div style="text-align: center;">
                                <!-- 商品图片预览，最大宽高280px，自适应显示 -->
                                <img :src="previewImageUrl" class="img-preview-dialog" />
                        </div>
                </el-dialog>
        </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import useCategoryStore from '@/store/modules/category'
import { reqSPU, reqDeleteSPU, reqToggleSPUStatus, reqSPUDetail } from '@/api/product/spu'
import type { SPUQueryParams } from '@/api/product/spu'
import spuForm from './spuForm.vue'
import { Plus } from '@element-plus/icons-vue' // 引入Plus图标

// 场景值：0-数据展示，1-SPU编辑，2-SKU编辑
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
        name: '',
        status: undefined as boolean | undefined // 状态筛选为布尔值
})

// SPU列表
const spuList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// 获取三级分类的仓库
const categoryStore = useCategoryStore()

// 获取子组件实例
const spu = ref()

// 监听三级分类的变化
watch(() => categoryStore.c3Id, () => {
        if (!categoryStore.c3Id) {
                spuList.value = []
                total.value = 0
                return
        }
        handleQuery()
})

// 查询SPU列表
const handleQuery = async () => {
        if (!categoryStore.c3Id) {
                ElMessage.warning('请先选择分类')
                return
        }

        loading.value = true
        try {
                // 构建查询参数，Name大写，Status为true/false，未选择时不传
                const params: any = {
                        Name: queryForm.name || undefined,
                        CategoryId: Number(categoryStore.c3Id),
                        PageNumber: currentPage.value,
                        PageSize: pageSize.value
                }
                if (queryForm.status !== undefined) {
                  params.Status = queryForm.status
                }

                const result: any = await reqSPU(params)
                if (result.status === 200) {
                        spuList.value = result.data || []

                        // 处理分页信息
                        if (result.headers && result.headers['x-pagination']) {
                                const pagination = JSON.parse(result.headers['x-pagination'])
                                currentPage.value = pagination.PageIndex || 1
                                pageSize.value = pagination.PageSize || 10
                                total.value = pagination.TotalCount || 0
                        } else {
                                total.value = spuList.value.length
                        }
                }
        } catch (error) {
                ElMessage.error('获取SPU列表失败')
                console.error('SPU查询错误:', error)
        } finally {
                loading.value = false
        }
}

// 重置查询
const resetQuery = () => {
        queryForm.name = ''
        queryForm.status = undefined
        currentPage.value = 1
        handleQuery()
}

// 新增SPU - 切换到编辑场景，隐藏列表
const addSpu = () => {
        scene.value = 1 // 切换到SPU编辑场景，隐藏列表
        nextTick(() => {
                spu.value?.initForm() // 初始化新增表单
        })
}

// 编辑SPU - 通过接口查询详情后赋值
const updateSpu = async (row: any) => {
        scene.value = 1 // 切换到SPU编辑场景，隐藏列表
        try {
                const result = await reqSPUDetail(row.Id)
                if (result.status === 200) {
                        nextTick(() => {
                                console.log(result.data)
                                spu.value?.initForm(result.data) // 用接口返回的数据初始化表单
                        })
                } else {
                        ElMessage.error('获取SPU详情失败')
                }
        } catch (error) {
                ElMessage.error('获取SPU详情失败')
                console.error('SPU详情查询错误:', error)
        }
}

// 修改查看SPU方法，改为弹窗展示
const viewSpu = async (row: any) => {
        try {
                const result = await reqSPUDetail(row.Id)
                if (result.status === 200) {
                        detailData.value = result.data
                        showDetailDialog.value = true
                } else {
                        ElMessage.error('获取SPU详情失败')
                }
        } catch (error) {
                ElMessage.error('获取SPU详情失败')
                console.error('SPU详情查询错误:', error)
        }
}

// 切换SPU状态 - 保持在列表场景，显示确认对话框
const toggleStatus = async (row: any) => {
        const action = row.Status === 1 ? '下架' : '上架'
        try {
                await ElMessageBox.confirm(
                        `确定要${action}SPU"${row.Name}"吗？`,
                        '确认操作',
                        {
                                confirmButtonText: '确定',
                                cancelButtonText: '取消',
                                type: 'warning',
                        }
                )

                // 新API，IsEnabled为true表示上架，false表示下架
                await reqToggleSPUStatus(Number(row.Id), row.Status === 0)
                ElMessage.success(`${action}成功`)
                handleQuery() // 刷新列表
        } catch (error) {
                if (error !== 'cancel') {
                        ElMessage.error(`${action}失败`)
                        console.error('切换状态错误:', error)
                }
        }
}

// 删除SPU - 保持在列表场景，显示确认对话框
const deleteSpu = async (row: any) => {
        try {
                await ElMessageBox.confirm(
                        `确定要删除SPU"${row.Name}"吗？删除后将同时删除其下所有SKU！`,
                        '确认删除',
                        {
                                confirmButtonText: '确定',
                                cancelButtonText: '取消',
                                type: 'warning',
                        }
                )

                await reqDeleteSPU(Number(row.Id))
                ElMessage.success('删除成功')
                handleQuery() // 刷新列表
        } catch (error) {
                if (error !== 'cancel') {
                        ElMessage.error('删除失败')
                        console.error('删除SPU错误:', error)
                }
        }
}

// 新增SKU - 切换到SKU编辑场景，隐藏列表
const addSKU = (row: any) => {
        openAddSkuDialog(row.Id, row.Name)
}

// 子组件自定义事件 - 切换场景
const changeScene = (num: number) => {
        scene.value = num
        if (num === 0) {
                handleQuery() // 返回列表时刷新数据
        }
}

// 分页相关方法
const handleCurrentChange = (page: number) => {
        currentPage.value = page
        handleQuery()
}

const handleSizeChange = (size: number) => {
        pageSize.value = size
        currentPage.value = 1
        handleQuery()
}

// 初始化
onMounted(() => {
        // 页面加载时不自动查询，等待用户选择分类
})

// ========== 新增：SPU详情弹窗相关逻辑 ==========
// 控制详情弹窗显示
const showDetailDialog = ref(false)
// 存储详情数据
const detailData = ref<any>(null)

// ========== 新增：添加SKU弹窗表单相关逻辑 ==========
import { reqAddSku } from '@/api/product/sku' // 正确导入添加SKU接口
const showAddSkuDialog = ref(false) // 控制弹窗显示
const addSkuForm = reactive({
  spuName: '', // SPU名称（只读）  
  name: '',    // SKU名称
  diffPrice: undefined, // 差价（用于SpecialPrice）
  status: 1, // 状态
  salePrice: undefined, // 销售价格（Price）
  costPrice: undefined, // 成本价格
  stockRatio: undefined, // 扣库存比例（QuotaDeductRatio）
  unit: undefined, // 单位
  mainImage: '', // 商品图（MainImage）
})
const addSkuRules = {
  spuName: [{ required: true, message: 'SPU名称不能为空', trigger: 'blur' }],
  name: [{ required: true, message: '请输入SKU名称', trigger: 'blur' }],
  diffPrice: [{ required: true, message: '请输入差价', trigger: 'blur' }],
  status: [{ required: true, message: '请选择状态', trigger: 'change' }],
  salePrice: [{ required: true, message: '请输入销售价格', trigger: 'blur' }],
  costPrice: [{ required: true, message: '请输入成本价格', trigger: 'blur' }],
  stockRatio: [{ required: true, message: '请输入扣库存比例', trigger: 'blur' }],
  unit: [{ required: true, message: '请选择单位', trigger: 'change' }],
  mainImage: [{ required: true, message: '请上传商品图', trigger: 'change' }],
}
const addSkuFormRef = ref()
let currentSpuIdForAddSku = 0 // 记录当前操作的SPU Id

// 打开添加SKU弹窗，记录SPU Id和SPU名称
const openAddSkuDialog = (spuId: number, spuName: string = '') => {
  currentSpuIdForAddSku = spuId
  Object.assign(addSkuForm, {
    spuName: spuName,
    skuCode: '',
    name: '',
    diffPrice: undefined,
    status: 1,
    salePrice: undefined,
    costPrice: undefined,
    stockRatio: undefined,
    unit: undefined,
    mainImage: '',
  })
  showAddSkuDialog.value = true
}

// 商品图上传前校验（与SPU新增一致）
const beforeSkuImageUpload = (file: File) => {
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
// 商品图上传成功回调（与SPU新增一致，拼接完整URL）
const handleSkuImageSuccess = (response: any) => {
  const baseUrl = import.meta.env.VITE_APP_SERVE || 'http://localhost:5161';
  addSkuForm.mainImage = response.data ? `${baseUrl}/${response.data}` : response.url;
  ElMessage.success('商品图上传成功');
}

// 提交新增SKU
const submitAddSku = () => {
  addSkuFormRef.value.validate(async (valid: boolean) => {
    if (!valid) return
    try {
      // 组装参数，字段名与后端一致，SpecialPrice取diffPrice
      const params = {
        SPUId: currentSpuIdForAddSku,
        Name: addSkuForm.name,
        SpecialPrice: Number(addSkuForm.diffPrice),
        Price: Number(addSkuForm.salePrice),
        CostPrice: Number(addSkuForm.costPrice),
        QuotaDeductRatio: Number(addSkuForm.stockRatio),
        Unit: Number(addSkuForm.unit),
        MainImage: addSkuForm.mainImage,
        Status: addSkuForm.status
      }
      await reqAddSku(params as any)
      ElMessage.success('添加SKU成功')
      showAddSkuDialog.value = false
      // 刷新SPU详情（如果详情弹窗打开）
      if (detailData.value && detailData.value.Id === currentSpuIdForAddSku) {
        const detailRes = await reqSPUDetail(currentSpuIdForAddSku)
        if (detailRes && detailRes.status === 200) detailData.value = detailRes.data
      }
    } catch (error: any) {
      ElMessage.error((error && error.Message) || '添加SKU失败')
      console.error('添加SKU错误:', error)
    }
  })
}

// ========== 新增：商品图片弹窗相关逻辑 ==========
const showImageDialog = ref(false) // 控制图片弹窗显示
const previewImageUrl = ref('')    // 当前预览图片地址

// 点击图片时，打开弹窗并设置图片地址
const handleImageClick = (url: string) => {
  previewImageUrl.value = url
  showImageDialog.value = true
}
</script>

<style lang="scss" scoped>
.app-container {
        padding: 20px;
}

.card-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
}

.search-form {
        margin-bottom: 20px;
}

.pagination-wrapper {
        margin-top: 20px;
        display: flex;
        justify-content: flex-end;
}

.image-error {
        display: flex;
        justify-content: center;
        align-items: center;
        width: 80px;
        height: 80px;
        background-color: #f5f7fa;
        color: #c0c4cc;
        font-size: 20px;
}

.text-gray {
        color: #909399;
}

.category-wrapper {
        margin-bottom: 20px;
        /* 分类筛选与下方内容的间距 */
}

/* ========== 新增：SPU详情弹窗信息行间距美化 ========== */
.spu-detail-info p {
        margin-bottom: 14px; /* 每行信息下方增加间距，提升可读性 */
        line-height: 1.8;
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

/* 商品图片弹窗图片样式
   - 最大宽高280px，防止弹窗过大
   - object-fit: contain 保证图片完整显示且不变形
   - display: inline-block 保证图片居中
*/
.img-preview-dialog {
  max-width: 400px;   /* 最大宽度280px，适应弹窗 */
  max-height: 400px;  /* 最大高度280px，防止撑大弹窗 */
  border-radius: 8px;  /* 圆角美化 */
  box-shadow: 0 2px 8px rgba(0,0,0,0.15); /* 阴影效果 */
  object-fit: contain; /* 保证图片完整显示且不变形 */
  display: inline-block; /* 居中显示 */
}
</style>