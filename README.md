# Luminous

[![Backend: Lucent](https://img.shields.io/badge/backend-LuoMuLoyal%2FLucent-2563eb?logo=github)](https://github.com/LuoMuLoyal/Lucent)

Flutter 主动式个人健康助手。以用药安全和短期健康事件为入口，在记录稀疏时仍提供有证据的主动建议与事件回顾。

Current version: **0.1.0-dev**

## Community

- [Roadmap](ROADMAP.md) — planned evolution and version milestones
- [Changelog](CHANGELOG.md) — release-level change history
- [Contributing](CONTRIBUTING.md) — development setup, conventions, and PR process
- [Code of Conduct](.github/CODE_OF_CONDUCT.md) — community standards
- [Security Policy](SECURITY.md) — vulnerability reporting
- [Product language](CONTEXT.md) — canonical health-event, sparse-record, guidance, and review terms
- [Issues](https://github.com/LuoMuLoyal/Luminous/issues) — bug reports and feature requests

## AI Workflow

- Repo AI-development reference: `docs/explanation/AI_Development_Workflow.md`
- Editor-assistant entry: `.github/copilot-instructions.md`
- Agent entries: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`
- MCP entry for compatible clients: `.cursor/mcp.json`
- VS Code project setting enables the Dart/Flutter MCP server: `.vscode/settings.json`
- Experimental app-side AI runtime seam lives in `lib/core/ai/` and is kept
  separate from Lucent-backed production assistant/report flows.
- Runtime seam flags are documented in `docs/explanation/AI_Development_Workflow.md`

## Baseline

- Tabs: `today / record / medicine / review / mine`
- Design tokens: color / type / spacing / radius / breakpoints / animation
- UI framework: [Forui](https://forui.dev)（2026-07 从 Material Design 全量迁移）
- API client: `generated/lucent_api`
- Network layer: `lib/core/network/`
- i18n: Flutter `gen-l10n` — ARB fragments live in `lib/l10n/src/`; main `app_zh.arb` / `app_en.arb` are **generated** via `dart scripts/arb_tools.dart merge` — never edit them directly.
- WeChat OAuth: Android/iOS uses the WeChat SDK through `fluwx` to obtain an auth code and then calls Lucent's mobile callback endpoint. Desktop login starts a loopback callback listener, asks Lucent for an authorize URL with that callback URI, opens the system browser, verifies the returned `state`, and completes login automatically when Lucent redirects back with `code` and `state`. Web login passes `/login/oauth/wechat` as the callback path. Manual callback paste remains as a fallback.

Mobile WeChat SDK builds need:

- Dart define `WECHAT_MOBILE_APP_ID=<wx app id>`
- iOS Dart define `WECHAT_IOS_UNIVERSAL_LINK=<universal link>` when applicable
- iOS native URL Scheme build setting: copy `ios/Flutter/Wechat.example.xcconfig` to `ios/Flutter/Wechat.xcconfig` and set the same `WECHAT_MOBILE_APP_ID`
- Matching Android signature/package and iOS URL Scheme/Universal Link setup in the WeChat Open Platform console and native projects. iOS Universal Link still requires real Associated Domains configuration in the Apple developer account and release signing setup.

Mobile JPush builds need:

- Dart define `--dart-define=JPUSH_APP_KEY=<appkey>` for Android/iOS builds (read via `String.fromEnvironment` in `lib/core/push/jpush_gateway.dart`); without it JPush stays silently disabled.
- Android native side additionally needs the gradle property `-PJPUSH_APP_KEY=<appkey>` (or `JPUSH_APP_KEY` environment variable) so `android/app/build.gradle.kts` can fill the `JPUSH_APPKEY` / `JPUSH_CHANNEL` manifest placeholders. Never write a real AppKey into the repo — inject at build time.

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
flutter test integration_test
dart run scripts/bootstrap_generated_sources.dart
dart run scripts/run_daily_checks.dart
dart run scripts/run_fullstack_checks.dart
dart run scripts/install_git_hooks.dart
```

## Generated Sources Policy

- App-side generated runtime sources stay local and are
  ignored:
  - `*.g.dart`
  - `*.freezed.dart`
  - `lib/l10n/app_localizations*.dart`
- `generated/lucent_api/lib/api/**` is tracked again for day-to-day contract review, but its
  nested `**/*.g.dart` stays ignored.
- `generated/lucent_api/pubspec.lock` stays ignored.
- After clone, and whenever ARB files, Freezed/JSON models, or the Lucent contract changes, run:

```bash
dart run scripts/bootstrap_generated_sources.dart
```

If you want shorter full-stack commands, copy `.env.example` to `.env`, fill in the
`E2E_*` entries, and run `dart run scripts/run_fullstack_checks.dart`.

## CI

- GitHub Actions workflow: `.github/workflows/flutter-ci.yml`
- Current CI scope: Lucent OpenAPI export, generated-source bootstrap, `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test`, hosted Lucent OpenAPI contract-sync verification, and `flutter build apk --release`
- Current CI is validation-only. It does not build or publish Android, iOS, desktop, or web artifacts.
- `integration_test/` currently contains two different lanes:
  - offline/mock-driven integration flows that exercise the real app shell and feature pages without a Lucent runtime
  - full-stack mobile lanes that require an Android emulator plus a locally reachable Lucent test runtime
- Device/emulator E2E is split by module and scenario under `integration_test/`; run all with `flutter test integration_test` or one scenario with `flutter test integration_test/settings_preferences_e2e_test.dart`.
- Local daily validation entry:
  `dart run scripts/run_daily_checks.dart`
- Local full-stack gate entry:
  `dart run scripts/run_fullstack_checks.dart`
- Local contract-sync gate:
  `dart run scripts/verify_lucent_openapi_sync.dart`
- Shared git hooks installer:
  `dart run scripts/install_git_hooks.dart`
- Short script-style entries:
  `dart run scripts/run_daily_checks.dart`
  `dart run scripts/run_fullstack_checks.dart`
- `scripts/run_fullstack_checks.dart` starts Lucent test runtime through `pnpm --dir ../Lucent test:runtime:start`, checks `GET http://127.0.0.1:3000/api/v1/health`, then runs the five Android-emulator lanes sequentially.
- `scripts/run_fullstack_checks.dart` now prefers `.env` via `--dart-define-from-file` when that file exists, and still falls back to `.env.fullstack-e2e` for older local setups.
- Shared repo hooks live in `.githooks/`. After cloning, run `dart run scripts/install_git_hooks.dart` once to point `core.hooksPath` at that folder. Hooks are kept lightweight: `commit-msg` validates Conventional Commits format; `pre-commit` formats staged Dart files and runs `flutter analyze`; `pre-push` runs `flutter analyze` and `dart format --set-exit-if-changed` (full test suite runs in CI).
- Current GitHub Actions still does not cover the full-stack emulator gate. That lane depends on a local Android emulator plus a Lucent test runtime started from `../Lucent`, including test database state and cross-repo orchestration.
- OpenAPI/client contract sync is an explicit local maintenance step today: when Lucent API code changes, first run `pnpm export:openapi` in `../Lucent` to materialize `Lucent/docs/reference/generated/openapi.json`, then run `dart run scripts/bootstrap_generated_sources.dart` in `Luminous`. `dart run scripts/verify_lucent_openapi_sync.dart` remains the lightweight gate for verifying the target OpenAPI path and generated-client layout.
- Hosted CI is self-contained: it bootstraps generated sources (l10n, build_runner, generated API client .g.dart) from tracked files without checking out Lucent. OpenAPI contract sync remains a local maintenance step (`dart run scripts/verify_lucent_openapi_sync.dart`).

## Docs

Start with [docs/README.md](docs/README.md).

Key shared backend contract docs:

- [assistant-safety](../Lucent/docs/reference/assistant-safety.md) — AI 助手安全边界（Lucent reference/ 存活）。
- 其余历史合同文档（reminder/environment/data-sources 系列、assistant-capabilities/rollout、
  mine-settings/app-info/data-export/support-resources）已归档于 `../Lucent/docs/archive/`；
  现行合同事实以 Lucent controller/DTO 代码与测试为准。

Key frontend docs:

- [docs/README.md](docs/README.md) — docs 唯一索引
- [docs/TODO.md](docs/TODO.md) — Deferred follow-up items
- [docs/product/Product_Vision.md](docs/product/Product_Vision.md)
- [docs/product/Product_MVP_Scope.md](docs/product/Product_MVP_Scope.md)
- [docs/product/Product_Safety_Privacy.md](docs/product/Product_Safety_Privacy.md)
- [docs/product/Product_Information_Architecture.md](docs/product/Product_Information_Architecture.md)
- [docs/reference/architecture.md](docs/reference/architecture.md) — Unified Flutter architecture
- [docs/reference/state-management.md](docs/reference/state-management.md)
- [docs/reference/routing.md](docs/reference/routing.md)
- [docs/reference/data-layer.md](docs/reference/data-layer.md)
- [docs/reference/adr/](docs/reference/adr/) — Architecture Decision Records
- [docs/reference/Design_System.md](docs/reference/Design_System.md)
- [docs/reference/Forui_Reference.md](docs/reference/Forui_Reference.md)
- [docs/reference/OpenApi_Client.md](docs/reference/OpenApi_Client.md)
- [docs/reference/Localization.md](docs/reference/Localization.md)
- [docs/logs/MigrationLog.md](docs/logs/MigrationLog.md) — Change history index
