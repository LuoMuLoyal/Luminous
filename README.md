# Luminous

[![Backend: Lucent](https://img.shields.io/badge/backend-LuoMuLoyal%2FLucent-2563eb?logo=github)](https://github.com/LuoMuLoyal/Lucent)

Flutter 个人健康助手。以用药安全为入口，连接日常记录与 AI 驱动的主动提醒、总结和报告。

Current version: **0.1.0-dev**

## Community

- [Roadmap](ROADMAP.md) — planned evolution and version milestones
- [Changelog](CHANGELOG.md) — release-level change history
- [Contributing](CONTRIBUTING.md) — development setup, conventions, and PR process
- [Code of Conduct](.github/CODE_OF_CONDUCT.md) — community standards
- [Issues](https://github.com/LuoMuLoyal/Luminous/issues) — bug reports and feature requests

## AI Workflow

- Repo AI-development reference: `docs/02-reference/AI_Development_Workflow.md`
- Editor-assistant entry: `.github/copilot-instructions.md`
- Agent entries: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`
- MCP entry for compatible clients: `.cursor/mcp.json`
- VS Code project setting enables the Dart/Flutter MCP server: `.vscode/settings.json`
- Experimental app-side AI runtime seam lives in `lib/core/ai/` and is kept
  separate from Lucent-backed production assistant/report flows.
- Runtime seam flags are documented in `docs/02-reference/AI_Development_Workflow.md`

## Baseline

- Tabs: `today / record / medicine / report / mine`
- Design tokens: color / type / spacing / radius / breakpoints / animation
- UI framework: [Forui](https://forui.dev)（2026-07 从 Material Design 全量迁移）
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

If you want shorter full-stack commands, copy `.env.example` to `.env`, fill in the
`E2E_*` entries, and run the Melos entries above. `tool/run_fullstack_checks.dart`
now prefers `.env` when present and otherwise falls back to its built-in default
test account values.

## CI

- GitHub Actions workflow: `.github/workflows/flutter-ci.yml`
- Current CI scope: `flutter pub get`, `flutter gen-l10n`, `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test`, hosted Lucent OpenAPI contract-sync verification, and `flutter build apk --release`
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
- `tool/run_fullstack_checks.dart` now prefers `.env` via `--dart-define-from-file` when that file exists, and still falls back to `.env.fullstack-e2e` for older local setups.
- Shared repo hooks live in `.githooks/`. After cloning, run `dart run tool/install_git_hooks.dart` once to point `core.hooksPath` at that folder. Hook entrypoints now call Dart directly instead of delegating through PowerShell wrappers.
- Current hook scope: `pre-commit` runs `flutter gen-l10n`, `dart format --output=none --set-exit-if-changed` on staged Dart files, and `flutter analyze`; `pre-push` runs `tool/run_daily_checks.dart`.
- Current GitHub Actions still does not cover the full-stack emulator gate. That lane depends on a local Android emulator plus a Lucent test runtime started from `../Lucent`, including test database state and cross-repo orchestration.
- OpenAPI/client contract sync is an explicit local maintenance step today: when Lucent API code changes, regenerate `Lucent/docs/openapi.json` first, then run `dart run tool/regenerate_lucent_openapi.dart` in Luminous before merging. `dart run tool/verify_lucent_openapi_sync.dart` is the lightweight gate for verifying the target OpenAPI path and generated-client layout without requiring a clean git working tree.
- Hosted CI now also enforces that gate by checking out `Lucent`, pointing `tool/verify_lucent_openapi_sync.dart` at the checked-out `docs/openapi.json`, and failing when regeneration would change `packages/lucent_openapi/`.

## Docs

Start with [docs/README.md](docs/README.md).

Key shared backend contract docs live in `../Lucent/docs/public/`:

- [reminder-contract](../Lucent/docs/public/reminder-contract.md)
- [environment-contract](../Lucent/docs/public/environment-contract.md)
- [data-sources](../Lucent/docs/public/data-sources.md)
- [data-sources-cn-products](../Lucent/docs/public/data-sources-cn-products.md)
- [data-sources-drugbank](../Lucent/docs/public/data-sources-drugbank.md)
- [data-sources-medical-qa](../Lucent/docs/public/data-sources-medical-qa.md)
- [data-sources-food-composition](../Lucent/docs/public/data-sources-food-composition.md)
- [assistant-contract](../Lucent/docs/public/assistant-contract.md)
- [assistant-capabilities](../Lucent/docs/public/assistant-capabilities.md)
- [assistant-rollout](../Lucent/docs/public/assistant-rollout.md)
- [assistant-safety](../Lucent/docs/public/assistant-safety.md)
- [mine-settings-contract](../Lucent/docs/public/mine-settings-contract.md)
- [support-resources-contract](../Lucent/docs/public/support-resources-contract.md)
- [app-info-contract](../Lucent/docs/public/app-info-contract.md)
- [data-export-contract](../Lucent/docs/public/data-export-contract.md)

Key frontend docs:

- [docs/README.md](docs/README.md) — Vault home / navigation map
- [docs/00-current/Current_State.md](docs/00-current/Current_State.md) — Current implementation state
- [docs/00-current/Next_Plan.md](docs/00-current/Next_Plan.md) — Next work ordering
- [docs/00-current/TODO.md](docs/00-current/TODO.md) — Deferred follow-up items
- [docs/01-product/Product_Vision.md](docs/01-product/Product_Vision.md)
- [docs/01-product/Product_MVP_Scope.md](docs/01-product/Product_MVP_Scope.md)
- [docs/01-product/Product_AI_Design.md](docs/01-product/Product_AI_Design.md)
- [docs/01-product/Product_Insights.md](docs/01-product/Product_Insights.md)
- [docs/01-product/Product_Safety_Privacy.md](docs/01-product/Product_Safety_Privacy.md)
- [docs/01-product/Product_Information_Architecture.md](docs/01-product/Product_Information_Architecture.md)
- [docs/01-product/MVP_Demo_Baseline.md](docs/01-product/MVP_Demo_Baseline.md)
- [docs/01-product/MVP_Demo_Script.md](docs/01-product/MVP_Demo_Script.md)
- [docs/02-reference/architecture.md](docs/02-reference/architecture.md) — Unified Flutter architecture
- [docs/02-reference/state-management.md](docs/02-reference/state-management.md)
- [docs/02-reference/routing.md](docs/02-reference/routing.md)
- [docs/02-reference/data-layer.md](docs/02-reference/data-layer.md)
- [docs/02-reference/adr/](docs/02-reference/adr/) — Architecture Decision Records
- [docs/02-reference/Design_System.md](docs/02-reference/Design_System.md)
- [docs/02-reference/Design_System_Components.md](docs/02-reference/Design_System_Components.md)
- [docs/02-reference/Design_System_Migration.md](docs/02-reference/Design_System_Migration.md)
- [docs/02-reference/Project_Guardrails.md](docs/02-reference/Project_Guardrails.md)
- [docs/02-reference/OpenApi_Client.md](docs/02-reference/OpenApi_Client.md)
- [docs/02-reference/Localization.md](docs/02-reference/Localization.md)
- [docs/03-logs/MigrationLog.md](docs/03-logs/MigrationLog.md) — Change history index
