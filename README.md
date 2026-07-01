# Luminous

[![Backend: Lucent](https://img.shields.io/badge/backend-LuoMuLoyal%2FLucent-2563eb?logo=github)](https://github.com/LuoMuLoyal/Lucent)

Flutter personal health copilot. Current mainline is the reset five-tab shell backed by Lucent.

Current version: **v4.0.0-dev**

## Baseline

- Tabs: `today / record / medicine / report / mine`
- Design tokens: color / type / spacing / radius / shadow / breakpoints
- API client: `packages/lucent_openapi`
- Network layer: `lib/core/network/`
- i18n: Flutter `gen-l10n`
- WeChat OAuth: Android/iOS uses the WeChat SDK through `fluwx` to obtain an auth code and then calls Lucent's mobile callback endpoint. Desktop login starts a loopback callback listener, asks Lucent for an authorize URL with that callback URI, opens the system browser, verifies the returned `state`, and completes login automatically when Lucent redirects back with `code` and `state`. Web login passes `/login/oauth/wechat` as the callback path. Manual callback paste remains as a fallback.

Mobile WeChat SDK builds need:

- Dart define `WECHAT_MOBILE_APP_ID=<wx app id>`
- iOS Dart define `WECHAT_IOS_UNIVERSAL_LINK=<universal link>` when applicable
- iOS native URL Scheme build setting: copy `ios/Flutter/Wechat.example.xcconfig` to `ios/Flutter/Wechat.xcconfig` and set the same `WECHAT_MOBILE_APP_ID`
- Matching Android signature/package and iOS URL Scheme/Universal Link setup in the WeChat Open Platform console and native projects. iOS Universal Link still requires real Associated Domains configuration in the Apple developer account and release signing setup.

## Commands

```bash
flutter pub get
flutter run
flutter analyze
flutter test
flutter test integration_test
dart run tool/regenerate_lucent_openapi.dart
dart run tool/run_daily_checks.dart
dart run tool/run_fullstack_checks.dart
dart run tool/install_git_hooks.dart
dart run melos run daily
dart run melos run fullstack
dart run melos run fullstack-today-report
```

If you want shorter full-stack commands, copy `.env.fullstack-e2e.example` to
`.env.fullstack-e2e` and run the Melos entries above. `tool/run_fullstack_checks.dart`
also auto-detects `.env.fullstack-e2e` when present and otherwise falls back to
its built-in default test account values.

## CI

- GitHub Actions workflow: `.github/workflows/flutter-ci.yml`
- Current CI scope: `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`
- Current CI is validation-only. It does not build or publish Android, iOS, desktop, or web artifacts.
- `integration_test/` currently contains two different lanes:
  - offline/mock-driven integration flows that exercise the real app shell and feature pages without a Lucent runtime
  - full-stack mobile lanes that require an Android emulator plus a locally reachable Lucent test runtime
- Device/emulator E2E is split by module and scenario under `integration_test/`; run all with `flutter test integration_test` or one scenario with `flutter test integration_test/settings_preferences_e2e_test.dart`.
- Local daily validation entry:
  `dart run tool/run_daily_checks.dart`
- Local full-stack gate entry:
  `dart run tool/run_fullstack_checks.dart`
- Local contract-sync gate:
  `dart run tool/verify_lucent_openapi_sync.dart`
- Shared git hooks installer:
  `dart run tool/install_git_hooks.dart`
- Short script-style entries:
  `dart run melos run daily`
  `dart run melos run fullstack`
  `dart run melos run fullstack-today-report`
- `tool/run_fullstack_checks.dart` starts Lucent test runtime through `pnpm --dir ../Lucent test:runtime:start`, checks `GET http://127.0.0.1:3000/api/v1/health`, then runs the five Android-emulator lanes sequentially.
- `tool/run_fullstack_checks.dart` now prefers `.env.fullstack-e2e` via `--dart-define-from-file` when that file exists.
- Shared repo hooks live in `.githooks/`. After cloning, run `dart run tool/install_git_hooks.dart` once to point `core.hooksPath` at that folder. Hook entrypoints now call Dart directly instead of delegating through PowerShell wrappers.
- Current hook scope: `pre-commit` runs `flutter gen-l10n`, `dart format --output=none --set-exit-if-changed` on staged Dart files, and `flutter analyze`; `pre-push` runs `tool/run_daily_checks.dart`.
- Current GitHub Actions still does not cover the full-stack emulator gate. That lane depends on a local Android emulator plus a Lucent test runtime started from `../Lucent`, including test database state and cross-repo orchestration.
- OpenAPI/client contract sync is an explicit local maintenance step today: when Lucent API code changes, regenerate `Lucent/docs/openapi.json` first, then run `dart run tool/regenerate_lucent_openapi.dart` in Luminous before merging. `dart run tool/verify_lucent_openapi_sync.dart` is the lightweight gate that fails when either side still has uncommitted contract/client drift.

## Docs

Start with [docs/README.md](docs/README.md).

Key shared backend contract docs live in `../Lucent/docs/public/`:

- [reminder-contract](../Lucent/docs/public/reminder-contract.md)
- [environment-contract](../Lucent/docs/public/environment-contract.md)
- [data-sources](../Lucent/docs/public/data-sources.md)
- [assistant-contract](../Lucent/docs/public/assistant-contract.md)
- [mine-settings-contract](../Lucent/docs/public/mine-settings-contract.md)

Key frontend docs:

- [docs/architecture.md](docs/architecture.md) — Unified Flutter architecture
- [docs/adr/](docs/adr/) — Architecture Decision Records
- [docs/Product_Vision.md](docs/Product_Vision.md)
- [docs/Current_State.md](docs/Current_State.md)
- [docs/MigrationLog.md](docs/MigrationLog.md)
- [docs/Next_Plan.md](docs/Next_Plan.md)
- [docs/MVP_Demo_Baseline.md](docs/MVP_Demo_Baseline.md)
- [docs/MVP_Demo_Script.md](docs/MVP_Demo_Script.md)
- [docs/Project_Guardrails.md](docs/Project_Guardrails.md)
- [docs/OpenApi_Client.md](docs/OpenApi_Client.md)
- [docs/Localization.md](docs/Localization.md)
