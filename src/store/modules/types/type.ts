//小仓库state类型
import type { RouteRecordRaw } from 'vue-router'
export interface UserState {
    //token
    token: string | null;
    menuRoutes: RouteRecordRaw[];
    username: string;
    name: string;
    avatar: string;
    buttons: string[];
}