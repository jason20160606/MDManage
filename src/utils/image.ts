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
