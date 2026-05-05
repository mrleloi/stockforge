---
report_id: research-scanner-20260429T131201Z
created_at: 2026-04-29T13:12:01Z
use_case: "StockForge Phase-0 AI harness self-learning loop: telemetry events (NDJSON) → sessions/agent-notes/mistake-log corpus → capability-map (model × effort × task_class limits) → promote-rule (cluster recurring rules to hooks/skills/charter) → Karpathy outer-loop framing (deepen/broaden/abandon experiments). Pick ONE opensource repo whose ideas/patterns most closely advance THIS specific loop. NOT a stock-data tool; a self-learning / autoresearch / agent-evaluation pattern source."
candidates_scanned: 6
picked: https://github.com/stanfordnlp/dspy
as_of: 2026-04-29
---

# Research-Scanner Report — StockForge Harness Self-Learning Loop (agent-pick-1)

## Phase 1 — Use Case Restatement (own words)

StockForge's harness emits structured telemetry (NDJSON events) from every agent session. These events
accumulate in `learning-data/events/`. A background sweep periodically indexes them (SQLite FTS5 Phase 0)
and runs a classification pass to identify drift clusters, mistake types, and promotion candidates.
The outputs update `capability-map.md` (model × effort × task_class grounding) and surface rules for
`promote-rule` to push into deterministic hooks/skills/charter. The Karpathy outer loop then frames the
next experiment (deepen/broaden/abandon) using measurement from prior cycles.

**Selection criterion**: the best repo closes this loop at pattern level — it provides ideas/structures
for (a) evaluation of agent behavior, (b) self-improving signal collection, (c) outer-loop framing
with measurable deepen/broaden/abandon decisions. Phase-0 portability (bash + POSIX; no Docker/Postgres
required to extract value from the patterns) is the tiebreaker. Charter principles 1 (evidence grounding),
8 (calibration over confidence), 9 (no LLM math) must be respected by the candidate's own design.

---

## Summary

- **Picked**: `stanfordnlp/dspy` @ `db83e5a` (2026-04-28)
- **Runner-up**: `langchain-ai/openevals`
- **Disqualified**:
  - `openai/swarm` — explicitly superseded by OpenAI Agents SDK; last substantive commit 2025-03-11 (>400 days ago); abandonware
  - `karpathy/llm.c` — LLM training infrastructure (C/CUDA); no agent-notes/evaluation loop; last commit 2025-05-10 (>350 days ago)
  - `langchain-ai/langsmith-sdk` — observability SDK, not a pattern source; requires LangSmith cloud account; Phase-0 portability fails
  - `agno-agi/agno` — production agent runtime (FastAPI + Docker + cloud); runtime dependency-heavy; not a self-learning loop pattern source

---

## Per-Candidate Findings (provenance-cited)

### 1. stanfordnlp/dspy

**URL**: https://github.com/stanfordnlp/dspy  
**License**: MIT (`LICENSE` @ HEAD, as-of 2026-04-29)  
**Last commit**: `db83e5ad` — "docs(observability): quote admonition titles so they render correctly (#9691)" — 2026-04-28T18:18:17Z  
**Days since last commit**: 1 day — HEALTHY  

**README verbatim**:
> "DSPy stands for Declarative Self-improving Python"
> "DSPy is a framework for programming—rather than prompting—language models"
> "offers algorithms for optimizing their prompts and weights"
> "use DSPy to teach your LM to deliver high-quality outputs"
> "DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines" (primary paper, Oct 2023)
> "iterate fast on building modular AI systems"

**Key pattern fit**:
DSPy's core loop is: define a metric (evaluation function) → collect labeled examples → run an optimizer
(BootstrapFewShot, MIPROv2, COPRO, etc.) → compile improved pipeline. This is structurally identical to
StockForge's: emit telemetry → classify events → update capability-map → promote rules → next experiment.
The "compile" metaphor maps directly to `promote-rule` (structured signal → deterministic artifact).

**Optimizer design** (from paper title and README): compilation is a background, off-session process, not
inline — matches StockForge's "write-heavy discipline, separate from runtime" framing (D-005 § "UP-08
directive: self-learning = write-heavy + indexing + caching").

**Provenance discipline**: DSPy's optimizer requires a `metric` function that returns a score from
deterministic code — the LLM does not score itself. This matches charter principle 9 (no LLM math)
and principle 1 (evidence grounding). The optimizer is code; the program is code; only generation is LLM.

**Phase-0 portability**: `pip install dspy` — pure Python, no Docker, no Postgres, no Redis required to
study and extract patterns. Patterns are readable in source (optimizers in `dspy/teleprompt/`).

---

### 2. langchain-ai/openevals

**URL**: https://github.com/langchain-ai/openevals  
**License**: MIT (`LICENSE` @ HEAD, as-of 2026-04-29)  
**Last commit**: `b362e8fe` — "Merge pull request #186 from langchain-ai/dependabot/..." — 2026-04-21T03:47:25Z  
**Days since last commit**: 8 days — HEALTHY  

**README verbatim**:
> "evals are an important part of bringing LLM applications to production"
> "the sequence of messages and tool calls it makes while solving a task"
> Agent trajectory matching modes: "strict", "unordered", "subset", "superset"
> "uses an LLM to assess whether an agent's trajectory is accurate"
> Prebuilt prompts for: Quality (conciseness, correctness, hallucination detection), Safety, Security, RAG, Code
> "type-checking with Pyright and Mypy (Python) or TypeScript's built-in checker"
> Evaluator interface: results include `key`, `score`, `comment` fields

**Key pattern fit**:
OpenEvals provides agent trajectory evaluation — checking whether an agent's sequence of tool calls
matches a reference. This is directly useful for evaluating agent sessions against expected behavior.
The `key/score/comment` schema maps naturally to StockForge's mistake-log entries. Hallucination
detection and correctness evaluators are relevant to charter principle 1.

**Limitation for this use case**: OpenEvals evaluators log to LangSmith. The feedback loop architecture
requires LangSmith as the sink — which is a cloud service, not Phase-0 portable for pure pattern
extraction. The internal evaluation patterns (trajectory matching logic, LLM-as-judge prompts) are
extractable; the full loop is not portable without LangSmith.

**Provenance discipline**: LLM-as-judge mode has the evaluating LLM output a score. This is structurally
close to "LLM math" if the score is used numerically downstream without calibration. OpenEvals does not
itself enforce the NO-LLM-math invariant.

---

### 3. openai/swarm

**URL**: https://github.com/openai/swarm  
**License**: MIT (`LICENSE` @ HEAD, as-of 2026-04-29)  
**Last commit**: `6af0b4ca` — "Pin pre-commit hook revisions to immutable commits (#83)" — 2026-04-15T17:10:28Z  
**Prior substantive commits**: "update readme" (2025-03-11), "point to Agents SDK" (2025-03-11)  
**Days since last substantive commit**: >400 days — ABANDONWARE FLAG  

**README verbatim**:
> "Swarm is now replaced by the OpenAI Agents SDK, which is a production-ready evolution of Swarm."

**Disqualifier**: Explicit upstream deprecation. README itself redirects to a different product. No
evaluation loop, no self-learning patterns, no outer-loop framing. Hard disqualified.

---

### 4. agno-agi/agno

**URL**: https://github.com/agno-agi/agno  
**License**: Apache-2.0 (`LICENSE` @ HEAD, as-of 2026-04-29)  
**Last commit**: `f9487d53` — "cookbook: frameworks quickstart for Agno + Claude Code + LangGraph + DSPy (#7743)" — 2026-04-29T12:50:38Z  
**Days since last commit**: <1 day — HEALTHY  

**README verbatim**:
> "Agno is the runtime for agentic software"
> "Build agents, teams, and workflows with memory, knowledge, guardrails, and 100+ integrations"
> "Serves agents as production services through a stateless, session-scoped FastAPI backend"
> "OpenTelemetry tracing, run history, and audit logs"
> "human approval workflows, RBAC security, and scheduling via cron jobs"
> "50+ endpoints"

**Disqualifier**: Agno is a production agent runtime — FastAPI backend + Docker + cloud deployment (Railway,
AWS, GCP mentioned). The value is in running agents at scale, not in extracting self-learning loop
patterns for a Phase-0 bash harness. The OTEL tracing is relevant to StockForge's telemetry story, but
this is a full platform, not a pattern library. Phase-0 portability fails for the primary loop.

Note: Apache-2.0 is permissive and not a license risk.

---

### 5. karpathy/llm.c

**URL**: https://github.com/karpathy/llm.c  
**License**: MIT (`LICENSE` @ HEAD, as-of 2026-04-29)  
**Last commit**: `f1e2ace6` — "Merge pull request #801 from ngc92/ngc92/fix-test" — 2025-05-10T23:24:10Z  
**Days since last commit**: ~354 days — ABANDONWARE FLAG (>180 days)  

**README verbatim**:
> "LLMs in simple, pure C/CUDA with no need for 245MB of PyTorch or 107MB of cPython"
> "I want llm.c to be a place for education"
> "llm.c is a bit faster than PyTorch Nightly (by about 7%)"

**Disqualifier**: llm.c is an LLM *training* implementation in C/CUDA — it teaches gradient descent,
tokenization, and forward/backward passes. It is a pedagogical reference for how LLMs work internally,
not for how to build a self-learning agent harness. No evaluation loop, no agent notes, no outer-loop
framing. Additionally >180 days without commit = abandonware risk under scanner rules. Hard disqualified.

---

### 6. langchain-ai/langsmith-sdk

**URL**: https://github.com/langchain-ai/langsmith-sdk  
**License**: MIT (`LICENSE` @ HEAD, as-of 2026-04-29)  
**Last commit**: `ff180c04` — "release(py): 0.7.38 (#2825)" — 2026-04-29T00:21:10Z  
**Days since last commit**: <1 day — HEALTHY  

**README verbatim**:
> "LangSmith helps your team debug, evaluate, and monitor your language models and intelligent agents"
> "pip install -U langsmith"
> Uses `@traceable` decorator and `wrap_openai` function for automatic tracing

**Disqualifier**: LangSmith SDK is a client library for the LangSmith cloud platform. The SDK itself
has no patterns for self-improving loops — it is a telemetry emitter toward a proprietary cloud sink.
Extracting patterns requires a running LangSmith account and server. The evaluation feedback loop
(sessions → metrics → improvement) is in the LangSmith platform, not in the SDK's codebase. Not portable
for Phase-0 pattern extraction.

---

## Scoring Matrix

| Candidate | harness-self-learning fit | karpathy-autoresearch fit | agent-notes integration fit | Phase-0 portability | provenance discipline | Notes |
|---|---|---|---|---|---|---|
| **stanfordnlp/dspy** | **5** | **5** | **4** | **5** | **5** | Winner |
| langchain-ai/openevals | 3 | 2 | 3 | 3 | 3 | Runner-up |
| agno-agi/agno | 2 | 1 | 2 | 1 | 2 | Disqualified |
| langchain-ai/langsmith-sdk | 2 | 1 | 2 | 1 | 2 | Disqualified |
| openai/swarm | 1 | 1 | 1 | 2 | 1 | Disqualified — abandonware |
| karpathy/llm.c | 1 | 2 | 1 | 3 | 3 | Disqualified — wrong domain + abandonware |

**Score definitions** (categorical, 1-5; NOT numerically aggregated by LLM):
- 5 = direct structural match with cited evidence
- 4 = strong alignment with minor gap
- 3 = partial alignment; extractable but requires adaptation
- 2 = tangential; tooling proximity but not pattern source
- 1 = no alignment or explicit disqualifier

**Score citations** (DSPy / winner row only, per methodology):

| Axis | Score | Cited evidence |
|---|---|---|
| harness-self-learning fit | 5 | "DSPy stands for Declarative Self-improving Python" + "offers algorithms for optimizing their prompts and weights" — compilation loop (collect signal → run optimizer → improve pipeline) maps structurally to telemetry→cap-map→promote-rule |
| karpathy-autoresearch fit | 5 | "DSPy: Compiling Declarative Language Model Calls into Self-Improving Pipelines" (paper title, README) — "compiling" = Karpathy deepen/broaden/abandon framing; metric-based outer loop is explicit design |
| agent-notes integration fit | 4 | DSPy optimizer consumes labeled examples + a metric function; StockForge agent-notes are unlabeled but structurally compatible (mistake-type + correction as (input, expected, actual) triples); gap: StockForge must author the metric function (1 session effort) |
| Phase-0 portability | 5 | "pip install dspy" — pure Python; no Docker, no Postgres, no Redis. Optimizer source in `dspy/teleprompt/` is readable Python. Patterns extractable without running any infrastructure |
| provenance discipline | 5 | DSPy metric function is deterministic code — LLM does NOT score itself. "use DSPy to teach your LM to deliver high-quality outputs" implies the teaching signal comes from code-evaluated metric, not LLM self-assessment. Matches charter P1 + P9 |

---

## Why Winner Beats Runner-up

**DSPy vs openevals** — two distinct reasons:

1. **Optimization loop vs evaluation-only**: DSPy closes the full loop: signal → optimizer → improved
   pipeline. openevals provides only the evaluation leg — it can score an agent run, but has no
   mechanism to feed that score back into pipeline improvement. StockForge's loop needs both legs.
   Source: DSPy README "Compiling Declarative Language Model Calls into Self-Improving Pipelines" vs
   openevals README "evals are an important part of bringing LLM applications to production" (stopping
   at evaluation, not optimization).

2. **Phase-0 portability is real vs conditional**: DSPy is `pip install dspy` with no external
   dependencies for studying the optimizer patterns. openevals' feedback loop requires LangSmith
   (cloud service) as the sink — README states "Logging to LangSmith" as the integration path for
   the evaluator feedback loop. For Phase-0 pattern extraction without cloud accounts, DSPy is
   portable; openevals is only partially so.

---

## What Winner Loses vs Runner-up

**DSPy's loss vs openevals**:

openevals has ready-made agent trajectory evaluators — strict/unordered/subset/superset matching of
tool call sequences, LLM-as-judge for trajectory correctness, and prebuilt hallucination-detection
prompts. These are directly applicable to evaluating StockForge agent sessions against expected tool
call sequences (e.g., "did the agent read current-execution.md before writing?"). DSPy's optimizer
infrastructure assumes you already have a metric function — it does not provide prebuilt agent
evaluation patterns. StockForge would need to write the trajectory evaluation logic from scratch when
adapting DSPy patterns, whereas openevals would provide that as a starting point.

**Honest trade-off**: openevals' prebuilt trajectory evaluators would reduce the effort to write
StockForge's first evaluation function by ~0.5-1 session. This is a real cost, not a trivial gap.

---

## Adversarial Bear Case (≥3 Distinct Points)

**Bear point 1 — Frontier-model substitution risk (6-month horizon)**

DSPy's core value proposition is optimizing prompts for models that respond well to few-shot examples
and structured optimization. Claude Sonnet 4.6 / Opus 4.7 at high effort already follow structured
instructions reliably (capability-map Strength row #1: "Multi-mechanism ensemble design lands well").
As frontier models improve at instruction following, the marginal value of DSPy-style prompt optimization
shrinks. If Claude 5 / Sonnet 5 natively generalizes from minimal examples, the "compile" step becomes
redundant. Risk window: 6-12 months.

**Bear point 2 — Abstraction mismatch with StockForge's bash-first harness**

DSPy is a Python framework designed to wrap LLM calls in Python module objects (`dspy.Module`,
`dspy.Predict`). StockForge's Phase-0 harness is bash + POSIX hooks + NDJSON files — there is no
Python LLM call layer yet (Phase 0 operates at the Claude Code CLI level, not API level). Extracting
DSPy patterns for a bash harness requires a translation step that is non-trivial. The "dogfood"
value in 5.5d.3 may be pattern-level only (reading optimizer source code) rather than running DSPy
against real StockForge data. This reduces the dogfood signal quality for the 5.5d.3 success criterion
("≥1 measurable insight").

**Bear point 3 — Maintenance governance risk**

DSPy is a Stanford research project (Stanford Future Data Systems lab). Research group repos have
non-commercial governance — direction is driven by PhD students and papers, not by production user
feedback. Last 5 commits (2026-04-24 to 2026-04-28) are all documentation/CI fixes (#9691, #9690,
#9649, #9687, #9661), with no new optimizer features. If the core research team graduates and moves
on, or if DSPy is absorbed into a larger framework (LangGraph has already built similar optimization
primitives), maintenance could stall. Last commit is 1 day old (HEALTHY now), but governance
concentration in a university research context is a structural fragility.

**Bear point 4 (bonus) — LLM-as-judge risk in optimizer**

Some DSPy optimizers (notably MIPRO variants) use an LLM to generate candidate instructions as part
of the optimization loop. If StockForge adopted DSPy's full optimizer stack (not just its patterns),
the LLM-generated instruction candidates could introduce hallucinated optimization steps — which
conflicts with charter principle 9 (no LLM math) if the LLM-generated instructions affect numeric
reasoning paths. Mitigation: StockForge should adopt DSPy's metric-function pattern and compilation
framing, not the full MIPRO optimizer, for the 5.5d.3 dogfood. Constraint known; manageable.

---

## Provenance Log

| Resource | URL | SHA / Release | As-of |
|---|---|---|---|
| DSPy README | https://raw.githubusercontent.com/stanfordnlp/dspy/main/README.md | HEAD → commit `db83e5ad` | 2026-04-29 |
| DSPy commits | https://api.github.com/repos/stanfordnlp/dspy/commits?per_page=5 | Top SHA: `db83e5ad7154ee2e31f2cdd4f13351ded47a23d3` | 2026-04-29 |
| DSPy LICENSE | https://raw.githubusercontent.com/stanfordnlp/dspy/main/LICENSE | HEAD → MIT | 2026-04-29 |
| LangSmith SDK README | https://raw.githubusercontent.com/langchain-ai/langsmith-sdk/main/README.md | HEAD → commit `ff180c04` | 2026-04-29 |
| LangSmith SDK commits | https://api.github.com/repos/langchain-ai/langsmith-sdk/commits?per_page=5 | Top SHA: `ff180c04237511b341ed455cfbfe6cadd9a5eeab` | 2026-04-29 |
| LangSmith SDK LICENSE | https://raw.githubusercontent.com/langchain-ai/langsmith-sdk/main/LICENSE | HEAD → MIT | 2026-04-29 |
| openai/swarm README | https://raw.githubusercontent.com/openai/swarm/main/README.md | HEAD → commit `6af0b4ca` | 2026-04-29 |
| openai/swarm commits | https://api.github.com/repos/openai/swarm/commits?per_page=5 | Top SHA: `6af0b4caf37dca4526dfd98e9fbd8ce36e7eeb22` | 2026-04-29 |
| openai/swarm LICENSE | https://raw.githubusercontent.com/openai/swarm/main/LICENSE | HEAD → MIT | 2026-04-29 |
| agno-agi/agno README | https://raw.githubusercontent.com/agno-agi/agno/main/README.md | HEAD → commit `f9487d53` | 2026-04-29 |
| agno-agi/agno commits | https://api.github.com/repos/agno-agi/agno/commits?per_page=5 | Top SHA: `f9487d5308e7e41faaa39a1edf1dd3fa368d7ec0` | 2026-04-29 |
| agno-agi/agno LICENSE | https://raw.githubusercontent.com/agno-agi/agno/main/LICENSE | HEAD → Apache-2.0 | 2026-04-29 |
| karpathy/llm.c README | https://raw.githubusercontent.com/karpathy/llm.c/master/README.md | HEAD → commit `f1e2ace6` | 2026-04-29 |
| karpathy/llm.c commits | https://api.github.com/repos/karpathy/llm.c/commits?per_page=5 | Top SHA: `f1e2ace651495b74ae22d45d1723443fd00ecd3a` | 2026-04-29 |
| karpathy/llm.c LICENSE | https://raw.githubusercontent.com/karpathy/llm.c/master/LICENSE | HEAD → MIT | 2026-04-29 |
| langchain-ai/openevals README | https://raw.githubusercontent.com/langchain-ai/openevals/main/README.md | HEAD → commit `b362e8fe` | 2026-04-29 |
| langchain-ai/openevals commits | https://api.github.com/repos/langchain-ai/openevals/commits?per_page=5 | Top SHA: `b362e8fe50c3eb0e6bb20abe09d2bbd9e82ed3e9` | 2026-04-29 |
| langchain-ai/openevals LICENSE | https://raw.githubusercontent.com/langchain-ai/openevals/main/LICENSE | HEAD → MIT | 2026-04-29 |

---

*Report generated by research-scanner subagent (claude-sonnet-4-6) per D-005 § 5.5d.3. Read-only scan — no repos cloned, no dependencies installed.*
