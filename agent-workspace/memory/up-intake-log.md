# UP Intake Log

> Append-only ledger of every `human-workspace/user_prompt/*.txt` intake + its resolution status.
> Cross-checked by `scripts/hooks/stale-prompt-detector.sh` (UserPromptSubmit hook) on each prompt.
> If user prompt references a CLOSED `UP-NN`, hook emits warning so agent surfaces closure first.
>
> **Schema** (per row):
> - `up_id`: identifier (`UP-NN` matching filename suffix)
> - `path`: source file
> - `intake_date`: date received
> - `status`: `open` | `in-progress` | `closed-by-D-NNN` | `superseded-by-UP-NN`
> - `closed_at`: date closed (if closed)
> - `topic`: 1-line summary
>
> **Update protocol**: append entry on intake; update `status` field on closure (in-place edit allowed).
> Created S7 (2026-04-29) per UP-07 follow-up "stale-prompt detection" bonus scope.

---

## Active Entries

```yaml
- up_id: UP-01
  path: human-workspace/user_prompt/20260429_01_init.txt
  intake_date: 2026-04-29
  status: closed-by-D-001
  closed_at: 2026-04-29
  topic: "Orch vs Claude-Code-native scaffold decision; pause orch dev"

- up_id: UP-02
  path: human-workspace/user_prompt/20260429_02_init.txt
  intake_date: 2026-04-29
  status: closed-by-D-002
  closed_at: 2026-04-29
  topic: "Workspace dualism + provenance + auto-detect drift; first Phase 0 harness design"

- up_id: UP-03
  path: human-workspace/user_prompt/20260429_03.txt
  intake_date: 2026-04-29
  status: closed-by-D-002
  closed_at: 2026-04-29
  topic: "S2-S3 round 3 follow-up — defer-all-non-MVP defaults; pre-amendment delta summary"

- up_id: UP-04
  path: human-workspace/user_prompt/20260429_04.txt
  intake_date: 2026-04-29
  status: closed-by-D-002
  closed_at: 2026-04-29
  topic: "Charter-tier B1 confirmation: AskUserQuestion is PRIMARY Q&A channel (not file-based)"

- up_id: UP-05
  path: human-workspace/user_prompt/20260429_05.txt
  intake_date: 2026-04-29
  status: closed-by-D-002
  closed_at: 2026-04-29
  topic: "AskUserQuestion 4-question limit; --dangerously-skip-permissions hard-limits; raw-session export"

- up_id: UP-06
  path: human-workspace/user_prompt/20260429_06.txt
  intake_date: 2026-04-29
  status: closed-by-D-003
  closed_at: 2026-04-29
  topic: "Sync infrastructure as top priority; layer separation; karpathy autoresearch full"

- up_id: UP-07
  path: human-workspace/user_prompt/20260429_07.txt
  intake_date: 2026-04-29
  status: closed-by-D-004
  closed_at: 2026-04-29
  topic: "Recalibrate 250K context-reboot threshold for Opus 4.7 — research-driven 180K/220K/250K band"

- up_id: UP-08
  path: human-workspace/user_prompt/20260429_08.txt
  intake_date: 2026-04-29
  status: closed-by-D-005
  closed_at: 2026-04-29
  topic: "Self-learning/upgrade pipeline = write-heavy data-ETL discipline; queue+event-driven background processing isolated from runtime; karpathy autoresearch + opensource integration; add to plan EARLY"
  intake_session: S8
  routed_to: "S9 PLAN — SCOPE-tier amendment ratified via D-005 (Track 5.5d insertion)"
  ratification_session: S9
  user_directive_phrase: "keep full autonomous"
```

---

## Closure Verification

Every `closed-by-D-NNN` entry must reference an existing decision file at `agent-workspace/memory/decisions/<NNN>-*.md` with `status: ACCEPTED`. Validation:

```bash
# Quick check (manual or hook):
for d in $(grep -oE 'D-[0-9]+' agent-workspace/memory/up-intake-log.md | sort -u); do
  num=$(echo "$d" | sed 's/D-//')
  ls agent-workspace/memory/decisions/${num}-*.md 2>/dev/null || echo "MISSING: $d"
done
```

---

## How Hook Reads This File

`scripts/hooks/stale-prompt-detector.sh` parses user prompt for patterns matching `UP-[0-9]+` / `D-[0-9]+` / `Track [0-9]+(\.[0-9a-z]+)?` / `S[0-9]+`. For each match:

1. Look up `up_id` in this file's YAML block
2. If `status: closed-*` → emit `<system-reminder>` to agent: "WARNING: prompt references closed {UP-N} via {D-NNN}; surface closure status before re-doing work"
3. If `status: open|in-progress` → no warning (proceed normally)
4. If `up_id` not found → no warning (might be a new UP being introduced this session; agent decides)

The hook is non-blocking — it only injects a system-reminder. Agent retains discretion to re-do work if user's intent is genuinely "redo with new info".
