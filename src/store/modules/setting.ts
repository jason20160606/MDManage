//小仓库：layout组件相关配置
import { defineStore } from 'pinia';
let useSettingStore = defineStore('setting', {
    state: () => {
        return {
            //用于控制菜单折叠
            fold: false
        };
    },

})
export default useSettingStore;