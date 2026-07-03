# Forui 重构剩余债务清偿计划

**创建日期：** 2026-07-03  
**目标：** 在 Luminous 运行时 `lib/` 中消除不必要的手写组件与手写 token 债务，完成“官方 Forui first”迁移；同时引入 `forui_hooks` 作为带 controller 的 Forui 组件的首选状态管理方式。  
**非目标：** 重绘产品交互、新增业务功能、重写数据模型语义。

---

## 1. 当前债务快照

基于 2026-07-03 审计结果，迁移进度约 **75% 完成 / 15% 薄封装 / 10% 未清债务**。剩余问题集中在四类：

### 1.1 手写设计 token（`lib/core/design/`）

#### Forui 自身的 token 体系

Forui 的主题由 `FThemeData` 持有，主要包括：

- **`FColors`**：语义颜色 token，如 `background`、`foreground`、`primary`、`secondary`、`muted`、`destructive`、`border`、`card` 等，已内置 light/dark 两套值，切换 `ThemeMode` 时自动生效。
- **`FTypography`**：字号/行高 token（`xs3` ~ `xl8`），例如 `context.theme.typography.lg`。
- **`FStyle`**：组件级风格容器，包含 `borderRadius`（`FBorderRadius`：none/sm/md/lg/xl/full）、`sizes`（`FSizes`，主要面向按钮等组件尺寸）、`pagePadding`、`borderWidth`、`shadow` 等。

**Forui 没有提供独立的通用间距 token scale**（类似 `level1..level12` 这种纯数字间距阶梯），间距通常由组件内部 padding、`FStyle.pagePadding` 或开发者手动 `spacing` 决定。

#### 当前文件的定位

| 文件                                                                             | 债务说明                                                                                            | 建议处理                                                                                                                                                                                                                    |
| -------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `app_colors.dart`                                                                | 语义颜色枚举 `AppColors { primary, secondary, destructive, muted, background, border, foreground }` | **保留**。这是数据/领域层在不持有 `BuildContext` 的情况下表达语义颜色的桥梁，UI 层通过 `AppColors.resolve(context.theme.colors)` 随当前主题解析。它是支持 light/dark/未来自定义 preset 多主题切换的关键层，不是重复造轮子。 |
| `app_spacing_tokens.dart`                                                        | 自定义 `level1..level12` 间距                                                                       | **保留并审计**。Forui 没有通用间距 scale，该文件作为项目布局词汇存在。仅删除未使用的 `level*` 和任何遗留语义别名。                                                                                                          |
| `app_radius_tokens.dart`                                                         | 自定义 `level0..level5` + `levelFull`                                                               | **评估后保留或对齐**。Forui 提供 `FBorderRadius`（none/sm/md/lg/xl/full）。若当前 `level*` 值与 Forui 圆角语义差异不大，可映射到 `context.theme.style.borderRadius`；若项目需要更细粒度，保留为项目约定并删除未使用值。     |
| `app_layout_tokens.dart` / `app_breakpoints.dart` / `app_responsive_sizing.dart` | 响应式 helper                                                                                       | **保留**。这些是布局工具，不是视觉 token。                                                                                                                                                                                  |
| `app_theme_controller.dart`                                                      | 仅保存 `ThemeMode`                                                                                  | **保留**。模式偏好无需迁移。                                                                                                                                                                                                |

**原则：** 不再新增自定义颜色/间距/圆角 token；需要新视觉值时，先用 `context.theme.colors.*`、`context.theme.typography.*`、`context.theme.style.*`，没有对应语义时再考虑扩展项目 token。

### 1.2 薄封装 `App*` wrapper（`lib/core/widgets/`）

这些 wrapper 当前委托给 Forui，但仍是手写层。原则是：** touched 时优先内联为原生 Forui，不新增 wrapper。**

- `common/app_back_button.dart` → `FButton.icon`
- `common/app_dialog_shell.dart` → `showFDialog + FDialog.raw`
- `common/app_divider.dart` → `FDivider`
- `common/app_header_action_chip.dart` → `FButton`
- `common/app_icon_badge.dart` → `FAvatar.raw`
- `common/app_image_placeholder.dart` → `FCard.raw`
- `common/app_section_header.dart` → `Row + Text`
- `common/app_state_views.dart` → `FCard.raw + FButton`
- `common/app_status_pill.dart` → `FBadge.raw`
- `common/app_text_action.dart` → `FButton` ghost
- `feedback/app_toast.dart` → 自定义 `OverlayEntry`（保留，但颜色/图标必须来自 Forui）
- `settings/app_setting_row.dart` / `app_settings_navigation_row.dart` / `app_settings_section.dart` / `app_settings_switch_row.dart` → `FTile` / `FTileGroup` / `FSwitch`
- `layout/responsive_content_frame.dart` → 响应式 helper（保留）

### 1.4 Material 图标残留（约 450 处）

- **数据/领域层把 `IconData` 直接暴露给 UI**：medicine/mine/record/report 的 repository 与 entity。
- **展示层仍有少量 `Icons.*`**：`today_dashboard_view.dart`、`today_view_models.dart`、`today_components.dart`、`medicine_mobile_drugbox_section.dart`、`medicine_copy.dart`、Mine 编辑页、`app_image_placeholder.dart`、`barcode_scanner_page.dart`。

### 1.5 测试债务

**忽略所有测试!**

- ~~`analysis_options.yaml` 排除 `test/**`，可能仍有旧 `AppTheme`/`AppSectionSurface` 引用。~~
- ~~测试中对 Material widget 的断言需要同步更新为 Forui 断言。~~

---

## 2. `forui_hooks` 引入

已在 `pubspec.yaml` 添加 `forui_hooks: ^0.23.0`。后续凡涉及 Forui controller 的页面，优先使用 `forui_hooks` 提供的 hook，例如：

- `useFTextFieldController()` 替代 `useTextEditingController() + FTextFieldControl.managed`
- `useFSelectController<T>()` 替代手动 `FSelectControl.lifted`
- `useFCheckboxController()` / `useFSwitchController()` 等对应 hook

规则：

1. 新建或重构的 Forui 页面/组件必须先用 `forui_hooks`。
2. 现有 `flutter_hooks` + `FTextFieldControl.managed` 的代码在 touched 时逐步迁移到 `forui_hooks`。
3. 不为了迁移而迁移没有 bug 的稳定代码；但新增 debt 必须通过 `forui_hooks` 解决。

---

## 3. 执行阶段

### Phase 0：基线锁定（当前）

- [x] 引入 `forui_hooks: ^0.23.0`
- [ ] 创建本计划文档
- [ ] 冻结当前 `flutter analyze` 0 issue 的基线
- [ ] 移除 `analysis_options.yaml` 中 `test/**` 的排除，先修复测试导入再进入 Phase 1

### Phase 3：wrapper 内联

目标：所有 `core/widgets/common/app_*.dart` 和 `core/widgets/settings/app_*.dart` 的薄封装在被 touched 时内联为原生 Forui。

1. 不批量删除未使用的 wrapper；但在修改调用它的页面时，顺手内联。
2. 当某个 wrapper 只剩 1-2 个调用方时，直接删除 wrapper 并内联。
3. `app_toast.dart` 保留自定义 overlay 行为，但彻底移除任何手写颜色/图标常量，全部来自 Forui theme。

### Phase 4：token 文件定型

1. **`AppColors` 保持语义桥梁定位**
   - 不删除、不扩展为第二套主题。
   - 数据/领域层继续返回 `AppColors`，UI 层继续用 `AppColors.resolve(context.theme.colors)` 解析。
   - 若未来需要 app 专属扩展色，优先使用 Forui 的 `ThemeExtension<AppColors>` 模式注入 `FColors.extensions`，而不是回到项目常量。
2. **`AppSpacingTokens` 审计**
   - 因 Forui 没有通用间距 scale，保留作为项目布局词汇。
   - 删除未使用的 `level*` 值和所有遗留语义别名（`xxs/xs/sm/...` 已删，需确认无残留）。
3. **`AppRadiusTokens` 对齐评估**
   - 对比 `context.theme.style.borderRadius`（none/sm/md/lg/xl/full）。
   - 若项目 `level*` 与 Forui 语义等价，优先使用 `FBorderRadius`；若需要额外档位，保留并文档化。
4. **`AppLayoutTokens` / `AppBreakpoints` / `AppResponsiveSizing`**
   - 保留并补充注释，明确为“响应式 layout helper，非视觉 token”。
5. 删除所有已废弃的 token alias/语义名。

---

## 4. 验收标准

- [ ] `flutter analyze --no-pub` 0 issue（含 `test/`）。
- [ ] `rg -n "\bIcons\." lib` 仅保留有注释的例外。
- [ ] `rg -n "AppThemeSurface|AppTypographyTokens|AppSectionSurface|AppColorTokens|AppShadowTokens|AppInkWell|AppDialog|AppTheme" lib test` 无匹配。
- [ ] Phase 1.3 中列出的手绘 surface 文件全部被替换为 `FButton`/`FCard`/`FBadge`/`FAvatar`。
- [ ] 新增或修改的 Forui controller 代码优先使用 `forui_hooks`。
- [ ] 无新增 `App*` wrapper；已有 wrapper 数量只减不增。

---

## 5. 风险与回退

| 风险                                          | 缓解                                                                          |
| --------------------------------------------- | ----------------------------------------------------------------------------- |
| `forui_hooks` 与现有 `flutter_hooks` 版本冲突 | 已添加同版本 `0.23.0`；若冲突，锁定 `flutter_hooks` 到 `forui_hooks` 兼容版本 |

| 手绘 surface 替换改变视觉细节 | 每处替换后截图对比，必要时使用 Forui 官方 style 参数微调 |

---

## 6. 下一动作

1. 开始 Phase 3：把 `core/widgets/common/app_*.dart` 和 `core/widgets/settings/app_*.dart` 薄封装内联为原生 Forui；优先处理只剩 1-2 个调用方的 wrapper。
2. 修复 `analysis_options.yaml` 的 `test/**` 排除并清理测试旧引用。
