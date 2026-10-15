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

---

## Phase 2: Unified Build Paradigm (Taskfile)

*Goal: Replace duplicated per-repo Makefiles with a shared, versioned build task contract and org-level Taskfiles that each repository inherits or overrides, while keeping every repo's pre-push gate and CI working throughout a staged migration.*

### Parallelization

All task names are fixed in Task 2.1, so Tasks 2.1–2.4 can be worked **in parallel** with each other and with Powerword Tasks 5.12 (validation auto-detection) and 5.13 (`powerword doctor`). Task 2.5 can start anytime but should ship after 2.2's distribution decision. Per-repo migrations (Kiln pilot first) are tracked in each repo's own roadmap and start once 2.1–2.4 and Powerword 5.12 are released.

```text
 .github 2.1 Contract ─┐
 .github 2.2 Go Taskfile ─┤
 .github 2.3 Shim + Guide ─┼──► Kiln pilot ──► Pithos / Aeolian / Daedalus / Lighthouse ──► Powerword 5.14
 .github 2.4 Task-aware CI ─┤
 Powerword 5.12 Detection ─┘
 Powerword 5.13 doctor ········ (advisory, any time)
 .github 2.5 Python Taskfile ··· (after 2.2) ──► Inkling
```

- [x] **Task 2.1 — Build Task Contract** `[Size: S]` ⚡ quick win
  Define the org-wide standard task names (`all`, `build`, `test`, `lint`, `fmt`, `tidy`, `vuln`, `check-coverage`, `clean`, `install-hooks`), their semantics, and shared variables (`MIN_COVERAGE`, `POWERWORD`, `VERSION`). The interface that Powerword detection, shared Taskfiles, and CI depend on.
  [Implementation Plan](plans/phase_2/task_2_1_build_task_contract.md)

- [x] **Task 2.2 — Shared Go Taskfile & Distribution Mechanism** `[Size: M]`
  Publish `taskfiles/go.yml` and `taskfiles/hooks.yml` implementing the contract with overridable vars and data-driven builds. Decide remote include vs. vendored copy with a `taskfile-sync` workflow.
  [Implementation Plan](plans/phase_2/task_2_2_shared_go_taskfile.md)

- [ ] **Task 2.3 — Makefile Shim, Starter Taskfile & Migration Guide** `[Size: S]`
  Ship a forwarding Makefile shim, a starter Taskfile with inherit/override examples, and a staged migration guide with per-repo checklist and rollout order.
  [Implementation Plan](plans/phase_2/task_2_3_shim_and_migration_guide.md)

- [ ] **Task 2.4 — Task-Aware Reusable Go CI Workflows** `[Size: M]`
  Add a `build-runner` (`auto`/`make`/`task`) input to `go-ci-standalone.yml`, `go-ci-with-sibling.yml`, and `release-go-binary.yml`, with detection mirroring Powerword 5.12 and a pinned Task install.
  [Implementation Plan](plans/phase_2/task_2_4_task_aware_ci.md)

- [ ] **Task 2.5 — Shared Python Taskfile** `[Size: S]`
  Publish `taskfiles/python.yml` implementing the contract for `uv`-managed repos, starting with Inkling.
  [Implementation Plan](plans/phase_2/task_2_5_shared_python_taskfile.md)

---

## Phase 2 Gate Criteria
Phase 2 is complete when **all** of the following are true:
- [ ] Contract v1, shared Go Taskfile, shim/guide, and Task-aware CI are released under a tagged `.github` version.
- [ ] Kiln has completed the pilot migration (stage 3 or later per the migration guide).
- [ ] CI self-test validates Make-only, Task, and partially migrated fixtures.
