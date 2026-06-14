# Luminous TODO

Last updated: 2026-06-14

This file records work that is still missing or intentionally gated. Current facts belong in `Current_State.md`; implementation order belongs in `Next_Plan.md`.

## MVP Gaps To Close

- Medicine safety coverage is still intentionally narrow.
  Current state: Medicine now has a real current-medicine risk-check page, workspace safety cards from the same source-backed result, add-before-save precheck in search, and basic duplicate-ingredient detection for reviewed `cn` detail strings after simple ingredient splitting. It still does not solve cross-source normalization or broader reviewed rule coverage.
  Needed outcome: broaden safety coverage deliberately without pretending certainty where source detail is missing.

- Report export is still placeholder-only.
  Current state: Report cards for clinic/monthly/print still call local toast behavior even though Lucent already has data-export request endpoints and Mine/Settings can show export request status.
  Needed outcome: connect at least one real export request/start flow, or narrow the product promise/documentation so “export” is not presented as an active MVP action.

- NLP partial-save recovery is still toast-led.
  Current state: failed candidate rows now stay in place with item-level error text plus an explicit “retry failed items” entry in the sheet.
  Needed outcome: only revisit this if the flow still regresses during MVP testing, for example if failed rows need stronger draft recovery or per-item save controls.

## MVP Gated But Not Blocking Right Now

- Real report export files, print output, and share links.
- Worker-written reminder delivery history for local/push/SMS channels.
- Environment-driven Today or Mine suggestions.
- Real barcode / OCR / photo / prescription recognition flow.
- Voice or screenshot-based natural-language record intake.
- Cross-source medicine normalization and unreviewed interaction expansion.
- Fixed red-flag rule library plus audited safety copy for urgent offline-care escalation.
- Privacy-preserving clinic summary / doctor-facing summary generation and preview flow.

## Not MVP

- Women-health / period management.
- Sports recovery.
- Specialist health packs.
- Smart devices.
- Family profiles.
- Skin recognition.
- Desktop-first workflows.
