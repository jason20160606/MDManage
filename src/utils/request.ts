//进行axios二次封装：使用请求与响应拦截器
import axios from 'axios'
import type { AxiosResponse } from 'axios'
//引入消息提示组件
import { ElMessage } from 'element-plus'
//引入用户相关的仓库
import useUserStore from '@/store/modules/user'

/**
 * 后端统一响应结构（PascalCase，与 MVC 的 PropertyNamingPolicy=null 一致）
 * 所有接口——成功、业务失败、鉴权失败、异常——都是这个结构。
 */
export interface ApiResponse<T = any> {
    Code: number;
    Success: boolean;
    Message: string;
    Data?: T;
    TraceId?: string;
}

/** 提取错误原因（业务失败的信封 / 网络错误） */
export const getErrorMessage = (e: any, fallback = '操作失败'): string => {
    if (!e) return fallback
    if (typeof e === 'string') return e
    const msg = e.Message || e.message || e.response?.data?.Message
    return typeof msg === 'string' && msg.trim() ? msg : fallback
}

/**
 * 页面 catch 中统一调用：拦截器已经弹过真实原因时不重复弹。
 * 只在「静默接口」或网络层异常时补一条，避免一句固定文案盖掉真实原因。
 */
export const showError = (e: any, fallback = '操作失败'): string => {
    const msg = getErrorMessage(e, fallback)
    if (!(e && e.__notified)) {
        ElMessage.error(msg)
    }
    return msg
}

/** 取列表数据：统一信封下就是 Data.Items */
export const getList = (res: any): any[] => {
    if (!res) return []
    if (Array.isArray(res)) return res
    if (Array.isArray(res.Items)) return res.Items
    return []
}

/** 取分页总数 */
export const getTotal = (res: any, fallback = 0): number => {
    const n = Number(res?.TotalCount)
    return Number.isFinite(n) && n > 0 ? n : fallback
}

//第一步：利用axios.create方法创建一个axios实例对象
const request = axios.create({
    //设置请求的基础路径
    baseURL: import.meta.env.VITE_APP_BASE_API,
    //批量发货/批量审核这类批量操作单次可能几十秒，5 秒会让前端误判为失败
    timeout: 60000,
    //设置请求头
    headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
    }
})

//第二步：请求拦截器
request.interceptors.request.use((config) => {
    let userStore = useUserStore();
    let token = userStore.token;
    if (token) {
        config.headers['Authorization'] = 'Bearer ' + token;
    }
    return config
}, (error) => {
    console.error('请求错误:', error)
    return Promise.reject(error)
})

//第三步：响应拦截器
// 约定：成功一律 return Data（调用方拿到的就是业务数据）；
//      失败一律 reject 整个信封（调用方可读 Message / Data，例如审核缺口明细）。
request.interceptors.response.use(
    (response: AxiosResponse<ApiResponse>) => {
        // 文件下载/导出：保留 AxiosResponse，页面从 res.data 取 Blob
        const responseType = response.config?.responseType
        if (responseType === 'blob' || responseType === 'arraybuffer') {
            return response
        }

        const res = response.data
        if (res && typeof res === 'object' && 'Success' in res) {
            if (res.Success) {
                return res.Data
            }
            // 业务失败兜底（正常应由 HTTP 4xx 分支处理）
            if (!(response.config as any)?.silent) {
                ElMessage({ type: 'error', message: res.Message || '请求失败', duration: 5 * 1000 })
                ;(res as any).__notified = true
            }
            return Promise.reject(res)
        }
        // 非信封响应（理论上不存在）原样返回
        return res
    },
    async (error) => {
        const status = error.response?.status;
        const originalRequest = error.config;
        const payload = error.response?.data;

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
                    const body = res.data;
                    const accessToken = body?.Data?.AccessToken;
                    if (!accessToken) {
                        throw new Error('刷新Token失败');
                    }
                    localStorage.setItem('access_token', accessToken);
                    if (body?.Data?.RefreshToken) {
                        localStorage.setItem('refresh_token', body.Data.RefreshToken);
                    }
                    const userStore = useUserStore();
                    userStore.token = accessToken;
                    userStore.refreshToken = body?.Data?.RefreshToken || refreshToken;
                    originalRequest.headers['Authorization'] = 'Bearer ' + accessToken;
                    return request(originalRequest);
                } catch (e) {
                    console.warn('Token 续期失败，需要重新登录', e);
                }
            }
            localStorage.removeItem('access_token');
            localStorage.removeItem('refresh_token');
            ElMessage({ type: 'warning', message: '登录已过期，请重新登录', duration: 5000 });
            if (window.location.hash.indexOf('/login') === -1) {
                window.location.href = '/#/login';
            }
            return Promise.reject(payload || error);
        }

        // 后端错误信封优先：{ Code, Success:false, Message }
        const message = (typeof payload?.Message === 'string' && payload.Message.trim())
            ? payload.Message
            : status === 403
                ? '没有访问该功能所在页面的权限，请联系管理员分配页面权限'
                : status === 404
                    ? '请求的接口不存在'
                    : status === 500
                        ? '服务器内部错误，请稍后重试'
                        : `网络错误(${status || '未知'})`;

        const notified = !(originalRequest as any)?.silent;
        if (notified) {
            ElMessage({ type: 'error', message, duration: 5 * 1000 });
        }

        // 把信封原样抛给调用方：需要明细的页面（如审核缺口）可读 Data
        const rejected = payload && typeof payload === 'object'
            ? Object.assign(payload, { __notified: true })
            : Object.assign(new Error(message), { __notified: true, status });
        return Promise.reject(rejected);
    }
)

export default request
