/**
 * 分页配置工具
 * 统一整个项目的分页变量命名、方法命名和后台参数处理
 */

// 分页配置接口
export interface PaginationConfig {
  // 分页变量名
  currentPage: string;      // 当前页码变量名
  pageSize: string;         // 每页大小变量名
  total: string;           // 总数变量名
  background: string;      // 背景色变量名
  
  // 方法名
  handleCurrentChange: string;  // 页码改变方法名
  handleSizeChange: string;     // 页大小改变方法名
  
  // 后台参数名
  pageNumberParam: string;      // 页码参数名
  pageSizeParam: string;        // 页大小参数名
  
  // 后台响应字段名
  pageIndexField: string;       // 页码字段名
  pageSizeField: string;        // 页大小字段名
  totalCountField: string;      // 总数字段名
}

// 标准分页配置
export const STANDARD_PAGINATION_CONFIG: PaginationConfig = {
  // 变量名标准
  currentPage: 'currentPage',
  pageSize: 'pageSize', 
  total: 'total',
  background: 'background',
  
  // 方法名标准
  handleCurrentChange: 'handleCurrentChange',
  handleSizeChange: 'handleSizeChange',
  
  // 后台参数名标准
  pageNumberParam: 'PageNumber',
  pageSizeParam: 'PageSize',
  
  // 后台响应字段名标准
  pageIndexField: 'PageIndex',
  pageSizeField: 'PageSize', 
  totalCountField: 'TotalCount'
}

// 分页布局标准
export const PAGINATION_LAYOUT = 'total, sizes, prev, pager, next, jumper'

// 分页大小选项标准
export const PAGINATION_SIZES = [10, 20, 50, 100]

// 处理后台分页响应的工具函数
export function handlePaginationResponse(response: any, config: PaginationConfig = STANDARD_PAGINATION_CONFIG) {
  if (response.headers && response.headers['x-pagination']) {
    try {
      const pagination = JSON.parse(response.headers['x-pagination'])
      return {
        [config.pageIndexField]: pagination[config.pageIndexField] || 1,
        [config.pageSizeField]: pagination[config.pageSizeField] || 10,
        [config.totalCountField]: pagination[config.totalCountField] || 0
      }
    } catch (error) {
      console.error('解析分页响应失败:', error)
      return {
        [config.pageIndexField]: 1,
        [config.pageSizeField]: 10,
        [config.totalCountField]: 0
      }
    }
  }
  return null
}

// 构建分页请求参数的工具函数
export function buildPaginationParams(currentPage: number, pageSize: number, config: PaginationConfig = STANDARD_PAGINATION_CONFIG) {
  return {
    [config.pageNumberParam]: currentPage,
    [config.pageSizeParam]: pageSize
  }
}

// 分页组件模板标准
export const PAGINATION_TEMPLATE = `
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
`

// 分页变量声明标准
export const PAGINATION_VARIABLES = `
// 分页相关变量
const currentPage = ref(1) // 当前页码
const pageSize = ref(10) // 每页显示数量
const total = ref(0) // 总数量
const background = ref(true) // 分页器背景色
`

// 分页方法标准
export const PAGINATION_METHODS = `
// 页码改变处理
const handleCurrentChange = (page: number) => {
  currentPage.value = page
  getData() // 重新获取数据
}

// 页大小改变处理
const handleSizeChange = (size: number) => {
  pageSize.value = size
  currentPage.value = 1 // 重置到第一页
  getData() // 重新获取数据
}
` 