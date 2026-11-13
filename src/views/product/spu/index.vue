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
                        <el-table ref="spuTableRef" :data="spuList" border style="width: 100%" v-loading="loading"
                                @sort-change="handleSortChange">
                                <el-table-column type="index" label="序号" width="80" />
                                <el-table-column prop="BrandName" label="SPU品牌" min-width="60" />
                                <el-table-column prop="Name" label="SPU名称" min-width="100" />
                                <el-table-column prop="CategoryPath" label="三级分类" min-width="200" sortable="custom"
                                        show-overflow-tooltip>
                                        <template #default="{ row }">
                                                {{ row.CategoryPath || row.CategoryName || '无' }}
                                        </template>
                                </el-table-column>
                                <el-table-column prop="Description" label="商品描述" min-width="200"
                                        show-overflow-tooltip />
                                <el-table-column label="SKU数量" width="100" align="center">
                                        <template #default="{ row }">
                                                <el-tag :type="(row.SkuCount || 0) > 0 ? 'success' : 'info'">
                                                        {{ row.SkuCount ?? row.SKUs?.length ?? 0 }}
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
                                <el-col :span="24">
                                    <p><strong>SPU名称：</strong>{{ detailData.Name }}</p>
                                    <p><strong>品牌：</strong>{{ detailData.BrandName }}</p>
                                    <!-- 所属分类：显示「一级 / 二级 / 三级」全路径 -->
                                    <p><strong>三级分类：</strong>{{ detailData.CategoryPath || detailData.CategoryName || '无' }}</p>
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
                            <el-table-column prop="Unit" label="规格" width="110" align="center">
                                <template #default="{ row }">
                                    {{ row.Unit || '-' }}
                                </template>
                            </el-table-column>
                            <el-table-column prop="Price" label="价格" width="100" align="center" />
                            <el-table-column prop="PriceDiffUnit" label="差价" width="100" align="center">
                                <template #default="{ row }">
                                    {{ row.PriceDiffUnit ?? '-' }}
                                </template>
                            </el-table-column>                            
                            <el-table-column prop="QuotaConversion" label="扣库存比例" width="110" align="center">
                                <template #default="{ row }">
                                    {{ row.QuotaConversion ?? '-' }}
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
                        <el-form-item label="扣库存比例" prop="stockRatio">
                            <!-- 使用数字输入框，最大100 -->
                            <el-input-number v-model="addSkuForm.stockRatio" :min="0" :max="100" :step="0.1" placeholder="请输入扣库存比例" style="width: 100%;" />
                        </el-form-item>
                        <!-- 每箱重量 / 体积（发货与运费按箱计量） -->
                        <el-form-item label="每箱重量(kg)">
                            <el-input-number v-model="addSkuForm.boxWeight" :min="0" :precision="3" :step="0.1" placeholder="1箱毛重，单位kg" style="width: 100%;" />
                        </el-form-item>
                        <el-form-item label="每箱体积(m³)">
                            <el-input-number v-model="addSkuForm.boxVolume" :min="0" :precision="4" :step="0.001" placeholder="1箱体积，单位m³" style="width: 100%;" />
                        </el-form-item>
                        <!-- 规格 -->
                        <el-form-item label="规格" prop="unit">
                            <el-input v-model="addSkuForm.unit" placeholder="如 10瓶/箱、6盒/箱" maxlength="50" clearable />
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
                    </el-form>
                    <template #footer>
                        <el-button @click="showAddSkuDialog = false">取消</el-button>
                        <el-button type="primary" @click="submitAddSku">确定</el-button>
                    </template>
                </el-dialog>

                <!-- 商品图片大图弹窗 -->
        </div>
</template>

<script setup lang="ts">
import { showError } from '@/utils/request'
import { ref, reactive, onMounted, watch, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import useCategoryStore from '@/store/modules/category'
import { reqSPU, reqDeleteSPU, reqToggleSPUStatus, reqSPUDetail } from '@/api/product/spu'
import spuForm from './spuForm.vue'

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
const pageSize = ref(50)
const total = ref(0)
const background = ref(true)

// 排序（后端排序，跨分页生效）：如 "CategoryPath asc"
const sortOrderBy = ref('')

// 获取三级分类的仓库
const categoryStore = useCategoryStore()

// 获取子组件实例
const spu = ref()

// 表格实例（用于清空排序状态）
const spuTableRef = ref()

// 监听三级分类的变化（分类只是可选筛选，清空分类时查询全部）
watch(() => categoryStore.c3Id, () => {
        currentPage.value = 1
        handleQuery()
})

// 查询SPU列表
const handleQuery = async () => {
        loading.value = true
        try {
                // 构建查询参数，Name大写，Status为true/false，未选择时不传
                const params: any = {
                        Name: queryForm.name || undefined,
                        PageNumber: currentPage.value,
                        PageSize: pageSize.value
                }
                if (categoryStore.c3Id) {
                        params.CategoryId = Number(categoryStore.c3Id)
                }
                if (queryForm.status !== undefined) {
                  params.Status = queryForm.status
                }
                // 三级分类排序：交给后端按「一级/二级/三级」路径排，跨分页有效
                if (sortOrderBy.value) {
                        params.OrderBy = sortOrderBy.value
                }

                const result: any = await reqSPU(params)
                if (result.status === 200) {
                        spuList.value = result.data || []

                        // 处理分页信息
                        if (result.headers && result.headers['x-pagination']) {
                                const pagination = JSON.parse(result.headers['x-pagination'])
                                currentPage.value = pagination.PageIndex || 1
                                pageSize.value = pagination.PageSize || 50
                                total.value = pagination.TotalCount || 0
                        } else {
                                total.value = spuList.value.length
                        }
                }
        } catch (error) {
                showError(error, '获取SPU列表失败')
                console.error('SPU查询错误:', error)
        } finally {
                loading.value = false
        }
}

// 重置查询
const resetQuery = () => {
        queryForm.name = ''
        queryForm.status = undefined
        sortOrderBy.value = ''
        spuTableRef.value?.clearSort()
        currentPage.value = 1
        handleQuery()
}

// 表头排序：目前只开放「三级分类」，由后端按分类全路径排序
const handleSortChange = ({ prop, order }: any) => {
        if (!order || prop !== 'CategoryPath') {
                sortOrderBy.value = ''
        } else {
                sortOrderBy.value = order === 'descending' ? 'CategoryPath desc' : 'CategoryPath asc'
        }
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
                showError(error, '获取SPU详情失败')
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
                showError(error, '获取SPU详情失败')
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
                        showError(error, '删除失败')
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
        // 打开页面直接展示全部 SPU，分类作为可选筛选
        handleQuery()
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
  diffPrice: 0, // 差价（用于PriceDiffUnit），默认 0
  status: 1, // 状态
  salePrice: 100, // 销售价格（Price），默认 100
  costPrice: 100, // 成本价格，默认 100
  stockRatio: 1, // 扣库存比例（QuotaConversion），默认 1
  boxWeight: undefined, // 每箱重量（kg）
  boxVolume: undefined, // 每箱体积（m³）
  unit: '', // 规格（自由文本，如 10瓶/箱）
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
    diffPrice: 0,
    status: 1,
    salePrice: 100,
    costPrice: 100,
    stockRatio: 1,
    boxWeight: undefined,
    boxVolume: undefined,
    unit: '',
    mainImage: '',
  })
  showAddSkuDialog.value = true
}

// 提交新增SKU
const submitAddSku = () => {
  addSkuFormRef.value.validate(async (valid: boolean) => {
    if (!valid) return
    try {
      // 组装参数，字段名与后端一致，PriceDiffUnit取diffPrice
      const params = {
        SPUId: currentSpuIdForAddSku,
        Name: addSkuForm.name,
        PriceDiffUnit: Number(addSkuForm.diffPrice),
        Price: Number(addSkuForm.salePrice),
        CostPrice: Number(addSkuForm.costPrice),
        QuotaConversion: Number(addSkuForm.stockRatio),
        BoxWeight: Number(addSkuForm.boxWeight) || 0,
        BoxVolume: Number(addSkuForm.boxVolume) || 0,
        Unit: addSkuForm.unit || '',
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

// ========== 商品图片相关逻辑已移除：后台暂不展示商品图，等以后做商城再加 ==========
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
</style>