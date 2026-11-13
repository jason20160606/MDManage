//小仓库state类型
import type { CategoryObj } from '@/api/product/attr/type'
//定义仓库的类型
export interface CategoryState {
    c1Id: string | number;
    c1Arr: CategoryObj[];
    c2Id: string | number;
    c2Arr: CategoryObj[];
    c3Id: string | number;
    c3Arr: CategoryObj[];
}
