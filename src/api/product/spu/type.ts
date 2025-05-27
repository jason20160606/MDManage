//服务器全部接口返回的数据类型
export interface ResponseData {
    code: number;
    message: string;
    ok:boolean,
    data: T;
}