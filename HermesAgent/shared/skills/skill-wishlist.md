# Skill 候选清单（skill-wishlist）

> 本文件**不是**白名单。它只是"有人推荐过、值得评估"的 Skill 候选池。
>
> 任何条目要被真正可用，**必须**走完 `guards/skill-quarantine.md` 的三阶段流转：
> `.quarantine/` → `.review/`（Argus 审过）→ 产线分类目录 + 登记到 `shared/skills/allowlist.yaml`。
>
> 本文件**不写实现代码、不写具体配置**，只记 "名字 + 想解决什么问题 + 主要风险点"。

---

## 状态说明

| 状态 | 含义 |
|---|---|
| `wishlist` | 仅在本文件登记，**未**进入 quarantine |
| `quarantined` | Daedalus 已写出原型，在 `.quarantine/`，**不可用** |
| `reviewing` | Argus 审查中，在 `.review/`，仍**不可用** |
| `promoted` | 已通过 allowlist 提升到产线（同步登记到 allowlist.yaml） |
| `rejected` | Argus 否决，归档到 `memory/skill-graveyard.md`，**不再评估**直到出现新证据 |

---

## 通用风险提醒

所有候选 Skill 共享以下评估视角：

- **身份混淆**：能否被 Gateway 入站消息触发？如能，是否走"先草稿 + 用户 CLI 确认"二步流
- **网络扩面**：默认是否需要 outbound 访问？是否能限定到具体域名？
- **数据外发**：会不会把本地文件 / MEMORY / 凭据带出去？
- **状态持久化**：是否需要新 ENV / cookie / token？这些是否进 `.env` 而非源码
- **撤销可能性**：动作做完能否撤销？不能撤销则属"不可逆"，要走 `irreversible-actions.md`

不通过这套问题的 Skill **不进 quarantine**。

---

## 候选列表

来源：第三方公众号「算力云」2026-05 文章《普通人只会聊AI，高阶玩家早已用Hermes，配齐这8个Skill封神》。
**原文为营销文，未经 Hermes 官方背书**，所有"能力描述"必须重新评估，不能照单实现。

### 1. 自主全网检索（web-research）

- **想解决**：手动找资料、复制粘贴的耗时
- **可能实现**：包装现有 search API（Tavily / Serper / Bing）+ 内容抽取
- **主要风险**：
  - 任意域 outbound → 必须限定 `allowed_domains`
  - 抓取页面内容 = 不可信源（参考 `prompt-injection.md`）
  - 搜索 API 计费，需 `require_user_confirm: true`
- **状态**：`wishlist`
- **优先级**：高（已有低风险替代 `tavily_search` 在 allowlist）

### 2. 全域平台登录复用（browser-session-reuse）

- **想解决**：从公众号 / 知乎 / 小红书等登录态平台抓内容
- **可能实现**：读 Chrome cookies / 复用浏览器会话
- **主要风险**：
  - **极高**——直接持有用户登录态 = 持有所有平台身份
  - 一旦 Skill 被劫持等于身份被盗
  - 抓取的内容是不可信源，可能含提示词注入
  - 平台 ToS 风险（多数 SNS 禁止自动化抓取）
- **状态**：`wishlist`（**强烈倾向 rejected**，等待用户明确诉求再评估）
- **优先级**：低 —— 默认按 reject 处理，需要时人工评估

### 3. 音视频解析（av-transcribe）

- **想解决**：YouTube / B站等视频字幕提取与摘要
- **可能实现**：包装 `yt-dlp` + Whisper / FunASR
- **主要风险**：
  - `yt-dlp` 是高权限命令行工具，必须沙箱
  - 视频音频可能含个人/版权内容
  - 模型转写可能含错误，不能直接当事实写 MEMORY
- **状态**：`wishlist`
- **优先级**：中

### 4. 代码理解（github-code-reader）

- **想解决**：解析开源仓库 / 解读代码逻辑
- **可能实现**：`git clone` 到 sandbox + grep + LLM 摘要
- **主要风险**：
  - 拉取任意仓库可能拉到恶意代码（不可信源）
  - 解析结果不能直接执行，只能"读 + 描述"
  - 长仓库吃 token，要分批
- **状态**：`wishlist`
- **优先级**：中（已有 `grep_in_repo` / `read_file` 在 allowlist，覆盖部分需求）

### 5. 浏览器操控（browser-automation）

- **想解决**：表单填写、批量查询、网页流程自动化
- **可能实现**：包装 Playwright / Puppeteer
- **主要风险**：
  - **极高**——能登录就能下单、能转账、能修改账户
  - 操作必然不可逆（多数 web 表单提交 = 不可撤）
  - **如启用必须**：仅在 `staging` profile、仅"草稿模式"、必须 Argus + 用户当面确认每步
- **状态**：`wishlist`（**默认 rejected**，仅在用户明确特定场景时单点开放）
- **优先级**：低

### 6. 内容创作与优化（content-pipeline）

- **想解决**：自动写 / 改 / 适配多平台文案
- **可能实现**：纯 LLM 调用 + 平台风格模板
- **主要风险**：
  - 低风险（纯生成 + 写本地文件）
  - 但**禁止**直接发布到平台——产出物只能落 `tasks/drafts/`
  - 风格模板里的"爆款逻辑"是营销话术，不写进 SOUL
- **状态**：`wishlist`
- **优先级**：中

### 7. 数据处理（data-cleaning）

- **想解决**：CSV / 表格清洗、统计、可视化
- **可能实现**：包装 pandas / duckdb + matplotlib
- **主要风险**：
  - 中低风险（本地数据处理）
  - 处理的数据可能含敏感字段——按 `memory-write-policy` 脱敏标准走
  - 生成图表写本地 `~/.hermes/outputs/`，不外发
- **状态**：`wishlist`
- **优先级**：中

### 8. 私人记忆沉淀（personal-memory）

- **想解决**：跨会话记住用户偏好、风格、习惯
- **现状**：**已被 Hermes 内置记忆体系覆盖**——见 `memory-write-policy.md` + `memory-backend-policy.md`
- **不需要新增 Skill**：在选好 `memory.provider`（mem0 / agentmemory / hindsight）后这项自动满足
- **状态**：`rejected`（重复造轮子）
- **优先级**：—

---

## 评估流程

要把任一 `wishlist` 推进到 `quarantined`：

1. 用户在对话里明确说"评估 X Skill"
2. 由 Daedalus 写最小原型，放 `.quarantine/`
3. Argus 按本文件「通用风险提醒」+ 该条目「主要风险」逐项审
4. 通过 → 提到 `.review/`，登记 `authored_skills_journal`
5. dry-run 至少一次 + 用户 CLI 显式同意 → 提到产线 + 加 `allowlist.yaml`

跳级一律拒绝。

---

## 维护规则

- 新候选只能从**用户对话或真实工作场景**进入本文件，不允许 Agent 主动添加
- 候选超过 **90 天未推进** → 移到末尾「沉睡候选」段
- 沉睡超过 **180 天且无新证据** → 归档到 `memory/skill-graveyard.md` 并从本文件删除
- `rejected` 条目不重复评估，除非用户提供新证据（如官方背书 / 安全审计报告）

## 沉睡候选

（90 天未推进的条目移到这里。空则保持空。）
