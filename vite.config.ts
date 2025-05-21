import { defineConfig, loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
//引入svg插件
import { createSvgIconsPlugin } from 'vite-plugin-svg-icons'
//引入mock插件
import { viteMockServe } from 'vite-plugin-mock'
// https://vite.dev/config/
export default defineConfig(({ command, mode }) => {
  //获取各种环境下的对应变量
  let env = loadEnv(mode, process.cwd());
  return {
    //配置插件
    plugins: [vue(),
    //svg图标
    createSvgIconsPlugin({
      iconDirs: [path.resolve(process.cwd(), 'src/assets/icons')],
      symbolId: 'icon-[dir]-[name]',
    }),
    //mock数据
    viteMockServe({
      mockPath: 'mock',
      enable: command === 'serve',
    })
    ],
    //配置别名
    resolve: {
      alias: {
        '@': path.resolve('src'),
      },
    },
    //scss全局变量配置
    css: {
      preprocessorOptions: {
        scss: {
          additionalData: `@import "@/styles/variable.scss";`,
        },
      }
    },
    //代理跨域
    server: {
      proxy: {
        [env.VITE_APP_BASE_API]: {
          //获取数据的服务器地址
          target: env.VITE_APP_SERVE,
          //是否代理跨域
          changeOrigin: true,
          //重写路径
          rewrite: (path) => path.replace(/^\/api/, ''),
        },
      },
    }

  }
})
