<template>
        <div class="app-container">
                <!-- 分类筛选组件 -->
                <Category :scene="scene"></Category>
                
                <!-- SPU列表页面 -->
                <el-card v-show="scene === 0">
                        <template #header>
                                <div class="card-header">
                                        <span>SPU管理</span>
                                        <el-button type="primary" @click="addSpu" :disabled="!categoryStore.c3Id">
                                                新增SPU
                                        </el-button>
                                </div>
                        </template>

                        <!-- 搜索区域 -->
                        <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
                                <el-form-item label="SPU名称">
                                        <el-input v-model="queryForm.name" placeholder="请输入SPU名称" clearable style="width: 200px;" />
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

                        <!-- SPU列表 -->
                        <el-table :data="spuList" border style="width: 100%" v-loading="loading">
                                <el-table-column type="index" label="序号" width="80" />
                                <el-table-column label="商品图片" width="120">
                                        <template #default="{ row }">
                                                <el-image
                                                        :src="row.mainImage"
                                                        :preview-src-list="[row.mainImage]"
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
                                <el-table-column prop="Name" label="SPU名称" min-width="200" show-overflow-tooltip />
                                <el-table-column prop="Description" label="商品描述" min-width="200" show-overflow-tooltip />                                
                                <el-table-column label="SKU数量" width="100" align="center">
                                        <template #default="{ row }">
                                                <el-tag :type="row.SKUs.length > 0 ? 'success' : 'info'">
                                                        {{ row.SKUs.length || 0 }}
                                                </el-tag>
                                        </template>
                                </el-table-column>
                                <el-table-column label="状态" width="100" align="center">
                                        <template #default="{ row }">
                                                <el-tag :type="row.status === 1 ? 'success' : 'info'">
                                                        {{ row.status === 1 ? '上架' : '下架' }}
                                                </el-tag>
                                        </template>
                                </el-table-column>
                                <el-table-column label="操作" width="280" fixed="right">
                                        <template #default="{ row }">
                                                <el-button type="primary" link @click="addSKU(row)" :disabled="row.status === 0">
                                                        添加SKU
                                                </el-button>
                                                <el-button type="success" link @click="updateSpu(row)">编辑</el-button>
                                                <el-button type="info" link @click="viewSpu(row)">查看</el-button>
                                                <el-button type="warning" link @click="toggleStatus(row)">
                                                        {{ row.status === 1 ? '下架' : '上架' }}
                                                </el-button>
                                                <el-button type="danger" link @click="deleteSpu(row)">删除</el-button>
                                        </template>
                                </el-table-column>
                        </el-table>

                        <!-- 分页 -->
                        <div class="pagination-wrapper">
                                <el-pagination
                                        v-model:current-page="currentPageNo"
                                        v-model:page-size="pageSizeNo"
                                        :page-sizes="[10, 20, 50, 100]"
                                        :background="background"
                                        layout="total, sizes, prev, pager, next, jumper"
                                        :total="total"
                                        @current-change="handleCurrentChange"
                                        @size-change="handleSizeChange"
                                />
                        </div>
                </el-card>

                <!-- SPU编辑对话框 -->
                <spuForm ref="spu" v-show="scene === 1" @change-scene="changeScene"></spuForm>
        </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted, watch, nextTick } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { Picture } from '@element-plus/icons-vue'
import useCategoryStore from '@/store/modules/category'
import { reqSPU, reqDeleteSPU, reqToggleSPUStatus } from '@/api/product/spu'
import type { SPUQueryParams } from '@/api/product/spu'
import spuForm from './spuForm.vue'

// 场景值：0-数据展示，1-SPU编辑，2-SKU编辑
const scene = ref<number>(0)

// 查询表单
const queryForm = reactive({
        name: '',
        status: undefined as number | undefined
})

// SPU列表
const spuList = ref<any[]>([])
const loading = ref(false)

// 分页相关
const currentPageNo = ref(1)
const pageSizeNo = ref(10)
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
                // 构建查询参数
                const params: SPUQueryParams = {
                        name: queryForm.name || undefined,
                        categoryId: categoryStore.c3Id,
                        status: queryForm.status,
                        pageNumber: currentPageNo.value,
                        pageSize: pageSizeNo.value
                }
                
                const result: any = await reqSPU(params)
                if (result.status === 200) {
                        spuList.value = result.data || []
                        
                        // 处理分页信息
                        if (result.headers && result.headers['x-pagination']) {
                                const pagination = JSON.parse(result.headers['x-pagination'])
                                currentPageNo.value = pagination.PageIndex || 1
                                pageSizeNo.value = pagination.PageSize || 10
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
        currentPageNo.value = 1
        handleQuery()
}

// 新增SPU - 切换到编辑场景，隐藏列表
const addSpu = () => {
        scene.value = 1 // 切换到SPU编辑场景，隐藏列表
        nextTick(() => {
                spu.value?.initForm() // 初始化新增表单
        })
}

// 编辑SPU - 切换到编辑场景，隐藏列表
const updateSpu = (row: any) => {
        scene.value = 1 // 切换到SPU编辑场景，隐藏列表
        nextTick(() => {
                spu.value?.initForm(row) // 初始化编辑表单
        })
}

// 查看SPU - 切换到编辑场景，隐藏列表
const viewSpu = (row: any) => {
        scene.value = 1 // 切换到SPU编辑场景，隐藏列表
        nextTick(() => {
                spu.value?.initForm(row, true) // 初始化只读表单
        })
}

// 切换SPU状态 - 保持在列表场景，显示确认对话框
const toggleStatus = async (row: any) => {
        const action = row.status === 1 ? '下架' : '上架'
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
                
                await reqToggleSPUStatus(Number(row.Id), row.status === 1 ? 0 : 1)
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
        scene.value = 2 // 切换到SKU编辑场景，隐藏列表
        // TODO: 这里需要实现SKU表单组件
        ElMessage.info('SKU管理功能待实现')
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
        currentPageNo.value = page
        handleQuery()
}

const handleSizeChange = (size: number) => {
        pageSizeNo.value = size
        currentPageNo.value = 1
        handleQuery()
}

// 初始化
onMounted(() => {
        // 页面加载时不自动查询，等待用户选择分类
})
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
</style>