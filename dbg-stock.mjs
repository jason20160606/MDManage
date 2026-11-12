import { chromium } from '@playwright/test'

const base = 'http://localhost:5173'
const out = 'D:/MyProject/NewOrderSystem/.tmp'

const browser = await chromium.launch({ channel: 'chrome', headless: true, args: ['--no-proxy-server'] })
const page = await browser.newPage({ viewport: { width: 1440, height: 900 } })
page.on('request', r => { if (r.url().includes('FactoryStockLog')) console.log('[req]', r.url()) })
page.on('response', async r => {
  if (r.url().includes('FactoryStockLog')) {
    const body = await r.text().catch(() => '')
    console.log('[resp]', r.status(), body.slice(0, 160))
  }
})
page.on('console', m => console.log('[console]', m.type(), m.text().slice(0, 200)))

await page.goto(`${base}/#/login`, { waitUntil: 'networkidle' })
await page.fill('input[placeholder="请输入用户名"]', 'admin')
await page.fill('input[placeholder="请输入密码"]', '920824')
await page.locator('button', { hasText: /登\s*录/ }).first().click()
await page.waitForTimeout(4000)

await page.goto(`${base}/#/stock/factory`, { waitUntil: 'networkidle' })
await page.waitForTimeout(2500)
const search = page.locator('input[placeholder="请输入产品名称"]').first()
await search.fill('抗皱面膜')
await page.getByRole('button', { name: '查询' }).click()
await page.waitForTimeout(1500)
await page.getByRole('button', { name: '库存记录' }).first().click()
await page.waitForTimeout(3000)
await browser.close()
