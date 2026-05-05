# human-workspace/ — Contract

> **Audience**: agents reading anything inside `human-workspace/`.
> **Established**: Decision 002 § Track 1 (Workspace Dualism Foundation).

## Identity

`human-workspace/` is the **human-authored authority** layer. Everything here represents **human decisions, scope, intent, and verification**. Agents READ this directory as authoritative; agents do NOT WRITE here except in one designated channel (`q-and-a/pending/` — where agents post questions for human to answer).

This separation exists because of a failure mode observed in the orch sister project (orch `decisions/040`, post-mortem CF-DOGFOOD-2): when human and agent share a single workspace without contract, agent silently overrides human-CRITICAL items via technical-defer logic. The user explicitly raised this concern in `human-workspace/user_prompt/20260429_02_init.txt` §1.1.

---

## Subdirectories

| Path | Purpose | Who writes |
|---|---|---|
| `user_prompt/` | Human's mid-flight scope/idea drops. Naming: `YYYYMMDD_NN_<slug>.txt`. Files are immutable post-creation (audit trail). | **Human only**. Agent: read-only. |
| `decisions/` | Human's strategic decisions (e.g., scope-lock, charter-revision-trigger, peer-share authorization). Format: `D-H-<NNN>-<slug>.md`. | **Human only**. Agent: read-only. |
| `q-and-a/pending/` | **The ONE channel where agent writes inside human-workspace**. Agent drops Q&A bundles per Grill Maximization doctrine; human responds inline or moves to `answered/`. | **Both** (agent writes new bundles; human writes answers). |
| `q-and-a/answered/` | Q&A bundles human has answered (with answers inline). Agent reads answers and acts. Archive forever; provenance trail. | **Human moves** (drag from `pending/`); agent reads. |
| `q-and-a/stale/` | Pending bundles that exceeded their `expected_answer_by` (default 24h, urgent 4h). Auto-moved by SessionStart hook (Track 5). | **Hook moves**; both read. |
| `notifications/` | Agent push to human — summaries, alerts, milestones. Format: `N-<TS>-<level>-<slug>.md`. Levels: INFO / SUMMARY / ALERT. | **Agent writes**; human reads. |

---

## Contract Rules (BINDING)

1. **Agent NEVER writes to `user_prompt/` or `decisions/`.** Permission deny. If something feels like a human decision but the human hasn't written it, dispatch a Q&A bundle into `q-and-a/pending/` instead.

2. **`user_prompt/` files are immutable post-creation.** Agent never deletes, renames, or edits these files. They are the audit trail of human interventions.

3. **Q&A bundle format** (per Track 4 spec): YAML frontmatter (`id`, `topic`, `opened_at`, `expected_answer_by`, `priority`, `related_decisions`, `status`) + question body + answer-fill section. Each bundle = up to 25 questions per Grill Maximization doctrine; split if more.

4. **Agent does not move files between `q-and-a/{pending,answered,stale}/`** — that's human's role (or hook's, in case of stale). Agent only WRITES new pending bundles and READS answers.

5. **Notifications are read-only for human.** Human shouldn't edit `notifications/*` files; if disagreement with notification content, drop a `user_prompt/` instead. Notifications are the agent's account of events.

6. **Provenance pointers**: every `agent-workspace/memory/decisions/D-<NNN>` should reference its source `human-workspace/user_prompt/<file>` or `human-workspace/decisions/D-H-<NNN>` if the agent's decision derives from human input.

7. **No multi-tenancy in this directory.** Per identity-scope.md (Track 7), stockforge is single-tenant Phase 0-5; if peer share happens it's via git-fork, each peer has their own `human-workspace/` per fork.

---

## Reading Priority for Agent

When loading session context (per `agent-workspace/constitution/autonomous-protocol.md` Track 7):

1. **All `user_prompt/*.txt`** — every prompt, not just most recent. Per orch lesson (decision-040 USER-CRITICAL tier): never silently defer human-CRITICAL items.
2. **All `decisions/*.md`** — human's strategic decisions are above charter principles in priority; charter is below human (charter was authored by human in the first place).
3. **Latest `q-and-a/answered/*`** — recent answers update agent's understanding.
4. **Open `q-and-a/pending/*`** — flag if waiting on human answers.
5. **Recent `notifications/*`** (last 7 days) — for situational awareness.

---

## Agent Self-Check

Before writing to `human-workspace/q-and-a/pending/`, ask:
- Is this question genuinely something the human must decide? (Charter principle / Charter-affecting / SCOPE-affecting / above ARCH-tier confidence threshold)
- Have I already grilled this in a recent bundle? (Don't ask twice; don't pollute pending/)
- Am I bundling per Grill Maximization (target 15-20 questions, max 25)? Or splintering across many small bundles?

If the answer to any is "I'm not sure" — DON'T write the bundle. Either answer it yourself with charter-principle reasoning + log decision, or wait until ambiguity clears.
