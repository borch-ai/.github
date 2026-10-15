# Plan: Task 2.4: Task-Aware Reusable Go CI Workflows

**Status:** Proposed
**Depends On:** Task 2.1 (names only — can proceed in parallel with 2.2 and 2.3)

`go-ci-standalone.yml` and `go-ci-with-sibling.yml` hardcode `make lint`, `make tidy`,
`make vuln`, `make check-coverage`, and `make build`. Add a `build-runner` input with
auto-detection matching Powerword's local resolver (Powerword Task 5.12), so a repo's CI
switches to Task at the same moment its pre-push hook does — with no workflow edits in the
consuming repo beyond a tag bump.

## User Review Required

> [!NOTE]
> Backward compatible: with `build-runner: auto` (the default), repos without a Taskfile
> keep running `make <target>` exactly as today.

### Detection Rule

> [!IMPORTANT]
> Detection rule (mirrors Powerword 5.12): use Task only if a Taskfile exists **and**
> defines all CI-invoked tasks (`lint`, `tidy`, `vuln`, `check-coverage`, `build`);
> otherwise fall back to Make, emitting a `::warning::` annotation that names the missing
> tasks. If a Taskfile exists, tasks are missing, **and** there is no Makefile, fail the
> job.

## Acceptance Criteria

- [ ] New input `build-runner` (`auto` | `make` | `task`, default `auto`) on both
  workflows.
- [ ] New input `task-version` (default: pinned v3.x) so repos can bump independently.
- [ ] A "Detect build runner" step outputs `runner` (`make`/`task`) and is reused by
  every job that runs build commands.
- [ ] When `runner == task`, Task is installed via a SHA-pinned setup action (with
  version comment) or `go install github.com/go-task/task/v3/cmd/task@<version>`.
- [ ] All build steps invoke `${{ steps.detect.outputs.runner }} <target>`.
- [ ] The existing `coverage-threshold` input is passed as `MIN_COVERAGE` (env for Task,
  `MIN_COVERAGE=...` arg for Make). Verify during implementation whether the input is
  currently forwarded to `check-coverage` at all; fix if not.
- [ ] Harden-runner remains the first step; egress audit covers the Task download host.
- [ ] `ci-self-test.yml` exercises both runners against fixtures (Make-only fixture and
  Task fixture from Task 2.2).
- [ ] Released under a new tag; Dependabot picks it up in consumer repos.

## Proposed Changes

### `.github/workflows/go-ci-standalone.yml`, `.github/workflows/go-ci-with-sibling.yml`

- Add inputs, detection step, conditional Task install, parameterized run steps.

### `.github/actions/setup-build-runner/action.yml` (new, recommended)

- Composite action shared by both workflows to avoid duplicated logic.
- Inputs: `build-runner`, `task-version`, `required-tasks`. Output: `runner`.
- Logic: Taskfile discovery (same filename list as Powerword 5.12), `task --list-all
  --json` check, Make fallback, warning/failure annotations.

### `.github/workflows/ci-self-test.yml`

- Matrix over `fixture: [make, task, task-partial]` asserting the selected runner.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Detection drift vs. Powerword's local resolver | Medium | Same filename list and rules documented in both plans; self-test covers the partial case. |
| Task install adds CI time / supply-chain surface | Low | Install only when needed; pinned version and SHA. |
| `with-sibling` `patch-gomod` flow depends on Make | Medium | Keep `patch-gomod` as a repo-specific task; workflow calls it via the detected runner. |

## Verification Plan

### Automated Tests

- `ci-self-test.yml` matrix passes for all three fixtures; `actionlint` and `yamllint`
  pass.

### Manual Verification

- Point a scratch branch of a consumer repo (not Kiln while it has in-flight work) at
  the new workflow ref and confirm unchanged Make behavior.
