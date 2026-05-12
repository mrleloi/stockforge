---
observation_id: 2026-05-12-S251-phase-4-scope-ratification-and-plan-reconciliation
type: scope-ratification + plan-reconciliation
session: S251
author: main-session (post-architect; not subagent)
created_at: 2026-05-12 (post-AskUserQuestion 6-Q completion + plan-file conflict resolution)
related_files:
  - agent-workspace/session-plans/pending/011-S251-phase-4-master-plan.md (CANONICAL)
  - agent-workspace/session-plans/pending/008-S235-phase-4-master-plan.md (SUPERSEDED-BY-011; amendment preserved as audit trail)
  - agent-workspace/memory/observations/sandwich-architect-S251-phase-4-master-plan-refresh.md (architect observation; describes 008 Path-X amendment)
  - agent-workspace/memory/checkpoints/latest.md (S250 close → S251 ratification handoff)
  - agent-workspace/memory/current-execution.md (S251 row with ratification block + corrected S252 NEXT ACTION)
trigger: User trivial-prompt "continue" at S251 entry → main-session dispatched sandwich-architect for Phase 4 master-plan refresh + concurrently fired AskUserQuestion 6-Q mega-bundle in 2 batches (Q-P4-4/3/5/1 first, Q-P4-2/6 second).
---

# S251 — Phase 4 SCOPE Ratification + Plan-File Reconciliation

## 1. SCOPE Ratification — AskUserQuestion 6-Q Mega-Bundle (Q-P4-1..Q-P4-6)

Fired in 2 sequential AskUserQuestion calls per tool's max-4 question limit, single-turn execution per `autonomous_continue_no_self_pause` + `qa_bundle_all_pending` doctrines.

| Q | Tier | Topic | Pick | Verbatim option | Rationale captured |
|---|---|---|---|---|---|
| Q-P4-4 | CHARTER | T5 harness-health-protocol.md deny-lift | A | APPROVE manual mv | One-time deny-lift via explicit user approval; functionally identical artifact location at constitution/; cleanest path per Charter Principle 8 cheapest-first. Unblocks S252 immediately. |
| Q-P4-3 | CHARTER | T8 charter v1.0→v1.1 timing | A | APPLY at S253 | Mechanical edit + version bump + ADR. Independent of E.4/D-055 cool-down (still ≥2026-05-14T~21Z). Closes Phase 3.5 deferred-doc backlog immediately. |
| Q-P4-5 | SCOPE | Phase 4 envelope acceptance | A | ACCEPT as-planned | 3.2-3.8M combined tokens + ~$90-160 imputed over 24-28 sessions per 011 framing. All 4 substantive tracks (A BC-6 / B BC-7 / C BC-8 / D thesis-maturation) tightly coupled to Charter Month 9/12 success criteria; Track E (BC-9 outer-loop) genuinely deferrable but cheap. |
| Q-P4-1 | SCOPE | Track C 6-perspective cost-cap breach risk | A | Haiku-hybrid Macro/Behavior/Manager | Mean ~$2.80 (within $3 Charter Principle 11 cap); worst-case ~$3.75 breach mitigated by Haiku-swap on 3 of 6 perspectives. ~$0.40/thesis savings. Per-label accuracy <0.85 risk MONITORED at S268 anti-flake gate (5-ticker × 2-run). |
| Q-P4-2 | SCOPE | Track D eval-set ticker selection | A | AUTO-PICK by sector-coverage rule | Deterministic algorithm: top-3 by market cap × 6 uncovered sectors (real-estate/retail/industrial/utilities/materials/healthcare) ≈ 15 new + 5 dogfood (BID/BVH/CTG/FPT/GAS) re-runs = 20 reference theses. Transparent, auditable, NO LLM judgment in picker. |
| Q-P4-6 | SCOPE | D-055 (E.4) cool-down disposition | A | HONOR until ≥2026-05-14T~21Z | Strictest charter discipline per Charter Revision Protocol. ~48hr delay; reserve sessions absorb slip. Track G (E.1 SDK removal) gated post-D-055 ratify per R-P4-9 ghost-greening prevention. |

All 6 picks = Recommended option A. Coherent Charter-Principle-8 cheapest-first profile. No silent defaults (UP-06 honored).

## 2. Plan-File Reconciliation

### Conflict detected

At S251 main-session ls of `agent-workspace/session-plans/pending/`, TWO Phase 4 master-plan files existed in parallel:

| File | Author | Authored | Frontmatter status (pre-reconciliation) | Track structure |
|---|---|---|---|---|
| `008-S235-phase-4-master-plan.md` | sandwich-architect (S235 + S251 amendment) | 2026-05-10 + 2026-05-12 S251 Path-X amendment | active | Track A bull-hardening (CRITICAL) / B LIVE crowd_sentiment / C KOL credentials / D eval-set / E sustained backlog + amended Tracks F/G/H (housekeeping/E.1/E.4) |
| `011-S251-phase-4-master-plan.md` | master-planner persona (S251 sibling) | 2026-05-12 | active; declares `supersedes: 008-S235-phase-4-master-plan.md` in frontmatter line 8 | Track 0 housekeeping + Track A BC-6 Track I resume / B BC-7 Tracks J+K resume / C BC-8 multi-perspective KEYSTONE / D thesis-maturation / E BC-9 outer-loop SKELETON / F VERIFY+close |

### Root-cause hypothesis

Most likely: a parallel master-planner subagent dispatched (perhaps via SessionStart hook continue-injector chain OR a sibling-claude race per L-S240-5 RC pattern) authored 011 concurrently with main-session's sandwich-architect dispatch which authored Path-X amendment on 008. Architect's observation file mentions ONLY 008 amendment + observation + current-execution.md edits — does NOT mention 011 authorship. Initial ls at S251 main-session entry showed 008 but NOT 011; second ls after architect completion showed both. Timeline-consistent with parallel-author race.

### Reconciliation decision: 011 = CANONICAL

Rationale:
1. **User Q-P4-x picks align with 011's structure**, not 008-amended:
   - Q-P4-4 = APPROVE T5 mv at S252 (matches 011 Track 0 S252; 008-amended Track F is sub-track with no clear S252 anchor)
   - Q-P4-3 = APPLY T8 at S253 (matches 011 session numbering; 008-amended re-baselined to S252+ but Track A is bull-probe not T8)
   - Q-P4-5 = ACCEPT envelope (framed as 011's 4 substantive tracks + Track E deferrable)
   - Q-P4-1 = Haiku-hybrid Macro/Behavior/Manager (Track C BC-8 6-perspective per 011; 008-amended Track A was bull-hardening retry-validator which is single-perspective)
2. **008-amended Track A is functionally vacuous**: bull-role hardening was already SHIPPED via D-053/D-054 (S239-S243 retry-validator symmetry; production validated). 011 § 0 explicitly identifies this and re-frames Phase 4 as BC-8 multi-perspective keystone + Phase 3 PAUSED tracks resume + housekeeping carryover.
3. **011 frontmatter explicitly declares `supersedes: 008-S235`** — author intent already documented.
4. **L-S204-1 / Charter Principle 8 cheapest-first** favors the cleaner artifact (011 self-contained) over the patched-stale artifact (008 + amendment).

### Reconciliation action

- 008 frontmatter `status` flipped `active → superseded-by-011-S251-phase-4-master-plan` with `superseded_reason` field documenting decision.
- 008 amendment section + body remain intact as audit-trail history per L-S43f-3 no-history-edit doctrine.
- 011 frontmatter unchanged (already declares supersession + active status).
- 011 = canonical Phase 4 master-plan for S252+ dispatch routing.

### What main-session did NOT do (preserved as audit trail)

- Did NOT delete 008-S235-phase-4-master-plan.md (preserves S235 + S251 architect amendment provenance).
- Did NOT edit 011 frontmatter to record ratification answers — this observation file is the canonical answers record.
- Did NOT dispatch sandwich-verifier on either plan (S251 architect amendment is editorial; 011 master-planner authorship was clean per its own frontmatter; AP-1 verifier dispatch deferred to Track F VERIFY at S277 Phase 4 close per 011 framing).

## 3. Corrected S252 NEXT ACTION

Per Q-P4-4 = APPROVE + 011's Track 0 housekeeping framing:

**S252 = sandwich-dev FOCUSED_IMPL: T5 manual mv `proposals/harness-health-protocol.md` → `constitution/harness-health-protocol.md`**

Brief includes: (a) Read source draft for content sanity (~12K LOC harness-health protocol); (b) one-time deny-lift via user-approved Q-P4-4 — perform mv via Bash; (c) search for cross-references to `proposals/harness-health-protocol.md` across constitution/, CLAUDE.md, agent-workspace/CLAUDE.md, memory/agent-notes.md, scripts/hooks/ + update to new constitution/ path; (d) verify file lands + content matches pre-mv via git diff; (e) write S252 observation + update current-execution.md S252 row + mistake-log digest.

NOT in S252 scope: T8 charter edit (PRIORITY 2 at S253 per Q-P4-3 = APPLY at S253); E.1 SDK removal (PRIORITY 4 post-D-055 ratify); D-055 ratification (PRIORITY 3 post-cool-down ≥2026-05-14T~21Z); Track A-E IMPL work (post-housekeeping).

Estimated cost: 30-60K main turn; FOCUSED_IMPL envelope under-budget.

## 4. Hard-rule honor S251 (ratification main-session sub-turn)

- 0 git commits (CLAUDE.md hard rule) ✓
- 0 charter file edits ✓ (Q-P4-3 APPLY at S253 not S251)
- 0 constitution writes ✓ (T5 mv is S252 work)
- 0 production-code edits ✓
- 0 new hooks ✓
- AP-1 honored — main-session did NOT review architect's own work; reconciliation is process-level (frontmatter status flip + observation write), not adversarial review of architect deliverable
- UP-06 honored — all 6 SCOPE/CHARTER questions fired with explicit lettered options; no silent defaults
- qa_bundle_all_pending honored — ALL pending Q-P4-x questions bundled across topics in 2 sequential AskUserQuestion calls; never piecemeal
- harness_priority_one — no harness defect surfaced this sub-turn
- autonomous_continue_no_self_pause — sub-turn extends architect-dispatch turn; S252 sandwich-dev dispatched in same overall turn per dont_self_pause_at_session_boundary

## 5. Carryover items for S252+

- Q-P4-1 per-label accuracy monitoring at S268 anti-flake gate (validate Haiku-hybrid Macro/Behavior/Manager ≥0.85 per-label accuracy)
- D-053 frontmatter DUPLICATE label hygiene (PRIORITY 5 anytime, single-file edit)
- 008-S235 + amendment archive to `session-plans/completed/` on next housekeeping turn (Track F VERIFY at S277 or earlier opportunistic)
- E.4/D-055 ratification calendar reminder: cool-down elapses ≥2026-05-14T~21Z; PRIORITY 3 at S253+ session

End of S251 ratification observation.
