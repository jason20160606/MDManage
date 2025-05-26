<template>
        <div>
                <!--三级全局组件-->
                <Category :scene="scene" />
                <el-card class="box-card" style="margin: 10px 0px;">
                        <div v-show="scene == 0">
                                <el-button type="primary" @click="addAttr" icon="Plus"
                                        :disabled="!categoryStore.c3Id">添加属性</el-button>
                                <el-table style="margin: 10px 0;" border :data="attrArr">
                                        <el-table-column prop="id" label="ID" type="index" width="80" align="center" />
                                        <el-table-column prop="attrName" label="属性名称" width="120" />
                                        <el-table-column label="属性值">
                                                <template #="{ row }">
                                                        <el-tag style="margin: 5px;" v-for="(item) in row.attrValueList"
                                                                :key="item.attrId">{{ item.valueName }}</el-tag>
                                                </template>
                                        </el-table-column>
                                        <el-table-column label="操作" width="120">
                                                <template>
                                                        <el-button type="primary" size="small" icon="Edit"
                                                                @cick="updateAttr"></el-button>
                                                        <el-button type="danger" size="small" icon="Delete"></el-button>

                                                </template>
                                        </el-table-column>
                                </el-table>
                        </div>
                        <div v-show="scene == 1">
                                <el-form inline>
                                        <el-form-item label="属性名称">
                                                <el-input placeholder="请你输入属性值"
                                                        v-model="attrParams.attrName"></el-input>
                                        </el-form-item>
                                </el-form>
                                <el-button @click="addAttrValue" :disabled="attrParams.attrName ? false : true"
                                        type="primary" icon="Plus">添加属性值</el-button>
                                <el-button type="primary" @click="cancel">取消</el-button>
                                <el-table style="margin: 10px 0;" border :data="attrParams.attrValueList">
                                        <el-table-column prop="id" label="ID" type="index" width="80" align="center" />
                                        <el-table-column label="属性名称" width="180">
                                                <template #="{ row, $index }">
                                                        <el-input :ref="(vc:any)=>inputArr[$index] = vc"  v-if="row.flag" @blur="tolook(row, $index)"
                                                                placeholder="请输入属性值名称"
                                                                v-model="row.valueName"></el-input>
                                                        <div v-else @click="toedit(row,$index)">{{ row.valueName }}</div>
                                                </template>
                                        </el-table-column>                                        
                                        <el-table-column label="操作">
                                                <template #="{ row, $index }">
                                                        <el-button type="primary" size="small" icon="Delete"
                                                                @click="attrParams.attrValueList.splice($index,1)"></el-button>                                                       
                                                </template>
                                        </el-table-column>
                                </el-table>
                                <el-button type="primary" @click="save"
                                        :disabled="attrParams.attrValueList.length > 0 ? false : true">保存</el-button>
                                <el-button type="primary" @click="cancel">取消</el-button>
                        </div>
                </el-card>
        </div>
</template>

<script setup lang='ts'>
//引入watch
import { watch, ref, reactive, nextTick } from 'vue';
//引入获取已有属性与属性值接口
import { reqAttr } from '@/api/product/attr';
import useCategoryStore from '@/store/modules/category';
import type { AttrResponseData, Attr, AttrValue } from '@/api/product/attr/type';
import { reqSaveOrUpdateAttr } from '@/api/product/attr';
import { ElMessage } from 'element-plus';
//获取三级分类的仓库
let categoryStore = useCategoryStore();
//存储数据
let attrArr = ref<Attr[]>([]);
//定义care展示内容
let scene = ref<number>(0);

//收集新增属性的数据
let attrParams = reactive<Attr>({
        attrName: '',
        categoryId: 0,
        categoryLevel: 3,
        attrValueList: []
});
//收集input框 存储input元素
let inputArr = ref<any>([]);
//监听仓库三级分类变化
watch(() => categoryStore.c3Id, () => {
        attrArr.value = [];
        if (!categoryStore.c3Id) {
                return;
        }
        //获取数据
        getAttr();
})
//获取数据
const getAttr = async () => {
        const { c1Id, c2Id, c3Id } = categoryStore;
        let result: AttrResponseData = await reqAttr(c1Id, c2Id, c3Id);
        if (result.code == 200) {
                attrArr.value = result.data;
        }
        //console.log(`output->`, attrArr)
}
//添加属性
const addAttr = () => {
        //每次点击先清空
        Object.assign(attrParams, {
                attrName: '',
                categoryId: categoryStore.c3Id!,
                categoryLevel: 3,
                attrValueList: []
        })
        scene.value = 1;
}
//修改属性
const updateAttr = () => {
        scene.value = 1;
        //收集三类id
        attrParams.categoryId = categoryStore.c3Id!;
}
//取消
const cancel = () => {
        scene.value = 0;
}
//添加属性值
const addAttrValue = () => {
        attrParams.attrValueList.push({
                valueName: '',
                flag: true       //控制是否可以编辑
        })
        //获取组件聚焦
        nextTick(() => {
                inputArr.value[attrParams.attrValueList.length - 1].focus();
        })
}
//保存
const save = async () => {
        //发送请求
        let result: AttrResponseData = await reqSaveOrUpdateAttr(attrParams);
        if (result.code == 200) {
                //切换场景
                scene.value = 0;
                //提示信息
                ElMessage({
                        message: attrParams.id ? '保存成功' : '添加成功',
                        type: 'success'
                });
                //重新获取数据
                getAttr();


        } else {
                ElMessage({
                        message: attrParams.id ? '保存失败' : '添加失败',
                        type: 'success'
                })
        }
        console.log(`output->`, attrParams)
}
//属性值失去焦点
const tolook = (row: AttrValue, $index: number) => {
        if (row.valueName.trim() == '') {
                //删除元素
                attrParams.attrValueList.splice($index, 1);
                ElMessage({
                        message: '属性值名称不能为空',
                        type: 'error'
                })
                return;
        }
        let repeat = attrParams.attrValueList.find((item) => {
                if (item != row) {
                        return item.valueName === row.valueName;
                }
        })
        if (repeat) {
                attrParams.attrValueList.splice($index, 1);
                ElMessage({
                        message: '属性值名称不能重复',
                        type: 'error'
                })
                return;
        }
        console.log(`output->`, repeat)
        row.flag = false;
}

//编辑
const toedit = (row: AttrValue, $index: number) => {
        row.flag = true;
        //响应式数据发生变化 获取更新后的DOM元素 
        nextTick(() => {
                inputArr.value[$index].focus();

        })
}

</script>

<style></style>