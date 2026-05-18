# Chapter 15 — Glossary

> **Diataxis quadrant**: Reference
> **Reading time**: lookup-only

Every term used throughout this book, defined. Sorted alphabetically. Cross-linked to the chapter or file where the term is detailed.

If a term you are looking for is not here, file a bug per [Chapter 14 § Reporting a Bug](14-contributing.md#147--reporting-a-bug-in-the-harness).

---

## A

**ADR** — Architecture Decision Record. A file at `agent-workspace/memory/decisions/NNN-<slug>.md` recording a decision with 12+ field schema. Sequential numbering, never reused. See [Chapter 7 § 7.7](07-memory-system.md#77--architecture-decision-records-decisions).

**agent** — Either Claude Code (the LLM) acting as engineering team, or a subagent persona dispatched via the `Agent` tool. See [Chapter 5 § 5.4](05-skills-commands-agents.md#54--subagents).

**agent-notes.md** — Memory file recording learned rules earned through real experience. Append-mostly, ≤700 LOC. See [Chapter 7 § 7.5](07-memory-system.md#75--learned-rules-agent-notesmd).

**agent-workspace/** — The agent-owned execution + memory directory. Agent writes freely (within constitution); human reads. See [Chapter 3 § The Two Workspaces](03-architecture.md#the-two-workspaces).

**AP-N** — Anti-pattern N. The 23 named failure modes the harness prevents. See [Chapter 12 § 12.2](12-internals.md#122--the-23-anti-patterns-ap-1ap-23).

**AskUserQuestion** — The tool that displays a UI prompt to the human user with up to 4 multi-option questions. The binding ratification surface for SCOPE/CHARTER decisions. See [Chapter 8 § 8.7](08-lifecycle.md#87--the-qa-bundle-mega-pattern).

**attestation-log.tsv** — Append-only TSV of sandwich-verifier verdicts (PASS / PASS-WITH-CONCERNS / FAIL). See [Chapter 7 § 7.11](07-memory-system.md#711--telemetry-files).

**autonomous_mode** — A flag in `current-execution.md` (`true` or `false`). When `true`, agent operates without per-session human gating. The only mode per `autonomous-protocol.md` Rule 1.

**auto-mv** — The rule (HH-E.2 / D-031) that permits the `qa-pending-auto-mover.sh` Stop hook to move Q&A bundles from `pending/` to `answered/` per 4 conditions. See [Chapter 8 § 8.6](08-lifecycle.md#86--workspace-dualism).

---

## B

**B-N** — Hard boundary N. The 14 actions the agent cannot take without explicit human approval. See [Chapter 4 § boundaries](04-constitution.md#boundaries).

**BC** — Bounded context. One of 9 in the stock domain (BC-1 Market Data through BC-9 Portfolio). See [Chapter 4 § architecture](04-constitution.md#architecture).

**bear case** — Counter-argument to a bullish thesis. Required ≥3 specific points per I-S10 invariant.

**block-control.sh** — CLI subcommand interface for the autonomous-BLOCKED flag (`status`, `raise`, `clear`, `check-prompt`).

**boundary** — A rule the agent cannot cross. Hard (B-N) require explicit approval; soft (SB-N) require documentation in decision log. See [Chapter 4 § boundaries](04-constitution.md#boundaries).

**BP-N** — Best Practice N. Positive pattern confirmed to work; lives in `agent-workspace/memory/self-awareness/best-practices.md`. See [Chapter 10 § 10.10](10-self-improvement.md#1010--best-practices-and-known-issues-catalogs).

**budget cliff** — Token threshold (default 220K) that triggers `session-self-reboot.sh` for fresh-context resume. See [Chapter 4 § session-budgets](04-constitution.md#session-budgets).

---

## C

**calibration** — Tracking the system's own accuracy over time. Per Charter Principle 8: confidence claims must trace to historical hit rate. See [Chapter 2 § Idea 5](02-mental-model.md#idea-5--calibration-over-confidence).

**checkpoint** — Session handoff state file at `agent-workspace/memory/checkpoints/latest.md`. Read by next session's bootstrap. See [Chapter 7 § 7.10](07-memory-system.md#710--checkpoints-checkpoints).

**Claude Code** — The Anthropic CLI tool that runs Claude as an interactive engineering assistant. The harness is built on top of Claude Code.

**CLAUDE.md** — Always-loaded project context file. Multiple exist: project root (always loaded), `agent-workspace/CLAUDE.md` (workspace contract), `human-workspace/CLAUDE.md` (human contract), `obsidian-vault/CLAUDE.md` (vault contract).

**command** — A user-typed slash invocation at `.claude/commands/<name>.md`. See [Chapter 5 § 5.3](05-skills-commands-agents.md#53--commands).

**constitution** — The 17 immutable rule files at `agent-workspace/constitution/`. Modification requires proposal → cool-down → ratification. See [Chapter 4](04-constitution.md).

**cool-down** — Mandatory waiting period before ratifying a proposal. CHARTER 48h, SCOPE 24h, ARCH 12h, IMPL 0h.

**coordination rule** — Explicit file-collision avoidance written to `current-execution.md` when parallel subagent sessions are active.

**cost-ledger.tsv** — Append-only USD cost ledger per session + subagent dispatch. See [Chapter 7 § 7.11](07-memory-system.md#711--telemetry-files).

**current-execution.md** — THE routing source-of-truth memory file. Read first at every SessionStart. See [Chapter 7 § 7.4](07-memory-system.md#74--the-routing-source-of-truth-current-executionmd).

---

## D

**D-NNN** — ADR number NNN. Sequential, never reused.

**DDD** — Domain-Driven Design. The architecture style used in `packages/domain/`.

**defer-cycles** — Field in ADR frontmatter tracking how many times the decision was deferred. >3 triggers R7 drift alert.

**dispatch** — Invoking a subagent via the `Agent` tool. Logged in `dispatch.jsonl`.

**dogfood** — Using one's own product. Per Charter Principle 7: features not used weekly get killed.

**DR-N / DR-A-N / DR-S-N** — Drift signal N. DR-A prefix = Tier-A auto-detected; DR-S prefix = stock-specific. See [Chapter 9 § 9.3](09-quality-system.md#93--drift-signals-dr1-dr12).

**drift** — Decay between intent and reality. Categories: code drift, UL drift, charter drift, harness drift.

---

## E

**echo chamber** — When same-agent self-review rationalizes its own mistakes. Prevented by fresh-context sandwich verifier (AP-1).

**effort** — A `/effort low|medium|high|xhigh|max` mode that adjusts agent reasoning depth. Cited in self-awareness profile cards.

**empirical-firing evidence** — Production log entry / artifact / telemetry row proving a hook actually fired (vs merely existing). Required by Charter Principle 11.

**escalation-engine.sh** — Phase B of the severity pipeline. Multi-cadence (Stop + SessionStart + UserPromptSubmit).

---

## F

**fresh context** — A subagent dispatch where the agent does NOT see the parent session's transcript. The defining property of subagents.

**firing-test** — Companion test at `scripts/hooks/firing-tests/<hook>-fire-test.sh` proving the hook fires correctly. Required by Charter Principle 11.

---

## G

**grilling** — Bundling 15-20 Q&A questions for human ratification. Via `grill-maximization` skill.

---

## H

**handoff** — Session-to-session continuity. Stop-hook driven modes A/B/C/D.

**harness** — The framework documented in this book. Layered: constitution / hooks / skills / commands / subagents / memory / lifecycle / application.

**harness health** — Self-monitoring via HH-1..HH-12 signals. See [Chapter 9 § 9.4](09-quality-system.md#94--harness-health-signals-hh-1hh-12).

**HH-N** — Harness health signal N. 12 catalogued.

**hook** — A shell script at `scripts/hooks/<name>.sh` that fires on a Claude Code lifecycle event. 118 catalogued. See [Chapter 6](06-hooks.md).

**human-workspace/** — The human-owned directory. Agent has narrow write rights. See [Chapter 3 § The Two Workspaces](03-architecture.md#the-two-workspaces).

---

## I

**I-N** — General invariant N (`invariants.md`).

**I-S-N** — Stock-domain invariant N (`invariants-stockforge.md`).

**IMPL-tier** — Lowest decision tier. Confidence threshold 0.50. Self-decide eligible.

**inline accumulation** — Recording rule digests in `agent-notes.md` rather than promoting to skill/hook/constitution. Past 2nd instance = anti-pattern (AP-23).

**intent-classifier** — Subagent that classifies user prompts into intent categories. Returns structured YAML.

**invariant** — A rule that must never break. General (I-N) or stock-specific (I-S-N).

---

## J

**Jaccard similarity** — Set-based similarity metric used by `promote-rule` skill to cluster `agent-notes.md` entries.

**JSONL** — JSON Lines format. Used for `dispatch.jsonl`, `component-telemetry.jsonl`.

---

## K

**Karpathy P1-P4** — The four principles (Think Before Coding / Simplicity First / Surgical Changes / Goal-Driven Execution) adopted from forrestchang/andrej-karpathy-skills. See [Chapter 4 § karpathy-principles](04-constitution.md#karpathy-principles).

**KI-N** — Known Issue N. Quirks the harness tolerates with workaround. Lives in `agent-workspace/memory/self-awareness/known-issues.md`. See [Chapter 10 § 10.10](10-self-improvement.md#1010--best-practices-and-known-issues-catalogs).

**KOL** — Key Opinion Leader. In VN stock context: influence-network channels (YouTube, Facebook, Telegram) whose recommendations measurably move prices.

---

## L

**L-S<N>-<M>** — Lesson learned in session N, sequence M.

**lesson-synthesizer** — Subagent (Stage 2 of self-upgrade loop) that captures missed lessons. Dispatched by `lesson-synthesis-watchdog.sh` ALERT.

**LOC** — Lines of code. Used in ceiling enforcement (D1) and retention caps.

---

## M

**M-S<N>-<M>** — Mistake recorded in session N, sequence M.

**master plan** — Phase-level plan at `agent-workspace/master-plans/`. Authored by `master-planner` subagent.

**MEMORY.md** — User auto-memory index. One-line per memory file. Tier 1 always-loaded.

**memory tier** — Tier 1 (always-loaded, ≤8K), Tier 2 (just-in-time), Tier 3 (explicit-pull). See [Chapter 7 § 7.1](07-memory-system.md#71--the-three-tier-memory-model).

**mistake-log.md** — Memory file recording failures with root cause + prevention. Append-mostly, ≤200 LOC. See [Chapter 7 § 7.6](07-memory-system.md#76--failure-catalog-mistake-logmd).

**Mode A/B/C/D** — Stop-hook handoff modes. See [Chapter 8 § 8.8](08-lifecycle.md#88--continuity-across-clear-and-auto-reboot).

**Mode-E** — Self-pause habit pattern. Forbidden by `autonomous-protocol.md` Rule 10.

**mv** — Move. Used in "auto-mv" rule for Q&A pending → answered, and in plan "mv from pending/ to completed/".

---

## N

**no LLM math** — Charter Principle 9: LLM never generates numbers it computed. All numbers from deterministic code.

---

## O

**observation** — Subagent return artifact at `agent-workspace/memory/observations/<subagent>-S<N>-<TS>.md`. See [Chapter 7 § 7.8](07-memory-system.md#78--subagent-observations-observations).

**Opus / Sonnet / Haiku** — Claude model tiers. Opus most capable; Haiku fastest. Per user directive 2026-05-17 "full opus + follow budget", all 14 subagents use Opus.

**outer loop** — Karpathy autoresearch outer loop: per-phase-boundary review and weight adjustment.

---

## P

**P1-P4** — Karpathy principles (see Karpathy P1-P4).

**PCG-S<N>-<M>** — Promotion Candidate from Generation S<N>, sequence M. Identified by sandwich-verifier or lesson-synthesizer.

**phase** — Long-running organizing unit (months). Tracked in `project.md` Phase Goals Tracker.

**plan** — Session-level execution document. Lives at `agent-workspace/session-plans/{pending,completed}/`. See [Chapter 8 § 8.3](08-lifecycle.md#83--the-plan-lifecycle).

**Principle 11** — Charter principle: "Harness must self-verify firing, not self-attest existence." See [Chapter 2 § Idea 4](02-mental-model.md#idea-4--the-harness-must-self-verify-firing-not-self-attest-existence).

**probabilistic** — Tier 2 quality gate: LLM-mediated check (vs deterministic Tier 1).

**PROPOSED / ACCEPTED / SHIPPED / SUPERSEDED-BY-D-NNN / REJECTED** — ADR status values. See [Chapter 4 § 4.4](04-constitution.md#44--decision-discipline-adrs).

**provenance** — Source citation for every decision. Required by `agent-workspace/CLAUDE.md` Contract Rule 5.

**promote-rule** — Skill that clusters `agent-notes.md` entries and proposes promotions. See [Chapter 10 § 10.3](10-self-improvement.md#103--the-promote-rule-skill).

---

## Q

**Q&A bundle** — Multi-question file at `human-workspace/q-and-a/pending/<id>.md` packaging decisions for human ratification.

---

## R

**ratification** — Explicit human approval that moves a proposal to ACCEPTED status.

**retire (rule)** — Discard a learned rule because it duplicates existing constitution / skill / hook, or is no longer applicable. Documented in `agent-notes.md` with reason.

**RM-N** — Risk Mitigation N. Named risk-mitigation entry in a plan.

---

## S

**S<N>** — Session number N. E.g., S407.

**sandwich pattern** — The 3-session choreography: architect → dev → verifier. See [Chapter 2 § Idea 2](02-mental-model.md#idea-2--the-sandwich-pattern-beats-single-agent-past-200k-tokens).

**SCOPE-tier** — Decision tier. Confidence threshold 0.90. AskUserQuestion if below.

**self-awareness** — Per-model x effort x task_class profile cards at `agent-workspace/memory/self-awareness/`. See [Chapter 7 § 7.13](07-memory-system.md#713--self-awareness-self-awareness).

**SessionStart / SessionEnd / Stop / UserPromptSubmit / PreToolUse / PostToolUse / SubagentStop / PreCompact / Notification** — Claude Code hook events.

**session** — One run of `claude` from open to close. Logged at `agent-workspace/memory/sessions/YYYY-MM-DD-session-N.md`. See [Chapter 8 § 8.1](08-lifecycle.md#81--session-types).

**session_id (SID)** — Unique session identifier. `$CLAUDE_SESSION_ID` env var.

**severity-classifier.sh** — Phase A of the severity pipeline. Stop late-chain hook. See [Chapter 6 § 6.6](06-hooks.md#66--the-severity-pipeline).

**severity tier** — CRITICAL / HIGH / MEDIUM / LOW. See [Chapter 4 § severity-schema](04-constitution.md#severity-schema).

**skill** — Auto-discoverable procedure at `.claude/skills/<name>/SKILL.md`. See [Chapter 5 § 5.2](05-skills-commands-agents.md#52--skills).

**STEP 0 — VBW Live Verification** — Mandatory verification phase in every sandwich plan before any production work.

**STEP 2.X / STEP 2.Y** — Architect-specific verification steps (path verification + operational-track cold-probe).

**subagent** — A fresh-context worker persona at `.claude/agents/<name>.md`. Dispatched via `Agent` tool. See [Chapter 5 § 5.4](05-skills-commands-agents.md#54--subagents).

**sync-pull / sync-grilling / sync-tracker** — Confidence Score machinery. See [Chapter 7 § 7.12](07-memory-system.md#712--sync-tracker-confidence-score).

---

## T

**Telegram push** — Phase D of the severity pipeline. External notification for CRITICAL/HIGH severity. Requires `STOCKFORGE_TELEGRAM_*` env vars.

**Tier 1 / Tier 2 / Tier 3** — Two meanings:
- **Quality gates**: deterministic / probabilistic / human (per CLAUDE.md § Quality Gates)
- **Memory**: always-loaded / JIT / explicit (per memory-tiers.md)

Context distinguishes.

**thesis** — Stock-domain investment analysis. Lives at `agent-workspace/memory/thesis-log/`. Bear case required (I-S10). See [Chapter 11 § Recipe 15](11-cookbook.md#recipe-15--run-a-thesis-session).

**tracking-retention.sh** — Stop hook enforcing retention caps on tracking files.

---

## U

**UL** — Ubiquitous Language. DDD term for the canonical vocabulary per bounded context. See [`agent-workspace/ubiquitous-language/glossary.md`](../../../agent-workspace/ubiquitous-language/glossary.md).

**urgent.md** — File at `human-workspace/notifications/urgent.md` where severity escalations accumulate.

---

## V

**VBW** — Verify-Before-Write protocol. 4 checkpoints (PRE-SPEC / PRE-TEST / MID-IMPLEMENT / PRE-COMMIT). See [Chapter 9 § 9.2](09-quality-system.md#92--vbw-protocol-verify-before-write).

**verdict** — Sandwich-verifier output: PASS / PASS-WITH-CONCERNS / FAIL. Recorded in `attestation-log.tsv`.

**verifier** — `sandwich-verifier` subagent. Fresh-context adversarial reviewer. Lacks Write tool (PCG-S401-4).

**VN** — Vietnam / Vietnamese. The stock market this project targets (HOSE / HNX / UPCoM).

**VN30** — The top 30 VN tickers by liquidity. Primary coverage scope.

---

## W

**wind-down** — Token threshold (default 180K) that triggers auto-prep handoff before cliff.

**workspace dualism** — Split between `agent-workspace/` and `human-workspace/`. See [Chapter 3 § The Two Workspaces](03-architecture.md#the-two-workspaces).

**write-vs-edit-guard.sh** — PreToolUse hook enforcing L-S45-2 (use Edit not Write on append-only memory files).

---

## X / Y / Z

(no entries)

---

## Compound Terms

**"Calibration over confidence"** — Charter Principle 8. Confidence claims must trace to hit rate.

**"Charter drift"** — Decay in adherence to PROJECT_CHARTER.md principles. Caught by `charter-coherence-spot.sh`.

**"CODE-DONE-DATA-PENDING"** — Plan attestation vocabulary per L-S385-2. Use when code substrate ready but data substrate pending.

**"Defense-in-depth"** — Multiple layered guards. Example: 3-prong mass-deletion defense (R1 prevention + R2 detection + R3 recovery).

**"Ghost work"** — Subagent dispatched but no observation written. Caught by `ghost-work-audit.sh`.

**"Mass-deletion defense"** — 3-prong (R1/R2/R3). See [Chapter 6 § 6.8](06-hooks.md#68--the-3-prong-mass-deletion-defense).

**"Mode-D clean handoff"** — Checkpoint mtime ≤60s; no auto-reboot needed; new session reads `checkpoints/latest.md`.

**"Phantom dispatch"** — Multiple concurrent claude.exe instances both dispatching the same task. Prevented by `single-claude-instance-lock.sh`.

**"Ritual demotion"** — Demoting a per-session ritual (audit / scan / refresh) when catch-rate 0 over 3+ sessions. See [Chapter 10 § 10.7](10-self-improvement.md#107--ritual-demotion-s99-rca-layer-5).

**"Ritual closure"** — Declaring a track closed via file existence + smoke-test pass. Forbidden by Charter Principle 11 without empirical-firing evidence.

**"Self-decide vs ask"** — Per-tier confidence threshold decision. See [Chapter 14 § 14.2](14-contributing.md#142--what-to-ask-vs-what-to-decide).

**"Sync-grilling"** — 38-session / 7-day cadence Q&A bundle to surface SCOPE-tier divergence.

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

End of Chapter 15. End of the book proper. Reference inventories follow at [`../reference/`](../reference/).
