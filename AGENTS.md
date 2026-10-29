# AGENTS.md - Luminous

## Documentation Rules

The doc-freshness advisory `dart run scripts/docs/verify.dart` prints stale
`status: active` docs (front-matter `updated` >90 days, unarchived
`status: stale`) and never blocks. The code→docs coverage mapping
(doc-map.yaml and the pre-commit doc-touch report) was retired on
2026-09-15 after its two-week observation window (tracked in `docs/TODO.md`).
Structural guarantees live in `--verify` (pre-push / daily): doc link
integrity, front-matter completeness, 90-day freshness, doc readership, and
`lib/features/*` README coverage. The migration-log overwrite check in
pre-commit still blocks.

### Standing rules

- **Migration log**: append a dated entry to `docs/logs/migration-log/YYYY-MM-DD.md`.
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
- **Closing a TODO**: delete the line from `docs/TODO.md`.
- **Finishing a plan**: delete the entire section from `plans/*.md`.
- **Doc lifecycle**: active docs older than 90 days without updates, or not
  linked from any other doc, are flagged by `dart run scripts/docs/verify.dart --verify`
  — review, update, or archive them to `docs/archive/`. Docs marked `status: frozen` are
  exempt from the 90-day freshness checks.
- **Front-matter**: every active content doc must carry YAML front-matter
  (`status: active|frozen` / `owner: frontend` / `updated: YYYY-MM-DD`);
  `--verify` flags missing blocks, stale `updated`, and `status: stale` docs not yet archived.
  `status: frozen` marks a doc intentionally frozen (desktop/Web-freeze, feature-freeze) —
  exempt from the freshness checks but still must carry valid front-matter; `status: stale`
  means the doc should be archived, not frozen.
- **Visible text/l10n change**: sync `docs/reference/localization.md`.
- Completed items are **deleted** outright — no markers.

## Stack

- Flutter, Riverpod (not GetX), GoRouter (not `Navigator.push(MaterialPageRoute(...))`).
- Backend: Lucent.
- 目标平台：`android` / `ios` / `windows` / `macos` / `linux` / `web` / `ohos`（鸿蒙壳：
  `ohos/` 内嵌 Web 制品，流水线 `.github/workflows/deploy-harmonyos.yml`）。
- 本地存储：原生平台 drift + **SQLCipher 加密**（密钥在平台安全存储）；Web 端不加密；
  键值偏好走 `hive_ce`（`lib/core/storage/kv_store.dart`）。

## Commands

```powershell
flutter pub get                                  # 拉取依赖
flutter analyze                                  # 最快反馈
flutter test                                     # 单元/Widget 测试
flutter test test/path/to_test.dart              # 单个测试文件
flutter test integration_test                    # 全部 E2E
flutter test integration_test/<scenario>_e2e_test.dart   # 单个 E2E 场景
dart scripts/l10n/arb_tools.dart merge                # 分片 ARB 合并(l10n 变更后)
flutter gen-l10n                                 # ARB 合并后生成 Dart 本地化代码
dart run scripts/contract/bootstrap.dart        # 生成物准备(全新 clone/ARB/契约变更后必跑)
dart run scripts/docs/generate.dart               # 再生成 reference/generated 清单(token/路由/feature 变更后)
dart run scripts/workflows/daily.dart           # 仓库安全级检查(analyze+test+文档+生成文档新鲜度)
dart run scripts/workflows/fullstack.dart       # 全栈检查(需 Lucent 运行时)
dart run scripts/docs/verify.dart               # 文档新鲜度通报(--verify 全量治理)
Push-Location tool/luminous_lints; dart run bin/luminous_lints.dart; Pop-Location   # 观察模式八条规则(warn，永远 exit 0)
Push-Location tool/luminous_lints; dart run bin/luminous_lints.dart --clean-layers --quiet; Pop-Location   # 分层门禁 R1–R9(违规 exit 1)
```

窄命令迭代，收尾前跑宽检查(`scripts/workflows/daily.dart`)。

## Architecture

架构是 **DDD-lite + Clean**，由 `luminous_lints --clean-layers` 强制执行（见下节）。
叙述文档：`docs/reference/architecture.md`、`docs/reference/data-layer.md`、
`docs/reference/state-management.md`。

- `lib/app/` — 组合根：`bootstrap.dart`、`router.dart`、`auth_session_adapter.dart`、
  `push_handlers.dart`、`sync_handlers.dart`、`settings_adapters.dart`，以及
  `composition/**`（provider 装配、跨 feature 接线、快照 hub 出口）。
- `lib/core/` — 横切基础设施：`network`（唯一网络入口）、`database`（drift）、`storage`、
  `design`、`widgets`、`i18n`、`router`、`logger`、`providers`、`feedback`、`forms`、`errors`、
  `config`、`accessibility`、`analytics`、`notifications`、`push`、`native`、`shortcuts`、
  `ai`、`theme`、`utils`。
- `lib/shared/` — 共享内核：`domain/failure.dart`（failure 词汇）、`domain/semantic.dart`、
  `design/`（跨 feature 视图令牌）。纯值类型，无 I/O。
- `lib/features/{feature}/` — 按 feature 的垂直切片，四层各有严格依赖方向：
  - `domain/` — 纯 Dart：只允许 `fpdart` / `freezed_annotation` / `meta` / `clock`、
    同 feature 的 `domain/`，以及 `lib/shared/domain/` 共享内核（纯值类型与 failure 词汇）。
    实体、repository 接口、纯规则服务、常量。
  - `application/` — use case（函数式）与 orchestrator（类式）：只允许 `domain/`
    （**含别的 feature 的 domain 接口/实体**，用于跨 feature 编排）、`lib/shared/domain/`
    与纯 Dart 包。不出现 `Ref` / `BuildContext` / 导航 / Toast。
  - `data/` — repository 实现、datasource、mapper、`@riverpod` 装配。只允许同 feature 的
    `domain/`、自身层，以及 `core/network` / `core/database` / `core/storage` / `lib/shared/`。
  - `presentation/` — pages / widgets / providers / controllers / utils。只允许同 feature 的
    `application/` + `domain/`、自身层、纯 UI 的 `core/` 子树与 `lib/app/composition`；
    **import `data/` 永远违规**。
- 依赖方向：`presentation → application → domain`；`data → domain`（实现接口）。
  组合根在 `lib/app/composition/`，把 data 实现注入 domain 接口。
- New code goes only under `lib/features/`, `lib/core/`, or `lib/shared/`. **Do not**
  add to legacy `lib/pages/`, `lib/stores/`, `lib/viewmodels/`, `lib/components/`.
- The five tabs are `today / record / medicine / review / mine`.

### Layering Rules（`--clean-layers`，R1–R9，无白名单）

```powershell
cd tool/luminous_lints; dart run bin/luminous_lints.dart --clean-layers --quiet
```

违规即 exit 1。pre-push（`scripts/hooks/git.dart`）、`scripts/workflows/daily.dart`、CI
都跑同一条命令（CI 在架构清理期带 `continue-on-error`，本地推送是真门禁）。

| 规则 | 约束 |
| --- | --- |
| `domain_purity` | `domain/**` 只允许 `dart:*` + `fpdart`/`freezed_annotation`/`meta`/`clock` + 同 feature `domain/` + `lib/shared/domain/`；**框架/插件包**（`flutter_riverpod`/`dio`/`drift`/`permission_handler`/`flutter_local_notifications`/`path_provider`/`hive_ce`）由 CLI 的文本级检查补充拦截 |
| `application_layer` | `application/**` 只允许 `domain/`（含别的 feature 的 domain）+ `lib/shared/domain/` + 纯 Dart 包 |
| `data_layer` | `data/**` 只允许同 feature `domain/`、自身层、`core/network`、`core/database`、`core/storage`、`lib/shared/` |
| `presentation_layer` | `presentation/**` 只允许同 feature `application/`+`domain/`、自身层、纯 UI 的 `core/` 子树（`design`/`widgets`/`i18n`/`feedback`/`utils`/`theme`/`logger`/`providers`/`accessibility`/`config`/`errors`/`forms`/`router`/`ai` + `l10n/` + `app/router` + `app/composition` + `app/auth_session_adapter.dart` + `lib/shared/`）；**import `data/` 永远违规** |
| `core_not_import_features` | `lib/core/**` 不得 import `lib/features/**`（旧 `core/auth`、`core/push` 豁免已取消） |
| `cross_feature_import` | 不得 import 别的 feature 的 `data/**` 或 `presentation/**`；跨 feature 读走对方 `domain/` |
| `directory_file_cap` | 单目录直挂源文件 **≤ 8**（生成文件不计） |
| `forbidden_directory` | 禁止 `presentation/services/`、`data/providers/`、`presentation/flows/` |

口径差异（待对齐）：观察模式的 `layered_import` 允许 providers 接缝与 `shell` 外壳，
`cross_feature_import` 目前两项都不允许——后者更严。按
`plans/2026-10-28-composable-tabs.md` A0 收敛到前者口径，届时以本文件为准同步。

### Cross-Feature Import Rules

1. **data → data prohibited** — a feature's `data/` layer must not import another feature's
   `data/` layer. Use domain interfaces (`domain/repositories/`) instead.
2. **presentation → presentation prohibited** — a feature's `presentation/` layer must not
   import another feature's `presentation/` providers. Use domain entities, the shared
   snapshot hub (`healthContextSnapshotProvider`), or the DataChangeBus.
3. **application → domain allowed** — the `application/` layer may import other features'
   `domain/` layer (interfaces + entities) for cross-feature orchestration.

这三条禁令由 `layered_import`（观察模式）扫描；严格分层由 `--clean-layers` 的
`cross_feature_import` 扫描（见 §Layering Rules）。feature 间消费 domain 公共接缝是
sanctioned 形态。两组规则对 providers 接缝的口径目前不一致，见 §Layering Rules 末段。

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
8. **Directory file-count cap** — a directory holding more than **8** direct source files
   (generated files excluded) is a gate violation (`directory_file_cap`, §Layering Rules).
   Split into subdirectories instead of exempting; there is no whitelist.

## State Management

- Riverpod `Notifier` + `NotifierProvider`; `@freezed` for immutable state.
- `ref.watch()` for reading, `ref.read()` for callbacks.
- Prefer `ref.watch(provider.select(...))` to slice state and avoid unnecessary rebuilds.
- Provider 放置：跨 feature 装配与注入放 `lib/app/composition/**`；feature 内读模型放
  `presentation/providers/`。`domain/` 与 `application/` 里不出现 Riverpod 类型。

## Routing

- `GoRouter` with `StatefulShellRoute` for bottom tabs. Use typed routes
  (`@TypedGoRoute` + `go_router_builder`).
- Tab roots: `/`, `/record`, `/medicine`, `/review`, `/mine`.
- Sub-pages are top-level full-screen routes outside the shell.

## Design System

Forui-led theming. Details in `docs/reference/design-system.md` and
`docs/reference/forui-reference.md`. Reference in `D:\25080\Documents\VSCodeProject\Lumos\forui-docs`

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
- **自定义规则两组(`tool/luminous_lints`)**，命令见 Commands：
  - **观察模式八条** — 默认 warn、永远 exit 0，`--fatal` 才阻断；清单见下节。
    观察期收敛后按计划逐条转 error。
  - **分层门禁九条（R1–R9）** — `--clean-layers` 模式下违规即 exit 1，无白名单；
    pre-push、`scripts/workflows/daily.dart`、CI 都跑同一条（CI 带 `continue-on-error`）。
    清单见 §Layering Rules。
  - 规则包自身测试 `cd tool/luminous_lints && dart test`。当前未接入 IDE 插件（analyzer
    版本与 analysis server 不一致，接入待主包升级后重评）。
- `analysis_options.yaml` 中 `avoid_print` / `unawaited_futures` / `discarded_futures` /
  `use_build_context_synchronously` 以 **error 级**生效(基线 0 违规);豁免必须在
  代码行内附理由注释。
- **测试承接约定**：UI 现状断言一律写 golden/widget 测试,不写进文档；e2e 不硬编码
  内部 ID。
- **Deferred marker**: still-useful deferred code keeps a comment marker and a TODO entry —
  never fake success in production paths:
  ```dart
  // Deferred by Product Brainstorm P0/P1: keep this code because the capability is useful,
  // but do not surface it until the matching contract/product job is ready.
  ```

### Custom Lint Rules(`tool/luminous_lints`)

**观察模式八条**的一句话清单(默认 warn,`--fatal` 才作门禁;规则细节见
`tool/luminous_lints/lib/src/`)。分层门禁 R1–R9 见 §Layering Rules。**扫描范围排除生成文件**(`*.g.dart` /
`*.freezed.dart`):它们是 gitignored 的 build_runner 产物,报在它们上面既无法靠改代码
消除,也会随生成器版本漂移——按上文"不得手改生成文件"的口径,规则同样不报。

- `no_direct_navigator` — 直接使用 Material `Navigator.*` 做**路由**导航(GoRouter 是唯一
  导航入口)。白名单 `lib/core/router/` 与 `lib/features/shell/`;**弹层关闭**
  (`pop` / `maybePop`,含 `Navigator.of(...)` 取到的 `NavigatorState` 句柄,以及围绕它的
  `canPop()` 守卫)是既有惯用法、GoRouter 无对应能力,规则不报;`push`/`pushNamed`/
  `pushReplacement` 等路由导航一律照报。
- `first_where_requires_or_else` — 无 `orElse` 的 `firstWhere` 在无匹配时抛
  `StateError`;提供 `orElse` 即通过。
- `no_bang_on_response_data` — data 层 `!` 强解包(典型 `response.data!`),坏 payload
  必须映射为 domain failure;仅扫描含 `/data/` 的路径,presentation 层不适用。
- `empty_catch_requires_comment` — 空 catch 块静默吞错;块内有注释、日志或 rethrow
  即通过。注意 `onError: (_) {}` 形态不在覆盖内,评审时需人工把关。
- `enum_parse_unknown_branch` — enum switch **语句**缺 fallback 分支;仅扫描**服务端来源**
  的枚举(即生成客户端 `package:lucent_api/` 的枚举,服务端可能返回本客户端未见过的新值),
  且须含 `unknown` / `unknownDefaultOpenApi` 分支或 `_`/`default`。本仓自有枚举是白盒:
  调用点与枚举一起编译,漏分支会在编译期暴露,补 `default` 反而变成吞掉新值的死代码,
  规则不报。Dart 3 switch 表达式豁免(编译器保证穷尽)。
- `no_raw_datetime_parse` — 裸 `DateTime.parse` 在畸形输入上抛 `FormatException`;
  改用 `parseDateTimeOrNull` / `parseDateTimeOrEpoch`(`lib/core/utils/date_format.dart`)。
- `layered_import` — 跨 feature 的 data→data 与 presentation→presentation 禁令
  (与上文 Cross-Feature Import Rules 一一对应);feature 间消费 domain/provider
  公共接缝是 sanctioned 形态,规则不报。子规则 2 有两处显式豁免,与上文口径对齐:
  **presentation/provider 接缝**(任何 `.../presentation/providers/...`)与
  **shell 基础设施**(`features/shell/presentation/`,所有 tab root 共用的外壳);
  跨 feature 的普通 presentation widget/page 仍照报。豁免只作用于子规则 2,
  `core → feature` 不受影响。
- `non_shrinking_row_child` — `Row` 里同时出现文本(`Text`/`Expanded`/`Flexible`)与
  **非 flex 的固有宽度组件**(`FBadge` / `PillChip` / `TintedStatusBadge` / `FButton`
  或名字匹配 `_?\w*(Badge|Chip|Pill|Tag)\w*` 的本地组件):`RenderFlex` 先给非 flex 子节点
  无界主轴约束,它们会占满固有宽度,把文字挤成多行或直接右溢出(真机 360dp + 大字号
  必现)。改成 `Wrap`(放不下自动换行)或把尾部组件包进 `Flexible`,并对按钮/徽章标签加
  `maxLines: 1` + `overflow: ellipsis`。`Wrap`/`OverflowBar`、尾部已 `Flexible`/
  `Expanded`/限宽 `ConstrainedBox` 的形态不报。

## Data Layer

- Repository pattern：`domain/repositories/` 接口 + `data/repositories/` 实现。
- **cache-first（ADR-0006）**：先读本地（drift / KV），命中即返回并节流后台刷新、刷新结果
  写回缓存。新增 repository 默认按此模式；跳过缓存必须在代码里写清理由。
- 装配：`@riverpod` 的 repository provider 与实现同文件（`data/repositories/*.dart`）；
  presentation 通过该 feature 的 `presentation/providers/data_access.dart` 再导出访问，
  **不直接 import `data/`**。`data/providers/` 目录已废弃并被门禁禁止。
- 跨 feature 读：共享快照 hub（`healthContextSnapshotProvider`）、DataChangeBus
  （`lib/core/providers/instrumentation/data_change_bus.dart`）或对方 `domain/` 接口。
- 离线写队列：`pending_sync_queue` + `SyncWorker`（`lib/core/database/sync/`），
  handler 在 `lib/app/sync_handlers.dart` 注册。
- 本地库：原生平台 drift + SQLCipher（`lib/core/database/connection_io.dart`），Web 端
  `connection_web.dart` 为未加密实现——跨端差异在 repository 之上不可见。
- Generated API client: `generated/lucent_api/`.

## L10n

**CRITICAL — ARB Editing Workflow**

The source of truth for l10n strings is the fragment files in `lib/l10n/src/`
(e.g., `record_zh.arb`, `mine_en.arb`). The main files `lib/l10n/app_zh.arb`
and `app_en.arb` are **generated** by merging these fragments — **never edit
them directly**.

Correct workflow when adding or modifying any user-visible string:

1. Edit the fragment file(s) in `lib/l10n/src/`
2. Run `dart scripts/l10n/arb_tools.dart merge` to regenerate `app_zh.arb` / `app_en.arb`
3. Run `flutter gen-l10n` to regenerate Dart localization code

Direct edits to `app_zh.arb` / `app_en.arb` **will be lost** on the next merge.

- Run `dart run scripts/contract/bootstrap.dart` after fresh clone or
  ARB / contract changes (includes the merge + gen-l10n + build_runner above).

## OpenAPI Client

- Source: `Lucent/docs/reference/generated/openapi.json`.
- Regenerate: `pnpm export:openapi` in Lucent → `dart run scripts/contract/bootstrap.dart` in Luminous.
- Tracked boundary: `generated/lucent_api/lib/api/**` except `**/*.g.dart`.

## Non-Negotiable Boundaries

- This is a Flutter + Riverpod + GoRouter + Forui project.
- Lucent owns shipping assistant/report AI backends; `lib/core/ai/` is an
  experiment seam, not the place to replace current Lucent production flows by default.
- Fix the requested problem directly — do not loosen lint rules or refactor nearby
  working code.
- `domain/` 保持零框架依赖（`domain_purity`）；不要在 `data/` 下新建 provider 目录。
- 不得用逐文件白名单绕过 `--clean-layers` 门禁；口径要改就改规则本身并同步本文件。
- Do not touch unrelated dirty or untracked files in sibling projects.
- Do not hand-edit generated files (`lib/l10n/app_localizations*.dart`,
`generated/lucent_api/**`, merged `app_*.arb`, `docs/reference/generated/**`).
- Generated docs follow the region convention: generators rewrite only the
`<!-- gen:<name>:start/end -->` block; content outside the region is handwritten
and never overwritten. Regenerate with `dart run scripts/docs/generate.dart`.
Stale generated docs fail `scripts/workflows/daily.dart` and CI.
