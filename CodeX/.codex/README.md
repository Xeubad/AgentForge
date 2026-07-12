# Codex 配置说明

## 关键文件

- `AGENTS.md`：Codex 项目级主规则，最重要。
- `.codex/config.toml`：项目级 Codex 配置，仅在可信项目中加载。
- `.codex/agents/*.toml`：可通过子代理工作流使用的自定义 agent。
- `GLOBAL-AGENTS.md`：建议复制到 `~/.codex/AGENTS.md` 的全局模板。
- `tasks/`：运行态进度、功能状态、交接摘要和质量快照。
