# Quality Snapshot

## Snapshot

- Date: 2026-05-01
- Scope: Codex configuration directory

## Product Areas

| Area | Verification State | Agent Readability | Stability | Key Gap |
| --- | --- | --- | --- | --- |
| Codex entrypoint | Verified | Good | Medium | Needs calibration in a real Codex session |
| Project config | Verified | Good | Medium | `.codex/config.toml` only loads in trusted projects |
| Custom agents | Verified | Good | Medium | Agent behavior needs real delegation tests |
| Harness workflow | Partially verified | Good | Medium | Standard validation path is not defined |
| Memory rules | Partially verified | Good | Medium | Actual Codex memory behavior should be tested in use |

## Architecture Layers

| Layer | Boundary Execution | Agent Readability | Risk |
| --- | --- | --- | --- |
| `AGENTS.md` | Good | Good | Can become too large if workflow details keep growing |
| `GLOBAL-AGENTS.md` | Good | Good | Must be manually copied to `~/.codex/AGENTS.md` if used globally |
| `.codex/config.toml` | Good | Good | Project trust is required before loading |
| `.codex/agents/` | Good | Good | Custom agents are uncalibrated until used |
| `tasks/` | Good | Medium | Must avoid becoming stale process paperwork |

## Next Quality Action

- Use one real Codex task to test whether `AGENTS.md` is too heavy.
- Define a standard validation path or explicitly mark this as documentation/config-only.
- Remove more process files if they do not improve handoff or verification.
