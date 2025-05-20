//通过vue-router实现路由功能
import { createRouter, createWebHashHistory } from 'vue-router'
import { constantRoute } from './routes'

//创建路由器
const router = createRouter({
    history: createWebHashHistory(),
    routes: constantRoute,
    /**
     * 定义路由切换时的滚动行为
     * 每次路由切换时，页面将滚动到左上角（坐标为 x: 0, y: 0 的位置）
     * @returns 一个包含滚动位置的对象，left 表示水平滚动位置，top 表示垂直滚动位置
     */
    scrollBehavior() {
        // 返回一个对象，设置水平滚动位置为 0，垂直滚动位置为 0
        return {
            left: 0,
            top: 0
        }
    }
})

export default router;

