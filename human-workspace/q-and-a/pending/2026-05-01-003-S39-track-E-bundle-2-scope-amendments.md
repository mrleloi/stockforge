---
id: QA-2026-05-01-003
topic: "MEGA-BUNDLE — All pending decisions S39+S40+S43b+L-S38 + branch + housekeeping (10 questions)"
superseded_topic: "Was: S39 Track E Bundle 2 — 3 SCOPE constitution amendments (now folded into Q1-Q3 below)"
opened_at: 2026-05-01T22:30:00+07:00
last_updated: 2026-05-01T23:00:00+07:00 (expanded to mega-bundle per user feedback "hỏi tôi mọi q&a luôn đi chứ")
expected_answer_by: 2026-05-08T22:30:00+07:00
priority: high
related_decisions:
  - D-013 (S35 promote-rule routing)
  - D-014 (Track F architecture)
  - D-015 / D-016 / D-017 (S38 charter promotes — mechanism precedent)
status: answered-2026-05-04-via-chat (awaiting user mv to answered/)
answered_at: 2026-05-04T00:00:00+07:00
answered_via: chat reply at S43c entry — "tôi accept toàn bộ q&a recommend của agent và các đề xuất còn đang block" (Vietnamese: accept all Recommended picks)
applied_picks: "Q1=A Q2=A Q3=A Q4=A Q5=A Q6=A Q7=a (deferred to next session) Q8=A Q9=A Q10=A"
mode: file-based-bundle
question_count: 10
defer_cycle: 0
source_prompts:
  - master-plan 005 § Track E rows 5-9 (Bundle 2 + Bundle 3)
  - L-S38-2 (subagent-as-LLM-substrate; surfaced 2026-05-01 user mid-S38 chat)
  - L-S38-1 (current-execution.md Tier 1 bloat 23.9K vs 8K)
  - S43a Stage B branch decision (was blocked on $; now unblocked via L-S38-2)
related_artifacts:
  - "Bundle 2 (Q1-Q3): proposals/architecture-amendment.md (98 LOC) + financial-data-protocol-amendment.md (42 LOC) + session-budgets-amendment.md (74 LOC)"
  - "Bundle 3 (Q4-Q5): proposals/financial-data-protocol-amendment-VN.md (116 LOC) + invariants-amendment-VN.md (108 LOC)"
  - "Q6: agent-workspace/constitution/autonomous-protocol.md (CHARTER per D-015) — proposed NEW § Cost Substrate"
  - "Q7-Q10: branch + housekeeping decisions"
gate_for: S39-IMPL execution + S40 + S43b + housekeeping cycle
mechanism_note: "All charter/constitution edits use S38 Q4=B mechanism (direct settings.json deny lift+restore). Verified working at S38."
---

# MEGA-Bundle 2026-05-01-003 — All Pending Decisions (10 Q)

> Per user feedback 2026-05-01: bundle ALL pending decisions across topics into one mega-bundle; every question MUST have lettered options. Superseded the original Bundle 2-only scope.

> Per `agent-workspace/constitution/decision-discipline.md` Rule 1 (ratified S38): SCOPE/CHARTER MUST require explicit user letter pick.

> **Reply format**: `Q1=A Q2=A Q3=A Q4=A Q5=A Q6=A Q7=a Q8=A Q9=A Q10=A` (or whatever picks; lowercase ok). Once received, agent auto-executes everything in one session (~80-120K main + subagent dispatches per Q7).

---

## Group A — Track E Bundle 2 (3 SCOPE constitution amendments)

> All 3 are AMENDMENTS to existing charter files (Edit semantics, not file move). Mechanism = same S38 Q4=B (verified zero-residue).

### Q1 — Append `architecture-amendment.md` (98 LOC) → `constitution/architecture.md`?

**What it adds**: NEW § "Slash Command vs Skill — Responsibility Split" after `## Forbidden Patterns`. Codifies L-S14-2 (skill-vs-command duplication multiplier). Slash commands = interactive entry points; skills = procedure libraries; no overlap.

**Practical-applied**: 3+ commands already follow this split (`/grill-me`, `/spec-author`, `/master-plan`).

- A: **Append (Recommended)** — Edit charter + ADR D-018 ratifies; effective immediately
- B: Defer to Phase 3 — collect more duplication evidence
- C: Reject — keep informal in agent-notes
- D: Open answer (specify)

**Answer**: **A** (applied 2026-05-04 at S43c via D-018)

---

### Q2 — Append `financial-data-protocol-amendment.md` Rule 11 Hook Portability (42 LOC) → `constitution/financial-data-protocol.md`?

**What it adds**: NEW § "Rule 11 — Hook Portability Per Phase" after `## When This Protocol Conflicts With Convenience`. Codifies L-S11-1 (Phase 0 hooks must be bash + POSIX only).

**Practical-applied**: 30+ hooks in `scripts/hooks/` already comply; `bash-hook-lint.sh § Check 1` deterministically enforces since S16.

- A: **Append (Recommended)** — Edit charter + ADR D-019 ratifies; bash-hook-lint upgrades from advisory to charter-mandated
- B: Move to architecture-amendment instead
- C: Defer entire proposal
- D: Open answer

**Answer**: **A** (applied 2026-05-04 at S43c via D-019)

---

### Q3 — Append `session-budgets-amendment.md` Mode A/B/C/D dispatch (74 LOC) → `constitution/session-budgets.md`?

**What it adds**: NEW § "Mode A/B/C/D — Cliff vs Injector Dispatch" after `## Hard Rules`. Canonicalizes D-004 thresholds (180K wind-down / 220K cliff / 250K hard cap) into mode mapping. Cross-references with `constitution/autonomous-protocol.md` Rule 2 (charter per D-015).

**Practical-applied**: `autonomous-stop-watchdog.sh` already implements; this just makes the threshold→mode mapping charter-binding.

- A: **Append (Recommended)** — Edit charter + ADR D-020 ratifies
- B: Promote to autonomous-protocol.md instead (charter-charter cross-promote; more friction)
- C: Defer entire proposal
- D: Open answer

**Answer**: **A** (applied 2026-05-04 at S43c via D-020)

---

## Group B — Track E Bundle 3 (2 CHARTER amendment-VN)

> CHARTER-tier per Q-B2 (extends Vietnam stock domain into existing charter files). All 4 OTHER deferred proposals (drift-signals-amendment-DR-INTENT + provenance-protocol) remain deferred per D-013.

### Q4 — Append `financial-data-protocol-amendment-VN.md` Rules 12-15 (116 LOC) → `constitution/financial-data-protocol.md`?

**What it adds**: NEW § "Vietnam-Domain Rules 12-15" after `## Rule 10: Backtest Reproducibility`, before `## Quick Reference Table`. Charter binds VN stock domain rules:
- Rule 12: HOSE/HNX/UPCoM tick sizes + Trần/Sàn enforcement
- Rule 13: T+2.5 settlement informational metadata (BR-3 from Phase 1 thin-slice spec)
- Rule 14: Per-Sàn tolerance for reconciliation (already implemented S33 ahead of charter)
- Rule 15: VND-only Phase 1; multi-currency deferred Phase 2+

**Practical-applied**: Phase 1 + 2 code (BC-1 reconciliation_service tolerance_for + sàn-tier in S33) already enforces Rule 14. This codifies what's shipped.

- A: **Append (Recommended)** — Edit charter + ADR D-021 ratifies; effective immediately
- B: Append BUT mark Rules 12, 13, 15 as Phase 2+ binding (defer enforcement of Rule 12 tick-size + Rule 13 T+2.5 + Rule 15 multi-currency until intraday/full-VN30/cash-mgmt land)
- C: Defer entire amendment to Phase 3
- D: Open answer

**Answer**: **A** (applied 2026-05-04 at S43c via D-021)

---

### Q5 — Append `invariants-amendment-VN.md` I-S55..I-S65 (108 LOC) → `constitution/invariants.md`?

**What it adds**: 11 NEW invariants after I-S54 (Calibration Drift Detection), before `## Code Integrity` section. Each invariant enforces a Vietnam-domain Rule from Q4 sibling amendment via dataclass `__post_init__` or Protocol. Examples:
- I-S55: Sàn enum (HOSE | HNX | UPCoM) — non-empty
- I-S58: T+2.5 informational only (cannot drive position math)
- I-S60: Per-Sàn tick-size validation
- I-S63: VND positive integer (no fractional VND)
- I-S65: Source agreement minimum 1 source per ticker (DUAL_SOURCE preferred per Rule 4)

**Phase-binding legend**: Phase 1 = enforced now (dataclass post_init); Phase 2+ = scaffold + binding deferred.

**Practical-applied**: BC-1 + BC-2 entities already follow these patterns (S27/S33/S34 implementations); this codifies them as I-S* numbered for traceability.

- A: **Append (Recommended)** — Edit charter + ADR D-022 ratifies; gate via Q4 (Q5 only effective if Q4=A or B)
- B: Append BUT skip Phase 2+ scaffolds (only ship Phase 1-binding invariants now; defer rest)
- C: Defer entire amendment to Phase 3
- D: Open answer

**Answer**: **A** (applied 2026-05-04 at S43c via D-022; Q4=A satisfied gate)

---

## Group C — L-S38-2 Charter Amendment (Subagent Cost Substrate)

> NEW lesson surfaced 2026-05-01 mid-S38 from your chat: *"sao lại cần key api? tìm cách chạy free đi. ví dụ dùng claude code, tạo subagent chạy."*

### Q6 — Amend `constitution/autonomous-protocol.md` (CHARTER) with NEW § "Cost Substrate"?

**What it adds**: NEW § codifying that any deferred-on-cost LLM path (S43a Stage B; R6 CafeF live; Q-S41-1 Opus dogfood) MUST first attempt subagent-dispatch substrate (Claude Code Agent tool) before requiring real $ via ANTHROPIC_API_KEY. Subagent dispatch billed against Claude Code subscription = zero marginal cost beyond subscription.

**Why charter (not skill/hook)**: It's a doctrine that reframes how the agent thinks about "blocked-on-cost" — touches identity (StockForge = self-funded research aid; ANTHROPIC_API_KEY direct = dependency creep).

**Practical-applied**: S43b (NEW path) and R6 reframe both depend on this rule.

- A: **Amend charter (Recommended)** — Edit autonomous-protocol.md + ADR D-023 ratifies; effective immediately; binds future "needs API key" framing
- B: Author as separate skill `cost-substrate-pivot/SKILL.md` instead (per Rule 3 hook-skill-charter cheapest-first; subagent-pivot is procedural not identity)
- C: Defer — apply ad-hoc per session without charter binding
- D: Open answer

**Answer**: **A** (applied 2026-05-04 at S43c via D-023)

---

## Group D — Branch Decision (Next Session After This Bundle Executes)

### Q7 — Once this bundle is applied (S39 + S40 + Q6 amend done), what next session?

Multiple unblocked branches:

- **a**: **S43b LIVE-via-subagent (Recommended if Q6=A)** — viết `SubagentLLMPerspectiveAdapter` thay `ClaudeLLMPerspectiveAdapter`; chạy 5-thesis dogfood (BID/BVH/CTG/FPT/GAS) qua Agent dispatch with Bear/Bull/Quant system_prompts (spec 006 § B.5 verbatim); writes thesis-log/ entries. ~150-200K (incl 15+ subagent dispatches at ~5-10K each)
- **b**: **R6 subagent crawl** — CafeF live smoke (multi-listing 5 tickers expanded to 30 VN30) qua subagent dispatch running existing scraper code. Validates Rule 6 provenance pipeline end-to-end. ~60-100K subagent
- **c**: **L-S38-1 trim current-execution.md** — paginate historical Phase 0 + Phase 1 session-rows to `agent-workspace/memory/sessions-rollup/<phase>.md`; reduces Tier 1 bloat 23.9K → ~8K (clears tier1-bloat-check.sh WARN). ~30-50K
- **d**: **Stop here — let user mv Q&A files + ack before next batch**
- **e**: Open answer

**Answer**: **a** (S43b LIVE-via-subagent next session — deferred from this turn due to budget; this turn applies Q1-Q6 + Q8-Q10 + HR-4)

---

## Group E — Operational Housekeeping (IMPL-tier defaults; user opt-out)

> These are IMPL-tier per `decision-discipline.md` Rule 1; agent COULD self-decide. Surfacing for user awareness + opt-out (per Rule 1 ARCH "explicit pick preferred; agent default with transparent flag if user unavailable" interpretation, applied conservatively here).

### Q8 — IMPL-S35-1 hook regex bug fix (low priority carry from S35)?

Hook somewhere in `scripts/hooks/` has a regex bug (low impact; documented as "low priority" in S35 close + S42 checkpoint). Agent can fix in ~5-10K main.

- A: **Fix this session/next session (Recommended)** — agent investigates + patches + smoke-tests
- B: Defer until it actually fires false-positive
- C: Open answer

**Answer**: **A** (S43c session — investigation + patch attempted)

---

### Q9 — Spec 006 § B.10 cost profile amendment (S42 carry)?

Spec estimated $1.30/thesis Opus; actual measured $0.90/thesis (Phase1Synthesizer fully deterministic per spec § A.6.1). Cosmetic spec amendment to keep spec-vs-actual aligned.

**Note**: With Q6=A subagent-substrate, this number becomes "$0/marginal" anyway — but the spec text still claims "$1.30 estimated"; should reflect either actual measurement OR new substrate.

- A: **Amend spec to actual $0.90 (current S42 baseline)** — keeps spec vs prod-code aligned; no charter touch
- B: **Amend spec to "$0 marginal via subagent substrate" (post Q6=A binding)** — supersedes A; only valid if Q6=A
- C: Defer to Phase 2 close batch amendment
- D: Open answer

**Answer**: **A** (literal "Recommended"; Q6=A also enables future B-style amendment; applied 2026-05-04 at S43c)

---

### Q10 — Phase 2 envelope amendment ADR (post-S43b cumulative ~1.5-1.7M vs 1.5M envelope band)?

Phase 2 cumulative tracking ~11-14% over envelope band (master-plan 005 §Budget). S43b will likely push to ~15-20% over. Need explicit envelope amendment ADR (IMPL-tier; agent can author).

- A: **Author IMPL-tier envelope amendment ADR after S43b close (Recommended)** — documents calibration delta; updates master-plan § Budget for remaining sessions
- B: Hold until Phase 2 close ceremony bundle
- C: Trigger SCOPE-tier escalation if envelope exceeds 25% over (one more Q&A bundle)
- D: Open answer

**Answer**: **A** (deferred to next session per Q7=a; Q10 ADR will follow S43b dogfood close)

---

## Decision Synthesis (post-answers)

After Q1-Q10 answers, agent will execute in single session:
1. **Q1-Q3 apply (Bundle 2)**: Edit settings.json deny lift → 3 charter Edit appends → restore deny → author D-018/D-019/D-020 → update each charter frontmatter `last_amended_at` + `amending_decisions` → S39-IMPL row in current-execution.md
2. **Q4-Q5 apply (Bundle 3)**: Same mechanism for amendment-VN; author D-021/D-022; verify cross-binding (Q5 gates on Q4)
3. **Q6 apply**: Amend constitution/autonomous-protocol.md NEW § Cost Substrate; author D-023; cross-link from D-015
4. **Q7 branch**: Execute next session per pick (a/b/c/d/e)
5. **Q8-Q10 housekeeping**: Per picks
6. Mega-checkpoint write; session log; updates `current-execution.md`

**Estimated total budget** (worst case all-A picks): ~120-160K main + ~80-100K subagent (Q7=a S43b dispatches) = ~200-260K combined. Phase 2 envelope post-mega will push to ~1.7-1.9M cumulative; Q10=A authors envelope ADR documenting.

## Notes

- **Mechanism (S38 Q4=B precedent)**: agent edits `.claude/settings.json` to temporarily lift constitution Edit/Write deny (deny>allow precedence forces direct settings.json Edit, not local override) → applies amendments → restores deny. Verified zero-residue at S38.
- **L-S38-1 (current-execution.md trim)** in Q7c is independent of Q1-Q6; can run anytime
- **2026-04-29-004** = born-answered (8 Qs already answered via AskUserQuestion at S15 close); just sitting in pending/ awaiting your mv to answered/
- **2026-05-01-002** (Track F SCOPE gates) = answered inline at S43a entry (Q-S41-1=C / Q-S41-2=A); awaiting mv to answered/
