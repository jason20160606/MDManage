<template>
  <div class="app-container">
    <!-- 搜索区域 -->
    <el-card class="search-wrapper">
      <el-form :model="queryParams" ref="queryForm" :inline="true">
        <el-form-item label="订单编号">
          <el-input v-model="queryParams.orderNo" placeholder="请输入订单编号" clearable />
        </el-form-item>
        <el-form-item label="物流单号">
          <el-input v-model="queryParams.trackingNo" placeholder="请输入物流单号" clearable />
        </el-form-item>
        <el-form-item label="物流公司">
          <el-select v-model="queryParams.logisticsCompany" placeholder="请选择物流公司" clearable>
            <el-option label="顺丰速运" value="SF" />
            <el-option label="中通快递" value="ZTO" />
            <el-option label="圆通速递" value="YTO" />
            <el-option label="韵达快递" value="YD" />
          </el-select>
        </el-form-item>
        <el-form-item label="发货时间">
          <el-date-picker
            v-model="queryParams.shipTime"
            type="daterange"
            range-separator="至"
            start-placeholder="开始日期"
            end-placeholder="结束日期"
            value-format="YYYY-MM-DD"
          />
        </el-form-item>
        <el-form-item>
          <el-button type="primary" @click="handleQuery">查询</el-button>
          <el-button @click="resetQuery">重置</el-button>
        </el-form-item>
      </el-form>
    </el-card>

    <!-- 操作按钮区域 -->
    <el-card class="table-wrapper">
      <template #header>
        <div class="card-header">
          <span>已发货列表</span>
          <div class="right">
            <el-button type="success" @click="handleExport">导出</el-button>
          </div>
        </div>
      </template>

      <!-- 表格区域 -->
      <el-table
        v-loading="loading"
        :data="tableData"
        border
      >
        <el-table-column prop="orderNo" label="订单编号" min-width="180" />
        <el-table-column prop="logisticsCompany" label="物流公司" width="120">
          <template #default="{ row }">
            {{ getLogisticsCompanyName(row.logisticsCompany) }}
          </template>
        </el-table-column>
        <el-table-column prop="trackingNo" label="物流单号" min-width="180" />
        <el-table-column prop="receiver" label="收货人" width="120" />
        <el-table-column prop="phone" label="联系电话" width="120" />
        <el-table-column prop="address" label="收货地址" min-width="200" show-overflow-tooltip />
        <el-table-column prop="shipTime" label="发货时间" width="160" />
        <el-table-column prop="status" label="物流状态" width="120">
          <template #default="{ row }">
            <el-tag :type="getLogisticsStatusType(row.status)">
              {{ getLogisticsStatusText(row.status) }}
            </el-tag>
          </template>
        </el-table-column>
        <el-table-column label="操作" width="200" fixed="right">
          <template #default="{ row }">
            <el-button type="primary" link @click="handleTrack(row)">物流跟踪</el-button>
            <el-button type="primary" link @click="handleDetail(row)">详情</el-button>
            <el-button type="primary" link @click="handlePrint(row)">打印</el-button>
          </template>
        </el-table-column>
      </el-table>

      <!-- 分页 -->
      <el-pagination
        v-model:current-page="queryParams.pageNum"
        v-model:page-size="queryParams.pageSize"
        :page-sizes="[10, 20, 50, 100]"
        :total="total"
        layout="total, sizes, prev, pager, next, jumper"
        @size-change="handleSizeChange"
        @current-change="handleCurrentChange"
      />
    </el-card>

    <!-- 物流跟踪对话框 -->
    <el-dialog
      v-model="trackDialogVisible"
      title="物流跟踪"
      width="800px"
      destroy-on-close
    >
      <el-timeline>
        <el-timeline-item
          v-for="(activity, index) in logisticsTrack"
          :key="index"
          :timestamp="activity.time"
          :type="index === 0 ? 'primary' : ''"
        >
          {{ activity.content }}
        </el-timeline-item>
      </el-timeline>
    </el-dialog>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from 'vue'
import { ElMessage } from 'element-plus'

// 查询参数
const queryParams = reactive({
  pageNum: 1,
  pageSize: 10,
  orderNo: '',
  trackingNo: '',
  logisticsCompany: '',
  shipTime: []
})

// 表格数据
const loading = ref(false)
const tableData = ref([])
const total = ref(0)

// 物流跟踪对话框
const trackDialogVisible = ref(false)
const logisticsTrack = ref([
  {
    time: '2024-01-20 10:00:00',
    content: '快件已签收，签收人：张先生'
  },
  {
    time: '2024-01-20 09:30:00',
    content: '快件已到达【北京朝阳区望京营业点】'
  },
  {
    time: '2024-01-19 20:00:00',
    content: '快件已从【北京转运中心】发出'
  },
  {
    time: '2024-01-19 18:00:00',
    content: '快件已到达【北京转运中心】'
  }
])

// 获取物流公司名称
const getLogisticsCompanyName = (code: string) => {
  const map: Record<string, string> = {
    'SF': '顺丰速运',
    'ZTO': '中通快递',
    'YTO': '圆通速递',
    'YD': '韵达快递'
  }
  return map[code] || code
}

// 获取物流状态类型
const getLogisticsStatusType = (status: string) => {
  const map: Record<string, string> = {
    'signed': 'success',
    'delivering': 'primary',
    'exception': 'danger'
  }
  return map[status] || 'info'
}

// 获取物流状态文本
const getLogisticsStatusText = (status: string) => {
  const map: Record<string, string> = {
    'signed': '已签收',
    'delivering': '运输中',
    'exception': '异常'
  }
  return map[status] || status
}

// 查询列表
const handleQuery = () => {
  loading.value = true
  // TODO: 调用接口获取数据
  setTimeout(() => {
    loading.value = false
  }, 1000)
}

// 重置查询
const resetQuery = () => {
  queryParams.orderNo = ''
  queryParams.trackingNo = ''
  queryParams.logisticsCompany = ''
  queryParams.shipTime = []
  handleQuery()
}

// 物流跟踪
const handleTrack = (row: any) => {
  trackDialogVisible.value = true
  // TODO: 调用物流跟踪接口
}

// 查看详情
const handleDetail = (row: any) => {
  // TODO: 跳转到详情页
}

// 打印
const handlePrint = (row: any) => {
  // TODO: 调用打印功能
}

// 导出
const handleExport = () => {
  // TODO: 调用导出功能
}

// 分页
const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  handleQuery()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  handleQuery()
}

// 初始化
handleQuery()
</script>

<style lang="scss" scoped>
.search-wrapper {
  margin-bottom: 20px;
}

.table-wrapper {
  .card-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
}

:deep(.el-timeline-item__content) {
  color: #666;
}
</style>
