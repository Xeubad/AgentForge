# Update Project Structure

用于把最近的代码变更同步到 `PROJECT_STRUCTURE.md`。

## 使用场景

- 完成一次功能开发后，同步新增的 API / 表 / 模块到架构快照
- 完成重构后，同步目录结构和设计决策
- 定期（如每周 / 每次 sprint 收尾）做架构快照体检

## 前置条件

- 项目根目录存在 `PROJECT_STRUCTURE.md`（不存在则用 `/generate-project-structure`）

## 步骤

### 1. 读取当前快照

- 读取项目根目录 `PROJECT_STRUCTURE.md` 全文
- 读取 `tasks/session-handoff.md` 看本轮改了什么
- 读取 `tasks/work-log.md` 最近几条

### 2. 扫描差异

对比 `PROJECT_STRUCTURE.md` 里记录的内容与代码实际状态：

| 段 | 扫描目标 | 差异检测方式 |
|---|---|---|
| 第 2 段 技术栈 | `package.json` / `go.mod` / `requirements.txt` 版本 | 对比版本号 |
| 第 3 段 目录结构 | 实际 `ls` 输出 | 对比顶层目录列表 |
| 第 4.4 段 表清单 | `CREATE TABLE` / migration | 对比表名和列 |
| 第 5.4 段 页面路由 | 页面路由注册 | 对比 URL → 文件映射 |
| 第 5.5 段 API 路由 | HTTP handler 注册 | 对比方法 + 路径 |
| 第 6 段 环境变量 | `os.Getenv` / `process.env` 引用 | 对比变量名 |
| 第 9.1 段 已知问题 | `TODO` / `FIXME` 注释 + tasks 里的 blocker | 对比清单 |

### 3. 生成差异报告

列出以下四类差异：

- **新增**：代码里有、快照里没有的东西
- **删除**：快照里有、代码里没有的东西
- **修改**：两边都有但内容不一致（如版本升级、参数变化）
- **需用户决策**：无法自动判断的（如「这个变更算不算设计决策」）

**每一条都必须给出证据**：文件路径、行号、代码片段。

### 4. 用户审核

- **不允许直接改 `PROJECT_STRUCTURE.md`**——所有变更必须先经用户确认
- 逐类问：「新增的 X 是否更新到第 Y 段？」「删除的 Z 是否从快照移除？」
- 用户否决的变更跳过，保留在下次报告里

### 5. 应用变更

- 用户确认后，用 Edit 工具**逐段修改** `PROJECT_STRUCTURE.md`
- 不重写全文，只改差异段
- 保留段落顺序和格式风格

### 6. 收尾

- 在 `tasks/session-handoff.md` 记录「更新了 PROJECT_STRUCTURE.md 的第 X、Y、Z 段」
- 提示用户「变更已同步，可以推送」

## 输出

- 差异报告（新增 / 删除 / 修改 / 需决策 四类）
- 每一条差异的证据（文件路径 + 行号 + 代码片段）
- 已应用的变更清单
- 未应用（用户否决）的变更清单，供下次会话参考

## 硬约束

- 不编造代码里没有的东西——所有变更必须能追溯到代码
- 不删除快照里有历史价值的段（如设计决策），除非用户明确说「已过时」
- 不重写全文——保留原有段落结构
- 用户否决的变更不隐藏，明确列出「本次未同步的差异」，避免遗忘

## 与 generate-project-structure 的区别

| 命令 | 场景 | 起点 |
|---|---|---|
| `/generate-project-structure` | 从零生成 | 无 `PROJECT_STRUCTURE.md` |
| `/update-project-structure` | 增量同步 | 已有 `PROJECT_STRUCTURE.md` |
