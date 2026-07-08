# Changelog

All notable changes to Luminous are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

Detailed daily migration logs live in `docs/03-logs/migration-log/`. This file
provides a release-level summary. Pre-2026-07 entries are archived under
`docs/04-archive/migration-log/`.

---

## [Unreleased]

### Added

- **Developer Options** — API endpoint switching (local / staging / production /
  custom), log level control (verbose / info / warning / error / none), feature
  flags page (on-device AI runtime, GenUI, streaming mode, barcode scan, PDF
  export). Debug-only, `kDebugMode` gated.
- **Talker logging** — `talker_flutter` integrated as the unified logging
  framework, replacing the `AppLogger` static wrapper. Runtime level filtering
  via `applyLogLevelToTalker()`.
- **Feature Flags system** — `FeatureFlagsController` with SharedPreferences
  persistence, seeded from compile-time env variables on first launch.
- **Open-source docs** — ROADMAP.md, CHANGELOG.md, CONTRIBUTING.md (expanded),
  CODE_OF_CONDUCT.md, GitHub Issue / PR templates.

### Changed

- `lucentBaseUrlProvider` now responds to `developerSettingsControllerProvider`
  in debug mode, enabling runtime endpoint switching with automatic Dio client
  rebuild.
- `aiRuntimeEnabled` renamed to `onDeviceAiRuntime` in FeatureFlagsState to
  distinguish from Lucent backend LLM configuration.

---

## [0.1.0-dev] — 2026-07-04

First development milestone after full project reset and Forui migration.
This is the initial development cycle — the project has not yet shipped a
stable release. Per [Semantic Versioning](https://semver.org/), major version
zero (0.y.z) is for initial development; the public API SHOULD NOT be
considered stable.

### Added

- **Five-tab shell** — Today / Record / Medicine / Report / Mine with
  responsive layout (mobile bottom nav + desktop sidebar).
- **Authentication** — credential login + registration, WeChat OAuth (mobile
  SDK via fluwx, desktop browser callback, web callback), Apple Sign-In,
  password reset, Security PIN with biometric elevation.
- **Daily records** — water / meal / vital / mood / symptom / activity / note
  / sleep entry types, quick-add dialogs, voice entry (speech_to_text), OCR
  entry (google_mlkit_text_recognition), calendar timeline, mobile filter sheet.
- **Medicine** — current medicines workspace, safety preview, dose logs,
  reminders with local notifications, medicine search, risk check.
- **AI Assistant** — SSE streaming chat, proposed actions (create / update /
  delete daily records, update user settings), conversation history with
  drawer, context source controls (health profile, daily records, sleep,
  current medicines), memory toggle, tool capability display.
- **Reports** — AI-driven summaries, trend visualization (fl_chart line / bar
  / pie charts), data export with status tracking.
- **Settings** — theme (mode + family), language (zh / en / system),
  accessibility (font size, reduce animations, high contrast), notifications
  (reminder advance, sleep reminder, DND), data storage (retention, image
  quality, sync preference), AI settings (summaries, assistant, memory,
  context sources), security PIN, data export, help, about, advanced (cache
  clear, reset defaults, licenses).
- **Design system** — Forui 0.23 migration (full replacement of Material
  Design), design tokens (color / type / spacing / radius / breakpoints /
  animation), shimmer skeletons, AppStateErrorView, AppToast feedback.
- **Infrastructure** — Riverpod 3 state management, GoRouter 17 navigation,
  generated OpenAPI client (`generated/lucent_api`), `EnvReader` for
  compile-time env variables, `LucentDioClient` with session management and
  locale injection, SSE client for streaming.
- **i18n** — full zh / en ARB localization via `flutter gen-l10n`, 800+ strings.
- **CI/CD** — GitHub Actions (analyze, format, test, OpenAPI sync verification,
  APK build), git hooks (pre-commit: gen-l10n + format + analyze; pre-push:
  daily checks), daily check script, fullstack E2E script, doc coverage check.
- **Testing** — 898 unit/widget tests, integration tests (auth, record,
  medicine, mine, settings, support), fullstack E2E lanes.

### Migration history

- Forui migration from Material Design (2026-06-28 → 2026-07-03)
- Riverpod 3 upgrade
- GoRouter 17 upgrade
- OpenAPI client regeneration pipeline
- Documentation restructure (Obsidian vault structure)
- Three rounds of code review and audit remediation (2026-07-05 → 2026-07-07)

---

## Versioning

| Version       | Status      | Notes                                      |
| ------------- | ----------- | ------------------------------------------ |
| `0.1.0-dev`   | Development | Forui migration, five-tab MVP, AI assistant |
| `1.0.0`       | Planned     | First stable mobile release                |
| `1.1.0`       | Planned     | Post-MVP polish, crash analytics, perf     |
| `1.2.0`       | Planned     | Medicine scan, GenUI, report drill-down    |
| `2.0.0`       | Planned     | Desktop, web, family profiles, wearable    |

See [ROADMAP.md](ROADMAP.md) for the full roadmap.
