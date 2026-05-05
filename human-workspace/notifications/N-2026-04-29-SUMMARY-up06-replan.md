---
id: N-2026-04-29-SUMMARY-up06-replan
level: SUMMARY
created_at: 2026-04-29T16:30:00+07:00
related_decisions:
  - D-002 (REV-3 amendment)
  - D-003 (NEW)
related_bundle: human-workspace/q-and-a/pending/2026-04-29-004-up06-track-5.5-amendment.md
expires_at: never (permanent record of scope amendment)
---

# SUMMARY — UP-06 Scope Amendment Complete (Track 5.5 Inserted)

User prompt `human-workspace/user_prompt/20260429_06.txt` (UP-06) raised 3 strategic concerns + directive "biến sync thành ưu tiên hàng đầu". Agent fired 2 rounds of AskUserQuestion (8 picks) and locked Phase 0 amendment.

## What changed

**Track 5.5 INSERTED** between Track 5 and Track 6. Three sub-tracks executed Layer→Sync→Self-Cap:

- **5.5a — Layer Foundation** (S5, ~150K): `.claude/manifest.yaml` + directory restructure separating harness/stockforge + `/attach` skill for portability. **No multi-tenant** (per Q6=D).
- **5.5b — Sync Infrastructure** (S6+S7, ~300K): 4-mechanism ensemble — intent-vs-impl-diff agent + sync-state.md + periodic grilling hook + sync-bundle-template.
- **5.5c — Self-Capability + Karpathy Autoresearch** (S8+S9, ~400K): decompose-work skill + capability-map.md + try-n-approaches skill + OTEL+JSONL hybrid measurement + promote-rule skill.

**Track 6 → REWRITE post-5.5** (S10) — skills/subagents port now layer-aware via 5.5a manifest.

**Track 9 → REDUCED** (~80K) since 5.5c absorbs OTEL stack setup.

## Budget delta (acknowledged via Q8=A)

- REV-2: ~1.28M total Phase 0
- **REV-3: ~2.02M total Phase 0** (within user-accepted ~1.5-2M band)
- Session count: 9 → 14

## Artifacts

- `agent-workspace/memory/decisions/003-up06-track-5.5-sync-layer-selfcap.md` (NEW)
- `agent-workspace/memory/decisions/002-phase-0-harness-bootstrap-design.md` (REV-3 amendment in-place)
- `agent-workspace/session-plans/pending/002-track-5.5-sync-layer-selfcap.md` (Track 5.5 master plan)
- `agent-workspace/session-plans/pending/001-port-from-orch.md` (REV-3 update — whole-phase view)
- `human-workspace/q-and-a/pending/2026-04-29-004-up06-track-5.5-amendment.md` (born-answered audit)
- `agent-workspace/memory/sessions/2026-04-29-session-4-replan.md` (this session's log)
- `agent-workspace/memory/checkpoints/latest.md` (S4-replan close handoff)

## Next session = S5 = Track 5.5a Layer Foundation

Pre-flight already prepared in `latest.md`. User can now `continue` to start S5, or drop a new prompt to redirect.

## UP-06 doctrine compliance

- ✅ AskUserQuestion was PRIMARY for all 8 questions (no file-only-default; mobile-remote-safe)
- ✅ Multi-batch chain (2 batches × 4) respected 4-question limit
- ✅ Pre-Amendment Delta Summary protocol applied (Q8 surfaced budget delta explicitly)
- ✅ No charter-tier questions absorbed via mixed bundle (these were SCOPE-tier 0.90)
- ✅ Bundle file = pure audit trail; not assumed as input surface

## What did NOT change

- Charter (`PROJECT_CHARTER.md`) — untouched
- Constitution (`agent-workspace/constitution/`) — untouched (still requires explicit human approval per workspace contract)
- Track 6 SCOPE — preserved; only execution shifts to layer-aware (post-5.5)
- Stock-domain invariants I-S1..I-S35 — unchanged
- Tracks 0-5 deliverables — frozen (S3 ship)

## Sync directive elevation

Per D-003 § Why #1: UP-06 §1 directive "biến sync thành ưu tiên hàng đầu" is now BINDING. Track 5.5b infrastructure addresses it via 4-mechanism ensemble. After Track 5.5b ships, every session will have access to sync-state.md + periodic grilling + intent-vs-impl-diff agent + sync Q&A template.
