# Generate Project Structure

用于扫描项目代码后自动生成 `PROJECT_STRUCTURE.md` 初稿。

## 使用场景

- 首次为一个已有项目生成架构快照
- 项目结构大改后重新生成基线版本
- 接手陌生项目时快速建立心智模型

## 步骤

### 1. 侦察阶段（只读）

按以下顺序扫描项目：

1. **根目录扫描**：`README.md`、`package.json` / `go.mod` / `pyproject.toml` / `Cargo.toml` / `pom.xml`、`.gitignore`、`docker-compose.yml`、`Dockerfile`
2. **入口文件**：`main.go` / `main.py` / `index.ts` / `app.py` / `server.js`
3. **目录结构**：`ls -R`（或等效），忽略 `node_modules` / `.git` / `dist` / `build` / `vendor`
4. **路由 / API 定义**：搜索 `HandleFunc` / `router.` / `@app.route` / `@Get` / `@Post` / `express()`
5. **数据模型**：搜索 `CREATE TABLE` / `Model` / `Entity` / `Schema` / `migration`
6. **静态资源 / 前端**：`static/` / `public/` / `src/` / `components/`
7. **环境变量**：搜索 `os.Getenv` / `process.env` / `os.environ`
8. **构建脚本**：`Makefile` / `package.json scripts` / `justfile`

### 2. 结构判断

根据代码规模决定填写深度：

- **小项目（< 500 行 / 单文件）**：只填第 1、2、3、10 段；建议改用 `tasks/project-context.md`
- **中等项目（500-5000 行）**：填第 1-6、8、10 段
- **大项目（> 5000 行）**：全部 10 段

### 3. 生成初稿

- 使用仓库根目录下 `PROJECT_STRUCTURE.md` 模板作为骨架
- **只写实际存在的东西**——没有的段留空并加注释 `<!-- 本项目无此内容 -->`
- 表格类内容（API 表 / 表清单 / CSS 变量 / 路由表）**必须逐一核对代码**，不能编造
- 关键设计决策段（第 10 段）只写能从代码 / commit / README 找到证据的决策，找不到的写 `<!-- 待用户补充 -->`
- 目录结构（第 3 段）用实际 `ls` 输出精简，不列 node_modules 等构建产物

### 4. 用户审核

- 生成完成后**必须让用户逐段审核**，不能直接落盘
- 逐段问：「第 X 段是否准确？」「有没有遗漏的表 / 接口 / 决策？」
- 用户确认后再写入 `PROJECT_STRUCTURE.md`
- 用户否决的段，标记 `<!-- 待用户补充 -->` 留空

### 5. 收尾

- 写入 `PROJECT_STRUCTURE.md` 到项目根目录（不是 `tasks/`）
- 在 `tasks/session-handoff.md` 记录「本轮生成了 PROJECT_STRUCTURE.md 初稿」
- 提示用户「后续架构变更可用 `/update-project-structure` 同步」

## 输出

- 生成的 `PROJECT_STRUCTURE.md` 文件路径
- 填写了哪些段、留空了哪些段
- 需要用户补充的问题清单

## 硬约束

- 不编造表 / 接口 / 组件——找不到证据的一律留空
- 不猜设计决策的「原因」——找不到证据的写 `<!-- 待用户补充 -->`
- 不改动项目源码——本命令只读
- 不覆盖已有 `PROJECT_STRUCTURE.md`——如果存在，先问用户是「重建」还是「用 `/update-project-structure`」
