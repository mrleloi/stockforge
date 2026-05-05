---
observation_id: promote-rule-S35
type: promotion-routing
created_at: 2026-05-01
session: S35
agent: promote-rule subagent dispatched from main S35 session (D4)
inputs: 9 proposals + 7 lesson candidates (L-S25-1, L-S26-1, L-S28-1, L-S30-1, L-S32-1, L-S33-X confirmed-absent, L-S34-1)
doctrine_basis:
  - queued-grill-master.md § Q-E3 "Hook FIRST, skill SECOND, charter LAST"
  - queued-grill-master.md § Q-B2 charter-tier explicit-pick required
  - queued-grill-master.md § Q-E2 phase-boundary promotion frequency
  - decision-discipline.md § Rule 3 promotion-target priority
  - decision-discipline.md § Rule 4 phase-boundary frequency
  - L-S15-1 charter-tier-split-rule (charter promotes get user-gate)
read_inputs:
  - 9 proposal files (full bodies for top candidates; headers + acceptance sections for others)
  - 9 constitution files (line-count check; absence verification — none of the 4 charter-track proposals are in constitution yet)
  - agent-notes.md (full L-S34-1 entry; lesson context cross-checked against session-25/26/28/30/32/33/34 close logs)
  - latest checkpoint S34-extension-close
  - queued-grill-master.md
---

# Promote-Rule S35 — Routing Decisions

## Summary

| Bucket | Count | Items |
|---|---|---|
| **promote-to-charter** | 3 | autonomous-protocol, decision-discipline, memory-tiers |
| **promote-to-skill** | 1 | provenance-protocol (extend write-a-skill or new provenance-discipline skill — actually charter-tier; see rationale; SKILL is fallback) → REROUTED to **applied + add to CLAUDE.md ritual** |
| **promote-to-hook** | 1 (proposals) + 4 (lessons) | architecture-amendment partial (skill-vs-command duplication detector hook); L-S30-1 VBW pre-flight Glob hook; L-S32-1 multi-strategy probe hook; L-S34-1 cross-BC import-linter; L-S25-1 architect-budget watchdog extension |
| **practical-applied** (proposal already used in practice; defer formal charter promote until Phase 3) | 3 proposals | provenance-protocol, financial-data-protocol-amendment (S16 hook portability — already in `bash-hook-lint.sh`), session-budgets-amendment (S14 Mode-D + S21 verifier — already in autonomous-stop-watchdog.sh + verified empirically) |
| **defer** | 2 proposals | financial-data-protocol-amendment-VN, invariants-amendment-VN, architecture-amendment (3 — see below) |
| **reject** | 0 | — |

**Lesson totals**: 7 candidates → 5 promote-to-hook + 1 promote-to-skill (L-S26-1 → decision-discipline.md draft section) + 1 confirmed-absent (L-S33-X). 5 of 7 hook-routed satisfies the constraint.

**Net charter-promotes (≥2 required)**: **3** (autonomous-protocol, decision-discipline, memory-tiers). PASSES constraint.
**Net hook/skill lesson-promotes (≥3 required)**: **5 hooks + 1 skill = 6**. PASSES constraint.

---

## Per-Proposal Routing

### 1. autonomous-protocol → **promote-to-charter** (HIGH PRIORITY)

- **Source**: `agent-workspace/proposals/autonomous-protocol.md` (127 LOC). 8 rules: full-autonomous-only mode (Rule 1, charter-tier user correction S15), Mode A/B/C/D handoff, hybrid context auto-loader, bootstrap budgets per session-type, Skill-tool gating, drift self-detection (Q-E1 defense-in-depth), drift recovery flow (Q-E4 async Q&A), AskUserQuestion scope.
- **Current state**: PRACTICAL-APPLIED multiple times — Rule 1 (autonomous_mode=true) cited at every checkpoint S14+; Rule 2 (Mode-D) shipped in `autonomous-stop-watchdog.sh` per L-S14-4; Rule 4 bootstrap budgets enforced empirically (S25 architect 192K overshoot WAS THIS RULE BEING TESTED → L-S25-1 lesson); Rule 8 violated by S15 close pre-correction → led to S15 user correction. NOT in constitution yet.
- **Routing**: **promote-to-charter**.
- **Rationale**: This proposal IS the project's identity-tier rule (autonomous_mode=true is the only mode). 13 sessions of de-facto enforcement without formal codification = drift risk; the S15 correction proves the cost. The proposal already incorporates all queued-grill answers (Q-C2/C3/E1/E4/2.1). User correction at S15 is explicit charter-tier authorization for Rule 1; remaining rules are downstream consequences. Charter is the right home.
- **If promote-to-charter**: Move file to `agent-workspace/constitution/autonomous-protocol.md`. Author ADR `D-013-promote-autonomous-protocol.md` (12-field schema) citing source_evidence (proposal frontmatter + S15 user correction + L-S14-4). Open AskUserQuestion with single explicit-pick question per Q-B2 charter-tier doctrine. Estimated LOC: 127 (no rewrite needed; proposal is constitution-ready).
- **User-gate**: REQUIRED (charter-tier per L-S15-1 + Q-B2). Bundle with decision-discipline + memory-tiers in single AskUserQuestion (3-pick batch).

### 2. decision-discipline → **promote-to-charter** (HIGH PRIORITY)

- **Source**: `proposals/decision-discipline.md` (111 LOC). Rule 1 tier-vs-default-acceptance, Rule 2 IMPL-tier doctrine + storage-substrate sub-clause, Rule 3 hook-skill-charter promotion priority, Rule 4 phase-boundary frequency, Rule 5 provenance-required.
- **Current state**: PRACTICAL-APPLIED 5+ times. Rule 1 cited explicitly in S15 PLAN doctrine. Rule 2 + sub-clause is the L-S11-2/L-S17-1 codification — used in D-006 (storage substrate IMPL-tier). Rule 3 is the basis for THIS routing exercise. Rule 4 was the (incorrectly defaulted) reason promotion skipped 15 sessions. NOT in constitution.
- **Routing**: **promote-to-charter**.
- **Rationale**: Without formalizing Rule 4 (phase-boundary trigger), the META-skip happens AGAIN. Rule 3 IS the doctrine I'm using right now to make these calls; it must be binding. Proposal is mature, citation-rich, used. Charter is right home.
- **If promote-to-charter**: Move to `agent-workspace/constitution/decision-discipline.md`. ADR `D-014-promote-decision-discipline.md`. Estimated LOC: 111. **NEW augmentation needed**: add explicit "Rule 4a — promotion run TRIGGER + ENFORCEMENT" sub-clause that wires phase-boundary check into a hook (`scripts/hooks/promotion-cycle-trigger.sh`) — the missing trigger is the dead-loop S35 fixed.
- **User-gate**: REQUIRED. Bundle with autonomous-protocol + memory-tiers.

### 3. memory-tiers → **promote-to-charter**

- **Source**: `proposals/memory-tiers.md` (87 LOC). Tier 1 always-loaded / Tier 2 just-in-time / Tier 3 explicit-pull. Maps every memory file. Boundary rules + anti-patterns.
- **Current state**: PRACTICAL-APPLIED implicitly — `agent-workspace/CLAUDE.md` § Reading Priority enumerates Tier 1/2 informally; bootstrap ceilings (Q-C3) reference these tiers without naming them. Bootstrap-overshoot risk increasing as more memory files accumulate (S25 demonstrated). NOT in constitution.
- **Routing**: **promote-to-charter**.
- **Rationale**: Closely paired with autonomous-protocol Rule 4 (bootstrap ceiling). If memory tiers are not codified, every new agent re-derives priority from scattered prose → bootstrap violations recur. Cheap promotion (87 LOC; no new content), high enforcement value. Proposal is constitution-ready.
- **If promote-to-charter**: Move to `agent-workspace/constitution/memory-tiers.md`. ADR `D-015-promote-memory-tiers.md`. Estimated LOC: 87. **Hook companion**: `scripts/hooks/tier1-bloat-check.sh` to grep tier-1 files at SessionStart, sum LOC, alert if >8K (PLAN ceiling). Already trivial; bundle with decision-discipline Rule 4a hook.
- **User-gate**: REQUIRED. Bundle with autonomous-protocol + decision-discipline.

### 4. provenance-protocol → **practical-applied** (defer formal charter promote until Phase 3 thesis cycle ramps)

- **Source**: `proposals/provenance-protocol.md` (192 LOC). Most detailed proposal: when-to-log + how-to-log + thesis-provenance + confidence-claim provenance + R7 defer-cycle tracking + DR-PROV/DR-DEFER/DR-CITE drift hooks integration.
- **Current state**: PRACTICAL-APPLIED EXTENSIVELY. Every D-NNN file in `agent-workspace/memory/decisions/` (D-001 through D-012) cites source_evidence. DR-PROV concept referenced in 5+ session checkpoints. The 12-field schema is enforced by `_template.md`. The defer-cycle pattern is in `qa-pending-stale-mover.sh`.
- **Routing**: **practical-applied** + add ritual to CLAUDE.md.
- **Rationale**: Cited at decision-points more than any other proposal (~7+ session-by-session uses). Adoption is operational, not aspirational. Charter promote is appropriate eventually but Phase 3 (when first real thesis lands + calibration data starts flowing) is more natural — current Phase 2 is BC-buildout where provenance is decisions-only and already enforced. Promoting now without Phase-3 thesis evidence leaves R7 defer-cycle and confidence-claim sections untested. **Better approach**: extract the 5 "When-to-log" rules into CLAUDE.md as Hard Rules (already partially there) + keep the proposal as living draft until Phase 3.
- **If defer**: re-trigger condition = first thesis ships (Phase 3 entry, master-plan 005 § S43+). At that point, sections 4-6 (thesis + confidence + R7) will have empirical signal; ratify with full evidence.
- **Implementation for main session**: NO file move. Append 1 paragraph to `CLAUDE.md` § Hard Rules: "Every decision file MUST cite source_evidence ≥1 entry (per provenance-protocol proposal); empty source_evidence = drift signal DR-PROV". Estimated LOC: ~3 lines.

### 5. financial-data-protocol-amendment (S16, Hook Portability) → **practical-applied + reject formal promote**

- **Source**: `proposals/financial-data-protocol-amendment.md` (42 LOC). Adds Rule 11 "Hook Portability Per Phase" (Phase 0 = bash+POSIX; Phase 1+ = Python+jq accepted).
- **Current state**: FULLY APPLIED — `scripts/hooks/bash-hook-lint.sh § Check 1 L-S11-1` is shipped and enforces. All Phase 0 hooks in `scripts/hooks/` are bash+POSIX. Rule 11 is the policy formalization of L-S11-1 lesson.
- **Routing**: **practical-applied** (already lives in code as a hook, where it belongs per Q-E3 cheapest-first).
- **Rationale**: Q-E3 says hook FIRST. The hook EXISTS and works. Promoting to charter as Rule 11 of financial-data-protocol.md adds nothing the hook doesn't already do, and adds a SECOND source-of-truth (hook code + charter prose) that can drift between Phase 0 and Phase 1+. Cleaner: leave the rule in the hook; document the policy in agent-notes (already done at L-S11-1) + add a 1-line cross-reference in financial-data-protocol.md pointing at the hook.
- **Implementation for main session**: NO file move. Optionally append 1-line note in `agent-workspace/constitution/financial-data-protocol.md` § "When This Protocol Conflicts With Convenience": "See `scripts/hooks/bash-hook-lint.sh § L-S11-1` for Phase 0 hook portability enforcement (bash+POSIX). Phase 1+ relaxes." LOC: 1.

### 6. financial-data-protocol-amendment-VN (Rules 12-15) → **defer**

- **Source**: `proposals/financial-data-protocol-amendment-VN.md` (116 LOC). Rule 12 T+2.5 settlement, Rule 13 Room ngoại, Rule 14 Sàn HOSE/HNX/UPCoM tiering, Rule 15 FX VND-USD point-in-time.
- **Current state**: PARTIALLY applied. Rules 12 + 14 referenced in S26 entity design (Bar.sàn field landed; Position.opened_at semantics in spec). Rules 13 + 15 are scaffolds — no ForeignOwnershipState entity yet (Phase 2 deferred), no FxRate entity yet (Phase 1 thin-slice = VND only). Sibling proposal invariants-amendment-VN.md (I-S55-I-S65) is co-dependent.
- **Routing**: **defer** (paired with invariants-amendment-VN).
- **Rationale**: Charter-promoting these rules now binds Phase 2/3 work that hasn't started. The rules are correctly drafted but their enforcement path requires entities that aren't built (ForeignOwnershipRepository, FxRateRepository, full intraday Bar). Promote to charter when the enforcing entities ship, not before — otherwise charter prose forward-references types that don't exist (drift signal D4 territory). Phase 2 is current scope; promote at Phase 2 close (S43+ when BC-2/BC-3/BC-5 + cross-BC composition lands) when Rules 12 + 14 have implementations and Rules 13 + 15 are next-on-deck.
- **Re-trigger condition**: Phase 2 close (master-plan 005 § Phase 2 boundary) AND `packages/domain/foreign_ownership/` directory exists AND `packages/domain/fx/` exists. Verify via `ls packages/domain/`.
- **Implementation for main session**: NO file move. Optional cross-reference in `agent-workspace/constitution/financial-data-protocol.md` near end-of-file: "VN-domain Rules 12-15 in `proposals/financial-data-protocol-amendment-VN.md` — defer charter promote until Phase 2 close per S35 routing decision." LOC: 1.

### 7. invariants-amendment-VN (I-S55-I-S65) → **defer** (paired with #6)

- **Source**: `proposals/invariants-amendment-VN.md` (108 LOC). 11 NEW invariants enforcing the VN-domain Rules 12-15.
- **Current state**: Same as #6 — partially applied at entity scaffold level (Bar.sàn lands per I-S59 in S26+S27 work), most enforcement Phase 2+. Sibling to #6.
- **Routing**: **defer**.
- **Rationale**: Same as #6. Charter-binding 11 invariants whose enforcement path requires unbuilt entities = forward-reference drift. Wait for Phase 2 close.
- **Re-trigger condition**: Same as #6 (Phase 2 close + relevant BC entities exist).
- **Implementation for main session**: NO file move. Same 1-line cross-reference pattern.

### 8. architecture-amendment → **promote-to-hook (partial) + defer (rest)**

- **Source**: `proposals/architecture-amendment.md` (98 LOC). 4 sections: Slash-cmd vs Skill responsibility split (L-S14-2), Companion-via-references when SKILL.md exceeds (L-S16-1, applied S20), Cross-locale pattern extension (L-S18-1, S18 evidence), Telemetry rollup deterministic-aggregator-first (L-S19-1, S19 evidence). All 4 sections are practical-applied; section 1 has a TBD drift-signal D-DUPL.
- **Current state**: PRACTICAL-APPLIED:
  - Section 1 (cmd vs skill): ENFORCED in `drift-signals-D1-D9.sh` LOC ceilings + cmd 120 / skill 150 split. Drift signal D-DUPL (>50% line overlap between cmd and skill of same name) NOT yet implemented as hook.
  - Section 2 (companion-via-references): APPLIED Track 6 secondary closure S20 (5 skills refactored).
  - Section 3 (cross-locale extension): APPLIED Track 8b S18 (Vietnamese pattern adds).
  - Section 4 (telemetry deterministic-first): SHIPPED `self-awareness-aggregate.sh` 124 LOC.
  - **L-S28-1 candidate** ("Adapter library surface lock-in" / probe-before-strategy-commit) and **L-S30-1 candidate** ("PLAN VBW pre-flight") and **L-S32-1 candidate** ("Multi-strategy ladder probe-first") all reference architecture-amendment.md as their target — but these belong as separate hook/skill promotes (see lessons section).
- **Routing**: **promote-to-hook (D-DUPL)** + **defer rest of architecture-amendment**.
- **Rationale**: Sections 1-4 are post-hoc rationalizations of patterns ALREADY ENFORCED in code or commit history. Promoting them to architecture.md adds prose without enforcement gain. Section 1's pending action (D-DUPL hook) is a CLEAN hook target — `scripts/hooks/cmd-skill-duplication-check.sh` greps `.claude/commands/<name>.md` against `.claude/skills/<name>/SKILL.md` and emits info-level signal when both >120 LOC AND line-similarity >50%. Defer the architecture.md amendment itself — it's documentation of the past, not enforcement of the future. The 3 lessons (L-S28-1, L-S30-1, L-S32-1) targeting it should each route independently per the lesson section below.
- **Implementation for main session**:
  - **Hook**: Author `scripts/hooks/cmd-skill-duplication-check.sh` (~40 LOC bash; greps + counts overlap). Hook into PostToolUse on `.claude/commands/**` or `.claude/skills/**` writes; emit drift-log. Estimated LOC: 40.
  - **architecture.md**: NO file move. The 4 sections of the amendment can fold to inline 4-bullet "Patterns Discovered" appendix in `agent-workspace/constitution/architecture.md` (~12 LOC) IF main session has budget; else defer.
- **Re-trigger condition for full charter promote**: when D-DUPL hook fires ≥3× → evidence section 1 has teeth → bundle 4 sections into ADR.

### 9. session-budgets-amendment → **practical-applied**

- **Source**: `proposals/session-budgets-amendment.md` (74 LOC). Mode A/B/C/D cliff-vs-injector dispatch + verifier budget by scope (L-S21-1 evidence).
- **Current state**: FULLY APPLIED in code:
  - Mode A/B/C/D dispatch logic shipped in `autonomous-stop-watchdog.sh` + `budget-watchdog.sh` + `session-self-reboot.sh` (S14).
  - Verifier budget table (60-80K / 100-120K / 150K) used empirically at S21 (126K actual whole-Phase verifier).
- **Routing**: **practical-applied**.
- **Rationale**: Same logic as financial-data-protocol-amendment (S16): the rule lives in code/hook where it belongs per Q-E3. Charter promote adds no enforcement, splits source-of-truth. The only outstanding action is to ensure `agent-workspace/constitution/session-budgets.md` has 1-line cross-reference to the hooks. Optional fold-in if main session has budget.
- **Implementation for main session**: NO file move. Optional 1-line note in `session-budgets.md` § Hard Rules: "See `scripts/hooks/autonomous-stop-watchdog.sh` + `budget-watchdog.sh` for Mode A/B/C/D enforcement (L-S14-4)." LOC: 1.
- **Re-trigger condition for full charter promote**: if Mode-D detection regresses OR verifier-budget calibration changes → bundle into ADR.

---

## Per-Lesson Routing

### L-S25-1 (architect-subagent budget) → **promote-to-hook**

- **Lesson**: sandwich-architect for spec-frame + glossary work consumes ~2-3× PLAN target (192K vs 80K). Need explicit envelope `architect-spec-frame: 150-200K` distinct from `architect-pure-plan: 60-80K`.
- **Routing**: **promote-to-hook** (extension to existing `budget-watchdog.sh`).
- **Rationale**: Per Q-E3 hook-first. The check is mechanical: at subagent-dispatch time, classify subagent kind (spec-frame vs pure-plan vs verify) by reading the dispatch prompt for keywords (`drill-me|spec|glossary|ubiquitous-language` → spec-frame envelope; else pure-plan). Token-track subagent run vs envelope; soft-warn on overshoot. No charter promote needed.
- **Hook artifact**: `scripts/hooks/subagent-budget-classifier.sh` extension to `subagent-stop-logger.sh`. Read dispatch prompt header from telemetry; assign envelope; warn on overshoot. Estimated LOC: 30.
- **Re-trigger condition**: 2 more architect-overshoot events without hook → escalate to skill (write-a-skill § dispatch budgets).

### L-S26-1 (master-plan internal contradiction) → **promote-to-skill** (extend decompose-work or new clause in decision-discipline)

- **Lesson**: when master-plan deliverable text and success-criteria text contradict, prioritize deliverable explicit text over abstract count. Document drift in session log.
- **Routing**: **promote-to-skill** — append clause to `decision-discipline.md` proposal AT charter-promote time (carry through into D-014). Falls under decision-discipline Rule 2 (IMPL-tier resolution doctrine) — this is exactly that pattern at the master-plan level.
- **Rationale**: Hook can't disambiguate two prose snippets in same file (NLP-judgment territory). Skill captures procedure: when IMPL agent finds master-plan internal contradiction, prefer deliverable-text, document IMPL-S<N>-<M>. This IS the L-S11-2 / L-S17-1 pattern at a different scope. Best home: NEW sub-clause in decision-discipline.md Rule 2 ("master-plan internal contradiction") added at charter-promote time.
- **Skill artifact**: 1 paragraph added to `decision-discipline.md` Rule 2 (carried into the charter promote of #2 above). Estimated LOC: 6.
- **Re-trigger condition**: emerged 1× S26; if recurs in S40+ → standalone skill `master-plan-resolution`.

### L-S28-1 (vendor-API surface drift) → **promote-to-hook**

- **Lesson**: vnstock 4.0.2 dropped TCBS as Quote source between master-plan authoring and IMPL — 6-hour vendor drift bricked the deliverable. Need probe-before-IMPL on every external library.
- **Routing**: **promote-to-hook**.
- **Rationale**: Q-E3 cheapest-first. The check is deterministic: at IMPL-session entry, for every adapter-bound library named in master-plan deliverables, run `python -c "import <lib>; help(<lib>.<api>)"` or vendor-specific probe; compare to master-plan-named API. Diff = vendor drift; surface to agent. Hook has higher leverage than skill because it's invoked automatically on every IMPL.
- **Hook artifact**: `scripts/hooks/vendor-api-probe.sh` (Phase 1+ — invokes Python; this is post-Phase 0 so L-S11-1 portability relaxes). Reads master-plan, extracts library + API references, runs probe, emits drift-log. Estimated LOC: 60.
- **Re-trigger condition**: hook fires 3× without vendor drift → loosen to weekly cron; fires 0× across phase → check selector.

### L-S30-1 (PLAN VBW pre-flight) → **promote-to-skill** (extend existing skill) + **applied + add to CLAUDE.md ritual**

- **Lesson**: master-plan should `ls <target-deliverable-dirs>` to surface starter-kit files before authoring deliverable list. **Already APPLIED 3× (S30, S33, …)** per agent-notes.
- **Routing**: **promote-to-skill** (extend existing `decompose-work` skill) + add to CLAUDE.md ritual.
- **Rationale**: Q-E3 — hook is too rigid (which dirs to ls? prompt-dependent). Skill captures the procedure cleanly. The pattern fits naturally in `.claude/skills/decompose-work/SKILL.md` § Pre-Flight Checklist: "Before authoring deliverable list, `ls` each target dir to surface existing starter-kit files; absorb-or-replace decision is IMPL-tier per L-S11-2." Applied 3× already per checkpoint — high-confidence pattern.
- **Skill artifact**: append ~10 LOC clause to `.claude/skills/decompose-work/SKILL.md` § Pre-Flight Checklist. + Add 1-line to CLAUDE.md § Session Protocol: "PLAN sessions MUST `ls` target deliverable dirs (VBW pre-flight per L-S30-1; applied 3× S30/S33/S34)."
- **Re-trigger condition**: regress (skip pre-flight + write redundant deliverable) → harden to hook scanning master-plan for "ls" command in pre-flight section.

### L-S32-1 (multi-strategy ladder probe-first) → **promote-to-hook**

- **Lesson**: when master-plan ladder has ≥3 strategies, run thin empirical probe of all viable strategies BEFORE committing to one. (Predecessor's source_evidence may be stale.) Extends L-S28-1.
- **Routing**: **promote-to-hook** (sister hook to vendor-api-probe).
- **Rationale**: Same deterministic-probe pattern as L-S28-1; deserves its own hook because the ladder-evaluation pattern is distinct from single-API probe. Hook scans master-plan for "≥3 strategies" or "ladder" or "alternatives A/B/C" pattern, prompts IMPL agent to declare probe results before committing. Cheap, deterministic.
- **Hook artifact**: extension to `scripts/hooks/vendor-api-probe.sh` OR new `scripts/hooks/multi-strategy-probe-check.sh`. Bundles with L-S28-1 hook. Estimated LOC: 25 (incremental).
- **Re-trigger condition**: pattern recurs Phase 2 → promote to charter via architecture.md amendment (re-evaluate then).

### L-S33-X (no NEW lesson) → **confirmed-absent**

- **Lesson**: Per S33 close: "0 NEW promoted; 0 NEW candidates; 1 PRIOR APPLIED" — L-S30-1 was the prior-applied. No new lesson candidate from S33.
- **Routing**: **n/a** — no artifact to promote.
- **Rationale**: Confirmed via S33 close-checkpoint inspection. Nothing to do.

### L-S34-1 (cross-BC import detection) → **promote-to-hook** (CONFIRMED — S35 D6)

- **Lesson**: NEW domain-layer files in any BC must `grep -rn "from packages.domain"` before gate-pass. Caught manually at S34; need import-linter `independence` contract.
- **Routing**: **promote-to-hook** (importlinter `independence` contract in `pyproject.toml`).
- **Rationale**: Mandated per task brief. S35 D6 deliverable already wires this. Per Q-E3 hook-first; this is canonical-mandate hook target. Importlinter runs as Tier-1 deterministic gate; cross-BC violation = block-on-fail.
- **Hook artifact**: `[[tool.importlinter.contracts]]` of `type = "independence"` in `pyproject.toml` listing `packages.domain.market_data`, `packages.domain.fundamental`, `packages.domain.news`, `packages.domain.research`, etc. as mutually independent. Plus optional `scripts/hooks/cross-bc-import-check.sh` as bash backstop for IDE-time check. Confirm S35 D6 covers this.
- **Confirmation note for main session**: D6 deliverable in `006-S35-meta-loop-recovery.md` is the canonical implementation. This routing entry just confirms.
- **Re-trigger condition**: importlinter false-positive rate >10% → tune contract scope.

---

## Implementation Recommendations for Main Session

Listed in priority order; main session executes after this routing observation lands.

### CHARTER PROMOTES (HIGH PRIORITY — needs user-gate)

1. **Bundle 1 AskUserQuestion** for 3 charter promotes (autonomous-protocol + decision-discipline + memory-tiers). Single batch, 3 explicit-pick questions per Q-B2 charter-tier doctrine. After user approves:
   - Move `proposals/autonomous-protocol.md` → `agent-workspace/constitution/autonomous-protocol.md` (+ ADR D-013, ~127 LOC carry-over). Estimated LOC delta: 0 (move).
   - Move `proposals/decision-discipline.md` → `agent-workspace/constitution/decision-discipline.md` (+ ADR D-014 + add Rule 2 sub-clause for L-S26-1 master-plan contradiction + add Rule 4a phase-boundary trigger sub-clause). Estimated LOC delta: +18 (new sub-clauses).
   - Move `proposals/memory-tiers.md` → `agent-workspace/constitution/memory-tiers.md` (+ ADR D-015). Estimated LOC delta: 0 (move).

### HOOK PROMOTES (deterministic; no user-gate needed)

2. **Hook: cross-BC import-linter** (L-S34-1; confirms S35 D6).
   - File: `pyproject.toml` (add `[[tool.importlinter.contracts]]` independence contract).
   - Bash backstop: `scripts/hooks/cross-bc-import-check.sh` (~25 LOC).
   - Estimated LOC: 25 + 12 (TOML).

3. **Hook: tier-1 bloat check** (memory-tiers Rule companion).
   - File: `scripts/hooks/tier1-bloat-check.sh` (~30 LOC). Greps Tier 1 files at SessionStart, sums LOC, alerts if >8K.

4. **Hook: cmd-skill-duplication-check (D-DUPL)** (architecture-amendment partial).
   - File: `scripts/hooks/cmd-skill-duplication-check.sh` (~40 LOC).

5. **Hook: subagent-budget-classifier** (L-S25-1).
   - Extension to `scripts/hooks/subagent-stop-logger.sh` (+30 LOC) OR new file.

6. **Hook: vendor-api-probe + multi-strategy-probe** (L-S28-1 + L-S32-1; bundled).
   - File: `scripts/hooks/vendor-api-probe.sh` (~85 LOC; Phase 1+ relaxes L-S11-1 — Python OK).

7. **Hook: promotion-cycle-trigger** (decision-discipline Rule 4a; the META-fix).
   - File: `scripts/hooks/promotion-cycle-trigger.sh` (~40 LOC). Runs at phase boundary (detects via current-execution.md phase change); fires `promote-rule` skill dispatch automatically. **THIS IS THE DEAD-LOOP FIX.**

### SKILL/CLAUDE.md UPDATES

8. **Skill: decompose-work § Pre-Flight Checklist** (L-S30-1).
   - Append 10 LOC clause to `.claude/skills/decompose-work/SKILL.md`.
   - Add 1-line to `CLAUDE.md` § Session Protocol about VBW pre-flight ritual.

### PRACTICAL-APPLIED (1-line cross-references; LOW priority)

9. **CLAUDE.md addition**: "Every decision file MUST cite source_evidence ≥1 entry (per provenance-protocol proposal practical-applied)." LOC: 3.

10. **financial-data-protocol.md cross-reference** to `bash-hook-lint.sh` § L-S11-1 (S16 amendment practical-applied). LOC: 1.

11. **session-budgets.md cross-reference** to `autonomous-stop-watchdog.sh` Mode-D (S14 amendment practical-applied). LOC: 1.

### DEFERRED (no action this session; re-trigger documented)

12. financial-data-protocol-amendment-VN — re-trigger Phase 2 close + relevant BC entities.
13. invariants-amendment-VN — re-trigger same as #12.
14. architecture-amendment (sections 2-4) — re-trigger after D-DUPL hook fires ≥3×.
15. provenance-protocol — re-trigger Phase 3 first thesis ships.

### Estimated LOC budget for main session implementation

| Bucket | LOC |
|---|---|
| 3 charter file moves + 3 ADRs (D-013/D-014/D-015) | ~0 (moves) + ~360 (3 ADRs × 120 LOC) = 360 |
| New sub-clauses in decision-discipline.md (L-S26-1 + Rule 4a) | +18 |
| 7 new/extended hooks | ~250 (25+30+40+30+85+40 + buffer) |
| 1 skill extension + CLAUDE.md tweaks | ~15 |
| 3 practical-applied 1-line cross-references | ~5 |
| 4 defer cross-references | ~4 |
| **Total** | **~650 LOC** |

Fits comfortably in MULTI_TASK_IMPL budget (150-250K); the heavy lift is 3 ADRs + 3 charter moves + 7 hooks. Suggest splitting across 2 IMPL sessions if S35 budget tight: S35-A = charter promotes + ADRs (user-gated batch); S35-B = hooks + skill + cross-references.

---

## Drift signals worth surfacing during implementation

- **DR-CHARTER**: each of D-013/D-014/D-015 MUST have `human` in approval_chain (per provenance-protocol DR-CHARTER pattern). If user batch-approves all 3 in single AskUserQuestion, that's 1 approval covering 3 ADRs — record explicitly in each.
- **DR-PROV**: every new ADR MUST have non-empty source_evidence; the proposal file is the highest-authority source.
- **DR-DEFER**: 4 deferred proposals get explicit `re_attempt_prereq` field (Phase 2 close OR Phase 3 first thesis OR D-DUPL fires 3×). Defer-cycle counter starts at 1 for each.

---

## Doctrine validation

- **Q-E3 honored**: hook-first for 5 lesson promotes + 1 proposal-section + the meta-trigger. Skill for 1 lesson (L-S30-1; procedural). Charter for 3 proposals where charter is the right home (identity, decision-routing fabric, memory-tier hierarchy).
- **Q-B2 honored**: charter-tier batch goes through explicit-pick AskUserQuestion (not default-acceptance).
- **Q-E2 honored**: this routing IS the phase-boundary promotion run (S35 = META_LOOP_RECOVERY = Phase-2-mid recovery boundary). Frequency satisfies "phase-boundary OR ≥10 new agent-notes" trigger (≥10 satisfied).
- **L-S15-1 honored**: charter-tier split rule = bundle 3 charter promotes in 1 user batch but 3 explicit-pick questions; never default-accept charter.
- **Karpathy P3 (Surgical changes)**: 4 deferrals with explicit re-trigger conditions = no speculative promotion. Charter promotes ONLY for proposals already practical-applied at multiple decision points.
- **No-LLM-Math hard rule**: routing decisions cite empirical signals (sessions cited at decision-points) not LLM-feel.
