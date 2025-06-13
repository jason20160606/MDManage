/**
 * 路由类型定义文件
 * 用于定义项目中使用的路由相关类型
 */

import type { RouteRecordRaw } from 'vue-router'

/**
 * 扩展Vue Router的路由记录类型
 * 添加自定义的meta字段，用于存储路由的额外信息
 */
export interface AppRouteMeta {
  title: string
  icon?: string
  roles?: string[]
  keepAlive?: boolean
  hidden?: boolean
}

export type AppRouteRecordRaw = Omit<RouteRecordRaw, 'meta'> & {
  meta?: AppRouteMeta
  children?: AppRouteRecordRaw[]
}

/**
 * 路由元信息类型
 * 用于单独定义meta字段的类型
 */
export type RouteMeta = NonNullable<AppRouteRecordRaw['meta']>

/**
 * 路由配置类型
 * 用于定义路由配置数组的类型
 */
export type AppRouteModule = AppRouteRecordRaw[] 