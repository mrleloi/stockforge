# Chương 15 — Thuật Ngữ (Glossary)

> **Phân khu Diataxis**: Reference
> **Thời gian đọc**: lookup-only

Mọi term được dùng xuyên suốt sách này, được định nghĩa. Sắp xếp alphabetical. Cross-link tới chapter hoặc file nơi term được chi tiết hóa.

Nếu term bạn đang tìm không ở đây, file một bug theo [Chương 14 § Report Bug](14-dong-gop.md#147--report-bug-trong-harness).

---

## A

**ADR** — Architecture Decision Record. Một file tại `agent-workspace/memory/decisions/NNN-<slug>.md` ghi lại một decision với schema 12+ field. Sequential numbering, không bao giờ reuse. Xem [Chương 7 § 7.7](07-he-thong-bo-nho.md#77--architecture-decision-records-decisions).

**agent** — Hoặc Claude Code (LLM) acting như engineering team, hoặc một subagent persona dispatched qua tool `Agent`. Xem [Chương 5 § 5.4](05-skills-commands-agents.md#54--subagents).

**agent-notes.md** — Memory file ghi lại các rule learned thông qua kinh nghiệm thực. Append-mostly, ≤700 LOC. Xem [Chương 7 § 7.5](07-he-thong-bo-nho.md#75--learned-rules-agent-notesmd).

**agent-workspace/** — Directory execution + memory do agent own. Agent write tự do (trong constitution); human đọc. Xem [Chương 3 § The Two Workspaces](03-kien-truc.md#the-two-workspaces).

**AP-N** — Anti-pattern N. 23 failure mode được đặt tên mà harness ngăn chặn. Xem [Chương 12 § 12.2](12-noi-tai.md#122--23-anti-pattern-ap-1ap-23).

**AskUserQuestion** — Tool hiển thị UI prompt cho human user với tối đa 4 multi-option question. Surface ratification binding cho SCOPE/CHARTER decision. Xem [Chương 8 § 8.7](08-vong-doi.md#87--the-qa-bundle-mega-pattern).

**attestation-log.tsv** — Append-only TSV của verdict sandwich-verifier (PASS / PASS-WITH-CONCERNS / FAIL). Xem [Chương 7 § 7.11](07-he-thong-bo-nho.md#711--telemetry-files).

**autonomous_mode** — Một flag trong `current-execution.md` (`true` hoặc `false`). Khi `true`, agent operate không có per-session human gating. Mode duy nhất theo `autonomous-protocol.md` Rule 1.

**auto-mv** — Rule (HH-E.2 / D-031) cho phép Stop hook `qa-pending-auto-mover.sh` move Q&A bundle từ `pending/` sang `answered/` theo 4 điều kiện. Xem [Chương 8 § 8.6](08-vong-doi.md#86--workspace-dualism).

---

## B

**B-N** — Hard boundary N. 14 action mà agent không thể take mà không có explicit human approval. Xem [Chương 4 § boundaries](04-hien-phap.md#boundaries).

**BC** — Bounded context. Một trong 9 trong stock domain (BC-1 Market Data đến BC-9 Portfolio). Xem [Chương 4 § architecture](04-hien-phap.md#architecture).

**bear case** — Counter-argument cho một bullish thesis. Required ≥3 specific point theo invariant I-S10.

**block-control.sh** — CLI subcommand interface cho flag autonomous-BLOCKED (`status`, `raise`, `clear`, `check-prompt`).

**boundary** — Một rule mà agent không thể cross. Hard (B-N) đòi hỏi explicit approval; soft (SB-N) đòi hỏi documentation trong decision log. Xem [Chương 4 § boundaries](04-hien-phap.md#boundaries).

**BP-N** — Best Practice N. Pattern positive được confirm là work; sống trong `agent-workspace/memory/self-awareness/best-practices.md`. Xem [Chương 10 § 10.10](10-tu-cai-thien.md#1010--best-practices-and-known-issues-catalogs).

**budget cliff** — Token threshold (default 220K) trigger `session-self-reboot.sh` cho fresh-context resume. Xem [Chương 4 § session-budgets](04-hien-phap.md#session-budgets).

---

## C

**calibration** — Track accuracy của hệ thống theo thời gian. Theo Charter Principle 8: confidence claim phải trace tới historical hit rate. Xem [Chương 2 § Idea 5](02-mo-hinh-tu-duy.md#idea-5--calibration-over-confidence).

**checkpoint** — Session handoff state file tại `agent-workspace/memory/checkpoints/latest.md`. Đọc bởi bootstrap của session tiếp theo. Xem [Chương 7 § 7.10](07-he-thong-bo-nho.md#710--checkpoints-checkpoints).

**Claude Code** — Anthropic CLI tool chạy Claude như một interactive engineering assistant. Harness được build trên top of Claude Code.

**CLAUDE.md** — Always-loaded project context file. Multiple exist: project root (always loaded), `agent-workspace/CLAUDE.md` (workspace contract), `human-workspace/CLAUDE.md` (human contract), `obsidian-vault/CLAUDE.md` (vault contract).

**command** — Một user-typed slash invocation tại `.claude/commands/<name>.md`. Xem [Chương 5 § 5.3](05-skills-commands-agents.md#53--commands).

**constitution** — 17 immutable rule file tại `agent-workspace/constitution/`. Modification đòi hỏi proposal → cool-down → ratification. Xem [Chương 4](04-hien-phap.md).

**cool-down** — Mandatory waiting period trước ratify một proposal. CHARTER 48h, SCOPE 24h, ARCH 12h, IMPL 0h.

**coordination rule** — Explicit file-collision avoidance được write vào `current-execution.md` khi parallel subagent session active.

**cost-ledger.tsv** — Append-only USD cost ledger per session + subagent dispatch. Xem [Chương 7 § 7.11](07-he-thong-bo-nho.md#711--telemetry-files).

**current-execution.md** — Memory file routing source-of-truth. Đọc đầu tiên tại mỗi SessionStart. Xem [Chương 7 § 7.4](07-he-thong-bo-nho.md#74--the-routing-source-of-truth-current-executionmd).

---

## D

**D-NNN** — Số ADR NNN. Sequential, không bao giờ reuse.

**DDD** — Domain-Driven Design. Style architecture dùng trong `packages/domain/`.

**defer-cycles** — Field trong ADR frontmatter track bao nhiêu lần decision được defer. >3 trigger R7 drift alert.

**dispatch** — Invoke một subagent qua tool `Agent`. Logged trong `dispatch.jsonl`.

**dogfood** — Dùng product của chính mình. Theo Charter Principle 7: feature không được dùng weekly bị kill.

**DR-N / DR-A-N / DR-S-N** — Drift signal N. Prefix DR-A = Tier-A auto-detected; prefix DR-S = stock-specific. Xem [Chương 9 § 9.3](09-he-thong-chat-luong.md#93--drift-signals-dr1-dr12).

**drift** — Decay giữa intent và reality. Category: code drift, UL drift, charter drift, harness drift.

---

## E

**echo chamber** — Khi same-agent self-review rationalize mistake của chính nó. Prevented bởi fresh-context sandwich verifier (AP-1).

**effort** — Mode `/effort low|medium|high|xhigh|max` điều chỉnh agent reasoning depth. Cited trong self-awareness profile card.

**empirical-firing evidence** — Production log entry / artifact / telemetry row chứng minh một hook thực sự fire (vs chỉ tồn tại). Required bởi Charter Principle 11.

**escalation-engine.sh** — Phase B của severity pipeline. Multi-cadence (Stop + SessionStart + UserPromptSubmit).

---

## F

**fresh context** — Một subagent dispatch nơi agent KHÔNG thấy transcript của parent session. Property defining của subagent.

**firing-test** — Companion test tại `scripts/hooks/firing-tests/<hook>-fire-test.sh` chứng minh hook fire đúng. Required bởi Charter Principle 11.

---

## G

**grilling** — Bundle 15-20 Q&A question cho human ratification. Qua skill `grill-maximization`.

---

## H

**handoff** — Session-to-session continuity. Mode A/B/C/D driven bởi Stop-hook.

**harness** — Framework được document trong sách này. Layered: constitution / hooks / skills / commands / subagents / memory / lifecycle / application.

**harness health** — Self-monitoring qua HH-1..HH-12 signal. Xem [Chương 9 § 9.4](09-he-thong-chat-luong.md#94--harness-health-signals-hh-1hh-12).

**HH-N** — Harness health signal N. 12 catalogued.

**hook** — Một shell script tại `scripts/hooks/<name>.sh` fire trên một Claude Code lifecycle event. 118 catalogued. Xem [Chương 6](06-hooks.md).

**human-workspace/** — Directory do human own. Agent có narrow write right. Xem [Chương 3 § The Two Workspaces](03-kien-truc.md#the-two-workspaces).

---

## I

**I-N** — Invariant general N (`invariants.md`).

**I-S-N** — Invariant stock-domain N (`invariants-stockforge.md`).

**IMPL-tier** — Decision tier thấp nhất. Confidence threshold 0.50. Self-decide eligible.

**inline accumulation** — Recording rule digest trong `agent-notes.md` thay vì promote sang skill/hook/constitution. Past instance thứ 2 = anti-pattern (AP-23).

**intent-classifier** — Subagent classify user prompt vào intent category. Return structured YAML.

**invariant** — Một rule không được break bao giờ. General (I-N) hoặc stock-specific (I-S-N).

---

## J

**Jaccard similarity** — Set-based similarity metric dùng bởi skill `promote-rule` để cluster entry `agent-notes.md`.

**JSONL** — JSON Lines format. Dùng cho `dispatch.jsonl`, `component-telemetry.jsonl`.

---

## K

**Karpathy P1-P4** — Bốn principle (Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution) adopt từ forrestchang/andrej-karpathy-skills. Xem [Chương 4 § karpathy-principles](04-hien-phap.md#karpathy-principles).

**KI-N** — Known Issue N. Quirk mà harness tolerate với workaround. Sống trong `agent-workspace/memory/self-awareness/known-issues.md`. Xem [Chương 10 § 10.10](10-tu-cai-thien.md#1010--best-practices-and-known-issues-catalogs).

**KOL** — Key Opinion Leader. Trong VN stock context: influence-network channel (YouTube, Facebook, Telegram) có recommendation measurably move giá.

---

## L

**L-S<N>-<M>** — Lesson learned trong session N, sequence M.

**lesson-synthesizer** — Subagent (Stage 2 của self-upgrade loop) capture missed lesson. Dispatched bởi ALERT của `lesson-synthesis-watchdog.sh`.

**LOC** — Lines of code. Dùng trong ceiling enforcement (D1) và retention cap.

---

## M

**M-S<N>-<M>** — Mistake recorded trong session N, sequence M.

**master plan** — Phase-level plan tại `agent-workspace/master-plans/`. Authored bởi subagent `master-planner`.

**MEMORY.md** — User auto-memory index. Một dòng per memory file. Tier 1 always-loaded.

**memory tier** — Tier 1 (always-loaded, ≤8K), Tier 2 (just-in-time), Tier 3 (explicit-pull). Xem [Chương 7 § 7.1](07-he-thong-bo-nho.md#71--the-three-tier-memory-model).

**mistake-log.md** — Memory file ghi lại failure với root cause + prevention. Append-mostly, ≤200 LOC. Xem [Chương 7 § 7.6](07-he-thong-bo-nho.md#76--failure-catalog-mistake-logmd).

**Mode A/B/C/D** — Stop-hook handoff mode. Xem [Chương 8 § 8.8](08-vong-doi.md#88--continuity-across-clear-and-auto-reboot).

**Mode-E** — Self-pause habit pattern. Forbidden bởi `autonomous-protocol.md` Rule 10.

**mv** — Move. Dùng trong rule "auto-mv" cho Q&A pending → answered, và trong plan "mv từ pending/ sang completed/".

---

## N

**no LLM math** — Charter Principle 9: LLM không bao giờ generate số mà nó tính. Tất cả số từ deterministic code.

---

## O

**observation** — Subagent return artifact tại `agent-workspace/memory/observations/<subagent>-S<N>-<TS>.md`. Xem [Chương 7 § 7.8](07-he-thong-bo-nho.md#78--subagent-observations-observations).

**Opus / Sonnet / Haiku** — Claude model tier. Opus capable nhất; Haiku nhanh nhất. Theo user directive 2026-05-17 "full opus + follow budget", tất cả 14 subagent dùng Opus.

**outer loop** — Karpathy autoresearch outer loop: per-phase-boundary review và weight adjustment.

---

## P

**P1-P4** — Karpathy principles (xem Karpathy P1-P4).

**PCG-S<N>-<M>** — Promotion Candidate từ Generation S<N>, sequence M. Identified bởi sandwich-verifier hoặc lesson-synthesizer.

**phase** — Long-running organizing unit (months). Tracked trong `project.md` Phase Goals Tracker.

**plan** — Session-level execution document. Sống tại `agent-workspace/session-plans/{pending,completed}/`. Xem [Chương 8 § 8.3](08-vong-doi.md#83--the-plan-lifecycle).

**Principle 11** — Charter principle: "Harness phải self-verify firing, không phải self-attest existence." Xem [Chương 2 § Idea 4](02-mo-hinh-tu-duy.md#idea-4--the-harness-must-self-verify-firing-not-self-attest-existence).

**probabilistic** — Tier 2 quality gate: LLM-mediated check (vs deterministic Tier 1).

**PROPOSED / ACCEPTED / SHIPPED / SUPERSEDED-BY-D-NNN / REJECTED** — ADR status value. Xem [Chương 4 § 4.4](04-hien-phap.md#44--decision-discipline-adrs).

**provenance** — Source citation cho mỗi decision. Required bởi `agent-workspace/CLAUDE.md` Contract Rule 5.

**promote-rule** — Skill cluster entry `agent-notes.md` và propose promotion. Xem [Chương 10 § 10.3](10-tu-cai-thien.md#103--skill-promote-rule).

---

## Q

**Q&A bundle** — Multi-question file tại `human-workspace/q-and-a/pending/<id>.md` package decision cho human ratification.

---

## R

**ratification** — Explicit human approval move một proposal sang status ACCEPTED.

**retire (rule)** — Discard một learned rule vì nó duplicate constitution / skill / hook đã có, hoặc không còn applicable. Documented trong `agent-notes.md` với reason.

**RM-N** — Risk Mitigation N. Named risk-mitigation entry trong một plan.

---

## S

**S<N>** — Session number N. Ví dụ: S407.

**sandwich pattern** — Choreography 3-session: architect → dev → verifier. Xem [Chương 2 § Idea 2](02-mo-hinh-tu-duy.md#idea-2--the-sandwich-pattern-beats-single-agent-past-200k-tokens).

**SCOPE-tier** — Decision tier. Confidence threshold 0.90. AskUserQuestion nếu dưới.

**self-awareness** — Profile card per-model x effort x task_class tại `agent-workspace/memory/self-awareness/`. Xem [Chương 7 § 7.13](07-he-thong-bo-nho.md#713--self-awareness-self-awareness).

**SessionStart / SessionEnd / Stop / UserPromptSubmit / PreToolUse / PostToolUse / SubagentStop / PreCompact / Notification** — Claude Code hook event.

**session** — Một run của `claude` từ open đến close. Logged tại `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`. Xem [Chương 8 § 8.1](08-vong-doi.md#81--session-types).

**session_id (SID)** — Unique session identifier. Env var `$CLAUDE_SESSION_ID`.

**severity-classifier.sh** — Phase A của severity pipeline. Stop late-chain hook. Xem [Chương 6 § 6.6](06-hooks.md#66--the-severity-pipeline).

**severity tier** — CRITICAL / HIGH / MEDIUM / LOW. Xem [Chương 4 § severity-schema](04-hien-phap.md#severity-schema).

**skill** — Auto-discoverable procedure tại `.claude/skills/<name>/SKILL.md`. Xem [Chương 5 § 5.2](05-skills-commands-agents.md#52--skills).

**STEP 0 — VBW Live Verification** — Mandatory verification phase trong mỗi sandwich plan trước bất kỳ production work nào.

**STEP 2.X / STEP 2.Y** — Verification step architect-specific (path verification + operational-track cold-probe).

**subagent** — Một fresh-context worker persona tại `.claude/agents/<name>.md`. Dispatched qua tool `Agent`. Xem [Chương 5 § 5.4](05-skills-commands-agents.md#54--subagents).

**sync-pull / sync-grilling / sync-tracker** — Machinery Confidence Score. Xem [Chương 7 § 7.12](07-he-thong-bo-nho.md#712--sync-tracker-confidence-score).

---

## T

**Telegram push** — Phase D của severity pipeline. External notification cho severity CRITICAL/HIGH. Đòi hỏi env var `STOCKFORGE_TELEGRAM_*`.

**Tier 1 / Tier 2 / Tier 3** — Hai meaning:
- **Quality gates**: deterministic / probabilistic / human (theo CLAUDE.md § Quality Gates)
- **Memory**: always-loaded / JIT / explicit (theo memory-tiers.md)

Context phân biệt.

**thesis** — Stock-domain investment analysis. Sống tại `agent-workspace/memory/thesis-log/`. Bear case required (I-S10). Xem [Chương 11 § Recipe 15](11-cong-thuc.md#recipe-15--run-a-thesis-session).

**tracking-retention.sh** — Stop hook enforce retention cap trên tracking file.

---

## U

**UL** — Ubiquitous Language. Term DDD cho canonical vocabulary per bounded context. Xem [`agent-workspace/ubiquitous-language/glossary.md`](../../../agent-workspace/ubiquitous-language/glossary.md).

**urgent.md** — File tại `human-workspace/notifications/urgent.md` nơi severity escalation tích lũy.

---

## V

**VBW** — Verify-Before-Write protocol. 4 checkpoint (PRE-SPEC / PRE-TEST / MID-IMPLEMENT / PRE-COMMIT). Xem [Chương 9 § 9.2](09-he-thong-chat-luong.md#92--vbw-protocol-verify-before-write).

**verdict** — Sandwich-verifier output: PASS / PASS-WITH-CONCERNS / FAIL. Recorded trong `attestation-log.tsv`.

**verifier** — Subagent `sandwich-verifier`. Fresh-context adversarial reviewer. Lack Write tool (PCG-S401-4).

**VN** — Vietnam / Vietnamese. Stock market mà project này target (HOSE / HNX / UPCoM).

**VN30** — Top 30 VN ticker theo liquidity. Primary coverage scope.

---

## W

**wind-down** — Token threshold (default 180K) trigger auto-prep handoff trước cliff.

**workspace dualism** — Split giữa `agent-workspace/` và `human-workspace/`. Xem [Chương 3 § The Two Workspaces](03-kien-truc.md#the-two-workspaces).

**write-vs-edit-guard.sh** — PreToolUse hook enforce L-S45-2 (dùng Edit không phải Write trên append-only memory file).

---

## X / Y / Z

(không entry)

---

## Compound Terms

**"Calibration over confidence"** — Charter Principle 8. Confidence claim phải trace tới hit rate.

**"Charter drift"** — Decay trong adherence tới principle PROJECT_CHARTER.md. Caught bởi `charter-coherence-spot.sh`.

**"CODE-DONE-DATA-PENDING"** — Plan attestation vocabulary theo L-S385-2. Dùng khi code substrate sẵn sàng nhưng data substrate pending.

**"Defense-in-depth"** — Multiple layered guard. Ví dụ: 3-prong mass-deletion defense (R1 prevention + R2 detection + R3 recovery).

**"Ghost work"** — Subagent dispatched nhưng không observation được write. Caught bởi `ghost-work-audit.sh`.

**"Mass-deletion defense"** — 3-prong (R1/R2/R3). Xem [Chương 6 § 6.8](06-hooks.md#68--the-3-prong-mass-deletion-defense).

**"Mode-D clean handoff"** — Checkpoint mtime ≤60s; không cần auto-reboot; session mới đọc `checkpoints/latest.md`.

**"Phantom dispatch"** — Multiple concurrent claude.exe instance đều dispatch cùng task. Prevented bởi `single-claude-instance-lock.sh`.

**"Ritual demotion"** — Demote một per-session ritual (audit / scan / refresh) khi catch-rate 0 qua 3+ session. Xem [Chương 10 § 10.7](10-tu-cai-thien.md#107--ritual-demotion-s99-rca-layer-5).

**"Ritual closure"** — Declare một track closed qua file existence + smoke-test pass. Forbidden bởi Charter Principle 11 không có empirical-firing evidence.

**"Self-decide vs ask"** — Per-tier confidence threshold decision. Xem [Chương 14 § 14.2](14-dong-gop.md#142--what-to-ask-vs-what-to-decide).

**"Sync-grilling"** — Cadence 38-session / 7-day Q&A bundle để surface SCOPE-tier divergence.

---

## Acronyms Quick Reference

| Acronym | Expansion |
|---|---|
| ADR | Architecture Decision Record |
| AP | Anti-Pattern |
| BC | Bounded Context |
| BP | Best Practice |
| DDD | Domain-Driven Design |
| DR | Drift Signal |
| HH | Harness Health |
| I | Invariant (general) |
| I-S | Invariant (stock-specific) |
| JSONL | JSON Lines |
| KI | Known Issue |
| KOL | Key Opinion Leader |
| L | Lesson |
| LOC | Lines of Code |
| M | Mistake |
| OSS | Open Source Software |
| PCG | Promotion Candidate Generation |
| RM | Risk Mitigation |
| SDD | Spec-Driven Development |
| SID | Session ID |
| SRE | Site Reliability Engineering |
| TSV | Tab-Separated Values |
| UL | Ubiquitous Language |
| VBW | Verify-Before-Write |
| VN | Vietnam(ese) |

---

Hết Chương 15. Hết sách chính. Reference inventory theo sau tại [`../reference/`](../reference/).
