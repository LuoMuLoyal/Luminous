---
status: active
owner: frontend
quadrant: reference
updated: 2026-08-20
---

# Active UI — Mine / Settings

Last updated: 2026-08-20（P1-2 B1：通知偏好远端权威同步、旧 SharedPreferences 一次迁移、四个通知开关接真实消费者；睡眠提醒仅按 bedtime 调度；P1-1 与 Mine 改造项 6/7/8 保持不变）

## Mine 根页结构

移动端：`单一档案状态主卡 → 档案提醒 → 健康档案分组 → AI 与隐私分组 → 通知与提醒分组 → 账号与安全分组`。

桌面端双栏：`Row[左7: AccountHero+StatusAlerts+Archive+NotificationsReminders | 右5: AiPrivacy+AccountSecurity]`，顶部可选 `MineSyncFailedBanner`。

- 未登录时登录门槛、preview 说明和主 CTA 并入 Mine 主卡，顶部独立的 `SignInHintBanner` 已移除，避免与 Hero 卡重复。
- 健康档案分组在未登录 preview 数据为空时，不再渲染空 `FTileGroup`，而是显示 `_ArchiveEmpty` 结构化空态卡片（图标 + 标题 + 描述）。
- 健康档案入口使用 Forui `FTileGroup + FTile`，状态通过明确文字表达。
- `通知与提醒` 分组只承接状态摘要与跳转（提醒设置/免打扰/通知收件箱），收件箱未读数来自真实后端。
- `AI 与隐私` 分组：`AI 设置` → `/settings/ai`，`报告分享` → `/settings`。
- `账号与安全` 分组：`账号与安全` → `/account`，`安全 PIN 码` → `/settings/security-pin`。
- Mine 主卡文案区分 `preview / 缺失关键信息 / 基本就绪` 三种 readiness 语义。
- Hero 描述文案动态化：根据 `_deriveGaps` 返回的缺失字段类型生成针对性描述（单缺口显示具体说明，多缺口显示汇总）。
- 缺口检测 5 项：`basicInfo` / `sexAtBirth` / `weight` / `allergy` / `medicine`。`emergencyContact` 为不排期字段（标注延后，填了无业务用途），不再作为 gap 引导用户填写。
- 角色文字"用户"已移除，Hero 不再显示角色胶囊。
- 登录胶囊替换为邮箱验证状态：已验证 → `primary` 蓝色白字；未验证 → `secondary` + warning 色；preview → `secondary` 灰色。
- 完整度计算 6 项（按「有用」而非「有值」计）：`allergyCount` / `currentMedicineCount` / `birthDate` / `heightCm` / `sexAtBirth` / `weightKg`。`onboardingCompleted` 是引导流程状态字段，当前无任何写入方（无 onboarding 流程），暂不纳入完成度；待有真实引导流程写入方后再纳入。
- 资料编辑页新增：生理性别下拉、体重输入、紧急联系人姓名/电话。

## 档案提醒（改造项 6）

- `MineStatusAlertsSection`（`sections/status_alerts.dart`）渲染在 `MineAccountHero` 之后、`MineArchiveSection` 之前，仅 `dashboard.alerts.isNotEmpty` 时显示；单 `FCard` 列表，每行 icon + 标题 + 副标题 + 右侧 badge，样式对齐健康档案条目。
- 副标题/badge 由展示层按结构化数据拼接（本地化与截断属展示层职责，data 层只携带结构化 `kind` / `items` / `count`）：过敏/用药卡 items 非空时，副标题为真实 label/药名前 2 项按分隔符拼接（zh「、」/ en ", "）+ 超出追加「等 N 项/种」后缀（`mineAlertAllergyMore/MedicineMore(count)`）；badge 为计数文案（`mineAlertAllergyCount/MedicineCount(count)`）；隐私卡走 `subtitleKey` / `badgeKey` 静态文案。
- 过敏卡：仅 `activeAllergyCount > 0` 且存在 isActive 过敏时生成，items 为真实 active 过敏 label 全量，count 为 `activeAllergyCount`。
- 用药卡：仅 `currentMedicineCount > 0` 时生成，items 为真实 isCurrent 药物 displayName 全量，count 为 `currentMedicineCount`；不再显示「按时服用」断言（无数据支持）。
- 隐私卡：保留，为静态产品提示（分享前先预览确认 / 先确认），非用户数据。
- 档案缺口（`missingCoreProfileFields`）不生成卡片：缺口已由 MineAccountHero 的 gap 展示（完成度/缺口口径一致），避免重复表达。
- 卡片顺序：过敏 → 用药 → 隐私；`MineStatusCard` 承载结构化数据（`kind` / `items` / `count`），`MineCopyKey` 仅保留 title 与隐私卡静态键。

## 同步失败警告

- `MineSyncFailedBanner` 在 Mine 页面顶部展示同步失败警告（warning 色 subtle 背景 + border + cloudAlert 图标）。点击“查看详情”打开 Forui 详情对话框，展示失败条目的数据类型、操作、记录 ID、尝试次数、加入时间和最近错误。
- `syncFailedCountProvider` 查询 `PendingSyncDao.permanentlyFailedCount()`。
- 详情对话框的“全部重试”会先通过 `PendingSyncDao.resetForRetry` 清除永久失败状态，再调用 `SyncWorker.flush()`；查看详情本身不再显示 Toast 占位提示。
- “全部重试”失败的异常不再静默吞掉：记录到 `talker`（release 下经 `SentryTalkerObserver` 上报 Sentry），界面仍显示通用错误文案。`_retryAll` 改用 `try/finally` 保证无论成功、失败或异常都重置 `_isRetrying`，防止按钮长期处于 loading（2026-08-04）。
- **用户面/诊断面分离（2026-08-13）**：
  - `Last error` 区域不再直接展示原始 `DioException` / `LucentApiException` 字符串，而是显示本地化友好提示（网络超时、数据校验失败、服务器错误、登录过期等）。
  - 原始错误、traceId、业务码、HTTP status 被折叠在「诊断信息」面板内，点击展开；面板提供「复制诊断信息」按钮，便于用户反馈问题时粘贴完整信息。
  - 实现依赖：`SyncWorker` 写入时用 `LucentErrorMapper.toAppError` 生成 `PendingSyncErrorDetails` 并存入 `pending_sync_items.lastErrorDetails`；旧版本只写入 `lastError` 的条目仍兼容，用户面降级为通用提示，诊断面板仍可展示原始字符串。

## 健康档案

- 基础健康档案（身高/体重等）。
- 过敏史编辑（预填充+更新+删除）。
- 当前用药。
- 疾病史编辑（预填充+更新+删除）。
- 未登录 preview 状态下 `MineArchiveSection` 显示显式空态：`mineArchiveEmptyTitle`（"健康数据需登录后查看" / "Health data available after sign in"）+ `mineArchiveEmptyDescription`，不再留空白区域。
- 身高字段从 `int.tryParse` 改为 `num.tryParse`，修复 double 身高值丢数据。
- 健康表单枚举使用 `health_enum_l10n.dart` 提供 l10n 映射。
- 删除操作接入 `showDangerConfirmationDialog` 二次确认（allergy/condition/medicine 三处编辑页）。
- 单位制显示切换（改造项 7）：档案 `unitSystem`（`metric | imperial`，设置页/资料编辑页有真实填写入口）接入**纯展示换算**——档案区体重行 imperial 时显示 lb（`weightInLb`：kg × 2.2046226218 后 round()，与 kg 行取整展示一致），metric/未设置显示 kg；身高行恒 cm（计划未列身高）。存储口径不变，仅展示换算；换算工具在 `lib/features/health_context/domain/services/unit_conversion.dart`。摘要瓦片、饮水角标、today 概览等其它 ml 展示点**不做**（保持存储口径 ml）。

## 健康数据导入与自动同步

- 健康数据页保留手动导入；不支持的平台显示具体原因，仅将 iOS HealthKit 和已安装且可用的 Android Health Connect 视为可用平台。
- 自动同步状态由 `healthAutoSyncAvailabilityProvider` 区分 `unsupported`、`notConfigured` 和 `available`。当前应用尚未配置后台执行器，因此平台可用时仍显示“仅支持手动导入”，设置中的自动同步开关保持禁用。
- 健康平台导入使用 external ID 优先、稳定字段指纹回退的去重策略；同日多条饮水与睡眠 episode 不再因日期合并而丢失。

## 设置页结构

标准 app 模式，五个分组：Account & Security / Notifications / Privacy / General / About。

- 两态切换使用内联 switch。
- 多态项路由到子页。
- 睡眠提醒页与免打扰页均使用主开关；关闭时时间区显示 `settingsNotificationsTimeUnset`（"未设置"）muted 占位，开启时才渲染 `FTimeField.picker`。开启瞬间若时间为 null，controller 会持久化语义默认值（睡眠 23:00–07:00、免打扰 22:00–07:00），保证列表页与子页一致。
- 保留期缩短确认：若新期限短于当前期限（含 forever→有限），弹出 `showDangerConfirmationDialog` 二次确认。
- 恢复默认设置接入 `showDangerConfirmationDialog` 二次确认，使用 `destructive` 红色样式 + 副标题提示。
- 通知 key 统一通过 `PrefKeys` 管理。
- 快速记录分组现在只保留 `settings-row-quick-entry` 次入口，跳转到
  `/record/quick-entry-settings`。动态排序、手动排序、饮水默认量、饮水角标和睡眠进行中标记由 Record 的快速记录设置页承载，不再在 Settings 根页直接显示开关。

### 设置模块细化（2026-07-19 追加）

- **垂直 padding 统一**：新增 `settingsPageVerticalPadding(BuildContext)` 函数（`settings/presentation/utils/settings_page_padding.dart`），统一响应式 `Spacing.level6`/`level7` 逻辑，`page.dart` 使用该函数替代固定 24。
- **分组标题统一**：删除 `page.dart` 内部 `_SettingsGroup` 自定义实现，统一使用 `SettingsSectionLabel`（`settings/presentation/widgets/shared/settings_section_label.dart`），所有分组改为 `SettingsSectionLabel` + `FTileGroup` 标准模式。
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
- **AI 设置上下文开关 toast + AI 隐私说明**（T8，2026-08-17）：`_guardedApply` 返回 `Future<bool>`（成功 true / 失败 false，失败仍走原错误 toast）；四个上下文开关（健康档案/日常记录/睡眠记录/当前用药）切换成功 toast「上下文开关将在下次对话生效」（`settingsAiContextChangeNextTurnToast`），通用开关（AI 总结/助手/记忆）不提示；上下文开关组下方新增「AI 隐私」小节（`SettingsSectionLabel` + 三行小字），说明记忆提炼要点用于后续对话、勾选来源在对话时提供给 AI、关闭开关不删除历史数据仅停止后续使用。
- **免打扰/睡眠提醒默认值一致性修复**（2026-07-19 P1-2）：`NotificationSettingsController.build()` 不再为四个时间字段兜底默认值，null 即"从未设置"；`setSleepReminderEnabled(true)`/`setDndEnabled(true)` 在时间为 null 时持久化语义默认值；`reset()` 显式将四个时间字段置 null。

### P1-2 B1 通知偏好与执行器（2026-08-20）

- `NotificationSettingsController` 登录后读取 Lucent `/api/v1/user/notification-preferences`；远端 `configured=true` 覆盖本地缓存，首次 `configured=false` 才把既有 SharedPreferences 值迁移一次。迁移成功写入完成标记，网络/PATCH 失败保留可重试状态；设置 PATCH 失败回滚内存与本地缓存。
- `healthAlerts`、`weeklySummary`、`waterReminders`、`sleepReminderEnabled` 均有真实消费者：前三者由 Lucent 规则/周洞察链路门禁，睡眠由独立 `SleepReminderNotificationCoordinator` 调度。
- 睡眠提醒复用 `LocalNotificationGateway`，使用稳定计划 ID 与 PrefKeys 取消旧计划；只在就寝时间生成未来 7 天计划，不把 `sleepWakeTime` 作为闹钟，并遵循通知权限、DND、声音/振动和网关失败降级。

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
- 通知类型支持：`ai_today_summary`、`ai_weekly_insight`、`ai_proactive_suggestion`、`medicine_missed_dose`、`password_changed`、`report_generated`、`medicine_reminder`、`system_announcement`、`oauth_login`（登录提醒，destructive 色）、`identity_linked`（绑定提醒，primary 色）、`unknown` 兜底。
- 详情页 `markAsRead` 在打开时自动调用（接口链路已反转）。
- 显式标为未读/删除动作。
- 后端在 AI 摘要完成、报告导出完成、密码变更时生成通知。
- **列表懒加载**（2026-07-19 P1-3）：通知列表从 `ListView(shrinkWrap: true)` + for 循环全量渲染改为 `ListView.builder` + 拍平 entries 懒加载。新增 `sealed class _ListEntry`（`_HeaderEntry`/`_ItemEntry`/`_LoadMoreEntry`），`_buildEntries()` 将分组结果拍平为单一列表，`itemBuilder` 用 `switch` 模式匹配按类型渲染，只构建可见区域的行。
- **列表骨架屏宽度**（2026-07-26）：`loading` 态使用 `StateSkeletonView` + 满宽 `StateSkeletonBlock(height: 64)`，修复原先 96px fallback 的窄骨架条。

## 安全 PIN 码

- 启用 PIN 码需二次输入确认（`confirmPin` 参数校验两次输入一致）。
- PIN 码替代 2FA / TOTP 双因素认证。

## 账号与安全

- 退出登录 tile（`ConsumerWidget` + `authSessionProvider`），未登录时使用 `primary` 色而非 `error` 色（登录引导不被渲染成危险操作）。
- 退出登录接入 `showDangerConfirmationDialog` 二次确认。
- 修改邮箱、修改密码、解绑三方身份在各自页面回调中先执行 `showSecurityElevationDialog(context, ref)`；已有有效 elevation token 自动跳过 PIN 对话框，后续请求由 `SecurityElevationInterceptor` 注入请求头。
- 纯页面入口 preflight 是兼容假设：`AuthAccountNotifier` 与认证领域接口保持 UI 无依赖，由页面在确认/表单校验后决定是否发起敏感操作；取消或未启用 Security PIN 时不调用后端。
- 敏感操作收到明确的 403/elevation-token-invalid 响应时，`AuthAccountState.requiresSecurityElevation` 提供机器可读状态，页面使用“请验证安全 PIN”引导文案；普通解绑业务 403 不复用该状态。
- P1-1 复审确认的两个 follow-up 已登记到 `docs/00-current/TODO.md`，当前仍未修复：settings provider loading/error 时 `asData == null` 的未知状态误判，以及 token/dialog 到期边界统一与精确到期测试。
- 账号注销支持密码和邮箱验证码两种确认方式（OAuth-only 用户通过验证码注销）。
- 注销区域顶部显示注销政策提示文字 + ghost 按钮跳转 `/legal/account-cancellation`（2026-07-21 P1）。
- `AuthAccountNotifier` 接入 `CooldownTimerMixin` 实现验证码发送倒计时。

## 助手入口

- Today 顶部栏暴露一级助手入口 → `/assistant` 工作区。
- Settings 保留相同的能力/权限控制作为二级入口。
- 助手工作区读取真实 Lucent capabilities，发送真实 SSE 请求；当前部分 graph 回答是在后端完成生成后按空白切分回放，真实 token 级增量链路待后续改造。Markdown 渲染使用基础 `MarkdownBody`，模板升级另列 TODO。
- 流式滚底优化：仅当用户已处于底部附近时自动滚底；用户上翻后显示"回到底部"悬浮按钮。
- 控制面板（启用 AI 对话 / 持久化记忆 / 4 个上下文开关）从对话页底部常驻移入右侧抽屉（`_AssistantControlsSheet`），顶栏新增 `settings2` 图标按钮打开，释放对话区垂直空间。
- 助手禁用时的提示文案指向右上角设置入口（"在右上角设置中打开启用 AI 对话开关"）。

## 数据层

- `SettingsProfileRemoteDataSource` 通过 `generated/lucent_api` Retrofit 客户端访问。
- `updatePreferences` 接受 `Object?` 类型参数（sentinel 区分"不修改"与"设为 null"）。
- `NotificationPreferencesRepository` 映射生成的偏好 DTO；nullable 睡眠时间清除时经 `LucentApiPaths` 使用 raw PATCH JSON，避免生成 DTO 的 `includeIfNull=false` 丢失显式 null。
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

- **IconActionButton 统一**：`mine/top_bar.dart` 的同名实现合并到 `core/widgets/common/icon_action_button.dart`，扩展 `showBadge` 参数支持红色小圆点未读提醒。
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
- 正文 Markdown 样式走 `MarkdownStyle.legal(context)`（正式文档样式，见 [[Design_System#Markdown 渲染]]，2026-08-03 起统一）。
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

- **角色文案移除**：Hero 区域不再显示角色胶囊（原 `mineAccountStudentRole` "用户"/"User" 已移除），替换为邮箱验证状态徽章。
- **无引用残留清理**：删除 `health_enum_l10n.dart` 中零引用的 `medicineSourceLabel` 函数；删除 `MineCopyKey.archiveRecordListTitle` 枚举值及 `copy.dart` 对应映射。
- **SyncBanner 注释修正**：`skeleton_view.dart` 类文档注释从 `SyncBanner` 改为 `MineSyncFailedBanner`。
- **免打扰 subtitle→details**：`notification.dart` 的 DnD tile 从 `subtitle:` 改为 `details:`，与同组其余 tile 一致。
- **垂直 padding helper 统一到全部子页**：`dnd.dart`、`sleep_reminder.dart`、`ai.dart`、`accessibility.dart`、`advanced.dart`、`data_storage.dart`、`feature_flags.dart`、`security_pin.dart`、`theme.dart` 共 9 个子页的内联三元表达式替换为 `settingsPageVerticalPadding(context)` 共享函数。
- **验证码冷却期禁用**：`change_email.dart` 的 `onSendCode` 在 `lastCooldownSeconds != null`（冷却中）时设为 `null`，防止冷却期间重复点击发送。
- **助手 provider 硬编码文案清理**：`conversation.dart` 的 `sendError` 从硬编码中文改为 `null`；`LucentApiException` 消息从中文改为英文。

## 2026-07-21 审查修复

- **通知列表 hover 性能优化**：`list_item.dart` 的 `_isHovered` 从 `bool` + `setState` 改为 `ValueNotifier<bool>` + `ValueListenableBuilder`。鼠标 hover/退出时仅重建操作按钮区域，不再触发整个列表项 widget 的 `build`，减少快速滚动时的不必要的重建开销。

## 2026-07-27 About 页面重构

- **App 元数据来源切换**：About 页面不再从 `GET /api/v1/public/app-info` 获取 App 名称/版本/描述/构建日期（那些是后端 `package.json` 的值），改为使用 `package_info_plus` 获取客户端自身的 App 名称、版本号和构建号。
- **横向布局**：顶部卡片从居中垂直排列改为横向 `Row`：左侧 App 图标 (`assets/icon/app_icon.png`，64x64) + 右侧 App 名称、版本号 (`版本 x.y.z · Build n`)、tagline。
- **Tagline**：新增 `settingsAboutTagline` ARB key，展示一句话产品描述。
- **API 精简**：后端 `app-info` 端点移除 `name`/`version`/`description`/`buildDate` 字段，只返回 `supportEmail` 和 `minClientVersion`（通过环境变量配置）。
- **l10n 清理**：移除不再使用的 `settingsAboutBuildNumberLabel` 和 `mineSettingAboutValue`；新增 `settingsAboutVersionLabel`（带 `{version}` 占位符）和 `settingsAboutBuildLabel`（带 `{buildNumber}` 占位符）。

## 2026-07-28 About 页面版本检查

- **检查更新 tile**：About 页新增“检查更新” tile，点击后通过 `ref.invalidate(appInfoProvider)` 强制刷新后端 `GET /api/v1/public/app-info`，获取 `latestVersion` 和 `downloadUrl`，与本地 `package_info_plus` 版本通过 `compareSemver()` 比较。
- **状态机**：`idle → checking → upToDate / updateAvailable / checkFailed`。各状态在 tile subtitle 中显示对应文案（success/warning/destructive 色）。checking 态在 suffix 位置显示 `CircularProgressIndicator`，其余态显示 `SemanticIcons.actionRefresh`。
- **自动打开下载页**：发现新版本时自动通过 `ExternalUrlLauncher` 打开 `downloadUrl`（如果后端配置了）。
- **后端字段**：`AppInfoDataDto` 新增 `latestVersion` 和 `downloadUrl`，通过 `LATEST_VERSION` 和 `DOWNLOAD_URL` 环境变量配置。
- **`kFallbackSupportUrl`**：从 `https://luminous.app/support` 修正为 `https://github.com/LuoMuLoyal/Luminous`。
- **l10n**：新增 `settingsAboutCheckUpdate` / `settingsAboutCheckUpdateChecking` / `settingsAboutCheckUpdateUpToDate` / `settingsAboutCheckUpdateAvailable`（带 `{version}` 占位符）/ `settingsAboutCheckUpdateFailed`。

## 2026-07-28 帮助页面自包含重构

- **后端依赖移除**：帮助页面不再消费 `supportResourcesProvider('help')`，FAQ 和反馈入口全部前端自包含。
- **FAQ 本地 Markdown**：新增 `assets/faq/faq_zh.md` 和 `faq_en.md`，按 `## ` 标题切分为多个 `_FaqItem`，每个 Q&A 使用 `FCollapsible` 可折叠展开，答案用 `MarkdownBody` 渲染。加载态使用 `InlineSkeleton` 骨架屏，错误态有重试按钮。
- **FAQ 答案 Markdown 样式**（2026-08-03）：走 `MarkdownStyle.legal(context)` 正式文档样式（见 [[Design_System#Markdown 渲染]]）。
- **反馈入口环境变量**：反馈 tile 通过 `EnvReader.string(EnvKey.supportEmail)` 获取 `SUPPORT_EMAIL` 环境变量，构造 `mailto:` URI 唤起邮件客户端。邮箱未配置时 toast 提示，打开失败时也 toast 提示。
- **l10n 变更**：新增 6 个 settings 键（`settingsHelpFaqSectionTitle`、`settingsHelpFaqLoadError`、`settingsHelpFeedbackSectionTitle`、`settingsHelpFeedbackSubject`、`settingsHelpFeedbackUnavailable`、`settingsHelpFeedbackOpenFailed`）；删除 mine 分片中未使用的 `mineHelpFaqTitle` / `mineHelpFaqSubtitle`。
- **后端反馈配置**：反馈入口通过 `appInfoProvider` 读取 Lucent 的 `supportEmail`，不再有服务端资源列表依赖。
- **反馈邮箱优先级**：`_FeedbackSection` 优先读后端 `appInfoProvider` 的 `supportEmail`，回退到编译期 `SUPPORT_EMAIL` 环境变量。

## 2026-08-20 Support resources 清理

- 删除客户端 `supportResourcesProvider`、SupportResource 实体及资源仓储映射；FAQ 继续由本地 Markdown 自包含渲染。
- Lucent 仅保留独立 `AppInfoApi` / `appInfoProvider`，用于反馈邮箱和版本检查。
