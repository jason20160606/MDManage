# MDManage（前端）

订单管理系统的前端工程：Vue 3 + TypeScript + Vite + Element Plus + Pinia。

> 项目总览、启动方式与完整文档索引见仓库根目录 [`../README.md`](../README.md)。
> 前端详细说明见 [`../docs/02-前端说明.md`](../docs/02-前端说明.md)。

## 常用命令

```bash
npm install
npm run dev          # http://localhost:5173，/api 代理到 http://localhost:5161
npm run build        # vue-tsc -b + vite build
npm run build:pro    # 生产环境构建
```

## 目录速览

| 目录 | 内容 |
| --- | --- |
| `src/api/` | 按业务域划分的请求函数 |
| `src/router/` | 常量 / 异步 / 任意路由，异步路由按权限码过滤 |
| `src/views/` | 页面（组织、商品、订单、发货、库存、财务、大屏…） |
| `src/utils/` | `request.ts`（统一响应解包）、`decimal.ts`、`image.ts`、`exportOrders.ts` 等 |
| `src/store/` | Pinia 模块：user / setting / category |

## 两点提醒

- 所有接口经 `src/utils/request.ts`：成功直接拿到 `Data`，失败 `reject` 整个信封；不要再写 `res.data` / `X-Pagination`。
- `src/views/stock/backstage/` 是**纯前端**工具，余量存浏览器 `localStorage`，与数据库库存无关；离线单文件版在 [`../tools/后台库存计算.html`](../tools/后台库存计算.html)，两处算法需同步维护。

本目录自身是独立 git 仓库，提交代码时注意所在仓库。
