---
observation_id: 2026-05-16-project-status-review
type: project-status-snapshot
created_at: 2026-05-16T~20:10 SEAST
author: main session (Opus 4.7 max effort)
trigger: user_prompt 20260516_01.txt § 4 — "about the project, how is the current project going, from the last time we analyze the research folder and integrate the idea into old project? human need to verify or answer anything? about project business or system design? any decision? from old/pending/stale q&a, answer, decision, etc... to make you clear everything, ready to ship the final product?"
scope: end-to-end project state snapshot since research-integration analysis (2026-05-15) + open human-decisions inventory + gap-to-ship estimate
severity: INFO (status report; no decisions blocking; carries action list for user review)
---

# StockForge — Project Status Review 2026-05-16

## TL;DR

**Project is on Wave 1 critical path, executing per master plan.** Phase A/B/C/D first-cycle SHIPPED + VERIFIED. ~50% of Wave 1 themes shipped to first IMPL cycle. NDH adapter IMPL in flight (S344 background as of this writing). **Zero pending Q&A** awaiting human; **zero CHARTER-tier blocked decisions**.

**Three new harness proposals authored THIS TURN** (Items 1-3 from your prompt) — Stop-hook performance audit + block/ask gate redesign + planner upgrade. These DO need human ratification because they reshape autonomous-mode contracts. After ratification + IMPL, expected ~30-50% faster sessions + ~95% faster Stop + <1 human intervention per 20 turns (vs current ~1 per 3).

**Realistic gap to MVP (Phase 4 close = thesis system fully wired for one VN stock):** ~20-30 sessions at current cadence; ~12-18 sessions after harness upgrades land.

---

## 1. Research integration — disposition status (15 repos)

Source: `agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md` (919 LOC) + `INTEGRATION_PROPOSAL_SUPPLEMENT_2026-05-15.md` (603 LOC). Master plan: `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` (821 LOC). Ratified at S326 via D-061 (Q-INT-2026-05 all answered).

| # | Repo | Disposition | Theme | Status |
|---|---|---|---|---|
| 1 | ai-hedge-fund | HIGH (confirm; LICENSE caveat) | Theme H BC-8 multi-perspective | ⏸ queued Phase F-prime |
| 2 | crawl4ai | HIGH pattern; MEDIUM wholesale | Theme L crawling adapter | ✅ **CONSUMED** S338 (RateLimiter + RobotsTxtManager pattern) |
| 3 | dexter | MEDIUM | Theme H pattern reference (TS stack mismatch) | ⏸ PLAN-only |
| 4 | FinceptTerminal | **DEMOTE LOW** (AGPL + $10k/yr commercial) | Theme K (pattern-only deferred) | ⏸ Phase 2+ scope |
| 10 | nautilus_trader | HIGH | Theme M (deferred past Wave 1) + W0-2.1 substrate | ✅ W0-2.1 SHIPPED S329 |
| 12 | Scrapling | HIGH parser+adaptive; REJECT Cloudflare/patchright | Theme L SelectorChain + RobotsTxtManager | ✅ **CONSUMED** S338 (RobotsTxtManager port — BSD-3 attribution corrected in 9eaeed1) |
| 13 | TradingAgents | HIGH | W0-3 atomic-write + W0-4 HTML-separator + Theme H | ✅ W0-3+W0-4 SHIPPED S332 (D-062 + D-063); Theme H ⏸ queued Phase F-prime |
| 14 | TradingAgents-CN | HIGH-HIGHEST (Apache-core; proprietary app/frontend) | Theme H + I sentiment lexicon pattern | ⏸ queued Phase F-prime + Phase E |
| 15 | Vibe-Trading | HIGH | W0-5 path-safety quad + Theme N (deferred) | ✅ W0-5 SHIPPED S332 (D-064); Theme N candidate-deferred |
| 5,7,8,9,11 | MoneyPrinter*, NarratoAI, Pixelle-Video, MediaCrawler | pattern-only / DEMOTED / REJECT-license | various (mostly K + L sub-cases) | ⏸ pattern-only references; no LOC port |

**Bottom line**: 5 of 15 repos have already contributed shipped LOC (crawl4ai + Scrapling + nautilus_trader + TradingAgents + Vibe-Trading). 4 more queued for Theme F-prime/H/I. 6 remain pattern-only or DEMOTED. Integration plan is being EXECUTED as specified.

---

## 2. Wave 1 master-plan progress

Per `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` § 6.4 critical path L → I → H → J → K:

| Phase | Theme | Status | Sessions | Shipped artifacts |
|---|---|---|---:|---|
| A | Recovery + Inventory | ✅ DONE | S323-S325 | post-mortems + decision audit + plan-018 stub |
| B | Wave 0 substrate finish | ✅ DONE | S326-S334 | W0-1 FSM + W0-1b re-escalate + W0-2 python-determinism + W0-3 atomic-write + W0-4 html-separator + W0-5 path-safety; ADRs D-059/062/063/064 PROPOSED |
| C | Theme G I-S1-1 Charter Amend | ✅ DONE | S335-S336 | financial-data-protocol Rule 16 + invariants I-S1-1 alias; D-065 ACCEPTED |
| D | Theme L Crawling Adapter Shape (first IMPL cycle) | ✅ DONE | S337-S339 | CrawlerAdapter ABC + CrawlerRegistry + 5 primitives + CafeF migration; D-066 PROPOSED |
| (Harness) | Stabilization Sweep | ✅ DONE | S340-S342 | 6 of 9 anomalies CLOSED (escalation dedup + .tmp orphan cleanup + dispatch-template gap + stray cleanup + mypy noise + sandwich-* template updates) |
| D | Theme L NDH adapter | ⏳ IN FLIGHT | S343-S344 (background) | plan-022 ✅ written; dev running |
| D | Theme L Vietstock adapter | ⏸ queued | ~S345-S347 | -- |
| D | Theme L VietnamBiz adapter | ⏸ queued | ~S348-S350 | -- |
| E | Theme I Vietnamese NLP (tokenization + sentiment + claim extraction) | ⏸ queued | ~S351-S356 (3-5 sessions) | -- |
| F-prime | Theme H BC-8 multi-perspective primitives | ⏸ queued | ~S357-S362 (3-4 sessions) | -- |
| G-prime | Theme J PDF + table extraction | ⏸ queued | ~S363-S368 (3-4 sessions) | -- |
| H-prime | Theme K UX/output | ⏸ queued | ~S369-S374 (3-4 sessions) | -- |

**Deferred past Wave 1** (Phase 2+):
- Theme M — Risk-engine + backtest + MessageBus (nautilus_trader port)
- Theme N — Statistical Validation Pipeline (Vibe-Trading Monte Carlo + Walk-Forward)

---

## 3. Pending decisions awaiting human

### 3.1 Q&A bundles

- **Pending** (`human-workspace/q-and-a/pending/`): EMPTY ✅
- **Stale** (`human-workspace/q-and-a/stale/`): 4 bundles from 2026-04-29 (auto-moved long ago; informational only — not blocking any current work)
  - `2026-04-29-002-charter-tier-harness-self-correction.md`
  - `2026-04-29-003-up05-askuser-permissions-rawsessions.md`
  - `2026-04-29-005-track-5.5a-layer-realization.md`
  - `2026-04-29-006-up08-self-learning-pipeline.md`
  - Action: ARCHIVE — these were superseded by D-031 + D-058 + Q-INT mega-bundle answers + S250 close-of-Phase-3.5; safe to mv to `q-and-a/archive/`

### 3.2 Proposals awaiting cool-down OR explicit ratification

| Proposal | Status | Type | Action |
|---|---|---|---|
| `E4-fresh-context-verifier-arch-charter-tier.md` | PROPOSAL; cool-down 48h started 2026-05-12T~21Z (apply window ≥2026-05-14T~21Z — ALREADY OPEN) | CHARTER-tier | ASKUSER ratification gate; defer until autonomous-loop healthy enough to absorb new charter rule |
| `memory-tiers.md` | PROPOSAL (no explicit status frontmatter; 48-hour cool-down referenced in body) | Constitution-tier | ASKUSER ratification gate |
| `harness-severity-escalation-system-2026-05-14.md` | Phase A-D shipped at S310 per BEHAVIORAL HOLD; remaining tiers proposed | Constitution-tier | Items 1-2 from THIS prompt subsume this; supersede with redesign |
| 12 other proposals | mostly ACCEPTED at S43c/S43f or earlier; frontmatter sync done | Various | No action |

### 3.3 NEW proposals from THIS turn (your prompt 20260516_01.txt)

| Proposal | Action expected from you |
|---|---|
| `observations/2026-05-16-stop-hook-performance-audit.md` | ACCEPT quick wins (P1-P3; ~30 min each) → dispatch architect → IMPL+VERIFY sandwich. Architectural A1-A4 deferrable. |
| `observations/2026-05-16-block-ask-gate-redesign.md` | ACCEPT 3-tier model (HARD/PENDING/SOFT) + answer Q-RD1..Q-RD4 (4 minor design questions) → 2-session sandwich to ship |
| `observations/2026-05-16-planner-upgrade-proposal.md` | ACCEPT E1-E4 + answer Q-PL1..Q-PL4 (4 minor design questions) → 1.5-2 session sandwich to ship |

**Total new harness-work commitment if all 3 accepted**: ~4-5 sandwich sessions, ~700K total token budget (under your current "opus max" edict; ~250K if reverted to Sonnet for sandwich-dev).

### 3.4 NO blocked decisions

- 0 CHARTER-tier decisions blocking next-phase entry
- 0 SCOPE-tier ambiguity
- Phase D continuation (NDH → Vietstock → VietnamBiz) and Phase E entry both proceed without further ratification

---

## 4. Business / system-design questions surfaced (would be nice if answered)

These are NOT blocking but would tighten Phase E-K plans:

| Q-PROD1 | Vietnamese NLP stack — sentencepiece/SentenceTransformer vs underthesea (VN-native) vs both? Theme I deep-dive said "evaluate empirically"; you may have an opinion |
| Q-PROD2 | Thesis output channel — Streamlit dashboard (Phase 1 default) only, OR also Telegram daily digest? Charter v1.1 doesn't pin this |
| Q-PROD3 | Sentiment universe — start with VN30 (~30 tickers) per Phase 2 hypothesis, OR narrower (5-10 high-attention names) for tighter calibration loop? |
| Q-PROD4 | Backtest scope for MVP — Walk-Forward on VHM (exemplar from Phase 1) only, OR full VN30? (relates to Theme N deferral) |
| Q-PROD5 | KOL ingestion priority — keep BC-6 PAUSED per Phase 3 close, OR resume after Phase D in parallel with Phase E? |

None of these block current work; all are Wave 1 Phase E+ decisions.

---

## 5. Open notifications inventory

`human-workspace/notifications/` (9 active, auto-rotating):
- `html-separator-warn.md` — 29 violations per D-063 (known; cleanup expansion deferred per plan-018 RM10)
- `path-safety-warn.md` — likely D-064 deltas (auto-generated)
- `bash-hook-lint-warn.md` — known per Item-1 timeout finding
- `tracking-retention-cap-breach.md` — likely `agent-notes.md` over 700 LOC cap; archive needed
- `checkpoint-mentions-incomplete.md` — see below
- `python-determinism-warn.md` — 2 pre-existing violations in production code (D-059 flagged at S315 W0-2)
- `urgent.md` — auto-rotated 14:42 today; current contents minimal
- `N-INFO-file-pattern-lint.md` — informational
- `20260510-085159-track-c-kol-creds-prep.md` — KOL credential prep notification (no human action required per Phase 3 PAUSE)

**Action recommended**: bulk-archive these warns once Item-1 hook-performance fix lands (warns won't regenerate as aggressively). Until then, leave as-is.

---

## 6. Realistic ship gap to MVP

**Definition of MVP** (per `PROJECT_CHARTER.md` v1.1 + Phase 4 master plan):
- 9 BCs wired (currently 5 with shipped code: BC-1+BC-2+BC-5+BC-9 + partial BC-7)
- 1 VN ticker end-to-end thesis (VHM exemplar from Phase 1 — already produced)
- Multi-perspective adversarial thesis output for VN30 universe
- Streamlit dashboard with thesis browser
- Telegram daily digest (optional per Q-PROD2)

**Current cadence** (S323-S342 / 20 sessions over ~10 days):
- ~2 sessions/day average
- ~10K shipped LOC + 968 passing tests + 8 ADRs accepted + 1 charter amendment

**Remaining work at current cadence**:
- Phase D finish (Vietstock + VietnamBiz adapters): 4-6 sessions
- Phase E Vietnamese NLP: 3-5 sessions
- Phase F-prime Theme H multi-perspective: 3-4 sessions
- Phase G-prime Theme J PDF/tables: 3-4 sessions
- Phase H-prime Theme K UX/output: 3-4 sessions
- Integration + dashboard wire-up: 3-5 sessions
- Calibration loop activation (Karpathy outer loop seed): 2-3 sessions
- **Total**: ~22-30 sessions = ~11-15 days at current cadence

**With Items 1-3 harness upgrades shipped first** (~4-5 sandwich sessions = 2-3 days extra invested):
- Stop-chain ~5min → ~10sec (saves ~5 min per session × 25 future sessions = ~2hr wall time)
- Human interventions ~1/3 turns → ~1/20 turns (saves ~10 mid-session pauses = significant friction reduction)
- Planner ~30% wall-time savings per multi-track plan (~20 sessions affected × ~5 min each = ~100min wall time)
- **Net**: invest ~3 days, recover ~5+ days across remaining Wave 1 → MVP in **~17-25 sessions = 9-13 days**

---

## 7. Recommended next moves (ordered)

1. **Let S344 NDH dev finish** (in flight; should return within 5-15 min). Spot-check + dispatch S345 verifier OR defer if you want to absorb Items 1-3 first.

2. **Accept Item 1 (Stop-hook performance) quick wins** — P1-P3 are ~30 min each + fire-tests; low-risk; 95% Stop speedup. Architectural A1-A4 can wait.

3. **Decide Item 2 (block/ask redesign)** — answer Q-RD1..Q-RD4 (4 minor design questions). Ship as 2-session sandwich.

4. **Decide Item 3 (planner upgrade)** — answer Q-PL1..Q-PL4 (4 minor design questions). Ship as 1.5-2 session sandwich.

5. **Decide whether to revert "opus max" edict** after Items 1-3 land — cost-conscious framework alignment.

6. **Continue Phase D** (Vietstock + VietnamBiz adapters) — should now use upgraded planner + faster Stop chain.

7. **Enter Phase E** (Theme I Vietnamese NLP) after Phase D complete. CafeF source ready since S338.

8. **Consider answering Q-PROD1..Q-PROD5** at your convenience — tightens Phase E+ plans but not blocking.

---

## What I did NOT do (scope discipline)

- **Did not stop S344 dev** — it was running before this turn; let it complete to avoid token waste
- **Did not modify agent dispatches or hooks** — pure observation
- **Did not write a new master-plan or alter existing master-plan-2026-05-15** — superseded only if you decide to shift theme order
- **Did not commit anything**
- **Did not archive stale Q&A** — manual mv would be hygiene; deferred for your call

## Compliance attestation

- harness_priority_one ✓ (Items 1-3 deep-dives address user-flagged harness gaps; Item 4 is status)
- 0 charter / 0 constitution writes
- 0 production code changes
- 0 commits
- AP-1 N/A (no fresh-context dispatch; main session synthesizes from artifact reads)
- D-060 N/A
- 4 observations persisted at `agent-workspace/memory/observations/` per Track 6
- Source citations: `agent-workspace/research/INTEGRATION_PROPOSAL_2026-05-15.md` + master-plan-2026-05-15 + recent ADRs D-056..D-066 + current-execution.md + project.md (reconciled this turn) + dispatch.jsonl/component-telemetry summaries + 18 proposals/ entries + 4 stale q&a bundles + 9 active notifications
