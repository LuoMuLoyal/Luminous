# Luminous TODO

Last updated: 2026-06-14

This file records work that is still missing or intentionally gated. Current facts belong in `Current_State.md`; implementation order belongs in `Next_Plan.md`.

## MVP Gaps To Close

- Real new-medicine safety check flow is not delivered yet.
  Current state: Medicine has reminder CRUD, dose logs, special-group safety context, and safety-themed cards, but the prominent risk-check entry still resolves to toast-only placeholder behavior and the workspace alerts are still local default cards instead of user-specific rule results.
  Needed outcome: adding or reviewing a medicine should surface source-backed checks against current medicines, allergies, and explicit known rules, with clear uncertainty when data is insufficient.

- Report export is still placeholder-only.
  Current state: Report cards for clinic/monthly/print still call local toast behavior even though Lucent already has data-export request endpoints and Mine/Settings can show export request status.
  Needed outcome: connect at least one real export request/start flow, or narrow the product promise/documentation so “export” is not presented as an active MVP action.

- Campus service entries are fetched from contract-backed support resources, but they are not actionable in the app yet.
  Current state: Mine renders real campus/support/pharmacy/emergency rows from `GET /api/v1/public/support-resources?scope=campus`, but tapping those rows still shows toast-only placeholder behavior.
  Needed outcome: open supported external/internal actions when the resource includes a usable action target, and keep only unsupported resource types as non-actionable.

- NLP partial-save recovery is still toast-led.
  Current state: failed candidate rows stay in place with item-level error text, which is enough for now, but there is no stronger retry/review affordance yet.
  Needed outcome: only revisit this if the flow starts regressing or blocks usability during MVP testing.

## MVP Gated But Not Blocking Right Now

- Real report export files, print output, and share links.
- Worker-written reminder delivery history for local/push/SMS channels.
- Environment-driven Today or Mine suggestions.
- Real barcode / OCR / photo / prescription recognition flow.
- Voice or screenshot-based natural-language record intake.
- Cross-source medicine normalization, duplicate ingredient detection, and unreviewed interaction expansion.
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
