# Borch-AI Build Task Contract (v1)

The **Build Task Contract** defines the standard task names, execution semantics, and shared variables that Borch-AI repositories expose as they adopt the Phase 2 Taskfile build paradigm. It acts as a tool-agnostic interface across the ecosystem—whether a repository is orchestrated via Task (`Taskfile.yml`) or a transitional forwarding Makefile shim.

The contract serves as the canonical specification for:

- **Powerword Validation Auto-detection** (`powerword review --local`)
- **Conformance Auditing** (`powerword doctor`)
- **Shared Taskfiles** (`Taskfile.go.yml`, `Taskfile.python.yml`)
- **Task-Aware Reusable CI Workflows** in `.github`

---

## Scope & Rollout (Contract v1)

- **Target Ecosystem:** Contract v1 targets Go-based and Python-based repositories participating in the Phase 2 build paradigm rollout (Kiln, Pithos, Powerword, Aeolian, Lighthouse, Daedalus, and Inkling), staged through the Kiln pilot migration.
- **Explicit Exclusions:** Docker-heavy, Node.js-heavy, and frontend mobile repositories (specifically **Lamplighter**, **Knurl**, and **study-systems**) are **explicitly out of scope** for Contract v1. These repositories maintain their specialized tooling until future phases.
- **Rollout Model:** The contract establishes the target interface for Phase 2. Conformance is achieved progressively as each repository completes its migration checklist (see `ROADMAP.md`).

---

## Contract v1 Specification

### Required Tasks

Every conforming Borch-AI repository **must** provide the following 10 tasks:

| Task | Semantics |
|------|-----------|
| `all` | Full local quality gate. Must execute at least `lint`, `vuln`, `check-coverage`, and `build`. This is the target executed by `powerword review` and the org-wide pre-push hook. |
| `build` | Compile all application and binary artifacts into `bin/` (or the language-appropriate distribution directory). |
| `test` | Run unit tests with race detection enabled (where supported by language runtime) and generate a code coverage profile. |
| `lint` | Execute static analysis and linting (Go: `powerword lint-go`). |
| `fmt` | Apply code formatting in place. |
| `tidy` | Normalize dependency manifests (Go: `go mod tidy`; Python: `uv lock`). CI validates that no uncommitted diff remains. |
| `vuln` | Perform known-vulnerability security scanning against dependencies (Go: `powerword vuln`). |
| `check-coverage` | Execute unit tests via `test`, then strictly enforce the `MIN_COVERAGE` threshold (Go: `powerword check-coverage`). |
| `clean` | Remove all generated build artifacts, temporary directories, and coverage profiles. |
| `install-hooks` | Install the standard Borch-AI pre-push hook into `.git/hooks`. |

### Optional (Reserved) Tasks

Repositories implementing the following extended workflows **must** use these reserved task names to maintain ecosystem consistency:

| Task | Purpose |
|------|---------|
| `install` | Install binaries or package artifacts into the user's `$PATH` or local environment. |
| `test-integration` | Run long-running integration, end-to-end, or external service test suites. |
| `test-fast` | Fast unit-test pass excluding race detection, integration checks, or coverage computation. |
| `dist` | Package production distribution archives (e.g., tarballs, container images, cross-compiled assets). |
| `fix-plans` | Run automated plan alignment or formatting fixes on task and phase plan files. |

### Shared Variables

Conforming build configurations accept and honor these standard environment variables and task variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `MIN_COVERAGE` | `91` | Code coverage percentage threshold. Reusable CI workflows (Task 2.4) and migration tooling pass coverage threshold inputs through this variable. **Migration Note:** Existing Makefiles read `COVERAGE_THRESHOLD`. In current workflows prior to Task 2.4, `.github/workflows/go-ci-with-sibling.yml` exports only `COVERAGE_THRESHOLD`, while `go-ci-standalone.yml` defaults to local repo variables. When Task 2.4 lands, reusable workflows will export *both* `MIN_COVERAGE` and `COVERAGE_THRESHOLD` for dual-variable forwarding. In the interim, transitional Makefiles and Taskfiles should fall back gracefully (e.g. `MIN_COVERAGE ?= $(or $(COVERAGE_THRESHOLD),91)`). |
| `POWERWORD` | `powerword` | Command or path used to invoke Powerword tooling (Powerword itself overrides this to `go run ./cmd/powerword`). |
| `VERSION` | `dev` | Semantic version string stamped into binary builds via linker flags or package metadata. |

---

## Contract Rules

1. **Naming Convention:** All task names are strictly `kebab-case`.
2. **Semantic Preservation:** Repository-specific tasks are encouraged (for example, `patch-gomod` in Pithos or Daedalus), but repository tasks must **never** reuse a contract task name with different semantics.
3. **Conformance Criteria:** A repository conforms to Contract v1 when:
   - Every one of the 10 required tasks exists and is runnable.
   - `all` executes at least `lint`, `vuln`, `check-coverage`, and `build`.
4. **Composition Freedom:** Repositories may include additional validation checks inside `all` (such as `markdown-lint`), provided the core four requirements are satisfied.
5. **Contract Versioning:** Changes to task names, semantics, or shared variables require:
   - Bumping the contract version specification (e.g., Contract v2).
   - Coordinated updates in Powerword's `defaultRequiredTasks` and `defaultValidationTask`.
   - Explicit documentation in `CHANGELOG.md`.

---

## Frequently Asked Questions (FAQ)

### Can I override `lint` to run additional linters?

**Yes.** You may customize or chain additional linters in your repository's `lint` task (such as running ShellCheck or Markdownlint in addition to language analysis), as long as the base quality gate semantics hold.

### Can I add repository-specific tasks?

**Yes.** Repositories frequently have unique needs (e.g., database migrations, code generators, seed scripts). You are free to add any custom tasks as long as their names do not collide with contract tasks.

### What happened to historical drift between repositories?

Historically, Kiln ran `lint build test` while Pithos and Powerword ran `lint vuln check-coverage build`. Contract v1 standardizes on the stricter quality gate to guarantee zero regression before push and CI.

### How does `powerword doctor` verify compliance?

`powerword doctor` inspects the active `Taskfile.yml` or `Makefile` in the repository, validates that all 10 required task names are present, verifies that the `task` executable is available, and flags non-conforming build setups.

### Which repositories are within the scope of Contract v1?

Contract v1 applies to Go-based and Python-based repositories participating in Phase 2 (Kiln, Pithos, Powerword, Aeolian, Lighthouse, Daedalus, and Inkling). Non-Go/Python repositories—specifically **Lamplighter** (React Native/mobile), **Knurl** (Node/TypeScript), and **study-systems**—are explicitly excluded from v1.

### How does coverage variable forwarding work between Make and Task?

Contract v1 defines `MIN_COVERAGE` as the standard variable name for Taskfiles, whereas legacy Makefiles expect `COVERAGE_THRESHOLD`. During Phase 2, Task 2.4 will update reusable CI workflows to export *both* variables simultaneously. Until Task 2.4 is deployed across all workflows, repos should accept both variables (e.g. `MIN_COVERAGE ?= $(COVERAGE_THRESHOLD)`) to ensure non-default CI thresholds continue to be enforced.
