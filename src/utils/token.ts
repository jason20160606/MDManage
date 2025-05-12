//封装本地存储数据与读取方法
export const setToken = (token: string) => {
    //设置token到本地存储
    localStorage.setItem('token', token);
}
export const getToken = () => {
    //获取本地存储的token
    return localStorage.getItem('token');
}