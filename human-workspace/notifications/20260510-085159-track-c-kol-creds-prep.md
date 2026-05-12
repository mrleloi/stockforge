---
notification_id: 20260510-085159-track-c-kol-creds-prep
type: user-action-prep
severity: medium
session: S235→S242
created_at: 2026-05-10T08:52:00+07:00
related_decision: Q-P4-2 = FULL (S235 SCOPE-tier authorization gate)
related_track: Track C (Phase 4 plan 008-S235-phase-4-master-plan.md)
expected_consume_session: S242 entry (estimated 2-3 sessions out per Track A queue: S236 → S237 → S240/S242)
status: pending-user-action
---

# Track C KOL credentials prep — user-side action needed before S242 entry

## Context

At S235 SCOPE-tier authorization gate, you upgraded Q-P4-2 from architect-recommended **PARTIAL** (1 platform) to **FULL — all 3 platforms**. This means Track C (BC-6 KOL ingest) Success Criterion **SC-3** is now binding: 3 LIVE rows in `kol_recommendations` per platform from real ingest, not fixture data.

S242 sandwich-dev session will need actual credentials at run-time to validate the onboarding flow + execute LIVE ingest. The session will fail validator with `WARN: missing credentials` if env-vars are unset.

## What you need to gather (before S242 entry)

| Platform | Required env-vars | How to obtain | Notes |
|---|---|---|---|
| **YouTube Data API v3** | `STOCKFORGE_YOUTUBE_API_KEY` | Google Cloud Console → APIs & Services → Credentials → Create API Key. Enable "YouTube Data API v3" on the project. | Easiest. Free tier = 10,000 units/day; each `search.list` call ≈ 100 units, each `videos.list` ≈ 1 unit. Sufficient for KOL discovery + recent-video fetch. |
| **Telegram Bot API** | `STOCKFORGE_TELEGRAM_BOT_TOKEN` (bot token) + `STOCKFORGE_TELEGRAM_CHANNEL_LIST` (comma-separated `@channel_username`) | (a) `@BotFather` → `/newbot` → copy token. (b) Add bot to each target VN-stock-KOL channel as admin (read-only privileges OK). | KOL must add bot to channel. If KOL won't add, fallback to public-channel scrape via web (heavier; covered by S236+ if blocker). |
| **Facebook Graph API** | `STOCKFORGE_FACEBOOK_ACCESS_TOKEN` + `STOCKFORGE_FACEBOOK_PAGE_LIST` | Facebook Developers → My Apps → Create App (Business type) → Tools → Graph API Explorer → Generate Access Token (Page Public Content Access scope). Store long-lived (60-day) token. | Heaviest setup (Meta verification path). If friction high → consider deferring FB-only to Phase 5 + amending Q-P4-2 to PARTIAL via SCOPE-tier follow-up. |

## Storage convention

- Local dev: `.env` file at repo root (gitignored — already in `.gitignore`)
- Schema:
  ```
  STOCKFORGE_YOUTUBE_API_KEY=AIzaSy...
  STOCKFORGE_TELEGRAM_BOT_TOKEN=12345:AABB...
  STOCKFORGE_TELEGRAM_CHANNEL_LIST=@vnstock_channel1,@stock_signal_kol2
  STOCKFORGE_FACEBOOK_ACCESS_TOKEN=EAAGm0...
  STOCKFORGE_FACEBOOK_PAGE_LIST=phantichchungkhoanvn,vnstockmaster
  ```
- Production (later phases): same env-var names; secrets rotated via the deployment env (Phase 5+ only — does not affect Phase 4 dogfood)

## When to act

S236 (Track A bull-role probe) starts now and runs ~15-30 min wall-clock. S237-S239 (Track A IMPL + 2 verify runs) follow. **You have ~3-5 sessions = est. 1-3 days of work cadence before S242 entry.** Gather creds in parallel; no blocking action this turn.

## Escalation path if friction

If any platform onboarding hits a hard wall (e.g., FB Meta verification rejects), open a SCOPE-tier follow-up via chat or `human-workspace/user_prompt/` — agent will re-fire AskUserQuestion to amend Q-P4-2 from FULL to PARTIAL with explicit deferral of the blocked platform to Phase 5 (Track C SC-3 then becomes PARTIAL-PASS per the plan's R-P4-4 mitigation).

## What the agent does NOT need

- **NOT this turn**: any creds-related action from you. S236 is in flight; this notification is just heads-up so you can prepare in parallel.
- **NOT ever via chat or commit**: do NOT paste actual creds into chat or any file the agent reads. Creds stay in your `.env` (gitignored). The agent will instruct S242 dev to read from env at runtime, never from chat content.

## Auto-close

This notification auto-closes when `apps/cli/validate_kol_credentials.py` exists AND validator's S242 first-run reports `youtube=ok telegram=ok facebook=ok`. If you defer FB to Phase 5, manually edit `status: pending-user-action` → `status: closed-partial-deferred-FB`.
