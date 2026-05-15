---
observation_id: master-planner-A-08-deepdive-MoneyPrinterV2
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: MoneyPrinterV2
repo_path: C:/htdocs/research/MoneyPrinterV2/
fit_level_hypothesis: LOW
fit_level_empirical: LOW (confirmed)
license: AGPL-3.0 (GNU Affero General Public License v3.0, copyright 2024 FujiwaraChoki)
phase_assignment: Phase 4+ (out-of-scope for Phase 1-2 Wave 1 IMPL)
---

## 1. Repo Summary

MoneyPrinterV2 (MPV2) is a community "make-money-online" automation toolkit (`README.md` L18-29) by FujiwaraChoki, sponsored by Post Bridge. It is a Python 3.12 monolithic CLI app (`README.md` L21) that bundles four loosely-coupled content-monetization automations behind a single menu-driven `src/main.py` entrypoint (`src/main.py` L21-56). Architecture is flat-modular: per-feature classes under `src/classes/`, top-level helpers (`config.py`, `cache.py`, `cron.py`, `llm_provider.py`, `post_bridge_integration.py`) and per-feature docs under `docs/` (`AffiliateMarketing.md`, `PostBridge.md`, `TwitterBot.md`, `YouTube.md`). Project framing is explicitly educational with an entertainment-content monetization lens — no investment, finance, or research-aid use cases (`README.md` L97-99 disclaimer).

## 2. What it does

The four headline modules (`README.md` L25-29, surfaced in `src/main.py` L11-19 imports `YouTube`, `Twitter`, `AffiliateMarketing`, `Outreach`, `TTS`) are: (a) **YouTube Shorts Automator** — LLM-scripted short-form video generation + TTS + scheduled upload via cron (`docs/YouTube.md`, `src/cron.py`); (b) **Twitter Bot** — scheduled tweet posting with CRON jobs (`docs/TwitterBot.md`, `classes/Twitter`); (c) **Affiliate Marketing** — Amazon affiliate pitch generation auto-shared to Twitter (`docs/AffiliateMarketing.md`, `classes/AFM`); (d) **Outreach** — scrape local businesses and cold-email them (`README.md` L29, `classes/Outreach`, README warns Go runtime required L41). The **Post Bridge integration** (`src/post_bridge_integration.py` L1-60, `docs/PostBridge.md` L1-33) is a thin handoff: after a successful YouTube Shorts upload, MPV2 calls Post Bridge's API to cross-post the same asset to TikTok + Instagram via a signed-upload-URL + create-post flow.

## 3. Hypothetical Phase 4+ relevance

Theoretically the Post Bridge cross-posting *pattern* (signed-URL upload + per-platform account resolver — see `resolve_social_account_ids` in `src/post_bridge_integration.py` L14-60) could inform a future stockforge "thesis-distribution to N peers" fan-out if Phase 4+ ever publishes thesis snapshots to Telegram/Discord/Zalo. However at N=3-5 trusted peers (Charter "build for ourselves and 3-5 peers"), a private Telegram/Discord webhook is one HTTP POST per recipient — there is no public-platform-publishing problem to solve, and Post Bridge itself is a paid SaaS for TikTok/Instagram/YouTube monetization audiences which stockforge explicitly does not target. The pattern is well-known and reimplementable in ~50 LOC if ever needed; copying MPV2 brings no leverage and inherits AGPL-3.0 viral copyleft (see §6).

## 4. Per-BC Mapping

Out-of-scope for Phase 1-2 Wave 1. No mapping to any of stockforge's 9 BCs (Ingestion / Claim / Thesis / Risk / Portfolio / Calibration / Backtest / Distribution / Governance). Closest hypothetical adjacency is a future Distribution BC (Phase 4+), but even there Post Bridge is the wrong tool — it targets public social platforms (TikTok/Instagram/YouTube per `docs/PostBridge.md` L3) and stockforge's "research aid for 3-5 peers" framing (I-S35) precludes public-platform fan-out.

## 5. Fit confirmation

**LOW (empirically confirmed)**. Reasoning: (a) **wrong domain** — content monetization, not investment research (`README.md` L18, L97-99 disclaimer); (b) **wrong scale** — designed for one-to-many public social fan-out (`docs/PostBridge.md` L3 "TikTok and Instagram"), stockforge targets 3-5 named peers; (c) **wrong primitive** — `classes/YouTube`, `classes/Twitter`, `classes/AFM`, `classes/Outreach` (per `src/main.py` L11-17 imports) all encode content-creator workflows with zero overlap to thesis/claim/risk primitives; (d) **license-incompatible** — AGPL-3.0 (`LICENSE` L1-3, L633) virality conflicts with stockforge's private-use posture; (e) **Phase 1-2 has no video/content output** per task brief. No code, no patterns, no dependencies worth importing.

## 6. License + Attribution

**AGPL-3.0** (`LICENSE` L1, Copyright 2024 FujiwaraChoki at L633). AGPL is strong copyleft with a network-use clause (`LICENSE` §13 L540-559) — any derivative interacting with users over a network must offer Corresponding Source. **Action for stockforge**: do not vendor, do not copy code, do not import as dependency. If a Post Bridge-style pattern is ever needed (Phase 4+), reimplement clean-room from the published Post Bridge REST API reference (`docs/PostBridge.md` L3 links api.post-bridge.com/reference) — no MPV2 code touches stockforge.

## 7. Risks — I-S35 preservation; ToS-grey patterns on automation

(a) **I-S35 (research-aid framing) preservation** — MPV2's framing is "make money online" (`README.md` L18) and "automate revenue" via AGPL-licensed bots; any superficial pattern-borrowing risks bleeding monetization/content-creator language into stockforge code or docs, which would directly violate the "thesis exploration not recommendation" framing. Quarantine: do not link MPV2 patterns from stockforge specs or skills. (b) **ToS-grey automation patterns** — MPV2 includes scraped-business cold-outreach (`README.md` L29, L41 Go runtime for emailing) and bulk Twitter/YouTube posting via cron, patterns that brush against platform Terms of Service and anti-spam laws (CAN-SPAM, GDPR for EU outreach). The disclaimer (`README.md` L97-99) explicitly disowns misuse liability — a signal that lawful use is on the operator. stockforge must not inherit these patterns even by reference; the Distribution BC (if/when built) targets named-peer private channels with consent, not scraped audiences.

Self-attestation: every claim cites a specific file in the repo.
