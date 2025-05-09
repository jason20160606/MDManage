//进行axios二次封装：使用请求与响应拦截器
import axios from 'axios'
//第一步：利用axios.create方法创建一个axios实例对象
const service = axios.create({
    //设置请求的基础路径
    baseURL: import.meta.env.VITE_APP_BASE_API,
    //设置请求超时时间
    timeout: 5000,
    //设置请求头
    headers: {
        'Content-Type': 'application/json;charset=UTF-8'
    }
})
//第二步：请求拦截器
service.interceptors.request.use((config) => {
    //获取本地存储的token
    const token = localStorage.getItem('token')
    //如果token存在，则在请求头中添加Authorization字段
    if (token) {
        config.headers['Authorization'] = token
    }
    return config
}, (error) => {
    //请求错误时的处理
    console.error('请求错误:', error)
    return Promise.reject(error)
})
//第三步：响应拦截器
service.interceptors.response.use((response) => {
    //获取响应数据
    const res = response.data
    //如果响应状态码为200，则返回数据
    if (res.code === 200) {
        return res
    } else {
        //如果响应状态码不为200，则抛出错误
        return Promise.reject(new Error(res.message || 'Error'))
    }
}, (error) => {
    //响应错误时的处理
    console.error('响应错误:', error)
    return Promise.reject(error)
})  
export default service

