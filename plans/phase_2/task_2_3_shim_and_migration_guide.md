# Plan: Task 2.3: Makefile Shim, Starter Taskfile & Migration Guide

**Status:** Proposed
**Depends On:** Task 2.1 (names only — can proceed in parallel with 2.2 and 2.4)

Give each repository a copy-paste path from Make to Task that never breaks existing
habits, docs, hooks, or CI mid-migration.

## User Review Required

> [!NOTE]
> The shim keeps `make <target>` working by forwarding to `task <target>`. Powerword's
> validation auto-detection (Powerword Task 5.12) and reusable CI (Task 2.4) both switch to
> Task only when the Taskfile defines `all` and the required contract tasks. Root overrides
> in consumer Taskfiles are honored during `task all` via root-qualified dependencies.

## Acceptance Criteria

- [ ] `templates/build/Makefile.shim` — forwarding Makefile with explicit `.PHONY`
  declarations for contract targets so directories like `build/` or files named `all` do
  not bypass forwarding (recipe lines must use a literal tab, hence MD010 disable):

  <!-- markdownlint-disable MD010 -->
  ```make
  # Transitional shim: forwards all targets to Task. See docs/taskfile-migration.md.
  .DEFAULT_GOAL := all

  # Targets that must be explicitly declared so directories or files on disk
  # (e.g. `build/`, `bin/`, or `all`) do not bypass Task execution.
  # Append any colliding repository-specific targets here.
  EXPLICIT_TARGETS := all build test lint fmt tidy vuln check-coverage clean install-hooks

  .PHONY: $(EXPLICIT_TARGETS)
  $(EXPLICIT_TARGETS):
  	@task $@

  %:
  	@task $@
  ```
  <!-- markdownlint-enable MD010 -->

- [ ] `templates/build/Taskfile.go.yml` — starter Taskfile that includes the org Go
  Taskfile (per Task 2.2's distribution decision) and defines every contract task as an
  inherit-alias, with commented examples of overriding a task (using root-qualified
  delegation) and adding a repo-specific one.
- [ ] `docs/taskfile-migration.md` — step-by-step guide matching the staged rollout:

  | Stage | Repo state | `powerword review` (local) | CI workflow |
  |-------|-----------|----------------------------|-------------|
  | 0 | Makefile only | `make all` | `make <target>` |
  | 1 | Starter Taskfile added, but `all` or CI targets not yet defined | `make all` (warns missing tasks) | `make <target>` (warns missing tasks) |
  | 2 | Taskfile defines `all` and all required CI contract tasks | `task all` | `task <target>` |
  | 3 | Makefile replaced by shim | `task all` | `task <target>` |
  | 4 | Shim removed, docs updated (only after all callers migrated) | `task all` | `task <target>` |

- [ ] Guide explicitly documents that local pre-push and CI detection are synchronized on
  the presence of `all` plus required targets so repos never experience a split runner state.
- [ ] Guide notes that Stage 4 (shim removal) is only permitted once all calling workflows
  (including release workflows such as `release-go-binary.yml`) and scripts have adopted
  Task-aware runners; repositories with any remaining Make callers remain safely at Stage 3.
- [ ] Guide instructs adding any repository-specific targets that collide with directory or
  file names (e.g. `dist/`, `docs/`) to `EXPLICIT_TARGETS` in the shim so they receive both an
  explicit forwarding recipe and a `.PHONY` declaration (avoiding disabled implicit-rule lookup).

- [ ] Guide includes a per-repo checklist: install Task, add starter Taskfile, port
  repo-specific targets, run `powerword doctor` (Powerword Task 5.13), bump reusable CI
  tag (Task 2.4), replace Makefile with shim, update README/GEMINI.md/Copilot
  instructions.
- [ ] Rollout order documented: **Kiln (pilot)** → Pithos, Aeolian, Daedalus, Lighthouse
  → Powerword (Powerword Task 5.14) → Inkling (Task 2.5). Lamplighter, Knurl, and
  study-systems remain on Make for v1.

## Proposed Changes

### `templates/build/` (new)

- `Makefile.shim`, `Taskfile.go.yml`.

### `docs/taskfile-migration.md` (new)

- Stages, checklist, rollout order, troubleshooting (e.g. "`task: command not found`",
  "remote include cache", "why does `review` still run `make all`?").

### `profile/README.md`

- Link the migration guide under "Build System" (shared with Task 2.1).

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Target names collide with existing directories or files (e.g. `build/`, `all`) | Low | Contract targets are explicitly declared in `EXPLICIT_TARGETS` with recipes and `.PHONY`; guide instructs adding colliding repo-specific targets to `EXPLICIT_TARGETS`. |
| Premature shim removal breaks release workflows or external callers | Medium | Migration guide restricts Stage 4 until all workflows (including `release-go-binary.yml`) adopt Task runners; consumers remain at Stage 3 until migrated. |
| Starter Taskfile drifts from `go.yml` | Medium | CI self-test (Task 2.2) also runs `task --list-all` on the starter to validate it parses. |

## Verification Plan

### Manual Verification

- In a scratch directory with the fixture module from Task 2.2: copy the shim and starter
  Taskfile, confirm `make all`, `make lint`, and `task all` behave identically.
- Markdown lint passes on the new docs.
