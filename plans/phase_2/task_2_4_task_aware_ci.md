# Plan: Task 2.4: Task-Aware Reusable Go CI Workflows

**Status:** Proposed
**Depends On:** Task 2.1 (names only — can proceed in parallel with 2.2 and 2.3)

`go-ci-standalone.yml` and `go-ci-with-sibling.yml` hardcode `make lint`, `make tidy`,
`make vuln`, `make check-coverage`, and `make build`. `release-go-binary.yml` hardcodes
`make lint`, `make tidy`, `make vuln`, and `make check-coverage` before its release step.
Add a `build-runner` input with auto-detection matching Powerword's local resolver
(Powerword Task 5.12), so a repo's CI switches to Task at the same moment its pre-push
hook does — with no workflow edits in the consuming repo beyond a tag bump.

## User Review Required

> [!NOTE]
> Backward compatible: with `build-runner: auto` (the default), repos without a Taskfile
> keep running `make <target>` exactly as today.

### Detection Rule

> [!IMPORTANT]
> Detection rule (mirrors Powerword 5.12 and aligns with Task 2.3 migration stages):
> Use Task only if a Taskfile exists **and** defines `all` **and** all CI-invoked tasks
> (`lint`, `tidy`, `vuln`, `check-coverage`, `build`).
>
> Detection & installation sequencing (evaluated in the consumer checkout `working-directory`):
>
> 1. If `build-runner == make`: skip Task installation and use Make directly.
> 2. If `build-runner == task`: install pinned Task unconditionally, assert that a Taskfile
>    exists in `working-directory` (failing immediately if missing), and use Task.
> 3. If `build-runner == auto`: inspect `working-directory` for Taskfile existence. If no
>    Taskfile is found, skip Task install and fall back to Make immediately. If a Taskfile
>    is found, install pinned Task **before** probing tasks via `task --list-all --json`
>    in `working-directory`. If `all` and all five CI tasks exist, select Task; otherwise
>    fall back to Make, emitting a `::warning::` annotation naming the missing tasks. If
>    a Taskfile exists, tasks are missing, **and** there is no Makefile, fail the job.

## Acceptance Criteria

- [ ] New input `build-runner` (`auto` | `make` | `task`, default `auto`) on
  `go-ci-standalone.yml`, `go-ci-with-sibling.yml`, and `release-go-binary.yml`.
- [ ] New input `task-version` (default: pinned v3.x) so repos can bump independently.
- [ ] A "Detect build runner" step outputs `runner` (`make`/`task`) and is reused by
  every job that runs build commands, operating inside the consumer checkout directory
  (`working-directory`, passing `inputs.repo-path` where applicable).
- [ ] Pinned Task is installed via a SHA-pinned setup action (with version comment) or
  `go install github.com/go-task/task/v3/cmd/task@<version>` after discovering a Taskfile
  in `working-directory` but *prior* to probing tasks via `task --list-all --json`
  (skipped entirely for explicit Make and Make-only auto runs; installed unconditionally
  when `build-runner == task`).
- [ ] All Make-backed quality gate steps invoke `${{ steps.detect.outputs.runner }} <target>`.
  In `release-go-binary.yml`, only the pre-release checks (`lint`, `tidy`, `vuln`,
  `check-coverage`) are runner-substituted; the downstream version-stamped cross-compilation
  into `dist/` and GitHub release asset upload remain intact.
- [ ] The existing `coverage-threshold` input is forwarded to `check-coverage` in all
  relevant workflows exporting BOTH `MIN_COVERAGE` (for Task and updated Makefiles) and
  `COVERAGE_THRESHOLD` (for unchanged legacy Makefiles) in the step environment
  (`MIN_COVERAGE: ${{ inputs.coverage-threshold }}` and
  `COVERAGE_THRESHOLD: ${{ inputs.coverage-threshold }}`). For Make invocations, also
  supply both variables as command-line arguments
  (`make check-coverage MIN_COVERAGE=... COVERAGE_THRESHOLD=...`).
- [ ] Harden-runner remains the first step; egress audit covers the Task download host.
- [ ] `ci-self-test.yml` exercises both runners against fixtures (Make-only fixture, full
  Task fixture from Task 2.2, and a Stage 1 partial fixture missing `all` / missing a CI task
  to assert clean fallback to Make with warning annotations).
- [ ] `ci-self-test.yml` validates non-default `coverage-threshold` enforcement under both
  runners (Make runner testing both `COVERAGE_THRESHOLD` and `MIN_COVERAGE`; Task runner testing
  `MIN_COVERAGE`).
- [ ] Released under a new tag; Dependabot picks it up in consumer repos.

## Proposed Changes

### `.github/workflows/go-ci-standalone.yml`, `.github/workflows/go-ci-with-sibling.yml`, `.github/workflows/release-go-binary.yml`

- Add inputs, detection step, conditional Task install, parameterized run steps.
- Ensure `check-coverage` exports both `MIN_COVERAGE` and `COVERAGE_THRESHOLD` (fixing
  `go-ci-standalone.yml`, which previously did not forward `coverage-threshold` to the step).
- In `release-go-binary.yml`, parameterize `lint`, `tidy`, `vuln`, and `check-coverage`
  with the detected runner while keeping the custom cross-compilation matrix into `dist/`
  unchanged.

### `.github/actions/setup-build-runner/action.yml` (new, recommended)

- Composite action shared by all three workflows to avoid duplicated logic.
- Inputs: `build-runner`, `task-version`, `required-tasks`, `working-directory` (default: `.`).
  Output: `runner`.
- Logic:
  - If `build-runner == make`: output `make`, do not install Task.
  - If `build-runner == task`: install pinned Task, verify Taskfile presence in
    `working-directory` (fail if missing), output `task`.
  - If `build-runner == auto`: check `working-directory` for Taskfile. If absent, output `make`
    without installing Task. If present, install pinned Task, probe task definitions with
    `task --list-all --json` in `working-directory`, and select `task` if `all` + required tasks
    exist, else warn and fall back to `make`.

### `.github/workflows/ci-self-test.yml`

- Matrix over `fixture: [make, task, task-partial]` asserting the selected runner.
- Assert that custom non-default coverage thresholds are honored by both Make and Task runners.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Detection drift vs. Powerword's local resolver | Medium | Same filename list and rules documented in both plans; self-test covers the partial case. |
| Task install adds CI time / supply-chain surface | Low | Install only when Taskfile is present or runner is explicitly task; pinned version and SHA. |
| Sibling checkout layout and repo-specific targets | Low | `go-ci-with-sibling.yml` executes build commands strictly within `repo-path` and does not invoke `patch-gomod`; runner detection operates inside `repo-path` preserving checkout layout without introducing prerequisite tasks. |

## Verification Plan

### Automated Tests

- `ci-self-test.yml` matrix passes for all three fixtures; `actionlint` and `yamllint`
  pass.

### Manual Verification

- Point a scratch branch of a consumer repo (not Kiln while it has in-flight work) at
  the new workflow ref and confirm unchanged Make behavior.
