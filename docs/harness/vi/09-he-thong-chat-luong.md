# Chương 9 — Hệ Thống Chất Lượng

> **Phân khu Diataxis**: Explanation + Reference
> **Thời gian đọc**: ~35 phút
> **Điều kiện tiên quyết**: Chương 6 (Hooks), Chương 8 (Vòng Đời)

Hệ thống chất lượng là verification layer của harness. Đó là cái thực thi "công việc này thực sự đã xong" — tại ba cadence khác nhau, bởi ba cơ chế khác nhau, với ba escalation path khác nhau.

Chương này bao quát:

- Mô hình 3-tier quality gate
- VBW protocol (Verify-Before-Write)
- Drift signals DR1-DR12 + DR-S
- Harness health signals HH-1..HH-12
- Charter Principle 11 và cách nó định hình mọi thứ

---

## 9.1 — Mô Hình 3-Tier Gate

Per CLAUDE.md § Quality Gates, mỗi change pass qua ba tier verification:

### Tier 1 — Deterministic (Per Commit, Auto-Block on Fail)

Mechanism: deterministic script exit 0 (pass) hoặc non-zero (fail). Không LLM judgment. Auto-block commit nếu bất kỳ cái nào fail.

Checks:
- `mypy --strict` — type checking, strict mode
- `pytest` — full test suite
- `ruff` — lint + format check
- `drift-signals-D1-D9.sh` — drift catalog (HIGH severity block)
- Dependency cycle check (thủ công `pydeps` invocation)
- `bash-hook-lint.sh` — cho bất kỳ modified hook script

Configuration: `STOCKFORGE_LOC_STRICT`, `STOCKFORGE_DRIFT_STRICT`, `STOCKFORGE_CITATION_STRICT` env vars trong `settings.json`. Default: warn-only; strict mode: block on fail.

Output đi đâu: `agent-workspace/quality-reports/deterministic/<TS>.md` (placeholder — actual outputs route vào session logs per current state).

### Tier 2 — Probabilistic (Per Merge, Separate Agent)

Mechanism: LLM-mediated checks dispatched trong fresh-context subagent. Trả về verdict, không bao giờ auto-block; main session decide action.

Checks:
- `/vbw-check` — Verify-Before-Write protocol áp dụng cho task hiện tại
- `/drift-check` — semantic drift signals (DR7 UL drift, DR12 anti-pattern)
- `/devils-advocate` — adversarial critique của plan/spec/code
- `intent-vs-impl-diff` subagent tại phase boundary — bắt silent absorption
- Architecture boundaries check (manual qua `/drift-check`)
- UL consistency check (qua `/ul-audit` → `ul-auditor` subagent)
- Code review (Tier 2 sandwich-verifier trong canonical workflow)
- **Calibration drift check** — confidence claims vs hit rate

Output đi đâu: `agent-workspace/quality-reports/probabilistic/<TS>.md` (placeholder; actually routes vào verifier session logs + observations).

### Tier 3 — Human (Per Phase Boundary hoặc Strategic Decision)

Mechanism: explicit user ratification qua `AskUserQuestion`.

Required cho:
- Architectural decisions (CHARTER-tier ratify)
- API contracts (SCOPE-tier ratify)
- Eval regression sign-off
- Thesis quality review
- Constitution amendments (ratification + cool-down)

Output đi đâu: `human-workspace/decisions/<file>.md`.

### Tại Sao Ba Tier

Mỗi tier bắt một failure class khác:

| Failure class | Caught by |
|---|---|
| Syntax error / type mismatch / failing test | Tier 1 |
| Logical inconsistency / hidden assumption / missed edge case | Tier 2 |
| Wrong direction / scope drift / strategic misalignment | Tier 3 |

Skip Tier 1 = bugs ship. Skip Tier 2 = code tốt làm sai việc. Skip Tier 3 = wrong product.

---

## 9.2 — VBW Protocol (Verify-Before-Write)

Đo được: 11.1% hallucination rate trước khi adopt VBW → 0% sau.

### Vấn Đề Cốt Lõi

LLM có xu hướng viết code từ **memory/convention** thay vì từ **verified source**. Khi agent "biết" một pattern thông dụng, brain auto-complete từ convention mà không cross-reference với actual implementation.

Failure mode quan sát được:
- Viết methods không tồn tại: `enable_kill_switch()` (agent invent từ đề cập "kill switch")
- Wrong argument counts: `create(4 args)` khi actual là `create(6-7 args)`
- Method name từ convention: `clear_domain_events` vs actual `clear_events`
- Import paths đoán từ pattern

Result: code trông đúng, không khớp reality, fail im lặng hoặc tại runtime.

### Bốn Checkpoint

| Checkpoint | Khi nào | Required Actions |
|---|---|---|
| **PRE-SPEC** | Trước khi viết bất kỳ specification | Đọc ACTUAL source code; list TẤT CẢ methods của entity liên quan từ code; verify factory method signature (exact param count và types); check nếu feature đã tồn tại (grep trước khi giả định "missing"); mark spec items là CURRENT (exists) vs PROPOSED (to implement) |
| **PRE-TEST** | Trước khi viết bất kỳ test | Verify mọi method call tồn tại (check type definitions); verify factory signature (exact params từ đọc `create()` source); verify import paths (grep cho actual file location); verify base class methods (đọc entity/aggregate base); test một file trước (type check trước khi viết thêm) |
| **MID-IMPLEMENT (mỗi 5 steps)** | Trong session | Cross-reference với spec (vẫn aligned?); check plan state; review recent edits cho convention-derived assumptions; re-read task description (5 phút re-read tiết kiệm hours of wrong direction) |
| **PRE-COMMIT** | Trước khi stage changes | Verify diff match plan; mypy/pytest/ruff pass; không có D1-D9 drift signal mới |

### Cách Operationalize

Mỗi sandwich plan có section **STEP 0 — VBW Live Verification**. Cả architect VÀ dev PHẢI execute STEP 0 trước bất kỳ production work:

```markdown
## C — VBW STEP 0 (Live Verification)

C.1 — Path existence verification
- Glob: `packages/application/fundamental/pdf_table_extractor_port.py`
  Expected: exists, ~120 LOC
  Verified: ✓ (S407)

C.2 — Signature verification
- Read: `packages/application/fundamental/pdf_table_extractor_port.py:42-78`
  Expected: `class PdfTableExtractorPort(Protocol):`
    `def extract_tables(self, pdf_path: Path, *, max_pages: int = 100) -> list[dict]: ...`
  Verified: ✓

C.3 — Caller verification
- Grep: `import PdfTableExtractorPort`
  Expected matches: `apps/dashboard/fundamental_view.py`, `tests/fundamental/test_pdf_*.py`
  Verified: 2 callers found
```

Nếu STEP 0 surface mismatch (ví dụ, cited path không tồn tại), plan được rewrite HOẶC dispatch được abort.

### Red Flags Trigger Mid-Implement Check

- Viết 3+ files liên tiếp không chạy test
- Tạo assumption về API không verified từ code
- Plan section đang được implement diverge từ initial reading
- Dispatch brief cite một path mà grep không tìm thấy

---

## 9.3 — Drift Signals DR1-DR12

Drift signals là deterministic checks cho architectural decay. Chạy qua command `/drift-check` + auto-fired tại Stop qua [`drift-signals-D1-D9.sh`](06-hooks.md#drift-signals).

### Tiered Coverage Map (D-029 / S48d ratification)

**Tier-A — Automated detector** (Stop-hook `drift-signals-D1-D9.sh`):

| Signal | Maps to | What |
|---|---|---|
| DR-A1 | formerly D1 | LOC ceiling overrun (PRIMARY per Q-A2; HIGH tại >20%) |
| DR-A2 | formerly D2 | Self-attestation mâu thuẫn với actual file content |
| DR-A3 | formerly D3 | Charter/SCOPE bundled với sub-charter items |
| DR-A4 | formerly D8 | Confidence claim không có calibration metadata |
| DR-A5 | formerly D9 | Runtime-path-leak vào write-only learning-data tree |
| DR1 | NEW S48c HH-B.4 | Domain layer import framework (grep `packages/domain/**`) |
| DR3 | NEW S48c HH-B.4 | LLM call không có retry/budget wrapper (grep `packages/infrastructure/**`) |
| DR6 | NEW S48c HH-B.4 | `Any` type trong domain package |
| DR8 | NEW S48c HH-B.4 | Cross-BC direct import |
| DR-S1 | covered by D6 | LLM emit number không có tool call |
| DR-S2 | covered by D7 | Thesis output không có bear case |
| DR2 | PARTIAL via D5 | Evidence không có citation |
| DR5 | PARTIAL via D5 | Claim stored không có metadata |
| DR10 | PARTIAL via D4 | Spec dangling reference |

**Tier-B — Manual `/drift-check` command** (semantic, LLM-judgment):

| Signal | What |
|---|---|
| DR4 | Hardcoded prompt bên ngoài `prompts/` |
| DR7 | UL term drift (cũng qua `/ul-audit`) |
| DR12 | Anti-pattern từ `agent-notes.md` |

**Tier-C — DB-query check** (yêu cầu Postgres connection):

| Signal | What |
|---|---|
| DR9 | Synthesis output không có verifier step |
| DR11 | Stale session-handoff (cũng git-log diff-able qua Tier-A heuristic) |

### HIGH Severity Signals (Block Commit/Merge)

| Signal | Rule |
|---|---|
| **DR1** | Domain layer import framework |
| **DR2** | Evidence không có citation |
| **DR5** | Claim stored không có required metadata |
| **DR6** | `Any` type trong domain package |
| **DR-S1** | LLM emit number không có tool call |
| **DR-S2** | Thesis output không có bear case |
| **DR-A1** | LOC ceiling overrun (>20%) |

### Example: DR1 Check

```bash
grep -rn "from fastapi" packages/domain/ --include="*.py"
grep -rn "from pydantic" packages/domain/ --include="*.py"
grep -rn "from sqlalchemy" packages/domain/ --include="*.py"
grep -rn "import psycopg" packages/domain/ --include="*.py"
grep -rn "from redis" packages/domain/ --include="*.py"
```

Bất kỳ match nào = HIGH severity. Fix: move framework-dependent code sang `infrastructure/`. Define một Protocol trong `domain/application`, implement adapter trong `infrastructure/`.

### Drift Log Flow

```
Hook fires → write to .drift-signals.log
  ↓ Stop chain
drift-rollup-daily.sh (idempotent per day)
  ↓ promotes to drift-logs/YYYY-MM-DD-rollup.md
  ↓ Stop chain (MUST run AFTER rollup)
drift-signals-log-rotate.sh
  ↓ weekly rotate
  ↓ archive to drift-signals-archive/<week>.log
```

---

## 9.4 — Harness Health Signals HH-1..HH-12

Các signal *self-monitoring* của harness. Codified trong [`harness-health-protocol.md`](../../../agent-workspace/constitution/harness-health-protocol.md). Implemented inline bởi [`harness-health-self-scan.sh`](06-hooks.md#harness-health-self-scan).

### Tại Sao HH-* Tồn Tại (Charter Principle 11)

Phase 2.5 close 8/8 track GREEN tại ritual audit. 14 session sau, ba empirical failure surface — tất cả detected qua user push, không qua harness self-detection:

1. **M-S49b-1**: `autonomous-stop-watchdog.sh` wired + smoke-test pass; logs show 0 entry `Stop session=` qua 10 turn.
2. **Promote-rule backlog**: 6+ session tích lũy agent-notes entries không có `promotion-cycle-trigger.sh` kích hoạt.
3. **Auto-detect orphans**: ~20 entry tag `Auto-detect: yes` không có companion hook ship.

Mỗi cái structurally complete nhưng **empirically broken**. Catalog HH-* là deterministic answer: continuously verify hooks actually fire trong production logs.

### 12 Signals

| # | What | Severity | Threshold |
|---|---|---|---|
| **HH-1** | Stop hook kích hoạt ≥1 lần mỗi active session | HIGH (KI-S49b-1 suppress: MEDIUM) | STOP_COUNT ≥ 1 kể từ latest SessionStart cho current SID |
| **HH-2** | UserPromptSubmit kích hoạt ≥1 lần trong 10 phút cuối | HIGH | RECENT ≥ 1 trong 10 phút cuối |
| **HH-3** | Promote-rule cycle delta < 8 sessions (≤10 ngày) | MEDIUM (HIGH tại 14d+) | Latest `promote-rule-S*.md` mtime trong 10 ngày |
| **HH-4** | Auto-detect candidates không có companion hook ≤ 2 | MEDIUM | `Auto-detect: yes` count - hooks count ≤ 2 |
| **HH-5** | Tier 1 always-loaded ceiling ≤ 8K tokens | HIGH | Combined token estimate của Tier 1 ≤ 8000 |
| **HH-6** | Hook dispatch sidecar staleness | MEDIUM | Latest dispatch sidecar mtime < threshold |
| **HH-7** | Checkpoint freshness (latest.md mtime ≤ 1800s) | MEDIUM | `now - mtime < 1800s` |
| **HH-8** | Charter file md5 stability trong cool-down | MEDIUM | Charter md5 không thay đổi trong proposal cool-down |
| **HH-9** | Mistake-log freshness | MEDIUM | mistake-log.md không stale so với recent sessions |
| **HH-10** | Firing-test orphans ≤ 2 | MEDIUM | Hooks không có companion firing-tests ≤ 2 |
| **HH-11** | Hook firing log mtime < threshold | LOW | Recent hook activity present |
| **HH-12** | project.md Phase == current-execution.md Phase | MEDIUM | Phase field nhất quán qua các file |

### Execution Order (Cheap-First)

Per [`harness-health-self-scan.sh`](06-hooks.md#harness-health-self-scan), HH checks được order theo computational cost:

1. HH-7 (single mtime check)
2. HH-11 (single mtime check)
3. HH-8 (md5)
4. HH-1 (log grep)
5. HH-2 (log grep with time bucket)
6. HH-9 (log grep)
7. HH-3 (find + age)
8. HH-6 (multi-file mtime + tail)
9. HH-4 (grep count + find count)
10. HH-10 (find + comparison)
11. HH-5 (delegated to `tier1-bloat-check.sh`)
12. HH-12 (phase string parse + diff)

### Caching

Same-session cache qua `.harness-health-cache-${SID}` với 5-min TTL. Trên UserPromptSubmit, cache hit né re-run full catalog.

### Aggregation States

- **GREEN** — không FAIL
- **YELLOW** — ít nhất một MEDIUM, không HIGH
- **RED-1** — một HIGH
- **RED-2** — hai+ HIGH

State xuất hiện trong `boot-summary.md` cho next-session bootstrap.

### KI Suppression

Per-signal KI clauses (ví dụ, HH-1 KI-S49b-1 Windows quirk). Suppression nâng severity floor (HIGH→MEDIUM) nhưng KHÔNG silence FAIL emission.

---

## 9.5 — Charter Principle 11 trong Thực Tiễn

Nguyên tắc: *"Harness phải self-verify firing, không self-attest existence."*

### Cách Nó Định Hình Mọi Thứ

| Decision | Without Principle 11 | With Principle 11 |
|---|---|---|
| Hook mới shipped | Smoke test pass → declare done | Smoke test + firing-test + production log evidence → declare done |
| Track close | Tất cả deliverables trong plan present → close | Tất cả deliverables present + empirical-firing evidence captured → close |
| Health audit | Tất cả scripts tồn tại → green | Tất cả scripts emit trong production logs trong thresholds → green |
| Hook deprecation | Hook vẫn trong code → keep | Hook silent cho 3+ sessions catch-rate 0 → demote-to-passive hoặc retire |

### Operational Markers

- **Empirical-firing evidence** = production log entry / artifact / telemetry row từ real session activity.
- **Ritual closure** = file existence + smoke-test exit 0.

Charter Principle 11 cấm declare track closed qua ritual closure alone. Empirical evidence phải được cite.

### Tại Sao Nó Cần Thiết

Phase 2.5 → Phase 3.5 transition surface gap này. Ba failure tất cả looked structurally complete nhưng empirically broken. Nguyên tắc là policy answer; HH-1..HH-12 là mechanical answer.

---

## 9.6 — Severity / Escalation Pipeline (Recap)

Detailed trong [Chương 6 § The Severity Pipeline](06-hooks.md#66--the-severity-pipeline). Recap:

```
DETECTORS → severity-classifier.sh (Phase A) → .severity-state.tsv
            ↓
            escalation-engine.sh (Phase B) → .autonomous-BLOCKED + urgent.md + Telegram
            ↓
            autonomous-block-enforcer.sh (Phase C) → DENY tool calls (RC=2)
            ↓
            telegram-push.sh (Phase D) → external push
```

Pipeline là cách quality system findings trở thành *user-visible actions*.

---

## 9.7 — Quality Reports

`agent-workspace/quality-reports/` có ba subdirectory match ba tier:

| Subdir | Cái gì đi đây | Producers |
|---|---|---|
| `deterministic/` | Tier 1 gate outputs | `drift-signals-D1-D9.sh` rollups, pytest reports |
| `probabilistic/` | Tier 2 gate outputs | `/vbw-check` reports, `/drift-check` semantic outputs |
| `drift-reports/` | Tier-A drift run outputs | `drift-rollup-daily.sh` |

**Current state**: hầu hết các cái này là placeholder directories. Actual gate evidence route vào session logs (Tier-1 deterministic), drift-log rollups (`drift-logs/YYYY-MM-DD-rollup.md`), và VERIFY session logs + observation files (Tier-2 probabilistic). Placeholder subdirectories tồn tại cho future centralization.

---

## 9.8 — Calibration Over Confidence (Recap)

Ý tưởng thứ năm từ [Chương 2 § Idea 5](02-mo-hinh-tu-duy.md#idea-5--calibration-over-confidence).

Nơi calibration data sống:

| Source | Cái gì nó track |
|---|---|
| `agent-workspace/calibration/` | Per-signal hit rate, KOL accuracy |
| `agent-workspace/memory/sync-tracker/state.tsv` | Per-category Confidence Score |
| `agent-workspace/memory/dispatch.jsonl` | Per-agent-dispatch outcome distribution |
| `agent-workspace/memory/mistake-log.md` | Failure catalog với root cause |
| `agent-workspace/memory/agent-notes.md` | Rules earned qua real experience |
| `agent-workspace/memory/attestation-log.tsv` | Sandwich-verifier verdicts |
| `agent-workspace/memory/personal-risk-profile.md` | User's risk tolerance + bias profile |

Per [Boundary B-12](04-hien-phap.md#boundaries): "Không bao giờ claim confidence không có calibration data."

---

## 9.9 — Anti-Patterns Hệ Thống Chất Lượng Thông Dụng

| Anti-pattern | Cái gì sai | Fix |
|---|---|---|
| Ritual closure không có empirical evidence | Principle 11 violation; hệ thống structurally complete nhưng broken | Cite production log evidence trong close attestation |
| Smoke test pass nhưng hook silent trong prod | M-S49b-1 class | HH-1 bắt; firing-test reflect actual spawn topology |
| `Auto-detect: yes` tagged nhưng không hook ship | HH-4 orphan accumulation | Promote-rule cycle bắt; ship hook |
| Tier 1 bloat past 8K | Mỗi session trả overhead | `tier1-bloat-check.sh` (HH-5) enforce; trích sang Tier 2 |
| Verifier giống architect (echo chamber) | Mistake của architect đi unnoticed | Fresh-context verifier (AP-1) |
| Confidence claim không có calibration | B-12 violation | Trace về `calibration/` data với n_samples/hit_rate |
| Hand-curated live-audit counts trong ADR | L-S333-1 attestation discipline | Quote emission của chính hook verbatim |
| Single-shot escalation (một fire, không bao giờ repeat) | L-S312-1 pattern | Per-artifact marker file + re-emit cadence |
| Age-proxy từ immutable timestamp | L-S312-3 pattern | Thêm `last_transition_at` column, không chỉ `detected_ts` |

---

## 9.10 — Đọc Tiếp Ở Đâu

- **Cách drift surface trở thành rules** → [Chương 10 — Tự Cải Thiện](10-tu-cai-thien.md)
- **23 anti-patterns** đầy đủ → [Chương 12 — Nội Tại](12-noi-tai.md#anti-patterns)
- **Chạy drift checks** → [Chương 11 § Audit cho Drift](11-cong-thuc.md#audit-for-drift)
- **Catalog DR + HH đầy đủ** → [Reference § Constitution](../reference/inventory-constitution.md)
