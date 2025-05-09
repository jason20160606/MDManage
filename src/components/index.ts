
import SvgIcon from './SvgIcon/index.vue';
import Pagination from './Pagination/index.vue';
//全局对象
const allGlobalComponents = { SvgIcon, Pagination };
//对外暴漏插件对象
export default {
  install(app: any) {
    //注册全局组件
    for (const [key, component] of Object.entries(allGlobalComponents)) {
      app.component(key, component);
    }   
  }
}