# session-self-reboot.ps1 - send /new to current Claude Code TUI window.
# Invoked by hooks (budget-watchdog.sh wind-down/cliff + autonomous-stop-watchdog.sh Mode-B).
# Ported from orch v2.2.0 (verbatim).
#
# Robustness: walks own parent chain (S1) -> claude.exe ancestor in same session (S2) ->
# any visible terminal (S3). AttachThreadInput bypasses foreground-stealing. Tolerant to
# "Access is denied" race + locked-desktop (LockApp/LogonUI/Idle in foreground).

param(
    [int]$InitialDelayMs = 400,
    [int]$RetryCount = 4,
    [int]$RetryDelayMs = 800,
    [string]$LogFile = "",
    [string]$FirstPrompt = ""
)

$ErrorActionPreference = "Continue"

if (-not $LogFile) {
    $ProjectDir = (Get-Item $PSScriptRoot).Parent.FullName
    $LogDir = Join-Path $ProjectDir "agent-workspace\memory\handoff-logs"
    New-Item -ItemType Directory -Force -Path $LogDir | Out-Null
    $LogFile = Join-Path $LogDir ("session-self-reboot-{0}.log" -f (Get-Date -Format "yyyyMMddTHHmmssZ"))
}
function Log($msg) { Add-Content -Path $LogFile -Value ("[{0}] {1}" -f (Get-Date -Format "o"), $msg) }

Log "start pid=$PID retries=$RetryCount"
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
  [DllImport("user32.dll")] public static extern bool BringWindowToTop(IntPtr hWnd);
  [DllImport("user32.dll")] public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);
  [DllImport("kernel32.dll")] public static extern uint GetCurrentThreadId();
}
"@

function Find-AncestorWindow {
    $mySessionId = (Get-CimInstance Win32_Process -Filter "ProcessId=$PID" -ErrorAction SilentlyContinue).SessionId

    # S1: walk from $PID
    try {
        $current = $PID
        for ($i = 0; $i -lt 12 -and $current -gt 0; $i++) {
            $proc = Get-Process -Id $current -ErrorAction SilentlyContinue
            if ($proc) {
                Log ("S1 hop {0} pid={1} name={2} hwnd=0x{3:X}" -f $i, $current, $proc.ProcessName, [int64]$proc.MainWindowHandle)
                if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
                    return @{ Handle = $proc.MainWindowHandle; ProcessName = $proc.ProcessName; Pid = $current; Strategy = "S1-ancestor" }
                }
            }
            $cim = Get-CimInstance Win32_Process -Filter "ProcessId=$current" -ErrorAction SilentlyContinue
            if (-not $cim) { Log "S1 no CIM record for $current (intermediate exited)"; break }
            $current = [int]$cim.ParentProcessId
        }
    } catch { Log "S1 error: $_" }

    # S2: walk from claude.exe in same session
    try {
        $claudes = Get-Process claude -ErrorAction SilentlyContinue
        foreach ($c in $claudes) {
            $cSess = (Get-CimInstance Win32_Process -Filter "ProcessId=$($c.Id)" -ErrorAction SilentlyContinue).SessionId
            if ($cSess -ne $mySessionId) { continue }
            $current = $c.Id
            for ($i = 0; $i -lt 8 -and $current -gt 0; $i++) {
                $proc = Get-Process -Id $current -ErrorAction SilentlyContinue
                if ($proc) {
                    Log ("S2 hop {0} pid={1} name={2} hwnd=0x{3:X}" -f $i, $current, $proc.ProcessName, [int64]$proc.MainWindowHandle)
                    if ($proc.MainWindowHandle -ne [IntPtr]::Zero) {
                        return @{ Handle = $proc.MainWindowHandle; ProcessName = $proc.ProcessName; Pid = $current; Strategy = "S2-claude-ancestor" }
                    }
                }
                $cim = Get-CimInstance Win32_Process -Filter "ProcessId=$current" -ErrorAction SilentlyContinue
                if (-not $cim) { Log "S2 no CIM record for $current"; break }
                $current = [int]$cim.ParentProcessId
            }
        }
    } catch { Log "S2 error: $_" }

    # S3: any visible terminal in same session
    try {
        $terminals = @("WindowsTerminal","mintty","ConsoleWindowHost","wt","pwsh","powershell","cmd","bash")
        foreach ($name in $terminals) {
            $matches = Get-Process $name -ErrorAction SilentlyContinue | Where-Object { $_.MainWindowHandle -ne [IntPtr]::Zero }
            foreach ($p in $matches) {
                $pSess = (Get-CimInstance Win32_Process -Filter "ProcessId=$($p.Id)" -ErrorAction SilentlyContinue).SessionId
                if ($pSess -eq $mySessionId) {
                    Log ("S3 candidate {0} pid={1}" -f $name, $p.Id)
                    return @{ Handle = $p.MainWindowHandle; ProcessName = $p.ProcessName; Pid = $p.Id; Strategy = "S3-terminal-fallback" }
                }
            }
        }
    } catch { Log "S3 error: $_" }
    return $null
}

function Activate-Window([IntPtr]$hwnd) {
    try {
        $fgHwnd = [Win32]::GetForegroundWindow()
        [int]$fgPid = 0
        $fgTid = [Win32]::GetWindowThreadProcessId($fgHwnd, [ref]$fgPid)
        $myTid = [Win32]::GetCurrentThreadId()
        $attached = $false
        if ($fgTid -ne 0 -and $fgTid -ne $myTid) {
            [Win32]::AttachThreadInput($myTid, $fgTid, $true) | Out-Null
            $attached = $true
        }
        [Win32]::ShowWindow($hwnd, 9) | Out-Null
        [Win32]::BringWindowToTop($hwnd) | Out-Null
        [Win32]::SetForegroundWindow($hwnd) | Out-Null
        if ($attached) { [Win32]::AttachThreadInput($myTid, $fgTid, $false) | Out-Null }
        Start-Sleep -Milliseconds 350
        return $true
    } catch { Log "activate error: $_"; return $false }
}

function Send-NewCommand {
    try {
        [System.Windows.Forms.SendKeys]::SendWait("/new")
        Start-Sleep -Milliseconds 200
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        return $true
    } catch { Log ("SendKeys error: " + $_.Exception.Message); return $false }
}

function Is-Desktop-Locked {
    param([string]$fgName, [int]$fgPid)
    if ($fgPid -le 4) { return $true }
    $blocked = @("LockApp","LogonUI","Winlogon","WerFault","ApplicationFrameHost+lock")
    foreach ($n in $blocked) { if ($fgName -ieq $n.Split('+')[0]) { return $true } }
    return $false
}

# Clear stale ready marker so fresh session SessionStart hook re-fires continue-injector.
$ProjectDir = (Get-Item $PSScriptRoot).Parent.FullName
$ReadyMarker = Join-Path $ProjectDir "agent-workspace\memory\.session-ready"
Remove-Item $ReadyMarker -ErrorAction SilentlyContinue
Get-ChildItem (Join-Path $ProjectDir "agent-workspace\memory") -Filter ".continue-fired-*" -ErrorAction SilentlyContinue |
    Remove-Item -ErrorAction SilentlyContinue

$target = Find-AncestorWindow
if (-not $target) {
    Log "ALL 3 STRATEGIES FAILED - no target window"
    $EscDir = Join-Path $ProjectDir "agent-workspace\memory"
    $EscMarker = Join-Path $EscDir ".auto-reboot-FAILED"
    Set-Content -Path $EscMarker -Value (
        "AUTO-REBOOT FAILED at " + (Get-Date -Format "o") + "`n" +
        "Reason: could not locate target terminal window (S1+S2+S3 all failed).`n" +
        "Action required: human/LLM must MANUALLY type /new in the Claude Code TUI.`n" +
        "Logfile: " + $LogFile + "`n"
    ) -ErrorAction SilentlyContinue
    Log "session-self-reboot done success=False reason=no-window-all-strategies-failed"
    exit 0
}
Log ("target window: pid=" + $target.Pid + " name=" + $target.ProcessName + " hwnd=0x" + ("{0:X}" -f [int64]$target.Handle) + " via=" + $target.Strategy)

$success = $false
$lockObserved = $false
for ($i = 1; $i -le $RetryCount; $i++) {
    Log "attempt $i/$RetryCount"
    Activate-Window $target.Handle | Out-Null

    $fg = [Win32]::GetForegroundWindow()
    [int]$fgPid = 0
    [Win32]::GetWindowThreadProcessId($fg, [ref]$fgPid) | Out-Null
    $fgProc = Get-Process -Id $fgPid -ErrorAction SilentlyContinue
    $fgName = if ($fgProc) { $fgProc.ProcessName } else { "?" }
    Log ("foreground pid=" + $fgPid + " name=" + $fgName)

    if (Is-Desktop-Locked -fgName $fgName -fgPid $fgPid) {
        $lockObserved = $true
        Log ("DESKTOP LOCKED -- foreground=" + $fgName + " pid=" + $fgPid + " -- SendKeys will fail until unlock")
        if ($i -lt $RetryCount) { Start-Sleep -Milliseconds 3000 }
        continue
    }

    if (Send-NewCommand) {
        Log "/new+Enter sent on attempt $i"
        $success = $true
        break
    } else {
        Log "send failed on attempt $i"
    }
    if ($i -lt $RetryCount) { Start-Sleep -Milliseconds $RetryDelayMs }
}

$reason = if ($success) { "ok" } else { if ($lockObserved) { "desktop-locked-during-all-retries" } else { "sendkeys-all-attempts-failed" } }
Log ("session-self-reboot done success=" + $success + " reason=" + $reason + " strategy=" + $target.Strategy)
if (-not $success) {
    $EscDir = Join-Path $ProjectDir "agent-workspace\memory"
    $EscMarker = Join-Path $EscDir ".auto-reboot-FAILED"
    $reasonLine = if ($lockObserved) {
        "Reason: Desktop was LOCKED during all $RetryCount retries (foreground=LockApp/LogonUI/Idle). SendKeys cannot reach interactive-desktop windows when secure desktop owns foreground."
    } else {
        "Reason: SendKeys all $RetryCount attempts failed (Access denied / foreground race) -- desktop NOT locked, possibly UAC prompt or other elevated foreground."
    }
    $actionLine = if ($lockObserved) {
        "Action: UNLOCK screen. Watchdog auto-retries reboot at next Stop hook (budget-watchdog.sh clears .cliff-fired/.wind-down-fired on this marker). Or: type /new manually."
    } else {
        "Action required: human/LLM must MANUALLY type /new in the Claude Code TUI."
    }
    Set-Content -Path $EscMarker -Value (
        "AUTO-REBOOT FAILED at " + (Get-Date -Format "o") + "`n" +
        $reasonLine + "`n" +
        "Target was: pid=" + $target.Pid + " name=" + $target.ProcessName + " strategy=" + $target.Strategy + "`n" +
        $actionLine + "`n" +
        "Logfile: " + $LogFile + "`n"
    ) -ErrorAction SilentlyContinue
}
