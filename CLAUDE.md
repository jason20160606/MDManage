# CLAUDE.md

Guidance for AI coding assistants working in this repository.

## Project

Frontend of an order / inventory management system (Vue 3 + TypeScript + Vite + Element Plus + Pinia + Vue Router in hash mode + Axios). It talks to the .NET 9 API in `../NET9CoreWebApi/` via the `/api` proxy.

**Read before changing anything:**

- [`../README.md`](../README.md) — project overview, startup, document index
- [`../docs/02-前端说明.md`](../docs/02-前端说明.md) — frontend architecture, routes, request contract, page list
- [`../docs/04-接口与数据字典.md`](../docs/04-接口与数据字典.md) — response envelope, pagination, status dictionaries
- [`../docs/07-开发规范.md`](../docs/07-开发规范.md) — coding conventions, checklists, verification
- [`../docs/01-系统架构与业务口径.md`](../docs/01-系统架构与业务口径.md) — business rules (fees, order state machine, inventory)

These replace the older per-folder development documents, which were removed in the 2026-11 documentation baseline cleanup.

## Commands

```bash
npm install
npm run dev          # dev server on 5173
npm run build        # vue-tsc -b && vite build
npm run build:pro    # production build
npm run preview
```

`package.json` uses npm scripts while the lockfile is `pnpm-lock.yaml`.

## Key conventions

- All HTTP calls go through `src/utils/request.ts`: success resolves to `Data`, failures reject the whole envelope `{ Code, Success, Message, Data, TraceId }`. Use `getList` / `getTotal` / `showError`; never `res.data` or `X-Pagination` headers.
- Backend fields are PascalCase. Pagination params: `PageNumber` / `PageSize`.
- Routes: `src/router/routes.ts` (constant / async / any), modules in `src/router/routers/`. `meta.roles` must match `permissions.Code`; add the matching backend mapping in `PagePermissionMap.cs` for new endpoints.
- Uploads must use `el-upload` `:http-request` with Axios (a bare `action` XHR has no token). Compress images via `src/utils/image.ts` first.
- `src/views/stock/backstage/` is a standalone local-only tool: leftover quantities live in `localStorage` (`backstage_stock_v1`), not in the database. The algorithm is duplicated in `../tools/后台库存计算.html`; keep both in sync and preserve the exact output text.

## Workflow expected by the maintainer

Before implementing a new feature, list the files to create/modify with their purpose and wait for confirmation; explain naming and organization during implementation; verify file locations, conventions and the build before handing off. See `../docs/07-开发规范.md`.
