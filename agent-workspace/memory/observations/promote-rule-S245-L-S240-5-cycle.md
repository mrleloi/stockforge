---
observation_id: promote-rule-S245-L-S240-5-cycle
type: promotion-proposal
session: S245
created_at: 2026-05-10T22:00:00+07:00
skill_invoked: promote-rule
mode: AUTONOMOUS-FULL
related_lessons: [M-S238-2, L-S239-4, L-S240-5, M-S189-1]
related_observations:
  - drift-detector-S241b-phantom-dispatch-RC.md
  - 2026-05-10-S243-parallel-finding-lock-trap-bug.md
  - sandwich-verifier-S243-D054-ratification.md
  - sandwich-dev-S244-lock-trap-fix.md
status: proposal-pending-human-review
threshold: AP-23 4-instance MET (Cluster A); AP-23 2-instance MET (Cluster B)
---

# Promote-Rule Cycle — S245: L-S240-5 phantom-dispatch + L-S243+-1 trap-eats-state

## Methodology Notes

This cycle is targeted, not exhaustive: the parent brief explicitly scopes the run to the L-S240-5 phantom-dispatch class (4-instance threshold MET per AP-23) plus the adjacent trap-eats-state class surfaced at S243 (now 2nd-instance). Full Jaccard sweep over all 50+ lessons in `agent-notes.md` Operational Lessons digest is OUT of scope this turn (parent budget envelope ~30-50K). Two clusters proposed below; remaining digest entries are not re-clustered.

Provenance of clustering decisions is by SOURCE (incident files + dispatch.jsonl) rather than lexical Jaccard, because the recurrence is established by causal-chain evidence (same defect class across 4+ separate incident reports), which is stronger signal than token-overlap.

---

## Cluster A — Phantom-Dispatch / Cross-Session Race (PROMOTION TRIGGER)

### Cluster ID + Member Entry IDs

**Cluster A: phantom-dispatch-cross-session**

| # | Instance ID | Date | Source | Originator |
|---|---|---|---|---|
| 1 | M-S238-2 | 2026-05-09 | (per checkpoint citation; mistake-log digest line absent — M-S238-2 lives in archive only at this LOC) | Sibling claude.exe instance dispatched same dogfood task |
| 2 | L-S239-4 | 2026-05-10 | drift-detector-S241b-phantom-dispatch-RC.md § H5 | Same — multi-claude race emergent across 30+ SessionStart events in 17min |
| 3 | L-S240-5 | 2026-05-10 | drift-detector-S241b-phantom-dispatch-RC.md § 3 (Root Cause) | Same — `b30ko1l41` originated session `6cb5f5f7`, notification arrived in sibling session `76f9cc94`, output keyed to a 3rd session UUID |
| 4 | S243 cross-session race | 2026-05-10 | 2026-05-10-S243-parallel-finding-lock-trap-bug.md § AMENDMENT + dispatch.jsonl:224-227 | TWO sandwich-verifier completions (`toolu_01TdcEZNv4F1AY7XVt7WmCFL` parent_session=`76f9cc94-...` AND `toolu_01AvFaju4Wt35oR3NNjt4aKm` parent_session=`ff85e8d5-...`) — DIFFERENT parent_session_ids — both wrote canonical observation path |

**Empirical evidence — dispatch.jsonl lines 224-227** (verbatim, this proposal's authoring agent grepped at S245 entry):

```jsonl
{"event":"DISPATCHED","dispatch_id":"toolu_01TdcEZNv4F1AY7XVt7WmCFL",...,"parent_session_id":"76f9cc94-3bcc-4e33-aa85-0ed0de72d750",...}
{"event":"COMPLETED","dispatch_id":"toolu_01TdcEZNv4F1AY7XVt7WmCFL",...,"parent_session_id":"76f9cc94-3bcc-4e33-aa85-0ed0de72d750",...,"duration_ms":5978647,...}
{"event":"DISPATCHED","dispatch_id":"toolu_01AvFaju4Wt35oR3NNjt4aKm",...,"parent_session_id":"ff85e8d5-9878-495b-84a1-ebce222de37d",...}
{"event":"COMPLETED","dispatch_id":"toolu_01AvFaju4Wt35oR3NNjt4aKm",...,"parent_session_id":"ff85e8d5-9878-495b-84a1-ebce222de37d",...,"duration_ms":119503,...}
```

**Corrected Root Cause** (supersedes S243-verifier-Section-H "in-session race" hypothesis):
The two parent_session_ids are DIFFERENT UUIDs. This is **cross-session** — two separate parent claude.exe processes both running in autonomous_mode=true, each independently dispatching its own sandwich-verifier subagent, both writing to the same canonical observation path.

This matches H5 from the original drift-detector RC (S241b), which was already definitive. The S243 verifier's "IN-SESSION race" hypothesis was empirically wrong — it conflated "two completion notifications observed in this session" with "both originated in this session". The two notifications were observed in session `ff85e8d5` because that session received its own subagent's result PLUS visibility of the sibling's. Per the same multi-claude-bash-subprocess-cross-visibility pattern documented in the original drift-detector report (`b30ko1l41` notified in sibling session 20min after origination).

### Class Summary (the recurring rule)

> **When `autonomous_mode=true` and >1 claude.exe runs concurrently, each instance independently consumes the same routing inputs (`current-execution.md` active task) and dispatches its own copy of the work. Without process-level mutual exclusion, dispatches multiply, costs amplify, observation files get written by competing dispatchers, and subsequent verifiers misattribute "phantom" entries to in-session bugs that don't exist.**

### Empirical Instance Count + Dates

- **4 confirmed instances** between 2026-05-09 (M-S238-2) and 2026-05-10 (L-S239-4 + L-S240-5 + S243 cross-session race)
- **AP-23 promotion threshold** (1st-instance no-promote / 2nd-instance promote-or-retire) → MET at instance #2 (L-S239-4); at instance #4 the class is OVERDUE for codification

### Promotion Target — HOOK (priority 1 per Q-E3)

**Verdict**: **HOOK** — the rule encodes a deterministic check (file existence + holder-pid liveness + clean exit on hard-block).

**Rationale**: This is exactly the class of guarantee that Q-E3's hook-first priority was designed for. The S244 SHIPPED fix (`scripts/hooks/single-claude-instance-lock.sh` line-30 trap deletion) IS the codification — it just needs formal promotion language so the rule is now binding doctrine, not "shipped fix one-off". A SKILL would burn LLM judgment on what bash already enforces deterministically (anti-pattern per AP-23). A CHARTER promotion is premature: the invariant is "no >1 autonomous-mode parent claude.exe shall dispatch to the same project simultaneously" — this is operational, not identity-level.

### Implementation Sketch

The implementation is **already shipped at S244** as the post-fix `scripts/hooks/single-claude-instance-lock.sh`. Promotion language formalizes it:

**Hook**: `scripts/hooks/single-claude-instance-lock.sh` (existing, S244-fixed)
**Fire-on event**: SessionStart (already wired in `.claude/settings.json` chain ABOVE essential-routing-fields-verifier.sh per S241b RC § 4.A)
**Behavior** (already implemented):
1. Read `agent-workspace/memory/.claude-instance.lock` if exists
2. If holder-pid alive (verified via `tasklist //FI "PID eq $HOLDER_PID"` matching `claude.exe`) → emit `[BLOCK]` to stderr + `export STOCKFORGE_AUTONOMOUS_DISABLE=1` + exit 2
3. Else write `session=$CLAUDE_SESSION_ID:$SELF_PID:$(date +%s)` to lock
4. Exit 0 — **no `trap` on EXIT** (S244 fix; ensures persistent lock across parent claude.exe lifetime)
5. SessionEnd hook at `.claude/settings.json:239` removes lock on clean exit

**Companion**: `scripts/hooks/firing-tests/single-claude-instance-lock-fire-test.sh` (shipped S244; 3/3 + 1 PENDING; full-suite 88/88 PASS)

**Promotion language** (proposed to add to agent-notes.md Operational Lessons digest table):

| ID | Title | Status | Severity | Archive line |
|---|---|---|---|---|
| L-S240-5 (PROMOTED-TO-HOOK at S245) | Single-instance lock REQUIRED when autonomous_mode=true; cross-session race produces phantom dispatch + cost amplification + observation collisions | ACTIVE | high | inline-S245 |

Full body lives in `agent-notes-archive-2026-05-10.md` (when next archive cuts) — for now retain provenance via this proposal observation file.

### Counter-Arguments (when promotion is wrong)

1. **Lock alone doesn't cover IN-SESSION parallel `Agent` dispatches**: True, but the S243 evidence shows the actual race was CROSS-SESSION not in-session. The verifier's in-session hypothesis was wrong. Hook IS sufficient for the actually-observed class. (See Cluster B for the residual in-session concern, which is a SEPARATE class.)
2. **Test coverage gap**: TC3 (live-sibling-blocked) is PENDING — cannot synthesize 2nd claude.exe from inside a single claude.exe context. **MITIGATION**: parent brief PRIORITY 0 manual 2-instance smoke is queued post-`/clear` reboot. Promotion is conditional on smoke confirming BLOCK-path fires.
3. **False-positive on legitimate dual-tenant**: If user intentionally runs 2 claude instances in same project (e.g., one for dev, one for read-only review), the lock blocks both. Mitigation: env override `STOCKFORGE_LOCK_BYPASS=1` could be added; not in S244 scope; queue as P3 hygiene.

### Recommended Verdict

**PROMOTE — HOOK already shipped, formalize as L-S240-5-PROMOTED-TO-HOOK**. Update agent-notes.md digest with the row above. Update promote-rule capability map (see "Capability-Map Update Sketch" below).

**Next-action owner**: parent main session at S245 — Edit agent-notes.md table to insert promotion row (1-line digest); Edit mistake-log.md if M-S238-2 needs back-promotion to digest table (currently absent from mistake-log digest); no new code changes needed (S244 already shipped).

---

## Cluster B — Trap-Eats-State (CANDIDATE; below threshold for Charter, MEETS HOOK threshold)

### Cluster ID + Member Entry IDs

**Cluster B: trap-on-EXIT-defeats-persistent-state-in-SessionStart-tier-hooks**

| # | Instance ID | Date | Source | Defect mechanism |
|---|---|---|---|---|
| 1 | M-S189-1 (HH-H.1 stale-checkpoint guard) | 2026-05-08 | mistake-log.md M-S189-1 line | Hook design-time threshold (300s) caused write-only marker `auto-reboot-BLOCKED-stale-checkpoint`; no clear-on-fresh path; orphan marker on disk for 8h+. Sibling HH-H.4 hook had correct mirror. M-S189-1 description characterizes this as "harness-guard-too-strict" but the deeper class is "hook writes state then loses ability to clean it up" |
| 2 | S243 lock-trap (L-S243+-1 candidate) | 2026-05-10 | 2026-05-10-S243-parallel-finding-lock-trap-bug.md | `single-claude-instance-lock.sh:30` `trap 'rm -f "$LOCK"' EXIT` fired microseconds after lock write at line 29 → SessionStart-tier hook lost persistent state by design intent (session-lifetime lock) |

**Class summary**: SessionStart-tier hooks that write persistent state for cross-process or cross-session use MUST NOT use bash `trap '...' EXIT` (or equivalent script-exit cleanup) — the hook process is short-lived but the state must persist for the parent process lifetime. Cleanup belongs at SessionEnd hook only.

### Note on AP-23 doctrine

S243 observation § Promotion candidate flagged this as "1st instance pending 3rd". Current AP-23 doctrine in agent-workspace constitution language (per checkpoint § Hard locks active line 95) is "1st instance no promote, 2nd instance promote". Under that doctrine, **2nd-instance threshold is MET**: M-S189-1 is the 1st (write-only marker; missing mirror cleanup); S243 lock-trap is the 2nd (trap eats state immediately). Both are the same family: "hook author didn't think through the asymmetric lifetime of script-process-vs-state-purpose".

The 1st-vs-2nd-instance ambiguity in checkpoint doctrine itself merits a clarification ADR or charter sync; for THIS cycle, the proposal proceeds on the 2nd-instance reading because both incidents are independently documented and the harm pattern is identical.

### Promotion Target — HOOK (priority 1 per Q-E3)

**Verdict**: **HOOK** (a deterministic LINTER hook over `scripts/hooks/*.sh`)

**Rationale**: A static linter can detect the antipattern at author-time, before the script ever ships. Charter promotion would over-reach (this is procedural, not identity-tier). Skill promotion would burn LLM budget on regex patterns. Lint-hook precedent: bash-hook-lint already exists in the codebase (per M-S117-1, M-S118-1 entries) — extend it with one new check.

### Implementation Sketch

**Hook**: extend `scripts/hooks/bash-hook-lint.sh` (existing) with new check:

```
Check N+1: trap-eats-persistent-state
- Detect: any SessionStart-tier hook (registered in .claude/settings.json under SessionStart chain) that contains BOTH:
  (a) a `trap '...rm -f...' EXIT` or `trap '...exit.*' EXIT` line, AND
  (b) writes persistent state to a path containing `/agent-workspace/memory/.` or `/.claude/.`
- Emit: lint warning citing L-S243+-1 + S244 fix precedent
- Exception: hooks that explicitly declare via comment `# ephemeral-state: lock cleared at SessionEnd-hook` → skip warning (allows legitimate trap on EXIT for tmpfile cleanup)
```

**Companion firing-test**: backfill 4 TCs (positive: trap+write triggers warning; negative: trap-only no warning; negative: write-only no warning; positive-with-exception: declared-ephemeral skipped).

**Promotion language** (proposed agent-notes.md digest row):

| L-S243+-1 (CODIFIED at S245) | SessionStart-tier hooks MUST NOT trap EXIT to remove persistent state; cleanup belongs at SessionEnd | ACTIVE | high | inline-S245 |

### Counter-Arguments (when promotion is wrong)

1. **The 1st instance (M-S189-1) was NOT a trap-eats-state pattern, it was missing-clear-path**: True — M-S189-1 had write-only-no-clear; S243 had write-then-trap-clear. The class summary needs to be more precise: "hook write/clear lifetime asymmetry vs intended state purpose". The lint check should detect BOTH sub-patterns. Update implementation sketch accordingly: also detect SessionStart-tier hooks that write persistent state without a corresponding SessionEnd cleanup line. (See `scripts/hooks/bash-hook-lint.sh` L-S111-1 mirror pattern — already partially solved for HH-H.1.)
2. **Lint false-positives on legitimate non-ephemeral-but-trap-cleared cases**: Mitigated via the `# ephemeral-state:` comment exception. Net cost: 1 line of declaration per legitimate case.
3. **Premature codification**: Only 2 confirmed instances. Counter-counter: AP-23 2nd-instance doctrine is explicit; further deferral risks 3rd instance landing during LIVE 5-ticker re-run on a different hook.

### Recommended Verdict

**PROMOTE — HOOK lint-check; queue as S246+ FOCUSED_IMPL** (deferred this turn because parent envelope is LESSON_SYNTHESIS not IMPL; lint extension + 4 TCs is ~1-2K LOC + companion firing-test, exceeds 50K-token cycle budget).

**Next-action owner**: parent main session at S245 — write 1-line digest row in agent-notes.md (the rule-codification half); dispatch S246 sandwich-dev for hook implementation half (the lint-check half); NO charter changes.

---

## Capability-Map Update Sketch

Per skill instructions § Step 9: does this promotion warrant a new task_class entry in `agent-workspace/memory/capability-map.md`?

**Cluster A (phantom-dispatch HOOK promotion)**: Existing task_class `harness-defect-fix` covers this. No new entry needed. Note: add a row in capability-map's "harness defects fixed via hook" sub-table if such sub-table exists (verify at implementation time).

**Cluster B (trap-eats-state lint-check)**: Existing task_class `bash-hook-lint-extension` (per M-S117-1 / M-S118-1 lineage of lint-check additions) covers this. No new entry needed.

**Conclusion**: capability-map UNCHANGED by this promotion cycle. Skill output schema § "Capability-map touch" = none for either cluster.

---

## Summary Table

| Cluster | Class | Instances | Threshold | Target | Status | Owner |
|---|---|---|---|---|---|---|
| A | phantom-dispatch cross-session | 4 (M-S238-2 + L-S239-4 + L-S240-5 + S243) | AP-23 4-instance MET | HOOK | Already shipped at S244; needs digest-row formalization at S245 | Parent main S245 — Edit agent-notes.md |
| B | trap-eats-state / hook-write-clear-lifetime-asymmetry | 2 (M-S189-1 + S243 lock-trap) | AP-23 2-instance MET | HOOK (lint-check extension) | Implementation deferred to S246 FOCUSED_IMPL | Parent main S245 codify; S246 sandwich-dev implement |

---

## Hard Locks Honored (this proposal)

- ✓ NO `git commit` — proposal is uncommitted markdown only
- ✓ NO charter file edits — neither cluster recommends charter promotion (both stay at HOOK tier)
- ✓ NO constitution writes — no files touched in `agent-workspace/constitution/`
- ✓ Read-only on all files except this new proposal observation
- ✓ NO subagent dispatches from within this skill cycle
- ✓ Stay within ~30-50K tokens (LESSON_SYNTHESIS envelope) — final token usage measured at parent.

---

## Provenance Citations (per skill § Step 9)

**Source rules / incident files** (absolute paths):

- `C:\htdocs\stockforge\agent-workspace\memory\observations\drift-detector-S241b-phantom-dispatch-RC.md` (lines 38-58 H5 verdict; lines 70-90 fix proposal)
- `C:\htdocs\stockforge\agent-workspace\memory\observations\2026-05-10-S243-parallel-finding-lock-trap-bug.md` (lines 1-86 full RC + AMENDMENT)
- `C:\htdocs\stockforge\agent-workspace\memory\observations\sandwich-verifier-S243-D054-ratification.md` (lines 256-268 § F-Operational-1)
- `C:\htdocs\stockforge\agent-workspace\memory\observations\sandwich-dev-S244-lock-trap-fix.md` (S244 SHIPPED record)
- `C:\htdocs\stockforge\agent-workspace\memory\dispatch.jsonl` lines 224-232 (cross-session evidence: 2 distinct parent_session_ids)
- `C:\htdocs\stockforge\agent-workspace\memory\mistake-log.md` line for M-S189-1 (HH-H.1 incident)
- `C:\htdocs\stockforge\agent-workspace\memory\agent-notes.md` lines 11-585 (digest table for context; specific entries for L-S189+ candidate not yet in digest)
- `C:\htdocs\stockforge\scripts\hooks\single-claude-instance-lock.sh` (S244 post-fix; line-30 trap removed)
- `C:\htdocs\stockforge\.claude\settings.json` line 239 (SessionEnd cleanup pre-existing)

**Q-E3 priority** chosen for both clusters: **HOOK** (deterministic-check tier; cheapest enforcement).

**capability-map cells touched**: none (existing task_classes cover both promotions).

---

End of S245 promote-rule cycle proposal. Awaiting parent main session decision on whether to (a) Edit agent-notes.md digest with the two PROMOTED rows now, or (b) defer until post-PRIORITY 0 manual 2-instance smoke confirms Cluster A's HOOK-already-shipped fix actually fires the BLOCK path empirically.
