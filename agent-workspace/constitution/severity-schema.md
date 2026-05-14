# Severity Schema — Unified 4-Level System

> **Status**: ACCEPTED (ratified 2026-05-14 via AskUserQuestion at S310; user picked "OK 4-level (Recommended)" + "6h HIGH escalation threshold" + "Both UserPromptSubmit + PreToolUse block")
> **Authored**: 2026-05-14 by main session S310
> **Source**: `agent-workspace/proposals/harness-severity-escalation-system-2026-05-14.md` §2 Layer 1
> **Provenance**: User directive verbatim "sửa hệ thống harness đi. dùng deterministic/hook/script để check và khiến human phải can thiệp..."
> **Audience**: Hooks, skills, agents, decisions — every artifact type that requires human attention classification.

---

## §1 The 4 Levels

| Level | Human attention | Auto-block? | Auto-escalate after | Telegram push? |
|---|---|---|---|---|
| **CRITICAL** | IMMEDIATE — autonomous mode blocked on next UserPromptSubmit / PreToolUse | YES (`.autonomous-BLOCKED` flag written by escalation-engine) | 0h (block on detect) | YES |
| **HIGH** | Within 6h — agent MUST fire AskUserQuestion (per L-S310-1 rule 3) | NO — but `additionalContext` injection forces LLM surfacing | 6h | YES |
| **MEDIUM** | Within 168h (1 week) — appears in weekly digest | NO | 168h | NO |
| **LOW** | FYI — log only | NO | never escalates | NO |

---

## §2 Mapping from existing fields

Pre-existing artifact fields are normalized into this unified schema by `scripts/hooks/severity-classifier.sh`:

| Artifact | Source fields | → Severity |
|---|---|---|
| Q&A bundle | `tier=CHARTER+SCOPE` / `priority=HIGH` + age ≥6h | HIGH |
| Q&A bundle | age ≥96h | CRITICAL |
| Decision | `status=PROPOSED` + `level=CHARTER` + age ≥24h | HIGH |
| Decision | `status=PROPOSED` + `level=SCOPE\|ARCH` + age ≥12h | MEDIUM |
| Decision | `status=PROPOSED` + `level=IMPL` | LOW |
| Mistake | `Severity=critical` AND not (resolved\|SHIPPED\|carryover\|FIX-SHIPPED\|RETRO-DISCOVERED) | CRITICAL |
| Mistake | `Severity=high` AND not (resolved\|SHIPPED\|carryover\|FIX-SHIPPED\|RETRO-DISCOVERED) | HIGH |
| Notification | body contains `CRITICAL\|critical` AND not `status=ANSWERED\|RESOLVED\|DEFERRED` AND age ≤24h | CRITICAL |
| Notification | body contains `ALERT\|alert\|URGENT` AND same filters | HIGH |
| Notification | body contains `WARN\|warn` AND same filters | MEDIUM |
| Stale-checkpoint marker | `.auto-reboot-PRE-BLOCKED-stale-checkpoint` present | CRITICAL |
| Charter-violation marker | `.charter-violation-detected` present | CRITICAL |
| Ghost-greening marker | `.ghost-greening-confirmed` present | CRITICAL |
| Autonomous-block flag | `.autonomous-BLOCKED` present | CRITICAL (self-detect; ensures flag visible in state) |

---

## §3 Examples by level

### CRITICAL — must block autonomous mode
- Charter violation detected by drift signal (e.g., DR-CHARTER)
- Deterministic gate failure repeated ≥3 times consecutive (mypy/pytest/ruff)
- Ghost-greening empirically confirmed (claimed file missing from disk)
- ANTHROPIC_API_KEY leaked or `import anthropic` snuck in (M-S227-1 family)
- Q&A bundle pending >96h (long-stuck)
- Mistake-log new entry with `Severity: critical` AND not yet resolved

### HIGH — fire AskUserQuestion within 6h
- SCOPE/CHARTER Q&A bundle pending ≥6h (no answer signal)
- Charter-tier decision PROPOSED past cool-down (≥24h) without ratification
- Mistake-log new entry with `Severity: high` AND not yet resolved
- Notification body has ALERT/URGENT keyword AND not yet ANSWERED/RESOLVED/DEFERRED

### MEDIUM — weekly digest
- ARCH or SCOPE decision PROPOSED past cool-down (≥12h) without ratification
- Calibration hit-rate drift >10% from baseline
- Phase-status-coherence mismatch persistent ≥3 sessions
- Notification body has WARN keyword

### LOW — log only
- Routine sync-tracker bumps
- Single drift signal fire (chronic, not novel)
- Hook firing-test pass log
- Notification body without severity keywords
- IMPL-tier decision PROPOSED (no auto-cool-down enforcement)

---

## §4 Enforcement chain (hook responsibilities)

```
severity-classifier.sh (Stop late chain)
   ↓ emits agent-workspace/memory/.severity-state.tsv
escalation-engine.sh (Stop + SessionStart + UserPromptSubmit)
   ↓ for CRITICAL: writes .autonomous-BLOCKED flag + urgent.md entry + telegram-push
   ↓ for HIGH: appends urgent.md + UserPromptSubmit additionalContext (forces AskUserQuestion) + telegram-push
   ↓ for MEDIUM: weekly digest-YYYY-Www.md entry
   ↓ for LOW: log only
autonomous-block-enforcer.sh (UserPromptSubmit FIRST + PreToolUse FIRST)
   ↓ when .autonomous-BLOCKED present:
      UserPromptSubmit → inject loud BLOCKED context
      PreToolUse → RC=2 deny for Edit/Write/Bash/MultiEdit/NotebookEdit/Agent
      Read/Glob/Grep allowed for diagnostic
   ↓ override: STOCKFORGE_FORCE_AUTONOMOUS=1 env (logged)
telegram-push.sh (called by escalation-engine for CRITICAL/HIGH)
   ↓ pushes plain-text severity-tagged message to user's Telegram chat
   ↓ creds: STOCKFORGE_TELEGRAM_BOT_TOKEN + STOCKFORGE_TELEGRAM_CHAT_ID env vars
```

---

## §5 State file schema (`.severity-state.tsv`)

Tab-separated rows:
```
severity<TAB>artifact_path<TAB>age_hours<TAB>next_action<TAB>classified_at
```

Columns:
- `severity`: CRITICAL | HIGH | MEDIUM | LOW
- `artifact_path`: relative from project root
- `age_hours`: integer; computed from file mtime
- `next_action`: BLOCK | ESCALATE-ASKUSERQUESTION | DIGEST | LOG-ONLY
- `classified_at`: ISO-8601 timestamp of this classifier run

State file is rewritten atomically each Stop hook (full re-scan; not append). Stale entries naturally disappear when artifact resolved.

---

## §6 Filter rules (false-positive prevention)

`severity-classifier.sh` MUST apply these filters:

1. **Decision scan**: skip `_template.md`, `README.md`, `TEMPLATE.md`, `index.md`
2. **Decision scan**: only emit if `status:` line starts with `PROPOSED` (not ACCEPTED/REVOKED/SUPERSEDED-BY-*)
3. **Q&A scan**: skip bundles with `status:` starting with `answered-`, `closed-`, `resolved-`
4. **Notification scan**: skip `urgent.md`, `urgent-archived-*.md`, `digest-*.md` (self-loop prevention)
5. **Notification scan**: skip if `status:` line starts with `ANSWERED`, `RESOLVED`, `DEFERRED` (or lowercase variants)
6. **Mistake-log scan**: skip lines containing `resolved`, `carryover`, `SHIPPED`, `FIX-SHIPPED`, `RETRO-DISCOVERED`

---

## §7 Constitution-tier discipline

This schema is constitution-tier (binding for all artifact authors). Amendments require:
1. User explicit ratification via AskUserQuestion (this initial schema was ratified S310 2026-05-14)
2. Cool-down ≥24h (per D-055 charter amendment protocol — but D-055 itself is the cool-down rule, so the meta-rule applies)
3. New decision record in `agent-workspace/memory/decisions/` superseding via SUPERSEDED-BY-D-NNN status

This file lives at `agent-workspace/constitution/severity-schema.md` and is in the project deny list (Write/Edit) per `.claude/settings.json`. Modifications require Bash-level cp from staging file (which is itself author-controlled).

---

## §8 Source decisions + provenance

- **L-S310-1**: Ritual demotion BINDING (sync-grilling cadence + routine-idle close) — preconditions for this system to be useful
- **L-S310-2**: Unified severity + escalation + block + Telegram-skeleton SHIPPED
- **D-058**: Q-INT mega-bundle ratification (related — clears 12 prior decisions blocking Wave plan)
- **D-055 (PROPOSED)**: charter amendment cool-down protocol — provides 24h cool-down framework reused here
- **Proposal source**: `agent-workspace/proposals/harness-severity-escalation-system-2026-05-14.md` (full audit + design rationale)
- **Hook implementations**:
  - `scripts/hooks/severity-classifier.sh` (5 firing-test TC)
  - `scripts/hooks/escalation-engine.sh` (7 firing-test TC)
  - `scripts/hooks/autonomous-block-enforcer.sh` (11 firing-test TC)
  - `scripts/hooks/telegram-push.sh` (3 firing-test TC)
  - Total: 26/26 firing-tests PASS at ship time

**End of severity-schema.md**
