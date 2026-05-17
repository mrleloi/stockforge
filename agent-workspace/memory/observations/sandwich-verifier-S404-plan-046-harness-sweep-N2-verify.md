---
type: sandwich-verifier-observation
session: S404
dispatched_by: main session at S403 close turn
agent_id: a61326480a4caba3f
plan_verified: agent-workspace/session-plans/completed/046-S402-harness-stabilization-sweep-N2.md
predecessor_dev: ac6d92e25b7966a6e (S403 sandwich-dev; commits 6d206c3 + b1765c5)
predecessor_architect: a50e338bffabe7a9b (S402 sandwich-architect)
verdict: PASS
merge_eligible: true
critical_count: 0
important_count: 1
minor_count: 2
promotion_candidates: 1
authored_at: 2026-05-17T22:25:00+07:00
note: |
  Content sourced verbatim from S404 verifier task-notification result text.
  Verifier honored D4.A persona override SHIPPED this session (NO observation/session-log
  .md files written by verifier itself; main session inline-persisted per M-S397-1 pattern
  now CANONICAL per D4.A commit 6d206c3 `.claude/agents/sandwich-verifier.md` lines 10-34).
  Verifier appended attestation-log row (TSV bookkeeping ≠ ".md report file"; persona-ALLOWED).
---

# Verification Report — S404 sandwich-verifier (plan-046 harness-sweep-N+2)

## Session Reviewed

- Plan: `agent-workspace/session-plans/completed/046-S402-harness-stabilization-sweep-N2.md`
- Dev observation: `agent-workspace/memory/observations/sandwich-dev-S403-harness-stabilization-sweep-N2.md`
- Architect observation: `agent-workspace/memory/observations/sandwich-architect-S402-harness-sweep-N2.md`
- Dev commit: `6d206c3` (S403 IMPL) + plan-mv commit `b1765c5`

## Overall Verdict

**PASS** — merge eligible. All 8 PROMOTE-NOW sub-tracks (D1+D2+D3.A-D+D4.A-B) ship empirically verified. 2 HOLD entries documented with explicit AP-7 triggers. Promotion queue drained 10→2 successfully (under 8-session HARD-BLOCK threshold).

## V1-V10 Grid Empirical Results

### V1 — D1 dogfood-the-promotion hook (L-S389-1 PROMOTE)
**PASS**. `bash -n` SYNTAX OK; firing-test 5/5 PASS independently re-run; hook logic correct (scans observation files for `STEP X.Y promoted` + `~[0-9]` co-occurrence per DD-1; ±5-line context window; -mmin 5 min filter); emits LOW WARN row to `.severity-state.tsv` non-blocking.

### V2 — D2 stop-finding-frontmatter-validator hook + template (L-S397-2 + PCG-S401-3 PROMOTE)
**PASS**. `bash -n` SYNTAX OK; firing-test 6/6 PASS independently re-run. **Live-run against `human-workspace/notifications/` produced 2 WARN rows**: `STOP-FINDING-S365-corpus-labelling-source.md` (missing severity); `STOP-FINDING-S394-pdf-real-pdfs-needed.md` (missing status). Both WARNs CORRECT per disk evidence. Template `_STOP-FINDING-template.md` (33 LOC) has all 8 required frontmatter scaffold fields + lettered options pattern in Decision-required section.

### V3 — D3.A dispatch-brief VBW pre-flight (L-S392-1 PROMOTE)
**PASS**. `.claude/agents/sandwich-architect.md` STEP 2.X lines 79-96 verbatim requires Glob/Read verification of every cited path + anti-example cites both S392 + S402 brief deviations. DC-IMPL-11 confirmed.

### V4 — D3.B operational-track cold-probe (L-S395-1 PROMOTE)
**PASS**. STEP 2.Y lines 98-119 requires full-pipeline (not wire-only) cold-probe at STEP 0 for operational plans + anti-example cites M-S395-1 compound BR-6/DD-3 blocker. DC-IMPL-12 confirmed.

### V5 — D3.C per-category LOC distinction (L-S397-1 PROMOTE)
**PASS**. Per-category LOC table inserted at lines 171-187 with 5-column distinction (Core code / Docstring/comment / Test / Fixture / Total). Anti-example cites plan-041 + PCG-V400-1 trigger. DC-IMPL-13 confirmed.

### V6 — D3.D close-loop verify (L-S397-3 PROMOTE)
**PASS**. STEP 7.X lines 278-291 (sandwich-architect.md) + STEP 5.6 lines 121-133 (sandwich-dev.md). Both cite M-S397-1 anti-example + require `wc -l` exact integer cite before return summary composition. DC-IMPL-14+15 confirmed.

### V7 — D4.A persona override (PCG-S401-4 PROMOTE) — META-TEST
**PASS — meta-test successful**. `.claude/agents/sandwich-verifier.md` lines 10-34 document Persona Override + M-S397-1 recovery pattern. This very dispatch confirms D4.A discipline working: NOT writing observation/session-log .md files; findings returned inline per persona override. DC-IMPL-16 confirmed.

### V8 — settings.json wiring
**PASS**. JSON parses OK (55 Stop hooks total). Wire order verified verbatim: line 424 severity-classifier.sh → line 428 dogfood-the-promotion.sh → line 432 stop-finding-frontmatter-validator.sh. Hook chain order coherent per plan-046 § F wire-up spec.

### V9 — PYTEST COUNT ANOMALY INVESTIGATION (CRITICAL request)
**RESOLVED — dev claim correct WITHIN scope; full baseline preserved**.
- `python -m pytest packages/ --no-header -q` → **1127 passed, 1 skipped** (matches dev claim exactly)
- `python -m pytest packages/ tests/ --no-header -q` → **1178 passed, 1 skipped** (full baseline preserved)
- 51-test delta is exactly in `tests/unit/` directory tree added during S399 G.3 IMPL (per S400 verifier baseline)
- **Dev's "no regression" was correct WITHIN their pytest invocation scope** (packages/ only); full-project baseline IS preserved.
- Tracking suggestion: M-S403-1 candidate + PCG-V404-1 (HOLD 1st-instance; AP-7 trigger: 2nd-instance dev observation citing pytest count omitting non-packages test directory → promote to dispatch-brief template requiring explicit `python -m pytest packages/ tests/` invocation).

### V10 — Charter compliance + LOC discipline + close-loop
- **Karpathy P3 surgical**: PASS. `git diff --name-only 6d206c3^..6d206c3 | grep -E '(packages/|apps/)' | grep -vE 'test_'` returns empty. Zero production code touched.
- **L-S389-1 dogfood (LOC integers)**: PASS for file LOC. `wc -l` exact match for all 10 cited files.
- **L-S397-1 per-category LOC (core-code count)**: MINOR DISCREPANCY. Dev cited 52+46=98 lines; empirical `grep -cE '^[[:space:]]*[^#[:space:]]'` gives 49+43=92 lines. Both well under 163 ceiling; counting-method nuance only.
- **L-S397-3 close-loop**: PASS. Observation=153 LOC + session-log=87 LOC confirmed via `wc -l`.
- **L-S389-1 dogfood on dev observation itself**: PASS at hook semantics (D1 hook does NOT trigger because S403 obs has no literal `STEP X.Y promoted` string within ±5 lines of `~[0-9]` patterns). However, line 113 of dev obs contains 5 `~` prefixed numbers describing MODIFICATION DELTAS — estimates not absolutes, but technically violate L-S389-1 spirit. MINOR finding.
- **agent-notes.md HOLD entries (DC-IMPL-18)**: PASS. Lines 36-50 contain both L-S389-2 + L-S396-1 HOLD entries with explicit AP-7 revisit triggers.

## Constitution Check

All PASS: 0 PROJECT_CHARTER.md / 0 constitution/ / 0 AOM writes / 0 production code; AP-7 + AP-23 + Karpathy P1-P4 + D-060 all PASS.

## Findings

### CRITICAL: 0
### IMPORTANT: 1

**V9 pytest invocation scope discipline gap**: Dev cited "pytest: 1127 passed, 1 skipped" in observation. Independent re-run `python -m pytest packages/ tests/` shows 1178/1. Full baseline 1178/1 IS preserved; dev's claim is correct only within `packages/` scope. Impact: low (no actual regression), but 1st-instance "dev pytest invocation incomplete — missed `tests/` directory added at S399". Action: surface as M-S403-1 candidate; PCG-V404-1 HOLD 1st-instance per AP-23.

### MINOR (2)

1. **Per-category core-code LOC count discrepancy (D1+D2)**: dev 52+46=98; empirical 49+43=92. Both well under 163 ceiling. Counting-method nuance only.
2. **Dev observation line 113 contains 5 `~` prefixed numbers in "modified files net additions" descriptor**: line 113 "Modified (net additions): ~8 (settings) + ~80 (architect) + ~14 (dev) + ~47 (verifier) + ~38 (agent-notes) = ~187 LOC net additions". D1 dogfood hook does NOT fire (no `STEP X.Y promoted` literal within ±5 lines). Violates L-S389-1 spirit but not hook semantics; M-S388-1 dogfood was about absolute LOC, not delta estimates.

## Promotion Candidates Surfaced This Session

**1 candidate** (V9 finding): **PCG-V404-1** (HOLD 1st-instance): dev pytest invocation scope discipline — must include both `packages/` AND `tests/` directories. AP-7 trigger: 2nd-instance promote to dispatch-brief template requiring explicit `python -m pytest packages/ tests/` invocation.

## Close-Loop Compliance Note (L-S397-3 + D4.A persona override)

Per D4.A persona override section now CANONICAL in `.claude/agents/sandwich-verifier.md` lines 10-34, sandwich-verifier MUST NOT write observation/session-log .md files. Honored:
- NO observation .md written by verifier
- NO session-log .md written by verifier
- Findings returned inline in final assistant message per M-S397-1 main-inline-persist pattern (now canonical per D4.A)

Attestation-log row appended (TSV bookkeeping is explicitly ALLOWED per persona):
`2026-05-17T22:25:00+07:00\tsandwich-verifier-S404-plan-046-harness-sweep-N2-verify\tNA\tNA\tNA\tPASS`

## Recommendation

**MERGE eligible**. Plan-046 IMPL complete + verified empirically. Promotion queue drained 10→2 with documented HOLD triggers. Wire-up coherent. No regressions in full-project pytest baseline (1178/1 preserved). All 8 PROMOTE-NOW sub-tracks ship with companion firing-tests + verification grids. V9 invocation-scope finding non-blocking; tracked as PCG-V404-1.

Specific next-actions for main session: (1) inline-persist this verification report (DONE per main-this-turn), (2) write session-log S404 with V1-V10 grid summary, (3) optionally append M-S403-1 + M-S404-NONE digests, (4) fix STOP-FINDING-S394 status field (D2 hook live-run flagged), (5) commit, (6) dispatch G.4 follow-on per S405 architect return.
