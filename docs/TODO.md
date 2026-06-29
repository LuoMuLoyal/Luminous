# Luminous TODO

Last updated: 2026-06-29

This file records work that is still missing or intentionally gated. Current facts belong in `Current_State.md`; implementation order belongs in `Next_Plan.md`.

## 延后（有明确原因）

- `ReportPanel` / `MedicinePanel` 默认 padding (md→lg) — 布局溢出，当前默认与 `AppLayoutTokens.cardPadding` 一致
- `formz` 表单校验 — 新增依赖，当前 AppToast 校验模式工作正常
- `intl.DateFormat` 替代 ISO 字符串 — padLeft 是线协议格式，DateFormat 不适用

## Not MVP

- Women-health / period management.
- Sports recovery.
- Specialist health packs.
- Smart devices.
- Family profiles.
- Skin recognition.
- Desktop-first workflows.

## MVP Gaps To Close

- No blocker is currently left on the frozen mobile MVP promise.
  Current state: The mobile MVP path is now defined as `record -> summarize -> bounded medicine safety check -> export`, with explicit uncertainty for unchecked medicines and no claim of broad cross-source normalization or unreviewed interaction expansion.
  Remaining work below belongs to post-MVP productization or hardening, not to MVP completion.

## MVP Gated But Not Blocking Right Now

- Lightweight assistant with user-controlled context permissions, bounded tool use, and streaming markdown output.
- Additional reviewed medicine rule expansion beyond the frozen current boundary.
- Cross-source medicine normalization and unreviewed interaction expansion.
- Fixed red-flag rules, audited offline-care escalation copy, and campus/help resource completeness.
- Agent-assisted support discovery or map-backed nearby-care lookup.
- Deeper medicine safety rule coverage and clearer unsupported / low-confidence wording beyond the frozen current boundary.
- Report/export finish-pass cleanup in the client only: final status wording consistency, expired-link handling, and one real-environment acceptance run. Do not reopen backend/export scope unless a real bug is found.
- Worker-written reminder delivery history for local/push/SMS channels.
- Environment-driven Today or Mine suggestions.
- Real barcode / OCR / photo / prescription recognition flow.
- Voice or screenshot-based natural-language record intake.
- Privacy-preserving clinic summary / doctor-facing summary generation and preview flow.
- Real authenticated Web report preview beyond the competition/marketing homepage.
