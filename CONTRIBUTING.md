# Contributing to Luminous

Thanks for your interest in contributing to Luminous! This guide covers everything
you need to get started.

## Quick Start

```bash
# Clone
git clone https://github.com/LuoMuLoyal/Luminous.git
cd Luminous

# Install dependencies
flutter pub get

# Run the app
flutter run

# Verify your environment
flutter analyze
flutter test
```

### Prerequisites

- Flutter SDK (check `pubspec.yaml` for the exact Dart/Flutter constraint)
- Dart SDK (bundled with Flutter)
- An IDE with Flutter support (VS Code or Android Studio recommended)
- A running Lucent backend for full-stack testing (see
  [Lucent](https://github.com/LuoMuLoyal/Lucent))

### Git Hooks (recommended)

After cloning, install the shared git hooks once:

```bash
dart run scripts/install_git_hooks.dart
```

This sets `core.hooksPath` to `.githooks/`. The hooks are kept lightweight to
avoid slowing down your workflow:

- **`commit-msg`**: validates Conventional Commits format — type enum,
  scope must not be empty, subject length ≤ 100, header length ≤ 120.
- **`pre-commit`**: runs `dart format` on staged `.dart` files and `flutter analyze`.
- **`pre-push`**: runs `flutter analyze` and `dart format --set-exit-if-changed`.

For a full local check, run `dart run scripts/run_daily_checks.dart`.

---

## Git Workflow

### Branches

- Keep `main` deployable at all times.
- Create short-lived branches with prefixes: `feat/`, `fix/`, `docs/`,
  `refactor/`, `chore/`.
- Use one branch for one task. Don't mix unrelated changes.
- Delete your branch after merging.

### Commits

This project uses [Conventional Commits](https://www.conventionalcommits.org/)
with Chinese summaries:

```
type(scope): 中文摘要
```

Common types:

| Type       | Use case                                    |
| ---------- | ------------------------------------------- |
| `feat`     | New feature                                 |
| `fix`      | Bug fix                                     |
| `docs`     | Documentation only                          |
| `refactor` | Code restructuring without behavior change  |
| `perf`     | Performance improvement                     |
| `test`     | Test additions or fixes                     |
| `chore`    | Tooling, dependencies, CI                   |
| `ci`       | CI/CD configuration                         |

Examples:

```
feat(auth): 添加微信桌面端登录
fix(scan): 修复空图片结果崩溃
docs(readme): 更新构建说明
chore(repo): 标准化 git 配置
```

Only write a commit body when there are breaking changes or behavior
incompatible with prior versions. For normal commits, keep a single-line summary.

### Never Commit

- Local IDE files: `.idea/`, personal `.vscode/*` (except shared workspace files)
- Build artifacts: `build/`, `android/build/`, `*.apk`, `*.ipa`
- Local dependencies: `.dart_tool/`, `.packages`
- Local generated app outputs: `*.g.dart`, `*.freezed.dart`, and
  `lib/l10n/app_localizations*.dart` (regenerate, don't hand-edit)
- Local generated OpenAPI implementation files: `generated/lucent_api/lib/api/**/*.g.dart`
- Local lockfile noise: `generated/lucent_api/pubspec.lock`
- Environment files with real credentials: `.env`, `key.properties`
- Presentation exports: `outputs/`, `Roadshow/`

### Before Push

The `pre-push` hook runs `flutter analyze` and `dart format --set-exit-if-changed`.
For a full local check:

```bash
dart run scripts/run_daily_checks.dart
```

If you changed ARB files:

```bash
# CRITICAL: Never edit app_zh.arb / app_en.arb directly.
# Edit fragment files in lib/l10n/src/ instead, then:
dart scripts/arb_tools.dart merge
flutter gen-l10n
```

If Lucent API code changed (cross-repo):

```bash
# In Lucent:
pnpm export:openapi

# In Luminous:
dart run scripts/bootstrap_generated_sources.dart
```

---

## Architecture

Luminous follows a feature-first architecture with shared core infrastructure.

```
lib/
├── app/           # App entry, root widget, router
├── core/          # Cross-cutting infrastructure
│   ├── config/    # App config, developer settings, feature flags
│   ├── design/    # Design tokens (color, spacing, typography, radius)
│   ├── network/   # Dio client, interceptors, SSE, session management
│   ├── router/    # GoRouter configuration
│   ├── feedback/  # Toast, snackbar wrappers
│   ├── widgets/   # Shared widgets (skeletons, error views, etc.)
│   ├── i18n/      # Localization helpers
│   ├── errors/    # Error handling
│   └── utils/     # Utilities
├── features/      # Feature vertical slices
│   ├── today/
│   ├── record/
│   ├── medicine/
│   ├── report/
│   ├── mine/
│   ├── auth/
│   ├── settings/
│   └── ...
├── l10n/          # ARB files + generated localizations
└── theme/         # Theme definitions
```

Each feature follows a layered structure:

```
features/{feature}/
├── data/          # Data sources, repositories, providers
├── domain/        # Entities, repository interfaces
└── presentation/  # Pages, widgets, controllers
```

### Key Rules

- **State management**: Riverpod, not GetX. Use `Notifier` / `AsyncNotifier` +
  `@freezed` for state.
- **Navigation**: GoRouter, not `Navigator.push(MaterialPageRoute(...))`.
- **New code** goes only under `lib/features/`, `lib/core/`, or `lib/shared/`.
  **Do not** add to legacy `lib/pages/`, `lib/stores/`, `lib/viewmodels/`,
  `lib/components/`.
- **User-visible text** goes through ARB + `flutter gen-l10n` — no hardcoded
  strings.
- **Page-level error states** use `AppStateErrorView`, never hand-written error
  views.
- **Loading states** use shimmer skeletons (`Shimmer.fromColors`) /
  `AppStateSkeletonView`, never `CircularProgressIndicator`.
- **Lightweight feedback** uses shared `AppToast`, not page-local `SnackBar`.
- **UI framework**: Forui. Prefer Forui primitives directly over adding new
  `App*` wrapper aliases. Use `FLucideIcons` over Material `Icons.*`.
- **Fix the requested problem directly** — do not loosen TS/ESLint rules or
  refactor nearby working code.

For the full architecture reference, see
[docs/02-reference/architecture.md](docs/02-reference/architecture.md).

---

## Testing

### Unit & Widget Tests

```bash
flutter test                                    # all tests
flutter test test/path/to_test.dart             # single file
flutter test --name "test name pattern"         # by name
```

- Mock repositories follow `Mock*Repository` naming.
- Test helpers live in `test/helpers/`.
  - `test_helpers.dart` — hand-written fakes (`MemorySessionStore`,
    `CaptureAdapter`, `SignedInAuthSessionNotifier`, screen size helpers,
    `mockNetworkImages`).
  - `mocks.dart` — mocktail-based mocks for common repository interfaces
    (`MockTodayRepository`, `MockReportRepository`, etc.). Use these when you
    need interaction verification (`verify`) or fine-grained stub control.
  - `test_forui_app.dart` — `TestForuiApp` / `TestForuiRouterApp` wrappers
    that bootstrap Forui theme + i18n for widget tests.
- Widget tests use `WidgetTester` with `ProviderScope` overrides.
- `network_image_mock` — call `mockNetworkImages(() async { ... })` in widget
  tests that render `CachedNetworkImage` to prevent real network calls.

### Integration Tests

All integration tests use the standard `integration_test` package with
`testWidgets`. Run them on a device or emulator:

```bash
# Run all integration tests
flutter test integration_test

# Run a single scenario
flutter test integration_test/settings/settings_preferences_e2e_test.dart
```

### Full-Stack E2E

Requires a local Android emulator + running Lucent test runtime:

```bash
dart run tool/run_fullstack_checks.dart
```

### Daily Checks

```bash
dart run scripts/run_daily_checks.dart
```

---

## Documentation

After every code change, update the following:

| Change type                         | Target                                    | Action             |
| ----------------------------------- | ----------------------------------------- | ------------------ |
| Any frontend code change            | `docs/03-logs/migration-log/YYYY-MM-DD.md`| Append entry       |
| Current UI/data/runtime state change| `docs/00-current/Current_State.md`        | Add/update item    |
| Closing a TODO item                 | `docs/00-current/TODO.md`                 | Delete the line    |
| Finishing a plan section            | `plans/*.md`                              | Delete section     |
| Visible text / l10n change          | `docs/02-reference/Localization.md`       | Sync update        |

Rules:

- Completed items are **deleted** outright — no `✅`, `DONE`, strikethrough, or
  any other marker.
- `docs/` is an Obsidian vault. Open `Luminous/docs/` as a vault for navigation,
  search, graph, and backlinks.
- Do not duplicate long instructions between root-level docs and child-project
  `AGENTS.md` files.

---

## OpenAPI Client

The API contract source of truth is **Lucent controller/DTO code plus a freshly exported local
`Lucent/docs/openapi.json`**. When the backend API changes:

1. In `Lucent`: `pnpm export:openapi`
2. In `Luminous`: `dart run scripts/bootstrap_generated_sources.dart`

Never hand-edit `generated/lucent_api/`. The generator handles enum defaults and
nullable map entries natively. Commit the regenerated non-`.g.dart`
`generated/lucent_api/lib/api/**` diff when the contract change is intentional.

Verify contract sync:

```bash
dart run scripts/verify_lucent_openapi_sync.dart
```

---

## Pull Requests

1. Create a branch from `main` following the naming convention.
2. Make your changes with focused commits.
3. Ensure all checks pass:
   ```bash
   flutter analyze
   flutter test
   dart run scripts/run_daily_checks.dart
   ```
4. Update documentation per the rules above.
5. Open a PR using the [template](.github/pull_request_template.md).
6. Link related issues (e.g., `Closes #123`).

### PR Review Criteria

- Conventional Commits format with Chinese summary.
- No hardcoded user-visible strings.
- Proper loading / empty / error states.
- Tests cover the changed behavior.
- Documentation is updated.
- No generated files or local config in the diff.

---

## Issue Reporting

- **Bug reports**: Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.yml).
  Include reproduction steps, expected vs actual behavior, and environment info.
- **Feature requests**: Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.yml).
  Describe the problem and proposed solution.
- **Security vulnerabilities**: Do NOT open a public issue. Follow the
  [Security Policy](SECURITY.md) and report privately to
  **luomuloyal@outlook.com**.
- **Roadmap discussions**: Check [ROADMAP.md](ROADMAP.md) before suggesting
  large-scale changes.

---

## Code of Conduct

By participating in this project, you agree to abide by the
[Code of Conduct](.github/CODE_OF_CONDUCT.md). Please be respectful and
constructive in all interactions.

---

## Questions?

- Start with [README.md](README.md) for project overview.
- Read [AGENTS.md](AGENTS.md) for AI-assisted development rules.
- Browse [docs/](docs/) for detailed architecture, design system, and product
  documentation.
