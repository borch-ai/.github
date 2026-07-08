# Plan: Task 1.2: Kiln Market Scout & Automated Niche Dashboard

**Status:** Proposed
**Depends On:** None

Build a scheduled workflow that automatically performs market trend analysis via Kiln and updates a central repository dashboard or organization profile README with current niche scores.

## User Review Required

> [!IMPORTANT]
> **API Secrets:** Running `kiln scout` requires API keys or access tokens to interface with external data providers (e.g., Reddit API, search trend providers). These secrets must be securely configured in the repository settings (e.g., `MARKET_INTEL_SECRETS`).
>
> **Git Push Permissions:** The workflow will need write permissions on `contents: write` to commit updated reports directly back to the repo.

## Acceptance Criteria

- [ ] Reusable workflow in `.github/workflows/kiln-scout-dashboard.yml`.
- [ ] Configured with both `schedule` (cron: `0 0 * * *` - daily at midnight) and `workflow_dispatch` (manual) triggers.
- [ ] Workflow steps:
  1. Set up Go environment and cache build objects.
  2. Install `kiln` CLI.
  3. Run `kiln scout --limit 10 --format markdown --output profile/README.md`.
  4. Use a markdown parsing step to locate an injection marker in `profile/README.md` (e.g., `<!-- KILN_SCOUT_START -->` ... `<!-- KILN_SCOUT_END -->`) and overwrite only that block with the new table.
  5. Commit and push the updated `profile/README.md` back to the repository using a bot account (`github-actions[bot]`).

## Proposed Changes

### `.github/workflows/kiln-scout-dashboard.yml`

- Define workflow structure with scheduler triggers.
- Add Go checkout, install, and execute logic for `kiln scout`.
- Add script step to inject the compiled results into [profile/README.md](file:///Users/human/code/.github/profile/README.md).
- Implement git config and push steps to save changes back to `main`.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| API rate limits or downtime from external platforms | Medium | Handle API failures gracefully in `kiln` so the scan logs the error and keeps previous data rather than breaking the build. |
| Commit churn pollutes git history | Low | Use standard squashed history or write to a dedicated branch/Pages site instead of polluting `main`. |
| Secrets leakage | Low | Ensure the command runs locally and stores outputs before writing to files; do not print raw logs of the API calls. |

## Verification Plan

### Manual Verification
- Manually run the workflow via the GitHub Actions UI (`workflow_dispatch`).
- Check `profile/README.md` to confirm the trends table was correctly injected and committed.
- Verify no secrets or sensitive request parameters were leaked in the console output.
