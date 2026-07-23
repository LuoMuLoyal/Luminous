# Design System Components

本文件是 [[Design_System]] 拆分后的子文档。

相关子文档：
- [[Design_System_Migration]]

## 组件规范

- pill alpha：`0.12`
- status pill radius：`RadiusTokens.level3`
- panel radius：`RadiusTokens.level5`
- section header fontWeight：`w600`
- icon badge size：`48px`
- text action icon：`16px`

## 路由过渡

- auth 页面：`CustomTransitionPage` + `FadeTransition`（400ms in / 280ms out）
- drill-down 页面：`SlideTransition` + `FadeTransition`（220ms in / 150ms out）

## 交互

- Today 与 Mine 页面支持下拉刷新：`RefreshIndicator` + `AlwaysScrollableScrollPhysics`。
- `ShellPage` 使用 lazy tab loading（`_pages[currentIndex]` 替代 `IndexedStack`）。
- 仅当前 tab 的 provider 在启动时触发；Riverpod 缓存使切回瞬间完成。

## 图表

- 记录趋势图表使用 `fl_chart`（`LineChart` / `BarChart`），替代手写 `CustomPainter` widgets。

## 数据类

- Freezed 应用于 74 个 presentation state 与 domain entity 类；所有手写 data class 已迁移。

## 对话框

- 共享对话框 helper：`showAppDialog` / `DialogShell`（`lib/core/widgets/common/dialog_shell.dart`）。`showAppDialog` 支持 `barrierDismissible` 参数（默认 `true`），需要不可点击遮罩关闭的场景（如扫码处理遮罩）传 `false`。
- `RecordNlpDialog` 与 `MedicineAddPrecheckDialog` 已使用它。
- **Forui 0.24.x**：`FCard.raw` / `FDialog.raw` 已移除，API 合并到 `FCard` / `FDialog`。`FDialog` 构造函数从声明式改为 `builder` 模式，调用方需自行用 `Column` + `Row` 构建布局。

## 反馈与通用 widget

- `Toast` 现在从 Forui theme 值解析颜色与图标处理，替代旧兼容主题层。
- `app_state_views.dart`、`app_text_action.dart`、`app_status_pill.dart`、`app_image_placeholder.dart`、
   `app_header_action_chip.dart`、`app_divider.dart` 使用直接 Forui 颜色 + Material `textTheme`。
- `StateMessageView`（`state_message.dart`）的 `description` 参数为可选 `String?`——仅需标题+图标的空态/错误态场景（如帮助页）不需要传入重复描述文案。
- `lib/core/widgets/common/` 不再保留 `AppSectionSurface`。
- `IconActionButton`（`core/widgets/common/icon_action_button.dart`）是全 App 唯一的顶栏图标按钮实现，支持 `showBadge` 参数在右上角叠加红色小圆点（用于未读消息提醒等场景）。Mine/Today 等模块的顶栏统一引用 core 版本，不再各自维护同名实现。
- `settingsPageVerticalPadding(BuildContext)`（`settings/presentation/utils/settings_page_padding.dart`）是设置页面统一的响应式垂直 padding 函数——窄屏（< `Breakpoints.mobile`）返回 `Spacing.level6`，宽屏返回 `Spacing.level7`。设置主页和所有子页统一引用该函数，不再各自手写响应式三元表达式。
- `SettingsSectionLabel`（`settings/presentation/widgets/shared/settings_section_label.dart`）是设置页面统一的分组标题组件——`TypographyToken.level3` + `w600` 字重 + `mutedForeground` 颜色 + `Spacing.level2` 水平 padding。设置主页和所有子页统一使用该组件，不再各自维护 `_SettingsGroup` 等自定义实现。
- `showForuiDatePicker`（`lib/core/widgets/common/date_picker.dart`）是全 App 共享的日历日期选择器工具函数，基于 `showFDialog + FCalendar.grid` 封装，统一记录/提醒/健康表单等所有日期选择入口。

## 对话框基础设施

- `lib/core/widgets/common/app_dialog_shell.dart` 是薄 Forui-first 布局 helper。
- 它在 `showFDialog + FDialog` 之上集中 `maxWidth/maxHeight`、共享 padding、滚动行为与键盘 inset 处理。
- **Forui 0.24.x 变更**：`FDialog.raw` 构造函数已移除，API 合并到 `FDialog`。`FDialog` 构造函数从声明式（`title`/`body`/`actions`）改为 `builder: (context, style) => ...` 模式。`style` 类型为 `FDialogStyle`，提供 `titleTextStyle` / `bodyTextStyle`。简单对话框优先迁移到 `showAppDialog`，在 builder 中用 `dialogContext.theme.dialogStyle.titleTextStyle` / `bodyTextStyle` 获取文本样式。

## Auth surface

- auth surface 进一步推向官方风格 Forui 组合：
  - login/register/forgot-password/change-email/account-settings 使用直接
    `FButton`、`FTabs`、`FToast`、`FDialog` 组合。
  - 主表单页使用 `Form` + `GlobalKey<FormState>` + `FTextFormField.email/password` +
     `AutovalidateMode.onUserInteraction`。
- 旧 wrapper 文件已直接删除而非保留为兼容 shim：
  - `auth_text_field.dart`
  - `auth_action_row.dart`
  - `auth_status_message.dart`
  - `auth_field_error.dart`
- `auth_shell.dart` 仅保留为薄 page-shell/card 布局 helper。

## Auth 测试

- Auth feature 测试已匹配 Forui surface：
  - 删除 deleted-widget 测试
  - `FilledButton` 断言变为 `FButton`
  - `TestForuiApp` / `TestAuthApp` 替代 stale `AppTheme` bootstraps
  - register 测试接受新的 `FCheckbox` terms-consent gate

## Login shell

- login shell 进一步收紧向官方示例：
  - logo 不再使用旧自定义渐变/阴影容器
  - password/code selector 位于 logo/title block 与 form card 之间，而非 form 内部

## Register form

- register form 现在带有真实 Forui `FCheckbox` terms/privacy consent gate。
- 用户接受前禁用账户创建。
- 旧占位 auth terms toast 替换为直接打开当前 public legal URL（`/terms` 与 `/privacy` on `luminous.app`）。

## Account settings

- `account_settings_page.dart` 在布局层面也更接近官方 Forui sample：
  - 账户管理按顶部 `FTabs` selector 分割
  - 一个 pane 用于 overview/profile/email/identity management
  - 另一个 pane 用于 password/delete-account actions
  - 每个 pane 渲染在单个外层 `FCard` 内，替代旧的嵌套卡片堆

## 表单验证

- auth form validation 通过 `AuthValidationMixin` 与 `CooldownTimerMixin`
   共享（`lib/features/auth/presentation/providers/shared/auth_form_mixin.dart`）。
- `RegisterFormNotifier`、`PasswordResetNotifier`、`LoginFormNotifier` 均使用两个 mixin。
- Email validation 委托给 `email_validator` package；任何 auth provider 中不再保留手写 email regex。

## Hooks

- `flutter_hooks` / `hooks_riverpod` 项目范围使用：
  - 之前手动管理 `TextEditingController` 生命周期的 16 个文件已迁移到 `HookConsumerWidget` / `HookWidget` +
     `useTextEditingController()`。
  - 零手动 `initState`/`dispose` controller boilerplate 保留。

## Material 输入替换

- 运行时 `lib/` 中的 Material 输入 widget 已完全替换为 Forui 等价物：
  - 无剩余 `TextFormField`、`DropdownButton`、`Switch`、`Checkbox`
  - 使用 `FTextField` / `FTextFormField`、`FSelect`、`FSwitch`、`FCheckbox`
- 仅有的剩余 `showDialog` 调用也已迁移到 `showAppDialog` / `showFDialog`。

