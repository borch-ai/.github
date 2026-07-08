![borch-ai](borch_ai_banner.png)

# borch-ai

> Generative Media & Publishing Orchestration for AI Agents

Welcome to **borch-ai**, a deterministic generative publishing and media ecosystem designed to orchestrate complex book writing, music production, illustration, and validation pipelines with absolute reliability.

---

## 🛠️ Our Ecosystem

We build tooling that bridges deterministic pipelines, agentic workflows, and human-in-the-loop validation.

### 🔥 [Kiln](https://github.com/borch-ai/kiln)
The business orchestration layer. Kiln sits above Pithos and drives the full publishing lifecycle from market research to live KDP listing.
- **Market Intelligence**: Scores niche candidates using Amazon Autocomplete, Google Trends, and Reddit sentiment via the Anxiety Index.
- **Fake Door Validation**: Deploys ephemeral GitHub Pages landing pages and polls click-through rates (via Lighthouse or Plausible) before committing production resources.
- **Forge & Deploy**: Orchestrates Pithos as a subprocess, tracks every book through the Foundry state machine (`scouted → validated → forged → deployed`), and uploads final assets to KDP.

### ⚓ [Pithos](https://github.com/borch-ai/pithos)
A rigid, deterministic book factory pipeline that takes concepts from initiation to final distribution.
- **Structured Pipeline**: Procedural execution through strictly sequenced states (`initiate` ➔ `brew` ➔ `assemble` ➔ `deploy`).
- **Local Review Loops**: Seamless Markdown review/edit syncing (`manuscript.md`) to pause execution and allow off-line content refinement before illustration.
- **MCP Native**: Plugs directly into Model Context Protocol (MCP) servers like `pw-mcp-imagegen` for automated, parallel asset generation.

### ⚡ [Powerword](https://github.com/borch-ai/powerword)
The core MCP plugin repository and developer toolkit for local validation and auditing.
- **Developer Critic**: Advanced workspace analyzers that validate branch changes against structured plans (`powerword review --local`).
- **Telemetry & Cost Accounting**: Fine-grained token usage tracking, budget management, and model cost analysis.
- **MCP Servers**: High-performance MCP servers for image generation, Amazon SEO optimization, Google Docs integration, and market intelligence.

### 🏮 [Lamplighter](https://github.com/borch-ai/lamplighter)
Our companion mobile frontend for remote pipeline monitoring and human-in-the-loop approvals.
- **Real-time Monitoring**: Track compilation logs, token costs, and illustration outputs directly from your phone.
- **Human-in-the-Loop**: Approve or request rewrites of stanzas/images on-the-fly to ensure publishing quality.

### 🎵 [Aeolian](https://github.com/borch-ai/aeolian)
The automated music and media factory. Aeolian translates market anxiety signals from Kiln into royalty-free, long-form audio-visual content.
- **Algorithmic Composition**: Procedurally generates multi-track MIDI arrangements (drums, bass, chords, leads) in any key and scale — zero AI audio API costs.
- **Audio Synthesis**: Renders MIDI into high-quality WAV/MP3 via FluidSynth and customizable Soundfonts.
- **Dynamic Visuals**: Generates parallax looping video backgrounds via `pw-mcp-imagegen` and compiles multi-hour MP4 videos via ffmpeg.
- **Lazy-Max Publishing**: Deploys directly to YouTube and digital music distributors with zero manual editing or uploading.

### 🗼 [Lighthouse](https://github.com/borch-ai/lighthouse)
The unified stack-wide telemetry sink and privacy-first web analytics platform.
- **Cookie-Free Web Analytics**: Implements a GDPR-compliant aggregate API to track conversion rates on validation landing pages.
- **Consolidated Telemetry**: Ingests token metrics, financial API expenses, exception errors, and feature engagement from all components.

### 🦉 [Daedalus](https://github.com/borch-ai/daedalus)
The autonomous Engineering & Architecture Intelligence layer for ecosystem self-healing.
- **Ecosystem Indexing**: Cross-references VISION/ROADMAP files to find misaligned dependencies.
- **Proactive Refactoring**: Drafts Architecture Decision Records (ADRs) and PRs for dead code elimination and shared library extraction.
- **The Ouroboros Protocol**: Meta-learning loop to improve its own analysis tools and prompts over time.

---

## 📐 Core Architecture

```mermaid
graph TD
    subgraph Kiln ["🔥 Kiln — Business Orchestration"]
        K[Kiln CLI]
        K -->|scout| Scout[Market Intelligence]
        K -->|validate| FD[Fake Door Tests]
        K -->|forge| P
        K -->|deploy| KDP[Amazon KDP]
    end

    subgraph Pithos ["⚓ Pithos — Book Factory"]
        P[Pithos CLI]
        P -->|1. initiate| M(manifest.json)
        P -->|2. brew| Stanzas[LLM Manuscript Gen]
        P -->|3. assemble| Layout[Print Layout Compilation]
        P -->|4. deploy| Cloud[Distribution & Cloud Export]
    end

    subgraph Aeolian ["🎵 Aeolian — Media Factory"]
        A[Aeolian CLI]
        A -->|aeolian compose| MidiGen[MIDI Composition]
        A -->|aeolian render| VideoGen[Video Render]
        A -->|aeolian deploy| Streaming[YouTube / DistroKid]
    end

    subgraph Powerword ["⚡ Powerword — MCP Plugin Hub"]
        PW[Powerword CLI / Critic]
        MCPS[MCP Server Registry]
        T[Telemetry & Token Budgets]
        PW --> MCPS
        PW --> T
    end

    subgraph Lighthouse ["🗼 Lighthouse — Telemetry & Analytics"]
        LH[Lighthouse Server]
        LDB[(DuckDB Database)]
        LH <--> LDB
    end

    subgraph Lamplighter ["🏮 Lamplighter — Mobile Monitor"]
        LL[Lamplighter]
    end

    subgraph Daedalus ["🦉 Daedalus — Architecture Agent"]
        D[Daedalus Engine]
    end

    %% Daedalus analyzes the ecosystem
    D -.->|analyze & refactor| K
    D -.->|analyze & refactor| P
    D -.->|analyze & refactor| A
    D -.->|analyze & refactor| PW
    D -.->|analyze & refactor| LH

    %% Kiln orchestrates Aeolian (book pipeline already wired inside Kiln subgraph)
    K -->|forge media| A

    %% Kiln consumes Powerword MCP plugins
    Scout -->|pw-mcp-trends| MCPS
    FD -->|pw-mcp-imagegen| MCPS
    KDP -->|pw-mcp-seo| MCPS

    %% Pithos consumes Powerword MCP plugins
    Stanzas -->|manuscript.md review| Rev[Local Review Loop]
    Rev -->|resume| P
    P -->|pw-mcp-imagegen| MCPS

    %% Aeolian consumes Powerword MCP plugins
    VideoGen -->|pw-mcp-imagegen| MCPS
    Streaming -->|pw-mcp-youtube| MCPS

    %% Telemetry & Analytics ingestion into Lighthouse
    T -->|telemetry| LH
    P -->|telemetry| LH
    A -->|telemetry| LH
    FD -->|visitor metrics| LH

    %% Data querying & display
    LH -->|CTR stats| K
    LH -.->|consolidated metrics| LL
    LL -.->|Human-in-the-Loop Approval| PW
```

## 📈 Live Market Intelligence (Daily Niche Scout)

<!-- KILN_SCOUT_START -->
_No active niche scout data available. Data is automatically scanned and injected daily by the [Task 1.2](https://github.com/borch-ai/.github/blob/main/plans/phase_1/task_1_2_kiln_market_scout_dashboard.md) workflow._
<!-- KILN_SCOUT_END -->

---

## 🚀 Getting Started

To run the full publishing pipeline locally, you need the CLI tools. The entry point is **Kiln**:

```bash
# 1. Install the toolchain
go install github.com/borch-ai/kiln/cmd/kiln@latest
go install github.com/borch-ai/pithos/cmd/pithos@latest
go install github.com/borch-ai/aeolian/cmd/aeolian@latest
go install github.com/borch-ai/powerword/cmd/powerword@latest
go install github.com/borch-ai/lighthouse/cmd/lighthouse@latest

# 2. Scout for a niche
kiln scout

# 3. Validate the top candidate with a Fake Door test
kiln validate <book-id>

# 4. Forge the book via Pithos
kiln forge <book-id>

# 5. Deploy to KDP
kiln deploy <book-id>
```

---

<p align="center">
  <sub>Built with ❤️ by the borch-ai team. Code quality audited by <b>Powerword Critic</b>.</sub>
</p>
