# Chương 2 — Mô Hình Tư Duy

> **Phân khu Diataxis**: Explanation (định hướng hiểu)
> **Thời gian đọc**: ~20 phút
> **Điều kiện tiên quyết**: Bắt Đầu Nhanh (Chương 1) hoặc bất kỳ tiếp xúc nào trước đó với Claude Code

Chương này giới thiệu **năm ý tưởng lớn** mà harness được xây dựng xung quanh. Mọi artifact trong hệ thống — mọi hook, mọi quy tắc constitution, mọi persona agent — tồn tại để phục vụ một hoặc nhiều ý tưởng này.

Nếu bạn hiểu năm cái này, hơn 200 bộ phận chuyển động sẽ trở nên đọc được.

---

## Ý Tưởng 1 — Người Dùng Là Đạo Diễn, Claude Code Là Cả Đội

Trước khi harness tồn tại, "dùng LLM để code" trông như: human gõ prompt, LLM gõ code, human edit và paste kết quả, lặp lại. Pattern này chạm trần nhanh. Quá 4-5 giờ làm việc, human trở thành nút thắt cổ chai khi review từng dòng.

Harness mã hóa một mô hình khác:

> **Người dùng viết spec, đặt direction, đưa ra các quyết định kiến trúc, ratify các quyết định, và review các kết quả.
> Claude Code viết code, test, các spec thường lệ, dispatch subagent, chạy verification, và báo cáo.
> Hai bên gặp nhau tại các ratification point được định nghĩa rõ, không phải tại mỗi dòng.**

Sự phân chia này không phải là ẩn dụ. Nó được thực thi bởi file permissions ([`.claude/settings.json`](../../../.claude/settings.json) allow/deny), bởi session protocol ([`session-start` ↔ `session-end`](08-vong-doi.md#session-protocol)), bởi [boundaries](04-hien-phap.md#boundaries) (`B-1: Never modify PROJECT_CHARTER.md`), và bởi vòng đời [Q&A bundle](08-vong-doi.md#qa-bundle).

Khi người dùng gõ một mục tiêu, harness giả định người dùng muốn một director's report — một brief, một plan, một confirmation prompt — không phải một nghìn dòng code chưa được verify đổ vào repo.

### Hệ Quả

- Agent **hỏi trước khi làm** khi câu trả lời thay đổi scope hoặc commit các nguồn lực ở charter-tier. ([AskUserQuestion chỉ dành cho các quyết định SCOPE/CHARTER](04-hien-phap.md#autonomous-protocol).)
- Agent **đề xuất, không áp đặt**. Quy tắc mới đi vào `agent-workspace/proposals/` trước; ratification chuyển chúng sang `agent-workspace/constitution/`.
- Agent **dispatch chính mình** khi công việc cần context tươi mới. Người dùng thấy một notification, không phải bức tường token.

### Tại Sao Điều Này Quan Trọng

Nguyên nhân lớn nhất đơn lẻ của các dự án AI-assisted thất bại là **drift giữa intent và implementation**. Sự phân chia director/team, được thực thi bởi cơ chế harness, là câu trả lời cấu trúc.

---

## Ý Tưởng 2 — Sandwich Pattern Vượt Trội Hơn Single-Agent Khi Quá 200K Token

Trong **Session 4 của dự án này** (post-mortem ở trong `agent-workspace/memory/post-mortems/`), một single agent đã cố plan, implement, và verify một tính năng multi-track trong một session. Session vượt 200,000 token và sụp đổ: plan drift khỏi implementation, implementation drift khỏi spec, và verifier (cùng agent, cùng context) ký duyệt cho công việc bị hỏng.

Tỉ lệ thất bại ở scale đó, đo thực nghiệm, là khoảng **20% catastrophic**.

Fix là **sandwich pattern**:

```
┌─────────────────────────────────────────────────────────────────┐
│ SESSION 1  —  ARCHITECT  (50-80K Sonnet / 150-230K Opus)        │
│  sandwich-architect subagent reads spec + constitution +         │
│  existing code → writes detailed plan to session-plans/pending/  │
│  NEVER writes production code.                                   │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ SESSION 2  —  DEV  (100-150K)                                    │
│  sandwich-dev subagent reads plan + relevant files → writes      │
│  code + tests per plan. NEVER re-plans.                          │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ SESSION 3  —  VERIFIER  (30-60K Sonnet / 80-180K Opus)           │
│  sandwich-verifier subagent reads plan + diff → reports verdict  │
│  (PASS / PASS-WITH-CONCERNS / FAIL). FRESH CONTEXT — has NEVER   │
│  seen the architect's or dev's reasoning. Adversarial by design. │
└─────────────────────────────────────────────────────────────────┘
```

Ba agent chia sẻ *artifacts* (plan, code, ADR) nhưng **không chia sẻ context**. Verifier thấy cùng evidence mà architect đã thấy nhưng tái dựng kết luận một cách độc lập. Sự bất đồng giữa intent của architect và cách đọc của verifier tự nó là tín hiệu bug.

### Tại Sao Ba Session Mà Không Phải Một

Sự phân chia đóng đồng thời ba failure mode:

1. **Plan/impl drift**: architect không thể drift giữa chừng vì session của architect đã kết thúc trước khi implementation bắt đầu.
2. **Echo-chamber verification**: verifier không thể rationalize các sai lầm của architect vì verifier chưa bao giờ đọc chúng.
3. **Context exhaustion**: mỗi session ở trong budget vì công việc nó sở hữu bị giới hạn.

### Pattern Sống Ở Đâu Trong Code

- Persona architect: [`.claude/agents/sandwich-architect.md`](../../../.claude/agents/sandwich-architect.md)
- Persona dev: [`.claude/agents/sandwich-dev.md`](../../../.claude/agents/sandwich-dev.md)
- Persona verifier: [`.claude/agents/sandwich-verifier.md`](../../../.claude/agents/sandwich-verifier.md)
- Plan template: [`agent-workspace/session-plans/pending/`](../../../agent-workspace/session-plans/pending/) (đọc bất kỳ plan gần đây, ví dụ, `045-S395-plan-vhm-thesis.md`)

### Nó Đổ Vỡ Ở Đâu

Pattern thất bại khi:

- Các dispatch brief trích dẫn các path không tồn tại (architect VBW bắt được điều này — xem [STEP 2.X](05-skills-commands-agents.md#sandwich-architect-mechanics)).
- Verifier được yêu cầu viết các phát hiện mâu thuẫn với persona no-Write của nó (cluster [PCG-S401-4](12-noi-tai.md#pcg-s401-4)).
- Main session re-plan trong khi dev (bị cấm bởi [Hard Rule "Never mix PLAN and IMPL in same session"](04-hien-phap.md#hard-rules)).

Những edge case này là lý do pattern cần harness xung quanh, không chỉ ba persona.

---

## Ý Tưởng 3 — Constitution Là Bất Biến; Mọi Thứ Khác Tiến Hóa

Harness vẽ một lằn ranh cứng giữa các artifact **bất biến** và **mutable**:

| Layer | Tính mutability | Modification protocol |
|---|---|---|
| `PROJECT_CHARTER.md` | Bất biến trong ~3 tháng | Human revision tường minh + version bump + cool-down 48h |
| `agent-workspace/constitution/*.md` | Bất biến đối với agent | Chỉ human, bị denied bởi `.claude/settings.json` |
| Skills, commands, agents | Mutable | Agent có thể edit; LOC ceilings được thực thi bởi hooks |
| Plans, sessions, observations | Append-only | Không bao giờ xóa; supersede qua trường status |
| Production code (`packages/`, `apps/`) | Mutable | Agent edit theo plan; sandwich pattern áp dụng |
| Memory routing (`current-execution.md`) | Mutable | Agent cập nhật tại session boundary |
| Configuration (`.claude/settings.json`) | Mutable | Agent có thể edit allow/deny/hooks |

### Tại Sao Hierarchy Này

Nếu không có nó, agent có thể âm thầm thay đổi quy tắc của chính nó. Drift sẽ cộng dồn. Sau 50 session, hệ thống sẽ không còn nhất quán.

Với nó:

- Charter đặt vision và principles. Nó thay đổi khi *dự án* thay đổi, không phải khi agent có một ý tưởng thông minh.
- Constitution mã hóa các quyết định đã ratified. Nó thay đổi qua một quy trình ADR tường minh với cool-down window.
- Skills, commands, agents, hooks tiến hóa tự do — nhưng luôn phục vụ constitution.
- Memory tích lũy state. State cũ được archive, không bao giờ bị phá hủy.

### Các Nguyên Tắc Charter (Verbatim)

11 nguyên tắc từ [`PROJECT_CHARTER.md`](../../../PROJECT_CHARTER.md):

1. **Evidence grounding** — mọi claim, mọi số phải truy ngược được về source + as-of date.
2. **Structured output over narrative** — multi-criteria assessment, không bao giờ một score "buy/sell" đơn lẻ.
3. **Adversarial by design** — các perspective bear + bull + critic + quant + behavior + manager.
4. **Proprietary data moat** — mọi tin tức được ingested, mọi KOL recommendation được tracked.
5. **Pattern transfer + local adaptation** — global setups + overlay đặc thù Vietnam.
6. **Human-in-loop is the product** — augment suy nghĩ, không bao giờ thay thế nó.
7. **Dogfood mandatory** — nếu tôi không dùng nó hàng tuần cho các quyết định thật, nó bị giết.
8. **Calibration over confidence** — hệ thống track độ chính xác của chính nó, không bao giờ claim confidence nó chưa earn được.
9. **No LLM math** — LLM không bao giờ tạo ra số. Tất cả các tính toán qua deterministic code.
10. **Position sizing & risk management are deterministic** — code-enforced.
11. **Harness must self-verify firing, not self-attest existence** — mọi hook ship kèm với một firing-test; `harness-health-self-scan.sh` verify signal-set HH-1 đến HH-12 trên mọi UserPromptSubmit + SessionStart.

Các nguyên tắc 9, 10, 11 là **các trụ chịu lực của harness**. Mọi hook và file constitution cuối cùng phục vụ ít nhất một trong số chúng.

---

## Ý Tưởng 4 — Harness Phải Self-Verify Firing, Không Self-Attest Existence

Đây là **Nguyên tắc Charter 11**, và nó xứng đáng có section riêng vì nó không hiển nhiên và là trụ chịu lực.

### Lớp Bug

Trong Phase 2.5 của dự án, harness được audit và tuyên bố "8 trong 8 track xanh". Mười bốn session sau, ba empirical failure nổi lên — tất cả được phát hiện bởi push của người dùng, không phải bởi self-check của chính harness:

1. **`autonomous-stop-watchdog.sh`** đã được wired trong Stop chain. Smoke test pass. Nhưng log cho thấy **zero entry `Stop session=` qua 10 turn**. Hook script tồn tại; nó không bao giờ fire.
2. **`promote-rule` backlog** tích lũy hơn 6 session các agent-notes entry chưa xử lý. Tại sao? Trigger là Stop-hook-dependent (xem #1).
3. **Auto-detect orphans**: ~20 agent-notes entry được tag `Auto-detect: yes` không có hook script đồng hành nào được ship. Tag là một lời hứa; implementation không bao giờ land.

Trong mỗi trường hợp, hệ thống hoàn chỉnh về mặt cấu trúc (file present, smoke test green, ritual closure ticked) nhưng **bị hỏng về mặt empirical** (hook silent trong log production).

### Nguyên Tắc

> *"Ritual closure của một track (file existence + smoke-test exit 0) bị cấm cho đến khi empirical-firing evidence (production log entry / artifact / telemetry row từ hoạt động session thật) được capture."*
> — Nguyên tắc Charter 11

### Cách Nó Được Thực Thi

- Mọi hook ship với một **companion firing-test** tại `scripts/hooks/firing-tests/<hook-name>-fire-test.sh`. Naming là bắt buộc.
- Hook liên tục [`harness-health-self-scan.sh`](06-hooks.md#harness-health-self-scan) chạy **12 signal (HH-1 đến HH-12)** trên mọi `UserPromptSubmit` và `SessionStart`, check xem các hook expected có thực sự emit trong `.session-hooks.log` trong các threshold.
- [`harness-health-protocol.md`](../../../agent-workspace/constitution/harness-health-protocol.md) mã hóa các signal ở constitution tier.
- Drift giữa *expected fires* và *observed fires* tự nó là một harness drift signal escalate qua severity pipeline.

### Điều Này Có Nghĩa Gì Với Bạn

Khi bạn thêm một hook, công việc chưa xong khi hook script tồn tại. Công việc xong khi firing-test pass VÀ production log cho thấy hook fire trong điều kiện real-session. Bất kỳ điều gì ít hơn là điều Nguyên tắc 11 cấm.

Nguyên tắc này là lý do có 115 firing-test cho 118 hook (3 cái thiếu được tracked tại HH-10).

---

## Ý Tưởng 5 — Calibration Over Confidence

Ý tưởng thứ năm là sâu nhất. Nó được mượn từ [Bridgewater principles](https://www.principles.com/) và framing của [Karpathy autoresearch](https://karpathy.ai/).

> **Một confidence claim chỉ có giá trị nếu nó truy ngược về một historical hit rate. Nếu không, claim là niềm tin hallucinated, không phải evidence.**

Harness vận hành điều này ở nhiều nơi:

| Cơ chế | Nó track gì | Nó sống ở đâu |
|---|---|---|
| `personal-risk-profile.md` | Risk tolerance của user + historical bias | `agent-workspace/memory/` |
| `calibration/` | Per-signal hit rate, KOL accuracy | `agent-workspace/calibration/` |
| `sync-tracker/state.tsv` | Per-category confidence score (Q-RCA-1) | `agent-workspace/memory/sync-tracker/` |
| `dispatch.jsonl` | Per-agent-dispatch outcome distribution | `agent-workspace/memory/` |
| `mistake-log.md` | Catalog thất bại với root cause + prevention rule | `agent-workspace/memory/` |
| `agent-notes.md` | Các quy tắc earn được qua kinh nghiệm thật | `agent-workspace/memory/` |
| `attestation-log.tsv` | Verdicts sandwich-verifier (PASS / PASS-WITH-CONCERNS / FAIL) | `agent-workspace/memory/` |

### Ranh Giới (Boundary)

[Boundary B-12](04-hien-phap.md#boundaries) nói:

> *"Không bao giờ claim confidence mà không có calibration data. Không emit các cụm từ như 'high confidence' hoặc 'strong signal' trong bất kỳ thesis, alert, hoặc output nào trừ khi claim truy ngược về data của `calibration/` với `n_samples`, `hit_rate`, `lookback_period`."*

Ranh giới này, như Nguyên tắc 11, là cấu trúc. Agent không thể nói "Tôi rất tự tin" theo mặc định. Nó chỉ có thể nói "Tôi rất tự tin, với hit rate X trên Y sample trong window Z" — và X/Y/Z phải đến từ data thật, không phải judgment của LLM.

### Tại Sao Nó Quan Trọng Với Harness

Harness tự nó là một loạt cá cược ("hook này sẽ bắt được lớp X của failure"). Vòng đời promote-rule ([Chương 10](10-tu-cai-thien.md)) là calibration-over-confidence được áp dụng cho chính harness: mọi quy tắc phải có catch-rate, và các quy tắc với zero catch-rate qua 3+ session bị demote hoặc retire.

---

## Năm Ý Tưởng Hợp Thành Như Thế Nào

Năm ý tưởng không độc lập. Chúng củng cố lẫn nhau:

```
        Director/Team
              ↓
       (split work between
        spec-author and
        code-writer)
              ↓
        Sandwich Pattern
              ↓
       (each session bounded;
        verifier independent)
              ↓
       Constitution Immutable
              ↓
       (ratified decisions
        do not silently drift)
              ↓
       Principle 11 (Self-Verify)
              ↓
       (verify rules ACTUALLY
        fire in production)
              ↓
       Calibration Over Confidence
              ↓
       (each rule's effectiveness
        is measured, not believed)
```

Bỏ bất kỳ cái nào, và các cái khác yếu đi:

- Không có **sự phân chia director/team**, agent làm mọi thứ và human review mọi thứ — bottleneck được khôi phục.
- Không có **sandwich pattern**, single-agent session quá 200K sụp đổ — drift được khôi phục.
- Không có **constitution immutability**, agent âm thầm viết lại quy tắc của chính nó — tính nhất quán bị mất.
- Không có **Nguyên tắc 11**, harness trở thành một bộ phim đạo cụ: script tồn tại, không có gì fire — regression vô hình.
- Không có **calibration**, mọi quy tắc sống mãi mãi bất kể giá trị — ritual bloat.

Năm cái cùng nhau tạo thành một hệ thống nhất quán. Mỗi chương tiếp theo là cái nhìn sâu hơn về cách sự nhất quán đó được engineer.

---

## Cái Chương Này Không Bao Phủ

- **Harness vật lý trông như thế nào** — file layout, layer composition. → [Chương 3](03-kien-truc.md)
- **Các quy tắc bất biến cụ thể** — mọi file constitution. → [Chương 4](04-hien-phap.md)
- **Session thực sự flow như thế nào** — session types, plan lifecycle, sandwich choreography. → [Chương 8](08-vong-doi.md)
- **Drift được phát hiện như thế nào** — DR1-DR12, HH-1-HH-12. → [Chương 9](09-he-thong-chat-luong.md)
- **Quy tắc được promote như thế nào** — `agent-notes.md` → skill → hook → constitution. → [Chương 10](10-tu-cai-thien.md)

Nếu bạn muốn một *bản đồ hệ thống*, tiếp tục đến [Chương 3](03-kien-truc.md). Nếu bạn muốn *rule book*, nhảy đến [Chương 4](04-hien-phap.md).
