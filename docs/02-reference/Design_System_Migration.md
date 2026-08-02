---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-02
---

# Design System Migration

本文件是 [[Design_System]] 拆分后的子文档。

相关子文档：
- [[Design_System_Components]]

## 迁移状态

- 该 bridge 正在主动被压平，而非原地重风格化：
  - `settings_page.dart`
  - `notification_list_page.dart`
  - 重建的 auth/account 对话框
  - 重写的 Today/Record 交互行
  - medicine `FTappable` 行
  - 均直接通过 `FScaffold` / `FHeader` / `FTappable` / `FDialog` 渲染，不再路由回已删除的根 wrapper 文件。
- 助手对话 shell 已越过同一边界：
  - `assistant_page.dart`、对话 surface/drawer、hero、消息气泡、proposal cards、tool chips
  - 直接读取 `context.theme.colors` + `Theme.of(context).textTheme`
  - 剩余 `Icons.*` 已替换为 Lucide 图标
- Today 首页顶部栏 + overview / priority / recommendation / todo sections 也通过直接 Forui 颜色/文本语义和 Forui
   card shell 渲染。
  - 不再依赖 `AppSectionSurface`、`AppTypographyTokens`、页面本地 `AppThemeSurface` 读取。
  - 共享 Today view-model 图标从 Material 图标切换到 Lucide。
- Today AI 摘要 shell 也已跟进：
  - `today_ai_summary_section.dart` 与 `today_page.dart` 不再为 AI card 和页面背景保留 `AppSectionSurface` /
     `AppTypographyTokens` 栈。
  - 2026-07-02 清理后，`rg -n "AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\\."
     lib/features/today` 无匹配。
- Mine 首页 body 也已同一方向：
  - `mine_dashboard_view.dart`、`mine_top_bar.dart`、`mine_account_hero.dart`、
     `mine_archive_section.dart`、`mine_status_overview.dart`
  - 隐私提示/共享标题 helper 不再把 `AppThemeSurface` / `AppTypographyTokens` 传过页面 body。
  - 可见 Mine header/account/archive/status shell 通过直接 Forui-aware 颜色/文本读取 + card-style 布局渲染。
  - signed-out 提示图标路径更新为 Lucide。
- Mine page shell 与 skeleton helper 也已跟进：
  - `mine_page.dart`、`mine_components.dart`、`mine_skeleton_view.dart`、`shell_deferred_content.dart`
  - 不再为 background、separator 或共享 row/chip wrapper 保留 feature-level `AppThemeSurface` 读取。
  - 2026-07-02 清理后，`rg -n "AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\\."
     lib/features/mine lib/features/shell` 无匹配。
- Report 首页 body 也已同一方向：
  - `report_page.dart`、`report_dashboard_view.dart`、`report_top_bar.dart`
  - score/metrics/trend/findings/patterns/export/AI-summary sections 与 reference notice
  - 不再把旧的 report-local `surface + typography + section surface` 栈穿过可见 shell。
  - 页面主 dashboard surface 全程使用 Forui-aware 颜色/文本读取 + card/button shell。
  - report-local 可见 Material 图标替换为 Lucide 等价物。
  - 剩余旧主题 bridge 限于共享 `report_components.dart` sparkline helper。
- medicine/search surface 也已越过同一边界：
  - `medicine_page.dart`、`medicine_workspace_view.dart`、`medicine_mobile_dashboard_view.dart`
  - 移动端 medicine sections、reminder detail/edit/form helpers、risk check page + risk tiles、
     search/add-precheck chain
  - 直接读取 `context.theme.colors` + `Theme.of(context).textTheme`
  - 使用 Forui card/group 语义
  - 不再依赖 `AppSectionSurface`、`AppThemeSurface`、`AppTypographyTokens`
- 2026-07-02 medicine/search phase 后，`rg -n "
   AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\\." lib/features/medicine
   lib/features/search` 无命中。
- Record 在最明显的 mobile-first panels 中部分越过同一边界：
  - NLP candidate/retry panels
  - meal-analysis summary/status widgets
  - image attachment card
  - meal-dish editor
  - date bar
  - mobile filter
  - AI input bar
  - quick-entry panel
  - mobile timeline
  - new-entry panel
  - 通过直接 Forui-aware 颜色/文本读取 + Lucide 图标渲染，替代旧的 record-local `surface + typography + section
     surface` chain。
- record 可见 panel pass 后，剩余旧主题债务集中在大壳层：
  - `record_page.dart`
  - `record_detail.dart`
  - `record_dashboard_view.dart` desktop/top-level glue
  - sidebar/timeline/summary/shared section widgets
- record page/detail entry layer 也已同一方向：
  - 顶层 `record_page.dart` action chips/FAB/error state
  - `record_detail.dart` detail cards/image shell/edit-delete affordances
  - 共享 record header-chart divider helpers
  - 使用直接 Forui-aware 颜色/文本读取 + Lucide 图标
- record desktop dashboard sections 也已大多越过同一边界：
  - `record_dashboard_view.dart`、`record_sidebar.dart`、`record_summary_grid.dart`、
     `record_timeline.dart`
  - 不再把 `AppThemeSurface` / `AppTypographyTokens` 穿过 desktop branch。
  - 可见 shell 遵循官方低饱和度 Forui 方向：白卡、细中性边框、黑色主状态、Lucide 图标。
- record helper/dialog shells 也已跟进：
  - `record_quick_actions.dart`、`record_week_strip.dart`、`record_nlp_dialog.dart`、
     `record_voice_entry_dialog.dart`、`record_ocr_entry_dialog.dart`
  - 不再依赖 `AppThemeSurface`、`AppTypographyTokens`、`AppSectionSurface`
  - 可见图标也使用 Lucide 替代 `Icons.*`
- 2026-07-02 record finish pass 后，`rg -n "
   AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\\." lib/features/record` 无匹配。
- Dense settings-page UI 正在 page 与 core-wrapper 两层被拖过去：
  - 顶层 `SettingsPage` 与主要二级设置子页已直接使用页面本地 Forui tiles/switch rows。
  - `core/widgets/settings/` 中剩余共享 wrapper 也通过 `FTile` / `FSwitch` 渲染，替代 Material `InkWell` /
     `Switch`。
- 助手控制 surface 也同一路径：
  - `AssistantControlsPanel` 不再组合 `AppSettingRow` 或 `AppSectionSurface`
  - enable/memory/context toggles 直接通过 Forui tiles 与 switches 渲染

## 迁移策略

- 主动迁移策略现在是「official Forui first」：
  - 当 Forui 组件或 CLI 生成样式已存在所需 surface 时，应替换本地自定义 wrapper，而非新增兼容抽象。
  - `dart run forui style ls` 确认官方样式支持 dialog、toast、sidebar、checkbox、switch、text-field、calendar、
     date-time-picker、time-picker、popover-menu、tooltip 及相关 shell primitives。

## 交互 shell 清理

- 交互 shell 清理已开始在 auth 外遵循相同规则：
  - `today_todo_section.dart`
  - `today_priority_section.dart`
  - `record_quick_actions.dart`
  - `record_date_bar.dart`
  - `record_nlp_dialog.dart`
  - `medicine_workspace_helpers.dart`
  - 移动端 medicine sections/safety/reminder rows
  - `theme_settings_page.dart`
  - `ai_settings_page.dart`
  - `sleep_reminder_settings_page.dart`
  - `settings_page.dart`
  - `notification_list_page.dart`
  - 上述文件的 touched call sites 不再依赖 `AppInkWell`、`AppDialog` 或 `PageScaffoldShell`。

## Auth 迁移模式

- auth 迁移有自己的可复用实现笔记：[[02-reference/Auth_Forui_Migration_Pattern]]。
- 该文档捕获要向前复制的稳定模式，并明确记录 auth-only 强制主题覆盖与单色 logo filter 曾被尝试但拒绝。

## 剩余 bridge 消费者

- 剩余 feature-level bridge 消费者也已被推出 `lib/`：
  - `account_settings_sections.dart`
  - `app_settings_master_toggle_page.dart`
  - `report_components.dart`
  - `medicine_safety_tip_style.dart`
  - `medicine_reminder_formatters.dart`
  - 不再依赖旧根 bridge 类型。
- 2026-07-02 root-removal pass 后，`rg -n "
   AppThemeSurface|AppTypographyTokens|AppSectionSurface|Icons\\." lib` 无匹配。
- 运行时 `lib/` 不再携带旧 bridge 文件。
- 激进迁移暂时把 `test/**` 排除在 analyzer 范围外，使遗留 test import 不阻塞最终 Forui runtime sweep。

## 2026-07-03 跟进

- **本地 surface 替换**：验证 `today_top_bar`、`medicine_page`、`mine_top_bar`、report sections 中剩余的手建
   chip/card/badge/avatar surface 已使用原生 Forui widgets（`FButton`、`FCard`、`FBadge`、
   `FAvatar`）。
- **Phase 1 icon cleanup**：运行时 `lib/` 中所有 Material3 `Icons.*`（含数据/领域 repositories 与 entities）已替换为
   `FLucideIcons.*` 等价物。剩余 `Icons.*` 引用仅在生成的 `*.g.dart` / `*.freezed.dart` 文件中。
- **Phase 3 wrapper inlining**：薄视觉别名 wrapper（`app_header_action_chip`、`app_icon_badge`、
   `app_image_placeholder`、`app_section_header`、`app_status_pill`、`app_text_action`、四个
   `app_settings_*` rows/section）已内联到原生 Forui widgets 并删除文件。
- **Phase 4 token alias cleanup**：验证运行时 `lib/` 与 `test/` 不再包含 `AppThemeSurface`、
   `AppTypographyTokens`、`AppSectionSurface`、`AppColorTokens`、`AppShadowTokens`、`AppInkWell`、旧
   `AppDialog`。
- **Phase 4 layout-helper comments**：为 `app_breakpoints.dart`、`app_layout_tokens.dart`、
   `app_responsive_sizing.dart` 添加文件级 doc comments，明确它们是响应式布局 helper 而非视觉设计 token。
- **Phase 4 token finalization complete**：
  - 审计 `AppSpacingTokens`，删除未使用的 `level11`
  - 确认 `AppRadiusTokens` 映射到 Forui `FBorderRadius` scale
  - 运行时 `lib/` 无 Material `Icons.*` 使用
  - 债务清偿计划中所有 Phase 4 项完成
- **删除已完成计划**：`plans/2026-07-03-forui-debt-paydown-plan.md` 删除；剩余持续约束由 `AGENTS.md` 强制执行。

## 最终清理

- 从运行时 `lib/` 移除 `Material(color: Colors.transparent)` wrapper。
- 它们之前的子节点（可滚动页面 body、`FTappable` tiles、`FCard` surfaces、dialog content）现在直接渲染，因为所有后代已使用 Forui
   组件。
- Material `Scaffold` / `AppBar` / `Drawer` 已在运行时 `lib/` 中完全替换为 Forui 等价物。
- 所有页面使用 `FScaffold` + `FHeader`。
- 助手最近对话 drawer 迁移到 `showFSheet(side: FLayout.rtl, ...)`。
- 剩余 `Drawer(` 引用仅为自定义 widget 类名。
- `lib/core/network/map_utils.dart` 中的共享工具 `coerceToStringMap` 去重 5 份相同的 `_coerceToMap` helper。
- `compareReminderTime` 从 3 份副本去重到 `medicine_reminder_formatters.dart` 中的 1 个公共版本。
- 登录页 password/code 模式切换使用 `flutter_animate` 的 `.fadeIn().slideX()`，匹配项目范围的进入动画模式。

## Forui 0.24.x 升级（2026-07-21）

- **`FThemes` 移除**：Forui 0.24.0 移除了除 `neutral` 外的所有预定义颜色方案。`lib/core/theme/theme.dart` 新增 `_familyColorOverride()` 函数，在 `FTheme.neutral` 基础上覆盖 `primary` / `primaryForeground` 模拟原有 `blue / green / orange / red / rose / slate / violet / yellow / zinc` 主题族。颜色值取自 Forui 0.23.x 预定义方案。
- **`FCard.raw` / `FDialog.raw` 移除**：API 合并到 `FCard` / `FDialog`。约 60 个文件的 `FCard.raw(` 批量替换为 `FCard(`，`AppDialogShell` 中的 `FDialog.raw` 替换为 `FDialog`。
- **`FDialog` 构造函数重构**：从声明式（`title`/`body`/`actions`）改为 `builder: (context, style) => ...` 模式。调用方需自行用 `Column` + `Row` 构建布局，通过 `style.titleTextStyle` / `style.bodyTextStyle` 或 `dialogContext.theme.dialogStyle.titleTextStyle` / `bodyTextStyle` 获取文本样式。简单对话框优先迁移到 `showAppDialog`。
- **`FDateSelectionControl.lifted` → `liftedSingle`**：API 从 `selected`/`select` 回调改为 `value`/`onChange`/`toggleable` 参数。
- **`FBadgeStyle.contentStyle` 移除**：`labelTextStyle` 从嵌套的 `contentStyle.delta(...)` 提升到 `FBadgeStyleDelta` 顶层。
- **`FHeader.nested` 布局修复**：`FHeader.nested` 不能放在 `ListView` 中（`_RenderNestedHeader` 在 tight width 约束下产出无效 `BoxConstraints` 崩溃）。所有 Tab 根页（Today/Report/Mine/Medicine 移动端）从 `ListView(FHeader.nested + ...)` 重构为 `Column(FHeader.nested + Expanded(ListView(...)))`。临时替代组件 `TabTopBar` 已删除。
- **验证**：`flutter analyze` 零问题。


相关子文档：
- [[Design_System_Migration]]

