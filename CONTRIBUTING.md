# Contributing to borch-ai

Thank you for contributing to the **borch-ai** publishing ecosystem. This guide applies to all repositories in the organization: **Kiln**, **Pithos**, **Powerword**, **Aeolian**, **Lighthouse**, and **Lamplighter**.

---

## Code Quality Standards

All repositories enforce the same quality gate. Run the full pipeline before pushing:

```bash
make
```

Individual targets (all repos):

| Target | What it does |
|---|---|
| `make fmt` | `gofmt -w -s .` |
| `make lint` | `golangci-lint run ./...` via `powerword lint-go` |
| `make vuln` | `govulncheck ./...` — detects CVEs in reachable code |
| `make check-coverage` | Tests + enforces **≥ 91% unit test coverage** |
| `make build` | Compiles the repo binary |

> [!IMPORTANT]
> The **91% unit test coverage** threshold is an org-wide hard requirement. PRs that drop coverage below this threshold will not be merged.

---

## Pre-Push Hook

Each repo ships a source-controlled pre-push hook. Install it once with:

```bash
make install-hooks
```

The hook runs `make all` then `powerword review --local`, which validates your diff against the assigned implementation plan. **Never bypass it with `git push --no-verify`** — fix the underlying issue instead.

---

## Branching & Merging Policy

- **Branch naming**: `task/<number>-<short-description>` (e.g. `task/3.9-cli-beautification`)
- **No direct pushes to `main`**: All changes go through a Pull Request. Branch protection is enforced.
- **Squash merge only**: All PRs are squash-merged to keep git history clean and bisectable.

---

## Pull Request Workflow

1. Open a PR from your task branch targeting `main`.
2. Ensure all CI checks pass (lint, CodeQL, coverage, PR title format).
3. After opening or updating a PR, poll for **Copilot Code Review** comments on a 30-second interval, up to a 7-minute timeout. Address all comments before declaring the task complete.
4. **Never merge your own PR.** Present the PR URL and its status, then wait for an explicit human approval to merge.

---

## Cross-Repository Boundaries

The borch-ai stack has strict ownership boundaries:

| Capability | Belongs in |
|---|---|
| New LLM / image-gen backends | **Powerword** (`pw-mcp-*` plugin) |
| Book factory pipeline logic | **Pithos** |
| Business orchestration & state | **Kiln** |
| Media / music pipeline | **Aeolian** |
| Telemetry sink & analytics | **Lighthouse** |

**Do not embed API client code for LLMs or external services directly in Kiln or Aeolian.** Build a Powerword MCP plugin and consume it via MCP stdio.

---

## Testing Standards

- Place `_test.go` files in the same package as the code under test.
- Use **table-driven tests** (`[]struct{ ... }`).
- Use interfaces for mocking — never make real network calls in unit tests.
- Integration tests use the `//go:build integration` build tag.

---

## Implementation Plans

Every non-trivial task starts from a plan file in `plans/`. Before writing code:

1. Read the plan for your task in `plans/`.
2. Read `ROADMAP.md` to understand context and avoid duplicating planned work.
3. Update the plan with final implementation choices and coverage achieved before closing the task.

---

## Security Issues

**Do not open a public issue for security vulnerabilities.** See [SECURITY.md](SECURITY.md) for the responsible disclosure process.
