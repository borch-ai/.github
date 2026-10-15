# Plan: Task 3.1: In-House Task Setup Action & Binary Verification

**Status:** Proposed
**Depends On:** Phase 2 (Task 2.4 - Task-Aware CI)

Replace external setup action dependencies (specifically `arduino/setup-task`) with an in-house
composite action (`.github/actions/setup-task`) that fetches official pre-compiled Task binaries,
verifies cryptographic SHA-256 checksums, and integrates with the runner tool cache.

## User Review Required

> [!NOTE]
> This action eliminates external third-party marketplace dependencies from the core Borch-AI
> build chain, strengthening supply chain security and guaranteeing deterministic, checksummed binary
> installations.

## Acceptance Criteria

- [ ] `.github/actions/setup-task/action.yml` created as a composite action accepting `version`
  (default: pinned, e.g. `3.54.0`).
- [ ] Direct download from official Task releases (`https://github.com/go-task/task/releases/download/...`).
- [ ] Strict cryptographic checksum verification (SHA-256) matching official Task checksums before execution.
- [ ] Supports runner operating systems and architectures (Linux x86_64, Linux ARM64, macOS x86_64, macOS ARM64).
- [ ] Adds the verified binary to `$RUNNER_TOOL_CACHE` or `$GITHUB_PATH`.
- [ ] Reusable workflows (`go-ci-standalone.yml`, `go-ci-with-sibling.yml`, `release-go-binary.yml`, and `ci-self-test.yml`)
  migrate from external actions to `.github/actions/setup-task`.
- [ ] CI self-test verifies that `.github/actions/setup-task` correctly installs Task, validates checksum, and runs tasks.

## Proposed Changes

### `.github/actions/setup-task/action.yml` (new)

- Composite action definition.
- Architecture and OS detection.
- Checksum validation map or verification against official release checksums.
- Binary extraction into `$RUNNER_TOOL_CACHE` and export to `$GITHUB_PATH`.

### Reusable Workflows & CI

- Replace `arduino/setup-task` references across `.github/workflows/`.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| GitHub Release download rate limits on unauthenticated runner | Low | Use `GITHUB_TOKEN` in `curl` auth header if available. |
| Checksum mismatch on new release bumps | Medium | Provide checksum map or verify against official release `task_checksums.txt`. |

## Verification Plan

### Automated Tests

- CI self-test runs `setup-task` across runner environments and executes test fixtures.
