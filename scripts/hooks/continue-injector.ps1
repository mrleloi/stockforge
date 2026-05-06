# continue-injector.ps1 — spawned by SessionStart hook in FRESH session (after /new).
# Waits for new TUI input field to settle, sends "continue" + Enter so fresh session's LLM
# gets first user prompt and begins autonomous resume loop.
# Ported from orch v2.2.0 (verbatim).

param(
    [int]$InitialDelayMs = 2500,
    [int]$RetryCount = 3,
    [int]$RetryDelayMs = 3000,
    [string]$LogFile = ""
)

$ErrorActionPreference = "Continue"

if (-not $LogFile) {
    $ProjectDir = (Get-Item $PSScriptRoot).Parent.Parent.FullName
    $LogDir = Join-Path $ProjectDir "agent-workspace\memory\handoff-logs"
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    $LogFile = Join-Path $LogDir ("continue-injector-{0}.log" -f (Get-Date -Format "yyyyMMddTHHmmssZ"))
}
function Log($msg) { Add-Content -Path $LogFile -Value ("[{0}] {1}" -f (Get-Date -Format "o"), $msg) }

Log "start pid=$PID initialDelay=$InitialDelayMs retries=$RetryCount retryDelay=$RetryDelayMs"

Start-Sleep -Milliseconds $InitialDelayMs

Add-Type -AssemblyName System.Windows.Forms
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class Win32 {
  [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
  [DllImport("user32.dll")] public static extern IntPtr GetForegroundWindow();
  [DllImport("user32.dll")] public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int lpdwProcessId);
}
"@

function Try-FocusClaudeTerminal {
    try {
        $claudes = Get-Process claude -ErrorAction SilentlyContinue
        if (-not $claudes) { Log "no claude.exe running"; return $false }

        foreach ($c in $claudes) {
            try {
                $parentId = (Get-CimInstance Win32_Process -Filter "ProcessId = $($c.Id)" -ErrorAction Stop).ParentProcessId
                if (-not $parentId) { continue }
                $parent = Get-Process -Id $parentId -ErrorAction SilentlyContinue
                if (-not $parent) { continue }
                Log ("claude pid={0} parent={1}({2}) mainWnd=0x{3:X}" -f $c.Id, $parent.ProcessName, $parent.Id, [int64]$parent.MainWindowHandle)
                if ($parent.MainWindowHandle -ne [IntPtr]::Zero) {
                    [Win32]::ShowWindow($parent.MainWindowHandle, 9) | Out-Null
                    [Win32]::SetForegroundWindow($parent.MainWindowHandle) | Out-Null
                    Start-Sleep -Milliseconds 400
                    return $true
                }

                $cur = $parent
                $hops = 0
                while ($cur -and $hops -lt 6) {
                    $hops++
                    try {
                        $curParentId = (Get-CimInstance Win32_Process -Filter "ProcessId = $($cur.Id)" -ErrorAction Stop).ParentProcessId
                    } catch { break }
                    if (-not $curParentId) { break }
                    $curParent = Get-Process -Id $curParentId -ErrorAction SilentlyContinue
                    if (-not $curParent) { break }
                    Log ("claude-ancestor hop {0} pid={1} name={2} mainWnd=0x{3:X}" -f $hops, $curParent.Id, $curParent.ProcessName, [int64]$curParent.MainWindowHandle)
                    if ($curParent.MainWindowHandle -ne [IntPtr]::Zero) {
                        [Win32]::ShowWindow($curParent.MainWindowHandle, 9) | Out-Null
                        [Win32]::SetForegroundWindow($curParent.MainWindowHandle) | Out-Null
                        Start-Sleep -Milliseconds 400
                        return $true
                    }
                    $cur = $curParent
                }
            } catch { Log "parent-walk error: $_" }
        }

        Log "no claude.exe ancestor has valid window; refusing fallback to random terminal (L-S48-1 bug: prior code grabbed first WindowsTerminal/cmd/bash with valid hwnd, typed continue into unrelated user windows under multi-claude conditions)"
    } catch { Log "focus error: $_" }
    return $false
}

function Send-Continue {
    try {
        [System.Windows.Forms.SendKeys]::SendWait("continue")
        Start-Sleep -Milliseconds 150
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        return $true
    } catch { Log "SendKeys error: $_"; return $false }
}

$ProjectDir = (Get-Item $PSScriptRoot).Parent.Parent.FullName

# Hard global rate-limit (covers ALL entry points: bootstrap startup/clear/resume + Mode-A/B/C/D
# recovery). Prevents bootstrap touching .session-ready on every SessionStart from generating a
# fresh idempotency tick that lets another injector fire seconds after the previous. Empirical
# trigger 2026-05-05: 180 injector spawns + 160 SessionStarts in single morning, sustained
# wrong-window "continue" typing into user TUI. See agent-workspace/memory/agent-notes.md L-S48-1.
$RateLimitMarker = Join-Path $ProjectDir "agent-workspace\memory\.continue-injector-last-fire"
if (Test-Path $RateLimitMarker) {
    $LastFire = (Get-Item $RateLimitMarker -ErrorAction SilentlyContinue).LastWriteTime
    if ($LastFire) {
        $AgeSeconds = ((Get-Date) - $LastFire).TotalSeconds
        if ($AgeSeconds -lt 60) {
            Log ("rate-limit: another injector fired {0:N1}s ago (<60s); exiting" -f $AgeSeconds)
            exit 0
        }
    }
}
Set-Content -Path $RateLimitMarker -Value (Get-Date -Format "o") -ErrorAction SilentlyContinue

# Per-tick idempotency was REMOVED at S53 (M-S53-3 fix). Rationale:
# Original design (L-S48-1) gated on `.session-ready` mtime → SessionTag advanced only on
# SessionStart events (`/clear`, fresh launch, `claude --resume`). Within a single session,
# SessionTag NEVER changes → first injector fire writes `.continue-fired-{Tag}` → ALL
# subsequent autonomous Stop→Mode-D→continue-injector handoffs hit "already fired" silent
# exit → autonomous-full loop dead within session boundaries. Smoking gun S53 19:59→20:16:
# Mode-D fired correctly but injector silent-exited because per-tick marker was carried
# over from prior bootstrap fire 16min earlier.
#
# Replacement contract (post-S53):
#   - 60s rate-limit (above) handles burst-spam within single SessionStart event
#   - Each caller has its OWN per-event idempotency marker:
#     - bootstrap (SessionStart): one fire per SessionStart event (no marker; bootstrap
#       itself only fires once per SessionStart)
#     - Mode-A (API truncation): `.api-truncation-recovery-fired-$RECOVERY_KEY`
#     - Mode-C (premature wind-down): `.mode-c-recovery-fired-$MODE_C_KEY`
#     - Mode-D (clean handoff): `.mode-d-recovery-fired-$MODE_D_KEY`
#   - Cross-caller: 60s rate-limit ensures no two callers fire injector within 60s window
# The L-S48-1 incident scenario (180 spawns + 160 SessionStarts in one morning) is fully
# covered by the 60s rate-limit since spawns averaged ~30-40 min apart well above 60s.
$SessionTag = "post-S53-no-per-tick"

$Sent = $false
for ($i = 1; $i -le $RetryCount; $i++) {
    Log "attempt $i/$RetryCount"
    $focused = Try-FocusClaudeTerminal
    if (-not $focused) {
        Log ("skip attempt {0}: no verified claude TUI window; will not type into foreground (L-S48-1 prevention)" -f $i)
        if ($i -lt $RetryCount) { Start-Sleep -Milliseconds $RetryDelayMs }
        continue
    }
    $fg = [Win32]::GetForegroundWindow()
    [int]$pid_fg = 0
    [Win32]::GetWindowThreadProcessId($fg, [ref]$pid_fg) | Out-Null
    $fgProc = Get-Process -Id $pid_fg -ErrorAction SilentlyContinue
    Log ("foreground pid={0} name={1}" -f $pid_fg, ($fgProc.ProcessName))
    if (Send-Continue) {
        Log "continue+Enter sent (attempt $i)"
        $Sent = $true
        break
    } else {
        Log "send failed (attempt $i)"
    }
    if ($i -lt $RetryCount) { Start-Sleep -Milliseconds $RetryDelayMs }
}

Log ("injector done sent={0}" -f $Sent)
