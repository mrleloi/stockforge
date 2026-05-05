---
name: empirical-probe-first
description: Probe ALL viable strategies in a multi-option ladder BEFORE committing to one. Use when a session-plan / decision-ADR / spec presents ≥3 strategy options (e.g. "Strategy A1/A2/A3" or "alternative B/C/D") and the recommended option's source-evidence may be stale. Outputs a probe matrix per strategy + commit decision with empirical citation. Pairs with `vendor-api-probe.sh` (deterministic detection layer; SessionStart hook) and `decompose-work` (deterministic-vs-LLM split per probe). Charter promotion target — codifies L-S32-1 doctrine surfaced at S32 Track A pivot (master-plan recommended A2 vnstock alternate; empirical probe rejected A1+A2; A3 SSI direct httpx adopted instead).
allowed-tools: [Read, Glob, Grep, Bash, Write]
---

# Skill: empirical-probe-first

## Purpose

When a master-plan / ADR / spec lists multiple competing strategies and recommends one, **probe ALL viable options empirically before commit** rather than trusting the recommendation. The recommendation's source-evidence (vendor docs, blog posts, prior session notes) may be stale, especially for vendor APIs that drift silently between releases.

Surfaced at S32 (Track A R2 closure):
- Master-plan 005 § Track A recommended A2 (vnstock 4.0.2 alternate-source backends).
- Empirical probe revealed A1 (TCBS endpoints) all 404 + A2 (vnstock Quote effectively VCI-only — TCBS/DNSE/SSI/FMARKET deprecated as Quote sources, MSN ConnectionError).
- A3 (SSI iBoard direct httpx adapter) — not initially recommended — was the only viable path. Adopted; R2 CLOSED with 100% VN30 coverage.

Without empirical probe, the session would have committed to A2 and shipped a degraded SINGLE_SOURCE pipeline.

This skill encodes the procedural discipline; companion deterministic detection lives in `scripts/hooks/vendor-api-probe.sh` (SessionStart hook; advisory stderr when ladder count ≥3 detected in active plan).

## When to Use

- Active session-plan / ADR / spec lists ≥3 strategy options for ONE problem (Strategy A1/A2/A3, alternative B/C/D, ladder etc.)
- Master-plan recommendation involves vendor API or library version that has shipped ≥1 release since the recommendation was authored
- Predecessor session relied on the same library and recorded surface-area assumptions (extends L-S28-1 vendor-API drift family)
- About to author production adapter / integration code and the choice is reversible only at high cost
- `vendor-api-probe.sh` SessionStart hook emitted the "multi-strategy ladder detected" advisory

## When NOT to Use

- Only one strategy proposed (no ladder)
- Strategy is pure-stdlib (no vendor surface to drift)
- Probe cost > likely savings (e.g., 5-min probe to dodge 30-second commit cost)
- Task already mid-IMPL and rolling back probe-then-pick would cost more than committing

## Process

1. **Enumerate** — list every strategy option from the source artifact verbatim. Quote the recommendation phrase.
2. **Pre-flight VBW** (per L-S30-1) — `Glob` / `Read` every file the recommendation claims exists.
3. **Per-strategy probe** — for each option run minimal viability check:
   - Importability (`python -c "import X; print(X.__version__)"`)
   - Surface-area sample call against ONE representative input (e.g., 1 ticker × 5 days for a market-data adapter)
   - Capture exit code + stderr + first 200 chars of stdout
4. **Build probe matrix** — write `data/<track>-probe-<vendor>.json` with one row per strategy:
   ```json
   {"strategy": "A2", "verdict": "REJECT", "evidence": "vnstock.Quote returns VCI-only post-4.0.2; TCBS/DNSE/SSI/FMARKET deprecated", "probed_at": "2026-04-30T14:22:00+07:00"}
   ```
5. **Pick** — first strategy with verdict=PASS; if multiple PASS, prefer simplest. If all REJECT → escalate to SCOPE-tier user-gate (do not silently degrade).
6. **Document deviation** — if pick differs from master-plan recommendation, author IMPL-tier ADR (`agent-workspace/memory/decisions/NNN-...md`) with `source_evidence` citing the probe matrix path. State explicitly: "master-plan recommended X; empirical probe rejected X; adopted Y per probe matrix".
7. **Update lesson log** — if probe revealed stale source-evidence, append to `agent-notes.md` under "Vendor API drift family (L-S28-1 / L-S32-1)" cluster.

## Outputs

| Artifact | Path | Required? |
|---|---|---|
| Probe matrix (machine-readable) | `data/<track>-probe-<vendor>.json` | Yes |
| Coverage report (human-readable) | `data/<track>-coverage-S{N}.md` | Yes if ladder picked involves vendor |
| IMPL-tier ADR | `agent-workspace/memory/decisions/NNN-...md` | Yes if pick differs from recommendation |
| SCOPE-tier escalation | AskUserQuestion (charter-tier split rule applies) | Only if all options REJECT |

## Pre-Flight Checklist (binding when applies)

- [ ] Active session-plan path resolved via `current-execution.md` (not hardcoded from memory)
- [ ] Strategy enumeration is verbatim from source — no agent paraphrase
- [ ] Each probe captured stderr (not just stdout) — silent failures are common with vendor SDKs
- [ ] Probe matrix written BEFORE pick decision — order matters for audit trail
- [ ] If pick differs from recommendation, IMPL-tier ADR cites probe matrix path in `source_evidence`

## Anti-Patterns

| Anti-pattern | Why bad | Correction |
|---|---|---|
| Trust the master-plan recommendation without probe | Vendor APIs drift silently; predecessor session's evidence may be stale | Always probe when ladder ≥3 |
| Probe only the recommended option | Defeats the purpose; can't compare | Probe ALL viable options before pick |
| Probe but pick recommendation anyway "to honor the plan" | Calibration drift; loses the empirical signal | Document the deviation as IMPL-tier ADR |
| Silently degrade to last-viable when all REJECT | Hides scope reduction from human; violates UP-06 NO-Silent-Default | Escalate via AskUserQuestion SCOPE-tier |
| Probe matrix fields opaque | Future audit cannot reconstruct decision | Use `{strategy, verdict, evidence, probed_at}` schema |

## Pairs With

- `scripts/hooks/vendor-api-probe.sh` — deterministic SessionStart hook detects ladder + emits advisory
- `decompose-work` skill — splits each probe into deterministic (importability check) vs LLM (verdict synthesis)
- `try-n-approaches` skill — Karpathy outer-loop framing; this skill is the strategy-pick lens within an approach
- `agent-workspace/memory/decisions/012-track-A-source-pivot.md` — exemplar ADR following this protocol (S32 origin)
- `agent-workspace/memory/decisions/013-S35-meta-loop-recovery-promote-routing.md` — S35 promote-routing decision that surfaced this skill as the next-tier promotion target

## Provenance

- **Origin**: L-S32-1 ("Empirical probe before strategy commit"; surfaced 2026-04-30 at S32 Track A R2 closure)
- **Hook companion shipped**: S35 META_LOOP recovery (`scripts/hooks/vendor-api-probe.sh`)
- **Skill promotion** (this file): Phase 2 close ceremony S43e (continuation 3); Phase 3 prereq #3 from `agent-workspace/memory/post-mortems/2026-05-04-phase-2-retrospective.md`
- **Per Q-E3 promotion priority**: hook FIRST (DONE S35) → skill SECOND (THIS) → charter LAST (deferred unless ≥3 violations recur Phase 3)
- **Cluster siblings**: L-S28-1 vendor-API drift family (vnstock 4.0.2 surface change); extends to KOL/news scrapers in Phase 3 (BeautifulSoup selector drift, RSS schema drift, etc.)
