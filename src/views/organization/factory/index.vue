<template>
    <div class="app-container">
      <el-card>
        <template #header>
          <div class="card-header">
            <span>工厂管理</span>
            <el-button type="primary" @click="handleAdd">新增工厂</el-button>
          </div>
        </template>
  
        <!-- 搜索区域 -->
        <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
          <el-form-item label="工厂名称">
            <el-input v-model="queryForm.name" placeholder="请输入工厂名称" clearable />
          </el-form-item>         
          <el-form-item>
            <el-button type="primary" @click="handleQuery">查询</el-button>
            <el-button @click="resetQuery">重置</el-button>
          </el-form-item>
        </el-form>
  
        <!-- 工厂列表 -->
        <el-table :data="factoryList" border style="width: 100%">
          <el-table-column prop="Id" label="工厂代码" width="120" />
          <el-table-column prop="Name" label="工厂名称" />
          <el-table-column prop="ContactPerson" label="负责人" />
          <el-table-column prop="ContactPhone" label="联系电话" />
          <el-table-column prop="Address" label="工厂地址" show-overflow-tooltip />          
          <el-table-column label="操作" width="280">
            <template #default="{ row }">
              <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
              <el-button type="primary" link @click="handleView(row)">查看</el-button>
              <el-button type="primary" link @click="handleInventory(row)">库存</el-button>
              <el-button type="primary" link @click="handleWarning(row)">预警</el-button>
              <el-button
                type="primary"
                link
                @click="handleToggleStatus(row)"
              >
                {{ row.status === 'active' ? '停用' : '启用' }}
              </el-button>
            </template>
          </el-table-column>
        </el-table>
  
        <!-- 分页 -->
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="currentPage"
            v-model:page-size="pageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="total"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleSizeChange"
            @current-change="handleCurrentChange"
          />
        </div>
      </el-card>
  
      <!-- 工厂编辑对话框 -->
      <el-dialog
        v-model="dialogVisible"
        :title="dialogType === 'add' ? '新增工厂' : '编辑工厂'"
        width="600px"
      >
        <el-form :model="factoryForm" label-width="100px">
          <el-form-item label="工厂代码" required>
            <el-input v-model="factoryForm.code" placeholder="请输入工厂代码" />
          </el-form-item>
          <el-form-item label="工厂名称" required>
            <el-input v-model="factoryForm.name" placeholder="请输入工厂名称" />
          </el-form-item>
          <el-form-item label="负责人" required>
            <el-input v-model="factoryForm.manager" placeholder="请输入负责人" />
          </el-form-item>
          <el-form-item label="联系电话" required>
            <el-input v-model="factoryForm.phone" placeholder="请输入联系电话" />
          </el-form-item>
          <el-form-item label="工厂地址" required>
            <el-input v-model="factoryForm.address" type="textarea" placeholder="请输入工厂地址" />
          </el-form-item>
          <el-form-item label="生产许可证">
            <el-upload
              class="upload-demo"
              action="/api/upload"
              :on-success="handleUploadSuccess"
              :on-error="handleUploadError"
            >
              <el-button type="primary">上传许可证</el-button>
            </el-upload>
          </el-form-item>
          <el-form-item label="状态">
            <el-switch
              v-model="factoryForm.status"
              :active-value="'active'"
              :inactive-value="'inactive'"
            />
          </el-form-item>
        </el-form>
        <template #footer>
          <div class="dialog-footer">
            <el-button @click="dialogVisible = false">取 消</el-button>
            <el-button type="primary" @click="handleSave">确 定</el-button>
          </div>
        </template>
      </el-dialog>
  
      <!-- 工厂详情对话框 -->
      <el-dialog v-model="detailVisible" title="工厂详情" width="800px">
        <el-descriptions :column="2" border>
          <el-descriptions-item label="工厂代码">{{ currentFactory?.code }}</el-descriptions-item>
          <el-descriptions-item label="工厂名称">{{ currentFactory?.name }}</el-descriptions-item>
          <el-descriptions-item label="负责人">{{ currentFactory?.manager }}</el-descriptions-item>
          <el-descriptions-item label="联系电话">{{ currentFactory?.phone }}</el-descriptions-item>
          <el-descriptions-item label="工厂地址" :span="2">{{ currentFactory?.address }}</el-descriptions-item>
          <el-descriptions-item label="生产许可证">
            <el-image
              style="width: 200px"
              :src="currentFactory?.license"
              :preview-src-list="[currentFactory?.license]"
            />
          </el-descriptions-item>
          <el-descriptions-item label="状态">
            <el-tag :type="currentFactory?.status === 'active' ? 'success' : 'info'">
              {{ currentFactory?.status === 'active' ? '正常' : '停用' }}
            </el-tag>
          </el-descriptions-item>
        </el-descriptions>
      </el-dialog>
  
      <!-- 库存查询对话框 -->
      <el-dialog v-model="inventoryVisible" title="库存查询" width="1000px">
        <el-form :model="inventoryQuery" :inline="true" class="search-form">
          <el-form-item label="商品名称">
            <el-input v-model="inventoryQuery.name" placeholder="请输入商品名称" clearable />
          </el-form-item>
          <el-form-item label="商品编码">
            <el-input v-model="inventoryQuery.code" placeholder="请输入商品编码" clearable />
          </el-form-item>
          <el-form-item>
            <el-button type="primary" @click="handleInventoryQuery">查询</el-button>
            <el-button @click="resetInventoryQuery">重置</el-button>
          </el-form-item>
        </el-form>
  
        <el-table :data="inventoryList" border style="width: 100%">
          <el-table-column prop="code" label="商品编码" width="120" />
          <el-table-column prop="name" label="商品名称" />
          <el-table-column prop="spec" label="规格" />
          <el-table-column prop="unit" label="单位" width="80" />
          <el-table-column prop="quantity" label="库存数量" width="100" />
          <el-table-column prop="minStock" label="最低库存" width="100" />
          <el-table-column prop="maxStock" label="最高库存" width="100" />
          <el-table-column prop="status" label="状态" width="100">
            <template #default="{ row }">
              <el-tag :type="getInventoryStatusType(row)">
                {{ getInventoryStatusText(row) }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column label="操作" width="150">
            <template #default="{ row }">
              <el-button type="primary" link @click="handleAdjustStock(row)">调整库存</el-button>
              <el-button type="primary" link @click="handleStockLog(row)">库存日志</el-button>
            </template>
          </el-table-column>
        </el-table>
  
        <div class="pagination-wrapper">
          <el-pagination
            v-model:current-page="inventoryPage"
            v-model:page-size="inventoryPageSize"
            :page-sizes="[10, 20, 50, 100]"
            :total="inventoryTotal"
            layout="total, sizes, prev, pager, next, jumper"
            @size-change="handleInventorySizeChange"
            @current-change="handleInventoryCurrentChange"
          />
        </div>
      </el-dialog>
  
      <!-- 库存预警对话框 -->
      <el-dialog v-model="warningVisible" title="库存预警" width="1000px">
        <el-tabs v-model="warningActiveTab">
          <el-tab-pane label="库存不足" name="low">
            <el-table :data="lowStockList" border style="width: 100%">
              <el-table-column prop="code" label="商品编码" width="120" />
              <el-table-column prop="name" label="商品名称" />
              <el-table-column prop="spec" label="规格" />
              <el-table-column prop="unit" label="单位" width="80" />
              <el-table-column prop="quantity" label="当前库存" width="100" />
              <el-table-column prop="minStock" label="最低库存" width="100" />
              <el-table-column prop="shortage" label="缺口数量" width="100">
                <template #default="{ row }">
                  <span class="warning-text">{{ row.minStock - row.quantity }}</span>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="150">
                <template #default="{ row }">
                  <el-button type="primary" link @click="handleAdjustStock(row)">调整库存</el-button>
                  <el-button type="primary" link @click="handleStockLog(row)">库存日志</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-tab-pane>
          <el-tab-pane label="库存积压" name="high">
            <el-table :data="highStockList" border style="width: 100%">
              <el-table-column prop="code" label="商品编码" width="120" />
              <el-table-column prop="name" label="商品名称" />
              <el-table-column prop="spec" label="规格" />
              <el-table-column prop="unit" label="单位" width="80" />
              <el-table-column prop="quantity" label="当前库存" width="100" />
              <el-table-column prop="maxStock" label="最高库存" width="100" />
              <el-table-column prop="excess" label="超出数量" width="100">
                <template #default="{ row }">
                  <span class="warning-text">{{ row.quantity - row.maxStock }}</span>
                </template>
              </el-table-column>
              <el-table-column label="操作" width="150">
                <template #default="{ row }">
                  <el-button type="primary" link @click="handleAdjustStock(row)">调整库存</el-button>
                  <el-button type="primary" link @click="handleStockLog(row)">库存日志</el-button>
                </template>
              </el-table-column>
            </el-table>
          </el-tab-pane>
        </el-tabs>
      </el-dialog>
  
      <!-- 调整库存对话框 -->
      <el-dialog v-model="adjustStockVisible" title="调整库存" width="500px">
        <el-form :model="adjustStockForm" label-width="100px">
          <el-form-item label="商品名称">
            <span>{{ currentProduct?.name }}</span>
          </el-form-item>
          <el-form-item label="当前库存">
            <span>{{ currentProduct?.quantity }}</span>
          </el-form-item>
          <el-form-item label="调整数量" required>
            <el-input-number v-model="adjustStockForm.quantity" :min="-currentProduct?.quantity" />
          </el-form-item>
          <el-form-item label="调整原因" required>
            <el-input v-model="adjustStockForm.reason" type="textarea" placeholder="请输入调整原因" />
          </el-form-item>
        </el-form>
        <template #footer>
          <div class="dialog-footer">
            <el-button @click="adjustStockVisible = false">取 消</el-button>
            <el-button type="primary" @click="handleAdjustStockSave">确 定</el-button>
          </div>
        </template>
      </el-dialog>
  
      <!-- 库存日志对话框 -->
      <el-dialog v-model="stockLogVisible" title="库存日志" width="800px">
        <el-table :data="stockLogList" border style="width: 100%">
          <el-table-column prop="time" label="操作时间" width="180" />
          <el-table-column prop="type" label="操作类型" width="100">
            <template #default="{ row }">
              <el-tag :type="row.type === 'in' ? 'success' : 'danger'">
                {{ row.type === 'in' ? '入库' : '出库' }}
              </el-tag>
            </template>
          </el-table-column>
          <el-table-column prop="quantity" label="数量" width="100" />
          <el-table-column prop="before" label="调整前" width="100" />
          <el-table-column prop="after" label="调整后" width="100" />
          <el-table-column prop="operator" label="操作人" width="120" />
          <el-table-column prop="reason" label="原因" show-overflow-tooltip />
        </el-table>
      </el-dialog>
    </div>
  </template>
  
  <script setup lang="ts">
  import { ref, reactive,onMounted } from 'vue'
  import { ElMessage } from 'element-plus'
  
  // 导入工厂列表API接口
  import { reqGetFactoryList } from '@/api/organization/factory'
  
  // 查询表单（保持原有逻辑）
  const queryForm = reactive({ name: '', code: '', status: '' })
  
  // 工厂列表（移除测试数据，改为通过接口获取）
  const factoryList = ref<any[]>([])
  // 分页数据（初始化为0）
  const currentPage = ref(1)
  const pageSize = ref(10)
  const total = ref(0)
  // 初始化加载数据（保持原有）
onMounted(() => {
    handleQuery()
})
  // 查询工厂（核心修改：调用API接口）
  const handleQuery = async () => {
    try {
      // 调用工厂列表接口（假设接口支持分页和查询参数，参数需与后端一致）
      const res = await reqGetFactoryList({
        page: currentPage.value,
        pageSize: pageSize.value,
        ...queryForm // 传递查询条件（name/code/status）
      })
      // 绑定接口返回的真实数据
      factoryList.value = res.data // 假设接口返回格式：{ data: { list: 工厂数组, total: 总条数 } }
      console.log(`output->`,res)
      total.value = res.data.total
    } catch (err) {
      ElMessage.error('获取工厂列表失败，请检查网络或联系管理员')
    }
  }
  
  // 分页事件（保持原有逻辑，触发查询）
  const handleSizeChange = (newSize: number) => {
    pageSize.value = newSize
    handleQuery()
  }
  const handleCurrentChange = (newPage: number) => {
    currentPage.value = newPage
    handleQuery()
  }
  
  // ... 其他未修改代码（对话框、库存查询等逻辑保持不变）
  </script>
  
  <style lang="scss" scoped>
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
  
  .warning-text {
    color: #f56c6c;
    font-weight: bold;
  }
  </style>