# Pattern Mining — ms-mdp-admin phase2_workflow
**Date**: 2026-04-29
**Source**: `C:\htdocs\labci\ms-mdp-admin_refactor\tasks\refactor_phase2\phase2_workflow\`
**Files deep-read** (11):
- `00-index.md`
- `04-spec-driven-development.md`
- `05-agentic-sdlc.md`
- `06-context-gates.md` (partial)
- `14-self-evaluation-framework.md`
- `18-ai-agent-self-governance.md`
- `19-multi-agent-orchestration.md`
- `20-multi-agent-communication.md`
- `22-spec-integrity-agent-operations.md`
- `25-token-context-optimization.md`
- `26-multi-agent-sandwich-workflow.md`
- `38-token-context-efficiency-combined.md`

**Files skimmed** (15+): 16, 17, 21, 23, 27, 28, 29, 31, 33, 34, 35, 37, 25-advanced (alt 25), and selective passes through 01-13, 24, 30, 32, 36 (titles/index only).

---

## Executive Summary

1. **The ms-mdp project distilled an "Agentic SDLC" framework from 51+ real refactor sessions** with measured failure data (Session 4 failed; 2/5 tasks reverted in S45). Their patterns are battle-tested, not aspirational. **Stockforge gets to inherit this for free** — most are stack-agnostic.

2. **Sandwich Workflow is the highest-leverage finding**: Architect (Claude Code) plans → Dev (Antigravity/Sonnet) implements → Verifier (Claude Code) cross-references diff vs spec. Failure rate dropped from 20% (single-agent) to ~6% (sandwich). **This maps exactly to stockforge's PLAN / IMPL / VERIFY session types in CLAUDE.md** but ms-mdp adds concrete handoff file formats.

3. **Verify-Before-Write (VBW) protocol** is documented with hard data: 11.1% hallucination rate measured in a real session, with 4 named anti-patterns (writing from memory, batching with same unverified pattern, etc.). **Stockforge has a VBW skill already** — ms-mdp's checkpoint structure (Pre-Spec / Pre-Test / Mid-Implement / Post-Implement) is more granular than what's in our agent-workspace/constitution.

4. **Guardian Agent + Decision Provenance Chain** is novel vs orch: a continuous-running agent that cross-validates spec ↔ code ↔ tests ↔ Jira/discussion threads, borrowed from safety-critical industries (IEC 62304, ASPICE, DO-178C). For finance — where stockforge claims need source + as-of dates — this is **directly applicable to our Self-Awareness Agent track**.

5. **Token-context strategy is empirical**: $0.15/M-token math, Lost-in-the-Middle citation (Liu 2023), 11.1% hallucination measurement, 87% token-savings claim per PBI when using spec-as-context. **Confirms stockforge's UP02 §1.5 reboot-cost concern is universal** — ms-mdp solved it via Sandwich + .context/agent-mailbox + GitNexus precomputed code intelligence.

6. **Multi-agent communication via local mailbox files** (`.context/agent-mailbox/inbox.md`, `outbox.md`, `shared-state.md`, `budget.md`) instead of going through a shared cloud — claims ~80% token savings vs all-via-Jira. **Direct port for stockforge's hook ports / observation files track.**

7. **Identity + Budget controls per agent** — each agent has emoji + role prefix (🔍 BA, ⚙️ Dev, 🧪 QA, 🛡️ Guardian) and explicit budget caps (BA: 3 Jira comments, 1 Confluence page, 5 local msgs per interaction). Guardian halts everyone if budget breached. **Useful for stockforge's grill-maximization track if we go multi-agent.**

8. **Spec dual-layer (Blueprint + Contract)** mirrors stockforge's existing dual-layer skill — Blueprint = architecture/anti-patterns; Contract = DoD + Regression Guardrails + Gherkin scenarios. Confirms stockforge's spec-dual-layer skill is on the right track; their PBI format (Directive + Context Pointer + Verification Pointer + Refinement Rule) is a useful refinement.

9. **Same-Commit Rule** for spec ↔ code: every behavior-changing commit MUST include the matching spec update, or the commit is rejected. Pre-commit hook enforces. **Stockforge raw/wiki separation needs a similar rule for spec ↔ code coupling.**

10. **Levels of Autonomy mapped to SAE** — they target L3 ("Conditional", aka "fighter jet": human steers + sets boundaries + intervenes; agent executes maneuvers). **Explicitly warns against L4/L5** ("regression to mediocrity" — agent picks generic/boilerplate without human strategic intent). **Validates stockforge's full-autonomous-but-with-human-checkpoint model.**

---

## Top 10 BORROW Patterns

### B1. Sandwich Workflow (Plan → Impl → Verify, 3 separate sessions)
- **Source**: `26-multi-agent-sandwich-workflow.md` §2-3
- **What**: 3 separate agent sessions, each with focused budget (50-80K plan, 100-250K impl, 30-60K verify). Total tokens HIGHER than single-agent, but each context stays under attention-decay threshold (~150K). Failure rate 20% → 6%.
- **Why for stockforge**: Already in CLAUDE.md as session types (PLAN / FOCUSED IMPL / MULTI-TASK IMPL / VERIFY). ms-mdp gives us the concrete handoff file format and the empirical "never mix plan+impl in same session" rule (S4 catastrophic failure).

### B2. session-handoff.md Structured Format
- **Source**: `26-multi-agent-sandwich-workflow.md` §3.3
- **What**: Single mandatory file with 5 sections — Last Session Summary / Pending Items per Agent / Notes (with root cause + suggested fix) / Quality Gate Status. Read first by every session.
- **Why for stockforge**: stockforge already has `agent-workspace/memory/current-execution.md` and `sessions/`; ms-mdp's format is more handoff-actionable (explicit "Pending: Architect" vs "Pending: Dev" lists and root-cause notes).

### B3. Same-Commit Rule for Spec ↔ Code
- **Source**: `04-spec-driven-development.md` "Spec Maintenance"
- **What**: Behavior-changing commit MUST include spec update; pre-commit hook detects mismatch.
- **Why for stockforge**: Currently we have raw/wiki separation but no enforced coupling between spec change and code change. Port directly into the stockforge git hook for spec drift.

### B4. Local-First Agent Mailbox (.context/agent-mailbox/)
- **Source**: `20-multi-agent-communication.md` §4
- **What**: `inbox.md`, `outbox.md`, `shared-state.md`, `budget.md`, `discussion-log.md` — agent-to-agent comms happen LOCAL, only finalized decisions go to cloud (Jira). Claims 80% token savings.
- **Why for stockforge**: Maps exactly to UP02 §1.5 (reboot cost / surgical context injection). Stockforge has no equivalent today; this is the missing primitive for hook ports / observation files.

### B5. Decision Provenance Chain
- **Source**: `22-spec-integrity-agent-operations.md` §3
- **What**: Every spec change requires: discussion thread + decision record (A3 format) + source evidence + approval chain + git blame. From IEC 62304/ASPICE/DO-178C aerospace/medical-device standards.
- **Why for stockforge**: For finance, this is mandatory — stockforge invariants demand source + as-of date on every claim. Adapt directly: every thesis decision needs source URL + extracted_at + approval (human checkpoint).

### B6. VBW Protocol with Granular Checkpoints
- **Source**: `18-ai-agent-self-governance.md` §"SELF-GOVERNANCE PROTOCOL"
- **What**: 4 named checkpoints (Pre-Spec / Pre-Test / Mid-Implement-every-5-steps / Post-Implement) with explicit checklists. Plus 5 named rules: VBW, CCF (Compile Check First), SYA (State Your Assumptions), DA (Drift Anchor), TBA (Token Budget Awareness).
- **Why for stockforge**: stockforge has a `vbw-check` command and `vbw-protocol.md` — adopt the more granular checkpoint structure. Especially the "every 5 steps re-read task.md" drift-anchor pattern.

### B7. Identity + Budget Caps per Agent
- **Source**: `20-multi-agent-communication.md` §1, §3
- **What**: Each agent has visual identity (emoji + role) and explicit per-interaction budget (e.g., BA: 3 Jira comments / 1 Confluence page / 5 local msgs). Guardian halts everyone if budget breached.
- **Why for stockforge**: Caps prevent runaway sessions. Stockforge already has session token budgets; per-agent (and per-channel) caps are finer-grained.

### B8. Drift Detection Signals (D1-D8) with Auto-Detection Scripts
- **Source**: `14-self-evaluation-framework.md` §I
- **What**: 8 named drift signals (Import creep, Anemic regression, Test theater, Spec staleness, Console.log proliferation, `any` leak, Fat controllers, Missing domain events) with severity + grep scripts. Pre-commit hook runs all 8.
- **Why for stockforge**: Already have DR1-DR12 in `drift-signals.md` and a `drift-check` command. ms-mdp's grep-script pattern shows how to make them runnable as a hook (not just human-checked).

### B9. Spec-as-Context-Filter (200-500 line target per BC spec)
- **Source**: `25-token-context-optimization.md` §4
- **What**: Each BC spec is a 200-500 line "super-prompt". Hits: "agent reads 1 spec file (200 lines) instead of 50 source files (5000 lines)" → 87% token savings per task. Specs MUST stay <500 lines or they're "monolithic anti-pattern".
- **Why for stockforge**: Confirms stockforge's spec template is on track. Add the size cap (<500 lines) as a hard rule.

### B10. Failure Catalog as First-Class Artifact (mistake-log.md)
- **Source**: `14-self-evaluation-framework.md` §V; `37-mdp-workflow-integration.md` "Change C"
- **What**: `.context/mistake-log.md` with format: What went wrong / Root cause / Prevention rule / Severity. Read during pre-flight. Each mistake → new rule in AGENTS.md → mistake never repeats.
- **Why for stockforge**: stockforge has `agent-notes.md` for learned rules but no structured mistake log. Adopt the format directly. Track 28→3 errors/sprint trajectory as a metric.

---

## Top 10 ADAPT Patterns

### A1. Multi-Agent Roster (BA / QA / Dev / PM / Research / Guardian)
- **Source**: `19-multi-agent-orchestration.md`, `20-multi-agent-communication.md`
- **Adaptation**: ms-mdp has 6 agents for an enterprise team. Stockforge is single-user; collapse to 3-4 agents: Architect (plan), Builder (impl), Verifier (review), Guardian (drift/spec-integrity continuous). Drop PM/BA agents — user IS the PM.
- **Port destination**: `.claude/agents/` (NestJS-style agent definitions) — but Python harness, not NestJS.

### A2. Critic Agent (Adversarial Review with Fresh Context)
- **Source**: `06-context-gates.md` "Tier 2"
- **Adaptation**: Their Critic reviews TypeScript code against TS specs. Stockforge needs adversarial reviewer for thesis output (must include bear case explicitly). Port concept; build a `thesis-adversary` skill that adds bear case + calibration check.
- **Port destination**: `.claude/skills/thesis-adversary/` or a dedicated subagent.

### A3. PBI Template (Directive + Context Pointer + Verification Pointer + Refinement Rule)
- **Source**: `04-spec-driven-development.md` §"PBI Cho Agent"
- **Adaptation**: Their PBI is for code tasks. Stockforge maps to thesis tasks: "Directive: explore PNJ thesis", "Context Pointer: specs/thesis/methodology.md", "Verification Pointer: scenarios for PNJ valuation", "Refinement Rule: if data unavailable, halt for human".
- **Port destination**: New `tasks/` template aligned with thesis-task structure.

### A4. .claudeignore + Layered Context Loading
- **Source**: `25-token-context-optimization.md` §3.1, §5.2-3; `38-token-context-efficiency-combined.md` §6.2
- **Adaptation**: Their `.claudeignore` excludes node_modules, dist, ms-mdp-admin/. Stockforge needs: `obsidian-vault/raw/` (immutable), `eval-sets/`, `agent-workspace/memory/sessions/` (load only handoff). Keep loading priority: constitution first, current-execution second, BC spec third, source on-demand.
- **Port destination**: `.claudeignore` + update CLAUDE.md context-loading order.

### A5. Token Budget Model per Session Type
- **Source**: `25-token-context-optimization.md` §5.1
- **Adaptation**: Their budgets (50-80K plan, 100-250K impl, 30-60K verify) are NestJS-task-sized. Stockforge tasks are smaller (Phase 0 harness). Adopt the structure but tune: PLAN 30-50K, FOCUSED IMPL 80-150K, VERIFY 20-40K. Hard limit: 250K → mandatory split (already in CLAUDE.md).
- **Port destination**: Already in `session-budgets.md`; refine numbers post-Phase-0.

### A6. Three-Tier Spec Architecture (Strategic / Tactical / Operational)
- **Source**: `16-spec-boundary-management.md`
- **Adaptation**: Tier 1 (Confluence narrative) → Stockforge Charter. Tier 2 (specs/{bc}/spec.md) → Stockforge specs/. Tier 3 (code+tests) → packages/. Already aligns; their formalization adds clarity on which tier wins in conflicts.
- **Port destination**: Add a "spec authority hierarchy" section to stockforge constitution.

### A7. Quality Gate Tiers (Deterministic / Probabilistic / Human)
- **Source**: `06-context-gates.md`; `14-self-evaluation-framework.md` §IV
- **Adaptation**: ms-mdp uses tsc/jest/sonar for Tier 1, AI Critic for Tier 2, human PR review for Tier 3. Stockforge adapts: mypy/pytest/ruff (Tier 1, already done), separate-agent code review + calibration drift check (Tier 2), human at phase boundary + thesis quality review (Tier 3). Already in CLAUDE.md — ms-mdp adds "catch errors at the cheapest gate possible" rule with cost-to-fix table.
- **Port destination**: Refine `agent-workspace/constitution/` with explicit cost-tier table.

### A8. Token Tracking Template per Session
- **Source**: `38-token-context-efficiency-combined.md` §6.5
- **Adaptation**: Their template tracks Pre-flight / Task context / Execution / Handoff against budget targets. Adapt for stockforge session-end protocol; add a per-thesis line-item.
- **Port destination**: `agent-workspace/memory/sessions/` template.

### A9. Confidence Scoring Per Change (HIGH/MEDIUM/LOW)
- **Source**: `14-self-evaluation-framework.md` §VII; `20-multi-agent-communication.md` §5.2.3
- **Adaptation**: Their confidence ladder triggers different review intensity (HIGH = auto-merge, LOW = senior + ADR). Stockforge has a "Confidence Score System" track in Phase 0 — port the 3-tier ladder. Critical: stockforge confidence MUST trace to historical hit rate (calibration), not just model "feeling certain" — this is stricter than ms-mdp.
- **Port destination**: `agent-workspace/calibration/` integrated with confidence ladder.

### A10. Anti-Behavior Catalog (A1-A8: Shotgun, Gold-plating, Spec amnesia, etc.)
- **Source**: `14-self-evaluation-framework.md` §III
- **Adaptation**: Their catalog is code-task-focused. Stockforge needs a thesis-version: A-thesis1 "single-perspective output", A-thesis2 "LLM-computed numbers", A-thesis3 "confidence without calibration data", A-thesis4 "recommending stocks user owns". Pattern is portable, content is stock-domain.
- **Port destination**: New file `agent-workspace/constitution/thesis-anti-patterns.md`.

---

## Top 5 LEARN Patterns

### L1. "Spec is God" insight + Cascading Failure analysis
- **Source**: `22-spec-integrity-agent-operations.md` §1.2
- **Why learn**: Frame for thinking about why spec corruption is exponentially worse than code bugs in a multi-agent world. Don't port a tool; internalize the framing — every spec change in stockforge could cascade through extraction, thesis synthesis, calibration. Lower the bar to "request spec change" and you've built a corruption pipeline.

### L2. The 80/20 Inversion (humans 20%, agents 80% of time)
- **Source**: `22-spec-integrity-agent-operations.md` §1.1
- **Why learn**: "Pain points come from the 80% where agents operate, not the 20% where humans do." Most research/governance literature optimizes the 20%. Stockforge must instrument the 80%: every agent action logged, every prompt validated, every output cross-checked.

### L3. Lost-in-the-Middle empirical curve (Liu 2023)
- **Source**: `25-token-context-optimization.md` §2.1
- **Why learn**: LLMs lose accuracy on info placed mid-context. Implication for stockforge: critical rules (constitution, no-LLM-math invariant) belong at TOP of context; fresh state at bottom; spec/source in middle is OK only if compact. Don't bury invariants in a 100K-token middle section.

### L4. "Regression to the Mean" warning against L4/L5 autonomy
- **Source**: `05-agentic-sdlc.md` §"L3 Fighter Jet"
- **Why learn**: Without human strategic intent, agents pick "average" solutions — generic boilerplate, no architectural novelty, no domain-specific edge. Stockforge user wants full-autonomous; this is the warning that full-autonomous needs SHARP human-set boundaries (charter, invariants, drift signals) or output drifts to vanilla.

### L5. Quadratic Attention Cost is non-linear, not 2x context = 2x output
- **Source**: `25-token-context-optimization.md` §2.2-3
- **Why learn**: 32K → 128K context = 16x compute, not 4x. And quality DECREASES per token at long context. Implication: stockforge's mandatory split rule at 250K is not paranoia, it's empirical. Don't be tempted to "just give it more context".

---

## Cross-Reference with Orch

| Topic | Orch Approach (inferred from stockforge CLAUDE.md / charter) | ms-mdp Approach | Stockforge fit |
|---|---|---|---|
| **Spec drift** | raw/wiki separation; spec-to-wiki skill; charter immutable | Same-Commit Rule + Guardian Agent + Decision Provenance Chain | ms-mdp adds enforcement (hook + agent), orch has structure. **Combine**: orch's raw/wiki layout + ms-mdp's enforcement. |
| **Multi-agent comm** | Implicit in subagent definitions; no shared mailbox | Local-First Mailbox (.context/agent-mailbox/) with budget caps | ms-mdp has the missing primitive. **Adopt mailbox** for stockforge hook ports / observation files track. |
| **Self-evaluation** | drift-signals DR1-DR12; agent-notes.md for learned rules | D1-D8 drift signals (overlapping); mistake-log.md with structured format; per-sprint metrics (errors caught, rules added) | Orch's drift signals are MORE comprehensive (12 vs 8). ms-mdp's mistake-log format is better than orch's notes. **Combine.** |
| **Session protocol** | session-start / session-end / current-execution.md | session-handoff.md with Pending-per-agent + root-cause notes | Orch's is broader; ms-mdp's is sharper for handoff specifically. **Refine current-execution.md format.** |
| **Spec template** | spec-dual-layer skill (business narrative + agent contract) | Blueprint + Contract structure (architecture + DoD/Gherkin) | Both dual-layer. ms-mdp's PBI 4-part format (Directive/Pointer/Verify-Pointer/Refinement) adds delta-task structure. **Adopt PBI format for thesis tasks.** |
| **Multi-agent orchestration** | Defined in `.claude/agents/`; subagent dispatch via skills/commands | Sandwich (Plan/Impl/Verify) + sequential handoff via @mention + Guardian continuous | Orch hasn't formalized sandwich pattern. **Adopt sandwich** as the default workflow. |
| **Calibration / confidence** | "Calibration over confidence" invariant; calibration/ folder | HIGH/MEDIUM/LOW confidence ladder per change; Guardian validates LOW before others proceed | ms-mdp lacks domain-specific calibration (stockforge needs hit-rate tracking). **Use ms-mdp's ladder structure + stockforge's empirical calibration source.** |
| **Token economy** | Session budgets table in CLAUDE.md | SCOPE protocol (Selective / Curated / Optimal preload / Progressive / Explicit boundaries); .claudeignore | Both aware. ms-mdp adds the empirical evidence (87% savings claim) and concrete .claudeignore for adoption. **Add .claudeignore + SCOPE checklist.** |

**Where they DIVERGE / which applies to stockforge:**
- Orch focuses on **principles and invariants** (charter, karpathy-principles, no-LLM-math); ms-mdp focuses on **operational mechanics** (session-handoff, mailbox, budget caps). **Stockforge needs both.** Orch's invariants ensure correctness; ms-mdp's mechanics ensure agents can execute autonomously without melting context.
- Orch is **finance-domain-aware** (calibration, sources, no-insider-info). ms-mdp is **stack-agnostic but TypeScript/NestJS-shaped**. Most ms-mdp patterns survive translation; the TypeScript-specific drift signals (D5 console.log, D6 `any` types) need Python equivalents (print() instead of structured logger; missing type hints).

---

## Anti-Patterns / Cautions

| # | Anti-Pattern | Source | Why it bit them | Stockforge implication |
|---|---|---|---|---|
| 1 | **AP-1: Load full codebase before working** | `25-token-context-optimization.md` §5.6 | Session 4 catastrophic failure — context overload, agent invented patterns, 0 output | Already in CLAUDE.md as "Session 4 failure mode". Reinforce. |
| 2 | **AP-2: Mix plan + implement in same session** | `25` §5.6; `26` §1.2 | Session 4. Role confusion. | Already a hard rule in CLAUDE.md. |
| 3 | **AP-5: Single-agent self-review** | `26` §1.1 | "Fox guarding henhouse" — confirmation bias, missed spec drift | Stockforge already prescribes "separate agent for Tier 2 gate". Validate this is enforced. |
| 4 | **AP-7: Retry failed approach instead of revert** | `25` §5.6 | S45 cascading reverts (370+ TS errors) | Stockforge needs a "revert early, revert often" rule. |
| 5 | **Spec-as-Source (L3 maturity, ANTI-PATTERN)** | `04-spec-driven-development.md` §"Three Maturity Levels" | "Tiny spec change → butterfly effect → 50 files changed → impossible to review". MDD failed in 2000s for same reason. | Stockforge user wants full-autonomous — this is the trap. **Do NOT** let agent generate 100% of code from spec without code-level review checkpoints. |
| 6 | **Stale Spec / Spec in Slack / Monolithic Spec** | `04` §"Anti-Patterns" | Specs decay when not enforced same-commit | Add same-commit hook before specs accumulate drift. |
| 7 | **Hallucination from convention** | `18` §"PHÂN TÍCH" — measured 11.1% rate | Agent writes from DDD pattern memory (`enableKillSwitch()`, `clearDomainEvents()`, `updateName()`) without verifying methods exist | Stockforge's no-LLM-math + sources rule is partial protection; need explicit VBW for method calls / library APIs / data fields. |
| 8 | **Spec for not-yet-implemented feature without "PROPOSED" tag** | `18` §"D-2 drift" | Agent wrote spec for kill switch as if it existed, didn't mark as proposed | Stockforge specs need explicit "CURRENT vs PROPOSED" markers, especially for thesis methodology (some research aspirational). |
| 9 | **Sandwich over-applied to small tasks** | `26` §5.5 limitations | 3-phase overhead > benefit on <3-file changes | Use the decision matrix: small tasks = single Claude Code session, no sandwich. Don't over-formalize. |
| 10 | **Plan staleness** | `26` §5.5 | Plan written, code changed during impl phase, plan now outdated | Re-read target files in Phase B (impl) — don't trust plan as ground truth on file content. |

---

## Connection to User's Concerns

### Reboot cost / surgical context injection (UP02 §1.5)
- **ms-mdp's answer**: Local-first agent mailbox (`.context/agent-mailbox/`). Inter-agent messages live as files. Only finalized state goes to Jira. **80% token savings claim**. Pair with structured `session-handoff.md` (200-500 tokens) → next session starts with minimal context bootstrap.
- **Empirical data**: Token budget per PBI: ~8.8K with framework vs ~70K without (87% savings, doc 14 §VI).
- **Direct port**: Build `agent-workspace/observations/` and `agent-workspace/sync-tracker/` — stockforge already has these directories. Adopt the mailbox file format (inbox.md / outbox.md / shared-state.md / budget.md).
- **Loadable bootstrap (per session, target <10K tokens)**: constitution.md (~2K) + CLAUDE.md (~3K) + session-handoff (~500) + skill manifest (~300) + mistake-log (~200) = 6-7K (per `38-token-context-efficiency-combined.md` §6.1).

### Grill maximization
- **ms-mdp's adversarial review pattern** (`06-context-gates.md` Tier 2): Critic Agent in fresh context with mandate "find violations, not praise". Run AFTER Builder, with separate session. Output is structured violation list, not feedback paragraph.
- **Combined with stockforge's `grill-me` and `devils-advocate` commands**: ms-mdp's "skeptical-by-design" framing reinforces that grill agent must NOT share context with the agent it's grilling.
- **Bear-case requirement** maps directly to stockforge's "single-perspective output is anti-pattern" invariant.

### Second-brain pattern
- **ms-mdp's three persistence tiers** (`38-token-context-efficiency-combined.md` §3.4):
  - Tier 1 Session: `.context/session-handoff.md` (~200-500 tokens, every session)
  - Tier 2 Cross-session: `.claude/memory/` (index only ~100-300 tokens, on-demand)
  - Tier 3 Permanent: `CLAUDE.md` + `constitution.md` (~4-6K tokens, every session)
- **Maps to stockforge**: Tier 1 = `agent-workspace/memory/current-execution.md` + `sessions/`. Tier 2 = `agent-workspace/memory/agent-notes.md` + `decisions/` + `thesis-log/` (loaded on-demand). Tier 3 = `CLAUDE.md` + `PROJECT_CHARTER.md` + `agent-workspace/constitution/`.
- **Gap to fill**: Stockforge's Tier 2 should have an INDEX file (one line per memory) so agent can decide what to load. Currently we list directories but no index.

### Self-Awareness Agent
- **ms-mdp's Guardian Agent** (`22-spec-integrity-agent-operations.md` §4): continuous-running, monitors all 5 channels (specs, code, tests, Jira, discussions). Detects drift, hallucination propagation, spec corruption. Can HALT all agents if critical issue detected.
- **Direct port for stockforge**: Self-Awareness Agent should be Guardian-shaped — runs every N actions (or per session-end), cross-validates: thesis output ↔ source claims ↔ calibration history ↔ user portfolio ↔ no-LLM-math invariant. Issues HALT signal if any inconsistency.
- **Detection patterns**: ms-mdp lists 6 specific Guardian checks (Section 4.3). Stockforge equivalents: thesis ↔ source URL match, claim ↔ as-of date validity, recommendation ↔ portfolio conflict (confirmation bias), calibration drift, no-insider-info, framing as research-aid.

### Q&A escalation / intent classification
- **ms-mdp's @Mention Protocol** (`20-multi-agent-communication.md` §2): 5 message types — REQUEST / RESPONSE / BROADCAST / ESCALATE / HALT. Each agent routes via @agent-{role} or escalates via @human-dev.
- **Stockforge intent classifier could use this**: classify user prompt → route to (Architect / Builder / Verifier / Guardian / human-only). ESCALATE = "ask human"; HALT = "this needs charter revision".

---

**Files (absolute, FYI)**:
- Output: `C:\htdocs\stockforge\agent-workspace\memory\patterns-discovered\pattern-mining-msmdp.md`
- Source root: `C:\htdocs\labci\ms-mdp-admin_refactor\tasks\refactor_phase2\phase2_workflow\`
