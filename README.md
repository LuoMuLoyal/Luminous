# Luminous

[![Backend: Lucent](https://img.shields.io/badge/backend-LuoMuLoyal%2FLucent-2563eb?logo=github)](https://github.com/LuoMuLoyal/Lucent)

Flutter + KMP 主动式个人健康助手，手机、桌面与手表共用同一套事实底座与 Lucent 后端。

产品由三条主线构成，它们不是并列的功能清单，而是同一个「可检查的个人上下文」的不同切入面：

- **记录与洞察**：以低负担的稀疏记录积累事实，在日 / 周 / 月尺度发现值得注意的变化。缺失表示未知而非零，每条结论携带覆盖率，证据不足时明确弃权。Review 同时承担 agent 的长期记忆：它生成周报 / 月报式摘要，agent 通过报告摘要工具按区间或按最近若干份读取，不必逐日重扫原始记录。
- **用药与药理知识**：从个人用药盒延伸到药物—酶—靶点—通路的关系网络，把「我这样吃药有没有风险」与「这些药之间是什么机制关联」放在同一个工作区里。用药安全是其中证据要求最高的一条主线，不是产品天花板。
- **可编排的工作台**：每个 tab 由已注册的组件装配而成，用户自己决定出现哪些、按什么顺序、多大尺寸；同一份布局同时描述手机、平板与桌面三种形态，并经 Lucent 的布局端点持久化与版本校验。

AI 在这三条主线里只承担理解、总结、解释与提醒文案；任何写操作都以提案形式出现，需用户显式确认。诊断、处方与药物风险判定不交给模型。会话线程与工作流状态由 LangGraph 的 Postgres checkpointer 持久化；长期上下文由已持久化的 today / report 摘要与健康数据本身共同构成，不依赖把聊天原文当事实。

Current version: **0.1.0-dev**

## Community

- [Roadmap](ROADMAP.md) — planned evolution and version milestones
- [Changelog](CHANGELOG.md) — release-level change history
- [Contributing](CONTRIBUTING.md) — development setup, conventions, and PR process
- [Code of Conduct](CODE_OF_CONDUCT.md) — community standards
- [Security Policy](SECURITY.md) — vulnerability reporting
- [Licence](LICENSE) · [Third-party notices](THIRD_PARTY_NOTICES.md) — project licence and dependency licences
- [Product language](docs/reference/Glossary.md) — canonical health-event, sparse-record, guidance, and review terms
- [Issues](https://github.com/LuoMuLoyal/Luminous/issues) — bug reports and feature requests

## AI Workflow

- Repo AI-development reference: `docs/explanation/ai-development-workflow.md`
- Editor-assistant entry: `.github/copilot-instructions.md`
- Agent entries: `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`
- MCP entry for compatible clients: `.cursor/mcp.json`
- VS Code project setting enables the Dart/Flutter MCP server: `.vscode/settings.json`
- Experimental app-side AI runtime seam lives in `lib/core/ai/` and is kept
  separate from Lucent-backed production assistant/report flows.
- Runtime seam flags are documented in `docs/explanation/ai-development-workflow.md`

## Baseline

- Tabs: `today / record / medicine / review / mine` — Today is the action panel, Record is the
  sparse-record fact panel, Medicine is the drug workspace, Review is longitudinal insight **and
  the agent's long-term memory** (weekly/monthly report summaries that assistant tools read), Mine
  holds profile and settings. Each tab's boundaries live in its feature README.
- **Platforms**: phone, desktop and the Wear OS watch are all shipping surfaces; **desktop is an
  equal platform, not a secondary adaptation target** (ADR-0008 amendment). Phone and desktop share
  one Flutter + KMP client and one Lucent backend; the watch is a separate Kotlin + Compose for Wear
  OS companion app in `../Luminous-watch`. The Web build remains available from the same client.
- **Shared platform layer**: Flutter owns UI, state and business logic; `native/` is a Kotlin
  Multiplatform module for platform-independent logic (step counting, baseline arithmetic, day
  splitting and related contracts), consumed through `pkgs/luminous_native_bridge` on Android and
  iOS. KMP is part of the client stack, not an optional add-on.

- **Composable surfaces**: every tab is assembled from registered components rather than a
  hand-written page. A surface's layout (which components, in what order, at which size, visible or
  not) is persisted per user and synced through Lucent, so one layout describes phone, tablet and
  desktop at once (`lib/core/composition/`, `lib/features/customizer/`). A component is identified by
  a domain id (`summary.metrics`, `dose.safety_engine`) and can be mounted on more than one surface.
- **Knowledge graph**: the medicine workspace renders pharmacological relations (drug → enzyme →
  target, cascade paths, shared targets, transport routes, substitution) from Lucent's relation
  endpoints. Each relation component has a list variant and a graph variant; the graph uses
  `graphview`'s Sugiyama layering because these relations are directed and tiered — force-directed
  layouts would place the same pathway differently on every open, and medical information needs a
  repeatable reading.
- **Generative UI is experimental and off by default**: an opt-in switch gates backend-generated
  surface components (`generative.<surface>`); with the switch off they are never registered, and a
  stored layout that references them degrades by skipping unknown ids.
- **Observability**: data-layer errors and logs route through the `core/network` contract outlet
  rather than ad-hoc logging, so failures carry the same vocabulary as user-facing states. Log sinks
  fall back to a local Talker when none is installed.
- Product constraints that the whole app enforces:
  - Missing data means **unknown**, never zero — no dimension may infer "didn't take the medicine"
    or "didn't drink" from an absent record.
  - Every conclusion carries coverage (`observedCount` / `expectedCount`); when evidence is thin the
    system **abstains** rather than emitting a weaker claim.
  - AI handles understanding, summarising, explaining and reminder copy only. It never diagnoses,
    prescribes, or decides drug risk — safety conclusions come from rules, leaflets, curated data or
    human review.
  - Assistant writes are **proposal-based**: any write requires explicit user confirmation.
- Design tokens: color / type / spacing / radius / breakpoints / animation. Desktop adds a third
  surface tier (sidebar < canvas < card) and a platform-dependent line height; see
  `lib/core/design/layout/surface.dart` and `lib/core/theme/family.dart`.
- UI framework: [Forui](https://forui.dev)（2026-07 从 Material Design 全量迁移）
- Responsive layout: `fluid_adaptive`'s Material 3 window size classes (600 / 840 / 1200) drive
  page padding, card density and content max width (`lib/core/design/layout/layout_scale.dart`).
- API client: `generated/lucent_api`
- Network layer: `lib/core/network/`
- Local persistence: Drift, with a pending-sync queue used by the write paths that need offline
  replay (`lib/core/database/`). Layout edits and offline writes replay through the same queue.
- i18n: Flutter `gen-l10n` — ARB fragments live in `lib/l10n/src/`; main `app_zh.arb` / `app_en.arb` are **generated** via `dart scripts/l10n/arb_tools.dart merge` — never edit them directly.
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
dart run scripts/contract/bootstrap.dart
dart run scripts/workflows/daily.dart
dart run scripts/workflows/fullstack.dart
dart run scripts/hooks/git.dart install
```

Backend base URL (`LUCENT_BASE_URL`) is a **compile-time** input read through `--dart-define` /
`--dart-define-from-file=.env`; editing `.env` needs a fresh `flutter run` because a hot restart
does not re-read defines. Release builds require it. Debug builds that pin it default to that URL
everywhere, physical devices included; with nothing pinned, Android falls back to
`http://10.0.2.2:3000` (the emulator-only alias for the host loopback, which a physical device
cannot reach). Debug builds can also switch endpoints at runtime in 我的 → 设置 → 高级 → API 端点
(`DeveloperSettingsController`) — an explicit choice there still wins over the pinned define. That
section exists in debug builds only, and the 「生产」preset resolves the build-injected
`LUCENT_PROD_BASE_URL` (falling back to `LUCENT_BASE_URL`): the deployed host address is **not**
stored in this repository — keep it in the untracked `.env` / CI secret. `local` and `staging`
resolve to loopback, so neither is reachable from a physical device.

## Environment files

Two untracked files, one template each (`.gitignore` ignores `.env` / `.env.*` but re-includes
`*.example`):

| Use | Template (tracked) | Local file (untracked) | Consumed by |
|---|---|---|---|
| App runtime (`flutter run`) | `.env.example` | `.env` | `.vscode/launch.json` "Luminous" |
| Full-stack E2E lane | `.env.e2e.example` | `.env.e2e` | `scripts/workflows/fullstack.dart` (and the "Luminous (Full-stack E2E Env)" launch config) |

The E2E file is self-contained on purpose: `--dart-define-from-file` accepts exactly one file, so
it carries the `E2E_*` account **and** the `LUCENT_BASE_URL` the app under test uses.

### Process environment variables (desktop)

Read by the native runner at process start, not compiled in — they work on any build, including
CI-produced release bundles:

| Variable | Platform | Effect |
|---|---|---|
| `LUMINOUS_SOFTWARE_RENDER` | Linux | Set to any non-empty value to disable Impeller and render with Skia. Needed on machines without a usable GPU driver (VMware/VirtualBox guests, `Mesa` llvmpipe): there the app otherwise initialises the engine and then never presents a first frame — process alive, no window. Unset restores the default (Impeller). See [`linux/runner/my_application.cc`](linux/runner/my_application.cc) |

```bash
LUMINOUS_SOFTWARE_RENDER=1 ~/.local/opt/luminous/luminous
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
dart run scripts/contract/bootstrap.dart
```

If you want shorter full-stack commands, copy `.env.e2e.example` to `.env.e2e`, fill in the
`E2E_*` entries, and run `dart run scripts/workflows/fullstack.dart`.

## CI

- GitHub Actions workflows are split by concern: `.github/workflows/ci.yml` is validation only; each release lives in its own file — `deploy-android.yml` (release APK), `deploy-ios.yml` (unsigned IPA on a macOS runner), `deploy-web.yml` (Flutter Web → GitHub Pages). See `.github/workflows/README.md`.
- `ci.yml` scope: ARB fragment merge, generated-source bootstrap, generated API client build, generated-docs check, `flutter analyze`, `flutter test --coverage`. It produces no release artifacts, so it runs on every push and pull request.
- Releases trigger on `push` to their branch (`main` for Android/iOS, `refactor` for Web) or on manual `workflow_dispatch`, which can run from any branch.
- iOS is built on GitHub-hosted `macos-latest` with `flutter build ios --release --no-codesign`, so the Windows development host does not need Xcode: the workflow produces an unsigned `luminous-ios-unsigned-ipa` artifact plus Dart symbols. Re-sign locally (Sideloadly / AltStore with your own Apple ID) to install it on a device. Signing certificates / provisioning profiles and TestFlight distribution are not wired up yet — see `docs/TODO.md`.
- Android ships one self-contained APK per ABI via `flutter build apk --release --split-per-abi` (`app-arm64-v8a-release.apk`, `app-armeabi-v7a-release.apk`, `app-x86_64-release.apk`), each carrying its own `libflutter.so`/`libapp.so`. ABI selection belongs to the Flutter tool — do not add `abiFilters` or variant-level `jniLibs` excludes: `abiFilters` conflicts with ABI splits, and variant-scoped excludes apply to *every* split output, which strips a split's own Flutter engine and yields an APK that crashes in `MainActivity.onCreate` with `Could not find 'libflutter.so'`.
- Release build inputs come from repository secrets/variables: `LUCENT_BASE_URL` (required — the run fails rather than shipping an artifact that cannot reach the API), plus optional `SENTRY_DSN`, `SUPPORT_EMAIL`, `JPUSH_APP_KEY`, `WECHAT_MOBILE_APP_ID`, `WECHAT_IOS_UNIVERSAL_LINK`. Missing optional values only disable the matching feature and emit a warning.
- `deploy-web.yml` builds and publishes Flutter Web to GitHub Pages; it auto-triggers on `push` to `refactor` (not `main`).
- `integration_test/` currently contains two different lanes:
  - offline/mock-driven integration flows that exercise the real app shell and feature pages without a Lucent runtime
  - full-stack mobile lanes that require an Android emulator plus a locally reachable Lucent test runtime
- Device/emulator E2E is split by module and scenario under `integration_test/`; run all with `flutter test integration_test` or one scenario with `flutter test integration_test/settings_preferences_e2e_test.dart`.
- Local daily validation entry:
  `dart run scripts/workflows/daily.dart`
- Local full-stack gate entry:
  `dart run scripts/workflows/fullstack.dart`
- Local contract-sync gate:
  `dart run scripts/contract/verify_openapi.dart`
- Shared git hooks installer:
  `dart run scripts/hooks/git.dart install`
- Short script-style entries:
  `dart run scripts/workflows/daily.dart`
  `dart run scripts/workflows/fullstack.dart`
- `scripts/workflows/fullstack.dart` starts Lucent test runtime through `pnpm --dir ../Lucent test:runtime:start`, checks `GET http://127.0.0.1:3000/api/v1/health`, then runs the five Android-emulator lanes sequentially.
- `scripts/workflows/fullstack.dart` prefers the E2E define file `.env.e2e` via `--dart-define-from-file` when it exists, and still falls back to `.env.fullstack-e2e` for older local setups (the app-development `.env` is deliberately not a candidate — it carries no `E2E_*` account).
- Shared repo hooks live in `.githooks/`. After cloning, run `dart run scripts/hooks/git.dart install` once to point `core.hooksPath` at that folder. Hooks are kept lightweight: `commit-msg` validates Conventional Commits format; `pre-commit` formats staged Dart files and runs `flutter analyze`; `pre-push` runs `flutter analyze` and `dart format --set-exit-if-changed` (full test suite runs in CI).
- Current GitHub Actions still does not cover the full-stack emulator gate. That lane depends on a local Android emulator plus a Lucent test runtime started from `../Lucent`, including test database state and cross-repo orchestration.
- OpenAPI/client contract sync is an explicit local maintenance step today: when Lucent API code changes, first run `pnpm export:openapi` in `../Lucent` to materialize `Lucent/docs/reference/generated/openapi.json`, then run `dart run scripts/contract/bootstrap.dart` in `Luminous`. `dart run scripts/contract/verify_openapi.dart` remains the lightweight gate for verifying the target OpenAPI path and generated-client layout.
- Hosted CI is self-contained: it bootstraps generated sources (l10n, build_runner, generated API client .g.dart) from tracked files without checking out Lucent. OpenAPI contract sync remains a local maintenance step (`dart run scripts/contract/verify_openapi.dart`).

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
- [docs/product/product-vision.md](docs/product/product-vision.md)
- [docs/product/product-mvp-scope.md](docs/product/product-mvp-scope.md)
- [docs/product/product-safety-privacy.md](docs/product/product-safety-privacy.md)
- [docs/product/product-information-architecture.md](docs/product/product-information-architecture.md)
- [docs/reference/architecture.md](docs/reference/architecture.md) — Flutter + KMP architecture
- [native/README.md](native/README.md) — Kotlin Multiplatform shared module (`luminous-native`)
- Watch companion app: [`../Luminous-watch`](../Luminous-watch) — separate Kotlin + Compose for Wear OS project
- [docs/reference/state-management.md](docs/reference/state-management.md)
- [docs/reference/routing.md](docs/reference/routing.md)
- [docs/reference/data-layer.md](docs/reference/data-layer.md)
- [docs/reference/adr/](docs/reference/adr/) — Architecture Decision Records
- [docs/reference/design-system.md](docs/reference/design-system.md)
- [docs/reference/forui-reference.md](docs/reference/forui-reference.md)
- [docs/reference/openapi-client.md](docs/reference/openapi-client.md)
- [docs/reference/localization.md](docs/reference/localization.md)
- [docs/logs/MigrationLog.md](docs/logs/MigrationLog.md) — Change history index
