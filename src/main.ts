import { createApp } from 'vue'
import App from '@/App.vue'
//引入element-plus插件与样式
import ElementPlus from 'element-plus'
import 'element-plus/dist/index.css'
//配置element-plus的语言为中文
import zhCn from 'element-plus/es/locale/lang/zh-cn'
//svg图标插件
//@ts-ignore
import 'virtual:svg-icons-register'
//引入自定义插件对象：注册整个项目的全局组件
import gloalComponents from '@/components'
//引入全局样式
import '@/styles/index.scss'
//引入路由
import router from '@/router/index'
//引入pinia插件
import pinia from '@/store/index'
//引入路由鉴权文件
import './premission'
//引入暗黑模式
import 'element-plus/theme-chalk/dark/css-vars.css'
//获取应用实例对象
const app = createApp(App);
//安装element-plus插件
app.use(ElementPlus, {
    locale: zhCn //配置语言为中文
});
//注册全局组件
app.use(gloalComponents)
//注册路由
app.use(router)
//注册pinia
app.use(pinia)
//将应用挂载到挂载点上
app.mount('#app')
