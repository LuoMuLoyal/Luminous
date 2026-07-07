# Luminous Roadmap

This document describes the planned evolution of the Luminous Flutter client.
It is a living document — directions shift as the product and community grow.

## Status

Luminous is currently at `0.1.0-dev`. The core mobile experience is functional
with all five tabs active, but the project has not yet shipped a stable release.

**What works today**

- Five-tab shell: Today / Record / Medicine / Report / Mine
- Authentication: credential login + WeChat OAuth (mobile SDK + desktop
  browser), Apple Sign-In, Security PIN
- Daily records: water, meal, vital, mood, symptom, activity, note, sleep —
  with quick-add, calendar navigation, and filtering
- Medicine: current medicines list, safety preview, dose logs, reminders with
  local notifications
- AI assistant: SSE streaming chat, proposed actions (create / update / delete
  records, update settings), conversation history, context source controls
- Reports: AI-driven summaries, trend visualization (fl_chart), data export
- Settings: theme (mode + family), locale, accessibility, notifications, data
  storage, AI context, security PIN, developer options (debug-only)
- Design system: Forui-based, full i18n (zh / en), shimmer skeletons,
  responsive layout (mobile + desktop sidebar)
- Infrastructure: Riverpod state management, GoRouter navigation, generated
  OpenAPI client, GitHub Actions CI, git hooks, daily/fullstack check scripts

**What's missing**

- Stable release (1.0.0) — still in dev phase
- Real medicine barcode / OCR / prescription recognition flow
- Push notification delivery (pending Lucent FCM/APNs)
- Web report preview beyond competition demo
- Release-mode error reporting / crash analytics
- Full desktop-first workflows

---

## Directions

### MVP Release → `1.0.0`

Ship the first stable mobile release.

- **Polish Pass** — unify visual hierarchy across all five tabs, eliminate
  overflow / truncation / black blocks, consistent loading / empty / error
  states
- **Safety Transparency** — Medicine risk check three-tier display (confirmed
  risk / confirmed safe / uncovered-uncertain), explicit coverage scope on
  pre-check sheet
- **Report Gating Clarity** — empty states explain why data is insufficient,
  show recording progress toward threshold
- **Reliability** — eliminate empty catch blocks, mock hardcoded dates, visible
  hardcoded strings, unstable route strings
- **Test Coverage** — raise widget test coverage for all critical user journeys,
  expand integration test scenarios
- **Release Gate** — `flutter analyze`, `flutter test`, `dart run
  tool/run_daily_checks.dart` all green; migration logs and current state docs
  synced; no post-MVP features advertised as current

### Post-MVP Polish → `1.1.0`

Harden the experience after stable release.

- **Error Reporting** — integrate crash analytics (Sentry or equivalent,
  China-friendly), structured error logging in release mode
- **Performance** — app size optimization, startup time profiling, image cache
  tuning, list virtualization audit
- **Accessibility** — full screen reader support, dynamic type scaling, touch
  target audit
- **Record Adherence** — weekly recording streak heatmap, density-aware AI
  summary gating, inline progress prompts
- **Clinic Summary** — structured doctor/pharmacist handoff export with
  field-level privacy redaction (PDF + plain text)
- **Symptom-Medicine Timeline** — cross-type correlation view in Record,
  clickable AI summary evidence expansion
- **Quick-Entry Widget** — Android home screen + iOS Lock Screen widgets for
  one-tap water logging and medication status
- **Offline** — local-first record editing with sync-on-reconnect, conflict
  resolution UX

### Feature Expansion → `1.2.0`

Extend product capabilities on a stable foundation.

- **Medicine Scan** — real barcode recognition, OCR for drug labels, prescription
  photo parsing (requires Lucent contract)
- **Report Drill-down** — period-over-period comparison, monthly / quarterly
  reports, CSV / image export
- **Environment-Aware Suggestions** — weather-linked health tips, seasonal
  medication reminders (requires Lucent environment module)
- **GenUI (Experimental)** — LLM-driven dynamic UI rendering, expanding
  `proposedActions` into an open component schema (behind `genUiEnabled` feature
  flag)
- **Assistant Enhancements** — conversation rename / delete / search, enhanced
  memory controls, new tool capabilities
- **Embedded Assistant** — inline AI entry points in Today / Medicine / Report
  instead of standalone-only access
- **Red-Flag Rules** — fixed rule table for high-risk symptom patterns (fever,
  allergic reaction, breathing difficulty) with static safety copy
- **Smart Reminder Priority** — context-aware reminder scheduling based on
  recording patterns and confirmation latency (requires Lucent rule extension)
- **Health Bridge** — Apple Health / Health Connect read-only integration for
  steps, sleep, water (reduces manual entry friction)

### Scale & Platform → `2.0.0`

Broaden platform reach and prepare for larger scale.

- **Desktop** — full desktop-first navigation, window management, keyboard
  shortcuts
- **Web** — progressive web app, shareable report preview (beyond demo)
- **Family Profiles** — multi-user household management, dependent care
- **Wearable** — Wear OS / watchOS companion for quick logging
- **Internationalization** — additional locales, timezone-aware scheduling,
  region-specific health guidelines

---

## Versioning

| Version  | Theme                | Status      |
| -------- | -------------------- | ----------- |
| `0.1.0-dev` | Initial development  | In progress |
| `1.0.0`     | MVP release          | Planned     |
| `1.1.0`     | Post-MVP polish      | Planned     |
| `1.2.0`     | Feature expansion    | Planned     |
| `2.0.0`     | Scale & platform     | Planned     |

Releases follow [Semantic Versioning](https://semver.org/). Each release passes
the full `flutter analyze` + `flutter test` + `dart run tool/run_daily_checks.dart`
gate before publish.

Detailed feature brainstorm and adjustment rationale: see
[docs/01-product/Product_Brainstorm_2026-07-07.md](docs/01-product/Product_Brainstorm_2026-07-07.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for
development setup, code conventions, and documentation rules.

## Feedback

This roadmap is open to discussion. Open an issue with the `roadmap` label to
propose changes, suggest priorities, or flag missing items.
