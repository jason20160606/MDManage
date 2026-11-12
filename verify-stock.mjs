import { chromium } from '@playwright/test'

const base = 'http://localhost:5173'
const out = 'D:/MyProject/NewOrderSystem/.tmp'

const browser = await chromium.launch({ channel: 'chrome', headless: true, args: ['--no-proxy-server'] })
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } })

await page.goto(`${base}/#/login`, { waitUntil: 'networkidle' })
await page.fill('input[placeholder="请输入用户名"]', 'admin')
await page.fill('input[placeholder="请输入密码"]', '920824')
await page.locator('button', { hasText: /登\s*录/ }).first().click()
await page.waitForTimeout(4000)

await page.goto(`${base}/#/stock/factory`, { waitUntil: 'networkidle' })
await page.waitForTimeout(2500)

// 搜索抗皱面膜
const search = page.locator('input[placeholder*="商品"], input[placeholder*="名称"], input[placeholder*="产品"]').first()
console.log('search placeholder', await search.getAttribute('placeholder').catch(() => 'none'))
await search.fill('抗皱面膜')
await page.getByRole('button', { name: '查询' }).click()
await page.waitForTimeout(2000)
const rows = page.locator('.el-table__body-wrapper tbody tr')
console.log('rows after search', await rows.count(), (await rows.first().innerText()).replace(/\n/g, ' | '))
await page.getByRole('button', { name: '库存记录' }).first().click()
await page.waitForTimeout(2500)
await page.screenshot({ path: `${out}/i3-factory-record2.png`, fullPage: true })
console.log('记录行数', await page.locator('.el-table__body-wrapper tbody tr').count())
await browser.close()
