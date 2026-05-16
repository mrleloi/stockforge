---
observation_id: sandwich-verifier-S358-vietnambiz-adapter-verify
type: sandwich-verifier-audit
verifier_agent_id: a81939517d5462577
created_at: 2026-05-16
plan_audited: agent-workspace/session-plans/completed/027-S356-phase-d-vietnambiz-adapter.md
dev_session_audited: S357 (commit 00a53ef)
verifier_has_no_Write: true (recovery pattern: main writes this file)
verdict: PASS-WITH-CONCERNS
merge_eligible: yes
defects: 0 CRITICAL / 0 IMPORTANT / 6 MINOR
l_s345_3_promote_now: FIRES (all 6 sextuple-guard items GREEN; n=3 instance threshold met)
l_s345_1_loc_trigger: CLEAR-AT-N3 (no AP-23)
phase_e_entry_ready: yes
---

# S358 sandwich-verifier — VietnamBiz adapter audit + L-S345-3 PROMOTE-NOW GATE

## Explicit Verdicts (gate questions)

- **(a) Overall**: PASS WITH CONCERNS — MERGE-ELIGIBLE: YES
- **(b) L-S345-3 PROMOTE-NOW FIRES: YES** — all 6 DD-7 sextuple-guard items GREEN independently confirmed. Recommend main writes `.claude/skills/crawler-reliability/SKILL.md` "Adapter Storage Discipline — discover-bypass-via-store_raw" section per plan-027 § L
- **(c) L-S345-1 LOC trigger window: CLEAR at n=3 (CLEARED)** — dev-reported 501/490/373 EXACTLY matches independent wc -l. AP-23 RED FLAG does NOT fire
- **(d) Phase E entry READY: YES** — recommend plan-028 architect dispatch for Phase E Theme I Vietnamese NLP entry

## DD-7 SEXTUPLE-GUARD EMPIRICAL VERIFICATION (THE GATE)

| # | Item | Verdict | Evidence |
|---|---|---|---|
| 1 | DC-IMPL-7 signature `(self, url: str, *, store_raw: bool = True)` | **GREEN** | line 346 (kw-only via `*`) |
| 2 | DC-IMPL-8 `store_raw=False` in discover() | **GREEN** | line 201 |
| 3 | DC-IMPL-9 `if store_raw:` guard | **GREEN** | line 377 |
| 4 | Test 7 `mock_sink.write.assert_not_called()` after discover | **GREEN** | line 281 in test_discover_does_not_persist_raw_html_via_sink |
| 5 | Test 19 `mock_sink.write.assert_called_once()` after fetch_and_parse | **GREEN** | line 459 in test_fetch_and_parse_writes_raw_html_via_sink + kwargs validation 461-463 |
| 6 | DC-SMOKE-4 EMPIRICAL: only article hashes | **GREEN** | `find data/raw/news/vietnambiz -type f` → exactly 1 file `e6a209b91f159f73.html` (113859 bytes; article); ZERO listing-page hashes |

**ALL 6 GREEN — L-S345-3 PROMOTE-NOW FIRES**.

## V1 DoD (36 items; 36/36 substantive PASS with 2 plan-accepted exceptions)

DC-FILE 9/9 PASS / DC-LOC 2 PASS + 1 architect-accepted (LOC-1 501 > 400 mirroring Vietstock 476 precedent) / DC-IMPL 10/10 PASS / DC-COMPLIANCE 5/5 PASS / DC-GATE 7 PASS + 1 architect-accepted (mypy 4 unused-ignore L-S354-1 HOLD pattern) / DC-SMOKE 5/5 PASS / DC-BOOK 5/6 PASS + 1 verifier-acceptance (this audit IS the BOOK-4 trigger).

## V2 Sub-tracks D1-D5: All PASS

## V3 DD compliance DD-1..DD-10: All PASS (especially DD-5 3.0s rate-limit + DD-7 sextuple-guard)

## V4 Charter/invariant compliance

0 charter / 0 constitution / 0 human-workspace writes. I-S34: 2 docstring attestation hits + 0 imports (sibling Vietstock precedent). I-S2/I-S22/Rule 8/Rule 16 ✓. D-066/D-059/D-060/D-061/D-062/D-064/D-065 ✓.

UTC+7 fix empirically verified: `published_at (UTC) = 09:33+00:00 <= ingested_at (UTC) = 16:19+00:00` → Rule 8 invariant holds.

## V5 Regression

pytest 1013→1034 (+21; 0 regressions; full suite 1034 passed in 17.97s). ruff clean on 3 new files. CafeF (12) + NDH (22) + Vietstock (23) = 57/57 sibling unchanged. mypy 4 unused-ignore (L-S354-1 pattern; not regression).

## V6 Integration smoke

SQLite `data/tmp-vietnambiz-smoke.sqlite` 36864 bytes; raw HTML 1 file 113859 bytes; DC-SMOKE-4 empirical 1:1 with `articles_written`.

## V7 DD-7 SEXTUPLE-GUARD: see above (THE GATE)

## L-S345-1 anti-regression CLEAR at n=3

Dev wc -l 501/490/373 = independent wc -l 501/490/373 EXACT MATCH. Three consecutive truthful sessions (NDH-S344 + Vietstock-S354 + VietnamBiz-S357). AP-23 RED FLAG does NOT fire. Lesson CLEARED.

## Findings — 6 MINOR (all tracking-only)

- **F1 MINOR**: Test 8 has no UTC+7 discriminating assertion — regression reverting `_TZ_VN` would silently pass. **INLINE-RESOLVED this turn** (added `assert result.published_at.utcoffset() == timedelta(hours=7)` to Test 8).
- **F2 MINOR**: Dev observation line-number drift (sextuple-guard items 1-3 claimed lines 340/143/371 vs actual 346/201/377). Substance correct; only positional metadata off. Tracking only.
- **F3 MINOR**: URL regex `^/[a-z0-9-]+-\d{15,}\.htm$` only matches root-level URLs (category-prefixed nested paths not matched). Dev-flagged Risk 2; live smoke confirms correct for observed listing-page link pattern.
- **F4 MINOR**: LOC 501 > 400 plan ceiling — Vietstock S355 precedent extends accepted.
- **F5 MINOR**: mypy 4 unused-ignore L-S354-1 HOLD pattern (sibling parity).
- **F6 MINOR**: CLI default `--listing /chung-khoan.htm` Windows POSIX-shell interpretation edge case.

## Promotion candidates

- **L-S345-3 PROMOTE-NOW FIRES** — all 6 sextuple-guard items GREEN at n=3; main session writes skill update.
- **L-S345-1 CLEARED at n=3** (3 consecutive truthful LOC reports).
- **L-S357-1 NEW (1st-instance HOLD)**: M-S357-1 lesson "for any VN site where meta datetime has no tz suffix, apply UTC+7 (Vietnam has no DST)". If 2nd VN site with no-tz datetime arises, promote to Vietnamese-locale datetime helper.

## Compliance attestation

- AP-1 fresh-context ✓
- 0 file writes / 0 commits (verifier-has-no-Write recovery)
- VBW ✓
- Empirical anchoring: all 6 sextuple-guard items grep-confirmed; pytest re-run; ruff re-run; smoke artifacts file-system-verified; UTC+7 fix Python-executed
- F1 INLINE-RESOLVED by main session per verifier mandate (applying-per-mandate; AP-1 holds per S339 9eaeed1 precedent)

## Recommendations

**MERGE** at commit 00a53ef + (this turn's close-bookkeeping). Phase D Theme L FULLY DONE (4/4 VN sources: CafeF + NDH + Vietstock + VietnamBiz). Phase E Theme I Vietnamese NLP entry UNLOCKED — dispatch plan-028 architect next.
