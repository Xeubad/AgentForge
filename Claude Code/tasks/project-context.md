# 项目上下文

> **用途**：存储当前项目的**轻量**持久化信息，让 Claude 每次新会话不用重新问基础问题。
> **位置**：每个部署了本配置的项目根目录 `tasks/project-context.md`。
> **生命周期**：跨会话持久化，直到你主动修改。
> **写入时机**：开局问卷首次填写 / 项目技术栈或规范发生变化时更新。
>
> **重要**：本文件是**轻量问卷**，只回答「用什么技术、什么阶段、什么规范」。
> 如果项目规模较大（500 行以上、多模块、多技术栈），推荐同时维护项目根目录的 `PROJECT_STRUCTURE.md`（完整架构快照）。
>
> **AI 读取优先级**：
> 1. `PROJECT_STRUCTURE.md`（项目根，权威架构快照）存在 → 优先读它
> 2. 否则读本文件（轻量上下文）
> 3. 都不存在 → 走完整开局问卷
>
> **两者可共存**：`PROJECT_STRUCTURE.md` 记「怎么写代码」，本文件记「用什么技术 + 团队偏好」。

---

## 项目基本信息

<!-- 开局问卷首次填写时由 Claude 协助写入，之后由你维护 -->

**项目类型**：（Web 应用 / API 服务 / 脚本工具 / CLI 工具 / 配置管理 / 混合 / 其他）
<!-- 示例：Web 应用 -->

**项目名称**：（仓库名或项目代号）
<!-- 示例：my-admin-dashboard -->

**简要描述**：（一句话说明这个项目做什么）
<!-- 示例：内部运营后台，管理用户、订单和数据报表 -->

---

## 技术栈

<!-- 填你实际用的，没有的留空。技术栈变化时更新这里。 -->

**主要语言**：
<!-- 示例：TypeScript -->

**前端框架**：（React / Vue / Next.js / Nuxt / 无 / 其他）
<!-- 示例：React 18 + Next.js 14 -->

**后端框架**：（Express / Fastify / NestJS / Django / FastAPI / Go gin / 无 / 其他）
<!-- 示例：NestJS -->

**数据库**：（PostgreSQL / MySQL / MongoDB / Redis / 无 / 其他）
<!-- 示例：PostgreSQL + Redis -->

**构建工具**：（Vite / Webpack / esbuild / 无 / 其他）
<!-- 示例：Vite -->

**包管理器**：（npm / pnpm / yarn / pip / go mod / 其他）
<!-- 示例：pnpm -->

**部署方式**：（Docker / Vercel / AWS / 自建服务器 / 其他）
<!-- 示例：Docker + GitHub Actions → AWS ECS -->

**其他关键依赖**：（ORM、状态管理、UI 库、测试框架等）
<!-- 示例：Prisma / Zustand / Ant Design / Vitest -->

---

## 当前阶段

<!-- 项目所处阶段，影响 Claude 的建议方向和审查深度。阶段变化时更新。 -->

**阶段**：（初期搭建 / 功能开发 / Bug 修复 / 上线前检查 / 运维迭代 / 重构 / 其他）
<!-- 示例：功能开发 -->

**备注**：（可选，补充阶段相关信息）
<!-- 示例：核心功能已上线，当前在做报表模块 -->

---

## 团队规范

<!-- 你团队或个人的编码规范、风格偏好、禁止事项。规范变化时更新。 -->

**编码风格**：（如：严格 TypeScript / ESLint Airbnb / Prettier 默认配置 / 其他）
<!-- 示例：TypeScript strict + ESLint recommended + Prettier 默认 -->

**命名规范**：（如：camelCase / snake_case / 组件 PascalCase / 常量 UPPER_SNAKE 等）
<!-- 示例：变量 camelCase / 组件 PascalCase / 常量 UPPER_SNAKE / 文件 kebab-case -->

**Git 规范**：（如：Conventional Commits / 分支命名 / PR 模板等）
<!-- 示例：Conventional Commits (feat/fix/chore) / 分支 feature/* 和 fix/* -->

**禁止事项**：（绝对不允许的做法）
<!-- 示例：不用 any / 不直接操作 DOM / 不在组件里写内联样式 / 不用 console.log 留在生产代码 -->

**审查标准**：（代码审查时重点关注什么）
<!-- 示例：正确性 > 安全性 > 可维护性 > 性能 > 风格 -->

**其他偏好**：（可选）
<!-- 示例：优先函数式写法 / 偏好组合而非继承 / 测试覆盖率要求 80%+ -->

---

## 维护说明

- **谁写**：首次由 Claude 开局问卷协助填写，之后由你手动维护
- **何时更新**：技术栈变化 / 阶段变化 / 规范变化时
- **何时删除**：项目废弃时清空内容或删除文件
- **与 session-handoff.md 的分工**：本文件记「项目是什么」，session-handoff 记「做到哪了」
- **与 PROJECT_STRUCTURE.md 的分工**：
  - 本文件（`project-context.md`）：轻量问卷答案，回答「用什么技术 + 团队偏好」
  - `PROJECT_STRUCTURE.md`（项目根）：完整架构快照，回答「在这个项目里具体怎么写代码」（含路由表、API 表、Handler 模板、设计决策等）
  - 小项目只用本文件；中大型项目建议同时维护 `PROJECT_STRUCTURE.md`（用 `/generate-project-structure` 生成）
