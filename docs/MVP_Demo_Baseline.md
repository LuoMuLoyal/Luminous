# Luminous MVP Demo Baseline

Last updated: 2026-06-17

This document defines the repeatable demo baseline for the current shipped MVP.
It is not a product-scope document. Use `Product_Vision.md` for scope and
`MVP_Demo_Script.md` for the live walkthrough.

## Goal

Make the deployed MVP demo repeatable without ad-hoc memory or last-minute
debugging.

The baseline covers three things:

1. which backend/runtime checks must pass before demo
2. which mobile flow must be rehearsed
3. what the demo account/data should look like

## Real MVP Path

```text
record -> summarize -> bounded medicine safety check -> export
```

## Demo Account Baseline

Use one dedicated demo account. Do not use your personal account during defense
or rehearsals.

Recommended baseline:

- one stable email/password account
- AI summaries enabled
- at least one current medicine already present
- at least one visible allergy or health-profile fact when needed for safety explanation
- enough recent records to make Today and Report non-empty

## Demo Data Baseline

Before a formal demo, the account should already satisfy:

- sign-in succeeds without password reset or email verification detours
- Today has enough data to generate one bounded AI summary
- Medicine has enough data to show:
  - current medicine list
  - one real safety-check path
  - one explicit coverage/unknown boundary if needed
- Report has enough recent records to show:
  - real dashboard cards
  - one AI summary generation path
  - one successful PDF export request

## What To Reset Manually

Current recommendation: keep demo reset as an operator routine, not an exposed
production API.

Reset or verify these before demo:

- old export requests that would make the latest status look confusing
- stale or accidental records that break the rehearsed storyline
- medicines/reminders that no longer match the walkthrough
- signed-in sessions on test devices if login state becomes confusing

## Pre-Demo Validation Order

1. Backend deploy smoke:
   - follow `../Lucent/docs/deployment.md`
   - run `pnpm deploy:smoke` on the server-side app directory with the required env vars
2. Frontend repo-safe checks:
   - `dart run tool/run_daily_checks.dart`
3. Full-stack local lane:
   - `dart run tool/run_fullstack_checks.dart`
4. Manual device rehearsal:
   - follow `MVP_Demo_Script.md` once from login to export

## Must Pass Before Demo

- deployed Lucent returns `200` on `/api/v1/health/ready`
- mobile app can sign in with the demo account
- Record can create at least one simple entry
- Today can generate a bounded summary
- Medicine can open risk check and show real rule-backed output
- Report can request at least one PDF export successfully

## Do Not Rely On During Demo

- manual oral explanation to cover a broken state
- deferred OCR, voice, screenshot, map lookup, or agent discovery
- campus resource completeness for every school
- unchecked medicine coverage being interpreted as safe

## Related Docs

- `MVP_Demo_Script.md`
- `Current_State.md`
- `Next_Plan.md`
- `../Lucent/docs/deployment.md`
