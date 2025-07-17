<template>
    <el-button size="small" icon="Refresh" circle @click="updateRefsh"></el-button>
    <el-button size="small" icon="FullScreen" circle @click="fullScreen"></el-button>
    <el-popover placement="bottom" title="主题设置" :width="200" trigger="hover">
        <el-form>
                <el-form-item label="主题颜色">
                    <el-color-picker size="small"  v-model="color" :teleported="false" show-alpha :predefine="predefineColors" @change="setColor" />
                </el-form-item>
                <el-form-item label="暗黑模式">
                    <el-switch size="small" @click="changeDark" v-model="dark" inline-prompt active-icon="MoonNight" inactive-icon="Sunny"/>
                </el-form-item>
            </el-form>
            
        <template #reference>
            <el-button size="small"  icon="Setting" circle></el-button>
        </template>
    </el-popover>

    <img :src="layUseUserStore.avatar" alt="" style="height: 24px;width: 24px;margin: 0 10px; border-radius: 10px;">
    <!--下拉菜单-->
    <el-dropdown>
        <span class="el-dropdown-link">
            {{ layUseUserStore.name }}
            <el-icon class="el-icon--right">
                <arrow-down />
            </el-icon>
        </span>
        <template #dropdown>
            <el-dropdown-menu>
                <el-dropdown-item @click="changePassword">修改密码</el-dropdown-item>
                <el-dropdown-item @click="updateAvatar">更新头像</el-dropdown-item>
                <el-dropdown-item @click="logout">退出登录</el-dropdown-item>
            </el-dropdown-menu>
        </template>
    </el-dropdown>

    <!-- 修改密码弹窗 -->
    <el-dialog v-model="showPwdDialog" title="修改密码" width="400px">
      <el-form :model="pwdForm" :rules="pwdRules" ref="pwdFormRef" label-width="110px">
        <el-form-item label="原密码" prop="oldPwd">
          <el-input v-model="pwdForm.oldPwd" :type="showOldPwd ? 'text' : 'password'">
            <template #suffix>
              <el-icon @click="showOldPwd = !showOldPwd" style="cursor:pointer;">
                <component :is="showOldPwd ? 'View' : 'Hide'" />
              </el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="新密码" prop="newPwd">
          <el-input v-model="pwdForm.newPwd" :type="showNewPwd ? 'text' : 'password'">
            <template #suffix>
              <el-icon @click="showNewPwd = !showNewPwd" style="cursor:pointer;">
                <component :is="showNewPwd ? 'View' : 'Hide'" />
              </el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPwd">
          <el-input v-model="pwdForm.confirmPwd" :type="showConfirmPwd ? 'text' : 'password'">
            <template #suffix>
              <el-icon @click="showConfirmPwd = !showConfirmPwd" style="cursor:pointer;">
                <component :is="showConfirmPwd ? 'View' : 'Hide'" />
              </el-icon>
            </template>
          </el-input>
        </el-form-item>
      </el-form>
      <template #footer>
        <el-button @click="showPwdDialog = false">取消</el-button>
        <el-button type="primary" @click="submitPwd">确定</el-button>
      </template>
    </el-dialog>

    <!-- 修改头像弹窗 -->
    <el-dialog v-model="showAvatarDialog" title="更新头像" width="400px">
      <div class="avatar-upload-card">
        <el-upload
          class="avatar-uploader"
          action="/api/Upload" :data="{ type: 'UserImages' }" name="file"
          :show-file-list="false"
          :before-upload="beforeAvatarUpload"
          :on-change="handleAvatarChange"
        >
          <div v-if="avatarPreview" class="avatar-preview-box">
            <img :src="avatarPreview" class="avatar-img" />
          </div>
          <div v-else class="avatar-upload-placeholder">
            <el-icon class="avatar-uploader-icon"><Plus /></el-icon>
            <div class="avatar-upload-text">点击上传头像</div>
          </div>
        </el-upload>
      </div>
      <template #footer>
        <el-button @click="showAvatarDialog = false">取消</el-button>
        <el-button type="primary" @click="submitAvatar">确定</el-button>
      </template>
    </el-dialog>
</template>

<script setup lang='ts'>
import { ref } from 'vue'
import { ElMessage } from 'element-plus'
//获取仓库
import useSettingStore from '@/store/modules/setting';
//获取用户相关仓库
import useUserStore from '@/store/modules/user';
//引入路由器
import { useRouter, useRoute } from 'vue-router';
import { reqChangePassword, reqChangeAvatar } from '@/api/user'
import { Plus, View, Hide } from '@element-plus/icons-vue'
let $router = useRouter();
//获取当前路由
let $route = useRoute();
let layUseUserStore = useUserStore();
let dark = ref(false);
//获取设定相关仓库
let layUseSettingStore = useSettingStore();
//退出登录
let logout = () => {
    //1.告诉服务器清除token，退出登录接口
    //2.清除本地token
    //3.跳转到登录页面
    layUseUserStore.userLogout();
    $router.push({ path: '/login', query: { redirect: $route.path } });
}

//刷新
let updateRefsh = () => {
    layUseSettingStore.refresh = !layUseSettingStore.refresh;
}
//全屏
let fullScreen = () => {
    //判断是否全屏
    let full = document.fullscreenElement;
    //全屏模式切换
    if (!full) {
        document.documentElement.requestFullscreen();
    } else {
        document.exitFullscreen();
    }
}
const color = ref('rgba(255, 69, 0, 0.68)')
const predefineColors = ref([
  '#ff4500',
  '#ff8c00',
  '#ffd700',
  '#90ee90',
  '#00ced1',
  '#1e90ff',
  '#c71585',
  'rgba(255, 69, 0, 0.68)',
  'rgb(255, 120, 0)',
  'hsv(51, 100, 98)',
  'hsva(120, 40, 94, 0.5)',
  'hsl(181, 100%, 37%)',
  'hsla(209, 100%, 56%, 0.73)',
  '#c7158577',
])
//switch事件
const changeDark=()=>{
    let html=document.documentElement;
    if(dark.value){
        html.classList.add('dark');        
    }else{
        html.classList.remove('dark');
    }
}
//设置主题颜色
const setColor=(color:string)=>{
    let html=document.documentElement;
    html.style.setProperty('--el-color-primary',color);    
}
const showPwdDialog = ref(false)
const showAvatarDialog = ref(false)
// 修改密码表单
const pwdForm = ref({ oldPwd: '', newPwd: '', confirmPwd: '' })
const pwdRules = {
  oldPwd: [{ required: true, message: '请输入原密码', trigger: 'blur' }],
  newPwd: [{ required: true, message: '请输入新密码', trigger: 'blur' }],
  confirmPwd: [
    { required: true, message: '请再次输入新密码', trigger: 'blur' },
    { validator: (rule: any, value: string, callback: any) => {
        if (value !== pwdForm.value.newPwd) {
          callback(new Error('两次输入的新密码不一致'))
        } else {
          callback()
        }
      }, trigger: 'blur' }
  ]
}
const pwdFormRef = ref()
// 头像相关
const avatarPreview = ref('')
const avatarFile = ref<File | null>(null)
// 打开弹窗
const changePassword = () => { showPwdDialog.value = true }
const updateAvatar = () => { showAvatarDialog.value = true }
// 提交修改密码
const submitPwd = async () => {
  await pwdFormRef.value?.validate()
  const res = await reqChangePassword({
    OldPassword: pwdForm.value.oldPwd,
    NewPassword: pwdForm.value.newPwd
  })
  if (res && res.Success) {
    ElMessage.success('密码修改成功')
    showPwdDialog.value = false
    pwdForm.value.oldPwd = ''
    pwdForm.value.newPwd = ''
    pwdForm.value.confirmPwd = ''
  } else {
    ElMessage.error(res?.Message || '密码修改失败')
  }
}
// 头像上传前校验
const beforeAvatarUpload = (file: File) => {
  const isImage = file.type.startsWith('image/')
  const isLt2M = file.size / 1024 / 1024 < 2
  if (!isImage) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  if (!isLt2M) {
    ElMessage.error('图片大小不能超过 2MB!')
    return false
  }
  return true
}
// 头像选择后预览和上传成功回调
const handleAvatarChange = (file: any, fileList: any) => {
  if (file.response) {
    // 兼容后端返回格式，拼接完整URL
    const baseUrl = import.meta.env.VITE_APP_SERVE || 'http://localhost:5161';
    let url = file.response.url || file.response.data || ''
    if (url && !/^https?:\/\//.test(url)) {
      url = `${baseUrl}/${url}`.replace(/\\/g, '/')
    }
    avatarPreview.value = url
  } else {
    avatarFile.value = file.raw
    const reader = new FileReader()
    reader.onload = e => { avatarPreview.value = e.target?.result as string }
    reader.readAsDataURL(file.raw)
  }
}
// 提交头像
const submitAvatar = async () => {
  if (!avatarPreview.value) {
    ElMessage.error('请先上传图片')
    return
  }
  const res = await reqChangeAvatar({
    Avatar: avatarPreview.value // 现在为图片地址
  })
  if (res && res.Success) {
    ElMessage.success('头像更新成功')
    showAvatarDialog.value = false
    layUseUserStore.avatar = avatarPreview.value // 前端同步
  } else {
    ElMessage.error(res?.Message || '头像更新失败')
  }
}
const showOldPwd = ref(false)
const showNewPwd = ref(false)
const showConfirmPwd = ref(false)
</script>
<script lang="ts">
export default {
    name: 'Setting'
}
</script>

<style>
/* 提高el-dialog弹窗的z-index，避免被其他元素覆盖 */
.el-overlay-dialog {
  z-index: 3000 !important;
}
.el-dialog__wrapper {
  z-index: 3000 !important;
}
/* 优化弹窗内容居中显示 */
.avatar-uploader {
  display: flex;
  justify-content: center;
  align-items: center;
  width: 180px;
  height: 180px;
  border: 2px dashed #d9d9d9;
  border-radius: 8px;
  background: #fafafa;
  cursor: pointer;
  transition: border-color 0.3s;
  margin: 0 auto;
}
.avatar-uploader:hover {
  border-color: #409eff;
}
.avatar-upload-card {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 200px;
}
.avatar-preview-box {
  width: 160px;
  height: 160px;
  border-radius: 8px;
  overflow: hidden;
  border: 1.5px solid #e4e7ed;
  background: #fff;
  display: flex;
  align-items: center;
  justify-content: center;
}
.avatar-img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  border-radius: 8px;
}
.avatar-upload-placeholder {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  width: 160px;
  height: 160px;
  border-radius: 8px;
  background: #f4f4f4;
}
.avatar-upload-text {
  margin-top: 10px;
  color: #999;
  font-size: 14px;
}
</style>