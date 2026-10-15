# Plan: Task 2.1: Build Task Contract

**Status:** Complete
**Depends On:** None

Define the org-wide **build task contract**: the standard task names, their semantics, and
the shared variables every Borch-AI repository exposes, regardless of whether it uses Make
or Task. The contract is the interface that Powerword's validation auto-detection
(Powerword Task 5.12), `powerword doctor` (Powerword Task 5.13), the shared Taskfiles
(Task 2.2, 2.5), and the Task-aware reusable CI (Task 2.4) all depend on.

## User Review Required

> [!IMPORTANT]
> **The task names below are fixed by this plan** so dependent tasks (here and in
> Powerword) can be implemented in parallel. Changing a name after those tasks start
> requires coordinated updates in Powerword (`defaultValidationTask`,
> `defaultRequiredTasks`) and in Tasks 2.2, 2.4, and 2.5.

### Current Drift

> [!NOTE]
> The repos have already drifted: Kiln's `all` runs `lint build test`, while Pithos and
> Powerword run `lint vuln check-coverage build`; Kiln computes coverage with `awk` while
> Pithos calls `powerword check-coverage`. The contract standardizes on the stricter
> Pithos/Powerword semantics.

## Contract v1

### Required Tasks

| Task | Semantics |
|------|-----------|
| `all` | Full local quality gate. Must run at least `lint`, `vuln`, `check-coverage`, `build`. This is what `powerword review` and the pre-push hook execute. |
| `build` | Compile all artifacts into `bin/` (or language equivalent). |
| `test` | Run unit tests with race detection (where applicable), writing a coverage profile. |
| `lint` | Static analysis (Go: `powerword lint-go`). |
| `fmt` | Apply formatting in place. |
| `tidy` | Normalize dependency manifests (Go: `go mod tidy`; Python: `uv lock`). CI verifies no diff afterwards. |
| `vuln` | Known-vulnerability scan (Go: `powerword vuln`). |
| `check-coverage` | Run `test`, then enforce `MIN_COVERAGE` (Go: `powerword check-coverage`). |
| `clean` | Remove build outputs and coverage files. |
| `install-hooks` | Install the org pre-push hook into `.git/hooks`. |

### Optional (Reserved) Tasks

Repos that provide these must use these names: `install`, `test-integration`,
`test-fast`, `dist`, `fix-plans`.

### Shared Variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `MIN_COVERAGE` | `91` | Coverage threshold; CI passes the `coverage-threshold` input through this. Note: existing Makefiles read `COVERAGE_THRESHOLD`; CI workflows and tooling will export both variables during migration for backward compatibility. |
| `POWERWORD` | `powerword` | How to invoke Powerword (Powerword itself uses `go run ./cmd/powerword`). |
| `VERSION` | `dev` | Version stamped into binaries. |

### Rules

- Task names are kebab-case.
- Repo-specific tasks are allowed and encouraged (e.g., `patch-gomod` in Pithos/Daedalus),
  but must not reuse a contract name with different semantics.
- A repository conforms when every required task exists and `all` meets its semantics.

## Acceptance Criteria

- [x] `docs/build-contract.md` published with the content above, versioned as
  "contract v1".
- [x] Linked from `profile/README.md` and the `.github` `README.md`.
- [x] Contract changes require bumping the contract version and a note in
  `CHANGELOG.md`.

## Proposed Changes

### `docs/build-contract.md` (new)

- Contract tables, rules, and a short FAQ ("Can I override `lint`?" → yes, as long as
  semantics hold).

### `profile/README.md`, `README.md`

- Add a "Build System" section linking to the contract and migration guide (Task 2.3).

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Repos need a different `all` composition | Medium | Contract defines a minimum; repos may add steps (e.g. Powerword's `markdown-lint`). |
| Non-Go repos can't satisfy Go-centric semantics | Medium | Semantics are phrased per language; Docker/Node-heavy repos (Lamplighter, Knurl, study-systems) are explicitly out of scope for v1. |

## Verification Plan

### Manual Verification

- Cross-check the required list against Powerword Task 5.12 (`all`) and 5.13
  (`defaultRequiredTasks`) plans for exact name parity.
- Markdown lint passes (`markdown-lint.yml`).
