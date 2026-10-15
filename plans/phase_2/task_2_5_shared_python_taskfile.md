# Plan: Task 2.5: Shared Python Taskfile

**Status:** Proposed
**Depends On:** Task 2.1 (names only); reuses the distribution mechanism chosen in Task 2.2

Publish `taskfiles/python.yml` implementing the build task contract for `uv`-managed
Python repositories (initially Inkling), so Python repos get the same `task all` entry
point and Powerword pre-push validation as Go repos.

## User Review Required

> [!NOTE]
> Lower priority than Tasks 2.1–2.4. Can start any time, but should ship after Task 2.2
> settles the distribution mechanism so both files are consumed the same way.

## Acceptance Criteria

- [ ] `taskfiles/python.yml` implements the required contract tasks with `uv`:
  - `build` → `uv build` (or no-op with message for non-packaged apps).
  - `test` → `uv run pytest --cov --cov-report=xml`.
  - `lint` → `uv run ruff check`; `fmt` → `uv run ruff format`.
  - `tidy` → `uv lock`.
  - `vuln` → `uv run pip-audit` (or equivalent; confirm tool choice during
    implementation).
  - `check-coverage` → `test`, then `{{.POWERWORD}} check-coverage {{.MIN_COVERAGE}} coverage.xml`
    (Cobertura support from Powerword Task 5.7).
  - `clean`, `install-hooks` (from `hooks.yml`), `all`.
- [ ] Overridable vars: `MIN_COVERAGE`, `POWERWORD`, `SRC_DIRS`, `TEST_DIRS`.
- [ ] CI self-test fixture (`tests/taskfiles/python-fixture/`) runs `task all`.

## Proposed Changes

### `taskfiles/python.yml` (new)

### `templates/build/Taskfile.python.yml` (new)

- Starter Taskfile mirroring the Go starter from Task 2.3.

### `.github/workflows/ci-self-test.yml`

- Add Python fixture job (setup-uv pinned to SHA).

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Inkling uses repo-specific targets (`train`, `notebook`, `pr-*`) | High | Those remain local tasks; only contract tasks come from the org file. |
| Vulnerability tooling differs across Python repos | Medium | `vuln` delegates to a var-defined command. |

## Verification Plan

### Automated Tests

- CI self-test runs `task all` on the Python fixture.

### Manual Verification

- In a scratch clone of Inkling, include the Taskfile and confirm `task test`,
  `task lint`, and `task check-coverage` match the existing Makefile targets.
