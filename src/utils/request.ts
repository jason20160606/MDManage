//进行axios二次封装：使用请求与响应拦截器
import axios from 'axios'
import type { AxiosResponse } from 'axios'
//引入消息提示组件
import { ElMessage } from 'element-plus'
//引入用户相关的仓库
import useUserStore from '@/store/modules/user'

// 定义接口响应类型
export interface ApiResponse {
    code: string;
    message: string;
    token?: string;
    data?: any;
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
        config.headers['Authorization'] = token;
    }
    return config
}, (error) => {
    //请求错误时的处理
    console.error('请求错误:', error)
    return Promise.reject(error)
})

//第三步：响应拦截器
request.interceptors.response.use(
    (response: AxiosResponse) => {
        //获取响应数据        
        // 如果返回的状态码不是200，说明接口请求有误
        
        return response
    },
    (error) => {
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

        return Promise.reject(error)
    }
)

export default request

