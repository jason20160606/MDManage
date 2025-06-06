<template>
        <div>
                <Category :scene="scene"></Category>
                <el-card class="box-card" style="margin: 10px 0px;">
                        <div v-show="scene == 0">
                                <el-button type="primary" icon="Plus" @click="addSpu"
                                        :disabled="categoryStore.c3Id ? false : true">添加SPU</el-button>
                                <!--展示已有数据-->
                                <div class="table" style="margin: 10px 0px;">
                                        <el-table border style="width: 100%" :data="recordsattr">
                                                <el-table-column label="ID" type="index" width="80"></el-table-column>
                                                <el-table-column label="SPU名称" prop="spuname"
                                                        width="180"></el-table-column>
                                                <el-table-column label="SPU描述" prop="discription" show-overflow-tooltip
                                                        width="180"></el-table-column>
                                                <el-table-column label="操作">
                                                        <template #="{ row }">
                                                                <el-button type="primary" size="small" icon="Plus"
                                                                        title="新增" @click="addSKU(row)"></el-button>
                                                                <el-button type="success" size="small" icon="Edit"
                                                                        @click="update(row)" title="修改"></el-button>
                                                                <el-button type="info" size="small" icon="View"
                                                                        title="查看"></el-button>
                                                                <el-button type="danger" size="small" icon="Delete"
                                                                        title="删除"></el-button>
                                                        </template>
                                                </el-table-column>
                                        </el-table>

                                </div>
                                <!--分页器-->
                                <el-pagination v-model:current-page="currentPageNo" v-model:page-size="pageSizeNo"
                                        :page-sizes="[100, 200, 300, 400]" :size="size" :disabled="disabled"
                                        :background="background" layout="prev, pager, next, jumper,->, sizes,total"
                                        :total="total" @current-change="getSPU" />
                        </div>
                        <!--新增修改SPU-->
                        <spuForm ref="spu" v-show="scene == 1" @change-scene="changeScene"></spuForm>
                        <!--新增修改SKU-->
                        <skuForm ref="sku" v-show="scene == 2"></skuForm>
                </el-card>


        </div>
</template>

<script setup lang='ts'>
import useCategoryStore from '@/store/modules/category';
import { ref, watch } from 'vue';
import { reqSPU } from '@/api/product/spu';
import type { Records } from '@/api/product/spu/type';
import spuForm from './spuForm.vue';
import skuForm from './skuForm.vue';
//场景值
/* 0:数据展示
   1:SPU
   2:SKU
*/
let scene = ref<number>(0);
let currentPageNo = ref(1); //当前页码
let pageSizeNo = ref(100); //每页显示多少条数据
let size = ref('medium'); //分页器尺寸
let disabled = ref(false); //分页器是否禁用
let background = ref(true); //分页器是否有背景色
let total = ref(0); //总条数
//获取三级分类的仓库
let categoryStore = useCategoryStore();
//存储已有的SPU数据
let recordsattr = ref<Records>([]);
//获取子组件实例SpuForm和SkuForm
let spu = ref();
let sku = ref();

//监听三级分类的变化
watch(() => categoryStore.c3Id, () => {
        //获取数据
        if (!categoryStore.c3Id) {
                return;
        }
        getSPU();

});
//获取三级分类的全部SPU
const getSPU = async () => {
        let result: any = await reqSPU();
        if (result.code == 200) {
                recordsattr.value = result.data.records;
                total.value = result.data.total;
        }
        console.log(`output->`, result)
}
//新增SPU
const addSpu = () => {
        //切换场景
        scene.value = 2;
        //调用子组件的方法初始化添加SKU的表单
}
        
//子组件自定义事件 让子组件通知父组件切换场景
const changeScene = (num: number) => {
        //子组件点击取消 场景变0 展示数据
        scene.value = num;
}
//修改SPU
const update = (row:any) => {
        //发生请求获取数据
        
        //切换场景
        scene.value = 1;
}
//新增SKU
const addSKU = (row:any) => {
        //发生请求获取数据
        //切换场景
        scene.value = 2;
        sku.value.initSkuData();

}
</script>

<style></style>