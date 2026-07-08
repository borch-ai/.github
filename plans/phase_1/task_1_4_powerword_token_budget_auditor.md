# Plan: Task 1.4: Powerword Token & PR Development Cost Auditor

**Status:** Proposed
**Depends On:** None

Build a lightweight workflow that parses agent telemetry logs from pull requests, checks the financial budget consumed during the generation of the codebase changes, and posts a summary directly to the PR comments.

## User Review Required

> [!NOTE]
> This workflow depends on agent telemetry being committed in a structured format (e.g., `.agents/telemetry.json` or `telemetry.log`) during development or generation. If no telemetry is generated, the auditor will fail gracefully with an informational note.

## Acceptance Criteria

- [ ] Reusable workflow in `.github/workflows/powerword-budget-auditor.yml`.
- [ ] Triggers on `pull_request` event.
- [ ] Workflow steps:
  1. Check out the branch.
  2. Locate the telemetry log (e.g., look for `.agents/telemetry.json`).
  3. Compile and execute `powerword audit --file .agents/telemetry.json` (or extract the token fields via jq).
  4. Compare computed costs against the configured limit (e.g., $2.00 per task).
  5. Post a table on the PR summarizing: Input/Output tokens, Model used, total cost, and a status indicator (e.g., `✅ Within Budget` or `⚠️ Budget Exceeded`).
- [ ] Does not fail the build if budget is exceeded, unless strict mode is enabled.

## Proposed Changes

### `.github/workflows/powerword-budget-auditor.yml`

- Define workflow with PR triggers.
- Add checkout, Go setup, and dependencies logic.
- Locate and parse telemetry JSON structures.
- Generate and post the Markdown summary table to the PR comment thread.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Telemetry file is missing | High | The script will check if the file exists; if not, it exits with status 0 and logs: "No telemetry file found in branch. Skipping budget audit." |
| Incorrect model pricing | Low | Store model pricing metadata inside the `powerword` utility to keep the calculation engine centralized and easy to update. |

## Verification Plan

### Manual Verification
- Commit a mock `.agents/telemetry.json` in a PR containing typical token usage figures.
- Verify that the workflow correctly parses the JSON and posts the matching cost breakdown table.
- Verify that omitting the telemetry file does not fail the action execution.
