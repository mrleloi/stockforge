---
plan_id: 011-S67-harness-self-upgrade-burst
phase: 3
parent_plan: agent-workspace/memory/routing-config.md + Plan 010 follow-up
sessions_covered: S67 (D1+D2+D3+D5 dispatch shipped pre-/clear; checkpoint under-recorded) + S68 (empirical re-verify + D6 inline + memory close)
authoring_session: S67 (post-S67-dev-dispatch-attestation)
status: COMPLETE — All P0 (D1+D2+D3+D5) + P1 (D6) shipped + verified. D4 deferred Plan 012. D7 DOCUMENTED-PASSIVE per AP-23. D8 PENDING-USER-RATIFICATION.
priority: P0 — harness self-upgrade > product (user directive 2026-05-06; L-S65-2 binding)
estimated_envelope: 100-150K main + 30-60K subagent (S67 ~70-90K main + ~80-120K subagent shipped D1+D2+D3+D5 before kill; S68 ~30-50K main consume + D6 inline)
related_predecessor: 010-S65-harness-upgrade-burst (status: COMPLETE; 7/7 D1-D7 shipped)
s67_outcome: D1 SHIPPED + dogfood-fix-cycle (3 iteration-bugs L-S52-3); M-S67-1 + M-S67-2 cataloged. SUBAGENT also shipped D2+D3+D5 before kill but checkpoint under-recorded → M-S67-3.
s68_outcome: Empirical re-verify confirmed D2+D3+D5 shipped + 38/38 firing-tests PASS + 322 BC pytest + 767+3skip full. D6 (etl-queue producer wiring) shipped inline + 7/7 firing-test PASS post-iteration-fix (L-S68-2 find pipefail bug fixed in lesson-synthesis-watchdog.sh as side effect).
---

# Plan 011 — Harness Self-Upgrade Burst #2

> Author per user directive 2026-05-06: "ưu tiên harness config/settings luôn là quan trọng nhất, nhất là để nó tự self-upgrade được". Goal not just close S65/S66 deferred items but enable the lesson-synthesizer / promote-rule loop to actually find new patterns autonomously from existing tracing data.

## Scope (8 deliverables; priority-ordered)

### Strategic frame

Plan 010 shipped operational hooks (pre-dispatch ADR check, cost-ledger, reboot summary, effort detector, drift schedule, etl-queue scaffold, profile-card rebuild trigger). What Plan 010 did NOT do: (a) close M-S66-1 / M-S66-2 deterministic prevention; (b) fix tracing-data quality so an LLM-driven analyst can ACTUALLY parse it autonomously; (c) build cross-reference manifests an LLM lesson-synthesizer needs to navigate; (d) wire producers into the etl-queue. Plan 011 = "make the self-upgrade loop actually closeable end-to-end".

### Empirical state at S67 entry (verified 2026-05-06)

- **Hook scripts in `scripts/hooks/`**: 64 (excl firing-tests/)
- **Wired in `.claude/settings.json`**: 57 unique
- **Real orphans (8)**: `diagnostic-pretooluse-stash.sh` + `diagnostic-subagentstop-stash.sh` (intentional stubs); `sync-tracker-render.sh` + `sync-tracker-update.sh` + `subagent-budget-classifier.sh` (helpers — verify call-sites); `metric-failure-mode-rate.sh` + `redact-secrets.sh` + `same-commit-rule.sh` (3 unwired with intent — D9 triage)
- **`cost-ledger.tsv`**: 13 data rows, single-session 2026-05-06 only — foundation works; needs ≥10 sessions/cell to rebuild profile cards
- **`dispatch.jsonl`**: 121 rows; many agent_type="unknown-agent" + model="unknown" → recorder parse bug
- **`component-telemetry.jsonl`**: structure OK; `tokens_real:0` frequently → not capturing real token deltas
- **`agent-workspace/memory/etl-queue/`**: empty (only `processed/` + README; no producer wired into queue)
- **`raw-sessions/`**: latest `2026-05-06-session-66.md` — file-naming post-S53 fix working
- **DoD watchdog**: hr_pending=0 sustained S65→S67 (clean)
- **L-S66-1 + L-S66-2**: BINDING manual rules; deterministic hooks DEFERRED at S66 close

### Deliverables

#### D1 — `post-dev-dispatch-attestation-check.sh` (L-S66-1 codify) — P0 ✅ COMPLETE-WITH-3-ITERATION-FIXES (S67 close, 2026-05-06)

**Final state**: Hook + firing-test shipped (post-/clear surviving artifacts). Eat-own-dogfood against `sandwich-dev-S67-BC-7-track-K.md` legacy observation caught 3 bugs (line 67 multi-line int / wrong BC6 paths / legacy fallthrough). Fixed in-session per L-S52-3 success-path. Re-firing-test 8/8 PASS; re-dogfood WARN+exit 0 (correct). SubagentStop wired `.claude/settings.json` line 448. Attestation log initialized at `agent-workspace/memory/attestation-log.tsv` (1 BLOCK row from pre-fix iteration; informational).

**Why**: M-S66-1 root-cause prevention. Sonnet 4.6 sandwich-dev returned false-attestation observation (claimed 85 PASS / actual 8 FAIL + 164 PASS). Manual main-session re-verify caught it; deterministic hook prevents recurrence even if main session forgets the rule. Just exercised SUCCESSFULLY at S67 entry (caught Explore agent's "63 orphan" hallucination via empirical verify).

**Hook**: `scripts/hooks/post-dev-dispatch-attestation-check.sh` (SubagentStop on `sandwich-dev`)
**Logic**:
1. Read latest observation file matching `agent-workspace/memory/observations/sandwich-dev-S<N>-*.md` (newest mtime)
2. Parse claim: extract `tests_passed:` + `tests_failed:` + `mypy_clean:` from observation frontmatter (require structured fields per L-S66-1 binding)
3. Empirical re-run: `pytest <bc-paths>` extracted from sub-plan reference; `mypy --strict <bc-paths>`; `find <bc-paths> -name "*.py" -not -path "*/__pycache__/*" | wc -l`
4. Diff observation claim vs empirical
5. If divergence > tolerance (`tests_passed` differs by ≥1, file count differs by ≥3) → emit JSON block with `decision: "block"` + diagnostic
6. Append marker file `agent-workspace/memory/.attestation-checked-<dispatch_id>` so main session can read
7. Append row to `agent-workspace/memory/attestation-log.tsv` (fields: ts | dispatch_id | observation_claim_passed | empirical_passed | divergence | verdict)

**LOC budget**: ≤180 LOC + ≤8 TC firing-test
**Saving**: 1 M-S66-1-class catastrophe per ~10 dispatches (~30-50K main fix-cycle + 39-file revert risk)
**Acceptance**: TC1 ground-truth match → no warn; TC2 +5 PASS divergence → block; TC3 file-count divergence → block; TC4 no observation file → exit 0; TC5 missing pytest binary → graceful skip with WARN; TC6 observation has unstructured (legacy) format → emit upgrade-prompt; TC7 dispatch_id mismatch → exit 0; TC8 strict-mode env `STOCKFORGE_ATTESTATION_STRICT=1` → block on warn-only conditions
**Rollback**: kill switch `STOCKFORGE_ATTESTATION_DISABLE=1`

#### D2 — `dispatch-jsonl-recorder.sh` agent_type/model parse fix — P0 ✅ COMPLETE-VERIFIED-S68 (shipped S67 dispatch; under-recorded; verified empirical S68 — 12/12 firing-test PASS)
**Why**: 121 dispatch rows, ~70% have `agent_type:"unknown-agent"` + `model:"unknown"`. This data is foundation for cost-per-agent histogram + A/B test outcomes + lesson-synthesizer routing analysis. Currently UNUSABLE for LLM autonomous synthesis.

**Fix**: existing `scripts/hooks/dispatch-jsonl-recorder.sh`
**Logic** (additive, per L-S43f-2 lean):
- Read CLAUDE_TOOL_NAME + CLAUDE_TOOL_INPUT env vars (PreToolUse path)
- Parse `subagent_type` field from tool-input JSON (jq-free per L-S11-1 portability; bash + grep/awk)
- Map `subagent_type` → known list (`sandwich-architect|sandwich-dev|sandwich-verifier|...`); fallback `unknown-agent`
- For COMPLETED event (SubagentStop): cross-ref the DISPATCHED row's `dispatch_id` for stable agent_type
- Model resolution: read `.claude/agents/<subagent_type>.md` frontmatter `model:` field; cache in `agent-workspace/memory/.dispatch-model-cache.tsv`

**Backfill option**: add `dispatch-jsonl-backfill.sh` one-shot (read 121 historical rows; cross-ref observation files in `agent-workspace/memory/observations/` to recover agent_type by filename pattern `sandwich-<role>-S<N>-*.md`)

**LOC budget**: ≤120 LOC delta + ≤6 TC firing-test (additive to existing tests)
**Saving**: enables A/B test result computation per Plan 010 routing-config (currently TBD due to data gap)
**Acceptance**: TC1 sandwich-architect dispatch → row has correct agent_type+model; TC2 ToolUse without subagent_type field → fallback "unknown-agent"; TC3 multi-dispatch in same session → distinct dispatch_id rows; TC4 backfill script processes existing 121 rows → ≥80% recovered

#### D3 — `component-telemetry.sh` tokens_real capture audit — P0 ✅ COMPLETE-VERIFIED-S68 (shipped S67 dispatch; verified S68 — 10/10 firing-test PASS)
**Why**: tokens_real=0 frequently observed. Without real token deltas, cost-ledger underestimates main-session cost (currently only Stop-event reads transcript-tokens), and per-tool cost histogram (Read vs Bash vs Agent) cannot be built.

**Fix**: `scripts/hooks/component-telemetry.sh` (existing; ~340 LOC per L-S10-1 ERR-trap-aware refactor)
**Logic**:
- Verify `CLAUDE_TOKENS_INPUT` / `CLAUDE_TOKENS_OUTPUT` env vars actually populated by Claude Code 4.x harness (empirical probe via diagnostic-pretooluse-stash.sh — already orphaned + ready for activation)
- If env vars unavailable: fall back to `.transcript-tokens` mtime delta (already used by budget-watchdog)
- Add `cache_read_tokens` / `cache_creation_tokens` columns (currently only `tokens_real` summed) — splits enable cache-hit-rate analysis per S65 cost-ledger schema

**Acceptance**: TC1 PostToolUse with non-zero env → row has tokens_real > 0; TC2 env unavailable → fall back graceful; TC3 cache_read present → captured; TC4 firing-test re-runs existing 6 TCs → no regression

**LOC budget**: ≤80 LOC delta + 4 NEW TCs to existing fire-test
**Saving**: enables true cost-per-tool histogram for routing decisions

#### D4 — `brief-template-generator.sh` (L-S66-2 codify) — P1
**Why**: Manual rule "include explicit Negative Scope when next-track exists" is rule-dependent on dispatcher discipline. Auto-generation removes this risk.

**Action**: NEW script `scripts/hooks/brief-template-generator.sh` (CLI utility, NOT a hook event handler)
**Logic**:
- Argument: `--sub-plan <path> --current-track <id> --next-track <id>` (e.g. `--current-track S52 --next-track S53`)
- Parse sub-plan markdown for `## S<N> Deliverables` sections; extract file paths from bullet lists
- Emit Negative Scope markdown block for inclusion in dispatch brief
- Bonus: emit Positive Scope summary (current track files only) for brief consistency

**LOC budget**: ≤140 LOC + ≤6 TC firing-test (CLI invocation)
**Saving**: 1 M-S66-X-class scope creep per ~5 IMPL dispatches (S52 was 39-file revert ≈ ~50K main)
**Integration**: orchestration step — when main session prepares sandwich-dev dispatch brief, invoke this CLI; paste output verbatim into brief
**Acceptance**: TC1 sub-plan with both S52+S53 sections → emit Negative Scope listing all S53 file paths; TC2 missing next-track → exit 0 + WARN; TC3 malformed sub-plan → graceful error message; TC4-6 edge formatting cases

#### D5 — Machine-readable cross-reference manifests — P1 ✅ COMPLETE-VERIFIED-S68 (shipped S67 dispatch; verified S68 — 8/8 firing-test PASS; manifests rendered: 67 hooks / 66 lessons / 31 mistakes / 32 ADRs at S68 audit)
**Why**: Lesson-synthesizer / promote-rule subagent currently CANNOT navigate `agent-notes.md` ↔ `mistake-log.md` ↔ `decisions/` ↔ `scripts/hooks/` ↔ `firing-tests/` because cross-refs are unstructured prose. Result: each synthesis dispatch must re-grep the same N references, burning tokens. Manifests = "URL registry" the LLM can query as deterministic input.

**Files** (NEW; under `agent-workspace/memory/indexes/`):
- `hook-registry.tsv` (cols: hook_name | wired_events | status[ACTIVE|ORPHAN|STUB] | linked_lessons | firing_test_path | last_modified)
- `lesson-registry.tsv` (cols: lesson_id | date | severity | hook_codified[YES|PARTIAL|NO] | hook_path | mistake_link | charter_promoted)
- `mistake-registry.tsv` (cols: mistake_id | session | severity | prevention_status[HOOK|MANUAL|OPEN] | hook_path | recurrence_count)
- `decision-registry.tsv` (cols: adr_id | session | tier[CHARTER|SCOPE|IMPL|ARCH] | status | promoted_to[hook|skill|charter|none])

**Renderer hook**: `scripts/hooks/index-registry-renderer.sh` (Stop-event; recompute on session close)
**LOC budget**: ≤220 LOC renderer + ≤8 TC firing-test
**Saving**: lesson-synthesizer dispatch tokens drop ~30K → ~10K per cycle (6× reduction); enables future ETL-based pattern-mining queries
**Acceptance**: TC1 fresh repo state → 4 manifests rendered with correct row counts; TC2 add new lesson → manifest updates; TC3 missing field → emit WARN + skip row; TC4-8 schema validation

#### D6 — etl-queue producer wiring — P1 ✅ COMPLETE-WITH-1-ITERATION-FIX-S68 (3 producer edits inline; firing-test 7/7 PASS post-fix; L-S68-2 pre-existing watchdog `find` pipefail bug fixed as side-effect)
**Why**: Plan 010 D6 shipped queue + processor scaffolds; ZERO producer hooks queue jobs into it. The queue is a dead pipe.

**Producers to wire** (3):
- `lesson-synthesis-watchdog.sh` (existing): on ≥8 new lessons accumulated, queue `lesson-synthesizer-dispatch.job` instead of HARD-BLOCK
- `profile-template-auto-populate.sh` (existing): on ≥10 cost-ledger samples per cell, queue `profile-card-rebuild-<cell>.job`
- `index-registry-renderer.sh` (NEW from D5): on session close, queue `manifest-render.job` (low priority — runs background)

**Modifications**: 3 hook scripts get ≤30 LOC additions each; jobs go to `agent-workspace/memory/etl-queue/<timestamp>-<task>.job` with YAML payload
**LOC budget**: ≤90 LOC delta total + 4 TC additions to existing fire-tests
**Saving**: deferred-work pipeline activates; lesson-synthesizer dispatch becomes async + non-blocking

#### D7 — Scheduled drift-detector cron actually scheduled — P2
**Why**: Plan 010 D5 documented cron intent; verification at S67 entry shows `.drift-detector-due` marker (455 bytes 2026-05-06 07:52) but no CronCreate routine actually scheduled. The "6h soft trigger" is currently passive (only fires when Stop hook detects elapsed time).

**Action**:
- Decide: keep passive (Stop-hook elapsed-time check) OR active (CronCreate routine)
- If active: CronCreate `drift-detector-6h` schedule `0 */6 * * *` dispatching `drift-detector` subagent fresh-context with brief from `agent-workspace/memory/drift-logs/` history
- If passive: document explicit decision; close Plan 010 D5 as "passive-only by design"

**Decision**: PASSIVE (per L-S43f-2 + AP-23 LLM-Guardian-creep avoidance — running cron LLM dispatches when no human is in loop violates AP-23). Document this in routing-config.md § 9.

**LOC budget**: 0 (documentation update only)

#### D8 — Orphan triage decision (3 unwired-with-intent hooks) — P2 ✅ DEFERRED-PHASE-BOUNDARY-S68 (user ratified A: defer all 3)
**Why**: `redact-secrets.sh` (security guard not enforced); `same-commit-rule.sh` (spec ↔ code coupling rule not enforced — but NO commits per CLAUDE.md hard rule, so possibly moot); `metric-failure-mode-rate.sh` (Karpathy framing metric tied to learning-data/events ndjson — currently inactive corpus).

**S68 user ratification (2026-05-06 AskUserQuestion bundle Q1)**: pick **A — Defer all 3 to phase boundary**. Per Plan 011 spec default proposal — no immediate wiring; revisit at next phase boundary or when triggers materialize (raw exports requirement, git-commit cadence change, learning-data corpus ≥60 events). Plan 011 D8 closed.

## Verification (DoD)

Per deliverable:
- [ ] Hook script written + bash-syntax-check (`bash -n`)
- [ ] Companion firing-test (≥6 TC) ≥1 positive + ≥3 negative cases — per L-S51-1 + L-S52-3
- [ ] firing-test 100% PASS first iteration OR fix-cycle within same session per L-S52-3
- [ ] bash-hook-lint clean (no NEW violations vs baseline 11; current 11 known)
- [ ] real-data smoke test (per L-S52-3): run hook against actual current state, not synthetic stub

Integration:
- [ ] Production smoke: full hook chain fires on synthetic test session (D1+D2+D3+D5)
- [ ] Tier 1 gate: pytest BC-7 172/172 + BC-6 150/150 (no regression)
- [ ] mypy --strict + ruff: unchanged
- [ ] `agent-workspace/memory/etl-queue/` shows ≥1 producer-driven job (D6 verification)
- [ ] `agent-workspace/memory/indexes/*.tsv` rendered with row counts > 0 (D5 verification)
- [ ] `dispatch.jsonl` post-D2 shows agent_type + model populated for ≥3 NEW dispatches

Memory close (after burst):
- [ ] `routing-config.md § 9 + § 10` updated with Plan 011 status
- [ ] M-S66-1 + M-S66-2 status: HOOK-DEPLOYED (post-D1+D4)
- [ ] L-S66-1 + L-S66-2: codification status updated to YES
- [ ] L-S67-1..L-S67-N codified for any pre-deploy iteration-bugs caught (per L-S52-3 success-path doctrine)
- [ ] `current-execution.md` S67/S68 row updated
- [ ] `session-plans/pending/011-...md` → `session-plans/completed/011-...md` (status: COMPLETE)
- [ ] S68 checkpoint with in_flight: empty + harness_burst_011_complete: true

## Rollback paths

- D1 firing-test fails → defer codification, document M-S67-X in mistake-log only; main-session manual rule retained
- D2 parse fix breaks SubagentStop chain → revert; restore prior agent_type="unknown-agent" baseline
- D3 telemetry tokens_real not capturable on Windows Claude Code 4.x → document KI-S67-1 (env var unavailable); fall back to transcript-tokens delta only
- D4 brief generator emits wrong paths → kill switch (don't invoke; manual brief authoring); does not affect Tier 1 gate
- D5 manifest renderer slow on full-corpus → soft-disable Stop-event firing; render on-demand only
- D6 producer wiring causes cascading failures → revert each producer addition individually
- D7 cron decision reversed → CronCreate routine + audit at next phase boundary
- D8 orphan wiring causes false-positive → kill switch per hook

## Provenance

- User directive 2026-05-06 (S67 turn): "ưu tiên harness config/settings luôn là quan trọng nhất, nhất là để nó tự self-upgrade được"
- L-S65-2 harness-priority-one rule (BINDING)
- L-S66-1 + L-S66-2 attestation + negative-scope rules (BINDING; deterministic codification deferred S66 → S67)
- M-S66-1 multi-layer root cause: 25% brief design, 25% routing model, 25% gate skip, 25% harness gap
- Empirical S67 entry probe: 8 real orphans, dispatch.jsonl agent_type parse bug, etl-queue empty, 1-session cost-ledger
- Subagent over-claim case study: Explore agent claimed "63 orphan hooks"; empirical verify (L-S66-1 binding) found 8 — same M-S66-1-class false attestation pattern, this time on harness-state itself rather than test counts
- Charter Principle 8: Calibration over confidence — Plan 011 verification gates must use empirical pytest/find/grep, NOT rely on subagent observation reports
- AP-23 LLM-Guardian creep avoidance: D7 declined active cron; D5 manifests deterministic (bash+awk only)
- L-S11-1 portability: bash + awk + grep only at hook level (NO python3, NO jq, NO yq) — explicit constraint per all D1-D7 + D8

## Sequencing

| Phase | Deliverables | Estimated cost |
|---|---|---|
| Author + sub-plan | D1 spec + D4 spec (binds dev brief) | ~15K main |
| Sandwich-dev dispatch (Sonnet max per S66 routing) | D1 + D2 + D3 + D5 + D6 + brief template | ~80-120K subagent |
| Main verification | post-dev attestation per L-S66-1 (eat own dogfood) + integration smoke | ~30K main |
| Memory close + checkpoint | per CLAUDE.md session-end protocol | ~15K main |

**Hard rules binding S67 → Plan 011 dispatch**:
1. **Sonnet max** for sandwich-dev (per S66 A/B FAIL revert)
2. **Brief Negative-Scope MANDATORY** — explicit list of files NOT to touch (P0 / Plan 011 boundary; Plan 012+ deliverables = next-track)
3. **Post-dev-dispatch attestation MANDATORY** — eat own D1 dogfood the moment D1 is shipped
4. **Pre-dispatch in-flight check** binding (L-S49b-3 + M-S64-1)
5. **Pre-dispatch ADR-number check** binding (L-S65-1; D-033 next available, no new ADR expected unless D5 manifests warrant ARCH-tier)
6. **Harness upgrade priority #1** binding (L-S65-2 + user memory `harness_priority_one.md`)
7. **L-S11-1 portability** — bash + awk only; NO python3/jq/yq at hook level
8. **VBW protocol** mandatory before authoring any new hook (L-S51-1 + L-S52-3)
9. **Companion firing-test discipline** — every NEW hook ships with ≥6 TC fire-test OR fix-cycle within same session

## Open questions for human ratification (AskUserQuestion at Plan 011 entry)

1. **Plan 011 P0 scope (D1-D5) — approve?** Options: A: Approve all 5 P0 / B: Approve D1+D2+D3 only (defer D4+D5 to Plan 012) / C: Approve D1 only (smallest possible burst) / D: Reject — defer entire Plan 011 to next phase
2. **Orphan triage policy (D8)** — Options: A: Wire `redact-secrets.sh` only / B: Wire all 3 with kill-switches / C: Defer all 3 to phase boundary / D: Delete unused orphans (cleanup)
3. **D7 drift-detector cron decision** — Options: A: Active CronCreate every 6h / B: Passive Stop-hook check only (current state — recommended per AP-23) / C: Configurable via env var
4. **Plan 011 envelope tolerance** — given S65-S66 used ~225K main+sub each, Plan 011 estimated 100-150K main + 30-60K subagent: Options: A: OK / B: Cap at 100K main + abort if envelope exceeded / C: Split into Plan 011 (D1-D3) + Plan 012 (D4-D8) for budget hygiene
5. **Profile cards rebuild trigger** — currently `BIASED-PRE-REBUILD-S65` until cost-ledger ≥10 sessions/cell. Options: A: Keep current rule / B: Lower threshold to ≥5 (faster iteration; risk underfit) / C: Add manual trigger via env var

## Self-track for Plan 011 dispatch + verification

- Pre-dispatch in_flight check (S67 close) — empty per S67 dev observation consumed
- Brief Negative-Scope MANDATORY: list files in Plan 010 + S52/S53 deliverables NOT to touch (NO product code in Plan 011 dispatch)
- Eat-own-dogfood: as soon as D1 shipped + tested, USE D1 hook to verify the same dispatch's observation
- Document any pre-deploy iteration-bugs caught at firing-test stage as L-S67-X (per L-S52-3 success-path) — NOT M-S67-X

End of Plan 011 spec. Pending user ratification at S67/S68 boundary.
