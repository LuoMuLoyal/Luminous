# Luminous TODO

Last updated: 2026-06-15

This file records work that is still missing or intentionally gated. Current facts belong in `Current_State.md`; implementation order belongs in `Next_Plan.md`.

## MVP Gaps To Close

- Medicine safety coverage is still intentionally narrow.
  Current state: Medicine now has a real current-medicine risk-check page, workspace safety cards from the same source-backed result, add-before-save precheck in search, explicit coverage-gap summaries for unchecked manual or source-missing items, bounded allergy matching, age-gated special-group warnings, and reviewed duplicate-ingredient checks for `cn` detail strings plus DrugBank synonym overlap. It still does not solve cross-source normalization or broader reviewed rule coverage.
  Needed outcome: broaden safety coverage deliberately without pretending certainty where source detail is missing.

- Fixed red-flag rules plus audited offline-care escalation copy are still missing.
  Current state: product vision already depends on bounded “seek offline help” prompts, but there is no finished MVP rule library + reviewed copy slice yet.
  Needed outcome: rule-based high-risk prompts and campus clinic / pharmacist / emergency resource guidance become real without turning AI into a medical triage engine.

## MVP Gated But Not Blocking Right Now

- Real report export files, print output, and share links.
- Worker-written reminder delivery history for local/push/SMS channels.
- Environment-driven Today or Mine suggestions.
- Real barcode / OCR / photo / prescription recognition flow.
- Voice or screenshot-based natural-language record intake.
- Cross-source medicine normalization and unreviewed interaction expansion.
- Privacy-preserving clinic summary / doctor-facing summary generation and preview flow.
- Real authenticated Web report preview beyond the competition/marketing homepage.

## Not MVP

- Women-health / period management.
- Sports recovery.
- Specialist health packs.
- Smart devices.
- Family profiles.
- Skin recognition.
- Desktop-first workflows.
