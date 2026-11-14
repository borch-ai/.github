# Taskfile Migration Guide (Build Contract v1)

This guide provides a zero-downtime, copy-paste migration path from `Makefile` to [Task](https://taskfile.dev) (`Taskfile.yml`) for **borch-ai** repositories implementing [Build Task Contract v1](./build-contract.md).

Using the transitional `Makefile.shim` and starter `Taskfile.go.yml` templates in [`templates/build/`](../templates/build/), repositories can adopt the shared organization Taskfile without breaking existing muscle memory (`make all`, `make test`), local git hooks, or CI workflows mid-migration.

---

## Staged Rollout Model

Both `powerword review --local` (Powerword Task 5.12) and the reusable GitHub Actions workflows (`.github` Task 2.4) synchronize their runner auto-detection on the exact same condition: **a `Taskfile.yml` that defines `all` plus the required CI contract targets**. Because both local and CI runners switch together, repositories never experience a split runner state.

| Stage | Repo state | `powerword review` (local) | CI workflow |
|-------|-----------|----------------------------|-------------|
| 0 | Makefile only | `make all` | `make <target>` |
| 1 | Starter Taskfile added, but `all` or CI targets not yet defined | `make all` (warns missing tasks) | `make <target>` (warns missing tasks) |
| 2 | Taskfile defines `all` and all required CI contract tasks | `task all` | `task <target>` |
| 3 | Makefile replaced by shim | `task all` | `task <target>` |
| 4 | Shim removed, docs updated (only after all callers migrated) | `task all` | `task <target>` |

> [!IMPORTANT]
> **When is Stage 4 (shim removal) allowed?**
> Stage 4 (removing the `Makefile` shim) is **only permitted once all calling workflows (including release workflows such as `release-go-binary.yml`), developer scripts, and hooks have adopted Task-aware runners**. Any repository that still has external or release callers invoking `make` must remain at **Stage 3**, where `Makefile.shim` transparently forwards `make <target>` to `task <target>`.

---

## Per-Repository Migration Checklist

Follow these steps in order when migrating a repository:

- [ ] **1. Install Task (v3.54.0+)**
  Ensure `task` (`go-task`) v3.54.0 or newer is installed locally:
  ```bash
  brew install go-task
  # or:
  go install github.com/go-task/task/v3/cmd/task@v3.54.0
  ```
- [ ] **2. Add the Starter Taskfile (`Taskfile.yml`)**
  Copy [`templates/build/Taskfile.go.yml`](../templates/build/Taskfile.go.yml) to `Taskfile.yml` at the root of the repository and pin the `includes.org.taskfile` URL to the latest `borch-ai/.github` release tag.
- [ ] **3. Configure Variables & Port Repository-Specific Targets**
  - Set `MIN_COVERAGE`, `BINARIES`, `LDFLAGS`, or `TEST_PKGS` under `vars:` in `Taskfile.yml` if the repository differs from the defaults in [`taskfiles/go.yml`](../taskfiles/go.yml).
  - If a standard contract target (such as `build` or `lint`) needs custom pre/post steps, replace its alias in `Taskfile.yml` with your custom commands and delegate to `task: org:<target>` as needed. Because `org:all` and `org:check-coverage` invoke subtasks via root-qualified references (`:lint`, `:vuln`, `:check-coverage`, `:build`, `:test`), your root override will automatically run during `task all`.
  - Port any non-contract targets (e.g., `integration-test`, `fix-plans`, `proto`) into `Taskfile.yml`.
- [ ] **4. Verify Contract Compliance with `powerword doctor`**
  Run `powerword doctor` (Powerword Task 5.13) and `task all` locally to verify that all required Build Contract v1 targets exist and pass:
  ```bash
  powerword doctor
  task all
  ```
- [ ] **5. Bump Reusable CI Workflow Tag**
  Update `.github/workflows/ci.yml` (and `.github/workflows/release.yml`, if applicable) to reference the Task-aware `.github` reusable workflow release tag (`.github` Task 2.4).
- [ ] **6. Replace `Makefile` with `Makefile.shim` (Stage 3)**
  Copy [`templates/build/Makefile.shim`](../templates/build/Makefile.shim) over the repository's `Makefile`.
  - **Check for colliding directory or file names:** If the repository has any custom targets whose names match an existing directory or file in the repo root (for example, `dist/`, `docs/`, `scripts/`, or `coverage`), append those target names to `EXPLICIT_TARGETS` in `Makefile`. This gives them both an explicit forwarding recipe and a `.PHONY` declaration so GNU Make does not treat the directory/file as already up to date or skip implicit pattern rules.
  - Verify that both `make all` and `task all` execute identically.
- [ ] **7. Update Repository Documentation**
  Update `README.md`, `GEMINI.md`, `.github/copilot-instructions.md`, and contributor docs to reference `task <target>` (while noting `make <target>` remains supported via the shim at Stage 3).

---

## Ecosystem Rollout Order

Repositories migrate in the following sequence:

1. **Kiln (Pilot)** — validates the Go starter Taskfile, remote include caching, `Makefile.shim`, and `powerword doctor` end-to-end.
2. **Pithos, Aeolian, Daedalus, Lighthouse** — standard Go repositories adopting `taskfiles/go.yml` and `Makefile.shim`.
3. **Powerword** (Powerword Task 5.14) — migrates once downstream consumers and self-hosted validation paths are verified.
4. **Inkling** (`.github` Task 2.5) — adopts the shared Python Taskfile (`taskfiles/python.yml`) for `uv`-managed projects.

> [!NOTE]
> **Out of Scope for v1:** Docker-, Node-, and mobile-heavy repositories (**Lamplighter**, **Knurl**, and **study-systems**) remain on `Makefile` for Contract v1.

---

## Troubleshooting

### `task: command not found`
Install Task v3.54.0+ via Homebrew (`brew install go-task`) or Go (`go install github.com/go-task/task/v3/cmd/task@v3.54.0`) and ensure `$(go env GOPATH)/bin` is on your `PATH`.

### Remote Include Cache & Offline Execution
Task v3.54.0+ caches remote `includes` under `.task/remote/` in the repository root and verifies checksums automatically.
- To force-refresh a cached remote Taskfile after bumping a tag:
  ```bash
  task --download
  ```
- Add `.task/` to `.gitignore` so cached remote Taskfiles and checksum state are never committed.

### Why does `powerword review` (or CI) still run `make all`?
Both `powerword review --local` and the reusable CI workflows only switch from `make` to `task` when `Taskfile.yml` defines `all` **and** every required contract target (`build`, `test`, `lint`, `fmt`, `tidy`, `vuln`, `check-coverage`, `clean`, `install-hooks`). Run `powerword doctor` to see which contract target is missing from your root `Taskfile.yml`.

### `make <target>` says ``make: `<target>' is up to date``
This happens when `<target>` matches a directory or file name on disk (such as `build/`, `dist/`, or `docs/`). In GNU Make, `.PHONY` alone does not trigger pattern rules (`%:`) for existing paths. Add the target name to `EXPLICIT_TARGETS` in your `Makefile` shim so it receives both `.PHONY` and an explicit `@task $@` recipe.
