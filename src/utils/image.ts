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

/* ------------------------------------------------------------------ *
 * 上传前压缩
 * 目的：手机直出照片动辄 3–8 MB，而头像显示尺寸只有 40–100 px，
 * 原样上传既慢又毫无意义。这里用 canvas 等比缩放到目标尺寸后重新编码，
 * 一张头像通常压到 15–30 KB，商品图通常压到 80–200 KB。
 * 纯浏览器 API，不引第三方库。
 * ------------------------------------------------------------------ */

export interface CompressOptions {
  /** 长边最大像素，默认 256（头像） */
  maxSide?: number
  /** 初始编码质量 0-1，默认 0.85 */
  quality?: number
  /** 压缩后体积上限（字节），超过则逐级降质量重试 */
  maxBytes?: number
  /** 是否保留透明通道：false 时铺白底（避免 PNG 透明区变黑） */
  keepAlpha?: boolean
}

export interface CompressResult {
  /** 压缩后的文件，可直接交给 el-upload 上传 */
  file: File
  /** 压缩后的预览地址（dataURL） */
  dataUrl: string
  /** 压缩后宽高 */
  width: number
  height: number
  /** 原图体积（字节） */
  originalSize: number
  /** 压缩后体积（字节） */
  size: number
  /** 是否真的压缩了；原图本身已足够小会原样返回 */
  compressed: boolean
}

/** 浏览器是否支持 webp 编码（Safari 14 以下不支持） */
let webpSupported: boolean | null = null
function canEncodeWebp(): boolean {
  if (webpSupported !== null) return webpSupported
  try {
    const c = document.createElement('canvas')
    c.width = 1
    c.height = 1
    webpSupported = c.toDataURL('image/webp').startsWith('data:image/webp')
  } catch {
    webpSupported = false
  }
  return webpSupported
}

/** 解码图片：优先 createImageBitmap（自动按 EXIF 方向摆正），失败退回 <img> */
async function decodeImage(file: File): Promise<{ source: CanvasImageSource; width: number; height: number; release: () => void }> {
  if (typeof createImageBitmap === 'function') {
    try {
      const bmp = await createImageBitmap(file, { imageOrientation: 'from-image' } as ImageBitmapOptions)
      return { source: bmp, width: bmp.width, height: bmp.height, release: () => bmp.close() }
    } catch {
      /* 某些浏览器不认 imageOrientation 参数，走下面的兜底 */
    }
  }
  const url = URL.createObjectURL(file)
  try {
    const img = await new Promise<HTMLImageElement>((resolve, reject) => {
      const el = new Image()
      el.onload = () => resolve(el)
      el.onerror = () => reject(new Error('图片解码失败'))
      el.src = url
    })
    // <img> 会把 EXIF 方向应用到 naturalWidth/Height，尺寸取渲染后的值
    return {
      source: img,
      width: img.naturalWidth || img.width,
      height: img.naturalHeight || img.height,
      release: () => URL.revokeObjectURL(url)
    }
  } catch (e) {
    URL.revokeObjectURL(url)
    throw e
  }
}

/** 逐级减半缩放，避免一次性大比例缩小产生锯齿 */
function scaleDown(ctx: CanvasRenderingContext2D, source: CanvasImageSource, sw: number, sh: number, dw: number, dh: number, keepAlpha: boolean) {
  let curW = sw
  let curH = sh
  let src: CanvasImageSource = source
  // 每次最多缩一半，最多迭代 6 次（4000px → 256px 约 4 次）
  for (let i = 0; i < 6; i++) {
    const nextW = Math.max(dw, Math.floor(curW / 2))
    const nextH = Math.max(dh, Math.floor(curH / 2))
    if (nextW === curW && nextH === curH) break
    const c = document.createElement('canvas')
    c.width = nextW
    c.height = nextH
    const cx = c.getContext('2d')
    if (!cx) break
    if (!keepAlpha) {
      cx.fillStyle = '#ffffff'
      cx.fillRect(0, 0, nextW, nextH)
    }
    cx.imageSmoothingEnabled = true
    cx.imageSmoothingQuality = 'high'
    cx.drawImage(src, 0, 0, curW, curH, 0, 0, nextW, nextH)
    src = c
    curW = nextW
    curH = nextH
    if (curW === dw && curH === dh) break
  }
  if (!keepAlpha) {
    ctx.fillStyle = '#ffffff'
    ctx.fillRect(0, 0, dw, dh)
  }
  ctx.imageSmoothingEnabled = true
  ctx.imageSmoothingQuality = 'high'
  ctx.drawImage(src, 0, 0, curW, curH, 0, 0, dw, dh)
}

function toBlob(canvas: HTMLCanvasElement, type: string, quality: number): Promise<Blob | null> {
  return new Promise(resolve => canvas.toBlob(resolve, type, quality))
}

function renameExt(name: string, ext: string): string {
  const base = name.replace(/\.[^.]+$/, '') || 'image'
  return `${base}.${ext}`
}

/**
 * 压缩图片。失败时抛错，调用方自行决定是中止上传还是放行原图。
 *
 * 尺寸计算：短边等比缩放，让长边不超过 maxSide，**不裁剪、不拉伸**。
 * 原图长边已小于目标尺寸且体积未超上限时，直接返回原文件（不做无意义的二次编码）。
 */
export async function compressImage(file: File, options: CompressOptions = {}): Promise<CompressResult> {
  const { maxSide = 256, quality = 0.85, maxBytes = 60 * 1024, keepAlpha = false } = options
  const originalSize = file.size

  // SVG 是矢量，压缩没有意义
  if (file.type === 'image/svg+xml') {
    return { file, dataUrl: '', width: 0, height: 0, originalSize, size: originalSize, compressed: false }
  }

  const { source, width, height, release } = await decodeImage(file)
  try {
    if (!width || !height) throw new Error('图片尺寸异常')

    const scale = Math.min(1, maxSide / Math.max(width, height))
    const targetW = Math.max(1, Math.round(width * scale))
    const targetH = Math.max(1, Math.round(height * scale))

    // 已经足够小：不重新编码，避免小图变大
    if (scale === 1 && originalSize <= maxBytes) {
      return {
        file,
        dataUrl: '',
        width: targetW,
        height: targetH,
        originalSize,
        size: originalSize,
        compressed: false
      }
    }

    const canvas = document.createElement('canvas')
    canvas.width = targetW
    canvas.height = targetH
    const ctx = canvas.getContext('2d')
    if (!ctx) throw new Error('浏览器不支持 canvas')
    scaleDown(ctx, source, width, height, targetW, targetH, keepAlpha)

    // 优先 webp（同等画质体积约 jpeg 的 60–70%），不支持则退回 jpeg
    let type = canEncodeWebp() ? 'image/webp' : 'image/jpeg'
    let ext = type === 'image/webp' ? 'webp' : 'jpg'
    let q = quality
    let blob = await toBlob(canvas, type, q)

    // 质量兜底：体积仍超上限就逐级降质量（0.85 → 0.75 → 0.65 → 0.55 → 0.5）
    while (blob && blob.size > maxBytes && q > 0.5) {
      q = Math.max(0.5, q - 0.1)
      blob = await toBlob(canvas, type, q)
    }
    // 极端情况：webp 编码器产出的体积反而更大，换 jpeg 再试一次
    if (!blob || (blob.size > originalSize && type === 'image/webp')) {
      const jpeg = await toBlob(canvas, 'image/jpeg', q)
      if (jpeg && (!blob || jpeg.size < blob.size)) {
        blob = jpeg
        type = 'image/jpeg'
        ext = 'jpg'
      }
    }
    if (!blob) throw new Error('图片编码失败')

    // 压完反而更大（例如原图已是高度优化的 webp），保留原文件
    if (blob.size >= originalSize && scale === 1) {
      return { file, dataUrl: '', width: targetW, height: targetH, originalSize, size: originalSize, compressed: false }
    }

    const outFile = new File([blob], renameExt(file.name, ext), { type, lastModified: Date.now() })
    const dataUrl = await new Promise<string>((resolve, reject) => {
      const reader = new FileReader()
      reader.onload = () => resolve(String(reader.result || ''))
      reader.onerror = () => reject(new Error('预览生成失败'))
      reader.readAsDataURL(outFile)
    })

    return { file: outFile, dataUrl, width: targetW, height: targetH, originalSize, size: outFile.size, compressed: true }
  } finally {
    release()
  }
}

/** 头像预设：256 px、目标 ≤ 60 KB */
export const AVATAR_PRESET: CompressOptions = { maxSide: 256, quality: 0.85, maxBytes: 60 * 1024, keepAlpha: true }

/** 商品图预设：1200 px 长边、目标 ≤ 300 KB */
export const PRODUCT_PRESET: CompressOptions = { maxSide: 1200, quality: 0.85, maxBytes: 300 * 1024, keepAlpha: false }

/** 把字节数格式化成易读文本：244 KB / 1.2 MB */
export function formatBytes(bytes: number): string {
  if (!bytes || bytes < 0) return '0 KB'
  if (bytes < 1024) return `${bytes} B`
  if (bytes < 1024 * 1024) return `${Math.round(bytes / 1024)} KB`
  return `${(bytes / 1024 / 1024).toFixed(1)} MB`
}
