---
created_at: 2026-04-29 (S19 — Track 9 Phase 0 reduced)
purpose: Append-only catalog of learned best practices per (model × effort × task_class).
related: agent-workspace/memory/agent-notes.md (general learned rules)
schema: BP-NNN entries (id / learned_at / context / rule / why / how_to_apply / promotion_target / refs)
---

# Best Practices — (model × effort × task_class)

> **Append-only.** New entries land at bottom with sequential `BP-NNN` IDs.
> Distinct from `agent-notes.md` (general learned rules) — this file is specifically
> about model-routing and effort-mode discretion learned from telemetry.

> **Phase 0 status**: 3 SEED entries below populated from existing session evidence.
> Phase 1+ promotion-routing absorbs new entries from session retrospectives.

---

## BP-001 — Use FOCUSED_IMPL for single-track refactor; MULTI_TASK_IMPL for cross-track wiring

- **learned_at**: 2026-04-29 (S14 close — Track 6 primary; S16 close — Track 7 IMPL)
- **context**: Choosing session type when refactor scope mixes single-file and cross-track wiring
- **rule**: FOCUSED_IMPL ~120K target for single-track refactor (top-N D1 violators); MULTI_TASK_IMPL ~150-200K for cross-track wiring (3+ hook wire-ins + skill amendments + decision amendments)
- **why**: FOCUSED_IMPL session 4-failure mode of mixing PLAN+IMPL is avoided; MULTI_TASK_IMPL absorbs the wiring overhead without bumping budget
- **how_to_apply**: When session plan touches >2 distinct subsystems (skill + hook + decision), pick MULTI_TASK_IMPL. When touches 1 subsystem family (e.g., skill refactor), pick FOCUSED_IMPL.
- **promotion_target**: agent-workspace/constitution/session-budgets.md § Type selection (post-Track-7)
- **refs**: D-002 REV-2 § D session sequencing; CLAUDE.md § Session Types

---

## BP-002 — Cross-language regex ports require locale-extension checklist

- **learned_at**: 2026-04-29 (S18 close — L-S18-1)
- **context**: Porting keyword/phrase regex tiers from source repos with different locale assumptions
- **rule**: Audit every regex tier for target-locale gaps; explicitly extend with N target-locale phrases; cover via tests; document the extension in port-decision file
- **why**: Source-repo regex (e.g., RU+EN) silently drops target-locale (VN) phrases the consuming project cares about; downstream calibration biased toward source locale
- **how_to_apply**: Pre-flight when porting: identify all keyword/phrase regex tiers; audit each against project identity locale; extend before shipping; tests must cover one example per added locale
- **promotion_target**: proposals/architecture-amendment.md § "When porting from source repos" OR evidence-extraction/SKILL.md § Cross-locale port checklist
- **refs**: D-007 § Decision; L-S18-1 (S18 session log)

---

## BP-003 — IMPL-tier resolution doctrine: agent self-decides when storage/library substrate is non-charter

- **learned_at**: 2026-04-29 (S17 + S18 close — IMPL-S17-1 + IMPL-S18-1 + IMPL-S18-2)
- **context**: Choosing storage substrate (TSV vs SQLite) or library scope (full vs reduced) when decision is non-charter, non-SCOPE
- **rule**: Agent self-decides via 3-options-considered + chosen + rationale + test PASS verification; documents in D-NNN; subject to drift audit + sandwich-verifier cross-check
- **why**: AskUserQuestion overhead disproportionate for non-charter IMPL choices; D-003 § Open Questions doctrine + autonomous_mode=true authorize the path; reversibility preserved via 12-field decision schema
- **how_to_apply**: If decision is IMPL-tier (affects_charter=false, affects_scope=false), agent picks based on options-considered analysis; test PASS + drift-clean + bash-hook-lint clean serve as the gate
- **promotion_target**: proposals/decision-discipline.md § "IMPL-tier resolution doctrine" Rule 3 sub-clause
- **refs**: D-006 § IMPL-S17-1; D-007 § IMPL-S18-1 + IMPL-S18-2; D-008 § approval_chain

---

---

## BP-S30-1 — VBW pre-flight before PLAN-tier deliverable: Read/Glob actual filesystem state

- **learned_at**: 2026-04-30 (S30 close — L-S30-1; APPLIED 3× since at S31, S33, S34)
- **context**: Authoring a session plan or master-plan whose deliverables claim specific file paths exist
- **rule**: Before writing "ratify in place" / "extend file X" / "split file Y" deliverables, run Glob + Read against the claimed paths. Do not trust master-plan stale path claims.
- **why**: Master-plan 004 + 005 had path-drift between authoring time and IMPL time. S30 caught `eval-sets/labeled-pumps/seed.md` nonexistent → ratified existing `eval-sets/{labeled-kol-recommendations,historical-pumps,historical-theses}/SEED.md` instead. S31 master-planner subagent confirmed `apps/dashboard/` does not exist + 9 proposals confirmed via Glob. S33 caught `value_objects/` directory absence vs master-plan stale claim.
- **how_to_apply**: Prepend every PLAN-tier session OR every IMPL-tier deliverable claiming a specific file/dir with: (a) Glob the claimed path pattern; (b) Read the file if expected to be modified; (c) Document any mismatch as IMPL-S{N}-* deviation rather than fabricating.
- **promotion_target**: Extend existing `vbw-check` skill `.claude/commands/vbw-check.md` to be invoked as Stop-hook pre-flight on every PLAN session OR add to `agent-workspace/CLAUDE.md` Reading Priority step 0
- **refs**: L-S30-1 (agent-notes); S30 + S31 + S33 + S34 session logs; current-execution.md § "L-S30-1 VBW APPLIED" mentions

## BP-S32-1 — Empirical probe before strategy commit (vendor-API resilience)

- **learned_at**: 2026-04-30 (S32 close — L-S32-1; extends L-S28-1)
- **context**: Master-plan offers ≥3 strategies for external dependency (vendor API source); PLAN-time source_evidence may be stale by IMPL time
- **rule**: When master-plan ladder has ≥3 strategies, probe ALL viable strategies before commit. Generate per-strategy go/no-go via 1-call smoke test BEFORE committing IMPL effort. Document probe outcome in decision file.
- **why**: S26 PLAN sourced TCBS REST → S28 IMPL hit 404 (~6h later). S31 master-plan 005 recommended A2 vnstock alternate-source → S32 probe rejected A2 (vnstock 4.0.2 deprecated TCBS/DNSE/SSI/FMARKET as Quote sources). Probe-first saves IMPL waste on dead vendor surface.
- **how_to_apply**: At IMPL-tier session start with vendor strategy: (a) write 30-LOC probe script per strategy; (b) run all probes; (c) pick first working strategy; (d) record probe results in D-NNN with timestamps; (e) deprecate failed strategies via banner edit.
- **promotion_target**: Extend `crawler-reliability` skill § "Pre-IMPL vendor probe" + add Stop-hook trigger when `D-NNN` cites ≥3 strategies with `affects=vendor_api`
- **refs**: L-S32-1, L-S28-1 (agent-notes); D-012 § probe-results table; KI-S35-4

## BP-S35-1 — Promotion cycle frequency: every 5 sessions OR phase boundary, whichever first

- **learned_at**: 2026-05-01 (S35 META_LOOP_RECOVERY — surfaced from 15-session promote-cycle skip)
- **context**: agent-notes accumulating lesson candidates without promotion to skill/hook/charter
- **rule**: Run `promote-rule` subagent every 5 sessions OR at every phase boundary, whichever fires first. Loose "promote at phase close" Q-E2 doctrine deferred 7 lessons across 9 sessions S25-S34 → 0 promoted. Tighten to N-cap.
- **why**: Phase boundaries are crowded with closure work; promotion gets squeezed out. 5-session cap creates regular pressure-relief without flooding overhead. Q-E2 answer (phase-boundary) was correct as floor; 5-session is the actionable ceiling.
- **how_to_apply**: At session-end Stop hook: count session-id since last `promote-rule-S{N}.md` observation. If ≥5 sessions OR phase boundary detected (current-execution.md § Phase changed) → fire `promote-rule` subagent dispatch with current proposal + lesson set. Soft-warn at 3 sessions; hard-block session close at 8.
- **promotion_target**: New deterministic hook `scripts/hooks/promotion-cycle-watchdog.sh` (Stop hook) + add to CLAUDE.md § Session End checklist as step 6
- **refs**: post-mortem 2026-05-01 § "Defer to phase close black hole"; S35 D4 promote-rule observation; Q-E2 in queued-grill-master.md

## BP-S35-2 — DR-INTENT at every phase boundary: re-read all user_prompts

- **learned_at**: 2026-05-01 (S35 — DR-INTENT signal birth)
- **context**: Phase entry / phase boundary; long-running autonomous trajectory with multiple historical user_prompts
- **rule**: At every phase boundary AND every 5 sessions, re-read ALL `human-workspace/user_prompt/*.txt` files (not just most recent). Cross-check active trajectory against each directive. Soft-flag drift; escalate USER-CRITICAL silent deferral.
- **why**: AP-5 (Charter-coherence defer overriding USER-CRITICAL). 8 user_prompts existed since project start; never re-read at phase boundary across 15 sessions S20-S34. UP-06 directives partially carried via Track 5.5 codification but later UP-07/UP-08 may have been silently deferred.
- **how_to_apply**: New skill step in `/drift-check` (S35 D5 shipped); semantic depth via `intent-vs-impl-diff` agent dispatch; Stop hook trigger on phase-boundary-detected.
- **promotion_target**: `agent-workspace/proposals/drift-signals-amendment-DR-INTENT.md` (S35 D5); promote to charter at Phase 2 close per Q-B2 SCOPE-tier user-gate
- **refs**: post-mortem 2026-05-01 § "Drift-check scope blind to human-intent layer"; CLAUDE.md SYNTHESIS § 6 AP-5

## BP-S43b-1 — Per-role model override pattern for LLM-perspective adapters

- **learned_at**: 2026-05-01 (S43b-BULL)
- **context**: One role's prompt-pairing produces empirical timeout / cost spike on the default-routed model while sibling roles complete fine
- **rule**: Add `role_model_overrides: dict[Role, str] | None` field to the adapter dataclass; resolution order is `model_override → role_model_overrides[role] → _ROLE_TO_MODEL[role] → _DEFAULT_MODEL`. Wire override in the use-case-builder, not the agent class — agent stays role-pure.
- **why**: Default routing per spec § B.10 was sonnet-for-{bear,bull}. Bull sonnet pairing reproduced 300s subprocess timeout 2/2 runs. Haiku-bull empirically completes <60s + cheaper. Pattern is reusable for any future role-specific tuning (e.g. quant→opus is already default; if a future role needs longer context, the field is right there).
- **how_to_apply**: When a single role exhibits stable failure mode under default routing AND siblings are healthy → audit for empirical model fit; promote a per-role override; document rationale in adapter docstring + builder callsite docstring.
- **promotion_target**: Could promote to a generic `RoleRoutedAdapter` skill, but pattern is small enough that inline-document doctrine (L-S15-1) suffices unless 2+ adapters need the same field.
- **refs**: `claude_llm_perspective_adapter.py` `role_model_overrides` field doc; `apps/_shared/use_case_builder.py::_build_subagent_agents`; KI-S43b-1; checkpoint S43b-BULL

---

## BP-S43b-2 — Prose-tolerant JSON extractor for LLM structured output

- **learned_at**: 2026-05-01 (S43b-FRESH)
- **context**: LLM contract says "output JSON" but model emits prose preamble + fenced JSON + prose postamble — naive `json.loads(raw)` fails
- **rule**: 3-tier extractor — (1) regex `_INNER_FENCE_RE` finds last fenced ```json...``` block; (2) brace-depth scan with string-aware skipping for fence-less prose-wrapped JSON; (3) raw text fallback (downstream parse fails with diagnostic). Always return LAST fence match — preamble fences sometimes appear when the model "thinks out loud" in earlier blocks.
- **why**: Even with explicit "Output JSON" prompt + low temperature, sonnet/opus regularly emit `Here are 4 bear points...\n\`\`\`json\n{...}\n\`\`\`\nNote: ...`. Agents that strictly require valid JSON drop key_points to 0 → bear-retry → cost burn → eventual incomplete thesis.
- **how_to_apply**: Apply in any LLM transport / adapter consuming JSON-contract output. Promotion target = util module `packages/infrastructure/_shared/llm_json_extract.py` if 2+ adapters need it.
- **promotion_target**: `packages/infrastructure/_shared/llm_json_extract.py` shared util OR extend prompt-engineering skill § "JSON contract output handling"
- **refs**: `packages/infrastructure/analysis/subagent_transport.py:55-118`; KI-S43b-2

---

## BP-S43b-3 — Wire deterministic compute services through gatherer, not agent

- **learned_at**: 2026-05-01 (S43b-EVIDENCE)
- **context**: Domain has a deterministic compute service (e.g. ta_service.compute_ta_features); agent prompt expects to interpret these numbers but no consumer wired the call
- **rule**: Wire deterministic-compute services in the data-gatherer layer (one orchestrator), not in the agent (per-call duplication). Gatherer returns SharedContext with all derived features pre-populated. Agent's adapter's `_context_to_str` is the only renderer; agent itself is pure interpretation. Honors I-S1 boundary cleanly.
- **why**: ta_service existed with 15 tests but unwired → quant returned 0 grounded points 2 dogfood runs → user assumed substrate broken when it was a wiring gap. Centralizing in gatherer means: (a) one place to verify "X feature populated"; (b) gatherer-level gap detection (`ta_insufficient`); (c) adapter renderer is feature-agnostic — no per-feature special casing.
- **how_to_apply**: When adding any deterministic compute (ratio service, TA, peer-comparable, percentile) → ensure gatherer reads → gatherer populates SharedContext field → adapter renders in `_context_to_str`. Test the 3-step chain end-to-end before live dogfood.
- **promotion_target**: `agent-workspace/constitution/architecture.md` § "Data substrate flow: BC repo → domain service → gatherer → SharedContext → adapter render"
- **refs**: `packages/infrastructure/analysis/phase1_data_gatherer.py:209-219`; `packages/domain/market_data/services/ta_service.py`; KI-S43b-4; spec § A.10

---

## BP-S43b-4 — Lesson-synthesis is mandatory at session-end (Stage 2 of self-upgrade loop)

- **learned_at**: 2026-05-01 (user audit S43b-EVIDENCE turn — surfaces 9-session dormant loop)
- **context**: Stop-hook aggregator runs (Stage 1: token counting) but lesson-synthesis (Stage 2) and promotion-cycle (Stage 3) require explicit agent dispatch that never fires
- **rule**: Every session that produces ≥1 user-correction OR ≥1 deferred-fix OR ≥1 substrate gap discovered MUST add ≥1 entry to known-issues.md AND/OR best-practices.md before checkpoint write. Reverse-pre-flight check: at session-end, if `git diff packages/` non-empty AND no new KI/BP entry → halt-warn.
- **why**: 9 sessions S35-S43b shipped clean feature work; 0 lesson entries appended. Patterns re-discovered each session (bull timeout pattern, prose-preamble pattern, TA wiring gap). User-memory dir captured some learnings but bypassed the project loop. KI-S43b-5 documents the structural failure.
- **how_to_apply**: New deterministic Stop-hook step `lesson-synthesis-watchdog.sh` — detects production diff + missing KI/BP entry → emits ALERT or invokes lesson-synthesis subagent. Until that hook ships, manual rule: agent's session-end checklist step must include "added ≥1 KI/BP entry if any pattern emerged".
- **promotion_target**: New deterministic hook `scripts/hooks/lesson-synthesis-watchdog.sh` (Stop priority 2 — after aggregator) + new subagent `.claude/agents/lesson-synthesizer.md` (fresh-context analysis of session diff + agent-notes append)
- **refs**: KI-S43b-5; BP-S35-1; user verbatim feedback in checkpoint `latest.md`

---

## BP-S43b-5 — Project-scoped lessons → agent-notes.md, NOT user-memory dir

- **learned_at**: 2026-05-01 (user feedback)
- **context**: Lesson is project-scoped (about stockforge architecture / patterns / failures) — NOT about user preference / language / role
- **rule**: Project-scoped lessons MUST land in `agent-workspace/memory/agent-notes.md` (version-controlled, hooks consume, promotion candidates). User-memory dir `C:\Users\PC\.ccs\instances\.../memory/` is for: (a) user role / preferences; (b) cross-project rules; (c) machine-specific paths. NEVER for: (a) project bug-fixes; (b) substrate patterns; (c) S{N} session lessons.
- **why**: User-memory writes bypass project promotion cycle (hook → skill → charter). 12+ entries accumulated as user-memory when they should have been agent-notes → project lesson-loop starves → patterns re-discovered. CLAUDE.md rules drift because charter doesn't see them.
- **how_to_apply**: Decision tree at write-time — "Is this lesson specific to stockforge code/patterns/sessions?" YES → agent-notes.md; "Is this about user / role / cross-project?" YES → user-memory. When ambiguous → both is acceptable but agent-notes.md is the canonical project copy.
- **promotion_target**: Document in `agent-workspace/CLAUDE.md` § "Memory routing decision tree"; add Stop-hook `memory-routing-audit.sh` that warns on user-memory writes during a session that touched `packages/` or `agent-workspace/`.
- **refs**: user verbatim "bạn lưu rất nhiều memory, note. chúng khiến hệ thống rất dễ lỗi"; checkpoint § "User feedback đúng"

---

## BP-S43b-6 — Pre-clear handoff-write invariant

- **learned_at**: 2026-05-01 (user reported prior-turn loss)
- **context**: A turn raised user-decision items (Q&A bundle, recommendation menu, charter-tier ratification) AND was followed by /clear → next turn started without those items in context → agent resumed wrong path
- **rule**: At end of EVERY turn that has pending user-decision items, agent MUST write `agent-workspace/memory/checkpoints/latest.md` with the pending decisions captured verbatim, BEFORE turn-end. Even if /clear is user-invoked, latest.md survives. /handoff-read or SessionStart hook resumes from this state.
- **why**: User reports concrete loss: "tương tự lúc tôi yêu cầu q&a, bạn list ra rồi tự clear luôn, nên tôi không thể trả lời." State-loss across /clear is a hard failure mode. checkpoints/latest.md is durable; conversation context is not.
- **how_to_apply**: Triggers requiring pre-clear-handoff write: (a) authored AskUserQuestion options; (b) listed numbered/lettered choices to user; (c) raised SCOPE-tier or charter-tier deferral; (d) reached `wind-down` budget threshold. New deterministic hook `pre-clear-handoff-guard.sh` — Stop priority 1 (before aggregator) — checks last turn's tool-use + text for these triggers; if matched and `latest.md` mtime older than turn-start → write checkpoint OR block /clear.
- **promotion_target**: New deterministic hook `scripts/hooks/pre-clear-handoff-guard.sh`; codify in `agent-workspace/constitution/autonomous-protocol.md` § "Pre-clear handoff invariant"
- **refs**: KI-S43b-6; user verbatim "rõ ràng là lỗi hệ thống, fix toàn diện"

---

## How to add new entries (Phase 1+)

```
BP-NNN — <one-line rule title>

- learned_at: <ISO-8601 UTC; session that surfaced the rule>
- context: <when this rule applies>
- rule: <the rule itself>
- why: <reason backed by evidence>
- how_to_apply: <concrete action>
- promotion_target: <where the rule lands once promoted (skill / hook / charter)>
- refs: <decisions/sessions/skills referenced>
```

Append below `BP-003` with sequential ID. Phase 1+ promotion subagent may identify
clusters of similar rules and merge into formal skill/hook/charter amendments.


---

## BP-S43b-7 — Harness-recovery DoD checklist + status convention

- **learned_at**: 2026-05-01 (KI-S43b-7 premature-stop; user pivot "fix toàn diện")
- **context**: User pivots to charter-tier recovery via verbatim trigger phrase. Agent must treat this as multi-turn arc with explicit DoD, not single task-list.
- **rule**: `current-execution.md` recovery row MUST list every HR-N item with terminal-status marker:
  - `✅ DEPLOYED` — hook/spec/code shipped + smoke-tested
  - `🔒 GATED-HUMAN-APPROVAL` — requires user explicit (charter amendment, $ burn, irreversible action)
  - `🔭 PHASE-N-DEFERRED` — explicitly out-of-scope for this arc with defer reason
  - `⏳ PENDING` — actionable autonomous work remaining (NEVER stop while any ⏳ exists)
  Stop is permitted ONLY when zero `⏳ PENDING` items remain.
- **why**: 3-turn premature-stop chain post-"fix toàn diện" pivot (user had to prompt 3× to re-engage); each turn ended tidy-summary while HR-3/4/6/7 sat PENDING. RC-1/2/3/4 documented in KI-S43b-7. Trust-loss risk on recurrence.
- **how_to_apply**: At session-end pre-flight: `grep -E '⏳ PENDING' agent-workspace/memory/current-execution.md` — non-empty ⇒ continue work, do NOT write tidy summary. End-of-turn output MUST include explicit DoD checklist when any HR-N item is in flight; never substitute with prose "awaits next prompt".
- **promotion_target**: NEW deterministic hook `scripts/hooks/harness-recovery-dod-watchdog.sh` (Stop, after lesson-synthesis-watchdog) — parses current-execution.md for ⏳ PENDING markers; if found AND production diff non-empty in scripts/hooks/ OR agent-workspace/constitution/ → ALERT in default mode, exit 2 in strict mode. Auto-detect tidy-summary anti-pattern.
- **refs**: KI-S43b-7; agent-notes L-S43b-10; user verbatim "lí do, tracing, note, update, fix để không lặp lại"

---

## BP-S43b-8 — Checkpoint `⚠️ unverified` fields are mandatory first-actions in the successor session

- **learned_at**: 2026-05-01 (S43b-EVIDENCE checkpoint + S43b-EVIDENCE-resume-verify Part A)
- **context**: A session completes a live dogfood run but cannot read back the thesis output before turn budget is exhausted; checkpoint marks the output field as `⚠️ unverified — need to read thesis-log/...`
- **rule**: Any checkpoint field marked `⚠️ unverified` MUST be the first resolved item in the successor session — before any new work, before any HR-N item, before phase-resume. The resolution is a Read + explicit VERIFIED/FAILED note written back to checkpoint. Do not bundle unverified-field resolution silently into "Part A — resume verify" as a side note; make it an explicit named task in the session plan and session log.
- **why**: S43b-EVIDENCE checkpoint flagged quant grounded points as `⚠️ unverified`. The successor session (S43b-EVIDENCE-resume-verify) performed the check in Part A but logged it as a single bullet ("HR-5 verified") without reading the actual thesis-log content or documenting what the quant section contained. The verification was nominal, not substantive. If quant had been silently broken, this path would not have caught it. Checkpoint `⚠️` markers are the handoff system's honesty signal — degrading them to nominal checks undermines the entire handoff protocol.
- **how_to_apply**: (1) At session-end: if any thesis-log run was not read back to confirm content, write `⚠️ unverified — must Read thesis-log/<file> in successor session and confirm <specific field>` in checkpoint; (2) At successor session-start: grep checkpoint for `⚠️ unverified`; for each hit, Read the referenced file; write `✅ VERIFIED: <field>=<value>` back to checkpoint; log the verification in session log under explicit heading "Unverified field resolution". Only then proceed to new tasks.
- **promotion_target**: Extend `pre-clear-handoff-guard.sh` to scan checkpoint for `⚠️ unverified` markers and require either resolution OR explicit carry-forward acknowledgement before session exit
- **refs**: `checkpoints/latest.md` (S43b-EVIDENCE) § "Quant grounded points populated ⚠️ unverified"; `2026-05-01-session-43b-evidence-resume-verify.md` § Part A; KI-S43b-4; KI-S43b-8
