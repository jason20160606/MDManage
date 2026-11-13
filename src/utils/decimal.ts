/**
 * 定点十进制 — 用于复现 C# decimal 的计算与输出语义。
 *
 * 后台库存计算的原实现跑在 C# 的 decimal 上，decimal 会把「值」和「小数位数」一起保留：
 *   6 * 18.5 => 111.0（小数点后 1 位，不会变成 111）
 *   5 * 0.44 => 2.20 （小数点后 2 位）
 *   0 * 0.7  => 0.0
 * JS 原生 number 既会丢尾随零，又会引入浮点误差（0.1 * 3 = 0.30000000000000004），
 * 直接算会导致最终文案改变，所以本模块所有运算都在「放大 10^s 倍的整数」上做。
 *
 * 规则对齐 .NET decimal：
 *   - 加减：结果小数位 = 两者较大者
 *   - 乘法：结果小数位 = 两者之和（不做尾零裁剪）
 *   - 取整：floor 向负无穷，trunc 向零
 *   - 取余：截断除（与 C# % 一致，符号随被除数）
 */
const POW10 = [
  1,
  10,
  100,
  1000,
  10000,
  100000,
  1000000,
  10000000,
  100000000,
  1000000000,
  10000000000,
  100000000000,
  1000000000000
]

/** 取 10 的 n 次方；n 超出表范围时退回 Math.pow（本项目不会出现） */
function pow10(n: number): number {
  return n < POW10.length ? POW10[n] : Math.pow(10, n)
}

export class Dec {
  /** 放大后的整数值，真实值 = v / 10^s */
  readonly v: number
  /** 小数位数 */
  readonly s: number

  private constructor(v: number, s: number) {
    this.v = v
    this.s = s
  }

  static of(v: number, s = 0): Dec {
    return new Dec(v, s)
  }

  static zero(): Dec {
    return new Dec(0, 0)
  }

  /** 解析字面量："7.9" => 7.9(1 位)、"0.80" => 0.80(2 位) */
  static parse(raw: string | number | null | undefined): Dec {
    if (raw === null || raw === undefined || raw === '') return new Dec(0, 0)
    const text = String(raw).trim()
    const m = /^(-)?(\d*)(?:\.(\d*))?$/.exec(text)
    if (!m) return new Dec(0, 0)
    const negative = m[1] === '-'
    const intPart = m[2] || '0'
    const fracPart = m[3] || ''
    const digits = (intPart + fracPart).replace(/^0+(?=\d)/, '')
    const v = Number(digits || '0')
    return new Dec(negative ? -v : v, fracPart.length)
  }

  /** 转成指定小数位后的整数值 */
  private scaledTo(s: number): number {
    return s === this.s ? this.v : this.v * pow10(s - this.s)
  }

  add(o: Dec): Dec {
    const s = Math.max(this.s, o.s)
    return new Dec(this.scaledTo(s) + o.scaledTo(s), s)
  }

  sub(o: Dec): Dec {
    const s = Math.max(this.s, o.s)
    return new Dec(this.scaledTo(s) - o.scaledTo(s), s)
  }

  /** 乘法：小数位相加，不裁尾零 */
  mul(o: Dec): Dec {
    return new Dec(this.v * o.v, this.s + o.s)
  }

  cmp(o: Dec): number {
    const s = Math.max(this.s, o.s)
    const a = this.scaledTo(s)
    const b = o.scaledTo(s)
    return a < b ? -1 : a > b ? 1 : 0
  }

  gt(o: Dec): boolean {
    return this.cmp(o) > 0
  }

  lt(o: Dec): boolean {
    return this.cmp(o) < 0
  }

  eq(o: Dec): boolean {
    return this.cmp(o) === 0
  }

  /** 向下取整，返回 0 位小数的 Dec */
  floor(): Dec {
    if (this.s === 0) return this
    return new Dec(Math.floor(this.v / pow10(this.s)), 0)
  }

  /** 向零取整为整数（等价 C# 的 (int) 强转） */
  truncInt(): number {
    return this.s === 0 ? this.v : Math.trunc(this.v / pow10(this.s))
  }

  /** 对整数取余，等价 C# decimal % int（截断除，符号随被除数） */
  modInt(n: number): Dec {
    const p = pow10(this.s)
    const divisor = n * p
    return new Dec(this.v - Math.trunc(this.v / divisor) * divisor, this.s)
  }

  /** 除以整数后向下取整，等价 Math.Floor(dec / n) */
  divFloorInt(n: number): Dec {
    const p = pow10(this.s)
    return new Dec(Math.floor(this.v / (n * p)), 0)
  }

  /** 按原有小数位输出，保留尾随零 */
  toString(): string {
    const negative = this.v < 0
    const abs = Math.abs(this.v)
    if (this.s === 0) return (negative ? '-' : '') + String(abs)
    const digits = String(abs).padStart(this.s + 1, '0')
    const cut = digits.length - this.s
    return (negative ? '-' : '') + digits.slice(0, cut) + '.' + digits.slice(cut)
  }
}

/** 便捷方法，配合 reduce / join 使用 */
