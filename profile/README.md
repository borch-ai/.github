![borch-ai](https://raw.githubusercontent.com/borch-ai/.github/main/profile/borch_ai_banner.png)

# borch-ai

> Generative Book Orchestration Ecosystem for AI Agents

Welcome to **borch-ai**, a deterministic generative publishing ecosystem designed to orchestrate complex book writing, illustration, and validation pipelines with absolute reliability.

---

## 🛠️ Our Ecosystem

We build tooling that bridges deterministic pipelines, agentic workflows, and human-in-the-loop validation.

### 🔥 [Kiln](https://github.com/borch-ai/kiln)
The business orchestration layer. Kiln sits above Pithos and drives the full publishing lifecycle from market research to live KDP listing.
- **Market Intelligence**: Scores niche candidates using Amazon Autocomplete, Google Trends, and Reddit sentiment via the Anxiety Index.
- **Fake Door Validation**: Deploys ephemeral GitHub Pages landing pages and polls Plausible click-through rates before committing production resources.
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

    subgraph Powerword ["⚡ Powerword — MCP Plugin Hub"]
        PW[Powerword CLI / Critic]
        MCPS[MCP Server Registry]
        T[Telemetry & Token Budgets]
        PW --> MCPS
        PW --> T
    end

    subgraph Lamplighter ["🏮 Lamplighter — Mobile Monitor"]
        LL[Lamplighter]
    end

    %% Kiln consumes Powerword MCP plugins
    Scout -->|pw-mcp-trends| MCPS
    FD -->|pw-mcp-imagegen| MCPS
    KDP -->|pw-mcp-seo| MCPS

    %% Pithos consumes Powerword MCP plugins
    Stanzas -->|manuscript.md review| Rev[Local Review Loop]
    Rev -->|resume| P
    P -->|pw-mcp-imagegen| MCPS

    %% Telemetry to Lamplighter
    T -.->|Real-time Telemetry| LL
    LL -.->|Human-in-the-Loop Approval| PW
```

---

## 🚀 Getting Started

To run the full publishing pipeline locally, you need all four tools. The entry point is **Kiln**:

```bash
# 1. Install the toolchain
go install github.com/borch-ai/kiln/cmd/kiln@latest
go install github.com/borch-ai/pithos/cmd/pithos@latest
go install github.com/borch-ai/powerword/cmd/powerword@latest

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
