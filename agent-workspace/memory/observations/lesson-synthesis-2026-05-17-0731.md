---
session: S365-end (multi-session autonomous window S357→S365 ~30 commits)
agent: lesson-synthesizer (fresh-context dispatch per BP-S43b-4)
date: 2026-05-17
surface: agent-notes
new_entry_id: L-S360-1 + L-S360-2 + L-S365-1 + L-S327-1 (4-rule cluster entry)
novelty: novel-cluster (n=4 instances in single 30-commit window; PROMOTE-NOW threshold met per L-S345-1 + AP-23 3rd-instance promote-or-retire)
severity: HIGH (cluster-level; user-flagged 2× verbatim)
auto_detect: yes (single new Stop hook `main-session-pre-dispatch-discipline.sh` covers all 4 sub-rules)
---

# Lesson-Synthesis Observation — S365-end

## Cluster picked

**"Main-session pre-dispatch self-discipline"** — n=4 instances inside the S357→S365 commit window:

| L-ID | Mistake-log row | What main did wrong | What would have caught it |
|---|---|---|---|
| L-S360-1 | M-S360-1 | Ended turn with "tidy summary" at S360 commit instead of dispatching S361 architect | grep own last assistant turn for `<Agent`/`AskUserQuestion` markers |
| L-S360-2 | M-S360-2 | Quoted Sonnet-column budget (50-80K PLAN) in dispatch to Opus-configured sandwich-architect (actual 165-231K) | `grep '^model:' .claude/agents/<agent>.md` before quoting budget |
| L-S365-1 | M-S365-1 | Reverted 6 agent model assignments AND budget table when user only asked about budget rule | count distinct knobs in user prompt vs fix scope |
| L-S327-1 | M-S327-1 | Treated `dispatch.jsonl` `event:COMPLETED` as authoritative; moved plan pending→completed/; had to revert when agent's actual final exit landed 4 min later | wait for `<task-notification>` OR observation file mtime > ledger ts |

## Target file written

- `agent-workspace/memory/agent-notes.md` — appended 1 cluster entry under `## Recent Rules (digest; last 5)` immediately above the S333 entry. LOC delta: +30 (cluster header + 4 sub-rules + anti-example + correct example + severity + auto-detect + cross-link). Within tracking-retention 700-LOC cap (post-write file ≈738 LOC; over by 38 — flag for digest sweep next ritual-demotion cycle, NOT an emergency).

## Promotion rationale

- **n=3 met**: 4 instances in single window > threshold 3 (L-S345-1 + AP-23 3rd-instance promote-or-retire calculus).
- **HOOK candidate**: All 4 sub-rules deterministically checkable from `.transcript-jsonl` parse + `grep` of agent files + dispatch-ledger join. Per Q-E3 promotion priority (HOOK > SKILL > CHARTER), one new Stop hook `main-session-pre-dispatch-discipline.sh` (~150 LOC + ~80 LOC firing-test) absorbs the whole cluster. Cheaper than 4 separate hooks; cheaper than a SKILL (no judgment needed — pure regex + lookup).
- **Charter NOT touched**: stays at agent-notes / hook tier. No charter amendment proposed (rule does not change invariants, only adds enforcement on existing rules).
- **User-flagged 2×**: M-S360-1 + M-S365-1 had verbatim user corrections. This elevates cluster from MEDIUM to HIGH severity per "user verbatim feedback is ground-truth signal" doctrine (BP-S43b-4).

## Other clusters identified for next promote-rule cycle

Not promoted this turn (kept as 1st-instance HOLD or 2nd-instance pending):

- **CLUSTER B — Detector/attestation accuracy**: L-S342-1 (cross-layer DI) + L-S342-2 (set -u overstated; M-S341-1) + L-S349-2 (DoD as assertion no enforcement) + L-S349-1 (LOC inflation calibration). Already partially covered by L-S333-1 live-audit-attestation-lint pending. Recommend bundle on next 3rd-instance.
- **CLUSTER C — Bug-acknowledged-but-not-fixed**: L-S347-2 + L-S351-1 (local-scoped trap EXIT sub-instance) + L-S363-2 (3rd-instance ADR-vs-source-drift). 3rd-instance threshold met for ADR-vs-source-drift specifically (L-S363-2) — recommend SEPARATE next-turn promote-rule cycle to focus on it alone.
- **CLUSTER D — Substrate cross-cutting refactor**: L-S354-1 (Protocol-typed injection refactor 3 BC-5 adapters) + L-S342-1 (cross-layer DI). 2nd-instance; HOLD.
- **CLUSTER E — Calibration discipline (LOC / corpus / TC-count)**: L-S345-1 (LOC honesty; CLEARED at n=4 per S363) + L-S349-1 (LOC inflation) + L-S351-4 (commit message TC count auto-verify) + L-S363-1 (per-source corpus attribution auto-derive). Recommend extend L-S139-1 hook `loc-claim-evidence.sh` to cover corpus + TC counts on next harness session.
- **CLUSTER F — Per-source crawl friction**: L-S345-3 already PROMOTED to crawler-reliability skill at S358; CLEARED.
- **CLUSTER G — VN-locale gotcha**: L-S357-1 (UTC+7 timezone for VN no-tz datetime) + L-S363-1 (per-source corpus attribution VN-source-specific). HOLD at 1st-instance for tz; promote on 2nd VN-source-NLP gotcha.

## Candidates RETIRE this turn

- **L-S345-1** — CLEARED at n=4 per S363 verifier (LOC honesty held across S345 / S354 / S357 / S363). Mark as PROVEN-CLEAR in next promote-rule cycle; can demote from active candidate set to passive index. Recommend keeping in archive but removing from "watch this for n+1" list.
- **L-S345-3** — already PROMOTED to crawler-reliability skill at S358 (PROMOTE-NOW fired). Remove from candidate list.

## Pattern not in candidate list (NEW discovery)

**Verifier-finding-back-fill discipline gap**: The S362 verifier (M-S357-1 inline-resolved) caught the UTC+7 VN timezone fix DURING verify, but the L-S357-1 candidate row was filed AFTER the fix without explicit "is there a 2nd VN-source where this would have applied?" sweep. This is a sub-instance of L-S318-1 (anti-pattern-class-fix discipline) applied to VERIFIER findings instead of MAIN findings. Recommendation: extend L-S318-1 wording to cover verifier-surfaced fixes too: "When verifier flags a class-level pattern, before declaring inline-resolved + 1-instance-HOLD, grep for siblings across other production paths." Currently 1st-instance only; HOLD-FOR-PROMOTION.

## Compliance attestation

- Read 4 surfaces (`agent-notes.md` last 30 entries via 2 offset/limit reads; `best-practices.md` full; `known-issues.md` head; `mistake-log.md` head + M-S360/M-S365 grep) before writing.
- Grep'd existing pattern surfaces for near-duplicates of "main-session", "self-pause", "budget", "ledger COMPLETED" — found L-S189 self-pause precedent (referenced inline as 1st-instance of M-S360-1 family); confirmed M-S321-1 + M-S327-1 already filed (referenced inline as L-S327-1 cross-link). No exact duplicates found; cluster entry is novel.
- 0 charter writes / 0 production-code edits / 0 commits (per BP-S43b-4 lesson-synthesizer constraints + project D-060 main-commits-only).
- 0 user-memory writes (per BP-S43b-5 — project-scoped lesson lands in agent-notes.md not user-memory).
- File-write footprint: 1 file edited (`agent-notes.md`) + 1 file created (this observation file). Both under `agent-workspace/memory/`; both whitelisted for non-charter subagent writes.

## Recommended next-turn promote-rule dispatch brief (if main wants to act)

**Brief**: "Implement Stop hook `main-session-pre-dispatch-discipline.sh` covering L-S360-1 + L-S360-2 + L-S365-1 + L-S327-1 per agent-notes 2026-05-17 cluster entry. Companion firing-test mandatory per Phase 3.5 Hard Rule #2. Wire to Stop chain after `lesson-synthesis-watchdog.sh` before `harness-recovery-dod-watchdog.sh`. Estimated ~150 LOC hook + ~80 LOC firing-test; FOCUSED_IMPL ~100-150K Opus per CLAUDE.md recalibrated table. Surface results to `.severity-state.tsv` MEDIUM-tier (NOT autonomous-blocking; emits WARN + UserPromptSubmit context-injection)."
