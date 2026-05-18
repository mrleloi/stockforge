# Chapter 12 — Internals

> **Diataxis quadrant**: Explanation (the *why* behind the *what*)
> **Reading time**: ~30 minutes
> **Prerequisites**: Chapters 6-10

This chapter covers the internals — design decisions, why the system is shaped the way it is, the 23 named anti-patterns, what was tried and abandoned. Reading this chapter is optional for *using* the harness; required for *contributing* to it.

---

## 12.1 — Why So Many Hooks?

A common first reaction: 118 hook scripts seems excessive.

The answer is empirical. Each hook traces to a specific failure mode that was caught (or that should have been caught). The harness did not start with 118 hooks — it accumulated them over ~400 sessions of dogfood.

The progression:

| Period | Approximate hook count | Why hooks were added |
|---|---|---|
| Phase 0 (session 1-22) | ~20 | Bootstrap, session lifecycle, basic governance |
| Phase 1 (session 23-30) | ~30 | First product, basic drift detection |
| Phase 2 (session 31-43) | ~50 | Multi-tier quality gates emerged |
| Phase 2.5 (session 44-49) | ~70 | Harness hardening; 8 HH-* tracks |
| Phase 3 (session 44-65) | ~80 | Memory tier discipline; retention |
| Phase 3.5 (session 50-250) | ~100 | Empirical-firing discipline; HH-1..HH-12 |
| Phase 4 (session 251-400+) | ~118 | Severity pipeline; mass-deletion defense; calibration |

Each major Phase introduced new failure modes that required new mechanical enforcement. The pattern: **a rule learned in `agent-notes.md` becomes a hook only after a second instance**, per the [AP-23 doctrine](#ap-23).

If we deleted hooks at random, the system would not get simpler — it would get more dangerous. The harness is at a Pareto front: each hook earns its keep.

That said, some hooks are demotion candidates. Per [Chapter 10 § 10.7 Ritual Demotion](10-self-improvement.md#107--ritual-demotion-s99-rca-layer-5), hooks with catch-rate 0 over 3+ consecutive sessions are evaluated for demotion-to-passive or retire. This is an active discipline, not a frozen state.

---

## 12.2 — The 23 Anti-Patterns (AP-1..AP-23)

Anti-patterns are named failure modes that the harness specifically prevents. They are documented in `agent-workspace/memory/patterns-discovered/SYNTHESIS.md` and cited throughout this book.

### High-Frequency Anti-Patterns

| ID | Name | What it is | Prevention |
|---|---|---|---|
| **AP-1** | Same-agent self-review | Architect/dev/verifier as single agent | Fresh-context sandwich pattern |
| **AP-2** | Self-track wind-down | LLM cites tokens; `.transcript-tokens` is authoritative | `budget-watchdog.sh` Mode-C guard |
| **AP-3** | Speculative abstraction | Factor out Protocol for single-use code | Karpathy P2; retire reflexively |
| **AP-5** | Charter-coherence defer overriding user-CRITICAL | Silently deferring user-CRITICAL items | Re-read `user_prompt/*` at every phase entry |
| **AP-6** | LLM math output | LLM generates number it computed | DR-S1 + `taskcompleted-audit.sh` |
| **AP-7** | Performative SC ticking | Vacuous "approve" attestations | Defer with explicit prereqs > vacuous approve |
| **AP-8** | Pre-staged work causing checkpoint drift | Updating files at session-end, not on task complete | Update on task complete |
| **AP-9** | Single-perspective thesis | Thesis without bear case | I-S10 + DR-S2 + `taskcompleted-audit.sh` |
| **AP-10** | Confidence without calibration | "High confidence" without hit-rate evidence | B-12 + DR-A4 |
| **AP-11** | Confirmation bias in stock picks | Recommending stocks user already owns | Portfolio check before recommendation |
| **AP-12** | Overfit to recent backtest | 2021-2022 performance ≠ 2024 prediction | Cross-period validation required |
| **AP-13** | Greedy auto-load | Loading 50K+ files at SessionStart | Hybrid auto-load + LLM-selector (per Rule 3) |
| **AP-14** | Hardcoded phase paths in skills | Skill cites `phase-3` literal | Resolve via `current-execution.md` |
| **AP-15** | Duplicated skill body in command | `<name>` skill + `/<name>` command both contain procedure | L-S14-2; pick one canonical |
| **AP-16** | Inline accumulation past 2nd instance | Not promoting rule on 2nd appearance | AP-23 RED FLAG; promote-or-retire |
| **AP-17** | Identity drift | Treating stockforge as generic framework | Reference `identity-scope.md` |
| **AP-18** | Stop-hook-Windows quirk hides everything | Stop never fires; all 50 Stop-chain hooks silent | T2 migration to UserPromptSubmit; HH-1 KI-S49b-1 |
| **AP-19** | Hook ships without firing-test | Track close declared GREEN; hook not verified | HH-10 + Charter Principle 11 |
| **AP-20** | Auto-detect tag without companion hook | 20 `Auto-detect: yes` rules; 0 hooks shipped | HH-4 orphan check |
| **AP-21** | Mixed PLAN + IMPL session | Session 4 catastrophic failure | Hard rule; sandwich pattern enforces |
| **AP-22** | Q&A bundle silent past 24h | "Wait for user-readiness" busy-loop | UP-06 NO-Silent-Default + `qa-stale-urgent-escalator.sh` |
| **AP-23** | Continuous LLM-Guardian / inline accumulation past 2nd instance | LLM checks at every step instead of deterministic hook | Deterministic hooks = Guardian; LLM Guardian only at session-end aggregation |

### Lower-Frequency Anti-Patterns

(AP-4 was reserved; documented as duplicate of AP-3 and dropped.)

### The AP-23 Pattern (Most Cited)

AP-23 deserves its own subsection because it is referenced more than any other anti-pattern. It says:

> "If a rule has been observed N+1 times (where N ≥ 2), and we are about to add a refinement-of-rule entry rather than promote to a deterministic hook, that is AP-23. The rule has graduated past inline accumulation. Either promote (to hook / skill / constitution) or retire (if duplicate of existing artifact)."

The 2nd-instance threshold is the bright line. Below it, rules can stay inline (might be one-off). At or above it, accumulation past inline is anti-pattern.

The **cluster exception**: when 3+ rules share a class (same root cause, same prevention), promote the whole cluster as a single artifact even if individual instances are 1st-instance.

---

## 12.3 — Why Sandwich (Not Single-Agent-With-Discipline)

A reasonable counter-proposal: "Why not a single agent that just disciplines itself to plan first, implement second, verify third?"

**Empirical answer**: it does not work past ~200K tokens. Session 4 measured this directly:

- Single agent attempted PLAN + IMPL + VERIFY in one session
- Crossed 200K tokens
- Plan drifted from implementation (LLM started "improving" plan mid-stream)
- Implementation drifted from spec (LLM forgot edge cases stated in earlier turns)
- Verifier (same agent, same context) signed off on broken work

The failure rate at that scale was ~20%. Not "occasional bugs" — *catastrophic* loss requiring full rollback.

**Mechanistic answer**: context window is not the bottleneck. *Attention* is. LLMs attend disproportionately to recent context. Past 200K, early-context details (the spec, the plan) get out-attended by recent-context details (the implementation in progress). This is not solved by a longer context window; it is solved by *bounding* the context to the work the session owns.

**The sandwich pattern's structural answer**:

- Architect's context: spec + constitution + similar past plans. Plan written.
- Dev's context: plan + code-to-touch. Implementation written.
- Verifier's context: plan + implementation diff. Verdict written.

Each agent's attention is concentrated on its own scope. **No agent has to attend to both plan and implementation simultaneously**. The drift mode is structurally impossible.

### Why Fresh Context Specifically

Could one agent run sequentially (plan, then implement, then verify) with `/clear` between phases?

Two issues:
1. **Persona conflict**: architect mindset ≠ dev mindset ≠ verifier mindset. Reading the persona file at each phase entry is wasteful; better to have three distinct persona files.
2. **Echo chamber**: even with `/clear`, a single agent who *recently* wrote the plan brings stylistic and assumption-level priors into verification. A fresh-context verifier has none of those priors.

The fresh-context verifier is the *adversarial* layer. AP-1 forbids same-agent self-review.

---

## 12.4 — Why the Severity Pipeline (Not Just `urgent.md`)

Before D-058 / S310, the harness had a `notifications/urgent.md` file that accumulated WARNs. The issue: nothing read it. Items piled up; the user did not see them.

The severity pipeline addresses this by:

1. **Classifying** items into 4 tiers (CRITICAL / HIGH / MEDIUM / LOW) so attention is proportional.
2. **Escalating** based on tier:
   - CRITICAL → block autonomous + Telegram push
   - HIGH → demand AskUserQuestion + Telegram push
   - MEDIUM → weekly digest
   - LOW → log only
3. **Enforcing** the block via PreToolUse hook (tool calls denied while flag set).
4. **Pushing** externally (Telegram) so user sees CRITICAL/HIGH outside the terminal.

The cascading design ensures that the *most important* items get the *most aggressive* surfacing, and the *trivial* items do not spam.

### Why Multi-Cadence Phase B

`escalation-engine.sh` fires on Stop + SessionStart + UserPromptSubmit. Three different windows. This is intentional:

- **Stop**: end of every turn — frequent re-check.
- **SessionStart**: new session entry — guarantees user sees state on resume.
- **UserPromptSubmit**: every prompt — gives the LLM context to respond appropriately.

Single-cadence (Stop only) was the original design. The S310 root cause was that single-cadence allowed Q-INT mega-bundle to sit silent for 20 hours: Stop fired but the user did not return for 20 hours. SessionStart re-fire ensures resumption surfaces the state.

---

## 12.5 — Why Two Workspaces (`agent-workspace/` + `human-workspace/`)

The workspace dualism was born from the **orch CF-DOGFOOD-2 post-mortem** (orch is a sister project at `C:\htdocs\orch-starter`).

### What Happened in Orch

Orch had a single shared workspace. Agent could write anywhere. Over time:

- Agent silently changed charter rules to fit its current understanding
- Human's intent (`user_prompt`) and agent's interpretation drifted
- Decisions ratified by agent inline became indistinguishable from decisions ratified by human
- Audit trail of who-said-what became impossible

The failure mode is named **CF-DOGFOOD-2**: charter drift via shared-workspace mutation.

### The Dualism Answer

Split the workspace:

- **Agent's domain**: `agent-workspace/`. Agent writes freely; human reads but rarely edits.
- **Human's domain**: `human-workspace/`. Human writes; agent has narrow write rights to specific channels.

The split is enforced by `.claude/settings.json` deny rules. Direct write to `human-workspace/user_prompt/` is denied; the agent cannot silently modify human's original intent.

### The Communication Channels

Cross-boundary communication happens through named channels (per [Chapter 8 § 8.6](08-lifecycle.md#86--workspace-dualism)):

- Human → Agent: `user_prompt/`, `decisions/` (agent reads only)
- Agent → Human: `q-and-a/pending/`, `notifications/urgent.md` (agent writes)
- Auto-mv: pending → answered via hook (`qa-pending-auto-mover.sh`) with explicit conditions

The auto-mv rule (4 conditions; HH-E.2 / D-031) is the most subtle. It allows the agent to MOVE Q&A bundles to `answered/` without breaking the human-only-writes-to-answered rule, because the move is performed by a validated hook with deterministic conditions, not by the agent directly.

---

## 12.6 — Why Constitution Files Are Immutable to Agent

Reasonable counter-proposal: "Why not let the agent edit constitution files? It is the agent's job to learn and adapt."

**Answer**: agent learning happens in `agent-notes.md`. *Promotion* of a learned rule to the constitution requires an explicit human-ratified step.

Without this gate:

- Agent could silently rewrite Charter Principle 8 ("Calibration over confidence") to "Calibration when convenient"
- Agent could silently extend `boundaries.md` to relax B-11 (position sizing override)
- Agent could silently delete an invariant under pressure to ship

**The constitution is the *contract*** between the human and the system. Contracts are not unilaterally modifiable.

The amendment process (proposal → 48h cool-down → ratification → mv) is deliberately slow. Slowness is the feature, not the bug.

---

## 12.7 — Why Hooks Use Bash (Not Python / TypeScript)

Several hooks shell out to Python (`python3` is a fallback for `date -d` math). Why not Python primary?

**Answer**: portability + speed + dependency simplicity.

- **Portability**: bash + POSIX coreutils exists on every dev machine + CI runner. Python availability varies (especially `python3` vs `python`).
- **Speed**: hook execution is in the hot path of every event. Python startup (~50-200ms) compounds across 118 hooks. Bash is ~5-20ms.
- **Dependency simplicity**: bash has zero install. Python requires version pinning + virtualenv discipline.

**The exception**: `recover-agent-notes.py`, `sync-tracker-bootstrap.py`. These are one-shot CLI utilities, not hot-path hooks. Python is appropriate.

**The constraint**: per L-S11-1 (Phase 0 portability), hook scripts may not depend on `jq`, `yq`, or Python (except as fallback). All structured-data parsing in hooks uses `awk`, `grep`, `sed`. This caps complexity but ensures portability.

### Windows Portability Scars

The bash-only constraint plus Windows compatibility creates a substantial surface area documented in [Chapter 6 § 6.10](06-hooks.md#610--windows-portability-scars). Examples:

- `$PPID == 1` in spawned hook contexts (use `tasklist //V` not `ps`)
- `VAR=val bash ...` fails silently (must use `env VAR=val bash ...`)
- PowerShell `Start-Process` truncates SessionStart chain (move spawning hooks to last position)
- KI-S49b-1 Stop-not-firing quirk (HH-1 KI suppression)

If we were Linux-only, the harness would be ~20% smaller.

---

## 12.8 — Why 12-Field ADR Schema (Not 4)

The minimal ADR pattern (per Michael Nygard's original 2011 article) has 4 fields: Title, Status, Context, Decision. Why does the harness require 12+?

**Answer**: the 4-field schema is for *recording* decisions. The harness needs to *operate* on decisions. That requires more structure.

Fields the harness consumes:

- `id` — for cross-reference and stable URLs
- `level` (CHARTER / SCOPE / ARCH / IMPL) — for tier-appropriate confidence threshold
- `source_evidence` — for audit trail
- `intent_classification` — for routing
- `options_considered` — for retrospective ("why not B?")
- `chosen` + `chosen_rationale` — for understanding
- `approval_chain` — for ratification provenance
- `verified_by` — for closure proof (Principle 11)
- `affects` — for impact tracking
- `depends_on` — for ordering
- `supersedes` / `superseded_by` — for revision graph
- `defer_cycles` — for R7 drift alert
- `re_attempt_prereq` — for resurrection logic
- `tags` — for grep

Removing any field would cripple a specific hook or skill. The schema is dense because it serves multiple consumers.

---

## 12.9 — What Was Tried and Abandoned

Not every harness experiment shipped. Some retired examples:

### Mode-E Self-Pause

**What it was**: agent paused itself in autonomous mode when feeling "unsure".

**Why it failed**: agent's unsure-detection was unreliable (correlated with rare phrasing more than actual uncertainty). Created a habit pattern of pausing that destroyed autonomous-loop reliability.

**Retired**: 2026-05-04 (S43) via Tier-3 charter promotion. `autonomous-protocol.md` Rule 10 codified "Autonomous-Mode Defection Forbidden" 4-layer defense.

### Mode-D SendKeys "continue" Mechanism

**What it was**: PowerShell SendKeys to inject "continue" into the next session after `/clear`.

**Why it failed**: brittle on Windows, raced with hook execution, occasionally missed.

**Retired**: 2026-05-XX. Replaced by the 3-hook checkpoint marker mechanism ([Chapter 8 § 8.8](08-lifecycle.md#88--continuity-across-clear-and-auto-reboot)).

### Greedy Auto-Loader (50K+ Files at SessionStart)

**What it was**: SessionStart hook attempted to pre-load all conceivably relevant files.

**Why it failed**: blew bootstrap ceiling; degraded every session.

**Retired**: Rule 4 of `autonomous-protocol.md` codified per-session-type ceilings (≤6K-≤20K). Auto-loader replaced by hybrid (deterministic + LLM-selector).

### `ccs:continue` and Other CCS-Level Commands

**What they were**: commands that lived at the CCS (Claude Code Subagent) plugin level, not the project level.

**Why they were not adopted**: they conflict with the project's own commands and the visibility-into-state property.

**Status**: not part of the harness; ignored.

### Single-Cadence Severity (Stop only)

**What it was**: original D-058 design fired `escalation-engine.sh` only on Stop.

**Why it failed**: did not surface state on session resume; 20-hour Q-INT silent period was the root cause of L-S310-1 demotion.

**Retired**: superseded by multi-cadence design (Stop + SessionStart + UserPromptSubmit).

---

## 12.10 — Comparison to Other Patterns

How does this harness compare to other AI-coding patterns in the field?

### vs Cursor / Aider / etc.

Those tools optimize the *editor* experience — they assume the human is in the loop reviewing every change. The harness optimizes for **autonomous** operation: human reviews at session/phase boundaries, not at every line.

### vs Agent Frameworks (AutoGPT, AgentGPT, etc.)

Those frameworks emphasize **agent autonomy** with weak external structure. The harness emphasizes **agent autonomy within strong external structure**. The 17 constitution files + 118 hooks are the "external structure" — they constrain the agent's freedom to reduce variance.

### vs Sandwich-Free LangChain / LangGraph

LangGraph supports multi-agent workflows similar to sandwich. The harness adds:
- **Persona files** (`.claude/agents/<name>.md`) as canonical worker definitions
- **Fresh-context guarantee** via Agent tool dispatch
- **Verifier no-Write** enforcement (PCG-S401-4)
- **Coordination rules** via `current-execution.md`

### vs Test-Driven Development (TDD)

TDD is a discipline; the harness is a system that *enforces* discipline. The relationship:

- TDD says "write tests first". The harness's `pre-commit-pytest-regression-guard.sh` enforces "tests pass before commit".
- TDD says "red, green, refactor". The harness's sandwich pattern (architect plans, dev implements, verifier refactors via Tier-2 review) is the multi-session analog.

### vs SRE / DevOps Discipline

The harness borrows heavily from SRE patterns:

- **Severity tiers** (CRITICAL / HIGH / MEDIUM / LOW) ← SRE incident severity
- **Defense-in-depth** (3-prong mass-deletion defense) ← SRE redundant safety nets
- **Postmortems** ← SRE blameless postmortems
- **Calibration** (sync-tracker confidence scores) ← SRE error budgets

---

## 12.11 — The Failure Modes the Harness Cannot Catch

Honesty matters here. The harness catches a lot. It does not catch:

### LLM Reasoning Failures Within a Single Tool Call

If the LLM writes a function that compiles and passes tests but implements the wrong algorithm, the harness sees a green commit. Defense: sandwich-verifier reviews diff for logical correctness; not perfect.

### Long-Horizon Strategic Drift

If the project's *direction* is wrong (e.g., building a VN stock tool when the market structure changes), no hook will catch it. Defense: PROJECT_CHARTER.md sets direction; AskUserQuestion CHARTER-tier ratification when scope shifts.

### Adversarial External Changes

If `vnstock` library changes its API silently, code breaks at runtime. Defense: `vendor-api-probe.sh` checks API reachability; not full API contract testing.

### Human Mistakes the Agent Cannot Reach

If the human commits `agent-workspace/constitution/karpathy-principles.md` with an error, the agent reads the error. Defense: charter revision protocol requires explicit version bump + rationale.

### Cost Surprises

If a sandwich-architect on Opus consumes 300K tokens unexpectedly, `cost-ledger.tsv` records the cost but does not prevent it. Defense: `budget-watchdog.sh` warns at 180K wind-down + 220K cliff; subagent budget classifier flags Architect/Verifier envelope.

### Cascading Test Removal

If a test gets deleted (not just disabled), `pre-commit-pytest-regression-guard.sh` sees fewer tests pass but does not flag the deletion. Defense: `loc-ceiling-check.sh` catches sudden file size changes; not perfect.

These known gaps are documented in `agent-workspace/memory/.harness-gaps.md` (informal log) and surfaced via [Chapter 14 § Contributing](14-contributing.md) for community input.

---

## 12.12 — Where to Read Next

- **Recipes for common tasks** → [Chapter 11 — Cookbook](11-cookbook.md)
- **Full artifact inventory** → [Chapter 13 — Reference](13-reference.md)
- **Extending the harness** → [Chapter 14 — Contributing](14-contributing.md)
- **Glossary of terms** → [Chapter 15 — Glossary](15-glossary.md)
