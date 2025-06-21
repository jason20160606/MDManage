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
        row-key="Id"
      >
        <el-table-column prop="OrderNo" label="订单编号" min-width="180" />
        <el-table-column prop="LogisticsCompany" label="物流公司" width="120">
          <template #default="{ row }">
            {{ getLogisticsCompanyName(row.LogisticsCompany) }}
          </template>
        </el-table-column>
        <el-table-column prop="TrackingNo" label="物流单号" min-width="180" />
        <el-table-column prop="receiverName" label="收货人" width="120" />
        <el-table-column prop="phone" label="联系电话" width="120" />
        <el-table-column prop="address" label="收货地址" min-width="200" show-overflow-tooltip />
        <el-table-column prop="OrderDate" label="发货时间" width="160" />
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
import { ref, reactive, onMounted } from 'vue'
import { ElMessage } from 'element-plus'
import { reqOrderlist } from '@/api/order' // 导入 API 接口

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
const tableData = ref<any[]>([])
const total = ref(0)

// 物流跟踪对话框
const trackDialogVisible = ref(false)
const logisticsTrack = ref([ // 模拟数据，待接入物流接口后替换
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
    '1': 'primary', // 已发货/运输中
    '0': 'info', // 待处理
    '2': 'success', // 已完成/已签收
    '3': 'danger'   // 已取消/异常
  }
  return map[status] || 'info'
}

// 获取物流状态文本
const getLogisticsStatusText = (status: string) => {
  const map: Record<string, string> = {
    '1': '运输中',
    '0': '待处理',
    '2': '已签收',
    '3': '已取消/异常'
  }
  return map[status] || status
}

// 获取订单列表数据
const getOrderList = async () => {
  loading.value = true
  try {
    const res = await reqOrderlist({})
    console.log('API返回数据:', res) // 添加日志
    if (res.status === 200 && Array.isArray(res.data)) {
      let filteredData = res.data;

      // 过滤出已发货订单 (假设status === '1')
      // filteredData = filteredData.filter((order: any) => order.status === '1');

      // // 根据查询参数过滤数据
      // if (queryParams.orderNo) {
      //   filteredData = filteredData.filter((order: any) => 
      //     order.OrderNo.toLowerCase().includes(queryParams.orderNo.toLowerCase())
      //   );
      // }
      // if (queryParams.trackingNo) {
      //   filteredData = filteredData.filter((order: any) => 
      //     order.TrackingNo && order.TrackingNo.toLowerCase().includes(queryParams.trackingNo.toLowerCase())
      //   );
      // }
      // if (queryParams.logisticsCompany) {
      //   filteredData = filteredData.filter((order: any) => order.LogisticsCompany === queryParams.logisticsCompany);
      // }
      // 暂时不处理发货时间过滤，因为API可能没有直接的shipTime字段
      
      // 分页处理
      const startIndex = (queryParams.pageNum - 1) * queryParams.pageSize;
      const endIndex = startIndex + queryParams.pageSize;
      tableData.value = filteredData.slice(startIndex, endIndex);
      total.value = filteredData.length; // 更新总数
      ElMessage.success('获取已发货订单列表成功');
    } else {
      tableData.value = [];
      total.value = 0;
      ElMessage.error(res.message || '获取订单列表失败');
    }
  } catch (error) {
    console.error('获取订单列表出错：', error);
    tableData.value = [];
    total.value = 0;
    ElMessage.error('获取订单列表失败');
  } finally {
    loading.value = false;
  }
}

// 查询列表
const handleQuery = () => {
  queryParams.pageNum = 1; // 查询时重置页码到第一页
  getOrderList();
}

// 重置查询
const resetQuery = () => {
  queryParams.orderNo = '';
  queryParams.trackingNo = '';
  queryParams.logisticsCompany = '';
  queryParams.shipTime = [];
  queryParams.pageNum = 1; // 重置时也重置页码
  getOrderList();
}

// 物流跟踪
const handleTrack = (row: any) => {
  // TODO: 调用物流跟踪接口，此处模拟数据需要替换
  trackDialogVisible.value = true
  ElMessage.info(`物流跟踪订单：${row.OrderNo}`);
}

// 查看详情
const handleDetail = (row: any) => {
  // TODO: 跳转到详情页，或者在当前页显示详情（如果需求是类似折叠效果）
  ElMessage.info(`查看订单详情：${row.OrderNo}`);
}

// 打印
const handlePrint = (row: any) => {
  // TODO: 调用打印功能
  ElMessage.info(`打印订单：${row.OrderNo}`);
}

// 导出
const handleExport = () => {
  // TODO: 调用导出功能
  ElMessage.success('导出成功')
}

// 分页
const handleSizeChange = (val: number) => {
  queryParams.pageSize = val
  getOrderList()
}

const handleCurrentChange = (val: number) => {
  queryParams.pageNum = val
  getOrderList()
}

// 初始化
onMounted(() => {
  getOrderList()
})
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
