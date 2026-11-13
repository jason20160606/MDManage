<template>
    <div class="app-container">
        <!-- SKU列表页面 -->
        <el-card v-show="scene === 0">
            <template #header>
                <div class="card-header">
                    <span>SKU管理</span>
                    <!-- 移除新增SKU按钮 -->
                </div>
            </template>

            <!-- 搜索区域 -->
            <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
                <el-form-item label="SKU名称">
                    <el-input v-model="queryForm.name" placeholder="请输入SKU名称" clearable style="width: 200px;" />
                </el-form-item>                
                <el-form-item label="品牌">
                    <el-select v-model="queryForm.brandId" placeholder="全部品牌" clearable style="width: 140px;">
                        <el-option v-for="b in brandOptions" :key="b.Id" :label="b.Name" :value="b.Id" />
                    </el-select>
                </el-form-item>
                <el-form-item label="状态">
                    <el-select v-model="queryForm.status" placeholder="请选择状态" clearable style="width: 120px;">
                        <el-option label="上架" :value="true" />
                        <el-option label="下架" :value="false" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="handleQuery">查询</el-button>
                    <el-button @click="resetQuery">重置</el-button>
                </el-form-item>
            </el-form>

            <!-- SKU列表 -->
            <el-table ref="skuTableRef" :data="skuList" border style="width: 100%" v-loading="loading"
                @sort-change="handleSortChange">
                <el-table-column type="index" label="序号" width="60" />
                <el-table-column prop="Name" label="SKU名称" min-width="170" show-overflow-tooltip />  
                <el-table-column prop="Unit" label="规格" width="110" align="center" show-overflow-tooltip>
                    <template #default="{ row }">
                        {{ row.Unit || '-' }}
                    </template>
                </el-table-column>
                <el-table-column prop="SPUName" label="SPU名称" width="130" show-overflow-tooltip />  
                <el-table-column prop="CategoryPath" label="三级分类" min-width="180" sortable="custom" show-overflow-tooltip>
                    <template #default="{ row }">
                        {{ row.CategoryPath || row.CategoryName || '-' }}
                    </template>
                </el-table-column>
                <el-table-column prop="BrandName" label="所属品牌" width="110" show-overflow-tooltip /> 
                <el-table-column prop="PriceDiffUnit" label="补差价(元/箱)" width="115" align="center">
                    <template #default="{ row }">
                        <el-tag type="danger">{{ row.PriceDiffUnit ?? '-' }}</el-tag>
                    </template>
                </el-table-column>                
                <el-table-column prop="QuotaConversion" label="扣库存比例" width="110" align="center">
                    <template #default="{ row }">
                        <span :title="`1 箱额度扣 ${row.QuotaConversion ?? 1} 箱库存`">×{{ row.QuotaConversion ?? 1 }}</span>
                    </template>
                </el-table-column>                
                <el-table-column prop="BoxWeight" label="每箱重量(kg)" width="120" align="center">
                    <template #default="{ row }">
                        {{ row.BoxWeight ? row.BoxWeight : '-' }}
                    </template>
                </el-table-column>
                <el-table-column prop="BoxVolume" label="每箱体积(m³)" width="120" align="center">
                    <template #default="{ row }">
                        {{ row.BoxVolume ? row.BoxVolume : '-' }}
                    </template>
                </el-table-column>
                <el-table-column prop="SpecialSlot" label="额度类型" width="100" align="center">
                    <template #default="{ row }">
                        <el-tag v-if="row.SpecialSlot > 0" type="warning">专属{{ row.SpecialSlot }}</el-tag>
                        <span v-else>通用</span>
                    </template>
                </el-table-column>                
                <el-table-column label="状态" width="90" align="center">
                    <template #default="{ row }">
                        <el-tag :type="row.Status === 1 ? 'success' : 'info'">
                            {{ row.Status === 1 ? '上架' : '下架' }}
                        </el-tag>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="250" fixed="right">
                    <template #default="{ row }">
                        <el-button type="primary" link @click="updateSku(row)">编辑</el-button>
                        <el-button type="info" link @click="viewSku(row)">查看</el-button>
                        <el-button type="warning" link @click="toggleStatus(row)">
                            {{ row.Status === 1 ? '下架' : '上架' }}
                        </el-button>
                        <el-button type="danger" link @click="deleteSku(row)">删除</el-button>
                    </template>
                </el-table-column>
            </el-table>

            <!-- 分页 -->
            <div class="pagination-wrapper">
                <el-pagination
                    v-model:current-page="currentPage"
                    v-model:page-size="pageSize"
                    :page-sizes="[10, 20, 50, 100]"
                    :background="background"
                    layout="total, sizes, prev, pager, next, jumper"
                    :total="total"
                    @current-change="handleCurrentChange"
                    @size-change="handleSizeChange"
                />
            </div>
        </el-card>

        <!-- SKU编辑表单 -->
        <skuForm ref="sku" v-show="scene === 1" @change-scene="changeScene" />

        <!-- SKU详情弹窗 -->
        <el-dialog v-model="showSkuDetailDialog" title="SKU详情" width="600px" :close-on-click-modal="false">
            <div v-if="skuDetail">
                <el-row :gutter="10" style="margin-bottom: 10px;">
                    <el-col :span="24">
                        <div class="sku-detail-info">
                            <p><strong>SKU名称：</strong>{{ skuDetail.Name }}</p>
                            <p><strong>SPU名称：</strong>{{ skuDetail.SPUName }}</p>
                            <p><strong>品牌：</strong>{{ skuDetail.BrandName }}</p>
                            <p><strong>三级分类：</strong>{{ skuDetail.CategoryPath || skuDetail.CategoryName || '-' }}</p>
                            <p><strong>规格：</strong>{{ skuDetail.Unit || '-' }}</p>
                            <p><strong>销售价格：</strong>{{ skuDetail.Price }}</p>
                            <p><strong>成本价格：</strong>{{ skuDetail.CostPrice }}</p>
                            <p><strong>差价：</strong>{{ skuDetail.PriceDiffUnit }}</p>
                            <p><strong>每箱重量：</strong>{{ skuDetail.BoxWeight ? skuDetail.BoxWeight + ' kg' : '-' }}</p>
                            <p><strong>每箱体积：</strong>{{ skuDetail.BoxVolume ? skuDetail.BoxVolume + ' m³' : '-' }}</p>
                            <p><strong>状态：</strong>{{ skuDetail.Status === 1 ? '上架' : '下架' }}</p>
                        </div>
                    </el-col>
                </el-row>
            </div>
            <template #footer>
                <el-button @click="showSkuDetailDialog = false">关闭</el-button>
            </template>
        </el-dialog>
    </div>
</template>

<script setup lang="ts">
import { showError } from '@/utils/request'
import { ref, reactive, onMounted, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqSkuList, reqDeleteSku, reqEnableSku } from '@/api/product/sku'
import { reqGetBrandList } from '@/api/organization/company'
import skuForm from './skuForm.vue'

// 场景值：0-数据展示，1-SKU编辑
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
    name: '',
    skuCode: '',
    brandId: undefined as number | undefined,
    status: undefined as boolean | undefined // 状态筛选为布尔值
})

// 品牌下拉（SKU 通过 SPU 继承品牌；SKU 不再有工厂归属）
const brandOptions = ref<any[]>([])

const loadOptions = async () => {
    try {
        const brandRes = await reqGetBrandList()
        const brandArr = Array.isArray(brandRes) ? brandRes : brandRes?.data || []
        brandOptions.value = brandArr
    } catch (e) {
        brandOptions.value = []
    }
}

// SKU列表
const skuList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPage = ref(1)
const pageSize = ref(50)
const total = ref(0)
const background = ref(true)

// 排序（后端排序，跨分页生效）：如 "CategoryPath asc"
const sortOrderBy = ref('')

// 表格实例（用于清空排序状态）
const skuTableRef = ref()

// SKU详情弹窗相关
import { reqSkuInfo } from '@/api/product/sku'
const showSkuDetailDialog = ref(false)
const skuDetail = ref<any>(null)

// 获取子组件实例
const sku = ref()

// 查询SKU列表
const handleQuery = async () => {
    loading.value = true
    try {
        // 构建查询参数，Status为true/false，未选择时不传
        const params: any = {
            Name: queryForm.name || undefined,
            SkuCode: queryForm.skuCode || undefined,
            BrandId: queryForm.brandId || undefined,
            // 后端分页参数是 PageNumber（原来传 PageIndex 会被忽略，翻页无效）
            PageNumber: currentPage.value,
            PageSize: pageSize.value
        }
        if (queryForm.status === true) params.Status = true
        else if (queryForm.status === false) params.Status = false
        // 三级分类排序：后端按「一级/二级/三级」路径排，跨分页有效
        if (sortOrderBy.value) {
            params.OrderBy = sortOrderBy.value
        }
        
        const result: any = await reqSkuList(params)
        console.log(result)
        if (result.status==200) {
            skuList.value = result.data || []
            
            // 处理分页信息
            if (result.headers && result.headers['x-pagination']) {
                const pagination = JSON.parse(result.headers['x-pagination'])
                currentPage.value = pagination.PageIndex || 1
                pageSize.value = pagination.PageSize || 50
                total.value = pagination.TotalCount || 0
            } else {
                total.value = skuList.value.length
            }
        }
    } catch (error) {
        showError(error, '获取SKU列表失败')
        console.error('SKU查询错误:', error)
    } finally {
        loading.value = false
    }
}

// 重置查询
const resetQuery = () => {
    queryForm.name = ''
    queryForm.skuCode = ''
    queryForm.brandId = undefined
    queryForm.status = undefined
    sortOrderBy.value = ''
    skuTableRef.value?.clearSort()
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

// 编辑SKU - 切换到编辑场景，初始化表单
const updateSku = async (row: any) => {
    scene.value = 1 // 切换到SKU编辑场景，隐藏列表
    // 获取详情，回填表单
    try {
        const result = await reqSkuInfo(row.Id)
        if (result.status === 200) {
            nextTick(() => {
                sku.value?.initForm(result.data)
            })
        } else {
            ElMessage.error('获取SKU详情失败')
        }
    } catch (error) {
        showError(error, '获取SKU详情失败')
        console.error('SKU详情查询错误:', error)
    }
}

// 查看SKU - 弹窗展示详情
const viewSku = async (row: any) => {
    try {
        const result = await reqSkuInfo(row.Id)
        if (result.status === 200) {
            skuDetail.value = result.data
            showSkuDetailDialog.value = true
        } else {
            ElMessage.error('获取SKU详情失败')
        }
    } catch (error) {
        showError(error, '获取SKU详情失败')
        console.error('SKU详情查询错误:', error)
    }
}

// 切换SKU状态 - 保持在列表场景，显示确认对话框
const toggleStatus = async (row: any) => {
    const action = row.Status === 1 ? '下架' : '上架'
    try {
        await ElMessageBox.confirm(
            `确定要${action}SKU"${row.Name}"吗？`,
            '确认操作',
            {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning',
            }
        )
        // 调用API
        await reqEnableSku(row.Id, action === '上架')
        ElMessage.success(`${action}成功`)
        handleQuery() // 刷新列表
    } catch (error) {
        if (error !== 'cancel') {
            ElMessage.error(`${action}失败`)
            console.error('切换状态错误:', error)
        }
    }
}

// 删除SKU - 保持在列表场景，显示确认对话框
const deleteSku = async (row: any) => {
    try {
        await ElMessageBox.confirm(
            `确定要删除SKU"${row.name}"吗？`,
            '确认删除',
            {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                type: 'warning',
            }
        )
        
        // 调用删除API
        await reqDeleteSku(row.Id)
        ElMessage.success('删除成功')
        handleQuery() // 刷新列表
    } catch (error) {
        if (error !== 'cancel') {
            showError(error, '删除失败')
            console.error('删除SKU错误:', error)
        }
    }
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
onMounted(async () => {    
    loadOptions()
    handleQuery()
})
</script>

<style lang="scss" scoped>
.app-container {
    padding: 20px;
}

.category-wrapper {
    margin-bottom: 24px; /* 增加三级分类与SKU管理卡片的距离 */
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

.price {
    color: #f56c6c;
    font-weight: bold;
    font-size: 14px;
}

.text-gray {
    color: #909399;
}

// SKU详情弹窗信息样式优化
.sku-detail-info p {
  margin: 0 0 8px 0;
  line-height: 1.7;
  font-size: 15px;
}
</style>