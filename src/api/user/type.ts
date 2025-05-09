//登录接口需要携带的参数
export interface LoginParams {
  username: string;
  password: string;
}
interface UserInfo {
    id: number;
    username: string;
    email: string;
    phone: string;
    status: string;
    token: string;
}
//登录接口返回的数据
export interface LoginResponse {
    code: number;
    message: string;
    data: {
        token: string;
        userInfo: UserInfo;
    };
}