# AGENTS.md - Luminous

## Documentation Rules

After every code change, run `dart run scripts/check_doc_coverage.dart --warning-only`.
It reads `docs/doc-map.yaml` and prints a per-rule report of which docs each touched code
area expects. The pre-commit hook runs the same tool in **blocking** mode: code files
staged but no `docs/` file staged → commit blocked. Bypass with `SKIP_DOC_CHECK=1`.

### Standing rules

- **Migration log**: append a dated entry to `docs/03-logs/migration-log/YYYY-MM-DD.md`.
  **Never overwrite** an existing entry — always append new sections below existing content.
  The pre-commit hook blocks commits where a staged migration-log file has more than 5 deleted
  lines (indicating overwrite rather than append).
  - Entries describe change scope and verification conclusions; do not write exact
    numbers that must stay in sync on later edits (e.g. total test counts).
    （日志条目描述变更范围与验证结论，不写需要持续同步的精确数字（如测试总数）。）
- **No handwritten "current state" narratives**: UI/data/runtime snapshots are not docs.
  Assertions live in golden/widget tests; per-feature constraints live in that feature's
  `README.md`. Do not create new `Active_*` / `*_Snapshot` style docs.
  （冻结新增手写"现状叙事"文档：断言进测试，约束进 feature README。）
- **Closing a TODO**: delete the line from `docs/00-current/TODO.md`.
- **Finishing a plan**: delete the entire section from `plans/*.md`.
- **Doc lifecycle**: active docs older than 90 days without updates, or unreferenced by
  `doc-map.yaml` / doc links, are flagged by `dart run scripts/check_doc_coverage.dart --verify`
  — review, update, or archive them to `docs/04-archive/`. Docs marked `status: frozen` are
  exempt from the 90-day freshness checks.
- **Front-matter**: every active content doc must carry YAML front-matter
  (`status: active|frozen` / `owner: frontend` / `updated: YYYY-MM-DD`);
  `--verify` flags missing blocks, stale `updated`, and `status: stale` docs not yet archived.
  `status: frozen` marks a doc intentionally frozen (desktop/Web-freeze, feature-freeze) —
  exempt from the freshness checks but still must carry valid front-matter; `status: stale`
  means the doc should be archived, not frozen.
- **Visible text/l10n change**: sync `docs/02-reference/Localization.md`.
- Completed items are **deleted** outright — no markers.

## Stack

- Flutter, Riverpod (not GetX), GoRouter (not `Navigator.push(MaterialPageRoute(...))`).
- Backend: Lucent.

## Commands

```powershell
flutter pub get                                  # 拉取依赖
flutter analyze                                  # 最快反馈
flutter test                                     # 单元/Widget 测试
flutter test test/path/to_test.dart              # 单个测试文件
flutter test integration_test                    # 全部 E2E
flutter test integration_test/<scenario>_e2e_test.dart   # 单个 E2E 场景
dart scripts/arb_tools.dart merge                # 分片 ARB 合并(l10n 变更后)
flutter gen-l10n                                 # ARB 合并后生成 Dart 本地化代码
dart run scripts/bootstrap_generated_sources.dart        # 生成物准备(全新 clone/ARB/契约变更后必跑)
dart run scripts/run_daily_checks.dart           # 仓库安全级检查(analyze+test+文档)
dart run scripts/run_fullstack_checks.dart       # 全栈检查(需 Lucent 运行时)
dart run scripts/check_doc_coverage.dart --warning-only   # 文档覆盖报告(--verify 全量治理)
```

窄命令迭代，收尾前跑宽检查(`run_daily_checks.dart`)。

## Architecture

- `lib/core/` — shared design system, theme, feedback, network, widgets.
- `lib/features/{feature}/` — per-feature vertical slices:
  - `application/` — business orchestration: use cases (function-style) and orchestrators (class-style)
  - `data/` — repositories, data sources, providers, mappers, utils
  - `domain/` — entities, repository interfaces, services, constants
  - `presentation/` — pages, widgets, controllers, providers, utils, models, services
- New code goes only under `lib/features/`, `lib/core/`, or `lib/shared/`. **Do not**
  add to legacy `lib/pages/`, `lib/stores/`, `lib/viewmodels/`, `lib/components/`.
- The five tabs are `today / record / medicine / review / mine`.

### Cross-Feature Import Rules

1. **data → data prohibited** — a feature's `data/` layer must not import another feature's
   `data/` layer. Use domain interfaces (`domain/repositories/`) instead.
2. **presentation → presentation prohibited** — a feature's `presentation/` layer must not
   import another feature's `presentation/` providers. Use domain entities, the shared
   snapshot hub (`healthContextSnapshotProvider`), or the DataChangeBus.
3. **application → domain allowed** — the `application/` layer may import other features'
   `domain/` layer (interfaces + entities) for cross-feature orchestration.

## Barrel Exports

- `core/` cross-cutting barrels (`design.dart`, `api.dart`, `state_views.dart`) are the
  only legitimate barrel files — they aggregate design tokens, network symbols, and
  state views consumed by all features.
- No feature-level barrel files — cross-feature imports use full `package:` paths:
  - ❌ `export '../sections/ai_summary.dart';` in a `shared/sections.dart` barrel
  - ✅ `import 'package:luminous/features/report/presentation/widgets/sections/ai_summary.dart';`
- No cross-layer re-exports — a provider file must not `export` a repository or entity;
  consumers import from the correct layer directly.
- Platform conditional exports (`if (dart.library.io)`) are exempt.

## File Naming Rules

**Core principle**: File name = responsibility, not location.

1. **No type-suffix when the directory conveys the type** — `_provider`, `_page`, `_widget`,
   `_section`, `_data_source`, `_repository` are redundant.
   - ❌ `providers/session_provider.dart` → ✅ `providers/session.dart`
2. **Never use a pure type word** (`provider.dart`, `repository.dart`). Add a business word.
3. **No directory-name prefix** on files inside that directory.
   - ❌ `medicine/presentation/pages/medicine_page.dart` → ✅ `medicine/presentation/pages/page.dart`
4. **No `app_` prefix on `core/` files** — `app_` is not a business word.
5. **Keep business words and implementation qualifiers** (`session`, `lucent`, `remote`, `mock`).
6. **Class names are unaffected** — only file names change.
7. **Test files mirror source** with `_test.dart` suffix.
8. **Directory file-count cap** — a directory holding more than 10 direct source files
   (generated files excluded) should be split into subdirectories; exemptions must be
   recorded in the migration log.

## State Management

- Riverpod `Notifier` + `NotifierProvider`; `@freezed` for immutable state.
- `ref.watch()` for reading, `ref.read()` for callbacks.
- Prefer `ref.watch(provider.select(...))` to slice state and avoid unnecessary rebuilds.

## Routing

- `GoRouter` with `StatefulShellRoute` for bottom tabs. Use typed routes
  (`@TypedGoRoute` + `go_router_builder`).
- Tab roots: `/`, `/record`, `/medicine`, `/review`, `/mine`.
- Sub-pages are top-level full-screen routes outside the shell.

## Design System

Forui-led theming. Details in `docs/02-reference/Design_System.md` and
`docs/02-reference/Forui_Reference.md`. Reference in `D:\25080\Documents\VSCodeProject\Lumos\forui-docs`

- `SemanticColor`, `Spacing`, `IconSizeTokens` — design tokens；圆角/字体直接取 Forui `context.theme.style.borderRadius.*` / `context.theme.typography.body/display.*`(via barrel `lib/core/design/design.dart`)。
- Prefer Forui primitives directly. Don't add thin wrappers that only preset styles;
  existing wrappers (`AppBackButton`, `AppDivider`, etc.) are kept as-is.
- Prefer `FLucideIcons` over Material icons (treat `Icons.*` as migration debt).
- Evaluate `forui_hooks` before writing manual controller plumbing.
- Use Forui CLI (`dart run forui style create`) for custom styling scaffolds.
- User-visible text goes through ARB + `flutter gen-l10n` — no hardcoded strings.
- Page-level error states use `AppStateErrorView` / `AppStateMessageView`, never
  hand-written error views.
- Loading states use shimmer skeletons (`AppSkeletonShimmer`), never
  `CircularProgressIndicator` or plain colored blocks.
- Lightweight feedback uses `AppToast`, not page-level `SnackBar`.

## Testing

- Unit/widget: `flutter test`. Integration: `integration_test/`.
- Mock repositories: `Mock*Repository`. Test helpers: `test/helpers/`.
- Tests never launch real device capabilities; inject platform-interface fakes
  (e.g. `PermissionHandlerPlatform`, `MobileScannerPlatform`, `PaddleOcrNativePlatform`).
- **Deferred marker**: still-useful deferred code keeps a comment marker and a TODO entry —
  never fake success in production paths:
  ```dart
  // Deferred by Product Brainstorm P0/P1: keep this code because the capability is useful,
  // but do not surface it until the matching contract/product job is ready.
  ```

## Data Layer

- Repository pattern: `domain/repositories/` interfaces, `data/repositories/` implements.
- Generated API client: `generated/lucent_api/`.

## L10n

**CRITICAL — ARB Editing Workflow**

The source of truth for l10n strings is the fragment files in `lib/l10n/src/`
(e.g., `record_zh.arb`, `mine_en.arb`). The main files `lib/l10n/app_zh.arb`
and `app_en.arb` are **generated** by merging these fragments — **never edit
them directly**.

Correct workflow when adding or modifying any user-visible string:

1. Edit the fragment file(s) in `lib/l10n/src/`
2. Run `dart scripts/arb_tools.dart merge` to regenerate `app_zh.arb` / `app_en.arb`
3. Run `flutter gen-l10n` to regenerate Dart localization code

Direct edits to `app_zh.arb` / `app_en.arb` **will be lost** on the next merge.

- Run `dart run scripts/bootstrap_generated_sources.dart` after fresh clone or
  ARB / contract changes (includes the merge + gen-l10n + build_runner above).

## OpenAPI Client

- Source: `Lucent/docs/openapi.json`.
- Regenerate: `pnpm export:openapi` in Lucent → `dart run scripts/bootstrap_generated_sources.dart` in Luminous.
- Tracked boundary: `generated/lucent_api/lib/api/**` except `**/*.g.dart`.

## Non-Negotiable Boundaries

- This is a Flutter + Riverpod + GoRouter + Forui project.
- Lucent owns shipping assistant/report AI backends; `lib/core/ai/` is an
  experiment seam, not the place to replace current Lucent production flows by default.
- Fix the requested problem directly — do not loosen lint rules or refactor nearby
  working code.
- Do not touch unrelated dirty or untracked files in sibling projects.
- Do not hand-edit generated files (`lib/l10n/app_localizations*.dart`,
  `generated/lucent_api/**`, merged `app_*.arb`).
