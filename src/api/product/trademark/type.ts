//品牌类型
export interface ResponseData{
    code:number,
    message:string    
}
//已有品牌的ts类型
export interface Trademark{
    id?:number | null,
    name:string,
    logo:string
}
//包含全部品牌的数据类型
export type Records = Trademark[];

//获取平品牌类型
export interface TrademarkResponseData extends ResponseData{
    data:{
        dataList:Records,
        recordCount: number,
        pageIndex: number,
        pageSize: number
    }    
}