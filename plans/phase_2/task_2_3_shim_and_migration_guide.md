# Plan: Task 2.3: Makefile Shim, Starter Taskfile & Migration Guide

**Status:** Proposed
**Depends On:** Task 2.1 (names only — can proceed in parallel with 2.2 and 2.4)

Give each repository a copy-paste path from Make to Task that never breaks existing
habits, docs, hooks, or CI mid-migration.

## User Review Required

> [!NOTE]
> The shim keeps `make <target>` working by forwarding to `task <target>`. Powerword's
> validation auto-detection (Powerword Task 5.12) prefers the Taskfile when it has an
> `all` task, so the shim does not cause double execution.

## Acceptance Criteria

- [ ] `templates/build/Makefile.shim` — forwarding Makefile (recipe line must use a
  literal tab, hence the scoped MD010 disable):

  <!-- markdownlint-disable MD010 -->
  ```make
  # Transitional shim: forwards all targets to Task. See docs/taskfile-migration.md.
  .DEFAULT_GOAL := all
  %:
  	@task $@
  ```
  <!-- markdownlint-enable MD010 -->

- [ ] `templates/build/Taskfile.go.yml` — starter Taskfile that includes the org Go
  Taskfile (per Task 2.2's distribution decision) and defines every contract task as an
  inherit-alias, with commented examples of overriding a task and adding a repo-specific
  one.
- [ ] `docs/taskfile-migration.md` — step-by-step guide matching the staged rollout:

  | Stage | Repo state | `powerword review` runs |
  |-------|-----------|-------------------------|
  | 0 | Makefile only | `make all` |
  | 1 | Starter Taskfile added, `all` not yet defined | `make all` (with warning) |
  | 2 | Taskfile defines `all` | `task all` |
  | 3 | Makefile replaced by shim | `task all` |
  | 4 | Shim removed, docs updated | `task all` |

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
| Shim's pattern rule shadows real files named like targets | Low | Document the edge case in troubleshooting. |
| Starter Taskfile drifts from `go.yml` | Medium | CI self-test (Task 2.2) also runs `task --list-all` on the starter to validate it parses. |

## Verification Plan

### Manual Verification

- In a scratch directory with the fixture module from Task 2.2: copy the shim and starter
  Taskfile, confirm `make all`, `make lint`, and `task all` behave identically.
- Markdown lint passes on the new docs.
