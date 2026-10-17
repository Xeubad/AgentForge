# Pi Agent 模板

这是一个可复制的 Pi Agent 工作模板。它把长期规则、角色提示、任务状态、记忆和工具配置分开存放。

## 目录

```text
PiAgent/
├── AGENTS.md                    # 项目级执行规则
├── settings.example.json        # Pi 设置占位模板
├── mcp.json.example              # MCP 配置占位模板
├── subagents.config.example.json # pi-subagents 全局配置模板
├── agents/                      # 子代理角色提示
│   ├── scout.md
│   ├── planner.md
│   ├── worker.md
│   ├── reviewer.md
│   └── oracle.md
├── prompts/
│   └── forge-task.md            # /forge-task 工作流提示
├── tasks/
│   ├── TASK-TEMPLATE.md         # 单任务模板
│   └── handoff.md               # 跨会话交接模板
└── memory/
    ├── USER.md                  # 用户确认的长期偏好
    ├── facts.md                 # 有来源的事实
    └── lessons.md               # 可复用经验
```

## 使用

1. 将 `AGENTS.md` 复制到目标项目根目录。
2. 安装 `pi-subagents` 后，优先使用它的内置角色；仅将自定义 `agents/planner.md` 复制到 `~/.pi/agent/agents/`。
3. 将 `settings.example.json` 与现有 `~/.pi/agent/settings.json` 合并，不要覆盖已有包和模型设置。
4. 需要 MCP 时，将 `mcp.json.example` 复制为 `.mcp.json`，只启用当前任务需要的服务器。
5. 将 `subagents.config.example.json` 复制到 `~/.pi/agent/extensions/subagent/config.json`。
6. 将 `prompts/forge-task.md` 复制到 `~/.pi/agent/prompts/`，通过 `/forge-task` 使用。
7. 新任务从 `tasks/TASK-TEMPLATE.md` 开始；跨会话前更新 `tasks/handoff.md`。
8. 只把用户明确确认的长期偏好和事实写入 `memory/`。

## 推荐工作流

```text
clarify → scout → plan → worker → reviewer → validate → handoff
```

复杂任务使用 2–3 个并行 worker；同一文件默认只允许一个写者。审查最多循环 3 次，仍未通过就停下并记录风险。

## 可选扩展

按需安装，不要一次启用全部扩展：

- `pi-tool-display`：折叠工具输出和渲染 diff。
- `pi-powerline-footer`：显示模型、上下文、git、成本和队列。
- `pi-mcp-adapter`：按需发现和启动 MCP 工具。
- `pi-web-access`：搜索、网页抽取和 GitHub 本地克隆。
- `pi-subagents`：scout、worker、reviewer、oracle 等角色。
- `pi-review-loop`：实现后的独立审查循环。
- `pi-rewind-hook`：按会话回滚文件变化。
- `pi-memory-workbench`：持久化 Markdown 记忆。

扩展来源：[`nicobailon`](https://github.com/nicobailon)。具体安装命令和配置键以对应仓库当前 README 为准。

## 开始前填写

- 默认语言：`中文`
- 默认模型：`MODEL_ID`
- 项目验证命令：`TEST_COMMAND`
- 默认输出长度：`短 / 中 / 详细`
- 外部发送策略：`必须确认 / 已授权范围内自动执行`
- 长期记忆范围：`USER_CONFIRMED_FACTS_ONLY`
