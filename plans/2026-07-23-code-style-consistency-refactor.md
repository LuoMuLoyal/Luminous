# Luminous 代码风格一致性重构计划

> 创建日期：2026-07-23
> 状态：待实施
> 涉及仓库：Luminous

---

## 一、背景

基于 2026-07-23 的全量代码风格审查，Luminous 在 `flutter analyze` 层面已无 lint 问题，
但仍有 7 类文件级/架构级风格不一致。这些问题不影响运行时行为，但会导致新开发者
难以判断"正确写法"，长期积累会稀释 AGENTS.md 规范的权威性。

本次重构目标：**消除所有已识别的风格偏差，使代码库与 AGENTS.md 规则 100% 对齐**。

---

## 二、审查发现汇总

| #   | 类别                                                                        | 严重度 | 涉及文件数       | 状态   |
| --- | --------------------------------------------------------------------------- | ------ | ---------------- | ------ |
| 1   | 文件命名违规（`_provider`/`_repository`/`_controller`/`_service` 后缀冗余） | P0     | 8                | 待修复 |
| 2   | `shared_widgets.dart` 巨型混合文件                                          | P0     | 1（含 7 个类）   | 待拆分 |
| 3   | `FCircularProgress` 在页面级加载状态中使用                                  | P1     | 6 文件 / 12 处   | 待清理 |
| 4   | 网络层硬编码中文字符串                                                      | P1     | 4 文件 / 11 处   | 待重构 |
| 5   | `AppDivider` 薄包装评估                                                     | P2     | 1                | 待决策 |
| 6   | Magic Number 间距（未使用 `Spacing.*` token）                               | P2     | ~7 文件 / ~15 处 | 待修复 |
| 7   | `shell/page.dart` l10n 硬编码 fallback                                      | P2     | 1 文件 / 2 处    | 待修复 |

### 已确认合规项（无需改动）

- 无 GetX 导入
- 无 `MaterialPageRoute`（页面导航）
- 无 Material `CircularProgressIndicator`
- 无 `SnackBar`（统一使用 `Toast`）
- 无 Material `Icons.*`（全量 `FLucideIcons`）
- 无 legacy 目录（`lib/pages/`、`lib/stores/`、`lib/viewmodels/`、`lib/components/`）
- 无 `ChangeNotifier`（统一 Riverpod）
- `flutter analyze` 0 issues
- GoRouter + `StatefulShellRoute` + `go_router_builder` typed routes
- Riverpod `Notifier` + `NotifierProvider` + `@freezed`
- ARB fragment 工作流（未直接编辑 `app_*.arb`）

### 已确认可接受项（无需改动）

- **`Navigator.of(context).pop()` 在对话框中的使用**（settings、scan 等 ~10 处）：
  这是 Flutter 对话框标准 `showFDialog` → `Navigator.pop(result)` 模式，
  属于对话框返回值机制，不是页面导航。AGENTS.md 禁止的是
  `Navigator.push(MaterialPageRoute(...))` 页面导航，不涉及对话框 pop。

---

## 三、技术方案

### 3.1 P0-A — 文件命名修复（8 个文件）

#### 规则回顾

> AGENTS.md File Naming Rules:
>
> 1. No type-suffix when the directory conveys the type — `_provider`, `_page`, `_widget`,
>    `_section`, `_data_source`, `_repository` are redundant.
> 2. Never use a pure type word (`provider.dart`, `repository.dart`). Add a business word.
> 3. No directory-name prefix on files inside that directory.

#### 文件清单与修正方案

| #   | 当前路径                                                      | 问题                                                                | 修正后路径                                            | 涉及 import 更新文件数 |
| --- | ------------------------------------------------------------- | ------------------------------------------------------------------- | ----------------------------------------------------- | ---------------------- |
| 1   | `settings/presentation/providers/profile_sync_provider.dart`  | `_provider` 后缀冗余（`providers/` 已传达类型）                     | `settings/presentation/providers/profile_sync.dart`   | 2                      |
| 2   | `core/database/cache_cleanup_provider.dart`                   | 同上                                                                | `core/database/cache_cleanup.dart`                    | 1                      |
| 3   | `scan/data/scan_repository.dart`                              | ① `_repository` 后缀冗余 ② 位于 `data/` 根而非 `data/repositories/` | `scan/data/repositories/scan.dart`                    | 2                      |
| 4   | `record/presentation/controllers/nlp_controller.dart`         | `_controller` 后缀冗余（`controllers/` 已传达类型）                 | `record/presentation/controllers/nlp.dart`            | 4                      |
| 5   | `settings/data/services/notification_permission_service.dart` | `_service` 后缀冗余（`services/` 已传达类型）                       | `settings/data/services/notification_permission.dart` | 4                      |
| 6   | `scan/domain/services/ocr_service.dart`                       | 同上                                                                | `scan/domain/services/ocr.dart`                       | 2                      |
| 7   | `record/domain/services/voice_recording_service.dart`         | 同上                                                                | `record/domain/services/voice_recording.dart`         | 1                      |
| 8   | `auth/presentation/services/wechat_oauth_service.dart`        | 同上                                                                | `auth/presentation/services/wechat_oauth.dart`        | 2                      |

> **注意**：每个文件都有对应的 `.g.dart` 或 `.freezed.dart` 生成文件。
> 重命名源文件后必须重新运行 `dart run build_runner build --delete-conflicting-outputs`
> 以重新生成 part 文件路径。

#### 边界情况 — `core/theme/theme_controller.dart`

文件 `core/theme/theme_controller.dart` 位于 `core/theme/` 目录：

- **Rule 1**：`theme/` 目录不传达 "controller" 类型，因此 `_controller` 后缀本身不违规。
- **Rule 3**：`theme_` 前缀与目录名 `theme/` 重复，**违规**。
- **Rule 2**：如果仅命名为 `controller.dart`，是纯类型词，**也违规**。
- **结论**：需使用业务词。文件主要实体是 `ThemePreference`，命名为 `preference.dart`。

| #   | 当前路径                           | 修正后路径                   | 涉及 import 更新文件数 |
| --- | ---------------------------------- | ---------------------------- | ---------------------- |
| 9   | `core/theme/theme_controller.dart` | `core/theme/preference.dart` | 5                      |

#### 操作步骤

每个文件的改名流程一致：

1. `git mv` 源文件到新路径（保留 git 历史）
2. 更新源文件内部的 `part 'xxx.g.dart'` 声明（如果有）
3. 全局搜索更新所有 `import ...old_name.dart` 为新路径
4. 如果文件中有 `@riverpod` 注解生成 `.g.dart`，改 part 声明
5. 完成所有 9 个文件后，统一运行：
   ```powershell
   cd Luminous
   dart run build_runner build --delete-conflicting-outputs
   flutter analyze
   ```

#### 受影响文件完整清单（import 更新）

以下是每个改名文件需要更新 import 的消费方文件：

- **`profile_sync.dart`**（← `profile_sync_provider.dart`）：
  - `settings/presentation/pages/language.dart`
  - `settings/presentation/pages/advanced.dart`

- **`cache_cleanup.dart`**（← `cache_cleanup_provider.dart`）：
  - `app/bootstrap.dart`

- **`scan/data/repositories/scan.dart`**（← `scan/data/scan_repository.dart`）：
  - `scan/presentation/pages/box_scan.dart`
  - `scan/presentation/pages/barcode_scanner.dart`

- **`nlp.dart`**（← `nlp_controller.dart`）：
  - `record/presentation/widgets/dialogs/nlp_dialog.dart`
  - `record/presentation/widgets/nlp/nlp_candidate_review.dart`
  - `record/presentation/widgets/nlp/nlp_candidate_editor.dart`
  - `record/presentation/pages/page.dart`

- **`notification_permission.dart`**（← `notification_permission_service.dart`）：
  - `settings/presentation/pages/notification.dart`
  - `settings/presentation/providers/notification.dart`
  - `settings/data/providers/notification_permission.dart`
  - `medicine/presentation/providers/reminder_notification_coordinator.dart`

- **`ocr.dart`**（← `ocr_service.dart`）：
  - `scan/presentation/pages/box_scan.dart`
  - `record/presentation/widgets/dialogs/ocr_entry_dialog.dart`

- **`voice_recording.dart`**（← `voice_recording_service.dart`）：
  - `record/presentation/widgets/dialogs/voice_entry_dialog.dart`

- **`wechat_oauth.dart`**（← `wechat_oauth_service.dart`）：
  - `auth/presentation/providers/oauth_login.dart`
  - `auth/presentation/providers/account.dart`

- **`preference.dart`**（← `theme_controller.dart`）：
  - `settings/presentation/utils/theme_preference_labels.dart`
  - `settings/presentation/pages/page.dart`
  - `settings/presentation/pages/theme.dart`
  - `settings/presentation/pages/advanced.dart`
  - `app/bootstrap.dart`

---

### 3.2 P0-B — `shared_widgets.dart` 拆分

#### 当前状态

文件 `core/widgets/common/shared_widgets.dart` 包含 7 个职责不相关的类/函数：

| 类/函数                         | 使用范围                                  | 应归属                                                               |
| ------------------------------- | ----------------------------------------- | -------------------------------------------------------------------- |
| `VerificationCodeField`         | 仅 auth（5 页面）                         | → `auth/presentation/widgets/shared/verification_code_field.dart`    |
| `MineEditFormLoading`           | 仅 mine（4 页面）                         | → `mine/presentation/widgets/shared/mine_edit_form_loading.dart`     |
| `SettingsSectionLabel`          | 仅 settings                               | → `settings/presentation/widgets/shared/settings_section_label.dart` |
| `settingsPageVerticalPadding()` | 仅 settings                               | → `settings/presentation/utils/settings_page_padding.dart`           |
| `SheetDragHandle`               | 多 feature（record/report/mine/medicine） | → `core/widgets/common/sheet_drag_handle.dart`                       |
| `SoftIcon`                      | 多 feature                                | → `core/widgets/common/soft_icon.dart`                               |
| `IconActionButton`              | 多 feature                                | → `core/widgets/common/icon_action_button.dart`                      |

#### 拆分方案

**Step 1 — 迁移 feature-specific 组件**

将 `VerificationCodeField`、`MineEditFormLoading`、`SettingsSectionLabel`、
`settingsPageVerticalPadding()` 分别移入对应 feature 目录。

迁移后更新消费方的 import 路径：

- `VerificationCodeField` 消费方（5 文件）：
  - `auth/presentation/pages/login.dart`
  - `auth/presentation/pages/register.dart`
  - `auth/presentation/pages/forgot_password.dart`
  - `auth/presentation/pages/change_email.dart`
  - `auth/presentation/pages/account_settings_sections.dart`

- `MineEditFormLoading` 消费方（4 文件）：
  - `mine/presentation/pages/profile_edit.dart`
  - `mine/presentation/pages/allergy_edit.dart`
  - `mine/presentation/pages/condition_edit.dart`
  - `mine/presentation/pages/current_medicine_edit.dart`

- `SettingsSectionLabel` + `settingsPageVerticalPadding()` 消费方（10 文件）：
  - 所有 `settings/presentation/pages/*.dart`（accessibility, feature_flags, page,
    security_pin, theme, notification, dnd, data_storage, ai, advanced）

**Step 2 — 拆分 core 通用组件**

将 `SheetDragHandle`、`SoftIcon`、`IconActionButton` 从 `shared_widgets.dart`
拆为独立文件。更新消费方的 import（约 12 文件引用 `shared_widgets.dart` 中的这三个类）。

**Step 3 — 删除 `shared_widgets.dart`**

确认无残留 import 后删除该文件。如果仍有少量类不便归类，可保留文件并改名，
但目标是完全消除这个"杂物抽屉"。

#### 受影响文件汇总

约 26 个文件需要更新 import 路径（auth 5 + mine 4 + settings 10 + core 通用组件消费者约 7）。

---

### 3.3 P1-A — `FCircularProgress` 页面级加载清理

#### 当前状态

`FCircularProgress` 是 Forui 组件（非 Material `CircularProgressIndicator`），
在按钮级和对话框级短期加载中使用是合理的。但在**页面级加载**中使用违反了
AGENTS.md "Loading states use shimmer skeletons" 的规则。

#### 需清理的页面级用法

| #   | 文件                                                             | 行       | 场景                                                   | 修正方案                                                                |
| --- | ---------------------------------------------------------------- | -------- | ------------------------------------------------------ | ----------------------------------------------------------------------- |
| 1   | `core/widgets/common/page_state.dart`                            | 259      | `_DefaultLoadingView` — `PageStateSwitch` 默认 loading | 提供基于 skeleton 的默认 loading，或要求各页面自行提供 `loadingBuilder` |
| 2   | `report/presentation/pages/clinic_summary_shared.dart`           | 47       | `loading: () => FCircularProgress()`                   | → skeleton view                                                         |

**修正说明**：原计划中 #3–#5 经代码审查确认为**按钮级加载**（`FCircularProgress` 在 `FButton` 内作为 `prefix`/`child`），属于可接受用法，无需修改。

#### 可接受的用法（保留不动）

| 文件                                                                     | 行            | 场景                 | 保留理由                        |
| ------------------------------------------------------------------------ | ------------- | -------------------- | ------------------------------- |
| `report/presentation/widgets/dialogs/clinic_summary_preview_dialog.dart` | 84            | 对话框内 loading     | 对话框短期加载，skeleton 不合适 |
| `settings/presentation/pages/security_pin.dart`                          | 206, 301, 360 | PIN 验证按钮 loading | 按钮级短期加载                  |
| `scan/presentation/pages/box_scan.dart`                                  | 173           | 扫描全屏覆盖层       | 相机预览覆盖层                  |
| `today/presentation/widgets/sections/suggestion_interactive.dart`        | 199           | 交互按钮 loading     | 按钮级                          |
| `core/widgets/common/shared_widgets.dart`                                | 57            | 验证码按钮 loading   | 按钮级                          |

#### 规则建议

在 AGENTS.md Design System 节中补充明确边界：

> - **页面级加载**（首次数据加载、页面切换 loading）→ 必须使用 shimmer skeleton
> - **按钮级加载**（提交中、验证中）→ 可使用 `FCircularProgress`
> - **对话框级加载**（对话框内短期等待）→ 可使用 `FCircularProgress`

---

### 3.4 P1-B — 网络层硬编码中文消除

#### 当前状态

网络层（`core/network/`）无 `BuildContext`，无法直接访问 l10n。当前用硬编码中文字符串
作为错误消息，违反 "no hardcoded strings" 规则。

#### 涉及文件

| 文件                                               | 行     | 硬编码消息                     |
| -------------------------------------------------- | ------ | ------------------------------ |
| `core/network/envelope.dart`                       | 26, 77 | `'请求失败（code: $code）'`    |
| `core/network/sse.dart`                            | 96     | `'流式响应为空，请稍后再试。'` |
| `core/network/map_utils.dart`                      | 49     | `'请求失败，请稍后再试。'`     |
| `core/network/interceptors/error_interceptor.dart` | 51-58  | 8 条网络错误消息               |

#### 重构方案

引入错误码枚举 + 表示层 l10n 映射：

**Step 1 — 定义 `NetworkErrorCode` 枚举**

在 `core/network/` 新建 `error_code.dart`：

```dart
/// 网络层错误码，用于在表示层映射 l10n 字符串。
///
/// 网络层抛出 [LucentApiException] 时携带此枚举而非硬编码消息文本。
enum NetworkErrorCode {
  /// 业务码非零（{code, message, data} envelope 的 code != 0）
  businessFailure,

  /// 流式响应为空
  emptyStreamResponse,

  /// 响应体为空
  emptyResponse,

  /// 连接超时
  connectionTimeout,

  /// 请求发送超时
  sendTimeout,

  /// 响应接收超时
  receiveTimeout,

  /// 服务器证书校验失败
  badCertificate,

  /// 网络连接失败
  connectionError,

  /// 请求已取消
  cancelled,

  /// HTTP 状态码错误
  badResponse,

  /// 未知网络错误
  unknown,
}
```

**Step 2 — 扩展 `LucentApiException`**

在 `LucentApiException` 中增加 `NetworkErrorCode? networkErrorCode` 字段，
网络层抛异常时填充此字段而非硬编码消息。

**Step 3 — 表示层 l10n 映射**

在 `core/widgets/common/` 或 `core/errors/` 新建 `network_error_l10n.dart`：

```dart
String mapNetworkErrorCode(NetworkErrorCode code, AppLocalizations l10n) {
  return switch (code) {
    NetworkErrorCode.businessFailure => l10n.networkErrorBusinessFailure,
    NetworkErrorCode.emptyStreamResponse => l10n.networkErrorEmptyStream,
    // ...
  };
}
```

**Step 4 — ARB fragment 新增**

在 `lib/l10n/src/` 中新建 `network_zh.arb` / `network_en.arb` fragment，
运行 `dart scripts/arb_tools.dart merge` + `flutter gen-l10n`。

**Step 5 — 错误展示页面使用映射**

`StateErrorView` / `Toast` 等在展示网络错误时，检查 `networkErrorCode` 并映射 l10n 文本。

---

### 3.5 P2-A — `AppDivider` 薄包装评估

#### 当前状态

`AppDivider` 仅设置默认颜色（`FColors.border`）和去 padding，是 `FDivider` 的薄包装。
AGENTS.md 规定 "Prefer Forui primitives directly over new `App*` wrappers"。

#### 评估结论

**保留**，理由：

1. 去除默认 padding 是项目级共识，每次手写 `FDividerStyleDelta` 容易遗漏。
2. 统一颜色为 `border` 是设计系统约束，封装可防误用。
3. 该包装有实际行为差异（非零默认值变更），不是零逻辑转发。

---

### 3.6 P2-B — Magic Number 间距修复

#### 当前状态

`Spacing` token scale 为：4 / 6 / 10 / 14 / 20 / 28 / 36 / 44 / 56 / 72 / 96 / 128。
缺少 `8` 和 `12` 这两个常用值，导致部分开发者直接使用硬编码数字。

#### 需修复的文件

| #   | 文件                                                         | 行  | 硬编码               | 修正                               |
| --- | ------------------------------------------------------------ | --- | -------------------- | ---------------------------------- |
| 1   | `record/presentation/widgets/dialogs/fast_entry_dialog.dart` | 53  | `EdgeInsets.all(20)` | → `EdgeInsets.all(Spacing.level5)` |
| 2   | `mine/presentation/widgets/sections/account_hero.dart`       | 237 | `EdgeInsets.all(4)`  | → `EdgeInsets.all(Spacing.level1)` |

#### 需讨论的间距 gap

以下硬编码值在当前 `Spacing` scale 中无精确匹配：

| 值   | 出现位置                                                                                                                                                                       | 选项                                                                                                      |
| ---- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------- |
| `8`  | `shell/presentation/page.dart`、`settings/presentation/pages/page.dart`、`settings/presentation/pages/feature_flags.dart`、`assistant/presentation/widgets/sections/hero.dart` | A: 在 scale 中补充 `level1_5 = 8`；B: 统一替换为最近的 `Spacing.level2`（6px）或 `Spacing.level3`（10px） |
| `12` | `settings/presentation/pages/page.dart`                                                                                                                                        | A: 在 scale 中补充；B: 替换为 `Spacing.level3`（10px）或 `Spacing.level4`（14px）                         |
| `2`  | `assistant/presentation/widgets/shared/proposal_card.dart`                                                                                                                     | 替换为 `Spacing.level1`（4px）或内联为语义化常量                                                          |

**建议方案 B**：不扩展 scale（保持 12 级），统一替换为最近 token。理由：

- 扩展 scale 会增加设计碎片化
- `8` 和 `12` 与现有 `6`/`10`/`14` 差异极小，视觉上无法区分
- 统一替换可消除所有 magic number

#### 操作步骤

1. 逐文件替换硬编码间距为 `Spacing.*` token
2. 运行 `flutter analyze` 确认无新增问题
3. 视觉回归检查（间距变化 ≤ 2px，预期无可见差异）

---

### 3.7 P2-C — `shell/page.dart` l10n 硬编码 fallback

#### 当前状态

文件 `lib/features/shell/presentation/page.dart`，行 156、161：

```dart
label: Text(l10n?.desktopSidebarSettings ?? '设置'),
label: Text(l10n?.desktopSidebarHelp ?? '帮助'),
```

当 `l10n` 为 null 时 fallback 到硬编码中文。

#### 修正方案

确保 `l10n` 始终非空。`ShellPage` 是根级 Widget，在 `MaterialApp` 之下，
`AppLocalizations.of(context)` 应始终可用。将 `l10n?` 改为 `l10n!` 并删除 fallback：

```dart
final l10n = AppLocalizations.of(context)!;
// ...
label: Text(l10n.desktopSidebarSettings),
label: Text(l10n.desktopSidebarHelp),
```

如果存在 `l10n` 确实为 null 的边界情况（如测试），应通过 `Localizations.of` 的
null-safe 模式处理，而非硬编码中文 fallback。

---

## 四、实施步骤与工作量

### P0（约 1-2 工作日）

| 步骤 | 内容                                                            | 工作量 | 依赖                   |
| ---- | --------------------------------------------------------------- | ------ | ---------------------- |
| 1    | 文件命名修复 — 9 个文件 `git mv` + import 更新                  | 0.5d   | 无                     |
| 2    | `dart run build_runner build --delete-conflicting-outputs`      | 0.1d   | Step 1                 |
| 3    | `flutter analyze` 确认 0 issues                                 | 0.1d   | Step 2                 |
| 4    | `shared_widgets.dart` 拆分 — 迁移 feature-specific 组件         | 0.5d   | 无（可与 Step 1 并行） |
| 5    | `shared_widgets.dart` 拆分 — 拆分 core 通用组件                 | 0.25d  | Step 4                 |
| 6    | 删除 `shared_widgets.dart` + import 更新                        | 0.25d  | Step 5                 |
| 7    | `flutter analyze` + `flutter test`                              | 0.1d   | Step 3 + Step 6        |
| 8    | 文档检查 `dart run tool/check_doc_coverage.dart --warning-only` | 0.1d   | Step 7                 |

### P1（约 1-2 工作日）

| 步骤 | 内容                                                     | 工作量 | 依赖               |
| ---- | -------------------------------------------------------- | ------ | ------------------ |
| 9    | `FCircularProgress` 页面级清理 — 5 个文件                | 0.5d   | P0 完成            |
| 10   | 网络层错误码枚举定义 + `LucentApiException` 扩展         | 0.5d   | 无（可与 P0 并行） |
| 11   | 网络层硬编码中文替换为错误码                             | 0.25d  | Step 10            |
| 12   | 表示层 l10n 映射 + ARB fragment 新增                     | 0.5d   | Step 11            |
| 13   | `dart scripts/arb_tools.dart merge` + `flutter gen-l10n` | 0.1d   | Step 12            |
| 14   | `flutter analyze` + `flutter test`                       | 0.1d   | Step 9 + Step 13   |
| 15   | 文档检查                                                 | 0.1d   | Step 14            |

### P2（约 0.5-1 工作日）

| 步骤 | 内容                                          | 工作量 | 依赖              |
| ---- | --------------------------------------------- | ------ | ----------------- |
| 16   | `AppDivider` 评估决策                         | 0.1d   | 无                |
| 17   | Magic number 间距修复 — 确定性替换（2 文件）  | 0.1d   | 无                |
| 18   | Magic number 间距修复 — 讨论后替换（~5 文件） | 0.25d  | Step 17           |
| 19   | `shell/page.dart` l10n fallback 修复          | 0.1d   | 无                |
| 20   | `flutter analyze` + `flutter test`            | 0.1d   | Step 18 + Step 19 |
| 21   | 文档检查                                      | 0.1d   | Step 20           |

---

## 五、验证清单

### P0 验证

- [ ] 9 个文件已重命名到正确路径
- [ ] 所有 import 路径已更新（约 23 个消费方文件）
- [ ] `dart run build_runner build --delete-conflicting-outputs` 无错误
- [ ] `flutter analyze` 零问题
- [ ] `shared_widgets.dart` 已删除
- [ ] 7 个组件已迁移到正确目录
- [ ] 所有消费方 import 已更新（约 26 个文件）
- [ ] `flutter test` 全部通过
- [ ] `dart run tool/check_doc_coverage.dart --warning-only` 无新增缺失

### P1 验证

- [ ] 5 个页面级 `FCircularProgress` 已替换为 skeleton
- [ ] `NetworkErrorCode` 枚举已定义
- [ ] `LucentApiException` 已增加 `networkErrorCode` 字段
- [ ] 4 个网络层文件的硬编码中文已替换为错误码
- [ ] `network_zh.arb` / `network_en.arb` fragment 已创建
- [ ] `dart scripts/arb_tools.dart merge` 成功
- [ ] `flutter gen-l10n` 成功
- [ ] 表示层 l10n 映射函数已实现
- [ ] `flutter analyze` + `flutter test` 通过
- [ ] 文档检查通过

### P2 验证

- [ ] `AppDivider` 保留/移除决策已记录
- [ ] 无 `EdgeInsets.(all|symmetric|only)(\d+)` 硬编码间距
- [ ] 无 `SizedBox(width: \d+)` / `SizedBox(height: \d+)` 硬编码尺寸
- [ ] `shell/page.dart` 无硬编码中文 fallback
- [ ] `flutter analyze` + `flutter test` 通过
- [ ] 文档检查通过

---

## 六、风险与注意事项

### 6.1 `git mv` 保留历史

使用 `git mv` 而非删除+新建，确保 git blame 历史可追溯。对于 `.g.dart` / `.freezed.dart`
生成文件，`git mv` 源文件后删除旧的生成文件，`build_runner` 会在新路径重新生成。

### 6.2 `build_runner` 重建

文件改名后 `part` 声明和生成文件路径会变化。必须在所有改名完成后统一运行一次
`dart run build_runner build --delete-conflicting-outputs`，避免中间状态编译失败。

### 6.3 `shared_widgets.dart` 拆分顺序

先迁移 feature-specific 组件（Step 4），再拆分 core 通用组件（Step 5），
最后删除原文件（Step 6）。如果并行操作可能导致 import 冲突。

### 6.4 网络层 l10n 设计约束

网络层不能依赖 `flutter/widgets.dart`（否则引入循环依赖）。`NetworkErrorCode` 枚举
必须是纯 Dart（无 Flutter 依赖），l10n 映射函数放在表示层（`core/widgets/` 或
`core/errors/`），由调用方在拥有 `BuildContext` 时调用。

### 6.5 文档同步

根据 AGENTS.md 规则，代码变更后需更新：

- `docs/03-logs/migration-log/2026-07-23.md` — 记录本次重构的变更条目
- `docs/00-current/` — 如有架构/状态变化（如 `shared_widgets.dart` 拆分、网络层错误码机制）
- `docs/02-reference/Design_System.md` — 如 P1 中补充了 `FCircularProgress` 使用边界规则
- `docs/02-reference/Localization.md` — 如 P1 中新增了 `network_*.arb` fragment

### 6.6 不扩展 `Spacing` scale

P2-B 中建议方案 B（不扩展 scale），因为：

- `Spacing` 的 12 级 scale 已覆盖绝大多数场景
- `8` 和 `12` 与 `6`/`10`/`14` 差异 ≤ 2px，视觉无法区分
- 扩展 scale 会增加设计系统碎片化，新开发者更难选择正确 token
- 如果确实需要 `8` 或 `12`，说明布局约束可能有设计问题，应从布局层面解决

### 6.7 提交策略

建议按 P0 / P1 / P2 分三个 commit：

1. `refactor(luminous): 文件命名与组件拆分`
2. `refactor(luminous): FCircularProgress 清理与网络层 l10n`
3. `refactor(luminous): magic number 间距与 l10n fallback`

每个 commit 前确保 `flutter analyze` + `flutter test` 通过。
