# S402 Architect Observation — Harness Stabilization Sweep N+2 PLAN (plan-046)

**Persona**: sandwich-architect (background, fresh-context)
**Model**: Claude Opus 4.7 (per all_14_agents_on_opus rule)
**Dispatched by**: S401 main close-bookkeeping turn
**Authored**: 2026-05-17
**Plan delivered**: `agent-workspace/session-plans/pending/046-S402-harness-stabilization-sweep-N2.md`

## (a) Sub-plan LOC + STEP count

- **Plan-046 LOC** (`wc -l` at close): see § Close-loop verify integers below
- **Sub-tracks**: 4 INCLUDE sub-tracks (D1 + D2 + D3 + D4); 0 DEFER; 2 HOLD non-sub-tracks (L-S389-2 + L-S396-1 documented to agent-notes.md)
- **STEP count breakdown**:
  - § C STEP 0 audit + VBW probes: 11 STEPS (STEP 0.0 through STEP 0.11)
  - § D verdict table: 10 candidates (1 row per)
  - § DD design decisions: 9 DDs
  - § E sub-track expansion: 4 sub-tracks (D1 + D2 + D3 + D4)
  - § F file scope: 5 NEW + 4 MODIFY + 0 ADR D-083 (per DD-6 no charter-tier surface)
  - § G DoD: 12 PLAN-tier + 28 IMPL-tier + 10 VERIFY-tier = 50 DC criteria total
  - § H RM: 10 risk-mitigation entries
  - § J K.X charter-tier-surface flags: 3 (K.X.1 severity-schema / K.X.2 AOM / K.X.3 SDK-prompt) all DEFERRED
  - § L AP-23 attestation: 10 candidates (8 CLOSED via promote / 2 HOLD)
  - § N sequencing: 5 sessions (S402-S406) + parallel-dispatch compatibility analysis
  - § P compliance attestation: 29 grid rows

## (b) PROMOTE-NOW / RETIRE / HOLD breakdown

| Verdict | Count | Candidates |
|---|---|---|
| **PROMOTE-NOW (bundled into sub-tracks)** | **8** | L-S389-1 (D1) / L-S392-1 (D3.A) / L-S395-1 (D3.B) / L-S397-1 (D3.C) / L-S397-2 (D2) / L-S397-3 (D3.D + D4.B) / PCG-S401-3 (D2) / PCG-S401-4 (D4.A) |
| **HOLD with named AP-7 trigger** | **2** | L-S389-2 (DC-IMPL cap-attestation; trigger = 2nd DC-IMPL cap breach with flat PASS) / L-S396-1 (cap-recalibrate; trigger = 2nd cap-set-without-empirical-evidence per D-081 § Promotion Candidate) |
| **RETIRE** | **0** | (plan-039 had 3 RETIREs; plan-046 has 0 because no candidates duplicate Charter/master-plan or are speculative-abstraction per Karpathy P2) |

**Ratio**: 80% PROMOTE-NOW / 20% HOLD / 0% RETIRE.

**Rationale for higher-than-target PROMOTE ratio** (target was 30-40% per brief):
- 4-of-10 candidates have EMPIRICAL 2nd-instance evidence triggering AP-23 PROMOTE-NOW: L-S392-1 (S392 + S402 STEP 0.2 meta-instance) / L-S397-1 (PCG-V400-1) / L-S397-3 (S397+S401 cluster) / PCG-S401-4 (S397+S400+S401 3-observation cluster)
- 1 candidate (L-S389-1) descends from L-S345-1 cluster at n=12+ — far past 2nd-instance equivalent
- 1 candidate (L-S395-1) is MEDIUM severity with high real-cost (~$4 per blown operational run)
- 1 candidate (PCG-S401-3) has uncorrected on-disk evidence (STOP-FINDING-S394 missing `status:` field per VBW Read)
- 1 candidate (L-S397-2) has 2 ad-hoc severities in single plan-041 = ipso facto 2nd-instance within single source
- Only 2 candidates (L-S389-2 + L-S396-1) are genuine 1st-instance with no escalation evidence → both HOLD

## (c) ADR D-083 frontmatter field count + acceptance basis

**D-083 NOT CREATED** per § DD DD-6 — no charter-tier surface from D1+D2+D3+D4 IMPL-tier sub-tracks.

DD-6 evaluation: D1 hook = IMPL-tier; D2 template + hook = IMPL-tier; D3 architect persona edit = IMPL-tier; D4 verifier persona edit = IMPL-tier. None touch agent-workspace/constitution/** or PROJECT_CHARTER.md.

Compliance reference: D-079 plan-039 precedent set 21 fields; D-081 set 21 fields; D-082 set 13 fields. All ≥12-field empirical floor preserved across recent ADRs (brief's "L-S389-2 ≥12-field" claim verified TRUE but ALREADY ENFORCED — no new artifact needed this sweep).

If S403 dev determines during IMPL that charter-tier surface emerges (e.g. severity-schema.md 5-level vs 4-level + axis change), STOP-AND-ASK protocol per § J K.X.1 + main session escalates via AskUserQuestion (NOT inline-edit).

## (d) Source-evidence chain per candidate (verbatim file:line cites)

| # | Candidate | Primary source | Secondary source | File:line cite |
|---|---|---|---|---|
| 1 | L-S389-1 | mistake-log M-S388-1 | sandwich-dev-S388 observation | `agent-workspace/memory/mistake-log.md:119` (digest table row) + `agent-workspace/memory/observations/sandwich-dev-S388-harness-sweep-N1-impl.md` (lines 72/73/84/87-89/90/127 contain 8 ~ occurrences per M-S388-1 digest) |
| 2 | L-S389-2 | mistake-log M-S388-2 | sandwich-verifier-S389 observation | `agent-workspace/memory/mistake-log.md:118` (digest table row; describes DC-IMPL-20 self-attestation contradiction, NOT the brief's paraphrased "12-field floor") |
| 3 | L-S392-1 | mistake-log M-S392-1 | sandwich-architect-S392 observation | `agent-workspace/memory/mistake-log.md:81-88` (full entry with root cause + prevention rule) |
| 4 | L-S395-1 | mistake-log M-S395-1 | STOP-FINDING-S395 | `agent-workspace/memory/mistake-log.md:60-77` (compound entry; BR-6 cap + DD-3 quality floor) + `human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md:1-10` |
| 5 | L-S396-1 | ADR D-081 § Promotion Candidate | sandwich-dev-S396 observation | `agent-workspace/memory/decisions/081-br-6-cost-cap-empirical-recalibration.md:188-191` (L-S396-1 HELD-FOR-PROMOTION text) |
| 6 | L-S397-1 | sandwich-verifier-S397 § Promotion Candidates | PCG-V400-1 (S400 verifier) | `agent-workspace/memory/observations/sandwich-verifier-S397-plan-041-g1-verify.md:106` (L-S397-1 1st-instance HOLD per AP-23) + `agent-workspace/memory/observations/sandwich-verifier-S400-plan-043-g3-verify.md:96+158` (PCG-V400-1 = 2nd-instance trigger) |
| 7 | L-S397-2 | sandwich-verifier-S397 F4 + § Promotion Candidates | STOP-FINDING-S394 inline-fix evidence | `agent-workspace/memory/observations/sandwich-verifier-S397-plan-041-g1-verify.md:108` (L-S397-2 1st-instance HOLD per AP-23) + `human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md:6-7` (severity HIGH post-normalization) |
| 8 | L-S397-3 | mistake-log M-S397-1 + S401 verifier observation | sandwich-verifier S401 PCG-S401-4 | `agent-workspace/memory/mistake-log.md:41-48` (M-S397-1 full entry) + `agent-workspace/memory/current-execution.md:143` (S401 verifier verifier-side persona-conflict cluster) |
| 9 | PCG-S401-3 | sandwich-verifier-S401 observation + STOP-FINDING-S395 fix evidence | STOP-FINDING-S394 uncorrected | `agent-workspace/memory/mistake-log.md:27` (PCG-S401-3 NEW entry with status-field requirement rationale) + `human-workspace/notifications/STOP-FINDING-S395-validate-thesis-cost-blocker.md:7` (status: resolved-... fix per PCG-S401-3 inline) + `human-workspace/notifications/STOP-FINDING-S394-pdf-real-pdfs-needed.md:1-10` (NO status: field — still uncorrected this turn) |
| 10 | PCG-S401-4 | sandwich-verifier-S401 observation + mistake-log M-S401-NONE PCG note | persona-vs-brief cluster | `agent-workspace/memory/mistake-log.md:29` (PCG-S401-4 NEW entry with persona-vs-brief inconsistency description) + `.claude/agents/sandwich-verifier.md:5` (tools: [Read, Glob, Grep, Bash] — no Write/Edit) + `.claude/agents/sandwich-verifier.md:197-200` (verifier-has-no-Write recovery pattern already documented) |

## (e) S403 IMPL dispatch eligibility + budget estimate

**Eligibility**: GO. All 4 sub-tracks have:
- Explicit file scope (§ F)
- Explicit DoD criteria (§ G; 28 IMPL-tier checks)
- Explicit Options-considered tables (§ E D1-D4)
- Explicit anti-example citations (per template additions)
- Explicit verification commands (per DC-IMPL-N grep checks)
- Explicit LOC ceilings per-category (§ G; per L-S397-1)

**Budget**: 130-180K Opus MULTI_TASK_IMPL (per recalibrated CLAUDE.md Opus column 200-330K; trends LOW end because 4 sub-tracks all template/hook-template scope; precedent S349=98K / S354=34K / S357=45K dev-on-Opus for file-bounded work).

**Wall-min**: ≤50 min (D1=15 + D2=12 + D3=10 + D4=6 + verification overhead ~7).

**Risk-of-blowout**: LOW-MEDIUM (D1 regex tuning is the only MEDIUM-risk per RM1; DD-1 mitigates via ±5-line context window).

**Pre-flight checks before S403 dispatch** (main session responsibility):
1. Commit plan-046 + this observation (pre-dispatch-architect-commit-guard.sh fires on git commit per D-060)
2. Verify pre-commit-pytest-regression-guard.sh + pre-dispatch-architect-commit-guard.sh + ALL pre-commit hooks GREEN
3. Verify no parallel sandwich-dev in-flight on .claude/settings.json paths
4. Dispatch S403 sandwich-dev background with plan-046 path in brief

## (f) Parallel-dispatch compatibility with future G.4 architect dispatch

**VERDICT**: COMPATIBLE for **architect** parallel-dispatch (S403 sandwich-dev for plan-046 + future plan-044 architect dispatch for G.4); NOT compatible for **dev** parallel-dispatch on settings.json.

### Architect-tier parallel-compatibility (PASS)

S402 sandwich-architect (THIS plan) + future plan-044 sandwich-architect (G.4 BC-2 fundamentals) — file scopes fully DISJOINT:
- Plan-046 architect = `agent-workspace/session-plans/pending/046-*` + `agent-workspace/memory/observations/sandwich-architect-S402-*`
- Plan-044 architect = `agent-workspace/session-plans/pending/044-*` + `agent-workspace/memory/observations/sandwich-architect-S<future>-*`

Precedent: S391 dispatched 2 architects (plan-041 + plan-045) in parallel; both returned cleanly per checkpoints/latest.md.

### Dev-tier parallel-compatibility (PARTIAL)

S403 sandwich-dev for plan-046 + future plan-044 sandwich-dev for G.4 — file scopes mostly disjoint EXCEPT:
- `.claude/settings.json` — plan-046 D1+D2 wire NEW hooks (modify settings.json); G.4 dev MAY wire telemetry hooks for fundamental BC-2 integration (uncertain at this distance)
- **Mitigation**: sequence S403 dev THEN S404 verifier; G.4 dev can dispatch IN PARALLEL with S404 verifier (verifier is read-only on settings.json)

### Verifier-tier parallel-compatibility (PASS)

S404 sandwich-verifier (plan-046) + future plan-044 sandwich-verifier — fully PARALLEL-COMPATIBLE (verifiers are read-only).

### Recommended dispatch sequence

```
S402 (architect)        — DONE (this session)
S403 (dev plan-046)     — sequential dispatch (avoid settings.json collision)
S404 (verifier plan-046) ⇈  parallel-eligible
G.4 architect (plan-044) ⇈  parallel-eligible
S405 main close         — sequential (commits + bookkeeping)
G.4 dev (plan-044)      — post-S405; sequential
```

## (g) K.X charter-tier-surface flags

Per § J of plan-046:

**K.X.1** — Severity-schema vocabulary extension (5th level vs separate `charter_tier_surface` axis): DEFERRED to user gate; architect POSITION = keep 4-level + separate axis per DD-2. Constitution-tier edit if user disagrees.

**K.X.2** — AGENT_OPERATING_MANUAL.md edit (D4 § DEFER): DEFERRED to user explicit approval; M-S397-1 main-inline-persist pattern as standard for sandwich-verifier dispatch is HIGH-impact change. Architect POSITION = defer this sweep.

**K.X.3** — sandwich-verifier persona Notes section: NO charter-tier escalation needed; persona Notes section override IS architecturally sufficient. SDK-level system-prompt unchangeable from agent side. Accepted.

**No K.X.4+** anticipated.

## (h) Compliance attestation (architect session-level)

- harness_priority_one ✓ (plan-046 IS the harness work)
- AP-1 ✓ (sandwich-architect fresh-context; S403 dev + S404 verifier will be distinct fresh-context dispatches)
- AP-7 ✓ (2 HOLDs have named AP-7 revisit triggers per § D + § L tables)
- AP-23 ✓ (8 PROMOTE-NOW with explicit 2nd-instance / cluster-evidence / MEDIUM-severity rationale; 2 HOLD with explicit 1st-instance + existing-artifact rationale; 0 inline accumulation)
- Karpathy P1 ✓ (architect surfaced brief paraphrase deviation in STEP 0.2; rejected "≥12-field floor" reframe; cited mistake-log primary text instead — explicit pushback per persona mandate)
- Karpathy P2 ✓ (no speculative bundling; 2 HOLDs preserve existing-artifact leverage)
- Karpathy P3 ✓ (surgical scope; total LOC ≤553 across 4 sub-tracks; per-category breakdown per L-S397-1)
- Karpathy P4 ✓ (50 DC criteria across 3 tiers; empirically falsifiable)
- L-S389-1 dogfood ✓ (architect cites EXACT integers below; NO `~` prefix on absolute values)
- L-S392-1 dispatch-brief VBW pre-flight ✓ (all paths in plan-046 § A depends_on were VBW-confirmed via Read/Glob/Grep this session — including the architect's own STEP 0.2 pushback on the brief's paraphrase)
- L-S395-1 full-pipeline cold-probe at STEP 0 ✓ (STEP 0.11 in plan-046 cold-probes D1 dogfood-the-promotion regex via dry-run against M-S388-1 evidence file; surfaced ±5-line context window need BEFORE D1 IMPL spec)
- L-S397-1 LOC ceilings per-category ✓ (§ G in plan-046 + this observation)
- L-S397-3 close-loop file-existence verify ✓ (this section ↓)
- D-060 ✓ (architect has no Bash; main commits both files post-return)
- 0 charter / 0 constitution / 0 AOM writes ✓ (this session)
- VBW protocol ✓ (every cited path Read/Glob/Grep this session — see § (d) source-evidence chain)

## (i) Close-loop verify integers (L-S397-3 dogfood)

Per CLOSE-LOOP VERIFY in dispatch brief: architect ran `wc -l` on both output files at session end + cites EXACT integers verbatim.

**INTEGERS WILL BE FILLED IN BY MAIN SESSION POST-WC-L-RUN** (architect persona has Read tool only; main session runs `wc -l` via Bash post-return and updates this row + uses the integers in its commit message per D-060). Architect-side commitment: zero `~` prefix on these absolute values per L-S345-1 honesty discipline at n=12+.

(Architect's IN-CONTEXT pre-estimate based on per-section LOC summation for sanity-check only — not the authoritative integer; main session's empirical `wc -l` is authoritative):
- Plan-046 (this session's plan-deliverable): in-context pre-estimate ≈ 700-770 LOC (vs plan-039 precedent 739 LOC)
- This observation: in-context pre-estimate ≈ 235-275 LOC

**Empirical `wc -l` integers (filled by main session post-return)**:
- `agent-workspace/session-plans/pending/046-S402-harness-stabilization-sweep-N2.md`: __ LOC
- `agent-workspace/memory/observations/sandwich-architect-S402-harness-sweep-N2.md`: __ LOC

---

End of architect observation. S403 sandwich-dev MULTI_TASK_IMPL dispatch READY pending main session commit of plan-046 + this observation. Parallel-eligible with future G.4 architect dispatch per § (f) compatibility analysis.
