---
plan_id: 018-S331-wave-0-W0-3-4-5-bundle
target_session: S332
type: MULTI_TASK_IMPL
budget: 150-200K (proposed)
phase: B (Wave 0 substrate finish — 2nd Phase B IMPL after W0-2.1)
track: Wave 0 W0-3 + W0-4 + W0-5 (bundled)
parent_master_plan: agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md § 4.13 + § 4.15 + § 5.1 + § 6.2
predecessor: 017-S329-wave-0-W0-2.1-python-determinism-fixes (DONE-VERIFIED S330 PASS / MERGE-ELIGIBLE 2026-05-15)
successor: TBD-S333-Phase-C-Theme-G-constitution-write (per master plan § 6.3; conditional on Phase A I-S1-1 confirm)
architect: S331 sandwich-architect (background; this plan)
dispatched_by: S328-main turn (parent main session orchestrating Phase B PLAN-IMPL-VERIFY sandwich)
authored: 2026-05-15
authoring_agent: Claude Opus 4.7 (sandwich-architect subagent)
executing_agent: sandwich-dev (background dispatch S332+; fresh-context; AP-1 verifier in S33N+2)
status: pending-execution

depends_on:
  - "D-061 (Wave-1 integration ratification — ACCEPTED 2026-05-15T15:30+07:00 blanket-A; § Decision item 8 lists W0-3/4/5 ports as 'empirically-confirmed citation chains'; W0-5 path-safety quad EXPANDED to 5-invariant via Q-INT-bis SUPPLEMENT § L/N coverage of UNC cross-cutting)"
  - "D-059 (Python determinism contract — ACCEPTED; precedent template for hook+firing-test+ADR triad shape used by all 3 sub-tracks)"
  - "D-060 (commit-policy-agent-may-commit — operational gate for the S332 dev commit boundary)"
  - "Charter v1.1 Principle 11 ('Harness must self-verify firing, not self-attest existence') — mandates companion firing-test per hook; binding for all 3 new hooks below"
  - "observations/master-planner-A-13-deepdive-TradingAgents.md § 0 (W0-3 + W0-4 source evidence — `tradingagents/agents/utils/memory.py:13-14, :109-163, :161-163, :215-217` + test `tests/test_memory_log.py:426-437`; license Apache-2.0)"
  - "observations/master-planner-A-15-deepdive-Vibe-Trading.md § 0 (W0-5 5-invariant source evidence — `agent/src/tools/path_utils.py:1-213` 4 public helpers + `_rejects_unc:27-30` cross-cutting; tests `agent/tests/test_path_safety.py:1-136`; license MIT)"
  - "observations/master-planner-A-10-deepdive-nautilus_trader.md § 0.3 + § 0.4 (FSM + Clock lifecycle precedent for W0-3 hook design — DST-doctrine 5-rule enforcement script shape at `C:/htdocs/research/nautilus_trader/.pre-commit-hooks/check_dst_conventions.sh`)"
  - "agent-workspace/session-plans/completed/014-S315-wave-0-W0-2-python-determinism-banned-patterns.md (template shape — DST-style hook + ≥10 TC firing-test + ADR + settings wire + DoD; closest-shape predecessor)"
  - "agent-workspace/session-plans/completed/017-S329-wave-0-W0-2.1-python-determinism-fixes.md (DC1..DC13 DoD-richness template + STEP 0 pre-flight pattern + Coordination + Compliance Attestation block)"
  - "scripts/hooks/python-determinism-check.sh (W0-2 hook — reference implementation for hook structure: idempotency marker, dual PostToolUse/Stop mode, severity-classifier integration, hour-bucket cache, RC=0 best-effort)"
  - "scripts/hooks/firing-tests/python-determinism-check-fire-test.sh (W0-2 firing-test — reference shape for ≥12 TC pattern with positive + negative + edge cases)"
  - "agent-workspace/constitution/harness-health-protocol.md § HH-10 (every priority-1 hook in scripts/hooks/ has companion firing-test — 3 new hooks must each ship with firing-test)"
  - "agent-workspace/constitution/severity-schema.md (Stop-chain severity routing — violations land in `.session-hooks.log` for severity-classifier.sh consumption)"

binding_decisions:
  - "Charter v1.1 Principle 11 (companion firing-test mandate)"
  - "Charter v1.1 Principle 8 (calibration over confidence — extends to 'atomicity over best-effort write' per W0-3 substrate)"
  - "I-S1 (NO LLM math) — hooks are deterministic regex/grep; no LLM judgment"
  - "I-S2 (every claim sourced) — fix-recipe citations are file:line specific to deep-dives + upstream repos"
  - "I-S34 (public sources only + ToS compliance) — N/A this bundle (no scraping involved)"
  - "D-061 § Decision item 8 — W0-3/4/5 ports already cited from empirical Phase A evidence"
  - "D-060 — agent MAY git commit (NOT push); S332 dev decides commit boundary per § Coordination"

hard_rules_acknowledged:
  - "no production code in THIS plan-session (CLAUDE.md § Session Types — never mix PLAN + IMPL)"
  - "no commits in THIS plan-session (sandwich-architect subagent instructions; no Bash tool granted)"
  - "no charter / no constitution / no human-workspace writes in THIS plan-session"
  - "no master-plan edits — D-061 ACCEPTED already ratifies the W0-3/4/5 source-evidence chain"
  - "every plan claim cites the source file:line (per I-S2 + AOM)"
  - "actual files read via Read tool, not from memory (VBW protocol)"
  - "W0-5 is FIVE invariants not four (per D-061 + A-15 § 0 empirical confirm — UNC reject is cross-cutting fifth invariant; do NOT regress to master-plan § 4.15 'quad' wording)"
---

# S33N+1 — Wave 0 W0-3 + W0-4 + W0-5 Bundle (Substrate Finish)

## Goal

Ship the final 3 Wave 0 substrate sub-tracks as one bundled MULTI_TASK_IMPL session:

1. **W0-3 — Atomic temp-file-replace doctrine** (`scripts/hooks/atomic-write-check.sh`):
   Ban un-protected in-place write patterns in production code that's writing append-only
   audit/state artifacts. Detect `open(...,'w'/'a')` + `Path.write_text(...)` writes in
   `packages/**/*.py` + `apps/**/*.py` that lack the sibling-tmp + `os.replace()` idiom.
   Source: TradingAgents `tradingagents/agents/utils/memory.py:109-163, :161-163, :215-217`
   (Apache-2.0; per `observations/master-planner-A-13-deepdive-TradingAgents.md § 0`).

2. **W0-4 — HTML-comment separator pattern** (`scripts/hooks/html-separator-check.sh`):
   For markdown files in append-only entry-segmented memory zones
   (`agent-workspace/memory/mistake-log.md`, `agent-notes.md`, `thesis-log/*.md`,
   the future memory log files W0-3 covers), enforce that entry-blocks are separated by
   `\n\n<!-- ENTRY_END -->\n\n` (forgery-proof — HTML markup the LLM cannot emit inside
   markdown prose). Source: TradingAgents `tradingagents/agents/utils/memory.py:13-14`
   (Apache-2.0; per `observations/master-planner-A-13-deepdive-TradingAgents.md § 0`
   "W0-4 — HTML-comment separator pattern" subsection).

3. **W0-5 — 5-invariant path-safety** (`scripts/hooks/path-safety-check.sh`):
   Enforce 5 path-safety invariants for any `Path(...)` / `os.path.*` / `open(...)` call site
   in production layers. Quad = 4 public helpers (sandbox / user-supplied / document / run-dir)
   + UNC reject cross-cutting = 5th invariant. Source:
   Vibe-Trading `agent/src/tools/path_utils.py:1-213` (MIT; per
   `observations/master-planner-A-15-deepdive-Vibe-Trading.md § 0`).

Each sub-track ships: hook (~150-200 LOC bash) + firing-test (≥12 TC for W0-3, ≥10 TC for W0-4,
≥15 TC for W0-5 = 5 invariants × ≥3 cases each) + ADR (PROPOSED at IMPL tier; ≥3 source_evidence
cites per D-061 standard, with target ≥6 cites due to multi-repo provenance) + settings.json
wire-up + DoD attestation.

**Out-of-scope cleanup** of existing production violations is deferred to follow-up
W0-3.1 / W0-4.1 / W0-5.1 cleanup sessions (per W0-2 → W0-2.1 split pattern proven safe at
S315 + S329; see § "Production-cleanup deferral" below).

## Context — why bundled

Three reasons to bundle W0-3 + W0-4 + W0-5 into ONE plan-session and ONE IMPL session:

1. **Architectural symmetry**: all three are *banned-pattern detectors on production Python +
   markdown*. They share the W0-2 hook structure (`python-determinism-check.sh`) as template:
   Stop-mode full-tree audit + optional PostToolUse single-file scan + hour-bucket idempotency
   marker + RC=0 best-effort + severity-classifier-fed `.session-hooks.log` emission.
   Bundling lets the dev write one hook by careful adaptation and copy-with-discipline for
   the other two (per L-S322-2 short-circuit-before-grep — the second + third hook benefit
   from the lessons learned writing the first).

2. **Token economy**: A separate PLAN + IMPL + VERIFY sandwich per sub-track would be
   3× ~50K plan + 3× ~120K impl + 3× ~40K verify = ~630K total. The bundled shape is
   1× 50-80K plan (this) + 1× 150-200K impl + 1× 30-60K verify = ~280-340K total.
   Savings: ~290-350K tokens (~46-50%). Within the master-plan § 6.2 envelope guidance for
   S332 ("100-200K — MULTI_TASK_IMPL if scope warrants per R-2 splits-if->10-tasks").
   Counting tasks: 3 hooks × (write + lint + wire + DoD) + 3 firing-tests × (author + run)
   + 3 ADRs = 21 discrete tasks. R-2 "splits-if->10-tasks" rule technically triggers; the
   counter-argument is that each task is small (~50-100 LOC bash for hook; ~50-80 LOC for
   firing-test; ~150-200 LOC ADR markdown) and shares the template. **Architect verdict:
   bundle is correct; flag as risk-RM2 below for the dev to split if budget tracking shows
   drift past 175K mid-session**.

3. **Phase B closure efficiency**: After this bundle + S33N+2 VERIFY PASS, Wave 0 substrate
   = 5 of 5 sub-tracks complete (W0-1 / W0-1b / W0-2 / W0-2.1 / **W0-3+4+5**). The next
   master-plan beat is Phase C (Theme G constitution write — S333) which is an unrelated
   workstream. Closing Wave 0 cleanly in one IMPL session leaves a stable substrate baseline
   before opening any product-layer work.

**Lineage**:
- D-061 ACCEPTED 2026-05-15T15:30+07:00 blanket-A on Q-INT-2026-05-5..8 unblocked Phase B.
- S328 PLAN authored plan 017 (W0-2.1). S329 IMPL shipped W0-2.1 (commits `510f533` + `82b3dca`).
  S330 VERIFY PASS / MERGE-ELIGIBLE (all DC1-DC13 confirmed at HEAD).
- S331 (this turn) = Phase B's 2nd PLAN session, bundling W0-3 + W0-4 + W0-5 per master plan
  § 6.2 row "S331 | PLAN (sandwich-architect) | 50-80K | Bundle W0-3 + W0-4 + W0-5 plans …".
- S33N+1 (dispatched after this plan ratifies) = IMPL.
- S33N+2 = VERIFY (AP-1 fresh-context).

---

## STEP 0 — Mandatory pre-flight (do this BEFORE writing any hook)

The implementing session (S33N+1) MUST run these first and write the results into the session
log. This plan was authored by a sandwich-architect subagent that has Read/Glob/Grep/Write but
NO Bash — so STEP 0 is the empirical anchor that grounds the plan recipes against the live
filesystem.

**STOP-IF-AMBIGUOUS clause**: if any STEP 0 expected count/file/pattern **differs from the
inventory below**, STOP and escalate to main via observation file +
`human-workspace/notifications/<slug>-ALERT.md`. Do NOT write any hook in a divergent state.

1. **Verify Wave 0 W0-2.1 close state** — confirm W0-2.1 truly DONE before adding 3 more hooks:
   ```bash
   grep -n "W0-2.1: Production cleanup" agent-workspace/memory/current-execution.md
   ls agent-workspace/session-plans/completed/017-S329-*
   bash scripts/hooks/python-determinism-check.sh </dev/null
   cat human-workspace/notifications/python-determinism-warn.md  # expected: missing OR status: RESOLVED
   ```
   Expected: W0-2.1 row = SHIPPED; plan 017 in `completed/`; determinism scan = 0 violations.
   If any differ → STOP per STOP-IF-AMBIGUOUS.

2. **Verify upstream repo presence + license headers** — the 3 new hooks port from 2 repos:
   ```bash
   ls C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py
   head -1 C:/htdocs/research/TradingAgents/LICENSE  # expected: "Apache License Version 2.0..."
   ls C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py
   head -1 C:/htdocs/research/Vibe-Trading/LICENSE   # expected: "MIT License" — copyright 2026 Vibe-Trading Contributors
   ```
   If repos absent or licenses changed → STOP. (License compatibility per D-061 § Decision
   item 1: Apache + MIT → LOC port permitted with attribution per-file header.)

3. **Verify the source-evidence file:line citations** still match the deep-dives:
   ```bash
   sed -n '13,14p;109,114p;161,163p;215,217p' C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py
   sed -n '27,30p;33,54p;75,87p;90,99p;158,171p;174,187p;190,213p' C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py
   ```
   Expected output matches the quoted text in `master-planner-A-13-deepdive-TradingAgents.md § 0`
   + `master-planner-A-15-deepdive-Vibe-Trading.md § 0` respectively. If patterns shifted
   (upstream commits since 2026-05-15) → STOP and update plan recipes before proceeding.

4. **Live-audit pre-existing violation counts** — informs whether W0-3.1 / W0-4.1 / W0-5.1
   cleanup is needed (these are OUT-OF-SCOPE of this bundle but the count must be recorded):
   ```bash
   # W0-3 candidates (in-place writes that are NOT in test_*.py or fixtures)
   grep -rn -E '(\.write_text\(|\.write\(|open\([^)]*[\"\x27](w|a)[\"\x27])' packages/ apps/ \
     | grep -v 'test_' | grep -v '/tests/' | wc -l
   # W0-4 candidates: markdown files in memory/* that should have ENTRY_END but don't
   grep -L '<!-- ENTRY_END -->' agent-workspace/memory/mistake-log.md agent-workspace/memory/agent-notes.md 2>/dev/null
   # W0-5 candidates: absolute paths in domain layer; `..` traversal; UNC; writes outside designated zones
   grep -rn -E '(Path\(.*/.*\)|os\.path\.|open\()' packages/domain/ | wc -l   # expected ~0 (domain pure)
   grep -rn -E '(\.\./|\\\\\\\\[a-zA-Z]|//[a-zA-Z]+/)' packages/ apps/ | wc -l
   ```
   Expected (from plan-authoring grep at 2026-05-15):
   - W0-3 candidates in production: ~1 confirmed (`packages/infrastructure/influence/llm_recommendation_extractor.py:466`
     `fname.write_text(payload, ...)` — non-critical persisted raw response; may or may not
     warrant atomic write per its own threat model — dev assesses).
   - W0-4 candidates: 0-2 (per plan-authoring grep, `<!-- ENTRY_END -->` currently appears in
     4 files all in `agent-workspace/research/` + 1 deep-dive observation file; `mistake-log.md`
     + `agent-notes.md` do NOT yet use the separator — these are the cleanup-1 candidates).
   - W0-5 candidates: ~0 in `packages/domain/` (good — domain layer pure per plan-authoring
     probe `Grep os.path.|Path(|pathlib` in `packages/domain/` = 0 matches); some count in
     `packages/infrastructure/` + `apps/` is expected (legitimate filesystem code in infrastructure).
   If counts wildly diverge → STOP and revise scope before writing hook detection regexes.

5. **Verify next-ADR number is still D-062** (no concurrent ADR writes since plan-authoring):
   ```bash
   ls agent-workspace/memory/decisions/ | grep -E '^[0-9]{3}-' | sort | tail -3
   ```
   Expected: latest landed = `061-wave-1-integration-ratification.md`. If `062-*` already
   exists → main session created an ADR in between; renumber this bundle's ADRs to next
   available (likely 063+064+065).

6. **Read upstream source files completely** (Read tool, full file) before authoring hook
   detector regexes:
   - `C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py` (~301 LOC)
   - `C:/htdocs/research/TradingAgents/tests/test_memory_log.py` (lines 426-437 for atomic test)
   - `C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py` (~213 LOC)
   - `C:/htdocs/research/Vibe-Trading/agent/tests/test_path_safety.py` (~136 LOC)
   Per VBW protocol: verify the actual current state of upstream, not the plan's stale snapshot.

7. **Baseline regression floors** — establish before-state:
   ```bash
   bash scripts/hooks/firing-tests/run-all.sh 2>&1 | tail -5   # expected: 103/103 PASS or similar
   bash scripts/hooks/bash-hook-lint.sh 2>&1 | tail -5         # expected: 0 violations
   python -m pytest packages/ apps/ -q 2>&1 | tail -3           # expected: all green
   ```
   Write the pre-IMPL pass/fail counts into the session log. The 3 new hooks + firing-tests
   must add to (not regress) these baselines.

---

## Sub-track 1 — W0-3 (Atomic Temp-File-Replace Doctrine)

### Pattern statement

**Banned**: production Python code that writes a state/audit/persistence file via raw
`open(path, 'w')...write()` OR `Path(path).write_text(...)` OR `path.write_bytes(...)` WHEN
the file extension/path indicates an append-only or state-snapshot artifact (`.json`, `.tsv`,
`.tsvl`, `.jsonl`, `.md` in memory zones, `.db`-adjacent state files, `.log`, `.csv` outputs).

**Required**: same call site must use the sibling-tmp + atomic-replace idiom:
```python
tmp_path = path.with_suffix(path.suffix + ".tmp")  # OR path.with_suffix(".tmp") if convention permits
tmp_path.write_text(new_text, encoding="utf-8")    # OR write_bytes
tmp_path.replace(path)                              # atomic on POSIX; near-atomic Windows ≥10 NTFS
```

Source: `master-planner-A-13-deepdive-TradingAgents.md § 0` "W0-3 — Atomic temp-file-replace
doctrine" — direct quotes from TradingAgents `tradingagents/agents/utils/memory.py:109-114`
docstring "Uses a temp-file + os.replace() so a crash mid-write never corrupts the log."
Concrete idiom at `memory.py:161-163` + `:215-217`.

### Hook design

**Path**: `scripts/hooks/atomic-write-check.sh` (NEW; target ~180-220 LOC bash).

**Modes** (mirror `python-determinism-check.sh` dual-mode shape):
- **PostToolUse** on `Edit|Write|MultiEdit` for `.py` files — scans only the edited file.
- **Stop** — full-tree audit of `packages/**/*.py` + `apps/**/*.py`.

**Detection rules** (regex-based; per L-S322-2 short-circuit before deep grep):

| # | Rule | Regex (POSIX ERE) | Severity | Allow-list |
|---|------|-------------------|----------|------------|
| AW-R1 | Bare `open(path, 'w'/'a'/'wb'/'ab')` followed within 5 lines by `.write(`, where path-arg expression does NOT contain `.tmp` | `open\([^)]*[\"\x27](w|a|wb|ab)[\"\x27]` + 5-line lookhead context grep | ERR | `if __name__ == "__main__":` blocks; `test_*.py` + `**/tests/**/*.py`; files where the call is followed by `os.replace(` / `os.rename(` / `.replace(` within 10 lines on same target |
| AW-R2 | `Path(...).write_text(...)` / `.write_bytes(...)` on a path expression whose suffix is in the AUDITED set (`.json`, `.jsonl`, `.tsv`, `.tsvl`, `.md`, `.log`, `.csv`) AND the path expression does NOT end in `.tmp` | `\.(write_text|write_bytes)\(` + path-expression suffix grep | ERR | same as AW-R1 + a file-level inline marker `# atomic-write-ok: rationale` (per L-S322-1 short-circuit pattern from W0-2 hook) |
| AW-R3 | `pickle.dump(obj, open(path, 'wb'))` or `json.dump(obj, open(path, 'w'))` — combined open+dump anti-pattern | `(json\|pickle)\.dump\([^,]+,\s*open\(` | ERR | same as AW-R1 |
| AW-R4 (WARN) | `.write_text(` on a path that exists outside the AUDITED set BUT inside `outputs/`, `logs/`, `state/`, `cache/`, `data/` directories (heuristic: persistence zone) | path-expression + directory-context grep | WARN | same as above |

**Severity emission**: violations land in `.session-hooks.log` as `severity=HIGH` (ERR) /
`severity=MEDIUM` (WARN) — consumed by `severity-classifier.sh`. Per `severity-schema.md` Layer
4 (code-quality violations).

**RC=0 always** (best-effort; never blocks Stop chain — same posture as W0-2 hook).

**Idempotency**: hour-bucket marker per file path under `agent-workspace/memory/.aw-marker-*`
(parallel to `.pydet-marker-*` for W0-2). Cleaned by find-+mmin+delete in hook itself.

**Notification**: aggregated into `human-workspace/notifications/atomic-write-warn.md` with
`status: pending` frontmatter on first detection of >0 violations; severity-classifier picks up.
Idempotent re-write (S318 pattern) — overwrite the same fixed name on each run; do NOT generate
NNN-timestamped fresh files (per L-S320-1 + plan 016 close).

### Allow-list zones (justification per zone)

| Zone | Why allowed |
|------|-------------|
| `**/test_*.py` + `**/tests/**/*.py` | Test code is allowed to write fixtures + scratch state non-atomically — failure mid-test = test failure, no audit corruption (per W0-2 R2 precedent: tests may use unsafe RNG). |
| `if __name__ == "__main__":` blocks | Script-bottoms are dev-only entry points; same exception as W0-2 R2. |
| Files with `# atomic-write-ok: <rationale>` inline marker on the offending line | Allows manual opt-out with a written rationale per L-S322-1 in-place pattern — same as `severity-classifier.sh:182-186` short-circuit precedent. Marker must include rationale text (non-empty) — empty marker fails. |
| `scripts/` (bash + scratch Python tooling) | Hook + script code is dev-tooling, not production audit-stream code. |
| `examples/`, `docs/`, `*.py` in repo root | Sample/demo code. |

### Firing-test design

**Path**: `scripts/hooks/firing-tests/atomic-write-check-fire-test.sh` (NEW; target ~250-300
LOC bash; ≥12 TC per architect-proposed minimum, mirroring W0-2's 12-TC count).

**SPAWN-CONTEXT**: `positional-arg` (the hook reads file paths from stdin or scans `packages/`
+ `apps/` via find; firing-test stages temp files in a sandbox dir).

**Test cases** (≥12 TC architect-proposed; dev may add edge cases up to ~18):

| TC | Pattern | Expected |
|---:|---------|----------|
| TC1 | `open("/path/state.json", "w")\nf.write(payload)` in production file | AW-R1 fires (ERR) |
| TC2 | `tmp = open("/path/state.json.tmp", "w"); ...; os.replace("/path/state.json.tmp", "/path/state.json")` | no fire |
| TC3 | `Path("/path/log.md").write_text(payload)` in `packages/infrastructure/` | AW-R2 fires (ERR) |
| TC4 | `tmp = Path("/path/log.md.tmp"); tmp.write_text(payload); tmp.replace("/path/log.md")` | no fire |
| TC5 | `open("/path/audit.jsonl", "a")\nf.write(record + "\\n")` (append mode) in production | AW-R1 fires (ERR) — append is also non-atomic |
| TC6 | `random.random()` test → already covered by W0-2 — sanity: this firing-test does NOT cross-fire on W0-2 patterns | no fire (W0-2 patterns untouched) |
| TC7 | `with open(...,'w') as f: f.write(...)` inside `if __name__ == "__main__":` | no fire (allow-list) |
| TC8 | `Path(...).write_text(...)` inside `test_my_feature.py` | no fire (test path allow-list) |
| TC9 | `Path(...).write_text(...)` with inline comment `# atomic-write-ok: log file rotation handled externally` on same line | no fire (rationale marker) |
| TC10 | `json.dump(obj, open("/path/state.json", "w"))` (combined dump+open) | AW-R3 fires (ERR) |
| TC11 | `Path("/path/output.csv").write_text(payload)` in `apps/cli/` (persistence zone WARN) | AW-R4 fires (WARN) |
| TC12 | Legitimate code: `Path("/path/state.json.tmp").write_text(p); Path("/path/state.json.tmp").replace("/path/state.json")` | no fire |
| TC13 (edge) | Empty Python file (0 bytes) | no fire (degenerate) |
| TC14 (edge) | File with no write operations at all | no fire (no signal) |
| TC15 (regression-floor) | The hook fired on a non-existent file path | RC=0 + no false fire |

**Firing-test exit criteria**: ALL 12+ TC PASS; hook RC=0 in every test; emitted log lines
match the expected ERR/WARN/no-fire pattern per `grep -c` on `.session-hooks.log` synthetic
fixture.

### ADR D-062 — Atomic Write Doctrine

**Path**: `agent-workspace/memory/decisions/062-atomic-write-doctrine.md` (NEW; ADR-tier IMPL).

**Required source_evidence cites** (target ≥6 per D-061 standard):

1. `observations/master-planner-A-13-deepdive-TradingAgents.md § 0` (W0-3 source confirmation;
   anchor for doctrine).
2. `C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:109-114` (docstring
   quote).
3. `C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:161-163` (concrete
   idiom: `tmp_path = ...; write_text; tmp_path.replace(...)`).
4. `C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:215-217` (idiom
   repetition in `batch_update_with_outcomes` — proves intentional).
5. `C:/htdocs/research/TradingAgents/tests/test_memory_log.py:426-437` (`test_update_atomic_write`
   — proves stale-tmp survival semantic).
6. `agent-workspace/constitution/financial-data-protocol.md` — must read at S33N+1 time to
   cite the I-S2 (every claim sourced) extension to atomic-write rule. (Likely cites the
   "data integrity" rule.)
7. `D-059` — sibling-doctrine ADR for hook+firing-test+ADR template + Charter Principle 11
   alignment.

**Content sections** (mirror `D-059` ADR shape):
- Context (Wave 0 substrate finish; W0-2 paved the pattern; W0-3 closes a real risk).
- What is guaranteed (every memory-zone write survives crash mid-write).
- What is platform-scoped (Windows NTFS near-atomic note from A-13 § 0).
- 3-4 banned patterns (AW-R1..R4) with rationale per rule.
- Reference to bash hook + firing-test paths.
- Compliance enforcement: WARN-only first 5 sessions; promote to BLOCKING after clean run
  (mirror D-059 ratchet at lines 218-224).
- Allowed-contexts clause (test files + main + inline marker).
- Charter alignment: Principle 11 (firing-test mandate satisfied).
- Attribution: "Pattern adapted from TradingAgents v0.2.4 (Tauric Research, Apache-2.0). See
  `tradingagents/agents/utils/memory.py:109-217`."

**Cool-down**: NONE (IMPL tier; per `severity-schema.md` — no charter cool-down for IMPL ADRs).

### settings.json wire-up

Add `atomic-write-check.sh` to TWO chains in `.claude/settings.json`:

1. **PostToolUse matcher** for `Edit|Write|MultiEdit` (where W0-2 lives at line ~395 area —
   see existing Edit-matcher block; the dev confirms exact insertion point at STEP 0). Hook
   reads stdin JSON for `file_path`, scans single edited file if Python.

2. **Stop chain** (where W0-2 lives at line 428 in the canonical Stop block — verified at
   plan-authoring time). Insert AFTER `python-determinism-check.sh` (line 428) and BEFORE
   `observation-orphan-detector.sh` (line 432). Stop-chain ordering rationale: severity-
   classifier MUST run AFTER both deterministic detectors (W0-2 + new W0-3) so violations
   from both feed into the same severity rollup.

**Coordination**: dev makes a single coherent edit to `.claude/settings.json` for ALL 3 new
hooks (W0-3 + W0-4 + W0-5) in ONE pass, to avoid 3 round-trips through JSON-validation.
See § "Coordination rules during dev" below.

### W0-3 DoD criteria

- [ ] **DC-W0-3-1** — `scripts/hooks/atomic-write-check.sh` exists, executable (Unix), parses
  valid bash (`bash -n` PASS).
- [ ] **DC-W0-3-2** — `scripts/hooks/firing-tests/atomic-write-check-fire-test.sh` exists,
  exits 0 with ≥12 TC PASS (12/12 minimum; dev MAY add more edge cases).
- [ ] **DC-W0-3-3** — `bash scripts/hooks/bash-hook-lint.sh` Check 1-11 PASS for the new hook
  + new firing-test (no new violations introduced).
- [ ] **DC-W0-3-4** — ADR D-062 PROPOSED at IMPL tier with ≥6 source_evidence cites; 12-field
  schema valid (`decisions/_template.md` compliance).
- [ ] **DC-W0-3-5** — `.claude/settings.json` valid JSON (jq `.` succeeds), `atomic-write-check.sh`
  in BOTH PostToolUse and Stop chains in correct order.
- [ ] **DC-W0-3-6** — Live audit count recorded in session log: N existing W0-3 violations
  found in `packages/` + `apps/`; if >0, the count is documented for future W0-3.1 cleanup
  session.

---

## Sub-track 2 — W0-4 (HTML-Comment Separator Pattern)

### Pattern statement

**Required**: append-only entry-segmented markdown files in stockforge memory zones MUST
use `\n\n<!-- ENTRY_END -->\n\n` as the inter-entry separator. The HTML comment is
forgery-proof against LLM accidental emission inside markdown prose (per A-13 § 0:
"`<!-- ... -->` is HTML markup which the LLM cannot emit inside markdown prose (LLMs see it
but render swallows it)"). It renders invisible in any markdown viewer.

**Banned**: append-only entry-segmented markdown files using:
- No separator (plain text concatenation) — entries blur, parser can't split.
- A naive ASCII separator (`---`, `***`, `=====`, `#` heading-as-separator) — LLMs can and
  do emit these inside prose, causing forgery / split-corruption.
- A separator inconsistent across the file (e.g., file mixes `---` and `<!-- ENTRY_END -->`).

Source: `master-planner-A-13-deepdive-TradingAgents.md § 0` "W0-4 — HTML-comment separator
pattern" — direct quote from TradingAgents `tradingagents/agents/utils/memory.py:13-14`:
```python
# HTML comment: cannot appear in LLM prose output, safe as a hard delimiter
_SEPARATOR = "\n\n<!-- ENTRY_END -->\n\n"
```
Used as round-trip delimiter at `memory.py:48` (write) and `:59` (parse).

### Hook design

**Path**: `scripts/hooks/html-separator-check.sh` (NEW; target ~150-180 LOC bash; smaller
than W0-3 hook because the scope is narrower — markdown files in specific zones).

**Modes**:
- **PostToolUse** on `Edit|Write|MultiEdit` for `.md` files in audited zones — scans only
  the edited file.
- **Stop** — full audit of files in audited zones.

**Audited zones** (path globs — files that MUST use `<!-- ENTRY_END -->`):

| Zone | Why audited |
|------|-------------|
| `agent-workspace/memory/mistake-log.md` | Per CLAUDE.md, append-only structured failure catalog (M-S<N>-<M> entries); explicit "Track 7 deliverable" per `agent-workspace/CLAUDE.md` subdirectory table. |
| `agent-workspace/memory/agent-notes.md` | "Learned rules from real experience (post-mortem / drift / user correction). Append-only mostly" per `agent-workspace/CLAUDE.md`. |
| `agent-workspace/memory/thesis-log/*.md` | "Stock-domain thesis exploration entries. Read-only for IMPL sessions" per `agent-workspace/CLAUDE.md`. |
| `agent-workspace/memory/observations/*.md` | Subagent return artifacts; each is one entry — entry-segmentation matters when multiple subagents append to a shared file (though current convention is one-file-per-subagent — flag any multi-entry case). |
| `agent-workspace/memory/post-mortems/*.md` | Per `agent-workspace/CLAUDE.md`, "After significant failure or thesis-revoked event: what failed, root cause, prevention rule. Append". |

**Excluded zones** (markdown files that are NOT entry-segmented append-only):
- `*.md` in repo root (README, PROJECT_CHARTER, AGENT_OPERATING_MANUAL, etc. — these are
  documents, not logs).
- `agent-workspace/constitution/*.md` (charter-tier documents).
- `agent-workspace/research/*.md` (research notes; structured but not entry-segmented).
- `agent-workspace/master-plans/*.md` (single-document plans).
- `agent-workspace/session-plans/**/*.md` (single-document plans).
- `agent-workspace/memory/sessions/*.md` (one-file-per-session; not multi-entry).
- `agent-workspace/memory/decisions/*.md` (one-file-per-ADR).
- `agent-workspace/memory/checkpoints/*.md` (one-file-per-checkpoint).

**Detection rules**:

| # | Rule | Detection | Severity |
|---|------|-----------|----------|
| HS-R1 | File in audited zone has ≥2 sectionable "entries" (heuristic: ≥2 top-level `#`/`##` headings AND ≥200 lines) BUT contains 0 `<!-- ENTRY_END -->` markers | grep + wc | ERR — file MUST adopt separator |
| HS-R2 | File in audited zone contains a malformed separator: `<!-- ENTRY -->` (singular instead of plural-ended `ENTRY_END`), `<!--ENTRY_END-->` (no spaces), `<!-- entry_end -->` (lowercase) | regex `<!--\s*[Ee][Nn][Tt][Rr][Yy](_[Ee][Nn][Dd])?\s*-->` minus exact-match `<!-- ENTRY_END -->` | ERR — malformed |
| HS-R3 | File mixes `<!-- ENTRY_END -->` with naive separators (`^---$` between entries) — separator drift indicator | dual grep + line-proximity check | WARN — inconsistent |
| HS-R4 (WARN — informational) | File is in an audited zone, has ≥2 entries, has separators correctly placed (HS-R1 + HS-R2 PASS), and the file is well-formed | (positive signal — emitted as `OK` line) | (no fire — informational only; helps build calibration data) |

**Allow-list mechanism**: file frontmatter `html-separator-exempt: true` — files explicitly
opt out of the rule. Inline `<!-- atomic-md-exempt: <rationale> -->` somewhere in first 20
lines also exempts (matching L-S322-1 in-place pattern).

**Severity emission**: violations land in `.session-hooks.log` as `severity=HIGH` (ERR) /
`severity=MEDIUM` (WARN).

**RC=0 always**; idempotency = hour-bucket marker `.htmlsep-marker-*`; notification
`human-workspace/notifications/html-separator-warn.md` (idempotent fixed-name; S318 pattern).

### Firing-test design

**Path**: `scripts/hooks/firing-tests/html-separator-check-fire-test.sh` (NEW; target ~180-220
LOC bash; ≥10 TC minimum).

**SPAWN-CONTEXT**: `positional-arg`.

**Test cases** (≥10 TC architect-proposed):

| TC | Setup | Expected |
|---:|-------|----------|
| TC1 | File with 3 entries separated by `<!-- ENTRY_END -->` in audited zone | no fire (correct) |
| TC2 | File with 3 entries, no separator, in audited zone (≥200 LOC) | HS-R1 fires (ERR) |
| TC3 | File with 1 entry only (small) in audited zone | no fire (degenerate, doesn't need separator) |
| TC4 | File with `<!-- ENTRY -->` (singular wrong) instead of `<!-- ENTRY_END -->` | HS-R2 fires (ERR) |
| TC5 | File with `<!--ENTRY_END-->` (no spaces) | HS-R2 fires (ERR) |
| TC6 | File with `<!-- entry_end -->` (lowercase) | HS-R2 fires (ERR) |
| TC7 | File mixing `<!-- ENTRY_END -->` and `---` between entries | HS-R3 fires (WARN) |
| TC8 | File in audited zone with frontmatter `html-separator-exempt: true` | no fire (allow-list) |
| TC9 | File in EXCLUDED zone (e.g., `agent-workspace/master-plans/foo.md`) with no separator and 3 entries | no fire (out of audit scope) |
| TC10 | File `agent-workspace/memory/observations/test-foo.md` with 1 entry only | no fire (single-entry observation files allowed; one-file-per-subagent convention) |
| TC11 | Empty file (0 bytes) in audited zone | no fire (degenerate) |
| TC12 (regression-floor) | Hook on non-existent file path | RC=0 + no false fire |

### ADR D-063 — HTML-Comment Separator Doctrine

**Path**: `agent-workspace/memory/decisions/063-html-comment-separator-doctrine.md` (NEW; IMPL).

**Required source_evidence cites** (target ≥6):
1. `observations/master-planner-A-13-deepdive-TradingAgents.md § 0` "W0-4 — HTML-comment
   separator pattern".
2. `C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:13-14` (the
   `_SEPARATOR` constant + inline comment).
3. `C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:48` (write usage:
   `entry = f"{tag}\n\nDECISION:\n{final_trade_decision}{self._SEPARATOR}"`).
4. `C:/htdocs/research/TradingAgents/tradingagents/agents/utils/memory.py:59` (parse usage:
   `text.split(self._SEPARATOR)`).
5. `agent-workspace/CLAUDE.md` subdirectory table (zones designated as append-only).
6. `D-059` template precedent.

**Content sections** (same shape as D-062):
- Context (entry-segmented logs in memory zones; LLM-emission risk; renderer-invisible).
- What is guaranteed (separator forgery-proof + viewer-invisible).
- Audited zones list + excluded zones list.
- 3 banned patterns (HS-R1..R3) with rationale per rule.
- Allow-list mechanism (frontmatter + inline marker).
- Attribution: "Pattern adapted from TradingAgents v0.2.4 (Tauric Research, Apache-2.0). See
  `tradingagents/agents/utils/memory.py:13-14`."

### settings.json wire-up

Add `html-separator-check.sh` to:
- **PostToolUse** matcher for `Edit|Write|MultiEdit` matcher (next to atomic-write-check).
- **Stop chain** AFTER `atomic-write-check.sh` (so both Phase B substrate hooks run sequentially).

### W0-4 DoD criteria

- [ ] **DC-W0-4-1** — `scripts/hooks/html-separator-check.sh` exists, executable, bash-valid.
- [ ] **DC-W0-4-2** — firing-test 10/10+ PASS.
- [ ] **DC-W0-4-3** — bash-hook-lint Check 1-11 PASS for the new hook + firing-test.
- [ ] **DC-W0-4-4** — ADR D-063 PROPOSED at IMPL tier with ≥6 source_evidence cites.
- [ ] **DC-W0-4-5** — settings.json valid + hook wired in both PostToolUse + Stop in correct order.
- [ ] **DC-W0-4-6** — Live audit count: N audited-zone files currently lack separator (cleanup-1
  scope); count recorded in session log.

---

## Sub-track 3 — W0-5 (5-Invariant Path-Safety)

### Pattern statement

**The 5 invariants** (per `master-planner-A-15-deepdive-Vibe-Trading.md § 0`, RECONFIRMED in
Vibe-Trading source `agent/src/tools/path_utils.py:1-213`):

Note: D-061 ratifies the "expansion from 4 to 5" — the master plan § 4.15 called it a "quad"
based on hypothesis; Phase A's empirical re-survey confirmed 4 PUBLIC HELPERS + UNC reject as
cross-cutting SHARED 5th invariant. This plan reflects the 5-invariant reality, NOT the
hypothesised quad.

| # | Invariant | What it bans | Source (Vibe-Trading) |
|---|-----------|--------------|------------------------|
| **P1 (Sandbox)** | Sandbox-relative path containment | `p` must resolve under a caller-supplied `workdir` after `Path(p).resolve()` normalization; raw `..`-escape or absolute-path-leak rejected | `path_utils.py:33-54` (`safe_path(p, workdir)`) |
| **P2 (User-supplied)** | User-supplied path scoped to whitelist of import roots | `p` from user (broker import / journal) must resolve under `_default_file_roots()` (`agent/uploads`, `agent/runs`, `cwd/uploads`, `cwd/data`, `~/.vibe-trading/uploads`, `~/.vibe-trading/imports`) OR env-allowed root via `VIBE_TRADING_ALLOWED_FILE_ROOTS` | `path_utils.py:158-171, :75-87` |
| **P3 (Document-reader)** | Document-reader paths scoped to import roots (intent-tagged separately from P2) | Same allowed-roots set as P2; declared as separate helper for call-site intent clarity | `path_utils.py:174-187` |
| **P4 (Run-dir)** | Generated-code / backtest run-dir paths scoped to wider run roots | `p` must resolve under `_default_run_roots()` (`agent/runs`, `cwd/runs`, `~/.vibe-trading/shadow_runs`) OR env-allowed root via `VIBE_TRADING_ALLOWED_RUN_ROOTS` | `path_utils.py:190-213, :90-99` |
| **P5 (UNC reject)** | **Cross-cutting**: UNC `\\server\share` AND POSIX `//server/share` share-prefix paths pre-rejected by every public helper before any root check | The shared `_rejects_unc(p)` at `path_utils.py:27-30` is called as the FIRST guard in each of P1-P4 — making this the 5th invariant (cross-cutting) | `path_utils.py:27-30` |

**StockForge layer scope** (per `agent-workspace/constitution/architecture.md` BC boundaries):
- **`packages/domain/**`**: STRICTEST — zero filesystem code permitted (already enforced by
  domain-purity convention per S313 plan note: "Pure Python dataclass + enum (ZERO framework
  dependency)"). Detector here = "hook fires if ANY of os.path, Path(), open() appears."
  Empirical: plan-authoring grep `os.path.|Path(|pathlib` on `packages/domain/` returned 0
  matches. Domain layer is currently clean.
- **`packages/application/**`**: Port abstractions only — no concrete filesystem use; if
  filesystem touch needed, must go through an injected port. Detector fires on direct usage.
- **`packages/infrastructure/**`**: Filesystem code allowed but MUST use the safe helpers
  (port stockforge versions of `safe_path` / `safe_user_path` / `safe_document_path` /
  `safe_run_dir` — propose names below).
- **`apps/**`**: Same as infrastructure.

**Note on porting strategy**: this hook ships the DETECTOR for path-safety violations. The
ACTUAL `safe_path` helper implementations (the 4 functions + 1 shared UNC guard) are a
**separate W0-5-impl item** that creates the Python module that callers can use to satisfy
the hook. For this PLAN's scope, the dev creates BOTH:
1. The detector hook (banned-pattern check on call sites).
2. A Python helper module `packages/_shared/path_safety.py` (or similar — propose at IMPL
   time) that implements the 4 helpers + UNC guard, ported with attribution from
   Vibe-Trading `path_utils.py`.

Without the helpers, hook violations have no fix-recipe; with both, the hook + helpers form
a complete contract.

### Hook design

**Path**: `scripts/hooks/path-safety-check.sh` (NEW; target ~200-250 LOC bash — slightly
larger than W0-3 because 5 invariants require 5 distinct detection passes).

**Modes**:
- **PostToolUse** on `Edit|Write|MultiEdit` for `.py` files in `packages/**` + `apps/**`.
- **Stop** — full-tree audit.

**Per-invariant detection rules**:

| Invariant | Rule | Detection | Severity |
|-----------|------|-----------|----------|
| P1 (Sandbox / `..`-traversal) | `..` literal in any `Path(...)` / `os.path.join(...)` / `open(...)` arg expression in production code | regex `(Path\([^)]*\.\.\|os\.path\.join\([^)]*\.\.\|open\([^)]*\.\.)` | ERR |
| P1b (absolute-path in domain) | Any `Path('/...')` / `Path('C:\\\\...')` / `Path('C:/...')` literal in `packages/domain/**` | path-prefix regex against domain glob | ERR |
| P2/P3 (user-supplied path no whitelist check) | Any `Path(<arg-or-env-var>)` / `open(<arg-or-env-var>)` where the path source is `sys.argv` / `os.environ.get(...)` / function-parameter-marked-user-supplied AND the call is NOT preceded by a `safe_*_path(` wrapper within 10 lines | heuristic regex + lookbehind | WARN (heuristic — high false-positive risk; WARN-only) |
| P4 (write outside designated zones) | Any `.write_text(` / `.write_bytes(` / `open(...,'w'/'a')` where the destination path expression does NOT resolve to one of `outputs/`, `logs/`, `state/`, `cache/`, `data/`, `agent-workspace/memory/`, `human-workspace/notifications/`, `human-workspace/q-and-a/` | regex + heuristic path-classification | WARN |
| P5 (UNC) | Any `\\\\` (escaped backslash pair → `\\` literal) OR `//` (POSIX UNC) at the start of a path literal in production code | regex `(Path\(['"]\\\\\\\\\|Path\(['"]//[a-zA-Z])` | ERR |

**Severity emission**: violations land in `.session-hooks.log` as `severity=HIGH` (ERR) /
`severity=MEDIUM` (WARN). P2/P3 + P4 are WARN by default (heuristic — easier to false-positive);
P1 + P1b + P5 are ERR.

**Allow-list mechanism**:
- `# path-safety-ok: <rationale>` inline marker on the offending line (L-S322-1 in-place pattern).
- `test_*.py` + `**/tests/**/*.py` exempt (test code may craft adversarial paths).
- `scripts/**/*.py` exempt (dev tooling).
- Files using the canonical `safe_path()` / `safe_user_path()` / etc helpers from
  `packages/_shared/path_safety.py` (introduced as part of this sub-track).

**RC=0 always**; idempotency = `.psafety-marker-*` hour-bucket; notification
`human-workspace/notifications/path-safety-warn.md` (S318 idempotent fixed-name).

### Firing-test design

**Path**: `scripts/hooks/firing-tests/path-safety-check-fire-test.sh` (NEW; target ~300-400
LOC bash; **≥15 TC minimum = 5 invariants × ≥3 cases each**).

**SPAWN-CONTEXT**: `positional-arg`.

**Test cases** (≥15 TC architect-proposed; mirror Vibe-Trading test surface
`agent/tests/test_path_safety.py:1-136`):

| TC | Invariant | Setup | Expected |
|---:|-----------|-------|----------|
| TC1 | P1 | `Path('/usr/local/../etc/passwd')` literal in `packages/infrastructure/foo.py` | P1 fires (ERR) |
| TC2 | P1 | `Path('../foo')` in production code | P1 fires (ERR) |
| TC3 | P1 | `safe_path(user_input, workdir)` call wrapping a Path | no fire |
| TC4 | P1b | `Path('/var/log/stockforge.log')` literal inside `packages/domain/observation_lifecycle/foo.py` | P1b fires (ERR) |
| TC5 | P1b | `Path('C:\\\\Users\\\\foo')` literal in `packages/domain/` | P1b fires (ERR) |
| TC6 | P1b | Same `Path('/var/...')` literal in `packages/infrastructure/` | no fire (infrastructure allowed) |
| TC7 | P2/P3 | `Path(sys.argv[1])` in `apps/cli/foo.py` not preceded by safe_*_path call | P2 fires (WARN) |
| TC8 | P2/P3 | `Path(os.environ.get('USER_INPUT'))` in production | P2 fires (WARN) |
| TC9 | P2/P3 | `Path(safe_user_path(sys.argv[1]))` (helper wrapped) | no fire |
| TC10 | P4 | `Path('/tmp/foo.json').write_text(...)` in production (not in allowed zone) | P4 fires (WARN) |
| TC11 | P4 | `Path('outputs/state.json').write_text(...)` (allowed persistence zone) | no fire |
| TC12 | P4 | `Path('agent-workspace/memory/foo.md').write_text(...)` (allowed memory zone) | no fire |
| TC13 | P5 | `Path('\\\\\\\\server\\\\share\\\\file')` in production | P5 fires (ERR) |
| TC14 | P5 | `Path('//server/share/file')` (POSIX UNC) | P5 fires (ERR) |
| TC15 | P5 | `Path('\\\\\\\\?\\\\C:\\\\foo')` (Windows extended-length path; rare edge) | dev decides — propose: fires P5 unless allow-list inline marker |
| TC16 | All | `# path-safety-ok: explicit UNC for windows-only build script` inline marker on offending line | no fire (rationale marker) |
| TC17 | All | Empty Python file | no fire (degenerate) |
| TC18 (regression-floor) | All | Hook on non-existent file | RC=0 + no false fire |

**Firing-test must verify**: each of P1, P1b, P2/P3, P4, P5 has ≥3 distinct test cases
(positive + negative + edge), totalling ≥15 TC.

### Companion port: `packages/_shared/path_safety.py`

**Path**: `packages/_shared/path_safety.py` (NEW; target ~150-200 LOC Python).

**Content**: 4 public helpers (`safe_path`, `safe_user_path`, `safe_document_path`,
`safe_run_dir`) + 1 internal `_rejects_unc(p)` shared cross-cutting guard, PORTED from
Vibe-Trading `agent/src/tools/path_utils.py:1-213` with:

- **Attribution header** per MIT license requirement (per D-061 § Decision item 1 +
  A-15 § 6 attribution template):
  ```python
  # Pattern adapted from Vibe-Trading (HKUDS/Vibe-Trading, MIT-licensed, 2026).
  # Upstream: agent/src/tools/path_utils.py (4 public helpers + _rejects_unc cross-cutting guard).
  # StockForge adaptation: VN-locale + stockforge-layout default roots (agent-workspace/memory/,
  # outputs/, human-workspace/, etc.).
  ```
- **Rename env vars**: `VIBE_TRADING_ALLOWED_FILE_ROOTS` → `STOCKFORGE_ALLOWED_FILE_ROOTS`;
  `VIBE_TRADING_ALLOWED_RUN_ROOTS` → `STOCKFORGE_ALLOWED_RUN_ROOTS`.
- **Refresh default-root list** to StockForge layout:
  - `_default_file_roots()` returns: `agent-workspace/uploads/` (if exists),
    `human-workspace/notifications/`, `outputs/`, `data/` (relative to project root).
  - `_default_run_roots()` returns: `outputs/runs/`, `state/runs/`.
- **Refresh docstring** to cite "5 invariants (4 helpers + UNC cross-cutting guard)" — A-15
  § 7 #6 anti-pattern to avoid ("DO NOT copy the docstring-out-of-date pattern" from
  upstream).
- **Unit tests** at `packages/_shared/test_path_safety.py`: ≥15 test functions covering each
  of P1-P5 with ≥3 cases each (mirroring the firing-test surface). Use pytest + parametrize
  for table-driven cases.

**Why ship the helpers along with the detector**: the hook detects violations BUT the
violator needs a fix-recipe. Without `packages/_shared/path_safety.py`, the hook's
remediation message ("use safe_path / safe_user_path / safe_document_path / safe_run_dir")
points to a non-existent helper — that's a useless red-flag (per A-13 § 7.6 "deterministic
termination ≠ consensus"-style false comfort). The helpers are the fix recipe; hook detects
absence; firing-test confirms both work.

### ADR D-064 — Path-Safety 5-Invariant Contract

**Path**: `agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md` (NEW; IMPL).

**Required source_evidence cites** (target ≥7 — higher bar because of 5-invariant complexity):
1. `observations/master-planner-A-15-deepdive-Vibe-Trading.md § 0` "W0-5 path-safety quad —
   RECONFIRMED in source".
2. `D-061 § Decision item 8` (W0-5 ratified as 5-invariant per Q-INT-bis SUPPLEMENT expansion).
3. `C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:27-30` (`_rejects_unc`
   cross-cutting 5th invariant).
4. `C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:33-54` (P1 sandbox helper).
5. `C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:158-171` (P2 user-supplied).
6. `C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:174-187` (P3 document).
7. `C:/htdocs/research/Vibe-Trading/agent/src/tools/path_utils.py:190-213, :90-99` (P4 run-dir).
8. `C:/htdocs/research/Vibe-Trading/agent/tests/test_path_safety.py:1-136` (test surface
   precedent).
9. `D-059` template precedent.
10. `agent-workspace/constitution/architecture.md` (BC layer boundaries — explains why
    domain-strict / infrastructure-permitted-with-helper).

**Content sections** (mirror D-059/D-062/D-063 shape):
- Context (Wave 0 substrate finish; 5 invariants from Vibe-Trading; cross-cutting UNC reject).
- The 5 invariants enumerated with rationale per each.
- Layer scope (domain strictest; infrastructure with helper).
- Helper API (`packages/_shared/path_safety.py` — 4 helpers + cross-cutting guard).
- Detector hook + firing-test references.
- Allow-list (test files, scripts, inline marker).
- Charter alignment: Principle 11 (firing-test mandate satisfied for hook); Principle 8
  (calibration: WARN→BLOCKING ratchet after clean run).
- Attribution: "Helpers adapted from Vibe-Trading (HKUDS/Vibe-Trading, MIT 2026). See
  `agent/src/tools/path_utils.py`."

### settings.json wire-up

Add `path-safety-check.sh` to:
- **PostToolUse** matcher for `Edit|Write|MultiEdit` (alongside W0-3 + W0-4 hooks).
- **Stop chain** AFTER `html-separator-check.sh` (full Wave 0 substrate substrate ordering
  is: severity-classifier → existing hooks → atomic-write-check → html-separator-check →
  path-safety-check → observation-orphan-detector → ...).

### W0-5 DoD criteria

- [ ] **DC-W0-5-1** — `scripts/hooks/path-safety-check.sh` exists, executable, bash-valid.
- [ ] **DC-W0-5-2** — `scripts/hooks/firing-tests/path-safety-check-fire-test.sh` 15/15+ PASS.
- [ ] **DC-W0-5-3** — bash-hook-lint Check 1-11 PASS for the new hook + firing-test.
- [ ] **DC-W0-5-4** — `packages/_shared/path_safety.py` exists, exports 4 helpers + UNC
  guard; module-level attribution header present.
- [ ] **DC-W0-5-5** — `packages/_shared/test_path_safety.py` ≥15 unit tests PASS via
  `python -m pytest packages/_shared/test_path_safety.py -q`.
- [ ] **DC-W0-5-6** — ADR D-064 PROPOSED at IMPL tier with ≥7 source_evidence cites.
- [ ] **DC-W0-5-7** — settings.json valid + hook wired in both PostToolUse + Stop in correct
  order (3rd of 3 new hooks; full ordering documented in session log).
- [ ] **DC-W0-5-8** — Live audit count: N path-safety violations in `packages/` + `apps/`
  (split per invariant P1..P5); count recorded for future W0-5.1 cleanup session.
- [ ] **DC-W0-5-9** — `mypy --strict packages/_shared/path_safety.py packages/_shared/test_path_safety.py`
  exits 0.
- [ ] **DC-W0-5-10** — `ruff check packages/_shared/path_safety.py packages/_shared/test_path_safety.py`
  exits 0.

---

## Bundle DoD aggregate — DC-AGG-1 through DC-AGG-15

Aggregated across all 3 sub-tracks; verifier S33N+2 confirms each empirically:

- [ ] **DC-AGG-1** — All 3 new hooks (atomic-write-check, html-separator-check, path-safety-check)
  exist, executable (Unix permissions), bash-valid (`bash -n` PASS each).
- [ ] **DC-AGG-2** — All 3 firing-tests exist and pass: 12+/12 (W0-3) + 10+/10 (W0-4) + 15+/15
  (W0-5) — total ≥37 TC across the bundle.
- [ ] **DC-AGG-3** — `bash scripts/hooks/bash-hook-lint.sh` exits 0 with 0 violations across
  full tree (the 3 new hooks + 3 firing-tests + 1 new Python module + 1 test module introduce
  ZERO new lint violations). Per L-S321-2 + plan 015 close: lint must be clean.
- [ ] **DC-AGG-4** — 3 new ADRs PROPOSED at IMPL tier (D-062 / D-063 / D-064); each with
  ≥6 (W0-3 + W0-4) or ≥7 (W0-5) source_evidence cites. Each 12-field schema valid.
- [ ] **DC-AGG-5** — `mypy --strict` exits 0 for `packages/_shared/path_safety.py` +
  `packages/_shared/test_path_safety.py`.
- [ ] **DC-AGG-6** — `ruff check` exits 0 for the new Python module + tests.
- [ ] **DC-AGG-7** — `python -m pytest packages/_shared/ -q` exits 0 with all new tests
  passing (no baseline regression).
- [ ] **DC-AGG-8** — `python -m pytest -q` (full suite) exits 0 — no baseline regression
  introduced by the new module + tests.
- [ ] **DC-AGG-9** — `.claude/settings.json` is valid JSON (`jq '.' .claude/settings.json`
  succeeds with no parse error). All 3 new hooks present in BOTH PostToolUse + Stop chains
  in the documented order:
  - PostToolUse (Edit|Write|MultiEdit matcher): [existing] ... → atomic-write-check →
    html-separator-check → path-safety-check (after any pre-existing PostToolUse hooks for
    .py + .md files).
  - Stop chain: [pre-existing ordering preserved] → `python-determinism-check.sh` (W0-2) →
    `atomic-write-check.sh` (W0-3) → `html-separator-check.sh` (W0-4) → `path-safety-check.sh`
    (W0-5) → `observation-orphan-detector.sh` → ... [rest of chain unchanged]. The dev
    confirms ordering matches the existing block at `settings.json:413-510` (Stop chain
    region per plan-authoring read).
- [ ] **DC-AGG-10** — Charter Principle 11 satisfied per `harness-health-protocol.md § HH-10`:
  every priority-1 hook in `scripts/hooks/` has companion firing-test in
  `scripts/hooks/firing-tests/`. After this bundle: 3 new hooks + 3 new firing-tests =
  delta zero in HH-10 backlog.
- [ ] **DC-AGG-11** — `scripts/hooks/firing-tests/run-all.sh` exits 0 with N+3 firing-tests
  PASS (where N = baseline at STEP 0). No baseline firing-test regressed.
- [ ] **DC-AGG-12** — Live audit summary in session log:
  - W0-3 violations in `packages/` + `apps/`: <N>
  - W0-4 separator-missing in audited zones: <N>
  - W0-5 violations split by invariant: P1=<n>, P1b=<n>, P2/P3=<n>, P4=<n>, P5=<n>
  - **Each count drives whether a W0-3.1 / W0-4.1 / W0-5.1 cleanup session is queued.**
  Plan-authoring expectation: small counts (single-digit each), suitable for one bundled
  W0-cleanup follow-up plan; if any count >10, recommend separate cleanup session per
  W0-2 → W0-2.1 precedent.
- [ ] **DC-AGG-13** — Session log written to
  `agent-workspace/memory/sessions/2026-05-XX-session-33N+1.md` per CLAUDE.md § Session
  Protocol "End" steps 2-3, summarising the bundle outcome + 3 ADRs PROPOSED + 3 hooks
  shipped + cleanup follow-up recommendation.
- [ ] **DC-AGG-14** — `agent-workspace/memory/current-execution.md` updated: W0-3/W0-4/W0-5
  status → SHIPPED (with sub-row per sub-track per § retention rules — ≤ 5 sessions inline
  / ≤ 200 LOC).
- [ ] **DC-AGG-15** — `agent-workspace/memory/mistake-log.md` either appended (M-S33N+1-N if
  any mistakes) or session log explicitly states "no mistakes this session" (enforced by
  `session-end-checklist-linter.sh` Stop hook per CLAUDE.md § Session Protocol "End" step 6).

---

## Production-cleanup deferral (out-of-scope cleanup items)

Each sub-track explicitly DEFERS production-cleanup of existing violations to a separate
follow-up session — same posture as the W0-2 → W0-2.1 split (plan 014 § "Out of scope"
defer line 92; followed up at S329 / plan 017 cleanly).

| Sub-track | Deferred cleanup session | Expected scope |
|-----------|--------------------------|----------------|
| W0-3 | **W0-3.1** (post-S33N+2 verify; PLAN+IMPL+VERIFY sandwich) | Fix detected `.write_text` / `open('w')` violations. From plan-authoring grep: ≥1 known (`packages/infrastructure/influence/llm_recommendation_extractor.py:466` `fname.write_text(payload, encoding='utf-8')` — non-critical audit-persist write); dev confirms full count at DC-AGG-12 audit. |
| W0-4 | **W0-4.1** | Add `<!-- ENTRY_END -->` separators to `agent-workspace/memory/mistake-log.md` + `agent-workspace/memory/agent-notes.md` (the 2 currently-missing-separator files per plan-authoring grep). Schema impact: low — `severity-schema.md § 2` mapping uses `Mistake` `Severity:` field grep + already tolerates either separator presence; adding `<!-- ENTRY_END -->` does NOT break the grep. |
| W0-5 | **W0-5.1** | Audit + fix path-safety violations split per invariant. Domain layer is currently clean (plan-authoring probe = 0 matches in `packages/domain/`). Infrastructure + apps layers may need `safe_path` / `safe_user_path` / etc. wrapping at user-input call sites. |

**Why deferral is correct here**: the hook + helpers + ADR + firing-test SHIP at S33N+1
(this bundle); the actual code-base sweep is a separate cognitive load (per
W0-2 → W0-2.1 separation reasoning at plan 014 line 92: "this session SHIPS the hook;
remediation of existing violations is a separate cleanup pass"). Bundling cleanup with hook-
ship would expand the IMPL session by 50-100K tokens and risk mixing two failure modes
(hook design bug vs cleanup completeness gap).

---

## Coordination rules during dev (S33N+1 active)

**Main session AVOIDS** during S33N+1 IMPL window (cross-session edit conflict prevention):

- `scripts/hooks/atomic-write-check.sh` + `scripts/hooks/firing-tests/atomic-write-check-fire-test.sh` (W0-3 new hook + firing-test)
- `scripts/hooks/html-separator-check.sh` + `scripts/hooks/firing-tests/html-separator-check-fire-test.sh` (W0-4)
- `scripts/hooks/path-safety-check.sh` + `scripts/hooks/firing-tests/path-safety-check-fire-test.sh` (W0-5)
- `packages/_shared/path_safety.py` + `packages/_shared/test_path_safety.py` (W0-5 helper module — dev creates both)
- `.claude/settings.json` (3 hooks wired in one coherent edit at end of IMPL window — DC-AGG-9; main session does NOT touch the file during S33N+1)
- `agent-workspace/memory/decisions/062-atomic-write-doctrine.md` + `063-html-comment-separator-doctrine.md` + `064-path-safety-5-invariant-contract.md` (3 new ADRs)
- `human-workspace/notifications/atomic-write-warn.md` + `html-separator-warn.md` + `path-safety-warn.md` (3 hooks' notification consumers — created on first violation detection by the hook; dev MAY edit `status:` field per L-S322-1 in-place deprioritize at IMPL close if hooks fire on test-fixture artifacts)
- `agent-workspace/memory/.aw-marker-*` + `.htmlsep-marker-*` + `.psafety-marker-*` (hour-bucket cache markers)
- `agent-workspace/memory/sessions/2026-05-XX-session-33N+1.md` (will be authored by S33N+1 dev at end)
- `agent-workspace/memory/observations/sandwich-dev-S33N+1-W0-3-4-5-bundle.md` (S33N+1 dispatch observation file)

**Main session MAY** continue work on (orthogonal):
- Any other `scripts/hooks/**/*.sh` not in the above list.
- `agent-workspace/memory/current-execution.md` (S33N+1 row pre-staging at S33N+1 start —
  but NOT during; the dev finalises the row at IMPL close).
- Anything in `agent-workspace/research/`, `agent-workspace/master-plans/`, other ADRs in
  `agent-workspace/memory/decisions/` outside D-062/D-063/D-064.
- `agent-workspace/proposals/`, `agent-workspace/calibration/`, `agent-workspace/thesis-log/`.
- `apps/` + `packages/` files OUTSIDE `packages/_shared/path_safety.py` (the W0-5 helper
  module — only file in `packages/` the dev touches).

**Commit boundary** (D-060 active): the S33N+1 dev MAY commit at IMPL close in a single
coherent commit OR split per sub-track (3 commits — one per W0-3/4/5). Recommended message
stems:

- Option A (single commit): `S33N+1: W0-3+4+5 — atomic-write + html-separator + path-safety hooks + helpers + ADRs (D-062/063/064)`
- Option B (3 commits):
  - `S33N+1: W0-3 — atomic-write-check hook + firing-test + D-062`
  - `S33N+1: W0-4 — html-separator-check hook + firing-test + D-063`
  - `S33N+1: W0-5 — path-safety-check hook + firing-test + helper module + D-064`

The dev picks based on whether all 3 sub-tracks reach DoD cleanly in one pass (Option A) or
incrementally (Option B). Do NOT push.

---

## Risk + Mitigation

| # | Risk | Likelihood | Mitigation |
|---|------|-----------|------------|
| RM1 | **False-positive flood**: hook fires on legitimate write-in-place patterns (e.g., test fixtures that intentionally write non-atomically for failure-mode simulation) | Med | Pre-emptive allow-lists per sub-track (test_*.py + tests/ + inline marker + `if __name__ == "__main__":`). Live audit at DC-AGG-12 records false-positive ratio; if FP-rate >50% on first run, dev MUST add additional allow-list entries before ratifying ADRs. |
| RM2 | **Budget envelope breach** (S33N+1 exceeds 200K target — 3 sub-tracks bundle may push past R-2 splits-if->10-tasks line) | Low-Med | Dev tracks token budget at sub-track boundary (after W0-3 close, after W0-4 close); if budget >175K at W0-4 close with W0-5 still to ship, **STOP-AND-SPLIT**: dispatch S33N+2 fresh-context dev for W0-5 alone; mark this session's commit boundary at W0-4 close; rename plan 018 to "W0-3 + W0-4 only"; file follow-up plan 019 for W0-5 in pending/. |
| RM3 | **Regex over-trigger on test fixtures inside hook firing-tests** (a firing-test fixture writes a synthetic banned pattern → the hook scans the firing-test directory and false-fires on it) | Med | Hook MUST exclude `scripts/hooks/firing-tests/**` from the audit scope (per all 3 sub-tracks; mirror W0-2 hook's behavior at `python-determinism-check.sh:106-110` excluded-paths logic — confirm during STEP 0 read). |
| RM4 | **`<!-- ENTRY_END -->` separator conflict** with `severity-classifier.sh` body-grep semantics (the classifier parses `mistake-log.md` looking for `Severity:` patterns; introducing HTML comments could shift line offsets) | Low | Plan-authoring grep on `severity-schema.md § 2`: the classifier matches `mistake.body.contains` patterns line-by-line; HTML comments are line-neutral (single-line `<!-- ENTRY_END -->`) so classifier line-by-line iteration is unaffected. Verify empirically: at DC-AGG-12, run `bash scripts/hooks/severity-classifier.sh` against current `mistake-log.md` AND against a synthetic copy with `<!-- ENTRY_END -->` separators inserted — outputs must match. If divergent → block W0-4 deployment; escalate. |
| RM5 | **Path-safety hook over-triggers in `packages/_shared/path_safety.py`** itself (the helpers' implementation contains `..` literals or UNC patterns in comments / docstrings — testing logic) | Med | The Python module itself MUST be exempt from the hook via the inline marker `# path-safety-ok: internal helper implementation` OR via a path-glob exclusion `packages/_shared/path_safety.py` in the hook's allow-list. Dev confirms during W0-5 firing-test development that the helper module + its test module both pass the hook clean. |
| RM6 | **AP-23 second-rule-about-rule trigger**: introducing 3 new ADRs (D-062 / D-063 / D-064) on top of D-059 + D-061 may trip CLAUDE.md AP-23 red flag ("Refinement-of-rule lesson-about-lesson") | Low | These are NOT rules-about-rules — D-062 / D-063 / D-064 are first-instance rules each (atomic-write doctrine ≠ Python determinism; HTML-separator ≠ atomic-write; path-safety ≠ either). Each is its own primitive; no refinement. Verify by reading D-062 etc carefully: if any reads "I-S1 + X" or "D-059 + Y" framing, it's likely a refinement and should be folded — but the proposed shape is each is a standalone primitive. |
| RM7 | **Settings.json edit conflict** (main session edits `.claude/settings.json` concurrently — e.g., to add an unrelated hook) | Low | Per Coordination § main avoids settings.json for the IMPL window. Dev makes the wire-up edit in ONE pass at IMPL close (single commit) so the conflict window is minimised. |
| RM8 | **Helper-port semantic drift** (Vibe-Trading's `safe_path` accepts `workdir` arg; stockforge port may need different convention) | Med | Plan reads upstream module IN FULL at STEP 0.6; ports the API surface verbatim (4 helpers + UNC guard); only env-var names + default-root list change. Test surface ports 1:1 from `agent/tests/test_path_safety.py:1-136` per A-15 § 7 #7 anti-pattern "DO NOT skip path-safety tests when porting C1". |
| RM9 | **W0-5 master-plan vs. D-061 wording divergence** — master-plan § 4.15 says "path-safety quad (4 patterns)"; D-061 ratifies "5-invariant (UNC reject cross-cutting)". Dev defaults to 4 by reading master plan first. | Low | Plan EXPLICITLY states the 5-invariant reality in 4 separate sections (§ Pattern statement, § Hook design rules, § Firing-test ≥15 TC = 5×3, § DoD DC-W0-5-2 "15/15+ PASS"). VBW protocol mandates the dev reads D-061 + A-15 § 0 not the master plan § 4.15 hypothesis. |
| RM10 | **Live-audit count shock**: DC-AGG-12 reveals 50+ violations in any sub-track, blowing up the cleanup-follow-up scope estimate | Med | If any count >10, the dev (a) records it accurately, (b) does NOT attempt in-bundle cleanup, (c) flags for a dedicated cleanup-follow-up plan in the session log; the bundle still ships at DoD. The cleanup session is THEN scoped per its own actual count. |

---

## Out-of-scope explicit list

These items are explicitly OUT of this bundle's scope (each cites where it actually belongs):

1. **Cleanup of existing W0-3/4/5 production violations** → deferred to W0-3.1/W0-4.1/W0-5.1
   per § Production-cleanup deferral.
2. **Vibe-Trading Monte Carlo + Bootstrap Sharpe CI + Walk-Forward backtest validation
   pipeline** → Theme N net-new per D-061 § Decision item 7; "deferred to Wave 2+" Wave 1
   non-goal; will land in a separate Charter-Month-12-prep PLAN session.
3. **Theme G I-S1-1 confidence-field constitution-write** → Phase C S333 PLAN (master plan
   § 6.3); requires explicit human-approve gate per CLAUDE.md hard rule; orthogonal to
   substrate work.
4. **Theme H BC-8 multi-perspective debate-style primitives** → Phase F-prime per D-061
   § Consequences "Phase F-prime: 3-4 sessions … BC-8 multi-perspective; INVERTED to
   debate-style"; depends on Theme G outcome.
5. **TradingAgents `ChromaDB → Postgres+pgvector` memory port** (C8/C9 patterns per A-13 § 3)
   → Wave 2+ candidate per A-13 § 3 row C8/C9 "Wave-2 candidate".
6. **nautilus_trader MessageBus / cross-BC event bus** (Theme M per master plan § 4.10) →
   deferred past Wave 1 per master plan.
7. **W0-2 → W0-2.1 WARN→BLOCKING ratchet promotion** (D-059 lines 218-224 promotion gate) →
   separate decision after 3+ clean sessions; not this bundle.
8. **HTML separator validation in pytest** (i.e., a Python-side validator for the separator
   pattern in test code) → optional; the bash hook is sufficient for Stop-mode + PostToolUse
   coverage. If dev finds an unavoidable need, propose as RM-add and document in session log.
9. **Renaming Vibe-Trading helper API** (e.g., snake_case → camelCase to match a different
   convention) → port verbatim per RM8 mitigation; if renaming desired, separate ADR after
   this bundle.
10. **Cross-platform UNC handling for `\\?\C:\...` Windows extended-length paths beyond a
    single TC15 firing-test case** → out-of-scope edge; if `\\?\...` is encountered in
    production at audit time, document in session log + propose narrow extension ADR.

---

## Verifier checklist (S33N+2 sandwich-verifier MUST re-check empirically)

Per AP-1 fresh-context; mirror plan 017's verifier checklist shape (V1 acceptance / V2 dev-
handoff / V3 charter / V4-V6 regression+smoke+integration):

### V1 — Acceptance (per DC-AGG-1 through DC-AGG-15)

- [ ] V1.1 — Empirically `ls scripts/hooks/atomic-write-check.sh` + `bash -n` PASS.
- [ ] V1.2 — Empirically `ls scripts/hooks/html-separator-check.sh` + `bash -n` PASS.
- [ ] V1.3 — Empirically `ls scripts/hooks/path-safety-check.sh` + `bash -n` PASS.
- [ ] V1.4 — Re-run all 3 firing-tests independently:
  ```bash
  bash scripts/hooks/firing-tests/atomic-write-check-fire-test.sh
  bash scripts/hooks/firing-tests/html-separator-check-fire-test.sh
  bash scripts/hooks/firing-tests/path-safety-check-fire-test.sh
  ```
  Each exits 0 with all-PASS report.
- [ ] V1.5 — `bash scripts/hooks/bash-hook-lint.sh` exits 0.
- [ ] V1.6 — `bash scripts/hooks/firing-tests/run-all.sh` exits 0 with N+3 PASS.
- [ ] V1.7 — All 3 ADRs (D-062/D-063/D-064) exist with valid 12-field schema + ≥6/6/7
  source_evidence cites respectively. `head -50` of each ADR shows correct frontmatter.
- [ ] V1.8 — `.claude/settings.json` valid JSON (`jq '.' .claude/settings.json` succeeds);
  3 new hooks present in PostToolUse + Stop chains.
- [ ] V1.9 — `python -m mypy --strict packages/_shared/path_safety.py` + test module: exits 0.
- [ ] V1.10 — `python -m ruff check packages/_shared/path_safety.py` + test module: exits 0.
- [ ] V1.11 — `python -m pytest packages/_shared/ -q` exits 0 with ≥15 new tests PASS.

### V2 — Dev handoff notes (the dev MAY flag concerns at session-log close; verifier validates each)

- [ ] V2.1 — Live audit counts in session log match an independent re-run of each hook in
  Stop-mode against HEAD (verifier reproduces; tolerance for hour-bucket cache freshness).
- [ ] V2.2 — Any RM mitigation invoked (e.g., RM2 split, RM10 count-shock) is documented with
  rationale + carry-forward; verifier confirms carry-forward is queued (e.g., file 019 in
  `session-plans/pending/` if RM2 split happened).
- [ ] V2.3 — Compliance Attestation block in session log includes: I-S1 ✓ / I-S2 ✓ /
  Charter Principle 11 ✓ / D-060 (commit count + 0 push) / 0 charter / 0 constitution / 0
  human-workspace (no notification-WRITE outside the 3 hooks' fixed-name idempotent files) /
  AP-1 honored (S33N+2 fresh-context).

### V3 — Charter compliance

- [ ] V3.1 — No charter edits (verify: `git diff HEAD~N HEAD PROJECT_CHARTER.md` empty).
- [ ] V3.2 — No constitution writes (verify: `git diff HEAD~N HEAD -- agent-workspace/constitution/`
  empty).
- [ ] V3.3 — Each new ADR includes attribution per D-061 § Decision item 1 (Apache + MIT
  attribution headers).
- [ ] V3.4 — Charter Principle 11 satisfied: every new hook ships with companion firing-test
  (per `harness-health-protocol.md § HH-10`). Verifier re-runs HH-10 detection: 0 backlog.
- [ ] V3.5 — Each new ADR cites at least one Phase A deep-dive (W0-3/W0-4 → A-13 § 0;
  W0-5 → A-15 § 0) per I-S2 every-claim-sourced.

### V4 — Regression (no baseline breakage)

- [ ] V4.1 — All pre-existing firing-tests still PASS (run-all.sh delta = +3, regression = 0).
- [ ] V4.2 — `python -m pytest -q` (full suite) baseline pass count + new tests; no pre-existing
  test regressed.
- [ ] V4.3 — `bash-hook-lint.sh` clean across full tree (no new violations from new hooks
  or firing-tests).
- [ ] V4.4 — W0-2 hook (`python-determinism-check.sh`) still PASSES on current HEAD (0
  violations) — neither sub-track triggered a cross-fire on W0-2 patterns.

### V5 — Smoke (synthetic banned pattern → all 3 detectors fire correctly)

- [ ] V5.1 — Synthesize a Python file at `/tmp/smoke/foo.py` with ALL the following: a
  `Path("/tmp/foo.json").write_text(...)` line (W0-3 trigger) + a `Path("/tmp/../etc/passwd")`
  line (W0-5 trigger). Run each hook against it; verify each fires its expected rule(s).
- [ ] V5.2 — Synthesize an entry-segmented markdown at `agent-workspace/memory/sandbox-foo.md`
  (note: NOT in audited zone unless dev placed it there during firing-test) — but better:
  use the firing-test's existing sandbox.
- [ ] V5.3 — Re-run all 3 hooks against full tree at HEAD; record violation counts; cross-check
  against session-log DC-AGG-12 numbers.

### V6 — Integration (hook ordering + severity-classifier feed)

- [ ] V6.1 — Run a full Stop chain (with `STOCKFORGE_HOOK_PROFILE=` default) on a synthetic
  session; verify `.session-hooks.log` contains correctly-ordered lines from W0-2 → W0-3 →
  W0-4 → W0-5 hooks (chronological order = Stop chain order). No hook output appears OUT of
  order.
- [ ] V6.2 — `severity-classifier.sh` correctly classifies the new ERR / WARN emissions from
  the 3 new hooks per `severity-schema.md § 2`. Verifier creates 1 ERR + 1 WARN per hook in
  a synthetic `.session-hooks.log` and runs the classifier; output should populate
  `.severity-state.tsv` with HIGH / MEDIUM rows respectively.
- [ ] V6.3 — `index-registry-renderer.sh` (Stop chain) renders the 3 new hook + firing-test
  pairs in its registry index without error.

**Verifier verdict format**: PASS / PASS-WITH-CONCERNS / FAIL. Per AP-1, verifier is
fresh-context Opus subagent; does NOT self-review (i.e., does not re-author the plan).

---

## STOP-IF-AMBIGUOUS clause (full)

S33N+1 dev MUST stop and escalate to main (via observation file +
`human-workspace/notifications/<slug>-ALERT.md` write) WITHOUT writing any production code if
any of the following hold:

1. **STEP 0.1 surprise**: W0-2.1 status row reads anything other than SHIPPED; OR plan 017
   is not in `completed/`; OR `python-determinism-check.sh` Stop-mode emits >0 violations
   on current HEAD (i.e., a regression has crept in since S330 verify PASS).
2. **STEP 0.2 surprise**: upstream repos (TradingAgents OR Vibe-Trading) absent OR licenses
   changed (no longer Apache-2.0 / MIT).
3. **STEP 0.3 surprise**: cited file:line patterns in upstream repos no longer match the
   deep-dive evidence (e.g., TradingAgents `memory.py:13-14` no longer shows the
   `_SEPARATOR = "\n\n<!-- ENTRY_END -->\n\n"` constant — perhaps upstream refactored).
4. **STEP 0.4 surprise**: live-audit count for ANY sub-track is wildly different from plan
   expectations (e.g., W0-3 count = 50+ in production, or W0-5 P1b shows domain-layer
   contamination — implies a separate emergency-cleanup session is needed BEFORE shipping
   the hook).
5. **STEP 0.5 surprise**: ADR numbers D-062/D-063/D-064 already taken (main session created
   intervening ADRs).
6. **STEP 0.7 surprise**: pre-existing firing-test or pytest baseline is RED (any failing
   tests before this IMPL begins) — fix-on-red-baseline is M-S37 precedent.
7. **RM2 trigger**: token budget at end of W0-4 sub-track > 175K — STOP-AND-SPLIT per RM2
   mitigation.
8. **RM5 trigger**: `packages/_shared/path_safety.py` cannot be exempted from the path-safety
   hook itself (the hook's exclude-list mechanism is insufficient) — re-design needed.
9. **Helper-port semantic blocker** (RM8): Vibe-Trading's `safe_path` API has a hidden
   dependency on a Vibe-Trading-specific helper that doesn't exist in stockforge (e.g.,
   `_default_file_roots()` references Vibe-Trading `pyproject.toml` defaults that don't
   transfer) — STOP and redesign helper API before continuing.

Escalation channel: write
`agent-workspace/memory/observations/sandwich-dev-S33N+1-W0-3-4-5-bundle-AMBIGUOUS-<slug>.md`
+ `human-workspace/notifications/S33N+1-stop-ambiguous-<slug>.md`. Do not push 3 hooks +
helpers through a divergent state.

---

## Session sizing & budget estimate

**S33N+1 envelope target**: 150-200K tokens (proposed; MULTI_TASK_IMPL with 21 discrete tasks
across 3 sub-tracks). Master plan § 6.2 row gives "S332 | FOCUSED_IMPL / VERIFY | 100-200K"
— this bundle uses the upper edge.

**Breakdown** (architect estimate; dev refines empirically):

- STEP 0 pre-flight (7 sub-steps; full-file Reads of 2 upstream sources): ~15-20K
- **W0-3 sub-track**:
  - Hook authoring (~200 LOC bash): ~12-18K
  - Firing-test authoring (~280 LOC bash, ≥12 TC): ~15-22K
  - Hook self-test + iteration: ~3-5K
  - ADR D-062 authoring (~200 LOC markdown): ~6-10K
  - Sub-track close (live audit + session-log update): ~3-5K
  **W0-3 subtotal**: ~40-60K
- **W0-4 sub-track**:
  - Hook authoring (~160 LOC bash): ~10-15K
  - Firing-test authoring (~200 LOC bash, ≥10 TC): ~12-18K
  - Hook self-test + iteration: ~3-5K
  - ADR D-063 authoring: ~6-10K
  - Sub-track close: ~3-5K
  **W0-4 subtotal**: ~35-50K
- **W0-5 sub-track** (largest — 5 invariants + Python helper module):
  - Hook authoring (~220 LOC bash): ~15-22K
  - Firing-test authoring (~380 LOC bash, ≥15 TC): ~20-30K
  - Python helper module `packages/_shared/path_safety.py` (~180 LOC): ~10-15K
  - Python test module (~200 LOC, ≥15 tests): ~12-18K
  - Hook self-test + helper unit-test iteration: ~5-8K
  - ADR D-064 authoring (largest ADR — 5 invariants): ~8-12K
  - Sub-track close: ~3-5K
  **W0-5 subtotal**: ~75-110K
- **Bundle close**:
  - `.claude/settings.json` wire-up (3 hooks × 2 chains = 6 insertions in one coherent edit): ~3-5K
  - `bash scripts/hooks/firing-tests/run-all.sh` + bash-hook-lint full-tree + pytest full-suite + mypy + ruff: ~5-8K
  - Session log + current-execution update + mistake-log + observation file authoring: ~12-18K
  - Optional commit(s) per D-060: ~3-5K
  - Buffer for STOP-IF-AMBIGUOUS / RM2 split / unexpected lint or test noise: ~15-25K
  **Close subtotal**: ~38-61K

**Estimated total**: ~203-301K — **uncomfortably above the 200K upper edge**; this is the
risk RM2 (budget envelope breach). Mitigations:

(a) If dev can write all 3 hooks in tighter LOC budgets (~150 LOC each instead of 180-220),
    save ~10-15K.
(b) If dev parallelizes ADR authoring while running firing-test iterations (interleaved
    flow), save ~5-10K context-switching overhead.
(c) **Most likely mitigation**: RM2 STOP-AND-SPLIT — dev ships W0-3 + W0-4 in S33N+1, then
    dispatches a fresh-context S33N+2 dev for W0-5 alone (which is itself ~75-110K and a
    cleaner FOCUSED_IMPL fit).

**Architect recommendation to S328-main (the parent that dispatched this PLAN)**: dispatch
S33N+1 as MULTI_TASK_IMPL with explicit RM2 budget-tracking instruction. If dev tracks token
budget at W0-4 close and is >175K, split per RM2; otherwise proceed to W0-5 in same session.

---

## Promotion-or-retire note (post-S33N+2)

Once S33N+1 + S33N+2 close clean and Wave 0 substrate hits 5-of-5 complete (W0-1/1b/2/2.1/3+4+5):

1. **W0-2 D-059 WARN→BLOCKING ratchet** (line 218-224 of D-059 ADR) becomes the next
   promote-or-retire candidate. Requires ≥3 clean sessions of W0-2 hook running with 0
   violations — at S33N+2 close, we'll have W0-2 clean since S329. Need 1-2 more sessions
   to clear the gate.
2. **W0-3/4/5 ratchet** — each new hook ships WARN-only first 5 sessions per ADR section
   "Compliance enforcement"; promote to BLOCKING after clean run. Tracked in each ADR's
   "Compliance enforcement" section.
3. **Wave 0 closure milestone**: post-S33N+2 verify PASS, update master plan § 5.1 Theme F
   status from "60% done" to "100% done" (5/5 sub-tracks complete); update
   `current-execution.md` to reflect substrate-finish boundary.

All three are OUT OF SCOPE for S33N+1; flagged here for S33N+3+ planning cycle.

---

## Compliance Attestation block (S33N+1 dev fills at session end)

The S33N+1 dev MUST end the session log with a compliance attestation matching this template
(per AOM § Attestation discipline + CLAUDE.md § Session Protocol):

```
Compliance attestation (S33N+1 close):
- I-S1 NO-LLM-math: ✓ — all 3 hooks are deterministic regex/grep; ADRs contain no LLM-
  emitted numbers; helper module is pure Python with no LLM calls.
- I-S2 source+as-of cites: ✓ — every hook rule traces to deep-dive file:line; every ADR
  cites ≥6 source_evidence; helper module header attributes Vibe-Trading MIT 2026.
- I-S35 research-aid framing: ✓ — no thesis-output or financial-advice framing in any
  hook/ADR/helper; substrate-only work.
- Charter Principle 11 (firing-test mandate): ✓ — 3 new hooks + 3 new firing-tests = HH-10
  backlog delta zero.
- Charter Principle 8 (calibration over confidence): ✓ — each new ADR contains a
  WARN→BLOCKING ratchet section; promotion gated on empirical clean-session count.
- harness_priority_one: ✓ — this IS harness substrate work; closes Wave 0 substrate to 5/5.
- D-060 commit-policy: ✓ — N commits made (single-commit OR 3-commit per Coordination § B),
  0 pushes.
- AP-1 honored: S33N+2 verifier is fresh-context; this dev does NOT self-verify the DoD.
- VBW protocol: ✓ — STEP 0 confirmed upstream sources at HEAD; full-file Reads of
  TradingAgents `memory.py` + Vibe-Trading `path_utils.py` before authoring detector
  regexes.
- 0 charter / 0 constitution / 0 human-workspace writes (only notification files via 3
  hooks' idempotent fixed-name writes — which are within the hooks' authorized scope).
```

---

## Provenance — sources read by this S331 PLAN session

Per AOM + I-S2 (every claim sourced); files read at plan-authoring time (2026-05-15):

1. `agent-workspace/master-plans/2026-05-15-wave-1-research-integration.md` (FULL — § 1-11;
   especially § 4.13 TradingAgents fit, § 4.15 Vibe-Trading fit (the legacy "quad" wording
   pre-Q-INT-bis), § 5.1 Theme F substrate, § 6.2 phase ordering with S331 row).
2. `agent-workspace/memory/observations/master-planner-A-13-deepdive-TradingAgents.md`
   (FULL — § 0 lost-S259-reconstruction for W0-3 + W0-4 source evidence; § 2-5 architecture;
   § 7 anti-patterns).
3. `agent-workspace/memory/observations/master-planner-A-14-deepdive-TradingAgents-CN.md`
   (FULL — cross-check confirming the W0-3/W0-4 patterns are NOT unique to CN fork; also
   surfaces additional substrate considerations).
4. `agent-workspace/memory/observations/master-planner-A-15-deepdive-Vibe-Trading.md`
   (FULL — § 0 lost-S259-reconstruction confirming W0-5 5-invariant reality; § 2-5 helper
   API; § 6 MIT attribution; § 7 anti-patterns including #6 stale-docstring warning).
5. `agent-workspace/memory/observations/master-planner-A-10-deepdive-nautilus_trader.md`
   (PARTIAL — § 0-3; DST doctrine cross-reference for hook design template informing all 3
   sub-tracks).
6. `agent-workspace/memory/decisions/061-wave-1-integration-ratification.md` (FULL —
   confirmed D-061 ACCEPTED 2026-05-15T15:30+07:00 blanket-A; § Decision item 8 cites
   W0-3/4/5 ports as empirically-confirmed citation chains; § Decision item 1
   license-class filter).
7. `agent-workspace/session-plans/completed/017-S329-wave-0-W0-2.1-python-determinism-fixes.md`
   (FULL — closest-template shape for DC1..DC13 DoD-richness + STEP 0 + STOP-IF-AMBIGUOUS
   + Coordination + Compliance Attestation block).
8. `agent-workspace/session-plans/pending/014-S315-wave-0-W0-2-python-determinism-banned-patterns.md`
   (FULL — original W0-2 plan; closest hook-design template).
9. `agent-workspace/memory/current-execution.md` (FULL — confirmed S329 result row + Wave 0
   substrate progress + dispatch context S328-main → S331 sandwich-architect).
10. `agent-workspace/CLAUDE.md` (FULL — workspace contract + auto-mv rule + reading priority
    + anti-patterns).
11. `agent-workspace/constitution/harness-health-protocol.md` (PARTIAL — § 1 identity + § HH-10
    every-hook-has-firing-test rule).
12. `agent-workspace/constitution/severity-schema.md` (PARTIAL — § 1 4-level system + § 2
    mapping for hook ERR/WARN feed into severity-classifier).
13. `scripts/hooks/python-determinism-check.sh` (PARTIAL — header + hook design lines 1-100;
    template for the 3 new hooks).
14. `.claude/settings.json` (PARTIAL — Stop chain lines 405-510 to confirm insertion order;
    PostToolUse + PreToolUse boundary; existing `python-determinism-check.sh` at line 428).
15. `agent-workspace/memory/decisions/059-python-determinism-contract.md` (PARTIAL via D-061
    + plan 014 context — for the WARN→BLOCKING ratchet shape that the 3 new ADRs inherit).
16. `packages/infrastructure/influence/llm_recommendation_extractor.py:447-468` (single
    grep confirming a real W0-3 candidate `fname.write_text(payload, ...)` at line 466 —
    informs DC-AGG-12 expected counts).
17. `packages/domain/` glob check (Grep `os.path.|Path(|pathlib`) — confirmed 0 matches;
    domain layer pure per W0-5 P1b detector design.
18. `CLAUDE.md` + `PROJECT_CHARTER.md` (already in main context; charter Principle 11 +
    hard rules + Karpathy 4).
19. `Grep <!-- ENTRY_END -->` across full tree — confirmed 4 current usages all in
    `agent-workspace/research/` + 1 deep-dive observation file; `mistake-log.md` +
    `agent-notes.md` do NOT yet use separator (W0-4 cleanup-1 candidates).

---

## Architectural questions for human or successor architect

These items emerged during plan-authoring and are flagged for explicit consideration. NONE
block dispatch (all have architect-proposed defaults the dev can implement); flagged for
optional human review.

**AQ-1 — Helper module location**: `packages/_shared/path_safety.py` proposed. Alternative
locations considered:
- (A) `packages/_shared/path_safety.py` (RECOMMENDED — neutral "shared infrastructure" zone;
  parallels Vibe-Trading's `agent/src/tools/path_utils.py` placement).
- (B) `packages/infrastructure/_shared/path_safety.py` (infrastructure-layer-specific —
  but then domain layer can't import from it without crossing layer boundaries).
- (C) `apps/_shared/path_safety.py` (app-layer — wrong; domain + infrastructure also need it).

Default = (A). If human wants different, flag before dispatch.

**AQ-2 — Inline marker syntax consistency**: 3 different markers across sub-tracks:
- W0-3: `# atomic-write-ok: <rationale>`
- W0-4: `<!-- atomic-md-exempt: <rationale> -->`
- W0-5: `# path-safety-ok: <rationale>`

These differ because W0-4 is markdown (`<!-- -->` HTML comment) while W0-3/W0-5 are Python
(`#` line comment). Architect verdict: consistent prefix (`-ok:`) per L-S322-1 in-place
pattern; markup-language-appropriate wrapper. No change recommended.

**AQ-3 — `<!-- ENTRY_END -->` separator collision with `severity-classifier.sh`**: per RM4,
plan-authoring grep on `severity-schema.md § 2` shows line-by-line parsing is unaffected.
But the W0-4 cleanup (W0-4.1 future) will rewrite `mistake-log.md` + `agent-notes.md` with
separators inserted between entries — this is the empirical validation moment. Architect
flag: when W0-4.1 runs, verifier MUST re-run `severity-classifier.sh` against pre- and
post-cleanup versions and confirm byte-for-byte output equivalence. This is OUT-OF-SCOPE for
this bundle but flagged for the W0-4.1 plan.

**AQ-4 — RM2 STOP-AND-SPLIT decision authority**: who decides at W0-4 close whether to split?
- (A) S33N+1 dev decides autonomously based on the documented 175K threshold (RECOMMENDED).
- (B) S33N+1 dev escalates to main session for the decision.
- (C) Plan pre-decides (split is mandatory regardless of token count) — but that defeats the
  bundle rationale.

Default = (A) — the dev has the empirical context.

**AQ-5 — Master plan vs. D-061 wording divergence on "quad" vs "5-invariant"**: per RM9, the
master plan § 4.15 has "path-safety quad (4 patterns)" while D-061 § Decision item 8 has the
5-invariant wording. The dispatcher's dispatch brief (this conversation's first turn) also
flagged this divergence explicitly. Architect verdict: 5-invariant is correct per D-061
ratification + empirical A-15 § 0 evidence. Master plan § 4.15 should arguably be amended
post-bundle close to retroactively reflect the 5-invariant reality — but master-plan edits
are out-of-scope per the plan's hard rules ("no master-plan edits — D-061 ACCEPTED already
ratifies master-plan revisions"). Flagged as cosmetic gap for future master-plan-revision
session.

---

## End — plan ready for S33N+1 dispatch

Plan written. S33N+1 dev: read this file fully + read STEP 0's referenced files + apply the
recipes per sub-track. Verifier (S33N+2): run § "Verifier checklist" V1-V6 empirically.
Plan moves `pending/` → `completed/` after S33N+2 PASS.
