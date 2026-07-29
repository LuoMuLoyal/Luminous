# Luminous Roadmap

This document describes the planned evolution of the Luminous Flutter client.
It is a living document — directions shift as the product and community grow.

## Status

Luminous is currently at `0.1.0-dev`. The core mobile experience is functional
with all five tabs active, but the project has not yet shipped a stable release.

**What works today**

- Five-tab shell: Today / Record / Medicine / Report / Mine
- Authentication: credential login + WeChat OAuth (mobile SDK + desktop
  browser), Apple Sign-In, QQ OAuth, Security PIN, OAuth-only account deletion
  via email verification code
- Daily records: water, meal, vital, mood, symptom, activity, note, sleep —
  with quick-add, calendar navigation, and filtering
- Medicine: current medicines list, safety preview with three-tier risk
  display (confirmed risk / confirmed safe / uncovered-uncertain), dose logs,
  reminders with local notifications
- AI assistant: SSE streaming chat, proposed actions (create / update / delete
  records, update settings), conversation history, context source controls,
  Markdown rendering for AI-generated text
- Reports: AI-driven summaries, trend visualization (fl_chart), data export,
  suggestion history (lifecycle-aware: active / expired / dismissed)
- Settings: theme (mode + family), locale, accessibility, notifications, data
  storage, AI context, security PIN, developer options (debug-only)
- Design system: Forui-based, full i18n (zh / en) with ARB fragment splitting,
  shimmer skeletons, responsive layout (mobile + desktop sidebar), semantic
  color system
- Infrastructure: Riverpod state management (with `@riverpod` code generation),
  GoRouter navigation (with `go_router_builder` type-safe routes), generated
  OpenAPI client, GitHub Actions CI, git hooks, daily/fullstack check scripts
- Offline support: Drift local database with cache-first repositories,
  SyncWorker with exponential backoff, pending sync queue, data retention
  cleanup, Web platform (WASM SQLite) support
- Error reporting: Sentry integration with Talker bridge, `runZonedGuarded`
  + `FlutterError.onError` crash capture
- Testing: 2294 unit/widget tests, Patrol-based integration tests, golden
  tests (CI-skipped), doc coverage gate
- Legal compliance: in-app legal document browser (terms / privacy /
  disclaimer / minor-protection / sdk-list / permissions / account-cancellation)
  with remote-first + assets fallback

**What's missing**

- Stable release — still in dev phase
- Real medicine barcode / OCR / prescription recognition flow
- Push notification delivery (pending Lucent FCM/APNs)
- Web report preview beyond competition demo
- Full desktop-first workflows

---

## Directions

Priority framework follows
[Product Brainstorm 2026-07-07](docs/01-product/Product_Brainstorm_2026-07-07.md).

### P0 + P1 → `1.0.0`

Ship the first stable mobile release. P0 items are complete; P1 items are in
progress.

- **P0 ✅ Safety Transparency** — Medicine risk check three-tier display
  (confirmed risk / confirmed safe / uncovered-uncertain), explicit coverage
  scope on pre-check sheet
- **P0 ✅ Report Gating Clarity** — empty states explain why data is
  insufficient, show recording progress toward threshold
- **P1 — Today Information Density** — narrow to 3 zones: top suggestion/reminder
  → AI daily summary (collapsed) → quick actions; move priority items to Record
- **P1 — Record Quick Entry Dynamic Sort** — sort by usage frequency, show top 3
  first, collapse rest; NLP entry as first priority; new users see only
  water/symptom/sleep
- **P1 — Mine Profile Completeness** — health profile shows completeness hint;
  empty allergies or current medicines → remind user (affects safety check
  coverage)
- **Release Gate** — `flutter analyze`, `flutter test`, `dart run
  scripts/run_daily_checks.dart` all green; migration logs and current state docs
  synced; no P2/P3 features advertised as current

### P2 → `1.1.0`

Harden the experience and add high-value features on the stable foundation.

- **Clinic Summary Template** — structured doctor/pharmacist handoff export
  with field-level privacy redaction (PDF + plain text)
- **Symptom-Medicine Timeline** — cross-type correlation view in Record,
  clickable AI summary evidence expansion
- **Record Adherence** — weekly recording streak heatmap, density-aware AI
  summary gating, inline progress prompts

### P3 → `1.2.0+`

Extend product capabilities.

- **Red-Flag Rules** — fixed rule table for high-risk symptom patterns (fever,
  allergic reaction, breathing difficulty) with static safety copy
- **Smart Reminder Priority** — context-aware reminder scheduling based on
  recording patterns and confirmation latency (requires Lucent rule extension)
- **Health Bridge** — Apple Health / Health Connect read-only integration for
  steps, sleep, water (reduces manual entry friction)
- **Quick-Entry Widget** — Android home screen + iOS Lock Screen widgets for
  one-tap water logging and medication status
- **Embedded Assistant** — inline AI entry points in Today / Medicine / Report
  instead of standalone-only access

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
| `1.0.0`     | P0 + P1 stable release | Planned     |
| `1.1.0`     | P2 feature polish    | Planned     |
| `1.2.0`     | P3 feature expansion | Planned     |
| `2.0.0`     | Scale & platform     | Planned     |

Releases follow [Semantic Versioning](https://semver.org/). Each release passes
the full `flutter analyze` + `flutter test` + `dart run scripts/run_daily_checks.dart`
gate before publish.

Detailed feature brainstorm and adjustment rationale: see
[docs/01-product/Product_Brainstorm_2026-07-07.md](docs/01-product/Product_Brainstorm_2026-07-07.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and [AGENTS.md](AGENTS.md) for
development setup, code conventions, and documentation rules.

## Feedback

This roadmap is open to discussion. Open an issue with the `roadmap` label to
propose changes, suggest priorities, or flag missing items.
