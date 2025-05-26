//小仓库state类型
import type { RouteRecordRaw } from 'vue-router'
import type { CategoryObj } from '@/api/product/attr/type'
export interface UserState {
    //token
    token: string | null;
    menuRoutes: RouteRecordRaw[];
    username: string;
    name: string;
    avatar: string;
    buttons: string[];
}
//定义仓库的类型
export interface CategoryState {
    c1Id: string | number;
    c1Arr: CategoryObj[];
    c2Id: string | number;
    c2Arr: CategoryObj[];
    c3Id: string | number;
    c3Arr: CategoryObj[];
}