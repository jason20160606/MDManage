<template>
    <div class="app-container">
        <!-- 分类筛选组件 -->
        <div class="category-wrapper">
            <Category :scene="scene"></Category>
        </div>
        
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
                <el-form-item label="状态">
                    <el-select v-model="queryForm.status" placeholder="请选择状态" clearable style="width: 120px;">
                        <el-option label="上架" :value="1" />
                        <el-option label="下架" :value="0" />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="handleQuery">查询</el-button>
                    <el-button @click="resetQuery">重置</el-button>
                </el-form-item>
            </el-form>

            <!-- SKU列表 -->
            <el-table :data="skuList" border style="width: 100%" v-loading="loading">
                <el-table-column type="index" label="序号" width="80" />
                <el-table-column label="商品图片" width="120">
                    <template #default="{ row }">
                        <el-image
                            :src="row.MainImage || row.images?.[0]"
                            :preview-src-list="row.images || []"
                            fit="cover"
                            style="width: 80px; height: 80px; border-radius: 4px;"
                        >
                            <template #error>
                                <div class="image-error">
                                    <el-icon><Picture /></el-icon>
                                </div>
                            </template>
                        </el-image>
                    </template>
                </el-table-column>
                <el-table-column prop="Name" label="SKU名称" min-width="200" show-overflow-tooltip />  
                <el-table-column prop="SPUName" label="SPU名称" width="150" show-overflow-tooltip />  
                <el-table-column prop="FactoryName" label="所属工厂" width="150" show-overflow-tooltip />                
                <el-table-column prop="BrandName" label="所属品牌" width="150" show-overflow-tooltip /> 
                <el-table-column prop="SpecialPrice" label="差价" width="120" align="center">
                    <template #default="{ row }">
                        <el-tag type="danger">{{ row.SpecialPrice ?? '-' }}</el-tag>
                    </template>
                </el-table-column>                
                <el-table-column label="扣减比例"  align="center">
                    <template #default="{ row }">
                        
                            {{ row.SpecialPrice }}
                        
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
                    <el-col :span="8">
                        <el-image :src="skuDetail.mainImage || skuDetail.images?.[0]" style="width:100px;height:100px; border-radius:6px; box-shadow:0 2px 8px #eee;" fit="cover" />
                    </el-col>
                    <el-col :span="16">
                        <div class="sku-detail-info">
                            <p><strong>SKU名称：</strong>{{ skuDetail.Name }}</p>
                            <p><strong>SPU名称：</strong>{{ skuDetail.SPUName }}</p>
                            <p><strong>品牌：</strong>{{ skuDetail.BrandName }}</p>
                            <p><strong>工厂：</strong>{{ skuDetail.FactoryName }}</p>
                            <p><strong>销售价格：</strong>{{ skuDetail.Price }}</p>
                            <p><strong>成本价格：</strong>{{ skuDetail.CostPrice }}</p>
                            <p><strong>差价：</strong>{{ skuDetail.SpecialPrice }}</p>
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
import { ref, reactive, onMounted, watch, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Picture } from '@element-plus/icons-vue'
import useCategoryStore from '@/store/modules/category'
import { reqSkuList, reqDeleteSku, reqEnableSku, type SkuQueryParams } from '@/api/product/sku'
import skuForm from './skuForm.vue'

// 场景值：0-数据展示，1-SKU编辑
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
    name: '',
    skuCode: '',
    status: undefined as number | undefined
})

// SKU列表
const skuList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)
const background = ref(true)

// SKU详情弹窗相关
import { reqSkuInfo } from '@/api/product/sku'
const showSkuDetailDialog = ref(false)
const skuDetail = ref<any>(null)

// 获取三级分类的仓库
const categoryStore = useCategoryStore()

// 获取子组件实例
const sku = ref()

// 监听三级分类的变化
watch(() => categoryStore.c3Id, () => {
    if (!categoryStore.c3Id) {
        skuList.value = []
        total.value = 0
        return
    }
    handleQuery()
})

// 查询SKU列表
const handleQuery = async () => {
    if (!categoryStore.c3Id) {
        ElMessage.warning('请先选择分类')
        return
    }

    loading.value = true
    try {
        // 构建查询参数
        const params: SkuQueryParams = {
            name: queryForm.name || undefined,
            skuCode: queryForm.skuCode || undefined,
            status: queryForm.status,
            pageIndex: currentPage.value,
            pageSize: pageSize.value
        }
        
        const result: any = await reqSkuList(params)
        console.log(result)
        if (result.status==200) {
            skuList.value = result.data || []
            
            // 处理分页信息
            if (result.headers && result.headers['x-pagination']) {
                const pagination = JSON.parse(result.headers['x-pagination'])
                currentPage.value = pagination.PageIndex || 1
                pageSize.value = pagination.PageSize || 10
                total.value = pagination.TotalCount || 0
            } else {
                total.value = skuList.value.length
            }
        }
    } catch (error) {
        ElMessage.error('获取SKU列表失败')
        console.error('SKU查询错误:', error)
    } finally {
        loading.value = false
    }
}

// 重置查询
const resetQuery = () => {
    queryForm.name = ''
    queryForm.skuCode = ''
    queryForm.status = undefined
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
        ElMessage.error('获取SKU详情失败')
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
        ElMessage.error('获取SKU详情失败')
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
            ElMessage.error('删除失败')
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