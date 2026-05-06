# /autonomous — Toggle Autonomous Mode (on/off/status)

> Created 2026-05-05 (S48 post-incident) per user request: "biến setting autonomous thành một dạng skill/command hay cấu hình nào để để human dễ dàng turn on/off thông qua prompt".
> Atomic toggle of TWO settings + stale marker cleanup. Single command for end-user.

## Usage

| Form | Effect |
|---|---|
| `/autonomous on` | Enable full-autonomous (continue-injector + budget-watchdog active) |
| `/autonomous off` | Disable autonomous (no auto-/clear+continue, no auto-reboot) |
| `/autonomous status` | Report current state (default if no arg) |
| `/autonomous` | Same as `/autonomous status` |

## What it changes (atomically)

Two settings must flip together — flipping only one leaves harness in inconsistent state (audit § DRC-3 + S48 incident root cause):

1. **`agent-workspace/memory/current-execution.md`** — field `**autonomous_mode**` (`true` / `false`)
   - Gates: `autonomous-stop-watchdog.sh:22` (Mode A/B/C/D detection); `session-start-bootstrap.sh:135` (continue-injector for `source=startup` only); 4+ other Stop/PostToolUse hook downstream consumers.
2. **`.claude/settings.json`** — env `STOCKFORGE_WATCHDOG_DISABLE` (`"1"` / `"0"`)
   - Gates: `budget-watchdog.sh:21` early-exit (auto-reboot at wind-down/cliff thresholds 180K/220K).

When turning ON, **also clear stale once-only markers** (otherwise watchdog won't refire):
- `agent-workspace/memory/.cliff-fired`
- `agent-workspace/memory/.wind-down`
- `agent-workspace/memory/.wind-down-fired`
- `agent-workspace/memory/.mode-{a,b,c,d}-recovery-fired-*`
- `agent-workspace/memory/.auto-reboot-FAILED`

## Agent execution instructions

### When user invokes `/autonomous on`

1. **Edit `agent-workspace/memory/current-execution.md`**:
   - Find line starting `**autonomous_mode**:` (search by exact prefix; use Grep first to locate exact line).
   - Replace `**autonomous_mode**: false (...)` → `**autonomous_mode**: true (RE-ENABLED YYYY-MM-DD via /autonomous on by user; previous DISABLED context preserved in checkpoints/latest.md + mistake-log)`.
   - Use Edit tool with sufficient context for uniqueness.

2. **Edit `.claude/settings.json`** env block:
   - Change `"STOCKFORGE_WATCHDOG_DISABLE": "1"` → `"STOCKFORGE_WATCHDOG_DISABLE": "0"`.

3. **Clear stale markers** (Bash):
   ```bash
   rm -f agent-workspace/memory/.cliff-fired \
         agent-workspace/memory/.wind-down \
         agent-workspace/memory/.wind-down-fired \
         agent-workspace/memory/.auto-reboot-FAILED 2>/dev/null
   rm -f agent-workspace/memory/.mode-*-recovery-fired-* 2>/dev/null
   ```

4. **Verify**:
   ```bash
   awk -F': ' '/^\*\*autonomous_mode\*\*/ {print $2; exit}' agent-workspace/memory/current-execution.md | awk '{print $1}'
   grep -E '"STOCKFORGE_WATCHDOG_DISABLE":\s*"[01]"' .claude/settings.json
   ```
   Both must return expected values (`true` / `"0"`). Abort + report if mismatch.

5. **Report (1-2 lines)**:
   `AUTONOMOUS ON — autonomous_mode=true; watchdog enabled (180K wind-down / 220K cliff); N stale markers cleared. Continue-injector + Mode-D auto-reboot now active.`

### When user invokes `/autonomous off`

1. **Edit `agent-workspace/memory/current-execution.md`**: replace `true → false` with annotation `(DISABLED YYYY-MM-DD via /autonomous off by user)`.

2. **Edit `.claude/settings.json`** env block: `"STOCKFORGE_WATCHDOG_DISABLE": "0"` → `"STOCKFORGE_WATCHDOG_DISABLE": "1"`.

3. **Verify** (same parse commands).

4. **Report**: `AUTONOMOUS OFF — autonomous_mode=false; watchdog disabled. Manual control: no auto-/clear, no auto-reboot, no continue-injector on source=startup. (User /clear still fires injector by design.)`

### When user invokes `/autonomous status` (or no arg)

1. **Read** autonomous_mode from current-execution.md (parse via awk).
2. **Read** STOCKFORGE_WATCHDOG_DISABLE from settings.json (grep).
3. **Read** stale marker files (`ls agent-workspace/memory/.cliff-fired .wind-down* .mode-*-recovery-fired-* 2>/dev/null`).
4. **Report 3-line state**:
   ```
   autonomous_mode: <true|false>
   watchdog_disable: <"0"|"1"|absent>
   stale_markers: <count or "none">
   inferred_state: <FULL_AUTONOMOUS | MANUAL | INCONSISTENT (mismatch — needs /autonomous on or off)>
   ```

## Hard rules

- This command bypasses NO other safety gate (`write-vs-edit-guard.sh`, drift-signals, charter immutability, etc. all still active).
- Re-enabling `autonomous_mode` does NOT auto-skip Phase 2.5 pre-condition checklist; the gating is doctrine-based, not deterministic. User judgment override.
- Any session ending with `autonomous_mode=true` respects all CLAUDE.md hard rules (NO LLM math, citations + as_of, etc.).
- This command itself is **not autonomous-mode-gated** — works regardless of current state (it IS the toggle).
- Toggle is **idempotent** — running `/autonomous on` when already on is no-op; same for off.

## Why a single command and not two settings?

Per audit `2026-05-05-harness-alignment-audit.md` § DRC-3 + S48 incident root cause: the two settings (`autonomous_mode` + `STOCKFORGE_WATCHDOG_DISABLE`) are coupled but live in different files. Separately editing them is error-prone and surfaces the inconsistent state where auto-reboot fires despite "autonomous off" because watchdog still has env var. Single atomic toggle eliminates this footgun.

## Companion docs

- Audit: `agent-workspace/memory/observations/2026-05-05-harness-alignment-audit.md`
- Root cause: `agent-workspace/memory/observations/2026-05-05-root-cause-3-axes.md`
- Phase 2.5 plan (where this command was conceived): `agent-workspace/session-plans/pending/009-S48-harness-hardening-middle-phase.md`
