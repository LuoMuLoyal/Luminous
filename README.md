# Luminous

[![Backend: Lucent](https://img.shields.io/badge/backend-LuoMuLoyal%2FLucent-2563eb?logo=github)](https://github.com/LuoMuLoyal/Lucent)

Flutter personal health copilot. Current mainline is the reset five-tab shell backed by Lucent.

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
powershell -ExecutionPolicy Bypass -File tool/run_daily_checks.ps1
powershell -ExecutionPolicy Bypass -File tool/run_fullstack_checks.ps1
dart run melos run daily
dart run melos run fullstack
dart run melos run fullstack-today-report
```

If you want shorter full-stack commands, copy `.env.fullstack-e2e.example` to
`.env.fullstack-e2e` and run the Melos entries above. `tool/run_fullstack_checks.ps1`
also auto-detects `.env.fullstack-e2e` when present and otherwise falls back to
its built-in default test account values.

## CI

- GitHub Actions workflow: `.github/workflows/flutter-ci.yml`
- Current CI scope: `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `flutter test`
- Current CI is validation-only. It does not build or publish Android, iOS, desktop, or web artifacts.
- Device/emulator E2E is split by module and scenario under `integration_test/`; run all with `flutter test integration_test` or one scenario with `flutter test integration_test/settings_preferences_e2e_test.dart`.
- Local daily validation entry:
  `powershell -ExecutionPolicy Bypass -File tool/run_daily_checks.ps1`
- Local full-stack gate entry:
  `powershell -ExecutionPolicy Bypass -File tool/run_fullstack_checks.ps1`
- Short script-style entries:
  `dart run melos run daily`
  `dart run melos run fullstack`
  `dart run melos run fullstack-today-report`
- `tool/run_fullstack_checks.ps1` starts Lucent test runtime through `../Lucent/scripts/dev/start-test-runtime.ps1`, checks `GET http://127.0.0.1:3000/api/v1/health`, then runs the four Android-emulator lanes sequentially.
- `tool/run_fullstack_checks.ps1` now prefers `.env.fullstack-e2e` via `--dart-define-from-file` when that file exists.
- Current GitHub Actions still does not cover the full-stack emulator gate. That lane depends on a separate Lucent test runtime, test database state, and Android emulator orchestration across two repositories.

## Docs

Start with [docs/README.md](docs/README.md).

Key shared backend contract docs live in `../Lucent/docs/public/`:

- [reminder-contract](../Lucent/docs/public/reminder-contract.md)
- [environment-contract](../Lucent/docs/public/environment-contract.md)
- [data-sources](../Lucent/docs/public/data-sources.md)

Key frontend docs:

- [docs/Product_Vision.md](docs/Product_Vision.md)
- [docs/Current_State.md](docs/Current_State.md)
- [docs/MigrationLog.md](docs/MigrationLog.md)
- [docs/Next_Plan.md](docs/Next_Plan.md)
- [docs/MVP_Demo_Baseline.md](docs/MVP_Demo_Baseline.md)
- [docs/MVP_Demo_Script.md](docs/MVP_Demo_Script.md)
- [docs/Project_Guardrails.md](docs/Project_Guardrails.md)
- [docs/OpenApi_Client.md](docs/OpenApi_Client.md)
- [docs/Localization.md](docs/Localization.md)
