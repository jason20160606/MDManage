//通过vue-router实现路由功能
import { createRouter, createWebHashHistory } from 'vue-router'
import { allroutes } from './routes'

//创建路由器
const router = createRouter({
    history: createWebHashHistory(),
    routes: allroutes,
    scrollBehavior() {
        return {
            left: 0,
            top: 0
        }

    }
})

export default router;

