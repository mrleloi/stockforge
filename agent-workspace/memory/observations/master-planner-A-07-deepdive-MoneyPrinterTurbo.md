---
observation_id: master-planner-A-07-deepdive-MoneyPrinterTurbo
session: S323-A-phase-a-deepdive
agent: general-purpose
date: 2026-05-15
repo: MoneyPrinterTurbo
repo_path: C:/htdocs/research/MoneyPrinterTurbo/
fit_level_hypothesis: LOW
fit_level_empirical: LOW (confirmed)
license: MIT (Copyright (c) 2024 Harry — `LICENSE` lines 1-3)
phase_assignment: Phase 4+ (out-of-scope for Phase 1-2 Wave 1 IMPL)
---

## 1. Repo Summary

MoneyPrinterTurbo (`harry0703/MoneyPrinterTurbo`, v1.2.7 per `pyproject.toml:10`) is an end-to-end AI short-video synthesis pipeline. The codebase is MVC-shaped (`app/controllers`, `app/services`, `app/models`, `app/router.py`, `webui/`) with a FastAPI backend (`fastapi==0.115.6` in `pyproject.toml:19`) plus a Streamlit WebUI (`streamlit==1.45.0` in `pyproject.toml:18`). Core dependencies in `pyproject.toml:15-34` include `moviepy==2.1.2` (video composition), `faster-whisper==1.1.0` (transcription), `edge-tts==7.2.7` + `azure-cognitiveservices-speech==1.41.1` (TTS), and a fan-out of LLM clients (`openai==1.56.1`, `google-generativeai==0.8.6`, `dashscope`, `g4f`). The `app/services/` directory holds the pipeline stages — `llm.py`, `voice.py`, `subtitle.py`, `material.py`, `video.py`, `task.py` (per `ls` of `app/services`).

## 2. What it does

Given a topic/keyword, the pipeline auto-generates a video script via an LLM (`app/services/llm.py`), synthesizes voice-over (`voice.py`), fetches royalty-free background clips (`material.py`), generates subtitles (`subtitle.py`), composes video (`video.py`), and emits 9:16 / 16:9 HD shorts (per README-en.md:36-37). It supports two deployment paths: (1) CPU-only via stock `Dockerfile` / `docker-compose.yml`, and (2) GPU-accelerated via `Dockerfile.gpu` (FROM `nvidia/cuda:12.1.1-cudnn8-runtime-ubuntu22.04` per `Dockerfile.gpu:1`) and `docker-compose.gpu.yml:21-27` (requires NVIDIA Container Toolkit + reserves 1 GPU device). README-en.md:107-110 also offers Google Colab one-click execution via a Colab badge — i.e. no local hardware needed for trial runs. README-en.md:90-97 declares GPU optional ("4+ GB VRAM recommended") but speed-critical for `faster-whisper` and batch generation.

## 3. Hypothetical Phase 4+ relevance

The only conceivable StockForge tie-in is Phase 4+ marketing/distribution: auto-generating short-form video summaries of completed thesis exploration outputs (e.g. a 30-second clip narrating the bear-vs-bull frame on a VN30 ticker). This is strictly downstream of the research-aid product and presupposes a content-marketing surface that does NOT exist in Phase 1-2 (no video output, per dispatch brief). Even at Phase 4+, the LLM-generated narration would conflict with I-S35 (research-aid framing, not financial advice) unless the script generation is rewired to consume only deterministic, citation-bound thesis artifacts — which would effectively rebuild `app/services/llm.py` from scratch. No code is reusable in Phase 1-2 Wave 1.

## 4. Per-BC Mapping (out-of-scope)

| BC | Mapping |
|---|---|
| All 9 BCs (data-ingest, fundamentals, crowd-sentiment, kol-trust, thesis-explore, calibration, risk-mgmt, portfolio, ui) | NONE. Pipeline produces video artifacts; no overlap with any thesis/data/risk BC. |

## 5. Fit confirmation

LOW confirmed. No surprises. The repo is a content-marketing pipeline; the only intersection with StockForge is the shared use of Streamlit (`pyproject.toml:18`) and Python 3.11+ (`pyproject.toml:13`), which is incidental commodity-stack convergence, not architectural fit. Wave-1 IMPL borrow: NONE.

## 6. License + Attribution

MIT License, Copyright (c) 2024 Harry (`LICENSE:1-3`). Permissive — were Phase 4+ to borrow any module, attribution + license-text inclusion would satisfy compliance. No copyleft contagion risk.

## 7. Risks

- **I-S35 preservability risk (HIGH if ever adopted)**: The pipeline's `llm.py` script-generation stage is designed to produce persuasive narrative copy ("Generate short videos from prompts" — `pyproject.toml:11`). Wiring this onto StockForge thesis output would directly violate the research-aid framing — auto-narrated video tends toward recommendation-shaped output ("buy/sell" affect) rather than trade-off-matrix framing. Any Phase 4+ adoption must intercept script generation with a deterministic citation-bound template, NOT free-form LLM prose.
- **GPU-Docker compute-cost concern (single-tenant 3-5-peer context)**: `Dockerfile.gpu:1` mandates CUDA 12.1 + cuDNN 8 base image, and `docker-compose.gpu.yml:21-27` reserves 1 NVIDIA GPU. For a 3-5-peer self-use product, standing up a GPU host (cloud A10/T4 ~$0.50-1.50/hr or on-prem RTX) is disproportionate vs. trivial output volume (a few clips/month). Colab fallback (`README-en.md:107-110`) mitigates trial-cost but is not a production path. CPU-only mode is viable per `README-en.md:90-97` but `faster-whisper` and `moviepy` composition become the bottleneck — throughput unsuitable for batch use. Net: no economically defensible Phase 4+ rollout for the target peer count.
- **LLM-math leak risk**: `app/services/llm.py` would, by default, allow the LLM to invent statistics inside generated narration — direct collision with the no-LLM-math invariant. Any adoption requires the script generator to be reduced to a templating layer over pre-computed deterministic outputs only.

Self-attestation: every claim cites a specific file in the repo.
