---
observation_id: defer-s43b-status-S43e
type: status-assessment
created_at: 2026-05-04
related_session: S43e (continuation 5)
purpose: clarify current state of DEFER-S43b-1 (cost ledger drift) + DEFER-S43b-2 (RatioService bank schema Q-S28-3) at Phase 2 close, so Phase 3 entry session does not re-investigate stale defers
---

# DEFER-S43b-1 / DEFER-S43b-2 status assessment

## DEFER-S43b-1 — cost ledger drift verification → ✅ EMPIRICALLY RESOLVED (recommend close)

**Original concern** (S43b harness recovery): cost ledger was reporting `$0` because the LLM adapter error-path swallowed cost data when JSON parse failed. Fixed at S43b via 3-tier prose-tolerant JSON extractor (`subagent_transport.py:55-118`) which prevents the error-path from being entered for typical prose-wrapped LLM output.

**Empirical evidence post-fix**:
- S43b last turn: `$0.95 bubbled correctly, no longer $0 from error path` (per `current-execution.md` S43b-EVIDENCE row line 189)
- S43d 5-thesis dogfood (BID/BVH/CTG/FPT/GAS): 5/5 reported real cost figures totalling $6.8413 (avg $1.37 per thesis)
- S43e VF-3 CTG reproducibility: $0.8178 reported (vs S43d baseline $0.9099 — both real, both within VF-2 ≤$2 average target)

**Source-of-truth code path verified intact** (this observation, not new investigation):
- `claude_llm_perspective_adapter.py:47` documents subagent transport CLI-reported `total_cost_usd` as authoritative
- `perspectives/{bear,bull,quant}_agent.py` all unpack `(raw_json, cost_usd, model_id, prompt_hash)` from `call_llm()` and pass `cost_usd=Decimal(str(cost_usd))` to perspective record (preserves precision per Charter Principle 9 / I-S1)
- 0 hits for `cost_usd = 0` or `cost_usd = Decimal(0)` in error-path code

**Recommendation**: close DEFER-S43b-1 at next checkpoint write. The "drift verification" is concretely satisfied by 6 separate dogfood runs (S43b-EVIDENCE-FPT + S43d × 5 + S43e × 1) all reporting real cost figures. No further investigation needed unless cost reverts to $0 in Phase 3 dogfood.

## DEFER-S43b-2 — RatioService bank schema (Q-S28-3) → 🔭 GENUINELY OPEN (Phase 3 sizing decision)

**Original concern** (S28 BC-2 Fundamental authoring): bank tickers (BID, CTG, VCB, MBB, etc. — ~7 of VN30) use a different chart-of-accounts than non-bank tickers (CAR / NIM / NPL / LDR / CIR are the standard bank ratios; P/E + P/B still apply but ROE / D/E / Net Margin / ROA need bank-specific formulas using net interest income, provisions, etc.).

**Q-S28-3 doctrine adopted at S28**: skip silently per "log + continue" — the `RatioService.compute_phase2_ratios` method returns only ratios where all required inputs exist; missing inputs are NOT errors, just absent rows in the output dict (`ratio_service.py:154` doc comment).

**Empirical Phase 2 effect** (per S43d 5-thesis dogfood):
- 5 tickers selected: BID (bank), BVH (insurance), CTG (bank), FPT (tech), GAS (oil & gas)
- BID + CTG = 2/5 bank tickers
- Bear/Bull/Quant agents handled bank-ticker fundamental gaps via Rule-7 honest-insufficient narrative ("limited fundamentals; skip ratio-based VALUE dimension")
- VF-2 cost target met ($6.84 / $1.37 avg ≤ $2 spec); thesis_id deterministic across re-runs (VF-3 PASS)
- Real harm signal: 0 (no thesis incorrectly synthesized; all flagged data gaps explicitly per Rule-7)

**3 options for Phase 3 sizing**:

- **Option A — Keep doctrine** (RECOMMENDED Phase 3 entry): the "log + continue" doctrine empirically works; bank-thesis quality limited by data-gap-attribution narrative, not by missing ratios. Ship Phase 3 with bank-as-special-case-via-narrative; revisit only if peer-comparable spec § A.10 gates on bank-specific ratios.
- **Option B — Implement bank-schema ratios**: extend RatioService with `compute_bank_ratios()` returning CAR/NIM/NPL/LDR/CIR; requires BC-2 ingestion to also fetch bank-specific line-items (deposit liabilities, loan portfolio breakdown, NPL classification). Estimated 1 sub-session ~80-120K (FOCUSED_IMPL); would close Q-S28-3 but adds ingestion-side complexity.
- **Option C — SCOPE-tier defer**: explicitly defer bank-schema to Phase 4+ with charter-tier note (bank fundamental analysis is its own discipline; treating as Phase 3 scope dilutes Phase 3 KOL/pump focus).

**Recommendation**: Option A (keep doctrine) for Phase 3 entry; revisit only if Phase 3 dogfood reveals bank-thesis quality is materially worse than non-bank thesis quality. Phase 3 master-plan should explicitly list this as a deferred line-item, not a hidden gap.

## Action items for Phase 3 entry session

1. Move DEFER-S43b-1 from "open" to "closed-empirically-resolved-S43e" in checkpoint substrate-residue list.
2. Re-classify DEFER-S43b-2 as "Phase 3 master-plan input — pick option A/B/C at Phase 3 SCOPE gate".
3. Phase 3 SCOPE user-gate question should include: "RatioService bank-schema — A=keep doctrine / B=implement / C=defer Phase 4+ (Recommended A)".

## Provenance

- **Origin**: S43b harness recovery deferred items (per `2026-05-01-session-43b-evidence-harness-recovery.md` lines 128-129)
- **Status assessment author**: Claude Opus 4.7, S43e continuation 5 (2026-05-04)
- **Trigger**: User repeated "continue" past Phase 2 close ceremony; remaining autonomous-actionable items thin → status clarification chosen as honest closing-loop work
- **No new code authored** this turn (status assessment only; honors L-S30-1 VBW pre-flight by reading actual files vs trusting checkpoint claims)
