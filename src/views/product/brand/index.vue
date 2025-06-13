<template>
        <div>
                <!-- 卡片视图 -->
                <el-card class="box-card">
                        <!-- 添加品牌按钮 -->
                        <el-button type="primary" icon="Plus" @click="addTrademark">添加品牌</el-button>
                        <!-- 表格视图 -->
                        <el-table style="margin: 10px 0;" border :fit="true" :data="trademarkArr">
                                <el-table-column prop="Id" label="ID" type="index" width="80" align="center" />
                                <el-table-column prop="Name" label="品牌名称" />
                                <el-table-column label="品牌LOGO">
                                        <template #="{ row, $index }">
                                                <img :src="row.logo" alt="" style="width: 60px;height: 60px;">
                                        </template>
                                </el-table-column>
                                <el-table-column prop="address" label="操作" width="120">
                                        <template #="{ row, $index }">
                                                <el-button type="primary" size="small" icon="Edit"
                                                        @click="updateTrademark(row)"></el-button>

                                                <el-popconfirm icon="Delete" :title="`你确认删除${row.name}?`" width="250px"
                                                        @confirm="deleteTrademark(row.id)">
                                                        <template #reference>
                                                                <el-button type="primary" size="small"
                                                                        icon="Delete"></el-button>
                                                        </template>
                                                </el-popconfirm>
                                        </template>
                                </el-table-column>
                        </el-table>
                        <!-- 分页器v-model:current-page：设置分页器当前页码v-model:page-size：设置分页器每页显示条数
                :page-sizes：设置分页器每页显示条数 :layout：设置分页器布局:total：设置分页器总条数 @size-change：设置分页器每页显示条数
                @current-change：设置分页器当前页码-->
                        <el-pagination @current-change="getHasTrademark" @size-change="sizechange"
                                v-model:current-page="pageNo" v-model:page-size="pageSize" :page-sizes="pageSizes"
                                layout=" prev, pager, next, jumper,->,sizes,total" :total="total" />
                </el-card>
                <!--对话框组件：在添加修改中-->
                <el-dialog v-model="dialogFormVisible" :title="trademarkParams.id ? '修改品牌' : '添加品牌'">
                        <el-form style="width: 80%;" :model="trademarkParams" :rules="rules" ref="formRef">
                                <el-form-item label="品牌名称" label-width="100px" prop="name">
                                        <el-input placeholder="请输入品牌名称" v-model="trademarkParams.name"></el-input>
                                </el-form-item>
                                <el-form-item label="品牌Logo" label-width="100px" prop="logo">
                                        <el-upload class="avatar-uploader"
                                                action="https://run.mocky.io/v3/9d059bf9-4660-45f2-925d-ce80ad6c4d15"
                                                :show-file-list="false" :on-success="handleAvatarSuccess"
                                                :before-upload="beforeAvatarUpload">
                                                <img v-if="trademarkParams.logo" :src="trademarkParams.logo"
                                                        class="avatar" />
                                                <el-icon v-else class="avatar-uploader-icon">
                                                        <Plus />
                                                </el-icon>
                                        </el-upload>
                                </el-form-item>
                        </el-form>
                        <template #footer>
                                <el-button type="primary" size="default" @click="cancle">取消</el-button>
                                <el-button type="primary" size="default" @click="confirm">确定</el-button>
                        </template>
                </el-dialog>
        </div>
</template>

<script setup lang='ts'>
import { ref, onMounted, reactive, nextTick } from 'vue';
import { reqAddOrUpdateTrademark, reqHasTrademark, reqDeleteTrademark } from '@/api/product/brand';
import type { Records, TrademarkResponseData, Trademark } from '@/api/product/brand/type'
import { ElMessage, type UploadProps } from 'element-plus'
//当前页码
let pageNo = ref<number>(1);
//每页显示条数
let pageSize = ref<number>(3);
//存储已有数量的总数
let total = ref<number>(0);
//设置下拉菜单
let pageSizes = ref([3, 10, 20, 30, 40]);
//存储已有品牌的数据
let trademarkArr = ref<Records>([]);
//修改新增对话框的显示与隐藏
let dialogFormVisible = ref<boolean>(false);
//定义收集新增品牌数据
let trademarkParams = reactive<Trademark>({
        name: '',
        logo: ''
})
//获取表单
let formRef = ref<any>();
//获取已有品牌的接口封装为一个函数：在任何情况下向获取数据，调用次函数即可
const getHasTrademark = async (pager = 1) => {
        let result: any = await reqHasTrademark();
        if (result.status == 200) {
                total.value = result.data.recordCount;
                trademarkArr.value = result.data;
        }
}
//添加按钮事件
const addTrademark = () => {
        //对话框显示
        dialogFormVisible.value = true;
        //清空数据
        trademarkParams.name = '';
        trademarkParams.logo = '';
        trademarkParams.id = null;
        //图片上传成功清楚错误信息
        //formRef.value?.clearValidate('name');
        //formRef.value?.clearValidate('logo');
        nextTick(() => {
                formRef.value.clearValidate('name');
                formRef.value.clearValidate('logo');
        })

}
//修改按钮事件
const updateTrademark = (row: Trademark) => {
        //清空校验数据错误信息
        nextTick(() => {
                formRef.value.clearValidate('name');
                formRef.value.clearValidate('logo');
        })
        //对话框显示
        dialogFormVisible.value = true;
        Object.assign(trademarkParams, row);
}
//取消按钮
const cancle = () => {
        dialogFormVisible.value = false;
}
//确定按钮
const confirm = async () => {
        await formRef.value.validate();
        let result: any = await reqAddOrUpdateTrademark(trademarkParams);
        if (result.code == 200) {
                ElMessage.success(trademarkParams.id ? '添加成功' : '修改成功');
                getHasTrademark(trademarkParams.id ? pageNo.value : 1);
        } else {
                ElMessage.error(trademarkParams.id ? '添加失败' : '修改失败');
                return;
        }
        dialogFormVisible.value = false;
}
const sizechange = (() => {
        pageNo.value = 1;
        getHasTrademark();
})
//删除按钮
const deleteTrademark = async (id: number) => {
        let result: any = await reqDeleteTrademark(id);
        if (result.code == 200) {
                ElMessage.success('删除成功');
                getHasTrademark(trademarkArr.value.length > 1 ? pageNo.value : pageNo.value - 1);
        } else {
                ElMessage.error('删除失败');
                return;
        }
}
//组件挂载完毕的钩子
onMounted(() => {
        getHasTrademark();
})
//上传图片组件->上传图片之前触发的钩子函数
const beforeAvatarUpload: UploadProps['beforeUpload'] = (rawFile) => {
        if (rawFile.type == 'image/jpeg' || rawFile.type == 'image/png' || rawFile.type == 'image/jpg') {
                if (rawFile.size / 1024 / 1024 < 4) {
                        return true;
                } else {
                        ElMessage.error('文件最大为4M')
                        return false
                }
        } else {
                ElMessage({
                        type: 'error',
                        message: '文件格式必须为ipeg,jpg,png'
                })
                return false;
        }
}
//上传图片组件->上传图片成功触发的钩子函数
const handleAvatarSuccess: UploadProps['onSuccess'] = (response, uploadFile) => {
        //response:响应的数据,uploadFile:上传的文件
        trademarkParams.logo = response.data;
        //图片上传成功清楚错误信息
        formRef.value.clearValidate('logo');

}
//品牌自定义校验规则
const validatorName = (rule: any, value: string, callback: Function) => {
        if (!value) {
                return callback(new Error('请输入品牌名称'));
        } else {
                return callback();
        }
}
//品牌LOGO自定义校验规则
const validatorLogo = (rule: any, value: string, callback: Function) => {
        if (!value) {
                return callback(new Error('请上传品牌LOGO'));
        } else {
                return callback();
        }
}


//表单校验规则
const rules = {
        name: [{ required: true, message: '请输入品牌名称', trigger: 'blur', validator: validatorName }],
        logo: [{ required: true, message: '请上传品牌LOGO', trigger: 'blur', validator: validatorLogo }]
}
</script>

<style scoped>
.box-card {
        width: 100%;
}

.el-table {
        width: 100%;
}

.avatar-uploader .avatar {
        width: 178px;
        height: 178px;
        display: block;
}
</style>
<style>
.avatar-uploader .el-upload {
        border: 1px dashed var(--el-border-color);
        border-radius: 6px;
        cursor: pointer;
        position: relative;
        overflow: hidden;
        transition: var(--el-transition-duration-fast);
}

.avatar-uploader .el-upload:hover {
        border-color: var(--el-color-primary);
}

.el-icon.avatar-uploader-icon {
        font-size: 28px;
        color: #8c939d;
        width: 178px;
        height: 178px;
        text-align: center;
}
</style>