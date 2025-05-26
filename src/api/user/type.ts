//定义用户相关数据的ts类型
//登录接口需要携带参数的ts类型
export interface loginFormData {
    username: string;
    password: string;
}
//定义全部接口返回数据类型
export interface responseData {
    code: number;
    message: string;
    ok: boolean;
}
//登录接口返回数据的ts类型
export interface loginResponseData extends responseData {
    data: string;
}
//获取用户信息接口返回数据的ts类型
export interface userInfoData extends responseData {
    data: {
        routeData:string[],
        buttons:string[],
        roles:string[],
        username:string,
        avatar:string
    }
}


