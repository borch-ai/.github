# CHANGELOG

All notable changes to the shared borch-ai GitHub configuration and reusable workflows are documented here.
Downstream repositories pick up workflow changes automatically on next CI run, so this changelog helps teams
understand what changed and why — especially when unexpected CI failures occur.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [Unreleased]

### Added

- **ci-self-test.yml**: New workflow that validates all workflow YAML files in this repo using `yamllint` and `actionlint` on every PR touching `.github/workflows/`.
- **ISSUE_TEMPLATE/bug.yml**: Structured bug report form with required fields for affected repo, description, and reproduction steps.
- **CODEOWNERS**: Requires review from `@borch-ai/platform` for changes to any workflow file.

### Changed

- **All workflows**: Pinned all GitHub Action references to full commit SHAs (supply chain hardening). Version tags are preserved as inline comments.
- **codeql-with-sibling.yml**: Added missing `step-security/harden-runner` step.
- **pr-title.yml**: Upgraded `amannn/action-semantic-pull-request` from `v5` → `v6.1.1`. Switched Harden Runner to `egress-policy: block` (no external network calls in this job).
- **pr-description.yml**: Switched Harden Runner to `egress-policy: block` (no external network calls in this job).
- **scorecard.yml**: Upgraded `ossf/scorecard-action` from `v2.4.0` → `v2.4.3`.
- **ISSUE_TEMPLATE/adr.md**: Added `daedalus` to the list of affected repositories.
- **CONTRIBUTING.md**: Added `daedalus` to the cross-repository boundary table.
- **ci-self-test.yml**: Updated actionlint downloader script reference to use tag `v1.7.7`'s commit SHA and pinned the binary download to `1.7.7` for supply chain security.
- **rulesets/core_branch_protection.json**: Added `required_status_checks` rule requiring "Code Linting" and "Security & Tests" checks to pass.
- **CONTRIBUTING.md**: Added `daedalus` to the boundary table, and documented the required status checks constraint.

---

## [2026-07-01]

### Added
- **daedalus-scan.yml**: Reusable workflow to run Daedalus ecosystem health scans.
- **pr-description.yml**: Reusable workflow to enforce PR description template compliance.
- **scorecard.yml**: Reusable OpenSSF Scorecard analysis workflow.
- **codeql-with-sibling.yml**: Reusable CodeQL workflow for repos with sibling `replace` directives.
- Harden Runner (`step-security/harden-runner`) added to all CI workflows.
- ShellCheck, Hadolint, and Yamllint linting steps added to `go-ci-*.yml`.

---

## [2026-06-15]

### Added
- **go-ci-standalone.yml**: Initial reusable Go CI workflow (lint, security scan, tests, build).
- **go-ci-with-sibling.yml**: Variant for repos with sibling `replace` directives.
- **codeql.yml**: Reusable CodeQL analysis workflow.
- **pr-title.yml**: Conventional Commits PR title enforcement.
- **link-task-issue.yml**: Automated issue linking via powerword.
- **ISSUE_TEMPLATE/**: `adr.md` and `implementation-plan.yml` templates.
- Community health files: `CODE_OF_CONDUCT.md`, `CONTRIBUTING.md`, `SECURITY.md`, `SUPPORT.md`.
- **rulesets/**: `core_branch_protection.json` and `branch_naming_rules.json`.
