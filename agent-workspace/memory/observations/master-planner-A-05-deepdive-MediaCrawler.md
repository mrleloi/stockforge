---
observation_id: master-planner-A-05-deepdive-MediaCrawler
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: MediaCrawler
repo_path: C:/htdocs/research/MediaCrawler/
fit_level_hypothesis: HIGH
fit_level_empirical: MEDIUM-LOW
license: NON-COMMERCIAL LEARNING LICENSE 1.1 (NOT OSI-approved; commercial use prohibited; per-file source-link mandatory)
---

## 1. Repo Summary

MediaCrawler is a Python async multi-platform scraper covering 7 Chinese social platforms: Xiaohongshu (xhs), Douyin (dy), Kuaishou (ks), Bilibili (bili), Weibo (wb), Baidu Tieba (tieba), Zhihu. Core entry `main.py:50-67` dispatches to `CrawlerFactory.CRAWLERS` dict keyed by platform code. Async architecture via Playwright + httpx. Maintained by `relakkes@gmail.com` (a paid "Pro" version exists at MediaCrawlerPro per `README_en.md:54-73`, suggesting the OSS variant is intentionally limited).

Dispatch-mandated docs found and read:
- `docs/data_storage_guide.md:1-72` — confirms storage adapters: CSV, JSON, JSONL (default), Excel, SQLite, MySQL, PostgreSQL; init via `--init_db <kind>` flag, store via `--save_data_option`.
- `docs/CDP模式使用指南.md:1-287` — the marquee technique. CDP (Chrome DevTools Protocol) mode connects to a real user's running Chrome via WebSocket `ws://localhost:9222/devtools/browser`. Default behavior since 2026-01: `CDP_CONNECT_EXISTING=True`. User must opt-in via `chrome://inspect/#remote-debugging` and click a confirmation dialog (`CDP模式使用指南.md:38-48`). Explicitly framed as "反检测能力" (anti-detection capability) in `CDP模式使用指南.md:9-14`.

Top-level structure documented in `docs/项目架构文档.md:147-204`:
- `base/base_crawler.py` — four abstract base classes (Crawler, Login, Store, ApiClient).
- `media_platform/<platform>/` — per-platform `core.py + client.py + login.py + field.py + help.py + extractor.py`.
- `store/<platform>/_store_impl.py` — per-platform storage adapter; multiple sub-classes per save-format.
- `tools/cdp_browser.py` — CDP launcher and connection manager (524 LOC).
- `proxy/proxy_ip_pool.py` + `proxy/proxy_mixin.py` — rotating IP pool with `ProxyRefreshMixin` to be inherited by clients (`proxy_mixin.py:34-77`).
- `libs/stealth.min.js` — minified fingerprint-spoofing script (180KB, single line; `libs/` count via `ls -la`).
- `cache/` — `AbstractCache` with `ExpiringLocalCache` + `RedisCache` (`项目架构文档.md:562-593`).
- `database/models.py` — 22 SQLAlchemy ORM classes across 7 platforms (`grep` enumeration).

## 2. Architecture / Design Patterns

The framework is a textbook abstract-base + per-platform-implementation layout:

- **Four abstract bases** (`base/base_crawler.py:26-127`):
  - `AbstractCrawler` with `start()`, `search()`, `launch_browser()`, plus `launch_browser_with_cdp()` providing default fallback to standard mode (`base_crawler.py:54-64`).
  - `AbstractLogin` with `begin/login_by_qrcode/login_by_mobile/login_by_cookies`.
  - `AbstractStore` with `store_content/store_comment/store_creator`.
  - `AbstractApiClient` with `request/update_cookies`.
- **Factory pattern**: `CrawlerFactory.CRAWLERS` dict (`main.py:50-67`) and per-platform `StoreFactory.STORES` (`项目架构文档.md:420-436`).
- **Mixin pattern for proxy refresh**: `ProxyRefreshMixin.init_proxy_pool()` + `_refresh_proxy_if_expired()` called before each request (`proxy_mixin.py:49-77`). XhsClient inherits both `AbstractApiClient` and `ProxyRefreshMixin` (`media_platform/xhs/client.py:45`).
- **Cursor-pagination loop for comment trees** (`media_platform/xhs/client.py:407-454`): tracks `has_more` + `cursor` strings, calls `get_note_comments` repeatedly, then recursively walks each first-level comment's `sub_comments` via `get_comments_all_sub_comments` (`client.py:456-536`). Sub-comments gated by `ENABLE_GET_SUB_COMMENTS` config flag (`client.py:474-478`).
- **Lifecycle sequence diagram** in `项目架构文档.md:273-327`: factory→start→optional CDP launch→pong (login check)→login fallback→search/detail/creator branch→store→cleanup.
- **Retry with tenacity decorator** on `request()` (`client.py:115`): `stop_after_attempt(3), wait_fixed(1)`, exempt `NoteNotFoundError`.
- **Signature-as-data-not-code via Playwright JS evaluation**: rather than reverse-engineering JS signatures, XHS calls `playwright_sign.sign_with_xhshow` which builds the `X-S/X-T/X-S-Common/X-B3-Traceid` headers (`client.py:78-113`). For Tieba, the client actually evaluates `fetch()` inside the browser page context to bypass TLS issues (`media_platform/tieba/client.py:108-120`) — this is a NOTABLE PATTERN.

## 3. Components / Features candidate (with explicit ToS-transferability flag per component)

| Component | File | ToS-transferability to VN/EU |
|---|---|---|
| `AbstractCrawler/Login/Store/ApiClient` quartet | `base/base_crawler.py:26-127` | TRANSFERABLE — pure interface design |
| `CDPBrowserManager` (connect to existing user browser via CDP) | `tools/cdp_browser.py:35-524` | TRANSFERABLE WITH CAVEATS — `_connect_existing_browser` (`cdp_browser.py:140-195`) requires user-driven opt-in (chrome://inspect dialog), which IS legitimate; but `_launch_browser` mode (`cdp_browser.py:250-286`) spawns headless Chrome with auto-confirm and is the legal-grey path |
| Cursor-paginated comment tree walker | `media_platform/xhs/client.py:407-536` | TRANSFERABLE — generic pagination, no platform-specific trickery |
| Storage adapter factory (CSV/JSON/JSONL/SQLite/MySQL/Postgres/Excel/Mongo) | `store/xhs/_store_impl.py:42-120` (+ ExcelStoreBase, MongoDBStoreBase) | TRANSFERABLE — pure I/O |
| `ProxyRefreshMixin` for client-side proxy rotation | `proxy/proxy_mixin.py:34-77` | TRANSFERABLE PATTERN, but providers (`快代理`, `万代理`) are China-only paid proxies; would need substitution |
| `ProxyIpPool` validation (echo.apifox.cn) | `proxy/proxy_ip_pool.py:42-100` | TRANSFERABLE — well-structured, uses tenacity retry |
| `AbstractCache` + `ExpiringLocalCache` + `RedisCache` | `项目架构文档.md:562-593` (referenced) | TRANSFERABLE |
| Login state preservation via `USER_DATA_DIR` per-platform | `config/base_config.py:91-92` + `cdp_browser.py:255-263` | TRANSFERABLE — standard browser-profile pattern |
| QR-code login flow (Chinese mobile-app scan) | `media_platform/xhs/login.py:36-130` | NOT TRANSFERABLE to VN — neither Facebook nor F319 use QR-code-from-app login; YouTube uses OAuth2 |
| **`libs/stealth.min.js` (180KB fingerprint spoofer)** | `media_platform/xhs/core.py:93` injects via `browser_context.add_init_script` | **LEGAL-GREY — see §7** |
| **`libs/douyin.js` (15KB) + `libs/zhihu.js` (6.7KB) custom JS** | `libs/` per `ls -la` | **LEGAL-GREY — content-specific JS-reverse fragments** |
| **Custom MD5 signature builder for Tieba PC API** | `media_platform/tieba/client.py:39, 66-74` (hardcoded `PC_SIGN_SECRET`) | **LEGAL-GREY — reverse-engineered private key** |
| **Browser-side `fetch()` evaluation to bypass TLS/proxy interception** | `media_platform/tieba/client.py:108-120` | LEGAL-GREY-LIGHT — sidesteps the platform's own anti-bot heuristics |
| `CAPTCHA appeared` exception handler (no bypass; just raises) | `media_platform/xhs/client.py:135-141` | TRANSFERABLE — fail-fast, no bypass |
| `app_runner.run()` with SIGINT/SIGTERM graceful-exit + 15s cleanup timeout | `main.py:142-157` + `tools/app_runner.py` (per `项目架构文档.md:740-757`) | TRANSFERABLE — solid harness pattern |

## 4. Per-BC Mapping

- **BC-6 Influence (KOL on YouTube/Facebook)**: Conceptual mapping to MediaCrawler's "creator" mode (`media_platform/xhs/core.py:121-123` — `get_creators_and_notes`) — fetch all content from a creator's homepage. Pattern reusable: enumerate creator IDs → fetch their content stream → paginate. BUT: YouTube has an official Data API v3 (preferred per I-S34 ToS-compliance) and yt-dlp for transcripts; Facebook public-page scraping is governed by Meta's robots.txt + ToS. The MediaCrawler creator-mode SHAPE transfers; the IMPLEMENTATION (xhshow signing, mobile-QR login) does not.
- **BC-7 Crowd (F319 forums)**: Closest analog is the Tieba module (`media_platform/tieba/`). Pattern: thread search → thread detail → comment tree with cursor pagination. F319.com is a vBulletin-style forum without JS-signing; mostly server-rendered HTML. MediaCrawler's heavyweight signing + CDP infrastructure is OVERKILL for F319 — a simpler httpx+BeautifulSoup or crawl4ai approach suffices. The valuable transfer is the COMMENT-TREE WALKER PATTERN (`media_platform/xhs/client.py:407-536`), not the signing layer.
- **BC-5 News**: No direct mapping. MediaCrawler is platform-API-driven, not generic-web. Use crawl4ai instead.
- **BC-1/2/3/4/8/9**: No mapping; out of scope.

## 5. Honest Fit Assessment

**Hypothesis was HIGH; empirical is MEDIUM-LOW** for these reasons:

1. **License blocks production use.** `LICENSE:13-18` — "non-exclusive, non-transferable right to use, copy, modify, and merge the Software for non-commercial learning purposes". §1 condition 2: "limited to learning and research purposes only, and may not be used for large-scale crawling". §1 condition 3: "may not be used for any commercial purposes". StockForge being single-tenant + 3-5 trusted peers may technically be non-commercial, but the "no large-scale crawling" clause is interpretively grey. Per-file source-link header is mandatory ("Repository: ... Licensed under NON-COMMERCIAL LEARNING LICENSE 1.1") — visible in every file e.g. `base/base_crawler.py:1-18`. CONCLUSION: Use as REFERENCE/PATTERN-SOURCE only; do not vendor.
2. **Platform list does not include VN targets.** No Facebook, no YouTube, no Vietnamese forum support. Per `main.py:50-59` the `CRAWLERS` dict is hardcoded to 7 Chinese platforms. Building VN platforms from scratch is required — MediaCrawler offers no platform-specific code reusable for VN.
3. **Signing/sub-detection layers are platform-coupled.** `xhs_sign.py`, `playwright_sign.py`, `libs/douyin.js`, `libs/zhihu.js`, Tieba's `PC_SIGN_SECRET` hardcoded MD5 key (`tieba/client.py:39`) — ALL specific to Chinese platforms' anti-bot schemes. None of this transfers to F319 (no JS signing), Facebook (different scheme), or YouTube (official OAuth API).
4. **CDP-mode pattern is the genuine reusable artifact.** `tools/cdp_browser.py` (524 LOC self-contained) IS extractable as a pattern even if not copied verbatim. The "connect to user's existing logged-in Chrome" approach (`cdp_browser.py:140-195`) is legitimate, user-consented, and superior to headless bot detection. This is the SINGLE highest-value takeaway.
5. **Storage / proxy / cache adapter shapes are textbook.** No StockForge-specific advantage over rolling our own with SQLAlchemy + httpx + cachetools.

**Recommended use**: STUDY PATTERNS, DO NOT VENDOR. Re-implement: (a) the AbstractCrawler/Login/Store/ApiClient interface shape, (b) the CDP-connect-existing-Chrome flow for any JS-heavy VN source (e.g. Facebook fanpages), (c) the cursor + sub-comments pagination loop. Skip everything in `media_platform/*/`, `libs/*`, `proxy/providers/*`.

## 6. License + Attribution

- **License**: NON-COMMERCIAL LEARNING LICENSE 1.1, custom (NOT in SPDX), `LICENSE:1-59` (English) + Chinese version `LICENSE:31-59`.
- **Key constraints** (`LICENSE:12-18`):
  - Non-exclusive, non-transferable.
  - Learning + research only.
  - "Not for large-scale crawling or activities that disrupt platform operations" (§1 cond. 2).
  - No commercial use without written consent.
  - Per-copy attribution required ("must include the above copyright notice and this license statement in all reasonably prominent locations").
- **Per-file attribution header**: every Python file starts with the same 18-line header (e.g. `base/base_crawler.py:1-18`, `tools/cdp_browser.py:1-18`, `proxy/proxy_mixin.py:1-18`) linking to GitHub URL of that file under `https://github.com/NanmiCoder/MediaCrawler/blob/main/...`.
- **Implication for StockForge**: If we extract any code, even patterns, we MUST (a) be confident our use is non-commercial (StockForge single-tenant + 3-5 trusted peers is defensible but document the rationale in an ADR), (b) preserve attribution headers on any literally-copied snippet, (c) NOT use it for "large-scale crawling" — soft rate-limits + low-volume queries only. Re-implementing the IDEA in our own code (clean-room re-derivation) avoids the license entirely. RECOMMENDATION: clean-room re-derive the CDP and comment-tree patterns; do not copy code.

## 7. Risks / Anti-patterns to avoid — **MANDATORY legal-grey audit**

**Legal-grey patterns present and how StockForge should treat them:**

1. **`libs/stealth.min.js` (180KB minified fingerprint spoofer)** — injected at every page load via `browser_context.add_init_script(path="libs/stealth.min.js")` (`media_platform/xhs/core.py:93`). This is the `puppeteer-extra-plugin-stealth` script; its purpose is to PRETEND a Playwright-driven Chrome is a normal user's Chrome. **VN/EU legal context**: in most ToS this constitutes "circumventing technical access controls" — EU CFAA-equivalent (Directive 2013/40/EU on attacks against information systems) and the EU AI Act risk-classification for "deceptive" automation lean against this. Vietnamese cybersecurity law (Law on Cybersecurity 2018) §16 prohibits "unauthorized access to information systems". **VERDICT: DO NOT TRANSFER**. Treat as a hard line — StockForge announces its bot identity in User-Agent and respects robots.txt.

2. **Reverse-engineered signing keys** — `tieba/client.py:39` hardcodes `PC_SIGN_SECRET = "36770b1f34c9bbf2e7d1a99d2b82fa9e"` derived from Baidu's private signing scheme. `media_platform/xhs/xhs_sign.py` + `playwright_sign.py` (328 LOC combined) implement Xiaohongshu's `X-S/X-T` signature algorithm. **VN/EU legal context**: Reverse-engineering for interoperability is allowed under EU Software Directive Art. 6, but using extracted keys to access non-public APIs typically violates platform ToS and may constitute "unauthorized access". **VERDICT: NEVER NEEDED FOR VN TARGETS** — F319 has no signing, Facebook scraping uses public-page-only patterns, YouTube uses official OAuth.

3. **CDP-launched-with-auto-confirm mode** — `cdp_browser.py:250-286` `_launch_browser()` mode (when `CDP_CONNECT_EXISTING=False`) spawns Chrome with `--remote-debugging-port` and connects without user opt-in. This is bot automation masked as a user. **VN/EU legal context**: less severe than stealth.js because it's openly automation, but still tries to evade detection. **VERDICT: USE ONLY `CDP_CONNECT_EXISTING=True` MODE** (`cdp_browser.py:140-195`), which requires user to opt-in via `chrome://inspect` and accept a confirmation dialog. That mode is user-consented and legitimate.

4. **Browser-context `fetch()` evaluation to bypass TLS** — `tieba/client.py:108-120` executes JS `fetch()` from inside the browser page (using its session+credentials) rather than from Python httpx. Avoids platform anti-bot heuristics that detect non-browser TLS fingerprints (JA3/JA4). **VN/EU legal context**: technically the request comes from a real browser session the user logged into; less black-hat than stealth.js but still a circumvention technique. **VERDICT: PATTERN IS ACCEPTABLE for own-account use where user has logged in voluntarily, NOT for scraping anonymous targets.**

5. **`AUTO_CLOSE_BROWSER=False` for "debugging"** (`config/base_config.py:83`) and persistent `USER_DATA_DIR` — keeps user's logged-in session indefinitely. Privacy/secrets risk: tokens, cookies, browsing history accumulate. **VERDICT: TRANSFERABLE WITH HARDENING** — must encrypt user_data at rest, separate browser profiles per scraping target, periodic credential rotation.

6. **`Crawler_Illegal_Cases_In_China` reference link in README** (`README_en.md:22`) — the upstream author explicitly anchors to a "web scraping illegal cases in China" repository. This is a tacit acknowledgement that even the AUTHOR considers this tooling legally fraught. **VERDICT: TREAT THE REPO'S LEGAL POSITIONING AS A WARNING SHOT.**

7. **`Crawler_Max_Sleep_Sec = 2` default** (`config/base_config.py:133`) — 2-second-max delay between requests. Too aggressive for ToS-compliant crawling. StockForge baseline should be 5-10s minimum + jitter, with per-source robots.txt enforcement. **VERDICT: DO NOT TRANSFER DEFAULT VALUES; we set our own rate limits.**

**Anti-patterns to skip**:
- Hardcoded private signing secrets in source files (`tieba/client.py:39`).
- 600-retry decorator on login check (`xhs/login.py:51` — `@retry(stop=stop_after_attempt(600))`) — that's a 10-minute brute-spam loop on a login probe.
- `DISABLE_SSL_VERIFY` config option (`base_config.py:135-137`) — even though gated by a warning, having the knob is asking for misuse. StockForge should hard-disable SSL-skip.
- No structured ToS-compliance gate before crawl; crawlers just run.

**MANDATORY StockForge guard rails when adopting any pattern from this repo**:
- Build a deterministic pre-crawl gate that checks the target's robots.txt + ToS-allowlist (I-S34) before allowing CDP/scraper to launch.
- Announce StockForge identity in User-Agent (not spoof a real browser).
- Cap request rate at platform-published API limits; reject unconfigured platforms by default.
- Audit-log every scrape with source URL + as-of timestamp + ToS-version-hash.
- Use only `CDP_CONNECT_EXISTING=True` consent flow if CDP is adopted at all.
- Drop ALL of `libs/*.js` and all `*_sign.py` files; we will NEVER need them for our targets.

---

Self-attestation: every claim cites a specific file in the repo.
