//进行axios二次封装：使用请求与响应拦截器
import axios from 'axios'
import type { AxiosResponse } from 'axios'
//引入消息提示组件
import { ElMessage } from 'element-plus'
//引入用户相关的仓库
import useUserStore from '@/store/modules/user'

// 定义接口响应类型
export interface ApiResponse {
    Success: string;
    Message: string;
    token?: string;
    Data?: any;
}

//第一步：利用axios.create方法创建一个axios实例对象
const request = axios.create({
    //设置请求的基础路径
    baseURL: import.meta.env.VITE_APP_BASE_API,
    //设置请求超时时间
    timeout: 5000,
    //设置请求头
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
})

//第二步：请求拦截器
request.interceptors.request.use((config) => {
    //获取用户仓库    
    let userStore = useUserStore();
    let token = userStore.token;
    //如果token存在，则在请求头中添加Authorization字段
    if (token) {
        config.headers['Authorization'] = 'Bearer ' + token;
    }
    return config
}, (error) => {
    //请求错误时的处理
    console.error('请求错误:', error)
    return Promise.reject(error)
})

//第三步：响应拦截器
request.interceptors.response.use(
    (response: AxiosResponse<ApiResponse>) => {
        // 统一处理后端ApiResponse格式
        const res = response.data;
        // 判断是否有code字段
        if (res && res.Success) {            
            if (res.Success) {
                // code为200，返回data字段（如有），否则返回整个res
                return typeof res.Data !== 'undefined' ? res.Data : res;
            } else {
                // code非200，弹出错误提示
                ElMessage({
                    type: 'error',
                    message: res.Message || '请求失败',
                    duration: 5 * 1000
                });
                return Promise.reject(res);
            }
        }
        // 没有code字段，直接返回原始response
        return response;
    },
    async (error) => {
        //存储网络错误信息
        let message = '';
        let status = error.response?.status;

        //根据不同的状态码，设置不同的错误信息
        switch (status) {
            case 400:
                message = '请求参数错误(400)';
                break;
            case 401:
                message = '未授权，请登录(401)';
                break;
            case 403:
                message = '拒绝访问(403)';
                break;
            case 404:
                message = '请求地址不存在(404)';
                break;
            case 405:
                message = '请求方法不允许(405)';
                break;
            case 500:
                message = '服务器错误(500)';
                break;
            default:
                message = `网络错误(${status})`;
                break;
        }

        //使用element-plus的消息提示组件，提示错误信息
        ElMessage({
            type: 'error',
            message,
            duration: 5 * 1000
        });

        // 打印详细的错误信息
        console.error('错误详情:', {
            status,
            headers: error.response?.headers,
            data: error.response?.data
        });

        const originalRequest = error.config;
        if (status === 401 && !originalRequest._retry) {
            originalRequest._retry = true;
            const refreshToken = localStorage.getItem('refresh_token');
            if (refreshToken) {
                try {
                    const res = await axios.post('/Auth/refresh', { refreshToken });
                    localStorage.setItem('access_token', res.data.access_token);
                    localStorage.setItem('refresh_token', res.data.refresh_token);
                    originalRequest.headers['Authorization'] = 'Bearer ' + res.data.access_token;
                    return request(originalRequest);
                } catch (e) {
                    localStorage.removeItem('access_token');
                    localStorage.removeItem('refresh_token');
                    window.location.href = '/login';
                }
            }
        }
        return Promise.reject(error);
    }
)

export default request

