# Plan: Task 1.3: Daedalus Plan-PR Alignment Critic

**Status:** Proposed
**Depends On:** None

Build a centralized workflow that integrates with Daedalus or Powerword to analyze Pull Request code diffs against architectural plans, evaluating alignment and warning developers of potential design drift.

## User Review Required

> [!IMPORTANT]
> **LLM API Keys:** Running design critic checks requires LLM access (e.g., Gemini API keys). The token `GEMINI_API_KEY` must be configured as an organization-level secret or repository-level secret.
>
> **PR Permissions:** The workflow needs `pull-requests: write` permissions to write feedback comments on incoming PRs.

## Acceptance Criteria

- [ ] Reusable workflow in `.github/workflows/daedalus-plan-critic.yml`.
- [ ] Triggers on `pull_request` (`opened`, `synchronize`, `reopened`) events.
- [ ] Workflow steps:
  1. Check out repository (with full history or at least the base branch history).
  2. Parse the files changed in the PR to find any `.md` files in `plans/` or check if the branch name references a specific task ID (e.g., `task-1-3`).
  3. Invoke `daedalus review --plan plans/path/to/plan.md --diff diff.txt` (or equivalent command from `powerword` or `daedalus`).
  4. Collect the output review report.
  5. Post the review report directly to the PR thread using `actions/github-script` or standard comment Actions.
- [ ] The workflow runs as a **non-blocking check** so that a critical review does not block compilation/CI.

## Proposed Changes

### `.github/workflows/daedalus-plan-critic.yml`

- Define workflow with `pull_request` triggers and permissions setup.
- Add checkout and diff generation steps.
- Set up Go, install `daedalus`/`powerword`, and run review analysis.
- Post the review findings to the PR timeline.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| API token cost is high | Medium | Only run on PR lifecycle events rather than every commit. Allow bypassing the critic using a `skip-critic` label or `[skip critic]` in commit messages. |
| Inaccurate review comments (hallucinations) | Medium | Clearly label the review comments as "AI Assistant Critic Findings" and explicitly state that it is a advisory checklist, not a blocking constraint. |
| Large PRs exceed LLM context window | Low | Trim diffs (e.g., excluding vendor or generated lockfiles) before sending to the critic engine. |

## Verification Plan

### Manual Verification
- Open a test PR modifying a file in a repository with an active plan (e.g., `daedalus` or `aeolian`).
- Verify that a comment listing completed and missing tasks is posted to the PR.
- Add `[skip critic]` to a commit message and verify that the workflow skips execution.
