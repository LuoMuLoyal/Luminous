# Luminous TODO

Last updated: 2026-06-15

This file records work that is still missing or intentionally gated. Current facts belong in `Current_State.md`; implementation order belongs in `Next_Plan.md`.

## MVP Gaps To Close

- Medicine safety coverage is still intentionally narrow.
  Current state: Medicine now has a real current-medicine risk-check page, workspace safety cards from the same source-backed result, add-before-save precheck in search, and basic duplicate-ingredient detection for reviewed `cn` detail strings after simple ingredient splitting. It still does not solve cross-source normalization or broader reviewed rule coverage.
  Needed outcome: broaden safety coverage deliberately without pretending certainty where source detail is missing.

- Report export is still only partially real.
  Current state: `给校医院` now uses the real Lucent export request flow for `hospital + pdf + last_7_days`. `月度报告` and `打印预览` remain visible but inactive until Lucent has distinct payloads/files for them.
  Needed outcome: either add real monthly/print export contracts, or keep the current narrowed export promise explicit in product copy and docs.

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
