<template>

    <el-card>
        <div class="box">
            <img :src="useStore.avatar" alt="111" class="avatar">

            <div>
                <h3 class="title">{{ getTime() }}好{{ useStore.name }}</h3>
            </div>
        </div>
    </el-card>
   

    <SvgIcon name="wel" width="1000px" height="500px" style="margin: 10px 0px;"></SvgIcon>

</template>

<script setup lang='ts'>
//引入仓库对象
import useUserStore from '@/store/modules/user';
import { getTime } from '@/utils/time';
let useStore = useUserStore();

</script>

<style scoped>
.box {
    display: flex;

    .avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background-color: #333;
        
    }

    .title {
        margin-left: 20px;
        line-height: 100px;
        font-size: 20px;
        color: #333;
    }
}
</style>