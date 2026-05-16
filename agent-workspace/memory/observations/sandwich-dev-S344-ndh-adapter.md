---
observation_id: sandwich-dev-S344-ndh-adapter
session: S344
agent: sandwich-dev (Claude Sonnet 4.6)
date: 2026-05-16
plan: agent-workspace/session-plans/pending/022-S343-phase-d-ndh-adapter.md
deliverables:
  - packages/infrastructure/news/crawler_adapters/ndh_adapter.py (NEW; ~290 LOC)
  - packages/infrastructure/news/crawler_adapters/__init__.py (updated; NDHAdapter export)
  - packages/infrastructure/news/__init__.py (updated; NDHAdapter export)
  - packages/infrastructure/news/crawler_adapters/test_ndh_adapter.py (NEW; 21 tests)
  - apps/cli/ingest_news_ndh.py (NEW; ~290 LOC)
  - agent-workspace/memory/decisions/066-bc5-crawler-adapter-contract.md (REV-1 amendment)
  - agent-workspace/memory/sessions/2026-05-16-session-344.md (session log)
  - .gitignore (added /tmp/ entry)
test_delta: "968 -> 989 (+21 new; 0 regressions)"
adr_action: "Path A REV-1 (D-066 amended; Out-of-scope item 12 ANSWERED)"
status: IMPL-COMPLETE-PENDING-VERIFY
---

# S344 Dev Observation

## STEP 0 Key Findings (for verifier)

1. **Canonical host changed**: nhipsongdoanhnghiep.vn redirects to nhipsongkinhdoanh.vn.
   ndh.vn DNS-failed entirely. The source_id "ndh" was retained (plan-022 DD-1 brand
   initialism rationale holds regardless of DNS redirect). Verifier should confirm this
   is acceptable.

2. **robots.txt**: `Allow: /` with `Disallow: /misc/language` only. Crawl-delay absent.
   2.0s default honored. No STOP-AND-ASK triggered.

3. **HTML structure**: Static (no JS). Body is `div.article-content` (not
   `div.detail-content` as in CafeF). Headline is `h1[class="article__title cms-title"]`.
   Date is `meta[property=article:published_time]` in ISO-8601+tz format.

4. **URL pattern**: `/slug-{numeric_id}.htm` confirmed. Using `re.compile(r"-\d+\.htm$")`
   with exclusion prefixes (/hashtag/, /cms/, /misc/).

5. **CLI smoke**: 1 article fetched and written. source="ndh". Vietnamese title parsed
   correctly. Raw HTML written to data/raw/news/ndh/. HOWEVER: Git Bash on Windows
   converts leading-/ args to Windows paths. Workaround: use PowerShell or inject
   sys.argv directly. Not a code issue.

---

## 5 Risk Areas for Verifier (prioritized)

### RISK-1 (HIGH): Canonical host change and source_id "ndh" retention
nhipsongdoanhnghiep.vn redirects to nhipsongkinhdoanh.vn. The source_id "ndh" was
retained based on plan-022 DD-1 (brand initialism for the editorial brand "Nhip Song
Doanh Nghiep" / "NDH"). But the live canonical hostname is now "nhipsongkinhdoanh.vn"
which could be interpreted as "Nhip Song Kinh Doanh" (different brand). The site still
covers financial/business content relevant to VN stock market.
**Verifier should**: Confirm whether source_id "ndh" is appropriate for the redirected
site, OR whether a new source_id (e.g., "nhipsongkinhdoanh" or "nskd") is warranted.

### RISK-2 (MEDIUM): _is_article_url exclusion list completeness
Current implementation excludes /hashtag/, /cms/, /misc/ prefix patterns and requires
`-{digits}.htm$` suffix. If the site adds new path structures (e.g., /category/slug-123
or /amp/slug-123.htm), these may be missed by discover(). The regex is conservative and
correct for observed URLs but may miss future link formats.
**Verifier should**: Inspect the actual listing page HTML (tmp/ndh_sample.html not
committed, but verifier can re-fetch and inspect) and verify no valid article URLs are
being excluded.

### RISK-3 (MEDIUM): SelectorChain fallback order coverage in tests
Tests cover: h1.article__title -> h1 fallback (test 8) and div.article-content ->
article fallback (test 9). The meta[og:title] as headline path (test 13) tests a case
where BOTH h1 variants are missing. But the real site's primary h1 class is
"article__title cms-title" (multi-class), and the SelectorChain strategy uses
`soup.find("h1", class_="article__title")` which matches multi-class elements where
"article__title" is one of the classes. Verifier should confirm BeautifulSoup class_=
matching behavior is correct for multi-class elements (it IS -- BS4 class_ is substring
match for multi-class elements, but this is worth explicit verification).

### RISK-4 (LOW): ScrapedArticle import from cafef_scraper cross-module dependency
NDHAdapter imports `ScrapedArticle` from `packages.infrastructure.news.cafef_scraper`.
This creates an infrastructure-layer cross-module dependency. If cafef_scraper is ever
deleted/renamed, NDHAdapter breaks. Plan-022 explicitly documents this as carry-forward
(future ADR may promote ScrapedArticle to packages/contracts/). Verifier should flag
if this architecture concern has become urgent before Phase D-N consolidation.

### RISK-5 (LOW): Rate-limit behavior with circuits open on bursty pages
The NDHAdapter's _fetch_with_optional_chain calls rl.report_response(url, 200) after
every successful fetch (hard-coded status 200 -- same pattern as CafeFAdapter). If the
HTTP response is actually a 429 or 503, the rate_limiter.report_response is called with
200 instead of the real status code, bypassing exponential backoff. This is a pre-existing
pattern from CafeFAdapter that was inherited here. Verifier should confirm whether a
proper status-code passthrough is needed for correctness.

---

## What Was Harder Than Expected

1. **Host discovery**: The plan assumed ndh.vn or nhipsongdoanhnghiep.vn; both are
   unreachable in different ways (ndh.vn DNS-fail; nhipsongdoanhnghiep.vn redirects to
   a different hostname). Required judgment call to proceed with redirected host.

2. **ruff ARG005 on test lambdas**: The dynamic type() construction in test_20 uses
   lambdas with formal self/path/url params that are unused. Fixed with _ prefix
   convention. Not hard, just required a ruff iteration.

3. **Git Bash POSIX path conversion**: The CLI smoke flag `--listing /hashtag/...`
   gets mangled to a Windows path by Git Bash. Required sys.argv injection workaround
   for the session log smoke. Not a code issue but could confuse future dev/verifier
   who runs the CLI in Git Bash.

---

## Plan Ambiguities Resolved

1. **Plan DD-4 note about SelectorChain inside fetch_and_parse**: Plan was clear that
   SelectorChain must be constructed inside fetch_and_parse (not cached), but the plan
   sketch had `SelectorChain[Tag]` with type annotation. In Python with mypy --strict,
   `SelectorChain[Tag]` as a local variable annotation works fine, but the `Tag` type
   must be imported. Used TYPE_CHECKING guard for `from bs4 import Tag` -- but
   discovered `BeautifulSoup` was unused at module level (only used in local import
   inside methods). Removed BeautifulSoup from TYPE_CHECKING to fix ruff F401.

2. **Plan specifies ingest_news_ndh.py ~250 LOC vs actual ~290 LOC**: The plan said
   ~250 LOC; actual is ~290. This is within the DC-LOC-3 range (200-350). The extra
   LOC comes from the _robots_fetcher helper and more complete CLI flag docstrings.

3. **Plan says `cast(str, anchor["href"])` in discover()**: Used `cast(str, anchor.get("href", ""))` 
   instead to avoid potential KeyError on malformed HTML (defensive; same logical effect
   for well-formed HTML; _is_article_url short-circuits empty string anyway).

---

## Carry-Forward Items for Next Per-Source IMPL (Vietstock, VietnamBiz)

1. **ScrapedArticle promotion**: Consider promoting `ScrapedArticle` to
   `packages/contracts/scraped_article.py` before the 3rd adapter ships. Currently
   each adapter imports from cafef_scraper which is awkward.

2. **Status code passthrough to RateLimiter**: The rl.report_response(url, 200) hard-
   code should be rl.report_response(url, actual_status_code). This requires the fetcher
   to return status code alongside HTML, or requires a different injection pattern. The
   CafeFAdapter has the same issue (it's a pre-existing pattern). Recommend fixing at
   one of the Vietstock/VietnamBiz adapters if rate-limit correctness becomes critical.

3. **CLI --listing Git Bash issue**: Document in AGENT_OPERATING_MANUAL that CLI scripts
   with path-like args should be invoked via PowerShell on Windows, not Git Bash. The
   click STRING options work fine in PowerShell.

4. **VietnamBiz adapter (plan-024)**: Plan-022 notes VietnamBiz gets 3.0s rate-limit per
   matrix. NDH pattern (SelectorChain + _is_article_url) can be directly mirrored; just
   adjust base_url, selector candidates, and URL pattern regex.

---

## Harness Anomalies Noted (not fixed -- harness_priority_one)

1. **python-determinism-check.sh ran successfully (exit 0)** -- no anomaly.

2. **mypy baseline has pre-existing Duplicate module error**: "apps\_shared" vs
   "packages\_shared" modules clash. This is a pre-existing baseline issue (not
   introduced by S344). Flagged for harness team awareness. Not fixed here.

3. **ruff baseline has 4 pre-existing errors** in packages/ apps/ (not in new files).
   New files are ruff-clean. Pre-existing errors not touched per Karpathy P3.

---

## ADR Action Summary

**Path A REV-1 taken** (as architect predicted; no contract gap found).
D-066 amended at Out-of-scope item 12 and Amendments section added.
No D-067 needed.

SelectorChain[T] contract validated:
- `frozen=True` dataclass with `Sequence[Callable[[], T | None]]` + `str` label
- `apply()` returns `(T | None, int)` -- works correctly for BS4 Tag closures
- Per-call construction inside fetch_and_parse is the correct pattern (closure-over-soup)
- Three SelectorChain instances per article (headline, body) + fmt-string chain for date

---

## Compliance Attestation

- **0 charter writes** (PROJECT_CHARTER.md untouched)
- **0 constitution writes** (agent-workspace/constitution/** untouched)
- **0 patchright / playwright_stealth / StealthyFetcher** imports (I-S34 HARD REJECT)
- **0 LLM math** (I-S1; adapter outputs URL/str/datetime -- no numeric computation)
- **D-060**: commit staged but NOT pushed (per hard rule)
- **AP-1**: this is fresh-context; no self-review; verifier S345 dispatches next
- **harness_priority_one**: anomalies surfaced in observation; NOT fixed here
- **Karpathy P3**: only touched paths listed in plan-022 J + standard session-log / obs /
  ADR amendment + .gitignore (for /tmp/ gitignore)
