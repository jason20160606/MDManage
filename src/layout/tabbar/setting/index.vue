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

    <img :src="getAvatarUrl(layUseUserStore.avatar)" @error="onAvatarError" alt="用户头像" style="height: 24px;width: 24px;margin: 0 10px; border-radius: 10px;">
    <!--下拉菜单-->
    <el-dropdown>
        <span class="el-dropdown-link">
            {{ layUseUserStore.nickname || layUseUserStore.username }}
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
                <component :is="showOldPwd ? View : Hide" />
              </el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="新密码" prop="newPwd">
          <el-input v-model="pwdForm.newPwd" :type="showNewPwd ? 'text' : 'password'">
            <template #suffix>
              <el-icon @click="showNewPwd = !showNewPwd" style="cursor:pointer;">
                <component :is="showNewPwd ? View : Hide" />
              </el-icon>
            </template>
          </el-input>
        </el-form-item>
        <el-form-item label="确认新密码" prop="confirmPwd">
          <el-input v-model="pwdForm.confirmPwd" :type="showConfirmPwd ? 'text' : 'password'">
            <template #suffix>
              <el-icon @click="showConfirmPwd = !showConfirmPwd" style="cursor:pointer;">
                <component :is="showConfirmPwd ? View : Hide" />
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
          action="/api/Upload" name="file"
          :show-file-list="false"
          :before-upload="beforeAvatarUpload"
          :http-request="uploadAvatarRequest"
          :on-change="handleAvatarChange"
          :on-error="handleAvatarError"
        >
          <div v-if="avatarPreview" class="avatar-preview-box">
            <img :src="getAvatarUrl(avatarPreview)" @error="onAvatarError" class="avatar-img" />
          </div>
          <div v-else class="avatar-upload-placeholder">
            <el-icon class="avatar-uploader-icon"><Plus /></el-icon>
            <div class="avatar-upload-text">点击上传头像</div>
          </div>
        </el-upload>
        <div class="avatar-tip">
          <template v-if="avatarUploading">正在压缩并上传…</template>
          <template v-else-if="avatarInfo && avatarPath && avatarInfo.compressed">
            已压缩：{{ formatBytes(avatarInfo.before) }} → {{ formatBytes(avatarInfo.after) }}（{{ avatarInfo.width }}×{{ avatarInfo.height }}）
          </template>
          <template v-else-if="avatarInfo && avatarPath">
            原图 {{ formatBytes(avatarInfo.after) }}，尺寸已合适（{{ avatarInfo.width }}×{{ avatarInfo.height }}）
          </template>
          <template v-else>支持 JPG / PNG / WebP，上传时自动压缩为 256×256</template>
        </div>
      </div>
      <template #footer>
        <el-button @click="showAvatarDialog = false">取消</el-button>
        <el-button type="primary" :disabled="avatarUploading || !avatarPath" @click="submitAvatar">确定</el-button>
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
import { reqChangePassword, reqChangeAvatar, reqUploadImage } from '@/api/user'
import { showError } from '@/utils/request'
import { Plus, View, Hide } from '@element-plus/icons-vue'
import { getAvatarUrl, onAvatarError, compressImage, formatBytes, AVATAR_PRESET } from '@/utils/image'
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
    { validator: (_rule: any, value: string, callback: any) => {
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
const avatarPreview = ref('')      // 预览地址（本地 dataURL 或服务器相对路径）
const avatarPath = ref('')         // 上传成功后服务器返回的相对路径，提交只用这个
const avatarUploading = ref(false) // 压缩 + 上传进行中
const avatarInfo = ref<{ before: number; after: number; width: number; height: number; compressed: boolean } | null>(null)
// 打开弹窗
const changePassword = () => { showPwdDialog.value = true }
const updateAvatar = () => { showAvatarDialog.value = true }
// 提交修改密码
// 注意：/User 返回的是不带 Data 的统一信封，拦截器会把 Data 解出来（此处为 null），
// 所以不能用 res.Success 判断，失败时拦截器已经 reject。
const submitPwd = async () => {
  try {
    await pwdFormRef.value?.validate()
  } catch {
    return // 表单校验未通过
  }
  try {
    await reqChangePassword({
      OldPassword: pwdForm.value.oldPwd,
      NewPassword: pwdForm.value.newPwd
    })
    ElMessage.success('密码修改成功')
    showPwdDialog.value = false
    pwdForm.value.oldPwd = ''
    pwdForm.value.newPwd = ''
    pwdForm.value.confirmPwd = ''
  } catch (e) {
    showError(e, '密码修改失败')
  }
}
/** 读成 dataURL，用于本地预览 */
const readAsDataURL = (file: Blob): Promise<string> =>
  new Promise((resolve, reject) => {
    const reader = new FileReader()
    reader.onload = () => resolve(String(reader.result || ''))
    reader.onerror = () => reject(new Error('预览读取失败'))
    reader.readAsDataURL(file)
  })

/** 从上传接口返回里取相对路径（兼容裸字符串 / {Data} / {Data:{Data}} 三种形态） */
const pickUploadPath = (res: any): string => {
  if (!res) return ''
  if (typeof res === 'string') return res
  const first = res.Data ?? res.data
  if (typeof first === 'string') return first
  if (first && typeof first === 'object') {
    const second = first.Data ?? first.data
    if (typeof second === 'string') return second
  }
  return ''
}

/**
 * el-upload 自定义上传：改用项目统一请求实例。
 * 内置的 action 方式走裸 XHR，不会带 Authorization，接口会直接 401。
 */
const uploadAvatarRequest = async (options: any) => {
  const res = await reqUploadImage(options.file, 'UserImages')
  const path = pickUploadPath(res)
  if (!path) throw new Error('上传接口未返回图片地址')
  return { Status: 200, Data: path }
}

// 头像上传前：校验 + 压缩（返回压缩后的 File，交给 el-upload 上传）
const beforeAvatarUpload = async (file: File) => {
  if (!file.type.startsWith('image/')) {
    ElMessage.error('只能上传图片文件!')
    return false
  }
  // 原图放宽到 10MB：手机直出照片普遍 3–8MB，压缩后会降到几十 KB
  if (file.size / 1024 / 1024 > 10) {
    ElMessage.error('图片大小不能超过 10MB!')
    return false
  }
  avatarUploading.value = true
  avatarInfo.value = null
  try {
    const result = await compressImage(file, AVATAR_PRESET)
    avatarInfo.value = {
      before: result.originalSize,
      after: result.size,
      width: result.width,
      height: result.height,
      compressed: result.compressed
    }
    // 压缩后体积更小，优先用它做预览，用户看到的就是最终上传的图
    avatarPreview.value = result.dataUrl || (await readAsDataURL(result.file))
    return result.file
  } catch (e) {
    avatarUploading.value = false
    ElMessage.error('图片处理失败，请换一张图片试试')
    return false
  }
}
// 头像上传结果：成功只认服务器返回的相对路径，避免把大段 dataURL 存进数据库
const handleAvatarChange = (file: any, _fileList: any) => {
  const resp = file?.response
  if (!resp) return // 仍在上传中，预览已由 before-upload 处理
  avatarUploading.value = false
  const path = pickUploadPath(resp)
  if (path) {
    avatarPath.value = path
    avatarPreview.value = path
  } else {
    ElMessage.error('上传失败，请重试')
  }
}
const handleAvatarError = (err: any) => {
  avatarUploading.value = false
  ElMessage.error(err?.Message || err?.message || '头像上传失败，请重试')
}
// 提交头像
const submitAvatar = async () => {
  if (!avatarPath.value) {
    ElMessage.error(avatarUploading.value ? '图片还在上传，请稍候' : '请先上传图片')
    return
  }
  try {
    // /User 返回不带 Data 的统一信封，成功与否看是否抛错
    await reqChangeAvatar({ Avatar: avatarPath.value })
    ElMessage.success('头像更新成功')
    showAvatarDialog.value = false
    layUseUserStore.avatar = avatarPath.value // 前端同步（store 有持久化）
  } catch (e) {
    showError(e, '头像更新失败')
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
  flex-direction: column;
  justify-content: center;
  align-items: center;
  gap: 10px;
  min-height: 200px;
}
.avatar-tip {
  font-size: 12px;
  line-height: 1.6;
  color: #909399;
  text-align: center;
  word-break: break-all;
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