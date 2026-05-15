---
observation_id: master-planner-A-11-deepdive-Pixelle-Video
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: Pixelle-Video
repo_path: C:/htdocs/research/Pixelle-Video/
fit_level_hypothesis: LOW
fit_level_empirical: LOW
license: Apache-2.0
phase_assignment: Phase 4+ (out-of-scope for Phase 1-2 Wave 1 IMPL)
---

## 1. Repo Summary

Pixelle-Video is an AI fully-automated short-video generation engine from AIDC-AI (`README_EN.md:1-2`, `NOTICE:1`). Top-level layout (`ls`): `api/`, `pixelle_video/` (with `pipelines/`, `services/`, `models/`, `prompts/`, `llm_presets.py`, `tts_voices.py`), `web/`, `workflows/`, `templates/`, `bgm/`, `docs/{en,zh}/` + `docs/FAQ.md` + `docs/FAQ_CN.md`, `Dockerfile`, `docker-compose.yml`, `mkdocs.yml`, `pyproject.toml`. Bilingual docs (EN + ZH) plus a substantial `docs/onboarding/` corpus (`01-PROJECT-CHARTER.md` through `12-ONBOARDING-TRACK.md` + `_meta/MASTER-PLAN.md`).

## 2. What it does

Takes a single topic string and orchestrates: script generation (LLM) → image planning → frame-by-frame ComfyUI image/video generation → TTS narration (Edge-TTS, Index-TTS) → BGM mix → final composed short video (`README_EN.md:17-22, 62-68`, `docs/en/index.md:17-23`). Supports multiple LLMs (GPT, Qwen, DeepSeek, Ollama) and a ComfyUI-based atomic-capability stack with custom workflow plug-in via `workflows/` JSON files (`README_EN.md:50-59`, `docs/FAQ.md:3-18`). Recent features include Motion Transfer, Digital Human, Image-to-Video pipelines (`README_EN.md:35-37`).

## 3. Hypothetical Phase 4+ relevance

If StockForge ever needs a video-output channel for thesis explainers (currently outside Phase 1-2 scope per master-plan § 4.11), Pixelle-Video offers a turnkey topic→short-video pipeline. However, its script-generation stage is LLM-narrative with no enforced citation slot or numeric-source binding (`docs/FAQ.md:32-39` discusses LLM/TTS errors but no claim-integrity layer), so I-S35 ("research aid, not financial advice") would require a wrapping content-policy + bear-case overlay before any number/ticker appears in narration. The atomic ComfyUI workflow architecture (`README_EN.md:59`) suggests citation-overlay could be injected as a custom workflow step, preserving I-S35 if treated as a presentation skin over already-verified deterministic outputs (numbers/claims sourced upstream from StockForge's no-LLM-math layer).

## 4. Per-BC Mapping (out-of-scope)

None for Phase 1-2. The 9 stock BCs (price, fundamentals, news, KOL, sentiment, thesis, portfolio, calibration, risk) generate structured outputs; video rendering is a presentation-layer concern that would sit downstream of all BCs as a Phase 4+ optional thesis-explainer channel.

## 5. Fit confirmation

LOW — confirmed. Repo is a content-creation tool (`README_EN.md:17-25` "Zero threshold... typing a sentence"), explicitly targeting general short-video creators, not financial research or claim-integrity workflows. No fundamentals/price/sentiment domain code (`pixelle_video/` subdirs are pipelines/services/models/prompts/tts — all generative-media oriented).

## 6. License + Attribution

Apache-2.0 (`LICENSE:1-3`); `NOTICE:1` "Copyright (C) 2025 AIDC-AI" with downstream OSS attributions (pillow MIT-CMU, httpx BSD-3, streamlit/openai/ffmpeg-python Apache-2.0, fastmcp/pyyaml/comfykit/playwright/edge-tts/fastapi/pydantic/loguru MIT) (`NOTICE:5-141`). `docs/zh/` mirror exists (`docs/zh/index.md` and full subtree per Glob) — same Apache-2.0 license signal via `docs/en/index.md:9`. Apache-2.0 permits derivative/private use with NOTICE retention; permissive enough for any future Phase 4+ adoption.

## 7. Risks — I-S35 preservation

(R1) Default pipeline produces fluent LLM-written narration with zero citation scaffolding (`docs/FAQ.md:32-46` only covers TTS/LLM error handling, not factual-grounding) — direct use in StockForge would violate I-S35 (research-aid framing) and I-S1 (no-LLM-math). (R2) TTS voice cloning capability (`docs/en/tutorials/voice-cloning.md`) introduces deepfake/impersonation risk if used to "voice" any analyst or KOL — must be banned in any Phase 4+ adoption. (R3) "3-minute video" speed framing (`docs/en/index.md:5`) culturally invites quick-take stock-tip content, opposite of adversarial-thesis discipline. (R4) Templates/visual styles (`docs/en/tutorials/custom-style.md`) trend toward attention-grabbing aesthetics, which conflicts with calibration-over-confidence principle. Mitigation if ever adopted: treat as pure presentation skin over already-verified structured outputs; ban LLM-authored narration in favor of deterministic templated narration from cited claim records; ban voice cloning entirely.

Self-attestation: every claim cites a specific file in the repo.
