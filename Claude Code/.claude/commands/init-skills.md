# Init Skills

扫描 cc-switch 管理的技能库，分析项目特征，生成 `tasks/skill-manifest.md`。

## 使用场景

- 首次部署模板到新项目时
- cc-switch 技能库变更后更新推荐
- 接手陌生项目时快速了解可用技能

## 前置条件

- cc-switch 已安装，技能库在 `~/.cc-switch/skills/`
- 项目中存在 `tasks/project-context.md`（或可通过 `/start-session` 快速填写）
- 标准启动路径可用（能确认项目类型和 tech stack）

## 步骤

### 1. 读取项目上下文

1. 读取 `tasks/project-context.md`（如果存在）
2. 读取 `package.json` / `go.mod` / `pyproject.toml` 等技术栈标识文件
3. 确认项目类型、技术栈、当前阶段

### 2. 扫描 cc-switch 技能库

**扫描路径**：`~/.cc-switch/skills/<skill-name>/SKILL.md`

**结构说明**：
- 每个技能一个目录，目录名即技能 ID
- `SKILL.md` 头部有 YAML frontmatter，包含 `name`、`description`、`metadata`（可选）
- `metadata` 中可能有 `category`、`tags`、`version`、`sources`

**扫描方法**：

```bash
# 列出所有技能
ls ~/.cc-switch/skills/

# 读取单个技能的 frontmatter
head -20 ~/.cc-switch/skills/<skill-name>/SKILL.md
```

**提取字段**：
- `name`：技能 ID（与目录名一致）
- `description`：技能描述（触发条件和使用场景）
- `metadata.category`（可选）：技能分类
- `metadata.tags`（可选）：标签列表

**输出**：技能列表 `[{id, name, description, category, tags}]`

> **注意**：cc-switch 还有一个 `cc-switch.db`（SQLite），但技能元数据的权威来源是各目录的 `SKILL.md` frontmatter。DB 用于同步和 profile 管理，不直接读取。

### 3. 分析项目-技能匹配度

对每个技能，根据其 `description` 中的触发条件判断与当前项目的相关性：

| 匹配等级 | 说明 | 处理 |
|----------|------|------|
| **核心** | 当前技术栈直接需要 | 标记为推荐 |
| **辅助** | 开发流程中有用 | 标记为推荐 |
| **可选** | 特定场景有用 | 标注触发条件 |
| **不适用** | 与项目类型无关 | 写入排除项 |

匹配逻辑：
- 前端项目（React/Vue/Flutter）→ frontend-dev / frontend-design / ui-ux-pro-max / interaction-design / react-best-practices 为核心
- 后端项目 → api-design / architecture-patterns 为核心
- 全栈项目 → 上述全部为核心
- 测试不完善的项目 → tdd / test-driven-development 为核心
- 需要方案设计时 → brainstorming / architecture-decision-records 为核心
- 文档 / 教学场景 → technical-writer 为核心
- 代码审查场景 → code-review / review / simplify 为核心
- Web 可访问性 → web-access-2.5.1 为核心（如涉及）
- PPT / 文档生成 → pptx / minimax-docx / minimax-xlsx 等按需
- 其余技能保持默认，不强制分类

### 4. 生成 skill-manifest.md

基于分析结果，填充 `tasks/skill-manifest.md` 模板：

1. **第 1 节**：填入 `~/.cc-switch/` 路径、技能总数、扫描时间
2. **第 2 节**：填入从 SKILL.md frontmatter 提取的技能列表（完整 36 个）
3. **第 3 节**：根据项目类型标记推荐 / 可选 / 排除
4. **第 4 节**：为标准开发流程编排技能链（从实际技能列表中选取）
5. **第 5 节**：按人格映射推荐技能
6. **第 6 节**：列出不适用技能及理由

### 5. 补充项目级规则

追加到 manifest 末尾：
- 团队约定的技能使用顺序
- 必须使用的技能（如"所有新功能必须通过 tdd"）
- 禁用技能及原因

### 6. 提示用户

- "已生成 `tasks/skill-manifest.md`，共扫描 X 个技能，推荐 X 个"
- "请审核第 3/4/5 节的推荐是否符合你的开发习惯"
- "cc-switch 技能库变更后，重新运行 `/init-skills` 更新"

## 输出

- `tasks/skill-manifest.md` 生成或更新
- 推荐技能数量和排除技能数量
- 需要用户审核的推荐项

## 注意事项

- 模板只定义推荐关系，不强制要求所有技能都用上
- 技能的具体参数（如 tdd 的测试框架）由实现人格在开发时决定
- 如果 cc-switch 版本变更导致目录结构不同，优先询问用户，不要猜配置结构
