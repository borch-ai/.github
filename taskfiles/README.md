# Borch-AI Shared Taskfiles

This directory contains reusable, contract-conforming [Taskfile](https://taskfile.dev) definitions shared across the Borch-AI organization.

## Requirements

- **Task Version:** Task `v3.54.0` or higher.
  - Remote Taskfiles are generally available and enabled by default without feature flags starting in Task v3.53.0+.
  - Install Task via `go install github.com/go-task/task/v3/cmd/task@v3.54.0` or your package manager.

## Available Taskfiles

- **`taskfiles/go.yml`**: Shared Go build tasks conforming to [Build Task Contract v1](../docs/build-contract.md). Provides all 10 required contract tasks (`all`, `build`, `test`, `lint`, `fmt`, `tidy`, `vuln`, `check-coverage`, `clean`, `install-hooks`).
- **`taskfiles/hooks.yml`**: Shared Git hook management tasks. Provides `install-hooks` to install the standard pre-push hook into `.git/hooks/pre-push`.

## Distribution Mechanism: Remote Include

Repositories include the shared taskfile directly from `.github` tagged releases via HTTPS remote includes. Task validates checksums and caches the downloaded taskfile locally under `.task/`.

### Consuming in a Go Repository

Create or update `Taskfile.yml` in the repository root:

```yaml
# https://taskfile.dev
version: '3'

vars:
  POWERWORD: '{{.POWERWORD | default "powerword"}}'
  MIN_COVERAGE: '{{.MIN_COVERAGE | default "91"}}'

includes:
  org:
    taskfile: https://raw.githubusercontent.com/borch-ai/.github/v0.3.0/taskfiles/go.yml
    vars:
      POWERWORD: '{{.POWERWORD}}'
      MIN_COVERAGE: '{{.MIN_COVERAGE}}'

tasks:
  all:
    desc: Run standard quality gate
    cmds:
      - task: org:all

  build:
    desc: Build binary artifacts
    cmds:
      - task: org:build

  test:
    desc: Run unit tests with race detection and coverage
    cmds:
      - task: org:test

  lint:
    desc: Run static analysis
    cmds:
      - task: org:lint

  fmt:
    desc: Format source code
    cmds:
      - task: org:fmt

  tidy:
    desc: Tidy dependencies
    cmds:
      - task: org:tidy

  vuln:
    desc: Scan dependencies for vulnerabilities
    cmds:
      - task: org:vuln

  check-coverage:
    desc: Verify test coverage threshold
    cmds:
      - task: org:check-coverage

  clean:
    desc: Remove build artifacts
    cmds:
      - task: org:clean

  install-hooks:
    desc: Install pre-push git hook
    cmds:
      - task: org:install-hooks
```

## Overriding Tasks and Variables

### Variable Overrides

The shared taskfile exposes the following overridable variables:

| Variable | Default | Purpose |
|----------|---------|---------|
| `MIN_COVERAGE` | `91` (or `.COVERAGE_THRESHOLD`) | Minimum code coverage percentage required by `check-coverage`. |
| `POWERWORD` | `powerword` | Command or path used to invoke Powerword tooling. |
| `VERSION` | `dev` | Semantic version string injected into binaries via linker flags. |
| `LDFLAGS` | `-s -w -X main.version={{.VERSION}}` | Go linker flags passed during `go build`. |
| `BINARIES` | Directories under `cmd/` | Space- or newline-separated list of binary names to compile. |
| `BIN_DIR` | `bin` | Target directory for compiled binaries. |
| `TEST_PKGS` | `./...` | Package pattern evaluated by `go test`. |
| `COVERPKG` | `./...` | Package pattern evaluated for coverage calculations. |
| `COVERAGE_PROFILE` | `coverage.out` | Output file path for test coverage profile data. |

To override a variable for your repository, define it in the root `Taskfile.yml` and forward it in the `includes.org.vars` map:

```yaml
vars:
  MIN_COVERAGE: '85'
  BINARIES: 'server worker'

includes:
  org:
    taskfile: https://raw.githubusercontent.com/borch-ai/.github/v0.3.0/taskfiles/go.yml
    vars:
      MIN_COVERAGE: '{{.MIN_COVERAGE}}'
      BINARIES: '{{.BINARIES}}'
```

### Task Overrides & Root Qualification

Composite tasks in `taskfiles/go.yml` (such as `all` and `check-coverage`) invoke contract tasks using root-qualified references (e.g. `:build`, `:lint`, `:vuln`, `:check-coverage`, `:test`).

This ensures that if a consuming repository overrides a specific task in its root `Taskfile.yml`, executing `task all` or triggering pre-push validation honors the repository's root override:

```yaml
tasks:
  # Custom build task overriding the shared default
  build:
    desc: Custom build with CGO enabled
    cmds:
      - CGO_ENABLED=1 go build -o bin/custom ./cmd/custom
```
