# Active UI — Mine / Settings

Last updated: 2026-07-19

## Mine 根页结构

移动端：`单一档案状态主卡 → 健康档案分组 → AI 与隐私分组 → 通知与提醒分组 → 账号与安全分组`。

桌面端双栏：`Row[左7: AccountHero+Archive+NotificationsReminders | 右5: AiPrivacy+AccountSecurity]`，顶部可选 `MineSyncFailedBanner`。

- 未登录时登录门槛、preview 说明和主 CTA 并入 Mine 主卡，不显示独立顶部登录提示条。
- 健康档案入口使用 Forui `FTileGroup + FTile`，状态通过明确文字表达。
- `通知与提醒` 分组只承接状态摘要与跳转（提醒设置/免打扰/通知收件箱），收件箱未读数来自真实后端。
- `AI 与隐私` 分组：`AI 设置` → `/settings/ai`，`报告分享` → `/settings`。
- `账号与安全` 分组：`账号与安全` → `/account`，`安全 PIN 码` → `/settings/security-pin`。
- Mine 主卡文案区分 `preview / 缺失关键信息 / 基本就绪` 三种 readiness 语义。

## 同步失败警告

- `MineSyncFailedBanner` 在 Mine 页面顶部展示同步失败警告（warning 色 subtle 背景 + border + cloudAlert 图标 + 点击重试 flush）。
- `syncFailedCountProvider` 查询 `PendingSyncDao.permanentlyFailedCount()`。

## 健康档案

- 基础健康档案（身高/体重等）。
- 过敏史编辑（预填充+更新+删除）。
- 当前用药。
- 疾病史编辑（预填充+更新+删除）。
- 身高字段从 `int.tryParse` 改为 `num.tryParse`，修复 double 身高值丢数据。
- 健康表单枚举使用 `health_enum_l10n.dart` 提供 l10n 映射。
- 删除操作接入 `showDangerConfirmationDialog` 二次确认（allergy/condition/medicine 三处编辑页）。

## 设置页结构

标准 app 模式，五个分组：Account & Security / Notifications / Privacy / General / About。

- 两态切换使用内联 switch。
- 多态项路由到子页。
- 睡眠提醒页使用主开关；关闭时子项禁用；时间选择使用 Forui `FTimeField.picker`。
- 保留期缩短确认：若新期限短于当前期限（含 forever→有限），弹出 `showDangerConfirmationDialog` 二次确认。
- 恢复默认设置接入 `showDangerConfirmationDialog` 二次确认，使用 `destructive` 红色样式 + 副标题提示。
- 通知 key 统一通过 `PrefKeys` 管理。

### 设置模块细化（2026-07-19 追加）

- **垂直 padding 统一**：新增 `settingsPageVerticalPadding(BuildContext)` 函数（`shared_widgets.dart`），统一响应式 `Spacing.level6`/`level7` 逻辑，`page.dart` 使用该函数替代固定 24。
- **分组标题统一**：删除 `page.dart` 内部 `_SettingsGroup` 自定义实现，统一使用 `SettingsSectionLabel`（`shared_widgets.dart`），所有分组改为 `SettingsSectionLabel` + `FTileGroup` 标准模式。
- **选中勾选图标统一**：`advanced.dart`、`feature_flags.dart` 的内联 `Icon(FLucideIcons.check, ...)` 统一替换为 `const SettingsSelectionIcon(selected: true)`，消除未选中时行宽跳变。
- **开关 tile 统一**：删除 `_SettingsSwitchTile`（开关不可键盘聚焦），"隐私报告"行改用标准 `FTile` + `suffix: FSwitch` 模式。
- **健康档案入口移位**：从"通用"组移至"账号与安全"组，返回栈不再混乱。
- **通知页权限永久拒绝**：`permanentlyDenied` 态直接调用 `controller.openSystemSettings()` 跳转系统设置，权限卡片新增"去系统设置开启"CTA 文案。
- **安全 PIN 输入优化**：新增"再次输入确认"步骤，专用 hint（"6 位数字"/"再次输入相同的 PIN 码"），所有输入框添加 `FilteringTextInputFormatter.digitsOnly`。
- **主题色系预览**：`theme.dart` 新增 `_ThemeFamilyDot` 组件，10 种色系行 prefix 显示对应颜色圆点。
- **无障碍字号预览**：`accessibility.dart` 字号选项 label 按对应 `scaleFactor` 缩放渲染。
- **数据导出 loading 优化**：idle 状态使用专用文案"尚未申请"；loading 态 spinner 集成到按钮内部并附带文案。
- **免打扰/睡眠提醒跨天提示**：结束时间早于开始时间时显示"跨天生效"提示。
- **帮助页状态组件统一**：从手写 `_EmptyState` 迁移至 `AppStateMessageView`（带图标+色调），加载态使用 `AppInlineSkeleton` 骨架屏。
- **语言页当前语言显示**："跟随系统"行显示当前生效语言（"当前：{language}"）。

## 主题

- 双层选择：显示模式 `system / light / dark` + 颜色主题 `blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc`。
- 只保留 `theme.mode` 与 `theme.family` 两个本地偏好。
- 高对比度模式使用 `HighContrastColors` 常量类。

## 通知

- Today 与 Mine 铃铛图标上的未读红点由真实后端未读数驱动。
- 分组列表页（今天/昨天/更早）使用 l10n 键，不硬编码中文。
- 分页 load-more、批量标为已读、滑动删除。
- 详情页带动作路由（「去处理」根据通知类型导航）。
- 通知类型 chip 使用 l10n 键，不硬编码英文直出。
- 详情页 `markAsRead` 在打开时自动调用（接口链路已反转）。
- 显式标为未读/删除动作。
- 后端在 AI 摘要完成、报告导出完成、密码变更时生成通知。

## 安全 PIN 码

- 启用 PIN 码需二次输入确认（`confirmPin` 参数校验两次输入一致）。
- PIN 码替代 2FA / TOTP 双因素认证。

## 账号与安全

- 退出登录 tile（`ConsumerWidget` + `authSessionProvider`），未登录时使用 `primary` 色而非 `error` 色（登录引导不被渲染成危险操作）。
- 退出登录接入 `showDangerConfirmationDialog` 二次确认。
- 账号注销支持密码和邮箱验证码两种确认方式（OAuth-only 用户通过验证码注销）。
- `AuthAccountNotifier` 接入 `CooldownTimerMixin` 实现验证码发送倒计时。

## 助手入口

- Today 顶部栏暴露一级助手入口 → `/assistant` 工作区。
- Settings 保留相同的能力/权限控制作为二级入口。
- 助手工作区读取真实 Lucent capabilities，发送真实 SSE 流式请求，Markdown 渲染。
- 流式滚底优化：仅当用户已处于底部附近时自动滚底；用户上翻后显示"回到底部"悬浮按钮。

## 数据层

- `SettingsProfileRemoteDataSource` 通过 `generated/lucent_api` Retrofit 客户端访问。
- `updatePreferences` 接受 `Object?` 类型参数（sentinel 区分"不修改"与"设为 null"）。
- `UserSettingsController` 状态类型从 DTO 改为 domain `UserSettings` 实体。
- 日期格式化通过 `lib/core/utils/date_format_utils.dart`，不使用手写 `padLeft` 拼接。

## 2026-07-19 补充

### Mine 档案链路

- `_ArchiveRow` 改为 `ConsumerWidget`，有记录时弹出记录列表 bottom sheet（`_showRecordListSheet`），点击具体记录跳 `/:id/edit`，底部"添加新记录"按钮跳新建页。
- 新增病史（condition）档案行（`heartPulse` 图标）。
- "待补充"颜色从 `destructive` 改为 `SemanticColor.warning`。
- "隐私报告"入口从 `AppRoutes.settings` 改为 `AppRoutes.settingsExport`。
- Hero 卡取消整卡 `FTappable`，改为 `FCard.raw`，保留内部"补全资料"主按钮。
- 头像新增编辑小徽标（pencil 图标 + primary 色圆形背景）。
- 同步失败横幅移除自带水平 padding，点击重试后增加 `AppToast` 反馈。

### 资料编辑

- 保存失败新增 `errorMessage` 监听，失败时 `AppToast.show` 显示。
- 保存按钮新增 `isSaving` 禁用 + `FCircularProgress` 进度指示器。
- 单位制下拉新增 `labelBuilder` 显示本地化标签。
- 移除 `onboardingCompleted` 状态和 `FSwitch` 开关。

### 健康表单

- 删除成功根据 `next.deleted` 区分显示 `mineEditDeletedToast`（"已删除"）。
- 三个 `FormState` 新增 `deleted` 字段。
- 保存/删除失败新增 `errorMessage` 监听。

### 表单输入细化（2026-07-19 追加）

- **IconActionButton 统一**：`mine/top_bar.dart` 的同名实现合并到 `core/shared_widgets.dart`，扩展 `showBadge` 参数支持红色小圆点未读提醒。
- **Mine 移动端底色**：从 `SemanticColor.neutral.muted` 改为 `colors.background`，与 today tab 一致。
- **缺口徽章 "+N"**：`gapCount > 2` 时显示 `mineReadinessGapMore`（"还有 N 项"）。
- **身高解析**：`profile_edit.dart` 从 `int.tryParse` 改为 `num.tryParse`，接受小数身高。
- **出生日期**：从 `FTextField` 改为 `FDateField.calendar`（日历选择器）。
- **血型**：从 `FTextField` 改为 `FSelect<String>.rich` 下拉（A+/A-/B+/B-/AB+/AB-/O+/O-）。
- **枚举 l10n**：三个 edit 页的下拉全部接入 `health_enum_l10n.dart`，显示本地化标签。新增 `allergySeverityDescription`/`conditionStatusDescription` 在下拉 `description` 位展示各档解释。
- **记录不存在态**：从复用 `mineErrorDescription` + `todayRetryAction` 改为专用 `mineEditRecordNotFoundTitle`/`Description` + `mineEditBackAction`（"返回"）。
- **用药表单分组**：字段按语义分为三组（药品信息 / 用法用量 / 时间与备注），每组用 `SettingsSectionLabel` + `FCard.raw` 包裹。
- **用药来源隐藏**：移除 `source` 下拉和 `sourceRefId` 文本框，`source` 固定为 `manual`，不再暴露 drugbank/cn 等内部概念。
- **日期选择器**：condition 的 `diagnosedAt` 和 medicine 的 `startedAt` 改为 `FDateField.calendar`。
- **用药骨架**：`MineEditFormLoading` 的 `blockHeights` 改为 6 块，与用药表单实际字段数一致。
- **共享日期选择器**：新增 `lib/core/widgets/common/date_picker.dart`（`showForuiDatePicker`），供全 App 统一使用。
- **通知加载态**：`notifications_reminders.dart` 的 `orElse` 从 `placeholderNoData` 改为 `mineNotificationInboxLoadingSummary`（"加载中…"）。
