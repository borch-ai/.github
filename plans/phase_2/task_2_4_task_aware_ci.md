# Plan: Task 2.4: Task-Aware Reusable Go CI Workflows

**Status:** Proposed
**Depends On:** Task 2.1 (names only — can proceed in parallel with 2.2 and 2.3)

`go-ci-standalone.yml`, `go-ci-with-sibling.yml`, and `release-go-binary.yml` hardcode
`make lint`, `make tidy`, `make vuln`, `make check-coverage`, and `make build`. Add a
`build-runner` input with auto-detection matching Powerword's local resolver (Powerword
Task 5.12), so a repo's CI switches to Task at the same moment its pre-push hook does —
with no workflow edits in the consuming repo beyond a tag bump.

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
> Detection & installation sequencing:
>
> 1. If `build-runner == make`: skip Task installation and use Make.
> 2. If `build-runner == task`: install pinned Task and use Task.
> 3. If `build-runner == auto`: inspect the workspace root for Taskfile existence. If no
>    Taskfile is found, skip Task install and fall back to Make immediately. If a Taskfile
>    is found, install pinned Task **before** probing tasks via `task --list-all --json`.
>    If `all` and all five CI tasks exist, select Task; otherwise fall back to Make,
>    emitting a `::warning::` annotation naming the missing tasks. If a Taskfile exists,
>    tasks are missing, **and** there is no Makefile, fail the job.

## Acceptance Criteria

- [ ] New input `build-runner` (`auto` | `make` | `task`, default `auto`) on
  `go-ci-standalone.yml`, `go-ci-with-sibling.yml`, and `release-go-binary.yml`.
- [ ] New input `task-version` (default: pinned v3.x) so repos can bump independently.
- [ ] A "Detect build runner" step outputs `runner` (`make`/`task`) and is reused by
  every job that runs build commands.
- [ ] Pinned Task is installed via a SHA-pinned setup action (with version comment) or
  `go install github.com/go-task/task/v3/cmd/task@<version>` after discovering a Taskfile
  but *prior* to probing tasks via `task --list-all --json` (skipped entirely for explicit
  Make and Make-only auto runs).
- [ ] All build steps invoke `${{ steps.detect.outputs.runner }} <target>`.
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

### `.github/actions/setup-build-runner/action.yml` (new, recommended)

- Composite action shared by all three workflows to avoid duplicated logic.
- Inputs: `build-runner`, `task-version`, `required-tasks`. Output: `runner`.
- Logic: Taskfile discovery (same filename list as Powerword 5.12). If absent or
  `build-runner == make`, output `make` without installing Task. If Taskfile is found or
  `build-runner == task`, install pinned Task, probe task definitions with
  `task --list-all --json`, and select runner (with fallback warnings as appropriate).

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
