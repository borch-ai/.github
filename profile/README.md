<p align="center">
  <img src="https://raw.githubusercontent.com/borch-ai/.github/main/profile/borch_ai_banner.png" alt="borch-ai banner" width="100%">
</p>

# <img src="https://raw.githubusercontent.com/borch-ai/.github/main/profile/borch_ai_logo.png" align="right" width="120" alt="borch-ai logo"> borch-ai

> Generative Book Orchestration Ecosystem for AI Agents

Welcome to **borch-ai**, a deterministic generative publishing ecosystem designed to orchestrate complex book writing, illustration, and validation pipelines with absolute reliability.

---

## 🛠️ Our Ecosystem

We build tooling that bridges deterministic pipelines, agentic workflows, and human-in-the-loop validation.

### ⚓ [Pithos](https://github.com/borch-ai/pithos)
A rigid, deterministic book orchestration pipeline that takes concepts from initiation to final distribution.
- **Structured Pipeline**: Procedural execution through strictly sequenced states (`initiate` ➔ `brew` ➔ `assemble` ➔ `deploy`).
- **Local Review Loops**: Seamless Markdown review/edit syncing (`manuscript.md`) to pause execution and allow off-line content refinement before illustration.
- **MCP Native**: Plugs directly into Model Context Protocol (MCP) servers like `pw-mcp-imagegen` for automated, parallel asset generation.

### ⚡ [Powerword](https://github.com/borch-ai/powerword)
The core MCP plugin repository and developer toolkit for local validation and auditing.
- **Developer Critic**: Advanced workspace analyzers that validate branch changes against structured plans (`powerword review --local`).
- **Telemetry & Cost Accounting**: Fine-grained token usage tracking, budget management, and model cost analysis.
- **MCP Servers**: High-performance MCP servers for image generation, Amazon SEO optimization, and Google Docs integrations.

### 🏮 [Lamplighter](https://github.com/borch-ai/lamplighter)
Our companion mobile frontend for remote pipeline monitoring and human-in-the-loop approvals.
- **Real-time Monitoring**: Track compilation logs, token costs, and illustration outputs directly from your phone.
- **Human-in-the-Loop**: Approve or request rewrites of stanzas/images on-the-fly to ensure publishing quality.

---

## 📐 Core Architecture

```mermaid
graph TD
    subgraph Powerword Ecosystem Hub
        PW[Powerword CLI / Critic]
        MCPS[MCP Server Registry]
        T[Telemetry & Token Budgets]
        PW --> MCPS
        PW --> T
    end

    subgraph Pithos Runner Pipeline
        P[Pithos CLI]
        P -->|1. Initiate| M(manifest.json)
        P -->|2. Brew| Stanzas[LLM Manuscript Gen]
        P -->|3. Assemble| Layout[Print Layout Compilation]
        P -->|4. Deploy| Cloud[Distribution & Cloud Export]
    end

    subgraph Lamplighter Frontend
        LL[Lamplighter Mobile Monitor]
    end

    %% Interactions
    P -->|Audit Diffs| PW
    Stanzas -->|Markdown Review| Rev[manuscript.md]
    Rev -->|Resume| P
    P -->|Call Server Tools| MCPS
    MCPS -->|Illustration Gen| Img[pw-mcp-imagegen]
    Img -->|Copy Asset| P
    
    T -.->|Real-time Telemetry| LL
    LL -.->|Human-in-the-Loop Approval| PW
```

---

## 🚀 Getting Started

To initialize a new book workspace and run the pipeline locally:

```bash
# 1. Install Pithos and Powerword tools
go install github.com/borch-ai/pithos/cmd/pithos@latest

# 2. Initiate a new project
pithos initiate --theme "A journey through agentic coding" --pages 12 --output ./my-book

# 3. Run the manuscript generation and enter the review loop
pithos brew --review --output ./my-book
```

---

<p align="center">
  <sub>Built with ❤️ by the borch-ai team. Code quality audited by <b>Powerword Critic</b>.</sub>
</p>
