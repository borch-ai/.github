# Centralized Workflows Roadmap

This document outlines the strategic phases for developing centralized GitHub Actions and reusable workflows to enhance developer productivity, telemetry feedback, and media previews across the **borch-ai** ecosystem.

---

## Ecosystem Context

The `.github` repository contains the reusable workflow templates and configuration templates that govern all repositories in the `borch-ai` organization. By centralizing these Actions, we enable automated quality assurance, linting, code scanning (`daedalus`), and deployment pipeline hooks across the entire codebase.

```text
                    ┌─────────────────────────┐
                    │     borch-ai/.github     │
                    │  (Centralized Workflows)│
                    └────────────┬────────────┘
                                 │
        ┌────────────┬───────────┼───────────┬────────────┐
        │            │           │           │            │
  ┌─────┴─────┐ ┌────┴────┐ ┌───┴───┐ ┌─────┴─────┐ ┌───┴────┐
  │   Kiln    │ │ Pithos  │ │Aeolian│ │ Powerword │ │Lighthouse│
  │(scout/val)│ │ (books) │ │(media)│ │  (shared) │ │(telemetry)│
  └───────────┘ └─────────┘ └───────┘ └───────────┘ └──────────┘
```

---

## Phase 1: Interactive & Automated Developer Pipelines

*Goal: Implement automated previews, budget audits, and agent alignment checkers to make the development and publishing pipelines more visual, cost-transparent, and reliable.*

- [ ] **Task 1.1 — Aeolian Audio-Visual Previewer** `[Size: L]`
  Generate short audio-visual previews (WAV/MP3/MP4) on pull requests that modify audio components or compositions. Render waveforms and upload media files as artifacts to allow inline reviews.
  [Implementation Plan](plans/phase_1/task_1_1_aeolian_audio_previewer.md)

- [ ] **Task 1.2 — Kiln Market Scout & Automated Niche Dashboard** `[Size: M]`
  Build a cron-scheduled workflow that automatically triggers `kiln scout`, parses market trends, and updates the organization profile or builds/commits a static markdown trends dashboard.
  [Implementation Plan](plans/phase_1/task_1_2_kiln_market_scout_dashboard.md)

- [ ] **Task 1.3 — Daedalus Plan-PR Alignment Critic** `[Size: XL]`
  Implement an automated critic workflow that evaluates PR diffs against corresponding `.md` plans in the repository to check requirement alignment, missing steps, or scope creep.
  [Implementation Plan](plans/phase_1/task_1_3_daedalus_plan_alignment_critic.md)

- [ ] **Task 1.4 — Powerword Token & PR Development Cost Auditor** `[Size: S]` ⚡ quick win
  Audit agent LLM token consumption and costs associated with generating the PR or running development tests. Write a summary directly to the PR to maintain financial transparency.
  [Implementation Plan](plans/phase_1/task_1_4_powerword_token_budget_auditor.md)

- [ ] **Task 1.5 — Ephemeral Fake Door Deployer** `[Size: M]`
  Deploy temporary landing pages to staging environments during `kiln validate` runs and run automated Lighthouse audits on SEO and load times, reporting findings to the triggering issue.
  [Implementation Plan](plans/phase_1/task_1_5_fake_door_deployer.md)

---

## Phase 1 Gate Criteria
Phase 1 is complete when **all** of the following are true:
- [ ] All 5 workflows are implemented as reusable templates in `.github/workflows/`.
- [ ] Each workflow includes self-testing or configuration validations.
- [ ] Integration documentation is added to the repository's `profile/README.md`.
