<template>
  <div class="app-container">
    <el-card>
      <template #header>
        <div class="card-header">
          <span>公司管理</span>
          <el-button type="primary" @click="handleAdd">新增公司</el-button>
        </div>
      </template>

      <!-- 搜索区域 -->
      <el-form :model="queryForm" ref="queryFormRef" :inline="true" class="search-form">
        <el-form-item label="公司名称">
          <el-input v-model="queryForm.name" placeholder="请输入公司名称" clearable />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>

      <!-- 公司列表 -->
      <el-table :data="companyList" border style="width: 100%">
        <el-table-column prop="Id" label="公司代码" width="120" />
        <el-table-column prop="Name" label="公司名称" />
        <el-table-column prop="Name" label="公司品牌" />        
        <el-table-column prop="status" label="状态" width="100">
          <template #default="{ row }">
            <el-tag :type="row.status === 'active' ? 'success' : 'info'">
              {{ row.status === 'active' ? '正常' : '停用' }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleEdit(row)">编辑</el-button>
            <el-button type="primary" link @click="handleView(row)">查看</el-button>
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

    <!-- 公司编辑对话框 -->
    <el-dialog
      v-model="dialogVisible"
      :title="dialogType === 'add' ? '新增公司' : '编辑公司'"
      width="600px"
    >
      <el-form :model="companyForm" label-width="100px">
        <el-form-item label="公司代码" required>
          <el-input v-model="companyForm.code" placeholder="请输入公司代码" />
        </el-form-item>
        <el-form-item label="公司名称" required>
          <el-input v-model="companyForm.name" placeholder="请输入公司名称" />
        </el-form-item>
        <el-form-item label="法人代表" required>
          <el-input v-model="companyForm.legalPerson" placeholder="请输入法人代表" />
        </el-form-item>
        <el-form-item label="联系人" required>
          <el-input v-model="companyForm.contact" placeholder="请输入联系人" />
        </el-form-item>
        <el-form-item label="联系电话" required>
          <el-input v-model="companyForm.phone" placeholder="请输入联系电话" />
        </el-form-item>
        <el-form-item label="公司地址" required>
          <el-input v-model="companyForm.address" type="textarea" placeholder="请输入公司地址" />
        </el-form-item>
        <el-form-item label="营业执照">
          <el-upload
            class="upload-demo"
            action="/api/upload"
            :on-success="handleUploadSuccess"
            :on-error="handleUploadError"
          >
            <el-button type="primary">上传营业执照</el-button>
          </el-upload>
        </el-form-item>
        <el-form-item label="状态">
          <el-switch
            v-model="companyForm.status"
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

    <!-- 公司详情对话框 -->
    <el-dialog v-model="detailVisible" title="公司详情" width="800px">
      <el-descriptions :column="2" border>
        <el-descriptions-item label="公司代码">{{ currentCompany?.code }}</el-descriptions-item>
        <el-descriptions-item label="公司名称">{{ currentCompany?.name }}</el-descriptions-item>
        <el-descriptions-item label="法人代表">{{ currentCompany?.legalPerson }}</el-descriptions-item>
        <el-descriptions-item label="联系人">{{ currentCompany?.contact }}</el-descriptions-item>
        <el-descriptions-item label="联系电话">{{ currentCompany?.phone }}</el-descriptions-item>
        <el-descriptions-item label="公司地址" :span="2">{{ currentCompany?.address }}</el-descriptions-item>
        <el-descriptions-item label="营业执照">
          <el-image
            style="width: 200px"
            :src="currentCompany?.license"
            :preview-src-list="[currentCompany?.license]"
          />
        </el-descriptions-item>
        <el-descriptions-item label="状态">
          <el-tag :type="currentCompany?.status === 'active' ? 'success' : 'info'">
            {{ currentCompany?.status === 'active' ? '正常' : '停用' }}
          </el-tag>
        </el-descriptions-item>
      </el-descriptions>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive, onMounted } from 'vue'
import { ElMessage, ElMessageBox } from 'element-plus'
import { reqGetBrandList } from '@/api/organization/company'

// 查询表单
const queryForm = reactive({ 
    name: '', // 公司名称
    code: '', // 公司代码
    status: '' // 状态（active/inactive）
})

// 公司列表（替换硬编码数据）
const companyList = ref<any[]>([])

// 分页（保持原有，但 total 需从接口获取）
const currentPage = ref(1)
const pageSize = ref(10)
const total = ref(0)

// 查询公司（修改后）
const handleQuery = async () => {
    try {        
        // 调用修正后的接口
        const res = await reqGetBrandList()
        // 假设接口返回格式：{ records: 公司数组, total: 总条数 }
        companyList.value = res.data
        // 从响应头中获取分页信息
    const pagination = JSON.parse(res.headers['x-pagination']);    
    currentPage.value = pagination.PageIndex;
    pageSize.value = pagination.pageSize;
    total.value = pagination.TotalCount;
    } catch (error) {
        ElMessage.error('获取公司列表失败，请重试')
        console.error('公司列表查询错误:', error)
    }
}

// 初始化加载数据（保持原有）
onMounted(() => {
    handleQuery()
})
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
</style>
