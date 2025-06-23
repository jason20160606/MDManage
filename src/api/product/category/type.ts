//产品分类类型定义
export interface ResponseData {
    code: number,
    message: string
}

//产品分类的ts类型
export interface Category {
    id?: number | null,
    name: string,
    parentId?: number | null,
    level: number, // 1: 一级分类, 2: 二级分类, 3: 三级分类    
    status?: number, // 0: 禁用, 1: 启用 (可选)
    icon?: string,
    description?: string,
    children?: Category[]
}

//包含全部分类的数据类型
export type Records = Category[];

//获取分类列表的查询参数
export interface CategoryQueryParams {
    name?: string;
    parentId?: number;
    level?: number;
    status?: number;
    pageNumber?: number;
    pageSize?: number;
}

//获取分类类型
export interface CategoryResponseData extends ResponseData {
    data: {
        dataList: Records,
        recordCount: number,
        pageIndex: number,
        pageSize: number
    }
}