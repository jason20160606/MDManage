
import SvgIcon from './SvgIcon/index.vue';
import Pagination from './Pagination/index.vue';
//引入element-plus图标
import * as ElementPlusIconsVue from '@element-plus/icons-vue'

//全局对象
const allGlobalComponents = { SvgIcon, Pagination };
//对外暴漏插件对象
export default {
  install(app: any) {
    //注册全局组件
    for (const [key, component] of Object.entries(allGlobalComponents)) {
      app.component(key, component);
    }
    //将element-plus提供图标注册为全局组件
    for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
      app.component(key, component)
    }    
  }
}