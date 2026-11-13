//进行axios二次封装：使用请求与响应拦截器
import axios from 'axios'
import type { AxiosResponse } from 'axios'
//引入消息提示组件
import { ElMessage } from 'element-plus'
//引入用户相关的仓库
import useUserStore from '@/store/modules/user'

// 定义接口响应类型
export interface ApiResponse {
    Success: boolean;
    Message: string;
    token?: string;
    Data?: any;
}

/**
 * 统一错误原因提取。
 * 后端写操作的业务失败会被拦截器 reject 成 ApiResponse（带 Message），
 * axios 的 HTTP 错误则带 response.data.Message / message。
 */
export const getErrorMessage = (e: any, fallback = '操作失败'): string => {
    if (!e) return fallback
    if (typeof e === 'string') return e
    const msg = e.Message || e.message || e.response?.data?.Message || e.response?.data?.message
    return typeof msg === 'string' && msg.trim() ? msg : fallback
}

/**
 * 页面 catch 中统一调用：拦截器已经弹过真实原因时不重复弹，
 * 带 silent 的接口（由页面自行展示）则由这里补弹真实原因。
 */
export const showError = (e: any, fallback = '操作失败'): string => {
    const msg = getErrorMessage(e, fallback)
    if (!(e && (e.__notified || e.response?.data?.__notified))) {
        ElMessage.error(msg)
    }
    return msg
}

/** 判断返回是否为成功（兼容 ApiResponse 信封、已拆包 DTO、AxiosResponse） */
export const isSuccess = (res: any): boolean => {
    if (!res) return false
    if (typeof res.Success === 'boolean') return res.Success
    if (typeof res.status === 'number') return res.status >= 200 && res.status < 300
    return true // 已拆包的纯数据：拦截器只会让成功的响应走到这里
}

/** 取列表数据（兼容裸数组 / AxiosResponse / {records,data}） */
export const getList = (res: any): any[] => {
    const d = res?.data ?? res
    if (Array.isArray(d)) return d
    if (Array.isArray(d?.records)) return d.records
    if (Array.isArray(d?.Data)) return d.Data
    return []
}

/** 取分页总数（优先 X-Pagination 头） */
export const getTotal = (res: any, listLength = 0): number => {
    const raw = res?.headers?.['x-pagination']
    if (raw) {
        try {
            const meta = typeof raw === 'string' ? JSON.parse(raw) : raw
            if (meta?.TotalCount != null) return Number(meta.TotalCount)
        } catch { /* 头格式异常时退回列表长度 */ }
    }
    return listLength
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
                // 标记「已提示」，页面 catch 里用 showError 就不会再弹一条固定文案盖掉真实原因
                (res as any).__notified = true;
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
                // 后端页面级权限策略返回 403：说明角色没有该页面权限，刷新 token 也解决不了，
                // 这里只提示，不跳转，避免打断用户当前页面的操作。
                message = '没有访问该功能所在页面的权限，请联系管理员分配页面权限(403)';
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
        // 后端把业务失败塞在 HTTP 错误体里时，优先展示真实原因
        const backendMessage = error.response?.data?.Message || error.response?.data?.message;
        if (typeof backendMessage === 'string' && backendMessage.trim()) {
            message = backendMessage;
        }

        ElMessage({
            type: 'error',
            message,
            duration: 5 * 1000
        });
        (error as any).__notified = true;

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

