# Plan: Task 2.2: Shared Go Taskfile & Distribution Mechanism

**Status:** Proposed
**Depends On:** Task 2.1 (names only — fixed in that plan, so work can proceed in parallel)

Publish a reusable `taskfiles/go.yml` (plus `taskfiles/hooks.yml`) implementing the
build task contract for Go repositories, and decide how consuming repos pull it in at a
pinned version. This replaces ~10 near-identical Makefile targets duplicated across
Aeolian, Daedalus, Kiln, Pithos, Lighthouse, and Powerword.

## User Review Required

> [!IMPORTANT]
> **Distribution decision (first step of this task).** Two options:
>
> 1. **Remote include** — `includes: { org: { taskfile: https://raw.githubusercontent.com/borch-ai/.github/<tag>/taskfiles/go.yml } }`.
>    Simplest for consumers, but Remote Taskfiles were long gated behind the
>    `TASK_X_REMOTE_TASKFILES` experiment. Adopt only if it is GA in the pinned Task
>    version, and confirm offline/cache behavior for the pre-push hook.
> 2. **Vendored copy (recommended fallback)** — consumers commit
>    `.taskfiles/borch-ai/go.yml` with a header recording the source tag and checksum;
>    a `taskfile-sync` reusable workflow (scheduled) opens a PR when a newer tag exists.
>    Works offline and is reviewable in diffs.
>
> Record the decision and rationale in this plan before implementing the Taskfile.

### Override Semantics

> [!NOTE]
> **Override semantics & root-qualified orchestration.** Task namespaces includes (`org:lint`);
> it does not let a local task silently replace an included one. The consumer pattern is:
> a repo's top-level `Taskfile.yml` defines each contract task as a thin alias
> (`lint: { cmds: [task: org:lint] }`) to *inherit*, or with its own commands to *override*.
> Crucially, when composite tasks inside `taskfiles/go.yml` (such as `all` or `check-coverage`)
> invoke other contract tasks, they must use root-qualified calls (`:build`, `:lint`, `:vuln`,
> `:check-coverage`, `:test` with a leading colon). This ensures that running `task all` or
> triggering pre-push validation honors the consuming repository's root overrides rather than
> defaulting to internal `org:*` tasks. Task 2.3 ships a starter Taskfile with all aliases
> pre-written. Evaluate `flatten`/`excludes` include options in the pinned version as a possible
> simplification.

## Acceptance Criteria

- [ ] `taskfiles/go.yml` implements every required contract task (Task 2.1) using
  overridable vars: `MIN_COVERAGE`, `POWERWORD`, `VERSION`, `LDFLAGS`, `BINARIES`
  (list of `cmd/*` names), `TEST_PKGS`, `COVERPKG`.
- [ ] Composite and orchestration tasks in `taskfiles/go.yml` (`all`, `check-coverage`)
  invoke subtasks via root-qualified references (e.g. `:build`, `:lint`, `:vuln`,
  `:check-coverage`, `:test`) so consumer root overrides take effect during aggregate execution.
- [ ] `build` loops over `BINARIES` (default: every directory under `cmd/`) and uses
  `sources`/`generates` for incremental builds.
- [ ] `lint`, `vuln`, `check-coverage` delegate to `{{.POWERWORD}}` with a
  `preconditions` check that prints an install hint when the default `powerword` binary
  is missing (skipped when `POWERWORD` is overridden).
- [ ] `taskfiles/hooks.yml` provides `install-hooks` (copies the org pre-push hook).
- [ ] Every task has a `desc:` so `task --list` is self-documenting.
- [ ] Minimum Task version declared and documented (latest v3.x at implementation time).
- [ ] Distribution mechanism implemented (remote include docs **or** `taskfile-sync`
  reusable workflow).
- [ ] Fixture tests in CI self-test verify both standard inheritance and that overriding
  `build` or `lint` in a consumer root Taskfile executes the override when running `task all`.
- [ ] Released under a new `.github` tag.

## Proposed Changes

### `taskfiles/go.yml` (new)

- `version: '3'`, `vars:` with defaults per the contract, contract tasks with `desc:`.
- `all: { deps: [":lint", ":vuln", ":check-coverage"], cmds: [task: :build] }`.
- `check-coverage: { deps: [":test"], cmds: ["{{.POWERWORD}} check-coverage --min {{.MIN_COVERAGE}}"] }`.

### `taskfiles/hooks.yml` (new)

- `install-hooks` task; the hook script itself stays in each repo for now.

### `.github/workflows/taskfile-sync.yml` (new, only if vendoring is chosen)

- Reusable workflow: compares the vendored header tag with the latest `.github` tag,
  copies updated files, opens a PR with a conventional `chore(taskfile): ...` title.
- Harden-runner first step; third-party actions pinned to SHAs.

### `tests/taskfiles/go-fixture/` (new)

- Minimal Go module (one `cmd/`, one package with a test) used by CI self-test.

### `.github/workflows/ci-self-test.yml`

- Add a job that installs Task (pinned) and runs `task all` against the fixture.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Remote includes not GA / require network in pre-push | Medium | Vendored fallback with sync workflow. |
| Repo-specific needs (CGO plugin, `patch-gomod`) don't fit | High | Everything is var-driven; repos override individual tasks via aliases. |
| `powerword` binary unavailable in some environments | Medium | Clear precondition message; `POWERWORD` var allows `go run` or a pinned path. |

## Verification Plan

### Automated Tests

- CI self-test runs `task all` on the fixture module and asserts `bin/` contents.

### Manual Verification

- In a scratch clone of Kiln (no commits), include the Taskfile and confirm `task all`
  matches `make all` results.
