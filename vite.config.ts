import { defineConfig,loadEnv } from 'vite'
import vue from '@vitejs/plugin-vue'
import path from 'path'
//引入svg插件
import { createSvgIconsPlugin } from 'vite-plugin-svg-icons'
import { viteMockServe } from 'vite-plugin-mock'
// https://vite.dev/config/
export default defineConfig(({ command }) => {
  //获取各种环境下的对应变量
  let env = loadEnv(command, process.cwd());  
  return {
    plugins: [vue(),
    createSvgIconsPlugin({
      iconDirs: [path.resolve(process.cwd(), 'src/assets/icons')],
      symbolId: 'icon-[dir]-[name]',
    }),
    viteMockServe({
      mockPath: 'mock',
      enable: command === 'serve',
    })
    ],

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
           target: env.VITE_SERVE,
           changeOrigin: true,
           rewrite: (path) => path.replace(/^\/api/, ''),
         },
       },
     }  

  }
})
