# Plan: Task 1.5: Ephemeral Fake Door Deployer

**Status:** Proposed
**Depends On:** None

Build a centralized workflow to automate the deployment, hosting, and SEO/Performance validation of fake-door landing pages used by Kiln for market validation.

## User Review Required

> [!IMPORTANT]
> **Deployment Target:** This workflow will build static HTML pages and deploy them to a hosting provider. We suggest using **GitHub Pages** (specifically deploying to a subdirectory inside the `gh-pages` branch) or **Cloudflare Pages** for zero-cost, serverless static previews.
>
> **Lighthouse Runner:** Performing Lighthouse audits requires a headless Chromium instance to run on the GitHub runner, which is standard on `ubuntu-latest` but adds dependency layers.

## Acceptance Criteria

- [ ] Reusable workflow in `.github/workflows/fake-door-deployer.yml`.
- [ ] Triggers on changes to `web/` or fake door assets, and on manual `workflow_dispatch` with a `page_id` input parameter.
- [ ] Workflow steps:
  1. Build the static landing page assets.
  2. Deploy to a temporary preview path (e.g., `https://<org>.github.io/<repo>/preview/<pr-number>/`).
  3. Wait for the endpoint to return a `200 OK` (health check loop with maximum 30-second timeout).
  4. Execute a Google Lighthouse audit against the preview URL.
  5. Format the Lighthouse metrics (Performance, Accessibility, Best Practices, SEO) into a markdown report.
  6. Comment the preview link and the Lighthouse score badges on the PR or parent issue.

## Proposed Changes

### `.github/workflows/fake-door-deployer.yml`

- Define workflow triggers and inputs.
- Add step to package static HTML/CSS/JS files.
- Deploy to pages/static bucket environment.
- Run `treosh/lighthouse-github-action` or a customized Lighthouse scan.
- Post summary results directly to the PR or issue timeline.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Staging site doesn't load fast enough for Lighthouse | Medium | Implement an active polling step using `curl` that waits up to 30 seconds for the URL to be ready before launching the Lighthouse container. |
| Overwriting production site | High | Enforce strict isolation: always deploy preview builds to a nested path containing the PR number or Git SHA, separating it from the root production deployment. |

## Verification Plan

### Manual Verification
- Manually launch the workflow using a sample fake-door page ID.
- Check that the page deploys correctly to the preview URL.
- Verify that the Lighthouse report generates correctly and the summary comment contains the score badges.
