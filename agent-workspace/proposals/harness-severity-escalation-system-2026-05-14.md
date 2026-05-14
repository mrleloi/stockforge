# Proposal — Unified Severity + Escalation + Block + External-Channel System

**Status**: PROPOSED (awaiting user ratification via AskUserQuestion fired same turn)
**Authored**: 2026-05-14 ~09:25 SEAST (~02:25Z) by main session S310 after user directive
**Trigger**: User directive (verbatim Vietnamese): "sửa hệ thống harness đi. dùng deterministic/hook/script để check và khiến human phải can thiệp vào cho những yêu cầu/blocking đặc biệt. đã có hệ thống level đánh giá cho các q&a, session pending, decision, note, error, ... chưa?"

**Scope**: Replaces ad-hoc severity fields across Q&A/decisions/mistakes/notifications with a unified 4-level schema + deterministic classifier + escalation engine + block enforcer + external channel adapter. Hardens what L-S310-1 (ritual demotion) addressed only inline.

---

## §1 Audit findings (current state — empirical scan 2026-05-14)

### A. Severity schemas are FRAGMENTED across artifact types

| Artifact | Field | Values observed | Source |
|---|---|---|---|
| Q&A bundles | `tier` + `priority` + `expected_answer_by` | tier=CHARTER / SCOPE+CHARTER / SCOPE; priority=HIGH/high; 24h-48h | `human-workspace/q-and-a/pending/*.md` |
| Decisions | `level` | CHARTER (15) / SCOPE (18) / ARCH (3) / IMPL (6) | `agent-workspace/memory/decisions/*.md` |
| Mistakes | `severity` | critical / high / medium / low | `agent-workspace/memory/mistake-log.md` |
| Notifications | inline keyword | INFO / SUMMARY / ALERT / WARN | `human-workspace/notifications/*.md` (no schema enforcement) |
| Hooks (urgent.md emit) | none (string body only) | various | `scripts/hooks/qa-stale-urgent-escalator.sh` etc. |

**Gap**: Same human-attention-tier maps to different field names + value sets. No way to query "give me all CRITICAL-tier outstanding items across artifact types."

### B. No BLOCK mechanism for autonomous mode

Current state:
- `human-workspace/q-and-a/.auto-mv-paused` — global kill switch but only for the auto-mv hook (1 mechanism), not for autonomous-mode globally
- `agent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint` — blocks reboot, not autonomous work
- `STOCKFORGE_FORCE_REBOOT=1` env override — exists for reboot, not for block

**Gap**: No `.autonomous-BLOCKED` flag that, when present, causes EVERY UserPromptSubmit / PreToolUse to return "BLOCKED: <reason>; human must resolve <artifact> first". Without this, agent keeps spinning even with CRITICAL items unresolved.

### C. 24h-pending escalation does NOT exist

Existing `scripts/hooks/qa-stale-urgent-escalator.sh`:
- Fires at **+48h** (`find -mtime +2`), not +24h
- Writes urgent.md only (one channel)
- Does NOT auto-fire AskUserQuestion
- Does NOT set block flag

**Gap**: Q-INT mega-bundle case (S259 filed → S309 stuck 20h) had `askuserquestion_fired: false` and never escalated; agent ran 50 busy-work sessions while bundle sat silent. Per L-S310-1 rule (3), agent MUST auto-fire AskUserQuestion at 24h pending — but no deterministic hook enforces this yet.

### D. No proactive AskUserQuestion auto-fire from hooks

Hooks can write `urgent.md`, but cannot directly invoke AskUserQuestion (it's a Claude Code tool only the LLM can call). Workaround: hook injects context via UserPromptSubmit `additionalContext` field, which the LLM reads + decides whether to fire AskUserQuestion. Currently nothing does this.

**Gap**: No hook injects "REQUIRED-ACTION: fire AskUserQuestion for bundle X (24h+ silent)" into the LLM's prompt cycle.

### E. No external notification channel

`human-workspace/notifications/urgent.md` is only useful when user opens the project directory. No push to Telegram / email / SMS / Discord.

Codebase scan for `telegram`: 0 references in scripts/hooks/. Mentioned in 2 decision artifacts (D-027, D-032) as future-Phase consideration; never implemented.

**Gap**: User physically away from machine → urgent.md unread → autonomous mode stalled indefinitely.

### F. Orphan notification accumulation

`human-workspace/notifications/` has ~80 files dating back to 2026-04-29 (e.g., `20260429-132547-learning-analysis-ready.md`, multiple `bash-hook-lint-warn` instances). No aggregation, no digest, no retention policy beyond urgent.md (which auto-rotates at 4KB).

**Gap**: Real signal drowns in noise. User cannot triage which items need attention.

### G. Watchdog hooks are fragmented; no central severity router

Existing watchdog/escalator/staleness hooks (partial list):
- `qa-stale-urgent-escalator.sh` (Q&A 48h)
- `idle-escape-detector.sh` (D-037; idle loop)
- `phase-status-coherence.sh` (phase mismatch)
- `budget-watchdog.sh` (token budget)
- `harness-health-cache-unknown` (marker-based)
- `adr-staleness-cache-unknown` (marker-based)
- `tracking-retention.sh` (size caps)
- `lesson-synthesis-watchdog.sh` (lesson promotion)

Each writes urgent.md OR sets its own marker. No common severity vocabulary. No central queue. No deduplication.

**Gap**: Adding a new watchdog requires inventing its own escalation path. Pattern is unscalable.

---

## §2 Proposed 5-layer design

### Layer 1 — Unified severity schema (`severity-schema.md` constitution doc)

4 levels, applies to Q&A + decisions + notifications + mistakes:

| Severity | Human attention required | Auto-block? | Auto-escalate after |
|---|---|---|---|
| **CRITICAL** | IMMEDIATE — autonomous mode blocked on next UserPromptSubmit / PreToolUse | YES — `.autonomous-BLOCKED` flag written | 0h (block on detect) |
| **HIGH** | Within 24h — AskUserQuestion auto-fire injection | NO — but `additionalContext` injection forces LLM to surface | 24h |
| **MEDIUM** | Within 168h (1 week) — urgent.md aggregated digest | NO | 168h |
| **LOW** | FYI — log only | NO | never escalates |

Mapping from existing fields:
- Q&A `tier=CHARTER+SCOPE` / `priority=HIGH` → severity HIGH (or CRITICAL if also `wait_until` exceeded)
- Decision `level=CHARTER` PROPOSED + cool-down expired without ratification → CRITICAL
- Mistake `severity=critical` → CRITICAL; `severity=high` → HIGH; etc.
- Hook-emitted `WARN` → LOW by default; `ALERT` → HIGH; new `CRITICAL` keyword reserved for block-class

Examples:
- CRITICAL: charter violation detected, deterministic gate failure repeated 3+ times, ghost-greening empirically confirmed, data integrity issue, ANTHROPIC_API_KEY leaked (M-S<N> family), `.autonomous-BLOCKED` already set
- HIGH: SCOPE/CHARTER Q&A bundle pending >24h, ADR PROPOSED >cool-down without ratification, ARCH+ decision needs fresh-context verifier
- MEDIUM: idle-loop 3+ sessions, calibration hit-rate drift >10%, phase-status-coherence mismatch, lesson promotion threshold reached
- LOW: routine sync-tracker bumps, single drift signal, hook firing-test pass log

### Layer 2 — Severity classifier (`severity-classifier.sh` deterministic hook)

**Trigger**: Stop hook (late chain — after lesson-synthesis-watchdog).

**Behavior**:
1. Scan `human-workspace/q-and-a/pending/*.md` → for each bundle, extract tier+priority+age → classify
2. Scan `agent-workspace/memory/decisions/*.md` status=PROPOSED → for each, extract level+age+cool-down → classify
3. Scan `agent-workspace/memory/mistake-log.md` for unresolved entries → extract severity
4. Scan `human-workspace/notifications/urgent.md` last 24h entries → classify by keyword
5. Scan stale-marker files (`.auto-reboot-PRE-BLOCKED-*`, `.adr-staleness-*`, etc.) → CRITICAL if present
6. Emit `agent-workspace/memory/.severity-state.tsv` with rows:
   ```
   severity<TAB>artifact_path<TAB>age_hours<TAB>next_action<TAB>classified_at
   CRITICAL<TAB>agent-workspace/memory/.auto-reboot-PRE-BLOCKED-stale-checkpoint<TAB>0<TAB>BLOCK<TAB>2026-05-14T02:25:00Z
   HIGH<TAB>human-workspace/q-and-a/pending/2026-05-13-Q-INT-mega-bundle.md<TAB>20<TAB>ESCALATE-ASKUSERQUESTION<TAB>2026-05-14T02:25:00Z
   MEDIUM<TAB>agent-workspace/memory/decisions/055-charter-amendment.md<TAB>13<TAB>RATIFY-AFTER-COOLDOWN<TAB>2026-05-14T02:25:00Z
   ```
7. Best-effort; never blocks Stop chain on its own errors (RC=0).

### Layer 3 — Escalation engine (`escalation-engine.sh` deterministic hook)

**Trigger**: Stop hook + UserPromptSubmit hook + SessionStart hook (3 cadences).

**Behavior**:
1. Read `.severity-state.tsv`
2. For each row:
   - **CRITICAL**: write `.autonomous-BLOCKED` flag with reason; append URGENT block-class entry to `urgent.md`; emit Telegram push (if configured)
   - **HIGH** at age >24h:
     - Append URGENT entry to `urgent.md` (idempotent per artifact via marker)
     - Inject `additionalContext` for UserPromptSubmit hook: `"REQUIRED-ACTION: Agent MUST fire AskUserQuestion for <artifact_path> before any other work this turn. Bundle is HIGH-severity, age <X>h."`
     - Emit Telegram push (if configured)
   - **MEDIUM** at age >168h: append digest entry to weekly notifications/digest-<week>.md; no block, no Telegram
   - **LOW**: log to `agent-workspace/memory/.severity-classifier.log` only

### Layer 4 — Block enforcer (`autonomous-block-enforcer.sh` deterministic hook)

**Trigger**: UserPromptSubmit hook (EARLY chain — before continue-injector) + PreToolUse hook (any tool).

**Behavior**:
1. Check `.autonomous-BLOCKED` flag presence
2. If present:
   - UserPromptSubmit: output `additionalContext` = "🛑 AUTONOMOUS BLOCKED: <reason verbatim from flag>. Human must (1) resolve listed artifacts (2) delete `.autonomous-BLOCKED` flag at `<path>` (3) then submit any prompt to resume. Agent: do NOT proceed with normal work this turn; respond with a one-paragraph status of the blocking artifacts + await human action."
   - PreToolUse: exit RC=2 (blocking) for tools other than Read/Glob/Grep (read-only allowed for diagnostics)
3. If absent: exit RC=0 silently

**Manual override**: `STOCKFORGE_FORCE_AUTONOMOUS=1` env bypasses block (for emergency operations; logs warning to mistake-log).

### Layer 5 — External channel adapter (`telegram-push.sh` deterministic hook)

**Trigger**: Called by escalation-engine.sh for CRITICAL/HIGH events only.

**Behavior**:
1. Read `$TELEGRAM_BOT_TOKEN` + `$TELEGRAM_CHAT_ID` env vars (from `.claude/settings.local.json` or system env)
2. If unset → skip silently (config not done)
3. POST to Telegram Bot API:
   ```
   POST https://api.telegram.org/bot<TOKEN>/sendMessage
   { chat_id: <CHAT_ID>, text: "🛑 [CRITICAL] StockForge S<N>: <artifact_path> needs immediate human action. Reason: <reason>." }
   ```
4. Idempotency: marker file `.telegram-pushed-<artifact-hash>-<severity>` prevents repeat pushes for same event
5. Best-effort: never fails the calling hook on network/API error

**User config required**:
- Create Telegram bot via @BotFather → get bot token
- Get user's chat ID (send `/start` to bot, then GET https://api.telegram.org/bot<TOKEN>/getUpdates → extract `chat.id`)
- Set env vars in `.claude/settings.local.json` (gitignored, per memory rule wildcard-permissions-preference)

---

## §3 Implementation phasing

### Phase A — Severity schema + classifier + state file (highest priority; ~150K tokens)
Files:
- `agent-workspace/constitution/severity-schema.md` (PROPOSED → user ratifies via Q3 below → moves to constitution/)
- `scripts/hooks/severity-classifier.sh`
- `scripts/hooks/firing-tests/severity-classifier-fire-test.sh`
- `agent-workspace/memory/.severity-state.tsv` (initial empty)
- `.claude/settings.json` Stop chain wiring

### Phase B — Escalation engine + AskUserQuestion injection (~150K tokens)
Files:
- `scripts/hooks/escalation-engine.sh`
- `scripts/hooks/firing-tests/escalation-engine-fire-test.sh`
- `.claude/settings.json` Stop + UserPromptSubmit + SessionStart wiring

### Phase C — Block enforcer (~80K tokens)
Files:
- `scripts/hooks/autonomous-block-enforcer.sh`
- `scripts/hooks/firing-tests/autonomous-block-enforcer-fire-test.sh`
- `.claude/settings.json` UserPromptSubmit + PreToolUse wiring

### Phase D — Telegram adapter (~80K tokens; gated on user config)
Files:
- `scripts/hooks/telegram-push.sh`
- `scripts/hooks/firing-tests/telegram-push-fire-test.sh` (mocked endpoint)
- Update `.claude/settings.local.json.example` documenting env vars

### Phase E — Migration of existing watchdogs to severity vocabulary (~80K tokens)
Update existing hooks to emit severity-tagged rows to `.severity-state.tsv` instead of/in addition to ad-hoc urgent.md writes:
- `qa-stale-urgent-escalator.sh` → emit HIGH at 24h (was 48h-only) + CRITICAL at 96h
- `idle-escape-detector.sh` → emit MEDIUM at idle ≥3 / CRITICAL at idle ≥10
- `phase-status-coherence.sh` → emit HIGH on mismatch
- `harness-health-*` → emit CRITICAL on RED, HIGH on YELLOW
- `budget-watchdog.sh` → emit CRITICAL on cliff, HIGH on wind-down

**Estimated total**: 540K tokens, 3-4 FOCUSED_IMPL sessions OR 1 MULTI-TASK-IMPL session (250K cap per CLAUDE.md).

---

## §4 Ratification questions (fired this turn via AskUserQuestion 4-Q batch)

See accompanying AskUserQuestion. Choices needed:
- Q1: 4-level schema OK / 3-level / 5-level / amend
- Q2: Block enforcer aggression — PreToolUse-blocks-all-write-tools / UserPromptSubmit-only-injects-context / both / different
- Q3: HIGH-severity escalation threshold — 24h / 12h / 6h / variable per artifact-class
- Q4: Telegram setup — provide credentials now / placeholder skeleton, configure later / different channel preference (Discord / email / SMS / other)

---

## §5 Risk + rollback

| Risk | Severity | Mitigation |
|---|---|---|
| `.autonomous-BLOCKED` flag bug stalls valid work | HIGH | `STOCKFORGE_FORCE_AUTONOMOUS=1` env override + flag includes hard manual delete instructions |
| Severity classifier false-positives CRITICAL | MEDIUM | Classifier emits to .severity-state.tsv (visible); block-enforcer reads via specific row patterns, not blanket trigger; thresholds documented |
| Telegram leak (token exposure) | HIGH | Token in `.claude/settings.local.json` (gitignored per wildcard-permissions-preference); never logged in attestation-log; redact-secrets.sh covers |
| 80 orphan notifications/*.md files | LOW | Phase F (separate session) writes notifications retention policy |
| Constitution-tier severity-schema.md write | MEDIUM | Per CLAUDE.md hard rule, propose first via this file; user ratifies via Q1; THEN move to constitution/ via separate Edit |

**Rollback**: each layer is an independent hook; remove from settings.json + delete script files. State file `.severity-state.tsv` is regenerated each Stop; safe to delete. Flag files (`.autonomous-BLOCKED`) safe to delete manually.

---

## §6 Source evidence

- User directive (verbatim): `human-workspace/user_prompt/20260514_*.txt` (this session) — "sửa hệ thống harness đi. dùng deterministic/hook/script..."
- Audit empirical scan: bash commands run S310 ~02:20Z (see session transcript)
- Existing fragmented schemas: see §1 table citations
- Q-INT case study (20h silent): `human-workspace/q-and-a/pending/2026-05-13-Q-INT-mega-bundle.md` frontmatter `askuserquestion_fired: false`
- Mistake-log Q-INT-class precedent: `agent-workspace/memory/mistake-log.md` M-S171-1 (22 consecutive idle sessions → idle-escape-detector.sh shipped at S175 via D-037)
- Charter rule: CLAUDE.md § Hard Rules — Ritual demotion clause (catch-rate=0 over 3+ ⇒ demote/retire) — L-S310-1 inline application; this proposal formalizes the deterministic enforcement

---

**End of proposal. AskUserQuestion fired same turn for ratification.**
