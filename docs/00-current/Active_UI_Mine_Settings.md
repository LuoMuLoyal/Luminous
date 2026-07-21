# Active UI — Mine / Settings

Last updated: 2026-07-21（法律合规 P0 补全 + P1 实施）

## Mine 根页结构

移动端：`单一档案状态主卡 → 健康档案分组 → AI 与隐私分组 → 通知与提醒分组 → 账号与安全分组`。

桌面端双栏：`Row[左7: AccountHero+Archive+NotificationsReminders | 右5: AiPrivacy+AccountSecurity]`，顶部可选 `MineSyncFailedBanner`。

- 未登录时登录门槛、preview 说明和主 CTA 并入 Mine 主卡，顶部独立的 `SignInHintBanner` 已移除，避免与 Hero 卡重复。
- 健康档案分组在未登录 preview 数据为空时，不再渲染空 `FTileGroup`，而是显示 `_ArchiveEmpty` 结构化空态卡片（图标 + 标题 + 描述）。
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
- 未登录 preview 状态下 `MineArchiveSection` 显示显式空态：`mineArchiveEmptyTitle`（"健康数据需登录后查看" / "Health data available after sign in"）+ `mineArchiveEmptyDescription`，不再留空白区域。
- 身高字段从 `int.tryParse` 改为 `num.tryParse`，修复 double 身高值丢数据。
- 健康表单枚举使用 `health_enum_l10n.dart` 提供 l10n 映射。
- 删除操作接入 `showDangerConfirmationDialog` 二次确认（allergy/condition/medicine 三处编辑页）。

## 设置页结构

标准 app 模式，五个分组：Account & Security / Notifications / Privacy / General / About。

- 两态切换使用内联 switch。
- 多态项路由到子页。
- 睡眠提醒页与免打扰页均使用主开关；关闭时时间区显示 `settingsNotificationsTimeUnset`（"未设置"）muted 占位，开启时才渲染 `FTimeField.picker`。开启瞬间若时间为 null，controller 会持久化语义默认值（睡眠 23:00–07:00、免打扰 22:00–07:00），保证列表页与子页一致。
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
- **AI 设置开关写入时序修复**（2026-07-19 P1-2）：`AiSettingsPage` 改为 `ConsumerStatefulWidget`，新增本地 `_isPatching` 状态——任一 PATCH 进行中时所有开关禁用，避免快速连点用 stale 快照翻转两次。所有开关 `onPress` 点击瞬间通过 `ref.read(...).value` 读最新值再翻转，`onChange` 直接用 `FSwitch` 回传值；四个上下文开关的 `AssistantContextPatch` 也在点击时基于最新 state 构造。写入统一走 `runGuarded` + `AppToast.show`，失败显示 `error.message` 或 `settingsSyncFailed` 兜底。
- **免打扰/睡眠提醒默认值一致性修复**（2026-07-19 P1-2）：`NotificationSettingsController.build()` 不再为四个时间字段兜底默认值，null 即"从未设置"；`setSleepReminderEnabled(true)`/`setDndEnabled(true)` 在时间为 null 时持久化语义默认值；`reset()` 显式将四个时间字段置 null。

## 主题

- 双层选择：显示模式 `system / light / dark` + 颜色主题 `blue / green / neutral / orange / red / rose / slate / violet / yellow / zinc`。
- 只保留 `theme.mode` 与 `theme.family` 两个本地偏好。
- 高对比度模式使用 `HighContrastColors` 常量类。

## 通知

- Today 与 Mine 铃铛图标上的未读红点由真实后端未读数驱动。
- 分组列表页（今天/昨天/更早）使用 l10n 键，不硬编码中文。
- 分页 load-more、批量标为已读、滑动删除。
- 侧滑操作支持切换已读/未读状态（未读→标读 info 色、已读→标未读 warning 色）与删除（destructive 色），两个 action 平分 50% 宽度并带文字标签。
- 未读圆点外包 `Semantics(label: notificationUnreadSemantics)`，读屏可识别。
- 详情页带动作路由（「去处理」根据通知类型导航）。
- 通知类型 chip 使用 l10n 键，不硬编码英文直出。
- 通知类型支持：`ai_today_summary`、`ai_proactive_suggestion`、`medicine_missed_dose`、`password_changed`、`report_generated`、`medicine_reminder`、`system_announcement`、`oauth_login`（登录提醒，destructive 色）、`identity_linked`（绑定提醒，primary 色）、`unknown` 兜底。
- 详情页 `markAsRead` 在打开时自动调用（接口链路已反转）。
- 显式标为未读/删除动作。
- 后端在 AI 摘要完成、报告导出完成、密码变更时生成通知。
- **列表懒加载**（2026-07-19 P1-3）：通知列表从 `ListView(shrinkWrap: true)` + for 循环全量渲染改为 `ListView.builder` + 拍平 entries 懒加载。新增 `sealed class _ListEntry`（`_HeaderEntry`/`_ItemEntry`/`_LoadMoreEntry`），`_buildEntries()` 将分组结果拍平为单一列表，`itemBuilder` 用 `switch` 模式匹配按类型渲染，只构建可见区域的行。

## 安全 PIN 码

- 启用 PIN 码需二次输入确认（`confirmPin` 参数校验两次输入一致）。
- PIN 码替代 2FA / TOTP 双因素认证。

## 账号与安全

- 退出登录 tile（`ConsumerWidget` + `authSessionProvider`），未登录时使用 `primary` 色而非 `error` 色（登录引导不被渲染成危险操作）。
- 退出登录接入 `showDangerConfirmationDialog` 二次确认。
- 账号注销支持密码和邮箱验证码两种确认方式（OAuth-only 用户通过验证码注销）。
- 注销区域顶部显示注销政策提示文字 + ghost 按钮跳转 `/legal/account-cancellation`（2026-07-21 P1）。
- `AuthAccountNotifier` 接入 `CooldownTimerMixin` 实现验证码发送倒计时。

## 助手入口

- Today 顶部栏暴露一级助手入口 → `/assistant` 工作区。
- Settings 保留相同的能力/权限控制作为二级入口。
- 助手工作区读取真实 Lucent capabilities，发送真实 SSE 流式请求，Markdown 渲染。
- 流式滚底优化：仅当用户已处于底部附近时自动滚底；用户上翻后显示"回到底部"悬浮按钮。
- 控制面板（启用 AI 对话 / 持久化记忆 / 4 个上下文开关）从对话页底部常驻移入右侧抽屉（`_AssistantControlsSheet`），顶栏新增 `settings2` 图标按钮打开，释放对话区垂直空间。
- 助手禁用时的提示文案指向右上角设置入口（"在右上角设置中打开启用 AI 对话开关"）。

## 数据层

- `SettingsProfileRemoteDataSource` 通过 `generated/lucent_api` Retrofit 客户端访问。
- `updatePreferences` 接受 `Object?` 类型参数（sentinel 区分"不修改"与"设为 null"）。
- `UserSettingsController` 状态类型从 DTO 改为 domain `UserSettings` 实体。
- 设置写入成功后发射 `DataChangeTopic.userSettings`，`todayDashboardProvider` 监听该事件，因此修改饮水目标、AI 摘要开关等设置后今日页会自动刷新。
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

## 法律文档

- About 页法律入口完整覆盖 7 种文档类型（2026-07-21 P0 补全 + P1）：隐私政策、服务条款、医疗免责声明、未成年人保护、第三方 SDK、权限使用说明、账号注销政策，均跳转 App 内 `/legal/:docType`。
- 列表页展示 7 种文档类型（条款/隐私/免责/未成年人保护/SDK 列表/权限/账号注销），每项带类型图标 + 标题 + 更新时间。
- 详情页从滚动 `Markdown` 改为 `MarkdownBody` + `SingleChildScrollView`，支持文本选择（`selectable: true`）。
- 正文字号从 `TypographyToken.level3`（14px）升级为 `level4`（16px），行高 `1.7`，长文阅读更舒适。
- h1/h2/h3 字号升级（level7/level6/level5）并添加段落间距（`h1Padding`/`h2Padding`/`h3Padding`）。
- 详情页包裹 `ResponsiveContentFrame` 限宽，宽屏不再通栏。
- 页面标题使用文档名（`doc.title`）替代固定"法律文件"。
- 正文顶部显示更新时间（`legalListUpdatedAt` + locale 感知 `formatDateTimeLabel`）。

## 2026-07-19 P2 低级一致性打磨

### Settings 模块

- **单 tile 分组合并**：`page.dart` 的 `_DataStorageSection`（单 tile）合并到 `_GeneralSection` 的 `FTileGroup`，消除碎片化分组。`_GeneralSection` 新增 `dataStorageSettingsControllerProvider` 订阅和 `_retentionLabel` 方法。
- **开源许可重复入口移除**：移除 `advanced.dart` 中重复的"开源许可"tile（`about.dart` 已有同一入口），避免两个页面都能进入相同 `showLicensePage`。
- **关于页 URL 常量化**：`about.dart` 的硬编码 `https://luminous.app/support` 提取为文件级私有常量 `_kFallbackSupportUrl`。

## 2026-07-20 P0 修复

- **帮助页空态/错误态去重**：`help.dart` 的空态和错误态 `AppStateMessageView` 移除 `description` 参数（此前 `description` 与 `title` 完全相同）。
- **高级设置页残余标题清理**：`advanced.dart` 移除已删除分组的残留 `SettingsSectionLabel`。

### Notification 模块

- **通知详情 typed route**：`list.dart` 的通知项点击从字符串拼路由 `context.push('/notifications/${item.id}')` 改为 typed route `NotificationDetailRoute(id: item.id).push(context)`，与项目其他路由一致，获得编译期路径校验。

## 2026-07-20 P1 修复

- **用药表单常用值选择器**：`current_medicine_edit.dart` 剂量和给药途径文本框下方新增 `_QuickSelectChip` 快速选择芯片（剂量 4 值 + 途径 4 值），点击直接填入。
- **PIN 校验行内 error**：`security_pin.dart` 从 toast 改为行内 `error: Text(...)` 显示校验错误。6 个 `ValueNotifier<String?>` 管理各字段错误，`useEffect` 注册 controller listener 自动清除。
- **帮助页重试 action**：`help.dart` 错误态新增 `actionLabel` + `onAction`（`ref.invalidate` 重载）。
- **弹层勾选图标占位**：`advanced.dart` + `feature_flags.dart` 的 `suffix` 从条件 null 改为始终渲染 `SettingsSelectionIcon(selected: ...)`，消除选中/未选间布局跳变。

## 2026-07-20 P2 我的/设置模块打磨

- **角色文案中性化**：`mineAccountStudentRole` 从"大学生"/"Student" 改为"用户"/"User"。
- **无引用残留清理**：删除 `health_enum_l10n.dart` 中零引用的 `medicineSourceLabel` 函数；删除 `MineCopyKey.archiveRecordListTitle` 枚举值及 `copy.dart` 对应映射。
- **SyncBanner 注释修正**：`skeleton_view.dart` 类文档注释从 `SyncBanner` 改为 `MineSyncFailedBanner`。
- **免打扰 subtitle→details**：`notification.dart` 的 DnD tile 从 `subtitle:` 改为 `details:`，与同组其余 tile 一致。
- **垂直 padding helper 统一到全部子页**：`dnd.dart`、`sleep_reminder.dart`、`ai.dart`、`accessibility.dart`、`advanced.dart`、`data_storage.dart`、`feature_flags.dart`、`security_pin.dart`、`theme.dart` 共 9 个子页的内联三元表达式替换为 `settingsPageVerticalPadding(context)` 共享函数。
- **验证码冷却期禁用**：`change_email.dart` 的 `onSendCode` 在 `lastCooldownSeconds != null`（冷却中）时设为 `null`，防止冷却期间重复点击发送。
- **助手 provider 硬编码文案清理**：`conversation.dart` 的 `sendError` 从硬编码中文改为 `null`；`LucentApiException` 消息从中文改为英文。

## 2026-07-21 审查修复

- **通知列表 hover 性能优化**：`list_item.dart` 的 `_isHovered` 从 `bool` + `setState` 改为 `ValueNotifier<bool>` + `ValueListenableBuilder`。鼠标 hover/退出时仅重建操作按钮区域，不再触发整个列表项 widget 的 `build`，减少快速滚动时的不必要的重建开销。
