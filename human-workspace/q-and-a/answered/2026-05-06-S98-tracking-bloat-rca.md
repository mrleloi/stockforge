---
bundle_id: 2026-05-06-S98-tracking-bloat-rca
created_at: 2026-05-06T11:00:00+07:00
created_by: main-session-S98 (claude-opus-4-7)
tier: CHARTER (re-architecting tracking system)
status: answered-via-chat-2026-05-06
related_user_prompt: 2026-05-06 mid-S98 chat (verbatim quote in S98 checkpoint USER ESCALATION block)
basis: harness_priority_one.md + S91→S98 cycle as Exhibit A (tracking cost > tracking benefit)
expected_response_format: explicit lettered pick per Q (Q-B2 rule — CHARTER/SCOPE-tier requires explicit letter)
---

# Q&A Bundle — S98 Tracking-Bloat RCA (CHARTER-tier)

## Context

User escalated tracking-system bloat as Priority #1 mid-S98:
> "hệ thống file dùng để tracking đang quá nhiều và cồng kềnh... chi phí tracking, load track data, thời gian tracking đang KHÔNG hiệu quả so với cách sử dụng tracking data. cần cách tiếp cận hiệu quả cho longterm hơn"

Empirical evidence at S98 close:
- `current-execution.md`: **304 KB** (>256KB Read tool limit — broken)
- `agent-notes.md`: 216 KB / 2008 LOC
- `mistake-log.md`: 116 KB / 1175 LOC
- `component-telemetry.jsonl`: **2.3 MB** (no rotation policy)
- `memory/` total: ≈ **6.4 MB**
- 71 hooks, 34 read current-execution, 10 read agent-notes
- L-S87-1 cycle S91→S98: 8 sessions × ~0.4-1K main = **~5-8K main TỔNG**, catch-rate post-S94 = **0/4 = 0%** (Exhibit A: cost >> benefit, self-recursive trap)

Full RCA in S98 chat response (preserved in checkpoint USER ESCALATION block).

---

## Q-RCA-1 — Triển khai Layer 1 (cap & compact) ngay S99?

**Why-needed**: Layer 1 is the mechanical fix that resolves immediate tool-limit breakage. Decision frames how aggressive the cap thresholds are.

- **A**: ✅ Full Layer 1 S99 (1 session impl ~5-8K main) — agent-notes 500 LOC cap, current-execution 5-session cap, mistake-log 200 LOC cap, telemetry weekly rotate. Archive overflow to `<file>/archive/YYYY-MM.md`. Add `tracking-retention.sh` hook (daily Stop). Add CLAUDE.md retention rule.
- **B**: Triage — chỉ cap current-execution.md (urgent: tool-limit broken) + telemetry rotate; defer agent-notes/mistake-log cap to later session.
- **C**: Bảo thủ — agent-notes 1000 LOC cap, current-execution 10-session cap, mistake-log 500 LOC cap (gấp đôi recommended).
- **D**: Khác (nêu rõ thresholds).

---

## Q-RCA-2 — L-S87-1 + L-S90-1 + L-S94-1 cluster: demote / retire / giữ?

**Why-needed**: This is the self-recursive codification trap (T2 in RCA). Decision determines whether we accept "rule about rule about rule" or break the cycle.

- **A**: ✅ DEMOTE all 3 to **passive** — giữ rule trong agent-notes header nhưng KHÔNG audit routine mỗi session. Re-engage chỉ khi 1 signal cụ thể (e.g., backlog description bị ai đó question, hoặc quarterly check).
- **B**: RETIRE all 3 hoàn toàn — xoá khỏi agent-notes (vẫn còn trong git history); promote dr-vs-passive heuristic thành deterministic hook (cheap).
- **C**: Giữ L-S87-1 + L-S90-1 active, retire chỉ candidate L-S94-1.
- **D**: Status quo — giữ tất cả như cũ; chấp nhận cost ~5-8K main / 8 sessions for 0% catch-rate.

---

## Q-RCA-3 — Layer 3 (reframe forensic vs working-memory split): triển khai?

**Why-needed**: This is the philosophical reframe (T4 in RCA). Decision determines whether tracking files are FORENSIC (write-often-read-rare) or also WORKING-MEMORY (read-often).

- **A**: ✅ YES — codify trong constitution `memory-tiers.md` (đã có draft từ Q-D3 closed; chỉ chưa codify). Forensic vs working-memory split. **Working-memory budget ≤ 20 KB** mỗi `continue` (boot-summary 4 KB + checkpoint 2 KB + routing 8 KB + project.md head 6 KB ≈ 20 KB). Forensic files (sessions/*, telemetry, full mistake-log, full agent-notes) NOT loaded routine — only on-demand grep.
- **B**: YES nhưng chỉ áp dụng routine `continue`; on-demand task vẫn được full read khi cần.
- **C**: NO — giữ current pattern (mọi tracking có thể là working memory khi cần).
- **D**: Khác.

---

## Q-RCA-4 — Layer 4 (dedicated index files cho hot files): triển khai?

**Why-needed**: This is the architecture fix (T3 hook fan-out). Decision determines whether we build deterministic index renderers to spare hooks from full-file reads.

- **A**: ✅ YES — extend `index-registry-renderer.sh` cover agent-notes / mistake-log / current-execution. Output `<file>.idx.tsv` (1-5 KB each) auto-rendered Stop event. Hooks read INDEX (1-5 KB) thay vì FULL file (200+ KB). LLM read full file CHỈ khi authoring/grilling.
- **B**: YES nhưng chỉ index agent-notes (lesson-id-line-anchor-status map) — cost/benefit clearest ở đây.
- **C**: NO — dùng grep on-demand đơn giản hơn (no index file, no maintenance overhead).
- **D**: Khác.

---

## Q-RCA-5 — Session ritual cleanup (drain rituals đang tự duy trì)?

**Why-needed**: This is the entrenchment trap (T5). Decision determines whether mỗi-session rituals must justify cost/benefit periodically.

- **A**: ✅ YES — mỗi ritual (L-S87-1 audit / drift-rollup re-scan / sync-grilling refresh / per-session log / current-execution prepend) phải có **catch-rate threshold + dormancy clock**. Catch-rate < X% over Y sessions → auto-demote to passive.
- **B**: Chỉ drop L-S87-1 audit (clearest 0% case); giữ drift-rollup + sync-grilling + per-session log.
- **C**: Drop tất cả mỗi-session rituals; chuyển sang **weekly aggregator** (1 hook chạy weekly, gộp drift-rollup + audit + sync-grilling).
- **D**: Status quo.

---

## Q-RCA-6 — Component-telemetry.jsonl 2.3 MB (chưa rõ ai dùng)?

**Why-needed**: Largest single file in memory/, no rotation policy, unclear ROI.

- **A**: ✅ Audit ai đọc (per grep: `self-awareness-aggregate.sh` + `profile-template-auto-populate.sh`); rotate **weekly**, retain **4 weeks** max, archive `component-telemetry.YYYY-WNN.jsonl.gz`. Add `telemetry-rotate.sh` daily Stop hook.
- **B**: Drop file hoàn toàn nếu post-audit ROI < threshold.
- **C**: Giữ nguyên (không bùng vì JSONL append-only và memory disk còn nhiều).
- **D**: Khác.

---

## Q-RCA-7 — Promote-to-hook trade-off khi LLM rule có catch-rate thấp?

**Why-needed**: Sets the policy for when LLM-rule should become deterministic hook vs retired vs kept.

- **A**: ✅ Khi 1 LLM rule (e.g. L-S87-1) catch-rate = 0 over 3+ sessions → mặc định **promote-to-hook** (1-time impl cost ~3K) **HOẶC retire**. KHÔNG tích luỹ thêm refinement inline (như đã xảy ra với L-S90-1 → L-S94-1 candidate).
- **B**: Promote-to-hook là LAST resort; rule-codification (lesson-tích-luỹ) ưu tiên.
- **C**: Status quo — rule tích luỹ trong agent-notes; review tay khi nhớ.
- **D**: Khác.

---

## Lifecycle

- **status**: pending
- **expected**: user picks 1 letter per Q (A-D); explicit picks required per Q-B2 (CHARTER/SCOPE-tier no default acceptance)
- **next-step on receipt**: S99 begins with reading user picks → produces Layer 1 impl plan (deterministic) + Layer 2-4 ADR drafts (per picks) → user ratifies before commit

When answered: update `status: answered-via-chat-YYYY-MM-DD` + add `answer:` block per Q. Auto-mover hook will mv to `q-and-a/answered/` per HH-E.2 contract.

---

## Answers (2026-05-06, via chat)

User reply verbatim: "ok đồng ý các recommendation qa, continue fix"

Interpretation: blanket approval of recommendation (option **A**) for every Q.

- **Q-RCA-1 → A**: Full Layer 1 S99 (agent-notes 500 LOC, current-execution 5-session, mistake-log 200 LOC, telemetry weekly rotate, tracking-retention.sh hook, CLAUDE.md retention rule).
- **Q-RCA-2 → A**: DEMOTE L-S87-1 + L-S90-1 + L-S94-1-candidate to passive in agent-notes header.
- **Q-RCA-3 → A**: Codify `memory-tiers.md` in constitution with 20 KB working-memory budget.
- **Q-RCA-4 → A**: Extend `index-registry-renderer.sh` cover agent-notes / mistake-log / current-execution; hooks read index instead of full file.
- **Q-RCA-5 → A**: Mỗi ritual phải có catch-rate threshold + dormancy clock; auto-demote khi catch-rate < X% over Y sessions.
- **Q-RCA-6 → A**: Component-telemetry.jsonl rotate weekly, retain 4 weeks max, archive nén; telemetry-rotate.sh daily Stop hook.
- **Q-RCA-7 → A**: LLM rule catch-rate = 0 over 3+ sessions → mặc định promote-to-hook (~3K impl) HOẶC retire; không tích luỹ thêm refinement inline.

Status: answered-via-chat-2026-05-06; closed_at: 2026-05-06 (S99 entry).
