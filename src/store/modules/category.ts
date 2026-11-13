//商品分类全局组件的小仓库
import { defineStore } from "pinia";
import { getList } from '@/utils/request'
import { reqC1, reqC2, reqC3 } from "@/api/product/attr";
import type { CategoryState } from "./types/type";
let categoryStore = defineStore("Category", {
    state: (): CategoryState => {
        return {
            //存储一级分类的数据
            c1Arr: [],
            //存储一级分类id
            c1Id: '',
            //存储二级分类的数据
            c2Arr: [],
            //存储二级分类id
            c2Id: '',
            //存储三级分类的数据
            c3Arr: [],
            //存储三级分类id
            c3Id: ''
        }
    },
    actions: {
        //获取一级分类接口方法
        async getC1Arr() {
            //调用接口
            const result: any = await reqC1();
            this.c1Arr = getList(result);
        },
        async getC2Arr() {
            const result: any = await reqC2(this.c1Id);
            this.c2Arr = getList(result);
        },
        async getC3Arr() {
            const result: any = await reqC3(this.c2Id);
            this.c3Arr = getList(result);
        }
    },
    getters: {

    }

})
export default categoryStore;