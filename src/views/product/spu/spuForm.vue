<template>
    <el-form label-width="100">
        <el-form-item label="SPU名称">
            <el-input placeholder="请输出SPU名称" v-model="SPUParams.spuname"></el-input>
        </el-form-item>
        <el-form-item label="SPU品牌">
            <el-select v-model="SPUParams.Id" placeholder="请选择品牌" style="width: 120px;">
                <el-option v-for="(item, index) in BRAND" :key="item.id" :label="item.tmName"
                    :value="item.id"></el-option>
            </el-select>
        </el-form-item>
        <el-form-item label="SPU描述">
            <el-input v-model="SPUParams.discription" placeholder="请输入描述" type="textarea"></el-input>
        </el-form-item>
        <el-form-item label="SPU图片">
            <el-upload v-model:file-list="IMG" action="https://run.mocky.io/v3/9d059bf9-4660-45f2-925d-ce80ad6c4d15"
                list-type="picture-card" :on-preview="handlePictureCardPreview" :on-remove="handleRemove">
                <el-icon>
                    <Plus />
                </el-icon>
            </el-upload>
            <el-dialog v-model="dialogVisibe">
                <img :src="dialogImageUrl" w-full alt="Preview Image" />
            </el-dialog>
        </el-form-item>
        <el-form-item label="SPU销售属性">
            <el-select v-model="unSelectSaleAttrIdAndValueName" style="width: 120px;" :placeholder="unSelectSaleAttr.length?`还未选择${unSelectSaleAttr.length}个`:`无`">
                <el-option :value="`${item.id}:${item.tmName}`" v-for="(item, index) in unSelectSaleAttr" :key="item.id" :label="item.tmName"></el-option>
            </el-select>
            <el-button :disabled = "unSelectSaleAttrIdAndValueName?false:true" @click="addSaleAttr" style="margin-left: 10px;" type="primary" size="default" icon="Plus">添加属性</el-button>
            <el-table border style="margin: 10px 0px;" :data="SALEATTR">
                <el-table-column label="ID" type="index" width="80"></el-table-column>
                <el-table-column label="销售属性名字" prop="tmName" width="120"></el-table-column>
                <el-table-column label="销售属性值">
                    <template #="{ row, $index }">
                        <el-tag style="margin: 0px 5px;" v-for="(itam, index) in row.attrName" :key="row.id" closable>
                            {{ itam.name }}
                        </el-tag>
                        <el-input @blue="toclook(row)" v-model="row.attrName" v-if="row.flag==true" placegolder="请输入属性值" size="small" style="width: 100px;"></el-input>
                        <el-button v-else @click="addattr(row)" type="primary" size="small" icon="Plus"></el-button>
                    </template>
                </el-table-column>
                <el-table-column label="操作" width="80">
                    <template #="{ row, $index }">
                        <el-button type="primary" icon="Delete" @click="SALEATTR.splice($index, 1)"></el-button>
                    </template>

                </el-table-column>
            </el-table>
        </el-form-item>
        <el-form-item>
            <el-button @click="save" type="primary" size="default">保存</el-button>
            <el-button type="primary" size="default" @click="cnecel">取消</el-button>
        </el-form-item>
    </el-form>
</template>

<script setup lang='ts'>
let $emit = defineEmits(['change-scene']);
import { reqSPU_BRAND, reqSPU_IMG, reqSPU_SALEATTR, reqSPU_AllSALEATTR } from '@/api/product/spu';
import { ElMessage } from 'element-plus';
import { ref, computed } from 'vue';
//点击取消按钮通知父组件切换场景
const cnecel = () => {
    $emit('change-scene', 0);
}
//存储已有SPU数据
let BRAND = ref<any>([]);
//存储全部图片树
let IMG = ref<any>([]);
//存储SPU销售属性
let SALEATTR = ref<any>([]);
//存储全部SPU销售属性值
let ALLSALEATTR = ref<any>([]);
//存储已有SPU数据
let SPUParams = ref<any>({
    category3Id: '',
    spuname: '',
    description: '',
    spuImageList: [],
    spuSaleAttrList: [],
    tmId: ''
});
//控制图片放大
let dialogVisibe = ref<boolean>(false);
//存储方法图片地址
let dialogImageUrl = ref<string>('');
//子组件方法
const initSpuData = async (row: any) => {
    //SPU：父组件传递过来的数据
    SPUParams.value = row;
    //获取全部品牌数据
    let res1 = await reqSPU_BRAND();
    //获取全部图片数据
    let res2 = await reqSPU_IMG(row.id);
    //获取全部销售属性数据
    let res3 = await reqSPU_SALEATTR(row.id);
    //获取全部销售属性值数据
    let res4 = await reqSPU_AllSALEATTR();
    BRAND.value = res1.data;
    IMG.value = res2.data.map(item => {
        return { name: item.id, url: item.imgUrl }
    });
    SALEATTR.value = res3.data;
    ALLSALEATTR.value = res4.data;
}
//图片预览
const handlePictureCardPreview = (file: any) => {
    dialogImageUrl.value = file.url;
    dialogVisibe.value = true;
}
//删除图片
const handleRemove = (file: any, fileList: any) => {
    IMG.value = fileList;
}
//计算未选择的销售属性
let unSelectSaleAttr = computed(() => {
    //全部销售属性有三个
    //已选择的销售属性有两个
    let unSelectAttr = ALLSALEATTR.value.filter(item => {
        return SALEATTR.value.every(item1 => {
            return item.tmName != item1.tmName;
        });
    })
    return unSelectAttr;
})
//收集还未选择的销售属性ID及名字
let unSelectSaleAttrIdAndValueName = ref<string>('')
//添加销售属性
const addSaleAttr = () => {
    //获取ID和名字
    let [id, tmName] = unSelectSaleAttrIdAndValueName.value.split(':');
    let newSaleAttr = {
        tmName,
        id,
        attrName: []        
    }
    //追加到数组中
    SALEATTR.value.push(newSaleAttr);
    //重置
    unSelectSaleAttrIdAndValueName.value = '';
}
//添加销售属性值
const addattr = (row: any) => {
    //点击按钮后，显示输入框
    row.flag = true;
    row.attrName.push({ name: '' });
}
//失去焦点
const toclook = (row: any) => {
    //点击按钮后，显示输入框
    row.flag = false;
    //收集销售属性值
    const {Id, tmName} = row;
    let newSaleAttr = {
        tmName,
        id:Id,
        attrName: row.attrName
    }
    //非法判断
    if(SALEATTR.value.trim()==''){
        ElMessage({
            type: 'error',
            message: '请输入属性值'
        })
        return;
    }
    //判断属性值是否重复
    let res = SALEATTR.value.every(item => {
        return item.attrName.every(item1 => {
            return item1.name != newSaleAttr.attrName;
        });
    });

    //追加到新的属性值对象
    row.attrName.push(newSaleAttr);
    
}
//保存
const save = () => {
    //整理参数
    //1.照片墙
    //2.销售属性
    //发送请求
    //成功 通知父组件切换场景
    //失败
}

//添加一个新的SPU
const addSpu = () => {
    
}

//对外暴漏
defineExpose({
    initSpuData
})
</script>

<style></style>