# Classification Heuristics — Deterministic vs LLM-Required vs Hybrid

> Reference for `decompose-work` skill. Used at Process step 3.

## Decision Tree

```
Sub-task arrives
│
├─ Output is countable / parseable / verifiable byte-equal?
│  ├─ YES → DETERMINISTIC candidate
│  │  ├─ Tool exists in: Bash | Grep | Glob | Read | node oneliner | existing hook?
│  │  │  ├─ YES → DETERMINISTIC (assign tool)
│  │  │  └─ NO → can a 20-line script be written? YES → DETERMINISTIC; NO → HYBRID
│  └─ NO → continue
│
├─ Requires multi-source synthesis / cross-reference / arbitration?
│  └─ YES → LLM-REQUIRED
│
├─ Requires creative naming / design / interface choice?
│  └─ YES → LLM-REQUIRED
│
├─ Requires interpretation of ambiguous user intent or domain context?
│  └─ YES → LLM-REQUIRED
│
├─ Requires calibration judgment ("is this confidence too high")?
│  └─ YES → LLM-REQUIRED
│
├─ Has both a deterministic gate AND a judgment escalation?
│  └─ YES → HYBRID (gate first, escalate on miss)
│
└─ Default: LLM-REQUIRED (if uncertain, treat as LLM; cheaper to demote later than to over-trust scripts)
```

## DETERMINISTIC — concrete signals

| Signal | Tool |
|---|---|
| count files / lines / matches | `wc -l`, `grep -c` |
| find files by name | `Glob`, `find` |
| extract by regex | `grep -oE`, `awk`, `sed` |
| parse JSON/YAML | `node -e 'JSON.parse(...)'`, `yq` |
| validate schema | JSONSchema validator, `node -e` |
| compute hash / dedup | `sha256sum`, `sort -u` |
| binary diff / file equality | `diff`, `cmp` |
| date/timestamp arithmetic | `date -d`, `awk` |
| copy / move / rename | `cp`, `mv`, `Edit/Write` |
| token-level similarity (≥0.7) | bash + jaccard or simple n-gram |
| run linter / type-checker / test | `ruff`, `mypy`, `pytest` |
| URL / regex / email validation | regex matchers |

If sub-task fits one of these, classify DETERMINISTIC. Don't burn LLM cycles.

## LLM-REQUIRED — concrete signals

| Signal | Why |
|---|---|
| "synthesize", "summarize", "interpret" | multi-source narrative judgment |
| "design", "architect", "name" | creative interface choice |
| "decide between A/B/C" with ambiguous criteria | judgment under uncertainty |
| "explain to user" | communication-style judgment |
| "is this confidence calibrated?" | meta-cognition over numeric data |
| "extract claims with provenance from Vietnamese news" | unstructured-text extraction |
| "draft thesis with bull + bear" | adversarial multi-perspective |
| "rephrase this rule for clarity" | linguistic judgment |
| "is this drift soft or hard?" | classification with fuzzy boundaries |

If sub-task fits one of these, classify LLM-REQUIRED. Don't try to script the judgment.

## HYBRID — concrete signals

| Signal | Pattern |
|---|---|
| "auto-classify if confidence ≥X else escalate" | gate first, LLM on miss |
| "extract claims (deterministic structure) + reason about implications (LLM)" | sequence: extractor → reasoner |
| "validate format then judge semantic correctness" | layer 1 deterministic, layer 2 LLM |
| "LLM proposes regex; bash applies it" | LLM authors → deterministic executes |
| "deterministic clusters; LLM names the cluster" | similarity → naming |

Hybrid = explicit handoff point. Document where the gate lives + what triggers escalation.

## Edge Cases

- **"Code generation"** — splits: design+naming = LLM, lint+test+typecheck = deterministic, integration choice = LLM.
- **"Search and replace"** — pure regex = DETERMINISTIC; semantic-aware (rename one usage but not the other) = LLM-REQUIRED.
- **"Run subagent"** — dispatch is deterministic; subagent's work is recursively decomposable.
- **"Read this file"** — DETERMINISTIC (no judgment). But "summarize this file" = LLM-REQUIRED.
- **"Verify the spec is satisfied"** — split: file existence + LOC + schema = DETERMINISTIC; semantic alignment with user intent = LLM-REQUIRED.

## Calibration Caveats

- **Stockforge invariant I-S1: NO LLM math.** All numerical computation is DETERMINISTIC, no exceptions. Even "estimate ~X%" is forbidden — if a number is needed, code computes it.
- **No-LLM-math edge case**: counting, classification confidence scoring, simple arithmetic all go to deterministic. LLM only INTERPRETS the numbers.
- **Provenance enforcement is DETERMINISTIC**: "every claim has source + as-of date" = bash regex grep on output, not LLM self-check.

## Anti-Patterns to Spot

- **Phantom determinism**: "I'll write a regex for sentiment classification" — sentiment is fuzzy, regex won't generalize, classify LLM.
- **Phantom LLM**: "I'll have the LLM count occurrences of X" — that's deterministic, use grep.
- **Hybrid that's actually LLM**: "auto-classify based on confidence" — but the confidence itself was LLM-judged. Then it's LLM-REQUIRED with self-rating, not hybrid.

## Cite

- D-003 § 5.5c.1 — strategic context
- UP-06 §3 — verbatim user directive
- I-S1, I-S20 (charter) — no-LLM-math invariant
- AP-23 (patterns-discovered) — deterministic hooks = Guardian; LLM Guardian only at session-end aggregation
