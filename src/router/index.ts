//通过vue-router实现路由功能
import { createRouter, createWebHashHistory } from 'vue-router'
import { constantRoutes } from './routes'

//创建路由器
const router = createRouter({
    history: createWebHashHistory(),
    routes: constantRoutes, // 初始化时只包含常量路由，不包含404
    /**
     * 定义路由切换时的滚动行为
     */
    scrollBehavior() {
        return {
            left: 0,
            top: 0
        }
    }
})

export default router;
