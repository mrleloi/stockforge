#!/usr/bin/env bash
# daily-backup.sh — R3 of 2026-05-14 mass-deletion prevention.
#
# Stop hook (daily marker). Once per calendar day, creates a compressed backup of the
# critical project directories to an OUT-OF-TREE location, so a future mass-deletion has
# a same-day local restore point (the 2026-05-14 incident was recoverable only because a
# git remote existed; uncommitted session work would have been lost without it).
#
# Backup target: $STOCKFORGE_BACKUP_DIR (default: <project-parent>/stockforge-backups/)
# Retention: keep 14 daily backups; older auto-pruned.
# Includes: agent-workspace/, scripts/, .claude/, packages/, bdd/, specs/, root *.md
# Excludes: .git, node_modules, __pycache__, .*_cache, forensic dirs, the backup dir itself.
#
# Origin: post-mortems/2026-05-14-mass-deletion-recovery.md §5 R3.
# Bash + POSIX only per L-S11-1. RC=0 always (best-effort; never blocks Stop chain).
# SPAWN-CONTEXT: positional-arg

set -uo pipefail
trap 'exit 0' ERR

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
MEM_DIR="$PROJECT_DIR/agent-workspace/memory"
LOG="$MEM_DIR/.daily-backup.log"
TS="$(date -Iseconds 2>/dev/null || echo unknown)"
TODAY="$(date +%Y-%m-%d 2>/dev/null || echo unknown)"

mkdir -p "$MEM_DIR" 2>/dev/null || true

# Resolve backup dir (out-of-tree by default)
PARENT_DIR="$(cd "$PROJECT_DIR/.." 2>/dev/null && pwd || echo "/tmp")"
BACKUP_DIR="${STOCKFORGE_BACKUP_DIR:-$PARENT_DIR/stockforge-backups}"

# Idempotency: one backup per calendar day
MARKER="$MEM_DIR/.daily-backup-done-${TODAY}"
if [ -f "$MARKER" ]; then
  exit 0
fi

# Cleanup stale day-markers (keep only today's)
for old in "$MEM_DIR"/.daily-backup-done-*; do
  [ -f "$old" ] || continue
  case "$old" in
    *".daily-backup-done-${TODAY}") ;;
    *) rm -f "$old" 2>/dev/null || true ;;
  esac
done

mkdir -p "$BACKUP_DIR" 2>/dev/null || {
  printf '[%s] daily-backup: SKIP (cannot create backup dir %s)\n' "$TS" "$BACKUP_DIR" >> "$LOG" 2>/dev/null || true
  exit 0
}

ARCHIVE="$BACKUP_DIR/stockforge-${TODAY}.tar.gz"

# Build the backup. tar with excludes + --ignore-failed-read so missing optional dirs
# (bdd/specs/docs may legitimately not exist in every project state) do NOT abort the
# whole backup. tar's exit code is NOT treated as fatal — the content-verify gate below
# is the real success check.
if command -v tar >/dev/null 2>&1; then
  ( cd "$PROJECT_DIR" 2>/dev/null && tar --ignore-failed-read -czf "$ARCHIVE" \
      --exclude='.git' \
      --exclude='.git-corrupt-*' \
      --exclude='node_modules' \
      --exclude='__pycache__' \
      --exclude='.mypy_cache' \
      --exclude='.pytest_cache' \
      --exclude='.ruff_cache' \
      --exclude='*.tar.gz' \
      agent-workspace scripts .claude packages bdd specs docs \
      PROJECT_CHARTER.md CLAUDE.md AGENT_OPERATING_MANUAL.md SPEC_TEMPLATE.md .gitignore \
      2>/dev/null
  ) || true   # tar may exit non-zero on missing optional paths — content-verify is the gate
else
  printf '[%s] daily-backup: SKIP (tar not available)\n' "$TS" >> "$LOG" 2>/dev/null || true
  exit 0
fi

# Verify archive created + contains expected content (content-check is more robust than
# a size threshold — gzip compression ratio varies wildly with content).
if [ -f "$ARCHIVE" ]; then
  ARCHIVE_BYTES=$(stat -c %s "$ARCHIVE" 2>/dev/null || stat -f %z "$ARCHIVE" 2>/dev/null || echo 0)
  # Sanity: archive must be non-empty AND list at least one expected entry.
  # NOTE: use `grep -c` (consumes ALL input) not `grep -q` (quits early) — with
  # `set -o pipefail`, grep -q exiting early on a large tar stream gives tar SIGPIPE,
  # and pipefail then propagates tar's failure → false negative. grep -c avoids this.
  ARCHIVE_OK=0
  if [ "$ARCHIVE_BYTES" -gt 0 ]; then
    VERIFY_HITS=$(tar -tzf "$ARCHIVE" 2>/dev/null | grep -cE 'PROJECT_CHARTER\.md|CLAUDE\.md|agent-workspace/' 2>/dev/null || echo 0)
    VERIFY_HITS="${VERIFY_HITS:-0}"
    [[ "$VERIFY_HITS" =~ ^[0-9]+$ ]] || VERIFY_HITS=0
    if [ "$VERIFY_HITS" -gt 0 ]; then
      ARCHIVE_OK=1
    fi
  fi
  if [ "$ARCHIVE_OK" -eq 1 ]; then
    echo "done" > "$MARKER" 2>/dev/null || true
    printf '[%s] daily-backup: OK %s (%s bytes; content-verified)\n' "$TS" "$ARCHIVE" "$ARCHIVE_BYTES" >> "$LOG" 2>/dev/null || true
  else
    printf '[%s] daily-backup: WARN archive failed content-verify (%s bytes) — not marking done\n' "$TS" "$ARCHIVE_BYTES" >> "$LOG" 2>/dev/null || true
    exit 0
  fi
else
  printf '[%s] daily-backup: archive not created\n' "$TS" >> "$LOG" 2>/dev/null || true
  exit 0
fi

# Retention: keep 14 most-recent daily backups, prune older
if command -v find >/dev/null 2>&1; then
  PRUNED=0
  while IFS= read -r OLD; do
    [ -f "$OLD" ] || continue
    rm -f "$OLD" 2>/dev/null && PRUNED=$((PRUNED + 1))
  done < <(find "$BACKUP_DIR" -maxdepth 1 -type f -name 'stockforge-*.tar.gz' -mtime +14 2>/dev/null)
  if [ "$PRUNED" -gt 0 ]; then
    printf '[%s] daily-backup: pruned %d backup(s) older than 14 days\n' "$TS" "$PRUNED" >> "$LOG" 2>/dev/null || true
  fi
fi

exit 0
