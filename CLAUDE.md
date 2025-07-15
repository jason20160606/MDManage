# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Vue 3 + TypeScript order management system with inventory tracking, built using Vite and Element Plus. It's a dealer inventory management system for managing product stock and order operations with special product handling logic for various product types.

## Build Commands

- `npm run dev` - Start development server with automatic browser opening
- `npm run build` - Build for production (with TypeScript checking)
- `npm run build:test` - Build for test environment (TypeScript check only, no emit)
- `npm run build:pro` - Build for production environment (TypeScript check only, no emit)
- `npm run preview` - Preview production build

Note: The project uses pnpm as package manager (pnpm-lock.yaml exists), but npm commands are configured in package.json.

## Code Quality Commands

- ESLint configuration exists in `eslint.config.js` with TypeScript and Vue support
- No specific lint/typecheck scripts defined - TypeScript checking is integrated into build process via `vue-tsc -b`

## Project Architecture

### Technology Stack
- **Frontend**: Vue 3 with Composition API (`<script setup>`)
- **Language**: TypeScript
- **Build Tool**: Vite
- **UI Framework**: Element Plus
- **State Management**: Pinia
- **Routing**: Vue Router
- **HTTP Client**: Axios
- **Charts**: ECharts/vue-echarts
- **Styling**: SCSS with global variables

### Key Directory Structure

```
src/
├── api/                    # API layer organized by business modules
│   ├── user/, order/, product/, shipping/, etc.
│   └── Each module has index.ts (API functions) and type.ts (TypeScript interfaces)
├── components/             # Reusable components
│   ├── Category/, Pagination/, SvgIcon/
│   └── screen/            # Data screen components
├── layout/                # Application layout components
│   ├── index.vue          # Main layout wrapper
│   ├── logo/, main/, menu/, tabbar/
├── router/                # Routing configuration
│   ├── index.ts           # Main router setup
│   ├── routes/            # Route modules (datascreen.ts, freight.ts, etc.)
│   └── types.ts           # Route type definitions
├── store/                 # Pinia state management
│   └── modules/           # Store modules (user.ts, category.ts, setting.ts)
├── utils/                 # Utility functions
│   ├── request.ts         # Axios configuration
│   ├── token.ts, time.ts, pagination.ts
├── views/                 # Page components organized by feature
│   ├── order/             # Order management (create, waiting, shipped, etc.)
│   ├── product/           # Product management (category, attr, spu, sku)
│   ├── stock/             # Inventory management (factory, dealer, backstage)
│   ├── screen/            # Data visualization dashboard
│   └── Various business modules
└── styles/                # Global styles and SCSS variables
```

### Architecture Patterns

1. **Module-based API Organization**: APIs are organized by business domain (user, order, product, etc.) with dedicated type definitions
2. **Feature-based View Structure**: Views are organized by business features rather than technical concerns
3. **Centralized State Management**: Pinia stores are modularized by feature
4. **Component Composition**: Reusable components are extracted to the components directory
5. **Route Module Pattern**: Routes are split into modules matching the feature structure

### Special Business Logic

The system handles special inventory calculation logic for different product types:
- **Family Sets**: Combined calculation with special deduction ratios
- **Detergent (Box)**: Custom postage handling
- **3-Pack Products**: 3:1 inventory deduction ratio
- **Face Towels**: Similar to 3-pack with additional price difference calculations

### Configuration

- **Vite Config**: Includes SVG icons plugin, mock server, SCSS global variables, and proxy configuration
- **Path Aliases**: `@` alias points to `src/` directory
- **Environment Variables**: Different environments (development, test, production) supported
- **ESLint**: Configured with TypeScript and Vue support

### Development Constraints

From `前端开发约束.md`:
1. Before developing new features: review existing file structure, reference similar implementations, create file list with explanations
2. During development: show file structure, explain naming rationale, explain code organization
3. After development: verify file locations, naming conventions, and code organization

## Key Technical Decisions

1. **Vue 3 Composition API**: Uses `<script setup>` syntax throughout
2. **TypeScript First**: Comprehensive type definitions for APIs and components
3. **Modular Architecture**: Clear separation between API, components, views, and business logic
4. **SCSS with Variables**: Global SCSS variables for consistent styling
5. **Mock Integration**: Built-in mock server for development

## Development Workflow

1. The project follows a structured development approach with documentation for constraints and development processes
2. Features are organized by business domain rather than technical layers
3. Each API module includes both implementation and type definitions
4. Components are designed for reusability across different views
5. The routing system supports dynamic route generation based on permissions

## Important Files to Reference

- `前端开发文档.md` - Comprehensive frontend development guide
- `前端开发约束.md` - Development constraints and workflow
- `src/router/types.ts` - Route type definitions
- `src/utils/request.ts` - HTTP request configuration
- `src/setting.ts` - Project configuration settings