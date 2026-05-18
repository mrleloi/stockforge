# Chapter 9 — The Quality System

> **Diataxis quadrant**: Explanation + Reference
> **Reading time**: ~35 minutes
> **Prerequisites**: Chapter 6 (Hooks), Chapter 8 (Lifecycle)

The quality system is the harness's verification layer. It is what enforces "this work is actually done" — at three different cadences, by three different mechanisms, with three different escalation paths.

This chapter covers:

- The 3-tier quality gate model
- The VBW protocol (Verify-Before-Write)
- Drift signals DR1-DR12 + DR-S
- Harness health signals HH-1..HH-12
- Charter Principle 11 and how it shapes everything

---

## 9.1 — The 3-Tier Gate Model

Per CLAUDE.md § Quality Gates, every change passes through three tiers of verification:

### Tier 1 — Deterministic (Per Commit, Auto-Block on Fail)

Mechanism: deterministic scripts that exit 0 (pass) or non-zero (fail). No LLM judgment. Auto-blocks the commit if any fails.

Checks:
- `mypy --strict` — type checking, strict mode
- `pytest` — full test suite
- `ruff` — lint + format check
- `drift-signals-D1-D9.sh` — drift catalog (HIGH severity blocks)
- Dependency cycle check (manual `pydeps` invocation)
- `bash-hook-lint.sh` — for any modified hook scripts

Configuration: `STOCKFORGE_LOC_STRICT`, `STOCKFORGE_DRIFT_STRICT`, `STOCKFORGE_CITATION_STRICT` env vars in `settings.json`. Default: warn-only; strict mode: block on fail.

Where output goes: `agent-workspace/quality-reports/deterministic/<TS>.md` (placeholder — actual outputs route into session logs per current state).

### Tier 2 — Probabilistic (Per Merge, Separate Agent)

Mechanism: LLM-mediated checks dispatched in a fresh-context subagent. Returns a verdict, never auto-blocks; main session decides action.

Checks:
- `/vbw-check` — Verify-Before-Write protocol applied to current task
- `/drift-check` — semantic drift signals (DR7 UL drift, DR12 anti-pattern)
- `/devils-advocate` — adversarial critique of plan/spec/code
- `intent-vs-impl-diff` subagent at phase boundary — catches silent absorption
- Architecture boundaries check (manual via `/drift-check`)
- UL consistency check (via `/ul-audit` → `ul-auditor` subagent)
- Code review (Tier 2 sandwich-verifier in canonical workflow)
- **Calibration drift check** — confidence claims vs hit rate

Where output goes: `agent-workspace/quality-reports/probabilistic/<TS>.md` (placeholder; actually routes to verifier session logs + observations).

### Tier 3 — Human (Per Phase Boundary or Strategic Decision)

Mechanism: explicit user ratification via `AskUserQuestion`.

Required for:
- Architectural decisions (CHARTER-tier ratify)
- API contracts (SCOPE-tier ratify)
- Eval regression sign-off
- Thesis quality review
- Constitution amendments (ratification + cool-down)

Where output goes: `human-workspace/decisions/<file>.md`.

### Why Three Tiers

Each tier catches a different failure class:

| Failure class | Caught by |
|---|---|
| Syntax error / type mismatch / failing test | Tier 1 |
| Logical inconsistency / hidden assumption / missed edge case | Tier 2 |
| Wrong direction / scope drift / strategic misalignment | Tier 3 |

Skipping Tier 1 = bugs ship. Skipping Tier 2 = good code that does the wrong thing. Skipping Tier 3 = wrong product.

---

## 9.2 — VBW Protocol (Verify-Before-Write)

Measured: 11.1% hallucination rate before VBW adoption → 0% after.

### The Core Problem

LLMs tend to write code from **memory/convention** rather than from **verified source**. When the agent "knows" a common pattern, the brain auto-completes from convention without cross-referencing actual implementation.

Observed failure modes:
- Writing methods that don't exist: `enable_kill_switch()` (agent invented from "kill switch" mention)
- Wrong argument counts: `create(4 args)` when actual is `create(6-7 args)`
- Method name from convention: `clear_domain_events` vs actual `clear_events`
- Import paths guessed from pattern

Result: code looks right, doesn't match reality, breaks silently or at runtime.

### The Four Checkpoints

| Checkpoint | When | Required Actions |
|---|---|---|
| **PRE-SPEC** | Before writing any specification | Read the ACTUAL source code; list ALL methods of the relevant entity from code; verify factory method signature (exact param count and types); check if feature already exists (grep before assuming "missing"); mark spec items as CURRENT (exists) vs PROPOSED (to implement) |
| **PRE-TEST** | Before writing any test | Verify every method call exists (check type definitions); verify factory signature (exact params from reading `create()` source); verify import paths (grep for actual file location); verify base class methods (read entity/aggregate base); test one file first (type check before writing more) |
| **MID-IMPLEMENT (every 5 steps)** | During session | Cross-reference against spec (still aligned?); check plan state; review recent edits for convention-derived assumptions; re-read task description (5 minutes of re-read saves hours of wrong direction) |
| **PRE-COMMIT** | Before staging changes | Verify diff matches plan; mypy/pytest/ruff pass; no new D1-D9 drift signals |

### How It's Operationalized

Every sandwich plan has a **STEP 0 — VBW Live Verification** section. Both architect AND dev MUST execute STEP 0 before any production work:

```markdown
## C — VBW STEP 0 (Live Verification)

C.1 — Path existence verification
- Glob: `packages/application/fundamental/pdf_table_extractor_port.py`
  Expected: exists, ~120 LOC
  Verified: ✓ (S407)

C.2 — Signature verification
- Read: `packages/application/fundamental/pdf_table_extractor_port.py:42-78`
  Expected: `class PdfTableExtractorPort(Protocol):`
    `def extract_tables(self, pdf_path: Path, *, max_pages: int = 100) -> list[dict]: ...`
  Verified: ✓

C.3 — Caller verification
- Grep: `import PdfTableExtractorPort`
  Expected matches: `apps/dashboard/fundamental_view.py`, `tests/fundamental/test_pdf_*.py`
  Verified: 2 callers found
```

If STEP 0 surfaces a mismatch (e.g., cited path does not exist), the plan is rewritten OR the dispatch is aborted.

### Red Flags That Trigger Mid-Implement Check

- Wrote 3+ files in a row without running tests
- Made assumption about API not verified from code
- Plan section being implemented diverges from initial reading
- Dispatch brief cites a path that grep can't find

---

## 9.3 — Drift Signals DR1-DR12

Drift signals are deterministic checks for architectural decay. Run via `/drift-check` command + auto-fired on Stop via [`drift-signals-D1-D9.sh`](06-hooks.md#drift-signals).

### Tiered Coverage Map (D-029 / S48d ratification)

**Tier-A — Automated detector** (Stop-hook `drift-signals-D1-D9.sh`):

| Signal | Maps to | What |
|---|---|---|
| DR-A1 | formerly D1 | LOC ceiling overrun (PRIMARY per Q-A2; HIGH at >20%) |
| DR-A2 | formerly D2 | Self-attestation contradicting actual file content |
| DR-A3 | formerly D3 | Charter/SCOPE bundled with sub-charter items |
| DR-A4 | formerly D8 | Confidence claim without calibration metadata |
| DR-A5 | formerly D9 | Runtime-path-leak into write-only learning-data tree |
| DR1 | NEW S48c HH-B.4 | Domain layer imports framework (grep `packages/domain/**`) |
| DR3 | NEW S48c HH-B.4 | LLM call without retry/budget wrapper (grep `packages/infrastructure/**`) |
| DR6 | NEW S48c HH-B.4 | `Any` type in domain package |
| DR8 | NEW S48c HH-B.4 | Cross-BC direct import |
| DR-S1 | covered by D6 | LLM emitted number without tool call |
| DR-S2 | covered by D7 | Thesis output without bear case |
| DR2 | PARTIAL via D5 | Evidence without citation |
| DR5 | PARTIAL via D5 | Claim stored without metadata |
| DR10 | PARTIAL via D4 | Spec dangling reference |

**Tier-B — Manual `/drift-check` command** (semantic, LLM-judgment):

| Signal | What |
|---|---|
| DR4 | Hardcoded prompt outside `prompts/` |
| DR7 | UL term drift (also via `/ul-audit`) |
| DR12 | Anti-pattern from `agent-notes.md` |

**Tier-C — DB-query check** (requires Postgres connection):

| Signal | What |
|---|---|
| DR9 | Synthesis output without verifier step |
| DR11 | Stale session-handoff (also git-log diff-able via Tier-A heuristic) |

### HIGH Severity Signals (Block Commit/Merge)

| Signal | Rule |
|---|---|
| **DR1** | Domain layer imports framework |
| **DR2** | Evidence without citation |
| **DR5** | Claim stored without required metadata |
| **DR6** | `Any` type in domain package |
| **DR-S1** | LLM emitted number without tool call |
| **DR-S2** | Thesis output without bear case |
| **DR-A1** | LOC ceiling overrun (>20%) |

### Example: DR1 Check

```bash
grep -rn "from fastapi" packages/domain/ --include="*.py"
grep -rn "from pydantic" packages/domain/ --include="*.py"
grep -rn "from sqlalchemy" packages/domain/ --include="*.py"
grep -rn "import psycopg" packages/domain/ --include="*.py"
grep -rn "from redis" packages/domain/ --include="*.py"
```

Any match = HIGH severity. Fix: move framework-dependent code to `infrastructure/`. Define a Protocol in `domain/application`, implement adapter in `infrastructure/`.

### Drift Log Flow

```
Hook fires → write to .drift-signals.log
  ↓ Stop chain
drift-rollup-daily.sh (idempotent per day)
  ↓ promotes to drift-logs/YYYY-MM-DD-rollup.md
  ↓ Stop chain (MUST run AFTER rollup)
drift-signals-log-rotate.sh
  ↓ weekly rotate
  ↓ archive to drift-signals-archive/<week>.log
```

---

## 9.4 — Harness Health Signals HH-1..HH-12

The harness's *self-monitoring* signals. Codified in [`harness-health-protocol.md`](../../../agent-workspace/constitution/harness-health-protocol.md). Implemented inline by [`harness-health-self-scan.sh`](06-hooks.md#harness-health-self-scan).

### Why HH-* Exists (Charter Principle 11)

Phase 2.5 closed 8 of 8 tracks GREEN at ritual audit. Fourteen sessions later, three empirical failures surfaced — all detected via user push, not via harness self-detection:

1. **M-S49b-1**: `autonomous-stop-watchdog.sh` wired + smoke-test pass; logs show 0 `Stop session=` entries across 10 turns.
2. **Promote-rule backlog**: 6+ sessions accumulated agent-notes entries without `promotion-cycle-trigger.sh` firing.
3. **Auto-detect orphans**: ~20 entries tagged `Auto-detect: yes` with no companion shipped hook.

Each was structurally complete but **empirically broken**. The HH-* catalog is the deterministic answer: continuously verify hooks actually fire in production logs.

### The 12 Signals

| # | What | Severity | Threshold |
|---|---|---|---|
| **HH-1** | Stop hook fires ≥1 time per active session | HIGH (KI-S49b-1 suppress: MEDIUM) | STOP_COUNT ≥ 1 since latest SessionStart for current SID |
| **HH-2** | UserPromptSubmit fires ≥1 time in last 10 min | HIGH | RECENT ≥ 1 in last 10 minutes |
| **HH-3** | Promote-rule cycle delta < 8 sessions (≤10 days) | MEDIUM (HIGH at 14d+) | Latest `promote-rule-S*.md` mtime within 10 days |
| **HH-4** | Auto-detect candidates without companion hook ≤ 2 | MEDIUM | `Auto-detect: yes` count - hooks count ≤ 2 |
| **HH-5** | Tier 1 always-loaded ceiling ≤ 8K tokens | HIGH | Combined token estimate of Tier 1 ≤ 8000 |
| **HH-6** | Hook dispatch sidecar staleness | MEDIUM | Latest dispatch sidecar mtime < threshold |
| **HH-7** | Checkpoint freshness (latest.md mtime ≤ 1800s) | MEDIUM | `now - mtime < 1800s` |
| **HH-8** | Charter file md5 stability during cool-down | MEDIUM | Charter md5 unchanged during proposal cool-down |
| **HH-9** | Mistake-log freshness | MEDIUM | mistake-log.md not stale relative to recent sessions |
| **HH-10** | Firing-test orphans ≤ 2 | MEDIUM | Hooks without companion firing-tests ≤ 2 |
| **HH-11** | Hook firing log mtime < threshold | LOW | Recent hook activity present |
| **HH-12** | project.md Phase == current-execution.md Phase | MEDIUM | Phase field consistent across files |

### Execution Order (Cheap-First)

Per [`harness-health-self-scan.sh`](06-hooks.md#harness-health-self-scan), HH checks are ordered by computational cost:

1. HH-7 (single mtime check)
2. HH-11 (single mtime check)
3. HH-8 (md5)
4. HH-1 (log grep)
5. HH-2 (log grep with time bucket)
6. HH-9 (log grep)
7. HH-3 (find + age)
8. HH-6 (multi-file mtime + tail)
9. HH-4 (grep count + find count)
10. HH-10 (find + comparison)
11. HH-5 (delegated to `tier1-bloat-check.sh`)
12. HH-12 (phase string parse + diff)

### Caching

Same-session cache via `.harness-health-cache-${SID}` with 5-min TTL. On UserPromptSubmit, cache hit avoids re-running full catalog.

### Aggregation States

- **GREEN** — no FAILs
- **YELLOW** — at least one MEDIUM, no HIGH
- **RED-1** — one HIGH
- **RED-2** — two+ HIGH

The state appears in `boot-summary.md` for next-session bootstrap.

### KI Suppression

Per-signal KI clauses (e.g., HH-1 KI-S49b-1 Windows quirk). Suppression elevates severity floor (HIGH→MEDIUM) but does NOT silence the FAIL emission.

---

## 9.5 — Charter Principle 11 in Practice

The principle: *"Harness must self-verify firing, not self-attest existence."*

### How It Shapes Everything

| Decision | Without Principle 11 | With Principle 11 |
|---|---|---|
| New hook shipped | Smoke test passes → declare done | Smoke test + firing-test + production log evidence → declare done |
| Track close | All deliverables in plan present → close | All deliverables present + empirical-firing evidence captured → close |
| Health audit | All scripts exist → green | All scripts emit in production logs within thresholds → green |
| Hook deprecation | Hook still in code → keep | Hook silent for 3+ sessions catch-rate 0 → demote-to-passive or retire |

### Operational Markers

- **Empirical-firing evidence** = production log entry / artifact / telemetry row from real session activity.
- **Ritual closure** = file existence + smoke-test exit 0.

Charter Principle 11 forbids declaring a track closed via ritual closure alone. The empirical evidence must be cited.

### Why It Was Needed

The Phase 2.5 → Phase 3.5 transition surfaced this gap. Three failures all looked structurally complete but empirically broken. The principle is the policy answer; HH-1..HH-12 is the mechanical answer.

---

## 9.6 — The Severity / Escalation Pipeline (Recap)

Detailed in [Chapter 6 § The Severity Pipeline](06-hooks.md#66--the-severity-pipeline). Recap:

```
DETECTORS → severity-classifier.sh (Phase A) → .severity-state.tsv
            ↓
            escalation-engine.sh (Phase B) → .autonomous-BLOCKED + urgent.md + Telegram
            ↓
            autonomous-block-enforcer.sh (Phase C) → DENY tool calls (RC=2)
            ↓
            telegram-push.sh (Phase D) → external push
```

The pipeline is how quality system findings become *user-visible actions*.

---

## 9.7 — Quality Reports

`agent-workspace/quality-reports/` has three subdirectories matching the three tiers:

| Subdir | What goes here | Producers |
|---|---|---|
| `deterministic/` | Tier 1 gate outputs | `drift-signals-D1-D9.sh` rollups, pytest reports |
| `probabilistic/` | Tier 2 gate outputs | `/vbw-check` reports, `/drift-check` semantic outputs |
| `drift-reports/` | Tier-A drift run outputs | `drift-rollup-daily.sh` |

**Current state**: most of these are placeholder directories. Actual gate evidence routes into session logs (Tier-1 deterministic), drift-log rollups (`drift-logs/YYYY-MM-DD-rollup.md`), and VERIFY session logs + observation files (Tier-2 probabilistic). The placeholder subdirectories exist for future centralization.

---

## 9.8 — Calibration Over Confidence (Recap)

The fifth idea from [Chapter 2 § Idea 5](02-mental-model.md#idea-5--calibration-over-confidence).

Where calibration data lives:

| Source | What it tracks |
|---|---|
| `agent-workspace/calibration/` | Per-signal hit rate, KOL accuracy |
| `agent-workspace/memory/sync-tracker/state.tsv` | Per-category Confidence Score |
| `agent-workspace/memory/dispatch.jsonl` | Per-agent-dispatch outcome distribution |
| `agent-workspace/memory/mistake-log.md` | Failure catalog with root cause |
| `agent-workspace/memory/agent-notes.md` | Rules earned through real experience |
| `agent-workspace/memory/attestation-log.tsv` | Sandwich-verifier verdicts |
| `agent-workspace/memory/personal-risk-profile.md` | User's risk tolerance + bias profile |

Per [Boundary B-12](04-constitution.md#boundaries): "Never claim confidence without calibration data."

---

## 9.9 — Common Quality-System Anti-Patterns

| Anti-pattern | What goes wrong | Fix |
|---|---|---|
| Ritual closure without empirical evidence | Principle 11 violation; system structurally complete but broken | Cite production log evidence in close attestation |
| Smoke test passes but hook silent in prod | M-S49b-1 class | HH-1 catches; firing-test reflects actual spawn topology |
| `Auto-detect: yes` tagged but no hook ships | HH-4 orphan accumulation | Promote-rule cycle catches; ship hook |
| Tier 1 bloat past 8K | Every session pays overhead | `tier1-bloat-check.sh` (HH-5) enforces; extract to Tier 2 |
| Verifier same as architect (echo chamber) | Architect's mistakes go unnoticed | Fresh-context verifier (AP-1) |
| Confidence claim without calibration | B-12 violation | Trace to `calibration/` data with n_samples/hit_rate |
| Hand-curated live-audit counts in ADR | L-S333-1 attestation discipline | Quote hook's own emission verbatim |
| Single-shot escalation (one fire, never repeats) | L-S312-1 pattern | Per-artifact marker file + re-emit cadence |
| Age-proxy from immutable timestamp | L-S312-3 pattern | Add `last_transition_at` column, not just `detected_ts` |

---

## 9.10 — Where to Read Next

- **How drift surfaces become rules** → [Chapter 10 — Self-Improvement](10-self-improvement.md)
- **The 23 anti-patterns** in full → [Chapter 12 — Internals](12-internals.md#anti-patterns)
- **Running drift checks** → [Chapter 11 § Audit for Drift](11-cookbook.md#audit-for-drift)
- **Full DR + HH catalogs** → [Reference § Constitution](../reference/inventory-constitution.md)
