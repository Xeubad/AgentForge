# Codex 高效率配置指南

这个目录是一套面向 Codex 的高效率开发配置模板。目标不是堆 prompt，而是把 Codex 的工作方式稳定成几个可复用机制：清晰入口、可信配置、可选子代理、运行态记录和验证闭环。

## 核心结构

```text
CodeX/
├─ AGENTS.md
├─ GLOBAL-AGENTS.md
├─ .codex/
│  ├─ config.toml
│  ├─ README.md
│  └─ agents/
│     ├─ rin.toml
│     ├─ haru.toml
│     ├─ en.toml
│     ├─ yuzu.toml
│     ├─ aura.toml
│     └─ kurohomura.toml
├─ memory/
│  └─ lessons.md
└─ tasks/
   ├─ feature-list.json
   ├─ progress.md
   ├─ quality.md
   └─ session-handoff.md
```

一句话理解：

- `AGENTS.md` 是项目级主规则。
- `GLOBAL-AGENTS.md` 是全局 `~/.codex/AGENTS.md` 模板。
- `.codex/config.toml` 是项目级 Codex 配置。
- `.codex/agents/*.toml` 是自定义子代理。
- `tasks/` 记录跨会话运行状态。
- `memory/` 记录长期可复用经验。

## 推荐安装方式

### 1. 全局规则

把 `GLOBAL-AGENTS.md` 的内容复制到：

```text
~/.codex/AGENTS.md
```

它负责跨项目通用习惯，例如中文输出、先读再改、验证优先、一次只推进一个功能、证据完成定义。

### 2. 项目规则

把 `AGENTS.md` 放到目标项目根目录。

Codex 会读取项目内的 `AGENTS.md` 作为项目级指令。子目录如果有自己的 `AGENTS.md`，更靠近当前工作目录的规则优先。

### 3. 项目配置

把 `.codex/config.toml` 放到目标项目根目录的 `.codex/` 下。

注意：项目级 `.codex/config.toml` 只会在可信项目中加载。第一次使用时，需要确认该项目是可信的。

### 4. 自定义 agent

把 `.codex/agents/*.toml` 放到项目级：

```text
your-project/.codex/agents/
```

或者放到全局：

```text
~/.codex/agents/
```

项目级适合当前仓库专用 agent，全局适合跨项目复用 agent。

## Agent 速查

| Agent | 用途 |
| --- | --- |
| `rin` | 默认高信噪比工程师，适合直接结论、根因定位、代码审查 |
| `haru` | 讲解型工程师，适合原理解释、架构取舍、教学式分析 |
| `en` | 严格审查工程师，适合 code review、上线前复核、高风险方案质疑 |
| `yuzu` | 推进型工程师，适合排障、卡住时拆步骤、恢复节奏 |
| `aura` | 重构与一致性工程师，适合命名、结构、前端观感和维护性整理 |
| `kurohomura` | 趣味化排障工程师，适合枯燥清理、复杂问题记忆点强化 |

这些 agent 只影响协作风格和任务分工，不覆盖安全、正确性和验证要求。

## 高效工作流

### 开工

1. 读取 `AGENTS.md`。
2. 读取 `tasks/progress.md`、`tasks/feature-list.json`、`tasks/session-handoff.md`。
3. 确认当前唯一要推进的功能。
4. 写清楚本轮做什么、不做什么、怎么验证。
5. 修改前先读相关代码或配置。

### 执行

- 只做当前功能，不顺手扩展范围。
- 优先最小改动闭环。
- 复用已有实现，不重复造轮子。
- 不猜外部 API、框架能力或 Codex 配置键，必要时查官方文档。

### 验证

- 能跑测试就跑测试。
- 不能验证时，明确说明原因和风险。
- `passing` 必须有证据，不能靠主观判断。
- 完成至少满足：代码实现正确、验证真实运行、用户路径或系统行为合理。

### 收尾

- 更新 `tasks/feature-list.json`。
- 长会话更新 `tasks/session-handoff.md`。
- 重要改动更新 `tasks/quality.md`。
- 清理临时文件、调试代码、无主 TODO。
- 如果不是 Git 仓库，明确说明无法提交。

## 文件维护原则

- 高频硬规则放 `AGENTS.md`。
- 个人长期习惯放 `GLOBAL-AGENTS.md`，再同步到 `~/.codex/AGENTS.md`。
- agent 分工放 `.codex/agents/*.toml`。
- 临时进度放 `tasks/`。
- 长期经验放 `memory/`。
- 不要把同一条规则复制到多个地方反复维护。

## 最小可用组合

如果只想保留最小配置，保留这些就够：

```text
AGENTS.md
.codex/config.toml
.codex/agents/rin.toml
GLOBAL-AGENTS.md
```

如果你做的是长会话、多功能或多人/多 agent 协作，再启用 `tasks/`。

## 后续校准

这套配置不应该无限变厚。每隔一段时间做一次检查：

- 哪些规则真的减少了返工？
- 哪些 tasks 文件从来不用？
- 哪些 agent 没有明显价值？
- `AGENTS.md` 是否已经太长？
- 是否可以删掉一层流程而不降低质量？

原则很简单：能提升稳定性的留下，只制造负担的删掉。
