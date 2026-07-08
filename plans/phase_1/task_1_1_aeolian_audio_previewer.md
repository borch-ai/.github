# Plan: Task 1.1: Aeolian Audio-Visual Previewer

**Status:** Proposed
**Depends On:** None

Build a centralized, reusable workflow that automates audio-visual rendering and preview generation for pull requests modifying media or composition assets.

## User Review Required

> [!WARNING]
> Running audio synthesis (FluidSynth) and video encoding (ffmpeg) in GitHub Actions requires installing system-level dependencies (`fluidsynth`, `ffmpeg`) which can increase runner setup times.
>
> **Soundfonts:** FluidSynth requires a `.sf2` soundfont. A lightweight General MIDI soundfont (e.g., ~10-20MB) must be hosted or cached to keep workflow run times under 2 minutes.

## Acceptance Criteria

- [ ] Reusable workflow in `.github/workflows/aeolian-preview.yml`.
- [ ] Triggers on changes to `internal/audio/**`, `go.mod`, or paths matching `*.mid`, `*.midi`, or `*.sf2`.
- [ ] Workflow steps:
  1. Install system packages (`fluidsynth`, `ffmpeg`, `libasound2-dev`).
  2. Cache/download a lightweight `.sf2` soundfont if not bundled in the workspace.
  3. Compile the `aeolian` CLI from the branch.
  4. Execute rendering command: `aeolian compose --preview --duration 15` and `aeolian render --format mp4`.
  5. Upload the resulting preview MP3 and MP4 files as run artifacts.
- [ ] Posts a GitHub PR comment containing a link to the artifacts, basic composition metadata (chords, scale, tempo), and a generated ASCII waveform visualization.

## Proposed Changes

### `.github/workflows/aeolian-preview.yml`

- Define reusable workflow mapping input triggers and env parameters.
- Add steps for setup, package installation, compilation, rendering, and artifact upload.
- Integrate with PR comments via `actions/github-script` to write preview reports.

## Risk Assessment

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| FluidSynth installation fails on runner | Low | Rely on standard Ubuntu `apt-get` packages. |
| Large Soundfont files slow down checkout | Medium | Cache soundfonts using GitHub Actions cache or host a lightweight version on a public GCS bucket. |
| Video rendering times out | Low | Restrict preview duration to 15 seconds. |

## Verification Plan

### Manual Verification
- Trigger the workflow manually or via a PR in the `aeolian` repository.
- Verify that MP3 and MP4 files are successfully uploaded and playable.
- Inspect the PR comment for correct metadata rendering and layout.
