# Session Handoff

## 当前已验证

- 当前目录是从 Claude Code 配置复制出的 Codex 迁移副本。
- 官方 Codex 配置入口是 `AGENTS.md` 和 `.codex/config.toml`。
- 自定义 Codex agent 应放在 `.codex/agents/*.toml`，每个文件定义一个 agent。
- `.codex/config.toml`、`.codex/agents/*.toml` 和 `tasks/feature-list.json` 已通过语法校验。

## 本轮改动

- 重写 `AGENTS.md` 为 Codex 项目级高效开发规则。
- 新增 `GLOBAL-AGENTS.md`，作为 `~/.codex/AGENTS.md` 的全局模板。
- 新增 `.codex/config.toml`，包含模型、审批、沙箱、web search、features 和 subagent 限制。
- 新增 `.codex/agents/rin.toml`、`haru.toml`、`en.toml`、`yuzu.toml`、`aura.toml`、`kurohomura.toml`。
- 新增 `.codex/README.md`，说明 Codex 文件职责。
- 删除旧 Claude 迁移文件和无关残留：`CLAUDE.md`、`GLOBAL-CLAUDE.md`、`README.md`、`.claude/`、`agents/`、`tasks/todo.md`、`tasks/lessons.md`。
- 新增 `README.md`，作为人读的 Codex 高效率配置指南，覆盖安装方式、文件职责、agent 速查、工作流和瘦身原则。

## 仍损坏或未验证

- 当前目录不是 Git 仓库，无法提交。
- 标准启动路径和标准验证路径尚未定义。
- `.codex/config.toml` 只在可信项目中加载。

## 下一步最佳动作

- 用一次真实 Codex 会话测试 `AGENTS.md` 是否过重。
- 如果实际使用中流程过重，优先瘦身 `AGENTS.md` 或 `tasks/`，不要继续堆规则。

## 命令

- 查看文件：`rg --files`
- 搜索内容：`rg "pattern"`
- Git 状态：`git status --short`
