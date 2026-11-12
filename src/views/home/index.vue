<template>
    <div>
    <el-card>
        <div class="box">
            <img :src="getAvatarUrl(useStore.avatar)" @error="onAvatarError" alt="用户头像" class="avatar">

            <div>
                <h3 class="title">{{ getTime() }}好{{ useStore.nickname }}</h3>
            </div>
        </div>
    </el-card>
   

    <SvgIcon name="wel" width="1000px" height="500px" style="margin: 10px 0px;"></SvgIcon>
</div>
</template>

<script setup lang='ts'>
//引入仓库对象
import useUserStore from '@/store/modules/user';
import { getTime } from '@/utils/time';
import { getAvatarUrl, onAvatarError } from '@/utils/image';
let useStore = useUserStore();

</script>

<style scoped>
.box {
    display: flex;
    z-index: 1;
    /* 保证首页内容层级较低，不会遮挡弹窗 */
    .avatar {
        width: 100px;
        height: 100px;
        border-radius: 50%;
        background-color: #e8edf4;
        
    }

    .title {
        margin-left: 20px;
        line-height: 100px;
        font-size: 20px;
        color: #333;
    }
}
</style>