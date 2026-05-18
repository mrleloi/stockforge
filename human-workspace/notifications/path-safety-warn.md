---
level: WARN
status: pending
---

# path-safety-check — ALERT

Path safety violations detected: 20

  - P4-WRITE-ZONE [WARN]: packages/infrastructure/influence/llm_recommendation_extractor.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/_shared/crawl/raw_html_sink.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/bench/pdf_bake_off.py — write operation outside allowed zone (2 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/extract_vn_claims.py — write operation outside allowed zone (2 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_fundamentals_vn30.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_news_cafef.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_news_ndh.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_news_vietnambiz.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_news_vietstock.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_pdf_fundamentals.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_vhm.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/ingest_vn30.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/score_vn_sentiment.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/tokenize_vn_text.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P4-WRITE-ZONE [WARN]: apps/cli/validate_thesis.py — write operation outside allowed zone (1 occurrence(s)) — write to outputs/, logs/, state/, cache/, data/, or memory zones
  - P2P3-UNSANITIZED [WARN]: apps/dashboard/pages/calibration_inspection.py — user-supplied path from sys.argv/os.environ without safe_*_path wrapper (1 occurrence(s)) — wrap with safe_user_path or safe_document_path
  - P2P3-UNSANITIZED [WARN]: apps/dashboard/pages/confluence_alerts.py — user-supplied path from sys.argv/os.environ without safe_*_path wrapper (1 occurrence(s)) — wrap with safe_user_path or safe_document_path
  - P2P3-UNSANITIZED [WARN]: apps/dashboard/pages/kol_daily_digest.py — user-supplied path from sys.argv/os.environ without safe_*_path wrapper (1 occurrence(s)) — wrap with safe_user_path or safe_document_path
  - P2P3-UNSANITIZED [WARN]: apps/dashboard/pages/ticker_sentiment.py — user-supplied path from sys.argv/os.environ without safe_*_path wrapper (1 occurrence(s)) — wrap with safe_user_path or safe_document_path
  - P2P3-UNSANITIZED [WARN]: apps/dashboard/pages/validate_thesis.py — user-supplied path from sys.argv/os.environ without safe_*_path wrapper (1 occurrence(s)) — wrap with safe_user_path or safe_document_path

## Fix guidance
- P1/P1b: Use safe_path(p, workdir) from packages/_shared/path_safety.py
- P2/P3: Wrap user-supplied paths with safe_user_path() or safe_document_path()
- P4: Write to allowed zones (outputs/, logs/, state/, cache/, data/, memory/)
- P5: Use safe_path/safe_user_path (UNC reject is cross-cutting); add # path-safety-ok: if intentional

See ADR: agent-workspace/memory/decisions/064-path-safety-5-invariant-contract.md
Helpers: packages/_shared/path_safety.py
Source: Vibe-Trading agent/src/tools/path_utils.py:1-213 (MIT 2026)
