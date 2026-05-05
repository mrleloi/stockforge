---
plan_id: 003-S15-track-7-constitution-amendments
session: S15
session_type: PLAN
authored_at: 2026-04-29
authored_by: Claude Opus 4.7 (S15 PLAN)
predecessor: agent-workspace/memory/checkpoints/latest.md (S14 close)
extends: agent-workspace/session-plans/pending/001-port-from-orch.md (Track 7 row)
budget_target: ~80K (PLAN-only); IMPL ratification deferred to S16 FOCUSED_IMPL ~150K
mode: AUTONOMOUS (full; autonomous_mode=true always per user correction S15 close)
---

# S15 PLAN — Track 7 Constitution Port + L-S* Promotions + D-003/D-005 Amendments

> **Goal**: produce a session plan that S16 IMPL can execute deterministically. Compose append-only amendment blocks for D-003 + D-005; route 9 learned-rule promotions per priority `hook > skill > charter`; surface 9 queued-grill triggers via AskUserQuestion multi-batch; lay out S16 IMPL deliverables with success criteria.
>
> **Constraint** (CLAUDE.md hard rule): never mix PLAN and IMPL in same session. This file is the PLAN; S16 ratifies + writes constitution drafts to `agent-workspace/proposals/` (per `agent-workspace/CLAUDE.md` § Constitution immutability).

---

## Pre-flight verification (S15 SessionStart, completed)

- ✅ Read checkpoint `latest.md` (S14 close)
- ✅ Read `current-execution.md` (S15 routing — Track 7)
- ✅ Read `2026-04-29-session-14.md` (S14 detail incl. IMPL-S14-1/2/3 + L-S14-1/2/3)
- ✅ Read `agent-notes.md` recent entries (L-S11..L-S14 promotion candidates confirmed)
- ✅ Read `observations/queued-grill-master.md` (9 Track-7-active triggers identified)
- ✅ Read D-003 § 5.5c.5 prose + D-005 § 5.5d.1/5.5d.2 prose (amendment composition source)
- ✅ Read `project.md` (Phase 0 state, Recent Decisions D-001..D-005)
- ✅ Direct D1 baseline verification: **16 violations** — 5 skills + 10 commands + 1 agent (matches checkpoint claim)

---

## Section 1 — Amendment composition (append-only)

### 1.1 D-003 § 5.5c.5 — `failure_mode` 8-code expansion (carry-over: IMPL-S13-1)

**Source**: `agent-workspace/memory/sessions/2026-04-29-session-13.md` § IMPL-S13-1 + carry-over note in `agent-workspace/memory/checkpoints/latest.md` § Open carry-over.

**Existing prose** (D-003 § 5.5c.5 JSONL Telemetry Schema Extension): mentions `failure_mode` field with 3-code prose (`B = build/runtime error / H = harness rejection / null = no failure detected`).

**Reality at S13 wire-in**: 8-code expansion shipped with `correlate_failure_mode()` in `scripts/hooks/component-telemetry.sh`:
| Code | Meaning |
|---|---|
| `B` | Build/runtime error (Stop hook signals API/runtime exception) |
| `C` | Premature wind-down (budget-watchdog mode-C alert before cliff) |
| `D` | Clean handoff (S14 addition — checkpoint mtime ≤ 60s, no A/B/C) |
| `E` | Eval/test failure (deferred — placeholder for Phase 1+ test harness) |
| `H` | Harness rejection (PreToolUse deny exit code 2) |
| `R` | Retry/escalation (drift signal HIGH triggered re-dispatch) |
| `T` | Timeout (Bash timeout exceeded, hook killed) |
| `null` | No failure detected this event (success case) |

**Amendment block (proposed S16 IMPL writes)**:
```markdown
### REV-4 (S15 PLAN — IMPL-S13-1 ratification) — failure_mode 8-code expansion

**Source**: S13 wire-in actuals + S14 Mode-D extension; documented in `2026-04-29-session-13.md` IMPL-S13-1 + S14 L-S14-4 (Mode-D).

**Decision**: D-003 § 5.5c.5 prose updated to enumerate 8 codes (B/C/D/E/H/R/T/null) with semantics per S13 implementation + S14 Mode-D addition. The `mode_d` row reflects clean-handoff recovery (autonomous-stop-watchdog.sh extension shipped S14).

**Status transition**: D-003 ACCEPTED-REV-3 → ACCEPTED-REV-4.
```

**Why append vs rewrite**: D-003 § 5.5c.5 is shipped scope; rewriting would obscure the wire-in date + Mode-D timing. Append-only preserves audit trail per workspace dualism contract.

**S16 IMPL action**: write the REV-4 block as an append to D-003 § Amendments (after REV-3 entry).

---

### 1.2 D-005 § 5.5d.1/5.5d.2 — Path consistency (carry-overs: IMPL-S11-2, IMPL-S12-1, IMPL-S14-1)

**Source**: `2026-04-29-session-11.md` IMPL-S11-2 + `2026-04-29-session-12.md` IMPL-S12-1 + `2026-04-29-session-14.md` IMPL-S14-1.

**Existing prose** (D-005 § 5.5d.1 deliverables): `agent-workspace/learning-data/{events,index,archive}/`.
**Existing prose** (D-005 § 5.5d.2 deliverables): `agent-workspace/memory/learning-data/index/categories-<TS>.md` (note: `memory/` prefix).

**Internal inconsistency**: § 5.5d.1 uses `agent-workspace/learning-data/...`; § 5.5d.2 uses `agent-workspace/memory/learning-data/...`. S10 IMPL chose §5.5d.1 layout (downstream artifacts: permissions, README, gitkeep, .gitignore, hooks all aligned). §5.5d.2 prose treated as drafting bug per IMPL-S11-2.

**Additional split surfaced at S12** (IMPL-S12-1): research-survey output and dogfood-insight output occupy distinct file purposes; IMPL chose `learning-data/dogfood/<tool>-research-report-<TS>.md` for research-scanner output and `learning-data/dogfood/<tool>.md` for dogfood insight artifact. D-005 § 5.5d.3 prose collapses both into single `<tool>.md` filename.

**Amendment block (proposed S16 IMPL writes)**:
```markdown
### REV-1 (S15 PLAN — IMPL-S11-2 + IMPL-S12-1 + IMPL-S14-1 ratification) — path layout consistency

**Source**: S10/S11/S12 IMPL-tier resolutions + S14 carry-over (skill spec-to-wiki SKILL.md still 227 LOC, separate D1 violation, deferred Track 6 secondary).

**Decision**:
1. **§5.5d.1 layout is canonical**: `agent-workspace/learning-data/{events,index,archive,dogfood,loop}/`. Downstream alignment cost dominated drafting precision per L-S11-2 IMPL-tier-resolution-doctrine.
2. **§5.5d.2 prose `agent-workspace/memory/learning-data/index/...` is corrected**: the `memory/` prefix was a drafting error; the canonical path is `agent-workspace/learning-data/index/categories-<TS>.md`.
3. **Dogfood file split** (§5.5d.3): `learning-data/dogfood/<tool>-research-report-<TS>.md` = research-scanner output (provenance log, scoring, bear case); `learning-data/dogfood/<tool>.md` = dogfood-insight artifact (post-integration measurable insight). Two files, two purposes.
4. **S14 Track 6 secondary carry-over**: skill `.claude/skills/spec-to-wiki/SKILL.md` (227 LOC) remains a D1 violation. Per L-S14-2 (skill-vs-command duplication multiplier), it's a separate refactor task — not blocking, scheduled for S16 secondary or S17.

**Status transition**: D-005 ACCEPTED → ACCEPTED-REV-1.
```

**S16 IMPL action**: write the REV-1 block as an append to D-005 § Amendments (currently empty).

---

## Section 2 — L-S* promotion routing (priority hook > skill > charter)

Per Q-E3 (deferred answer; will fire via AskUserQuestion this session): cheapest first = hook ratifies a deterministic check; skill encodes procedural discipline; charter amendment is heaviest lift (immutability invariant).

| Lesson | Title | Recommended priority | Target artifact |
|---|---|---|---|
| **L-S11-1** | Phase 0 hook portability (bash + node + POSIX only) | **HOOK + SKILL** | NEW `scripts/hooks/bash-hook-lint.sh` (deterministic check) AND amend `agent-workspace/constitution/financial-data-protocol.md` § Phase boundaries |
| **L-S11-2** | IMPL-tier-resolution-doctrine (downstream-alignment wins, surface via carry-over) | **CHARTER** | Amend `agent-workspace/constitution/decision-discipline.md` (Track 7 deliverable; create if not yet authored) |
| **L-S12-1** | Metric-function-required for self-learning claims | **HOOK shipped + SKILL shipped + CHARTER optional** | `learning-loop-metric-check.sh` shipped S13; `try-n-approaches/SKILL.md` enforces; charter amendment OPTIONAL — deferred unless Q-E2/E3 user pick mandates |
| **L-S12-2** | Research-scanner dispatch discipline (provenance + bear-case + license) | **HOOK shipped + CHARTER optional** | `research-scanner-output-validator.sh` shipped S13; charter amendment OPTIONAL |
| **L-S13-1** | Producer-consumer log path mismatch (silent telemetry brick) | **HOOK extension** | Extend `bash-hook-lint.sh` (NEW per L-S11-1) with producer-consumer check: scan `LOG_VAR=` assignments without matching `>>` or `>` redirect anywhere in `scripts/` |
| **L-S13-2** | Cumulative-vs-windowed metric distinction | **SHIPPED** (`--window N` arg in S14) → **SKILL** | Amend `try-n-approaches/SKILL.md` § Best practices: "metric script MUST support BOTH cumulative AND windowed modes"; OR `references/metric-patterns.md` if deepens |
| **L-S14-1** | Progressive-disclosure refactor first-draft 150-180 LOC; budget compression reserve | **SKILL** | Amend `write-a-skill/SKILL.md` § Best practices |
| **L-S14-2** | Skill-vs-command duplication multiplier | **SKILL + CHARTER** | Amend `write-a-skill/SKILL.md` § "Skill vs Command" section AND amend `agent-workspace/constitution/architecture.md` § Slash command vs skill responsibility split |
| **L-S14-3** | Wildcard permissions land in settings.local.json (charter deny rules preserved) | **MEMORY + SKILL** | Update `~/.ccs/.../memory/harness_bootstrap_permission_override.md` AND amend `update-config/SKILL.md` § Preconditions checklist |
| **L-S14-4** | autonomous_mode flag + Mode-D clean-handoff coverage (S14 mid-session fix) | **CHARTER** | Codify Mode A/B/C/D coverage in `agent-workspace/constitution/autonomous-protocol.md`; document cliff-vs-injector dispatch in `session-budgets.md` |

**Total promotion targets**:
- **2 NEW hooks**: `bash-hook-lint.sh` (covers L-S11-1 portability + L-S13-1 producer-consumer)
- **5 SKILL amendments**: write-a-skill, try-n-approaches, update-config, plus 2 references companions
- **4 CHARTER drafts** (proposals/ — pending user explicit approve): `decision-discipline.md` (NEW; L-S11-2), `architecture.md` (NEW or amend; L-S14-2), `autonomous-protocol.md` (NEW or amend; L-S14-4 + Q-C2/C3/E1/E4 inputs), `financial-data-protocol.md` (amend; L-S11-1)
- **2 OPTIONAL charter amendments**: L-S12-1 + L-S12-2 (already enforcement-shipped via hooks; charter amendment is documentation, not enforcement)

---

## Section 3 — Queued-grill multi-batch (FIRED + CLOSED this session)

Per `observations/queued-grill-master.md`, 9 items had `fire_when` triggers matching active context (Track 7). All 9 fired across 3 batches (4 + 3 + 2) in S15 PLAN; all closed with Recommended option same turn.

**Batch 1 — Governance defaults (4 questions)**:
| ID | Question | Answer |
|---|---|---|
| **Q-E3** | Promotion target priority | **Hook FIRST, skill SECOND, charter LAST** (cheapest deterministic check first) |
| **Q-E2** | Agent-notes → promotion frequency | **Phase-boundary only** (manual review by promotion subagent, fresh-ctx) |
| **Q-B2** | Hard block on default-acceptance for charter/SCOPE-tier? | **Yes — charter/SCOPE-tier MUST require explicit letter pick** |
| **Q-D3** | Codify Tier 1/2/3 memory tiers? | **Yes — add `memory-tiers.md` to constitution** |

**Batch 2 — autonomous-protocol.md authoring inputs (3 questions)**:
| ID | Question | Answer |
|---|---|---|
| **Q-C2** | Context auto-loader mechanism? | **Hybrid: auto for routine SessionStart; LLM-selector for complex** |
| **Q-C3** | SessionStart bootstrap token ceiling? | **Adaptive: PLAN ≤8K / IMPL ≤15K / VERIFY ≤6K** |
| **Q-2.1** | Skill-tool autonomous mode policy? | **Skill calls only in SUPERVISED mode; gate autonomous loops to NOT call skills** |

**Batch 3 — Drift detection + recovery (2 questions)**:
| ID | Question | Answer |
|---|---|---|
| **Q-E1** | How agents auto-detect drift WITHOUT human prompt? | **All A+B+C combined** (per-task DA-rule + Stop-hook /session-verify + fresh-ctx drift-auditor subagent) |
| **Q-E4** | Drift recovery flow if auto-detected mid-session? | **Open Q&A bundle with detected drift + 3 remediation options; let human pick async** |

**Outcome**: zero items carried to S16 SessionStart. `queued-grill-master.md` Active Queue is now empty for Track 7 triggers; only Q-D1 (sessions folder scaling, fires Phase 1) and Q-D2 (Obsidian wiki scaling, fires Phase 1) remain queued.

**Implication for S16 IMPL deliverables (Section 4)**: all 9 answers fold into the constitution drafts. Specifically:
- `proposals/decision-discipline.md` codifies Q-E3 + Q-E2 + Q-B2
- `proposals/autonomous-protocol.md` codifies Q-C2 + Q-C3 + Q-2.1 + Q-E1 + Q-E4
- `proposals/memory-tiers.md` codifies Q-D3

---

## Section 4 — S16 IMPL deliverables (FOCUSED_IMPL ~150K target)

Assuming all 9 queued-grill items answered (in S15 or carried to S16 SessionStart), S16 IMPL produces:

### 4.1 NEW hooks (`scripts/hooks/`)

| Hook | LOC budget | Scope |
|---|---|---|
| `bash-hook-lint.sh` | ≤180 | L-S11-1 portability whitelist + L-S13-1 producer-consumer detection. Wired as Stop hook + on-demand. |
| `learning-loop-metric-check.sh` (wire) | already shipped S13; **wire to settings.json** | Stop-hook gate — soft-warn if `learning-data/loop/*-experiment-frame.md` lacks `metric_function:` frontmatter. |
| `research-scanner-output-validator.sh` (wire) | already shipped S13; **wire to settings.json** | Stop-hook gate — soft-warn if dogfood research report lacks provenance + adversarial-bear-case sections. |

### 4.2 NEW constitution drafts (`agent-workspace/proposals/`)

Per `agent-workspace/CLAUDE.md` rule 1 — agents write to `proposals/` only; user explicit approve moves to `constitution/`.

| Draft file | Source | LOC budget |
|---|---|---|
| `proposals/decision-discipline.md` | L-S11-2 + Q-B2 + Q-E3 | ≤150 |
| `proposals/autonomous-protocol.md` (or amend if exists) | L-S14-4 + Q-C2 + Q-C3 + Q-E1 + Q-E4 + Q-2.1 + **S15-close user correction (full autonomous, no SUPERVISED)** | ≤200 |
| `proposals/architecture.md` (amend if exists) | L-S14-2 § Slash command vs skill responsibility split | append ≤30 LOC |
| `proposals/financial-data-protocol.md` (amend) | L-S11-1 § Phase 0 hook portability | append ≤30 LOC |
| `proposals/memory-tiers.md` (NEW if Q-D3 ≠ C) | Q-D3 answer | ≤80 LOC |
| `proposals/session-budgets.md` (amend if exists) | L-S14-4 cliff-vs-injector dispatch | append ≤20 LOC |

### 4.3 SKILL amendments

| Skill | Source lessons | Edit scope |
|---|---|---|
| `.claude/skills/write-a-skill/SKILL.md` | L-S14-1 + L-S14-2 | append ≤25 LOC § Best practices |
| `.claude/skills/try-n-approaches/SKILL.md` | L-S13-2 | append ≤15 LOC § Best practices |
| `.claude/skills/update-config/SKILL.md` (or `references/preconditions.md`) | L-S14-3 | append ≤15 LOC checklist |
| Memory file: `~/.ccs/.../harness_bootstrap_permission_override.md` | L-S14-3 | append ≤10 LOC |

### 4.4 D-003 + D-005 amendments

Append blocks composed in Section 1.1 + 1.2 above. Mechanical write to `agent-workspace/memory/decisions/003-...md` and `005-...md` § Amendments sections.

### 4.5 D1 baseline NOT-WORSE check

Run `bash scripts/hooks/drift-signals-D1-D9.sh` after all S16 writes. Confirm violation count = 16 (no new violations). Track 6 secondary closure (5 skills + 10 commands + 1 agent remaining) is **OPTIONAL S16** — only if budget allows after primary deliverables; otherwise S17.

---

## Section 5 — S16 success criteria

| # | Criterion | Pass condition |
|---|---|---|
| 1 | D-003 + D-005 amendments shipped (append-only) | grep finds REV-4 block in D-003, REV-1 block in D-005; no rewrite of pre-existing sections |
| 2 | All 9 queued-grill items either answered (in-session) or re-queued with new `fire_when:` | `queued-grill-master.md` shows status `fired` + `closed` for answered, OR `fire_when: <next-trigger>` for re-queued |
| 3 | NEW `bash-hook-lint.sh` shipped + smoke-tested + wired | wc -l ≤180; runs without ERR-trap silent fail; Stop hook entry in settings.json |
| 4 | `learning-loop-metric-check.sh` + `research-scanner-output-validator.sh` wired in settings.json | Stop hooks block in settings.json contains both; smoke fire produces expected output |
| 5 | Constitution drafts in `proposals/` (NOT `constitution/`) | each draft is at `agent-workspace/proposals/<name>.md`; pending user explicit approve before move |
| 6 | 0 new D1 violations | drift-signals run shows ≤16 violations (improvement or hold) |
| 7 | Skill amendments shipped + LOC verified | `wc -l` after each Edit; SKILL.md ≤150 (no new D1) |
| 8 | Promotion targets summary written to `agent-workspace/memory/observations/promotion-routing-S16.md` | one-row-per-lesson summary linking to artifact + status |
| 9 | `proposals/autonomous-protocol.md` codifies autonomous_mode=true as ONLY mode | grep `SUPERVISED` in proposal returns 0; AskUserQuestion-for-routine-handoffs explicitly listed as anti-pattern; Mode-A/B/C/D coverage codified per S14 L-S14-4 |
| 10 | NEW drift signal candidate (D11 or D-IDENTITY extension) added to `bash-hook-lint.sh` or `drift-signals-D1-D9.sh` | Scans LIVE config for `SUPERVISED|autonomous_mode:\s*false|until Track 7`; flags as fabricated-default drift; historical session/checkpoint files exempt per L-S10 |

---

## Section 6 — Carry-over to S17+

- **Track 6 secondary closure** (16 D1 violations) — can absorb 1-2 S16 if budget room; otherwise S17 dedicated session
- **L-S12-1 + L-S12-2 charter amendments** — OPTIONAL; only if Q-E3 answer mandates charter coverage even when hook shipped
- **Promote-rule skill dispatch** — once S16 ships routing artifacts, `promote-rule` skill should run on agent-notes for any rules not yet promoted
- **Q&A bundles 002-006** — still in `human-workspace/q-and-a/pending/`; humans move to `answered/` on their schedule
- **Re-measure failure_mode rate** at S16+ once natural events accumulate further (consistent with S13/S14 carry-over)

---

## Section 7 — Drift-watch (S15 PLAN)

- **DR1 (LOC ceiling)**: this PLAN file is informational scope — not a SKILL/command/agent. No D1 implication.
- **DR2 (self-attestation)**: 16 violations claim verified by direct `wc -l` (Section 0 pre-flight); not estimate.
- **DR-DEFER**: 0 — Track 7 PLAN proceeding on schedule per S14 close.
- **DR-CONFIG**: settings.json NOT modified in S15 (PLAN session; IMPL changes deferred to S16).
- **DR-PROV**: every claim in this plan maps to a session log line, decision § section, agent-notes entry, or queued-grill item. Provenance log:
  - § 1.1 → S13 IMPL-S13-1 + L-S14-4
  - § 1.2 → S11 IMPL-S11-2 + S12 IMPL-S12-1 + S14 IMPL-S14-1
  - § 2 (promotion routing) → agent-notes L-S11-1, L-S11-2, L-S12-1, L-S12-2, L-S13-1, L-S13-2, L-S14-1, L-S14-2, L-S14-3, L-S14-4
  - § 3 (queued-grill batches) → `observations/queued-grill-master.md` Q-B2/C2/C3/D3/E1/E2/E3/E4/2.1
  - § 4 (S16 deliverables) → composed from § 1+2+3 above; no novel scope
- **DR-IDENTITY**: stockforge identity preserved. Track 7 = constitution port from agent-notes/lessons; harness-engineering layer; no biz-logic touch.

---

## Section 8 — Estimated S15 tokens (post-pre-flight)

- Pre-flight reads: ~30K (checkpoint + current-execution + S14 log + agent-notes + decisions + queued-grill + project.md + drift baseline + decision prose)
- This PLAN composition: ~20K
- AskUserQuestion Batch 1-3 (9 items, multi-batch): ~5K
- Folding answers + final tweaks: ~5K
- SessionEnd protocol writes: ~10K

**Subtotal estimate**: ~70K self-track. Within ~80K PLAN target.

---

## Appendix A — File creation order for S16 IMPL

S16 SessionStart should:
1. Read this plan
2. Read S15 session log
3. Read queued-grill-master answers (if Batch 2 + 3 carried)
4. Compose IMPL execution sequence:
   - Step 1: D-003 + D-005 amendments (mechanical; ≤5 min)
   - Step 2: NEW `bash-hook-lint.sh` + smoke-test
   - Step 3: Wire 3 hooks to settings.json (Stop block)
   - Step 4: Compose `proposals/<file>.md` drafts (one per item in 4.2)
   - Step 5: Skill + memory amendments (mechanical; ≤10 min)
   - Step 6: Run drift-signals; verify ≤16 D1
   - Step 7: Write `promotion-routing-S16.md` summary
   - Step 8: Update current-execution.md + write session log + checkpoint

Estimated S16 budget: ~150K (FOCUSED_IMPL).

---

## Appendix B — IMPL-tier autonomy reservations (S16)

Per L-S11-2 IMPL-tier-resolution-doctrine, S16 agent has IMPL discretion on:
- Exact LOC distribution within budgets above (e.g., 175 vs 180 for `bash-hook-lint.sh`)
- Whether to bundle hook-wire-ins into one settings.json edit or three separate Edits
- Whether `proposals/architecture.md` amendment sits inline vs in a `references/` companion
- Final text wording within constitution drafts (subject to stockforge identity-scope coherence)

Items requiring explicit user pick (CHARTER-tier per Q-B2 incoming answer):
- Charter-tier amendments — `proposals/decision-discipline.md` and `proposals/autonomous-protocol.md` likely require explicit user approve before move from `proposals/` to `constitution/`. Per `agent-workspace/CLAUDE.md` rule 1.

---

End of S15 PLAN draft. Now firing AskUserQuestion Batch 1 to surface foundational queued-grill items.
