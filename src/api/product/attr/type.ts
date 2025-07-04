//分类相关数据的ts类型
export interface ResponseData {
    code: number,
    message: string,
    ok: boolean
}
//分类的ts类型
export interface CategoryObj {
    Id: number | string,
    Name: string,
    category1Id?: number,
    category2Id?: number
}
//包含全部分类的数组类型
export interface CategoryResponseData extends ResponseData  {
    data: CategoryObj[];
}
//包含属性的数组类型
export interface AttrValue {
    id?: number,
    valueName: string,
    attrId?: number,
    flag?: boolean
}
export type AttrValueList = AttrValue[];
//存储属性的ts类型
export interface Attr {
    id?: number,
    attrName: string,
    categoryId?: number | string,
    categoryLevel: number,
    attrValueList: AttrValueList  
}
export type AttrList = Attr[];
//存储全部属性的数组类型
export interface AttrResponseData extends ResponseData {
    data: Attr[];
}

