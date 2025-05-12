//进行axios二次封装：使用请求与响应拦截器
import axios from 'axios'
//引入消息提示组件
import { ElMessage } from 'element-plus'
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
    return response.data
}, (error) => {
    //存储网络错误信息
    let message = '';
    let status = error.response.status;
    //根据不同的状态码，设置不同的错误信息
    switch (status) {
        case 400:
            message = '请求错误(400)';
            break;
        case 401:
            message = '未授权，请登录(401)';
            break;
        case 403:
            message = '拒绝访问(403)';
            break;
        case 404:
            message = '地址请求出错(404)';
            break;
        case 500:
            message = '服务器错误(500)';
            break;
        default:
            message = '网络出现错误';
            break;
    }
    //使用element-plus的消息提示组件，提示错误信息
    ElMessage({        
        type: 'error',
        message
    });
    return Promise.reject(error)
})
export default service

