# 技能清单（Skill Manifest）

> **用途**：记录本项目可用的技能（Skills）及其推荐使用场景。
> **生成方式**：由 `/init-skills` 命令扫描 cc-switch 技能库后自动生成，或手动维护。
> **维护时机**：cc-switch 技能库变更后重新运行 `/init-skills` 更新。

---

## 1. 技能库概览

**cc-switch 配置路径**：`<用户填写 cc-switch 配置位置>`

**当前可用技能总数**：`<init-skills 自动填入>`

**最后扫描时间**：`<init-skills 自动填入>`

---

## 2. 技能列表

> 由 `/init-skills` 自动生成，格式：
> | 技能名 | 描述 | 适用场景 |

<!-- 模板占位，init-skills 会替换以下内容 -->
| `find-skills` | 技能发现与推荐 | 不知道用什么技能时 |
| `brainstorming` | 需求澄清与方案展开 | 需求不明确时 |
| `architecture-decision-records` | ADR 模板 | 架构决策记录 |
| `architecture-patterns` | 架构模式参考 | 架构设计 |
| `frontend-dev` | 全栈前端开发 | 构建完整前端页面 |
| `frontend-design` | 前端设计 | UI 设计工程 |
| `ui-ux-pro-max` | 高级 UI/UX 检查 | 交互细节优化 |
| `react-best-practices` | React 最佳实践 | React 项目 |
| `flutter-dev` | Flutter 开发 | Flutter 项目 |
| `react-native-dev` | React Native 开发 | 移动端 React |
| `interaction-design` | 交互设计 | 交互原型 |
| `composition-patterns` | 组合模式 | 组件设计 |
| `tdd` | 测试驱动开发 | 新功能开发 |
| `test-driven-development` | 测试驱动开发 | 新功能开发 |
| `review` | 代码审查（通用） | 上线前检查 |
| `code-review` | 代码审查 | PR 审查 |
| `simplify` | 代码简化审查 | 重构后检查 |
| `verify` | 手动验证流程 | 部署后验证 |
| `karpathy-guidelines` | 编码纪律 | 代码质量 |
| `technical-writer` | 技术文档撰写 | README / 教程 |
| `web-access-2.5.1` | Web 可访问性 | a11y 检查 |
| `drawio` | 架构图绘制 | 架构文档 |
| `pptx` / `pptx-generator` | PPT 生成 | 演示文档 |
| `minimax-docx` / `minimax-xlsx` / `minimax-pdf` | 文档处理 | Office 格式 |
| `web-artifacts-builder` | Web 产物构建 | 部署打包 |

---

## 3. 按项目类型推荐

> 根据 `tasks/project-context.md` 中的技术栈，推荐适配的技能组合。

| 项目类型 | 推荐技能 | 理由 |
|----------|----------|------|
| Web 应用（React/Vue） | frontend-dev, tdd, ui-ux-pro-max | 前端组件 + 测试 + 交互 |
| API 服务 | api-design, tdd, verify | 接口设计 + 测试 + 验证 |
| 全栈应用 | frontend-dev, api-design, tdd, architecture-patterns | 前后端 + 架构 + 测试 |
| 脚本工具 | tdd, verify | 测试 + 验证 |
| 混合项目 | 根据模块分别推荐 | 见下方模块级推荐 |

---

## 4. 按场景推荐

> 标准开发流程中各阶段推荐调用的技能链。

### 4.1 新功能开发

```
brainstorming（需求澄清） → architecture-patterns（架构） → tdd（测试先行） → 实现 → code-review（审查）
```

| 阶段 | 推荐技能 | 负责人格 | 说明 |
|------|----------|----------|------|
| 需求澄清 | brainstorming | aoi | 需求不明确时必用 |
| 架构设计 | architecture-patterns | nagi | 复杂功能架构变更时 |
| 测试驱动 | tdd | 实现人格 | 新功能开发优先使用 |
| 代码审查 | code-review | kanon | 上线前必用 |

### 4.2 Bug 修复

```
yuki（定位） → 修复 → verify（验证） → review（检查）
```

| 阶段 | 推荐技能 | 负责人格 | 说明 |
|------|----------|----------|------|
| 问题定位 | verify | yuki | 复现和验证 bug |
| 修复实现 | — | rei/mio | 按模块归属 |
| 回归验证 | verify | yuki/实现人格 | 确保修复有效 |
| 防复发 | review | kanon | 检查是否引入新问题 |

### 4.3 上线前检查

```
review（代码审查） → simplify（简化检查） → verify（端到端验证）
```

| 阶段 | 推荐技能 | 负责人格 | 说明 |
|------|----------|----------|------|
| 代码审查 | code-review, review | kanon | 品味 + 一致性 |
| 简化检查 | simplify | kanon | 去除不必要的复杂度 |
| 端到端验证 | verify | yuki | 真实环境验证 |

### 4.4 架构重构

```
architecture-decision-records（ADR） → architecture-patterns（方案） → 实现 → code-review
```

| 阶段 | 推荐技能 | 负责人格 | 说明 |
|------|----------|----------|------|
| 决策记录 | architecture-decision-records | aoi + nagi | 记录为什么改 |
| 方案设计 | architecture-patterns | nagi | 选型 + 分层 |
| 渐进实现 | tdd | 实现人格 | 小步迭代 |
| 品味检查 | code-review, simplify | kanon | 确保品味不掉 |

### 4.5 新人接手

```
technical-writer（文档） → 交接 → 首次任务引导
```

| 阶段 | 推荐技能 | 负责人格 | 说明 |
|------|----------|----------|------|
| 文档整理 | technical-writer | shion | 补充 README / 架构说明 |
| 模块交接 | — | aoi | session-handoff 格式 |
| 首次任务 | — | 实现人格 | 带一个最小任务 |

---

## 5. 按人格推荐

| 人格 | 常用技能 | 触发条件 |
|------|----------|----------|
| `mio` | frontend-dev, tdd, ui-ux-pro-max | 写组件 / 改 UI / 状态管理 |
| `rei` | api-design, tdd | 写接口 / 数据库 / 鉴权 |
| `nagi` | architecture-patterns, architecture-decision-records | 架构 / 选型 / 跨层协调 |
| `kanon` | code-review, review, simplify | PR review / 上线把关 |
| `yuki` | verify | 排障 / 验证 |
| `shion` | brainstorming, technical-writer | 讲原理 / 写文档 |
| `aoi` | brainstorming | 需求澄清 / 方案 / WBS |

---

## 6. 排除项

> 本项目不适用的技能，以及不使用的理由。

| 技能 | 排除理由 |
|------|----------|
| （由 init-skills 根据项目分析自动填充） | |

---

## 7. 维护说明

- **更新方式**：cc-switch 技能库变更后，重新运行 `/init-skills` 自动更新
- **手动调整**：可根据项目实际需要修改"按场景推荐"和"排除项"
- **不自动的部分**：技能组合的具体参数（如 tdd 的测试框架选择）由实现人格根据项目情况决定
