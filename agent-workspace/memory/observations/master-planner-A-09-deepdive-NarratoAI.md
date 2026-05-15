---
observation_id: master-planner-A-09-deepdive-NarratoAI
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: NarratoAI
repo_path: C:/htdocs/research/NarratoAI/
fit_level_hypothesis: LOW
fit_level_empirical: LOW (confirmed)
license: Modified MIT — Non-Commercial Use Only (cite `LICENSE` lines 1-2, 10-13)
phase_assignment: Phase 4+ (out-of-scope for Phase 1-2 Wave 1 IMPL)
---

## 1. Repo Summary

NarratoAI v0.7.9 (`project_version` file) is an "all-in-one AI-powered tool for film commentary and automated video editing" (`README-en.md` L3) authored by linyq (`LICENSE` L3, Copyright 2024). It is a Streamlit-based (`webui.py`, `requirements.txt` L5 `streamlit>=1.45.0`) Python application that orchestrates LLM script generation, voice-over (`edge-tts`, `azure-cognitiveservices-speech`, `dashscope` per `requirements.txt` L4, L16, L18), and video editing (`moviepy==2.1.1`, `requirements.txt` L3). Docker-deployable (`Dockerfile`, `docker-compose.yml`, `docker-entrypoint.sh`).

## 2. What it does

The app takes source video material and produces narrated/edited output: it ships service modules for `generate_narration_script.py`, `generate_video.py`, `clip_video.py`, `audio_merger.py`, `subtitle.py`, `voice.py`, and `youtube_service.py` (all in `app/services/`). Vision/LLM analyzers cover Gemini (`app/utils/gemini_analyzer.py`, `gemini_openai_analyzer.py`) and Alibaba Qwen-VL (`app/utils/qwenvl_analyzer.py`); LLM dispatch goes through `app/services/llm/` with a migration adapter (`generate_narration_script.py` L20). Target use case is short-drama commentary / film recap content creation (`README-en.md` L38 "supports short drama commentary").

## 3. Hypothetical Phase 4+ relevance

If StockForge ever expands beyond research-aid framing into educational content output (explicitly NOT a Phase 1-2 / Wave-1 goal per task brief), narration-of-stock-charts or thesis-explainer videos could in theory borrow the LLM-script + TTS + video-clip pipeline pattern. However, such an output channel would clash with the I-S35 research-aid invariant (audio/video output risks being consumed as advice). No code reuse path identified for Phase 1-2; the architecture is single-tenant desktop/Streamlit, not aligned with StockForge's Postgres+pgvector backend stack.

## 4. Per-BC Mapping (out-of-scope)

None of StockForge's 9 BCs (Market Data, Fundamentals, News, Sentiment, KOL, Thesis, Calibration, Portfolio, Risk) map to NarratoAI. The closest tangential overlap is LLM-prompting infrastructure (`app/services/llm/`, `app/services/prompts/` referenced in `generate_narration_script.py` L22), but StockForge already has its own prompt-engineering skill and no-LLM-math constraint that NarratoAI does not enforce.

## 5. Fit confirmation (LOW)

LOW fit confirmed empirically. Domain mismatch: video/film commentary vs. VN equity research. Stack mismatch: moviepy/edge-tts/Streamlit-desktop vs. StockForge's Postgres-backed Python service. License blocks commercial reuse (`LICENSE` L11-13) which is fine for research-aid but eliminates any future revenue-product path. Zero Wave-1 IMPL action.

## 6. License + Attribution

Modified MIT — Non-Commercial Use Only, Copyright 2024 linyq (`LICENSE` L1-3). Personal/educational/research use permitted (`LICENSE` L10); commercial use prohibited without written permission (`LICENSE` L11-13). If any pattern (e.g., LLM provider abstraction) were ever borrowed, attribution required and commercial path blocked.

## 7. Risks

- **I-S35 preservation**: Adopting NarratoAI's narration/video output paradigm would actively undermine the research-aid framing — audio/video commentary on stocks reads as advice to consumers. STRONG recommendation: do not import this output pattern even in Phase 4+.
- **Documentation-quality**: The user-facing README is screenshot-heavy (`docs/` lists ~16 PNGs: `index-en.png`, `check-en.png`, `img001`-`img007` in en+zh per `ls docs/` output), which would impede code-port comprehension. HOWEVER, the repo also ships a structured engineering doc-track under `docs/onboarding/` (00-RECON-REPORT, 01-PROJECT-CHARTER, 02-HLD, 03-LLD-CRITICAL-MODULES, 04-ADR-LOG, ..., 12-ONBOARDING-TRACK), so technical documentation exists if a future port were ever attempted. Documentation-quality risk: MODERATE (not HIGH).
- **License**: Non-commercial clause (`LICENSE` L11) eliminates any future monetization path if code is reused.
- **Scope-creep risk**: Mere awareness of this repo could tempt a future agent to propose video-output features that violate the Phase 1-2 charter; the LOW fit decision should be re-affirmed at any Phase 4 planning gate.

Self-attestation: every claim cites a specific file in the repo.
