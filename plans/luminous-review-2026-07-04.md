# Luminous 全项目审查报告

**审查日期：** 2026-07-04
**分支：** refactor
**最新提交：** `81d2675b` docs(vault): 重组文档结构
**审查范围：** 全项目（lib/ 目录）
**审查方式：** rg 静态扫描 + 全量分析

---

## 1. 不优雅写法

### 1.1 魔法数字 / 硬编码常量

| 位置 | 问题 | 建议 |
|------|------|------|
| `app/router.dart:41-44` | `_authTransitionIn = 400`, `_authTransitionOut = 280`, `_crudTransitionIn = 220`, `_crudTransitionOut = 150` | 提取为 `AppTransitionDurations` 常量类 |
| `assistant_message_bubble.dart:52` | `maxWidth: 560` | 提取为 `AssistantMessageMaxWidth` |
| `assistant_state_card.dart:26` | `maxWidth: 560` | 同上，与 bubble 重复 |
| `auth_shell.dart:47` | `maxWidth: 560` | 同上，重复第三次 |
| `auth_shell.dart:171,175` | `duration: 180.ms` | 提取为 `AuthShellAnimationDuration` |
| `shell_page.dart:17` | `_sidebarAnimationDuration = 200` | 提取为 `SidebarAnimationDuration` |
| `shell_sidebar_provider.dart:59` | `expandedWidth = 232` | 提取为 `SidebarExpandedWidth` |
| `report_dashboard.dart:52` | `maxValue: 100` | 百分比最大值应提取为 `PercentageMaxValue` |
| `medicine_recognize_dialog.dart:52` | `maxWidth: 400` | 提取为 `DialogMaxWidth` 或复用现有常量 |
| `assistant_page.dart:58` | `duration: 180` | 动画时长未复用 `auth_shell.dart` 中的 180ms |
| `mine_dashboard_view.dart:36,40` | `duration: 220` | 与 `_crudTransitionIn` 相同但未复用 |
| `assistant_conversation_drawer.dart:34` | `: 360.0` | 抽屉宽度硬编码，应提取为 `ConversationDrawerWidth` |

**重复 maxWidth: 560 出现 3 次**，应提取为 `ContentMaxWidth` 或 `FormMaxWidth` 统一使用。

### 1.2 硬编码日期（Mock 数据）

| 位置 | 问题 | 建议 |
|------|------|------|
| `mock_report_repository.dart:30-31,48-49` | `DateTime(2026, 6, 6)` / `DateTime(2026, 6, 12)` | Mock 数据硬编码，应使用相对日期（如 `DateTime.now().subtract(days: 7)`） |
| `mock_report_repository.dart:156-160` | 同上，再次重复 | 重复定义 |
| `mock_mine_repository.dart:50` | `DateTime.utc(2099, 1, 1, 0, 0)` | 遥远的未来日期，Mock 意图不明确 |
| `report_dashboard_provider.dart:19-20` | 再次使用 `DateTime(2026, 6, 6)` | 与 mock 数据耦合，provider 不应依赖 mock 的硬编码日期 |

### 1.3 动画时长未统一

以下动画时长分散在各处，未集中管理：
- 180ms（assistant_page, auth_shell）
- 200ms（shell_page）
- 220ms（mine_dashboard_view, router）
- 400ms（router auth in）
- 280ms（router auth out）
- 150ms（router crud out）

**建议：** 创建 `AppAnimationDurations` 类统一管理。

---

## 2. 重复造轮子

### 2.1 重复组件名称

rg 扫描发现以下组件名重复定义：
- `_VerificationCodeField` — 4 次（不同文件中同名私有组件）
- `_MineEditFormLoading` — 4 次
- `_TrendPlaceholder` — 2 次
- `_SoftIcon` — 2 次
- `_SheetDragHandle` — 2 次
- `_SectionTitle` — 2 次
- `_SectionLabel` — 2 次
- `_QuickActionTile` — 2 次
- `_IconActionButton` — 2 次
- `_AiSummaryPlaceholder` — 2 次

私有组件（`_` 开头）在不同文件中重复定义，虽然作用域隔离，但说明存在**可提取的共享模式**。建议提取到 `core/widgets/shared/` 中复用。

### 2.2 重复导入模式

高频导入（来自 rg 分析）：
- `import 'package:flutter/material.dart'` — 180 次
- `import 'package:forui/forui.dart'` — 162 次
- `import 'package:luminous/core/design/app_design.dart'` — 132 次
- `import 'package:luminous/l10n/app_localizations.dart'` — 129 次
- `import 'package:flutter_riverpod/flutter_riverpod.dart'` — 90 次
- `import 'package:luminous/core/design/app_colors.dart'` — 57 次
- `import 'package:luminous/core/widgets/common/app_state_views.dart'` — 54 次

虽然这些导入无法减少，但 `app_design.dart` 和 `app_colors.dart` 都导入时，应确认 `app_design` 是否已导出 `app_colors`，避免重复导入。

---

## 3. 可用第三方包替代

### 3.1 自定义组件 vs 包

项目中自定义了大量基础组件：
- `AppDivider`（20 次导入）
- `AppStateViews`（54 次导入）
- `ResponsiveContentFrame`（26 次导入）
- `PageScaffold`（26 次导入）

这些组件已稳定使用，但需确认是否已有第三方包（如 `forui`）提供等价物。若 `forui` 已覆盖，应逐步迁移以减少维护负担。

---

## 4. 健壮性不足

### 4.1 强制解引用（!.）

`!.` 使用共计 **74 处**。虽然部分是必要的（如已知非 null），但过量使用表明：
- 类型设计不够精确（如 `String?` 在确定非空时仍用 nullable）
- 空值防御过度依赖运行时断言而非编译时保证

建议：对高频使用 `!.` 的文件进行逐行审查，确认是否可改为 `?.` 或提前 null-check。

### 4.2 空值安全访问（?.）

`?.` 使用共计 **507 处**，说明空值处理意识良好。但 `!.` 与 `?.` 比例约为 1:7，仍有优化空间。

### 4.3 异常处理

try-catch 块 **49 个**，throw **59 次**。异常处理覆盖率尚可，但需确认：
- 异步操作（如 API 调用）是否都有 try-catch
- catch 中是否都有用户反馈（Toast / Snackbar）

---

## 5. 维护隐患

### 5.1 层间耦合（presentation 直接依赖 data）

**严重问题：** 多个 Provider 直接 import 具体的数据层实现，而非依赖抽象接口。

| Provider | 直接依赖的具体实现 | 应依赖的抽象 |
|----------|-------------------|-------------|
| `report_dashboard_provider.dart` | `mock_report_repository.dart` | `ReportRepository` 接口 |
| `today_dashboard_provider.dart` | `mock_today_repository.dart` | `TodayRepository` 接口 |
| `mine_dashboard_provider.dart` | `lucent_mine_repository.dart` + `mock_mine_repository.dart` | `MineRepository` 接口 |
| `record_dashboard_provider.dart` | `mock_record_repository.dart` | `RecordRepository` 接口 |
| `today_ai_analysis_provider.dart` | `lucent_today_ai_repository.dart` | `TodayAiRepository` 接口 |
| `report_ai_summary_provider.dart` | `lucent_report_ai_summary_repository.dart` | `ReportAiSummaryRepository` 接口 |
| `search_provider.dart` | `lucent_repository.dart` | `MedicineSearchRepository` 接口 |

**问题：** Provider 直接决定使用哪个实现（mock 或 lucent），这应在 `main.dart` 或依赖注入层统一配置，而非分散在各 Provider 中。

**建议：** 使用 Riverpod 的 `override` 机制在顶层注入实现，Provider 中只依赖接口类型。

### 5.2 路由结构膨胀

rg 扫描发现 `router.dart` 中定义了 **42 个 GoRoute**，页面文件 **31 个**，对话框 **9 个**。路由数量多且集中在一个文件，维护成本高。

**建议：** 按 feature 拆分路由配置，如 `router_auth.dart`、`router_record.dart` 等，在主路由中合并。

### 5.3 状态管理 Provider 数量

Provider 统计：
- `FutureProvider` — 7 个
- `AsyncNotifierProvider` — 5 个
- `StateProvider` — 少量（未在本次扫描中精确统计）

`FutureProvider` 和 `AsyncNotifierProvider` 比例接近 1:1，但未统一使用某一种模式。建议团队统一状态管理策略（如全部使用 `AsyncNotifier` 以支持 side effects）。

### 5.4 测试文件排除在 analyzer 外

`analysis_options.yaml` 已排除 `test/**`。本次扫描发现测试文件 **123 个**，这些代码无法通过静态分析检查类型安全。

**建议：** 尽快恢复 `test/**` 的 analyzer 覆盖，或至少恢复部分核心测试的覆盖。

### 5.5 TODO 遗留

rg 扫描发现 2 个 TODO：
- `core/utils/clock.dart:3` — "TODO: inject [Clock] throughout the codebase instead of calling DateTime.now() directly"
- `record_fast_entry_choices.dart:7` — "TODO: load these from a remote configuration or local config file"

**状态：** ⚠️ 未处理

---

## 6. Mock 数据清理进度

rg 扫描发现 Mock 文件 **6 个**：
- `mock_medicine_workspace_repository.dart`
- `mock_mine_repository.dart`
- `mock_record_repository.dart`
- `mock_report_repository.dart`
- `mock_today_repository.dart`
- `mock_repository.dart`（search）

多个 Provider 仍直接依赖 Mock 实现（见 5.1），说明：
- 部分功能未完成真实接口对接，或
- Provider 中硬编码了 Mock 选择逻辑

**建议：** 制定 Mock 清理计划，明确每个 Mock 的替换时间表。

---

## 7. 与 2026-07-04 增量审查对比

| 问题 | 增量审查（bc730bcf） | 全项目扫描（本报告） | 结论 |
|------|---------------------|---------------------|------|
| 按钮迁移完成度 | 部分完成（TextButton/IconButton 遗留） | 未涉及具体改动 | 遗留问题仍需处理 |
| app_dialog_shell Material 反向添加 | 发现问题 | 未在本次扫描中复现（可能已修复） | 需确认 |
| 透明 Material 清理 | 部分完成 | — | 仍需最终 sweep |
| 提交标题与范围匹配 | 不匹配 | — | 建议后续提交精确描述 |
| 路由结构 | — | 42 个 GoRoute，建议拆分 | 新发现 |
| 层间耦合（Provider→Repo） | — | 严重，多个 Provider 直接依赖实现 | 新发现 |
| Mock 硬编码日期 | — | 多处使用固定日期 | 新发现 |
| 动画时长未统一 | — | 分散多处 | 新发现 |
| 重复组件名 | — | 10+ 个组件名重复定义 | 新发现 |

---

## 8. 最优先修复项

1. **层间耦合（Provider→具体 Repo）** 🔴 — 使用 Riverpod override 统一注入，Provider 只依赖接口
2. **Mock 硬编码日期** 🔴 — 替换为相对日期，移除对固定日期的依赖
3. **重复 maxWidth: 560** 🟡 — 提取为 `ContentMaxWidth` 常量
4. **动画时长统一** 🟡 — 创建 `AppAnimationDurations` 类
5. **重复组件名提取** 🟡 — 将 `_VerificationCodeField`、`_SectionTitle` 等提取为共享组件
6. **路由拆分** 🟡 — 按 feature 拆分 router.dart
7. **恢复 test/** 的 analyzer 覆盖 🟡 — 逐步恢复静态分析
8. **TODO 处理** 🟢 — 完成 `clock.dart` 和 `record_fast_entry_choices.dart` 中的 TODO


---

## 9. 源码回查细化（2026-07-04 05:26）

对报告中标记为"可能"、"需确认"的条目进行源码回查，结果如下：

### 9.1 ✅ app_dialog_shell Material 反向添加（已确认修复）

**回查结果：** `lib/core/widgets/common/app_dialog_shell.dart` 当前实现：

```dart
return FDialog.raw(
  constraints: BoxConstraints(...),
  animation: animation,
  builder: (context, style) { ... },
);
```

组件已完全使用 `forui` 的 `FDialog.raw`，**不再反向添加 Material 组件**。此前增量审查发现的 Material 反向添加问题**已修复**，无需进一步处理。

### 9.2 TODO 遗留项确认

#### 9.2.1 clock.dart — 抽象时钟注入

**位置：** `lib/core/utils/clock.dart:3-6`

```dart
/// TODO: inject [Clock] throughout the codebase instead of calling
/// [DateTime.now()] directly in business logic.
```

**回查结果：** TODO 确实存在。这是一个**架构改进项**，当前业务代码中仍有大量 `DateTime.now()` 直接调用，导致时间相关逻辑难以测试。建议：
- 在 `ProviderScope` 中注入 `Clock` 实例
- 逐步替换各 Provider/Service 中的 `DateTime.now()` 为 `clock.now()`

**优先级：** 🟢 低（技术债，不影响功能）

#### 9.2.2 record_fast_entry_choices.dart — 配置外置

**位置：** `lib/features/record/domain/constants/record_fast_entry_choices.dart:7-10`

```dart
/// TODO: load these from a remote configuration or local config file so that
/// labels, default values, and supported units can be adjusted without a
/// full app release.
```

**回查结果：** TODO 确实存在。当前快速录入选项（体重、血压、血糖等）硬编码在 Dart 文件中，任何调整都需要发版。建议：
- 短期：移至 `assets/config/fast_entry_choices.json`，通过 `rootBundle` 加载
- 长期：从后端获取配置，支持动态调整

**优先级：** 🟡 中（影响运营灵活性）

### 9.3 结论

- `app_dialog_shell` 的 Material 反向添加问题**已确认修复**
- 两处 TODO **均真实存在**，建议按优先级排期处理
- 无其他需修正的误报项
