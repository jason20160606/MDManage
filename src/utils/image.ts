/**
 * 将图片路径转换为完整 URL。
 * - data: 开头的本地预览地址直接返回
 * - 已是完整 URL（旧数据库数据）：提取路径部分，替换为当前服务器地址
 * - 相对路径（新数据）：直接拼接当前服务器地址
 */
export function getImageUrl(path: string): string {
  if (!path) return ''
  if (path.startsWith('data:')) return path

  const base = (import.meta.env.VITE_APP_SERVE as string || '').replace(/\/$/, '')

  if (/^https?:\/\//.test(path)) {
    try {
      path = new URL(path).pathname.replace(/^\//, '')
    } catch {
      return path
    }
  }

  return base ? `${base}/${path}` : path
}

/**
 * 默认头像：前端本地静态资源，不依赖后端文件，也不会被接口鉴权影响。
 * 用 BASE_URL 拼接，部署到子路径时依然有效。
 */
export const DEFAULT_AVATAR = `${import.meta.env.BASE_URL}images/default-avatar.svg`

/**
 * 头像专用 URL：空值直接返回默认头像；非空仍走正常的服务器地址拼接。
 */
export function getAvatarUrl(path?: string | null): string {
  return path ? getImageUrl(path) : DEFAULT_AVATAR
}

/**
 * 图片加载失败（文件被删、404、地址失效）时切成默认头像。
 * 只在「当前 src 已经是默认头像」时停止，避免默认图自身失败造成死循环，
 * 同时保证之后换成新头像再次失败时仍能兜底。
 */
export function onAvatarError(event: Event) {
  const img = event.target as HTMLImageElement | null
  if (!img) return
  const fallback = new URL(DEFAULT_AVATAR, window.location.href).href
  if (img.src === fallback) return
  img.src = DEFAULT_AVATAR
}
