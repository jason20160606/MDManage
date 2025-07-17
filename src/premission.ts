//路由鉴权（路由权限设置）
// 全局前置路由守卫，初始化的时候被调用、每次路由切换之前被调用
import router from './router'
import nprogress from 'nprogress';
//获取用户相关的小仓库内部token数据，去判断用户是否登录
import useUserStore from './store/modules/user';
import pinia from './store';
let userStore = useUserStore(pinia);
nprogress.configure({ showSpinner: false });

//引入进度条样式
import 'nprogress/nprogress.css';
//全局前置守卫
router.beforeEach(async(to: any, _from: any, next: any) => {
    //to:将要访问的路径
    //from:从哪个路径跳转而来
    //next:是一个函数，表示放行
    //next() 放行 next(path) 放行到指定的路由
    nprogress.start();
    //获取token，判断用户是否登录
    let token = userStore.token;
    //获取用户名字
    let username = userStore.username;
    
    if (token) { //登录成功
        if (to.path == '/login') { //如果是去登录页，放行
            next({ path: '/' });
        } else { //去其他页面，放行
            //判断是否有用户信息
            if (username) { //有用户信息，放行
                next();
            } else { //没有用户信息，获取用户信息
                try {
                    //获取用户信息
                    await userStore.getUserInfo(); 
                    next();
                } catch (error) { //token过期，获取不到用户信息，重新登录
                    //用户退出登录
                    await userStore.userLogout();                    
                    next({ path: '/login', query: { redirect: to.path } });
                }
            }
        }
    } else { //没有token，未登录
        if (to.path == '/login') { //如果是去登录页，放行
            next();
        } else { //去其他页面，跳转到登录页    
            next({ path: "/login", query: { redirect: to.path } });
        }
    }
})
//全局后置守卫，初始化的时候被调用、每次路由切换之后被调用
router.afterEach((_to: any, _from: any) => {
    nprogress.done();
})
//1.任意路由切换进度条变化--nprogress
//2.路由鉴权（路由权限设置）
//3.项目中路由鉴权的实现
//  1.全部路由组件：登录|404|任意路由|首页|数据大屏|权限管理（三个子路由）|商品管理（四个子路由）
//  2.用户未登录：可以访问login，其余路由不能访问
//  3.用户登录成功：不可以访问login[指向首页]，其余路由可以访问