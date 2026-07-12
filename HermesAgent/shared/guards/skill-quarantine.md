# Skill 三阶段流转护栏（Hermes 最大独家点）

Hermes 能让 Agent 在运行时**自创新的 Skill**——这是它区别于其他 AI Agent 工具的最强能力，也是最大的攻击面。

本文件定义"自创 Skill 怎么从'刚生出来'走到'被信任地调用'"。**三阶段流转**是强制的，跳阶段一律拒绝。

---

## 1. 三阶段总览

```
       Daedalus 写出来             用户挑出值得保留的            用户人工 promote
[隔离区 .quarantine/] ──── 审 ────→ [审查区 .review/] ──── Argus 审 ────→ [产线 <category>/]
            ↓                              ↓                                ↓
        不能被调用                     不能被调用                     被 allowlist 收录
        只能被读                       只能被读 + dry-run             被 Agent 自动可调
```

| 阶段 | 路径 | 是否可调用 | 进入条件 | 进入操作者 |
|---|---|---|---|---|
| 隔离区 | `~/.hermes/skills/.quarantine/<name>/` | ❌ | Daedalus 自创默认进这里 | Daedalus |
| 审查区 | `~/.hermes/skills/.review/<name>/` | ❌（仅 dry-run） | 用户从隔离区挑出 + Argus 通过审查清单 | 用户 + Argus |
| 产线 | `~/.hermes/skills/<category>/<name>/` | ✓ | Argus 通过提升审查 + 写入 allowlist | 用户人工 promote |

---

## 2. 隔离区（.quarantine/）

### 进入条件

任何 Skill 由 Daedalus（或其他 SOUL）撰写后**默认**写入此处。**不允许**任何 SOUL 跳过本阶段。

### 物理布局

```
~/.hermes/skills/.quarantine/
├── <skill-name>/
│   ├── SKILL.md            # 必需：触发关键词、能力说明、参数、副作用、回滚方式
│   ├── *.py / *.sh / *.js  # 实现文件
│   └── _audit.yaml         # 自动生成：何时由谁创建、为什么、源任务上下文
└── _audit.log              # 全局 audit log（追加写入）
```

### 行为约束

- **不能被任何 Agent 调用** — 哪怕 SOUL 切到 Daedalus 也不行
- **可以被读取**（用于审查），但读取动作必须出自 Argus 或用户显式命令
- **隔离期最长 30 天**：超过 30 天没被 promote 也没被丢弃的 Skill，Atlas 在周复盘时自动归档到 `skill-graveyard.md` 并删除
- **同名替换不允许**：如果 quarantine 里已经有同名 Skill，Daedalus 必须在新 Skill 后加 `-v2` / `-v3` 后缀，不允许覆盖

### audit log 必填字段

`_audit.yaml` 必须包含：

```yaml
skill_name: <name>
created_at: <ISO 8601>
created_by_soul: daedalus
created_in_profile: <profile-name>
source_task: <task-id>           # 来自 in-flight.json
trigger_reason: <user-facing 描述：为什么 Agent 决定要写这个 Skill>
declared_side_effects:           # Daedalus 自己声明的副作用
  - filesystem_write: [paths]
  - network_outbound: [domains]
  - external_api: [api-name]
  - shell_commands: [commands]
declared_dependencies:           # 该 Skill 依赖的外部 lib / MCP / 其他 Skill
  - lib: <name@version>
  - mcp_server: <name>
  - dependent_skill: <name>
risk_flags:                      # Daedalus 自检后的风险旗
  - uses_subprocess: false
  - uses_eval: false             # eval/exec 一律 false，否则 Argus 直接拒
  - writes_outside_outputs: false
  - calls_paid_api: false
```

任一 risk_flags 为 true 时，必须有对应的"Argus 已确认放行"记录才能进 `.review/`。

---

## 3. 审查区（.review/）

### 进入条件

用户在对话里**明确**说"把 quarantine/X 提到 review"或类似指令，Argus 走完审查清单（见下）通过后，由用户人工移动文件。

### Argus 审查清单（从隔离区 → 审查区）

- [ ] SKILL.md 存在且完整？
- [ ] `_audit.yaml` 字段齐全？
- [ ] 实现代码里**没有** `eval` / `exec` / `os.system` / `subprocess.shell=True`？
- [ ] 实现代码里**没有**硬编码 API key / Token / 绝对路径？
- [ ] 副作用声明与实际代码一致？（Argus 抽查关键函数）
- [ ] 网络出口在 `gateway/domain-allowlist.yaml` 范围内？
- [ ] 文件写入只在 `config.yaml: filesystem.write_paths` 内？
- [ ] 不调用未在白名单的其他 Skill / MCP？
- [ ] 同名 Skill 是否已在产线？冲突如何说明？

**任一不通过 → 拒绝并要求 Daedalus 重写**。

### 行为约束

- 仍**不能**被 Agent 自动调用
- 可以做 **dry-run**：用户在对话里说"dry-run review/X 用参数 Y"，Hermes 让 Daedalus 在沙箱跑一次，输出预期效果（不真实写文件、不真实发请求）
- dry-run 失败的 Skill 不允许提升到产线，必须打回 quarantine 修

---

## 4. 产线（<category>/）

### 进入条件

用户在对话里**明确**说"把 review/X 提到产线 <category>"，Argus 走完提升审查清单通过后，由用户人工移动文件 **+** 在 `shared/skills/allowlist.yaml` 里登记。

### Argus 提升审查清单（从审查区 → 产线）

- [ ] 至少经过一次 dry-run？
- [ ] dry-run 结果与 SKILL.md 声明一致？
- [ ] 用户在本次对话明确说要提升？
- [ ] 选择了正确的产线分类目录（不混类）？
- [ ] `allowlist.yaml` 登记了该 Skill 的：name / source / version / permissions / network / audited_by / audited_at / notes？
- [ ] 如果替换了同名旧 Skill，旧版本是否归档到 `.review/_archive/`？

### 行为约束

- 一旦进入产线，Hermes 默认可以**自动调用**它（前提是 `config.yaml: skills.policy = allowlist` 且该 Skill 在 allowlist 里）
- 任何**产线 Skill 的修改**必须降级回 `.review/`，重走审查
- 产线 Skill 被拉黑 → 归档到 `memory/skill-graveyard.md`，**不删除**历史

---

## 5. 自创 Skill 的"绝对不允许"

任何 SOUL 写出来的 Skill 只要满足以下任一条件，**直接进入永久黑名单，不允许任何阶段流转**：

- 调用 `eval` / `exec` / `compile`
- 使用 `subprocess.Popen(..., shell=True)` 或 `os.system`
- 包含网络后门特征：监听端口、反向 shell、远程代码加载
- 读取 `~/.ssh/` / `~/.aws/` / `~/.config/gcloud/` / `auth.json` / `.env`
- 写入上述任何路径
- 修改 `~/.hermes/HERMES.md` / `shared/guards/*` / `shared/skills/allowlist.yaml`
- 安装新的 pip / npm / brew 包
- 自我复制（生成另一个写 Skill 的 Skill）

发现 → 立即拉黑 + 归档 graveyard + Atlas 写 lessons + Argus 升级巡查。

---

## 6. 隔离区的清理责任

Atlas 在周复盘时**必须**：

1. 列出 quarantine 里 ≥ 7 天未动的 Skill
2. 列出 review 里 ≥ 14 天未提升的 Skill
3. 把超过 30 天没动的 quarantine Skill 归档到 graveyard + 删除原文件
4. 提示用户哪些值得 promote、哪些建议 abandon

清理动作要写进 `tasks/daily-log.md` 的 `[skill-cleanup]` 标签。

---

## 7. 反模式（禁止）

- "我看这个 Skill 没问题，直接放产线"——任何 SOUL（包括 Argus 自己）都不能跳阶段
- "用户上次说允许了"——授权不跨会话，不跨任务
- "这只是改个小 bug"——产线 Skill 改动必须降级回 review
- "先放产线，用了之后再观察"——绝不
- "这个 Skill 是用户自己写的不用审"——用户写的也要走 review，至少一次 dry-run
- "Skill 之间互相调用，audit log 太麻烦"——必须写，写漏一次下次拒绝
