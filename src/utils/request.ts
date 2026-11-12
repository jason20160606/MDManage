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
    //设置请求超时时间（批量发货/批量审核这类批量操作单次可能几十秒，5 秒会让前端误判为失败）
    timeout: 60000,
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
        // 统一处理后端 ApiResponse 结构：{ Success, Message, Data }
        const res = response.data;
        if (res && typeof res === 'object' && 'Success' in res) {
            if (res.Success) {
                // 只在真的有数据时才拆包。Data 为 null（发货、审核、删除这类只回结果的接口）时
                // 必须把整个信封返回，否则调用方拿到 null 再读 res.Success 会直接抛异常，
                // 表现就是“后端已经成功、前端弹发货失败”
                return typeof res.Data !== 'undefined' && res.Data !== null ? res.Data : res;
            }
            // 业务失败必须 reject，否则调用方会拿原始响应继续往下走
            // silent: 由调用方自己展示完整原因（例如批量发货要弹窗列出逐单失败明细）
            if (!(response.config as any)?.silent) {
                ElMessage({
                    type: 'error',
                    message: res.Message || '请求失败',
                    duration: 5 * 1000
                });
            }
            // 后端识别到登录态失效时统一回登录页，避免只看到一句业务报错
            if (/登录状态已失效|请先登录|未登录/.test(res.Message || '')) {
                localStorage.removeItem('access_token');
                localStorage.removeItem('refresh_token');
                if (window.location.hash.indexOf('/login') === -1) {
                    window.location.href = '/#/login';
                }
            }
            return Promise.reject(res);
        }
        // 数组等非 ApiResponse 结构原样返回
        return response;
    },
    async (error) => {
        const status = error.response?.status;
        const originalRequest = error.config;

        // 401：先用 refresh token 静默续期，成功后重放原请求，不打扰用户
        if (status === 401 && originalRequest && !originalRequest._retry) {
            originalRequest._retry = true;
            const refreshToken = localStorage.getItem('refresh_token');
            if (refreshToken) {
                try {
                    // 后端路由是 /User/refresh，且 RefreshToken 走 query 参数
                    const baseURL = import.meta.env.VITE_APP_BASE_API || '/api';
                    const res = await axios.post(
                        `${baseURL}/User/refresh?RefreshToken=${encodeURIComponent(refreshToken)}`
                    );
                    const payload = res.data?.Data;
                    if (!payload?.AccessToken) {
                        throw new Error('刷新Token失败');
                    }
                    localStorage.setItem('access_token', payload.AccessToken);
                    if (payload.RefreshToken) {
                        localStorage.setItem('refresh_token', payload.RefreshToken);
                    }
                    // 同步更新 pinia：只写 localStorage 的话，后续请求仍会用旧 token
                    const userStore = useUserStore();
                    userStore.token = payload.AccessToken;
                    userStore.refreshToken = payload.RefreshToken || refreshToken;
                    originalRequest.headers['Authorization'] = 'Bearer ' + payload.AccessToken;
                    return request(originalRequest);
                } catch (e) {
                    console.warn('Token 续期失败，需要重新登录', e);
                }
            }
            // 续期不可用或失败：清凭证并回登录页
            localStorage.removeItem('access_token');
            localStorage.removeItem('refresh_token');
            ElMessage({ type: 'warning', message: '登录已过期，请重新登录', duration: 5000 });
            if (window.location.hash.indexOf('/login') === -1) {
                window.location.href = '/#/login';
            }
            return Promise.reject(error);
        }

        //存储网络错误信息
        let message = '';

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

        return Promise.reject(error);
    }
)

export default request

