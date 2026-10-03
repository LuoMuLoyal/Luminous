# Changelog

All notable changes to Luminous are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project
adheres to [Semantic Versioning](https://semver.org/).

Detailed daily migration logs live in `docs/logs/migration-log/`. This file is a release-level
summary. Older entries are archived under `docs/archive/<YYYY-MM>/`, one folder per month, with
file names unchanged.

---

## [Unreleased]

### Added

- Developer options: API endpoint switching (local / staging / production / custom), log level
  control (verbose / info / warning / error / none), and a feature flags page (on-device AI
  runtime, GenUI, streaming mode, barcode scan, PDF export). Debug-only and gated behind
  `kDebugMode`.
- Talker logging: `talker_flutter` is the unified logging framework, replacing the `AppLogger`
  static wrapper. Runtime level filtering through `applyLogLevelToTalker()`.
- Feature flags: `FeatureFlagsController` with SharedPreferences persistence, seeded from
  compile-time environment variables on first launch.
- Open-source docs: ROADMAP.md, CHANGELOG.md, an expanded CONTRIBUTING.md, CODE_OF_CONDUCT.md,
  SECURITY.md, THIRD_PARTY_NOTICES.md, CODEOWNERS, dependabot.yml, and GitHub Issue / PR
  templates.

### Changed

- `lucentBaseUrlProvider` now responds to `developerSettingsControllerProvider` in debug mode, so
  the endpoint can be switched at runtime with an automatic Dio client rebuild.
- `aiRuntimeEnabled` was renamed to `onDeviceAiRuntime` in `FeatureFlagsState` to distinguish it
  from the Lucent backend LLM configuration.

---

## [0.1.0-dev] - 2026-07-04

First development milestone after the full project reset and the Forui migration. The project has
not shipped a stable release. Per [Semantic Versioning](https://semver.org/), major version zero
(`0.y.z`) is for initial development, and the public API should not be considered stable.

### Added

- Five-tab shell: Today / Record / Medicine / Review / Mine, with a responsive layout (mobile
  bottom nav and desktop sidebar).
- Authentication: credential login and registration, WeChat OAuth (mobile SDK via fluwx, desktop
  browser callback, web callback), Apple Sign-In, password reset, and Security PIN with biometric
  elevation.
- Daily records: water / meal / vital / mood / symptom / activity / note / sleep entry types,
  quick-add dialogs, voice entry (speech_to_text), OCR entry (google_mlkit_text_recognition),
  calendar timeline, and a mobile filter sheet.
- Medicine: current medicines workspace, safety preview, dose logs, reminders with local
  notifications, medicine search, and risk check.
- AI assistant: SSE streaming chat, proposed actions (create / update / delete daily records,
  update user settings), conversation history with a drawer, context source controls (health
  profile, daily records, sleep, current medicines), memory toggle, and tool capability display.
- Reports: AI-driven summaries, trend visualization (fl_chart line / bar / pie charts), and data
  export with status tracking.
- Settings: theme (mode and family), language (zh / en / system), accessibility (font size, reduce
  animations, high contrast), notifications (reminder advance, sleep reminder, DND), data storage
  (retention, image quality, sync preference), AI settings (summaries, assistant, memory, context
  sources), security PIN, data export, help, about, and advanced (cache clear, reset defaults,
  licenses).
- Design system: Forui 0.23 migration (full replacement of Material Design), design tokens (colour
  / type / spacing / radius / breakpoints / animation), shimmer skeletons, `AppStateErrorView`,
  and `AppToast` feedback.
- Infrastructure: Riverpod 3 state management, GoRouter 17 navigation, a generated OpenAPI client
  (`generated/lucent_api`), `EnvReader` for compile-time environment variables, `LucentDioClient`
  with session management and locale injection, and an SSE client for streaming.
- i18n: full zh / en ARB localization through `flutter gen-l10n`.
- CI/CD: GitHub Actions (analyze, format, test, OpenAPI sync verification, APK build), git hooks
  (pre-commit: gen-l10n + format + analyze; pre-push: daily checks), a daily check script, a
  full-stack E2E script, and a doc-coverage check.
- Testing: unit and widget tests plus integration tests (auth, record, medicine, mine, settings,
  support) and full-stack E2E lanes.

### Migration history

- Forui migration from Material Design (2026-06-28 → 2026-07-03)
- Riverpod 3 upgrade
- GoRouter 17 upgrade
- OpenAPI client regeneration pipeline
- Documentation restructure (Obsidian vault structure)
- Three rounds of code review and audit remediation (2026-07-05 → 2026-07-07)

---

## Versioning

| Version     | Status      | Notes                                         |
| ----------- | ----------- | --------------------------------------------- |
| `0.1.0-dev` | Development | Forui migration, five-tab shell, AI assistant |
| `1.0.0`     | Planned     | First stable mobile release                   |
| `1.1.0`     | Planned     | P2 polish, crash analytics, performance       |
| `1.2.0`     | Planned     | Medicine scan, GenUI, report drill-down       |
| `2.0.0`     | Planned     | Desktop, web, family profiles, wearable       |

See [ROADMAP.md](ROADMAP.md) for the full roadmap.
