# Cursor 高效开发规则

本目录用于沉淀 Cursor 项目开发规则。当前推荐使用 `.cursor/rules/*.mdc` 分层架构，旧版 `.cursorrules` 仅作兼容入口。

## 当前文件结构

```text
.cursor/
  rules/
    00-agent-workflow.mdc      # 始终生效：工作流、安全、上下文、输出
    10-frontend-react.mdc      # 前端文件生效：React/TS/UI 规则（globs 命中 *.tsx/*.jsx/*.ts/*.js/*.css 等）
    20-backend-node.mdc        # 后端文件生效：Node/API/数据库规则（globs 命中 server/**/backend/** 等）
    90-quality-gate.mdc        # 始终生效：验证、收尾、评估
.cursorignore                  # 控制 Cursor 索引和 AI 可访问文件
.cursorrules                   # ⚠️ 旧版兼容入口，新规则不要堆进这里
```

## 分层规则说明

| 文件 | alwaysApply | globs | 职责 |
|---|---|---|---|
| `00-agent-workflow.mdc` | ✅ | 无 | 全局行为：开工流程、执行纪律、代码生成约束、用户澄清条件 |
| `10-frontend-react.mdc` | ❌ | `**/*.tsx` `**/*.jsx` `**/*.ts` `**/*.js` `**/*.css` 等 | React/TS 组件、UI 设计、a11y、性能 |
| `20-backend-node.mdc` | ❌ | `**/server/**` `**/backend/**` `**/api/**` `**/routes/**` 等 | 架构边界、输入输出、数据安全、异步错误处理 |
| `90-quality-gate.mdc` | ✅ | 无 | 完成定义、验证顺序、收尾输出、评估结论 |

## 部署方式

1. 把 `.cursor/rules/` 目录复制到目标项目根目录。
2. 把 `.cursorignore` 复制到目标项目根目录，按项目实际情况调整排除规则。
3. 在 Cursor Settings → User Rules 保留个人轻量偏好（如"默认中文、少废话、先给结论"）。
4. 项目约束全部放入 `.cursor/rules/`，不依赖聊天历史。

## 核心策略

- **规则分层**：全局行为放 `alwaysApply: true`，技术栈规则用 `globs` 精准命中文件。
- **少而硬**：规则只写会影响结果质量的约束，不写泛泛审美口号。
- **先读后改**：修改前必须搜索并读取相关文件，复用已有组件、工具函数、类型和配置。
- **先查后用**：涉及外部库、框架能力、Cursor 配置或第三方 API，不猜；优先查官方文档。
- **最小闭环**：一次只推进一个明确目标，做最小但完整的改动。
- **验证优先**：能运行测试、类型检查、lint 或启动检查就运行；不能验证要说明原因和风险。
- **中文协作**：默认中文输出；代码标识符保持英文；注释只在必要时添加。

## 大型任务流程

1. 先让 Cursor 输出"冲刺合同"：目标、范围、排除项、验收标准、验证方式、风险。
2. 让 Cursor 修改前先执行代码库搜索，修改后给出验证命令和结果。
3. 非琐碎任务完成后，让 Cursor 给出评估结论：`Accept` / `Revise` / `Block`。

## 不建议迁移的旧规则

- "改完即退""用户会手动测试"：会破坏验证闭环。
- "自动生成 README"：不是每个开发任务都需要文档，容易扩大范围。
- 固定技术栈写死在全局规则：应放到按路径触发的规则里。
- 要求输出完整文件结构和完整代码：在真实项目中会增加噪音，Cursor 应直接改文件。

## 添加新规则

如果需要添加新的技术栈规则（如 Python、Go、Rust），按以下格式创建新文件：

```markdown
---
description: 简短描述这条规则的职责
globs:
  - "**/*.py"
  - "**/scripts/**"
alwaysApply: false
---

# 规则标题

## 段落 1
- 规则内容
```

- 文件名格式：`<优先级数字>-<简短名称>.mdc`（如 `30-python-scripts.mdc`）
- `alwaysApply: true` 用于全局行为，`false` 用于按文件路径触发
- `globs` 写要命中的文件路径模式
- `description` 写一句话描述，会显示在 Cursor 的规则列表里

## 完成判定

使用 `Accept / Revise / Block`：

- `Accept`：代码实现、验证证据、系统行为三层都满足。
- `Revise`：方向正确，但有未完成项、未覆盖边界或验证不足。
- `Block`：需求不清、基础启动失败、关键依赖未知、风险不可控。
